import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/packing_item.dart';
import '../services/trip/trip_service.dart';

/// Provider for managing packing items during the "use packing list" flow
///
/// Manages local state of packing items and handles batch updates to API.
/// Tracks changes by comparing current state against the original API data,
/// which correctly handles toggle-back scenarios (user toggles item, then
/// toggles it back to original state = no actual change).
final usePackingItemsProvider = AsyncNotifierProvider.family<
    UsePackingItemsNotifier, List<PackingItem>, String>(
  () => UsePackingItemsNotifier(),
);

/// Notifier for managing packing items state
///
/// Stores original items from API and compares against current state
/// to determine if there are actual unsaved changes.
class UsePackingItemsNotifier
    extends FamilyAsyncNotifier<List<PackingItem>, String> {
  final TripService _tripService = TripService();

  /// Original items from API - used as baseline for change detection
  List<PackingItem>? _originalItems;

  @override
  Future<List<PackingItem>> build(String arg) async {
    debugPrint('📦 [UsePackingItems] build() called for list: $arg');

    // Clear original items on rebuild (fresh start)
    _originalItems = null;

    try {
      final result = await _tripService.getPackingListItems(packingListId: arg);
      if (result == null) {
        debugPrint('❌ [UsePackingItems] No data returned from API');
        throw Exception('Failed to load packing items');
      }

      final items = result['items'] as List<PackingItem>;

      // Store deep copy of original items for change detection
      _originalItems = items.map((item) => item.copyWith()).toList();

      debugPrint('✅ [UsePackingItems] Loaded ${items.length} items');
      _logItemsSummary(items);

      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ [UsePackingItems] Error loading items: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Toggle an item's packed status (local state only)
  void toggleItemPacked(String itemId) {
    state.whenData((items) {
      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        debugPrint('⚠️ [UsePackingItems] Item not found: $itemId');
        return;
      }

      final item = items[itemIndex];
      final newPackedState = !item.isPacked;

      debugPrint(
          '🔘 [UsePackingItems] Toggle "${item.name}": ${item.isPacked} → $newPackedState');

      final updatedItems = [...items];
      updatedItems[itemIndex] = item.copyWith(isPacked: newPackedState);

      state = AsyncData(updatedItems);
    });
  }

  /// Check all items (local state only)
  void checkAllItems() {
    debugPrint('✅ [UsePackingItems] Checking all items');

    state.whenData((items) {
      final updatedItems = items.map((item) {
        return item.isPacked ? item : item.copyWith(isPacked: true);
      }).toList();

      state = AsyncData(updatedItems);
    });
  }

  /// Uncheck all items (local state only)
  void uncheckAllItems() {
    debugPrint('❌ [UsePackingItems] Unchecking all items');

    state.whenData((items) {
      final updatedItems = items.map((item) {
        return item.isPacked ? item.copyWith(isPacked: false) : item;
      }).toList();

      state = AsyncData(updatedItems);
    });
  }

  /// Save all changed items to the API
  ///
  /// Compares current state against original to find actual changes,
  /// then sends a bulk update request. Returns true on success.
  Future<bool> saveProgress() async {
    debugPrint('💾 [UsePackingItems] saveProgress() called');

    // Get items that actually changed
    final changedItems = _getChangedItems();

    if (changedItems.isEmpty) {
      debugPrint('⏭️ [UsePackingItems] No actual changes to save');
      return true;
    }

    debugPrint(
        '💾 [UsePackingItems] Saving ${changedItems.length} changed items');

    return await state.when(
      data: (items) async {
        try {
          // Build bulk update payload
          final updates = changedItems.map((item) {
            debugPrint(
                '📤 [UsePackingItems] Saving "${item.name}": isPacked=${item.isPacked}');
            return {
              'itemId': item.id,
              'isPacked': item.isPacked,
            };
          }).toList();

          final result = await _tripService.bulkUpdateItems(
            packingListId: arg,
            updates: updates,
          );

          if (result == null) {
            debugPrint('❌ [UsePackingItems] Bulk update returned null');
            return false;
          }

          final updatedCount = result['count'] as int;
          debugPrint('✅ [UsePackingItems] Saved $updatedCount items');

          // Update original items to current state (new baseline)
          _originalItems = items.map((item) => item.copyWith()).toList();
          debugPrint('🔄 [UsePackingItems] Updated baseline state');

          return true;
        } catch (e, stackTrace) {
          debugPrint('❌ [UsePackingItems] Error saving: $e');
          debugPrint(stackTrace.toString());
          return false;
        }
      },
      loading: () async {
        debugPrint('⏳ [UsePackingItems] Cannot save while loading');
        return false;
      },
      error: (e, _) async {
        debugPrint('❌ [UsePackingItems] Cannot save with error state: $e');
        return false;
      },
    );
  }

  /// Refresh items from API (discards local changes)
  ///
  /// Use this for "Reset to Saved" to ensure we have the latest from server.
  Future<void> refresh() async {
    debugPrint('🔄 [UsePackingItems] refresh() called - reloading from API');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Discard local changes and restore to original state
  ///
  /// Use this when user wants to discard unsaved changes without an API call.
  /// Fast operation since it just restores from cached original items.
  void discardChanges() {
    debugPrint('🗑️ [UsePackingItems] discardChanges() called');

    if (_originalItems == null) {
      debugPrint('⚠️ [UsePackingItems] No original items to restore');
      return;
    }

    // Restore state to original items (deep copy to avoid reference issues)
    final restoredItems =
        _originalItems!.map((item) => item.copyWith()).toList();
    state = AsyncData(restoredItems);
    debugPrint(
        '✅ [UsePackingItems] Restored ${restoredItems.length} items to original state');
  }

  /// Check if there are actual unsaved changes
  ///
  /// Compares current state against original API data.
  /// Correctly handles toggle-back scenarios.
  bool hasUnsavedChanges() {
    final hasChanges = _getChangedItems().isNotEmpty;
    debugPrint('🔍 [UsePackingItems] hasUnsavedChanges: $hasChanges');
    return hasChanges;
  }

  /// Get list of items that have changed from original state
  List<PackingItem> _getChangedItems() {
    if (_originalItems == null) return [];

    final currentItems = state.valueOrNull;
    if (currentItems == null) return [];

    final changedItems = <PackingItem>[];

    for (final currentItem in currentItems) {
      // Find original item by ID
      final originalItem = _originalItems!.firstWhere(
        (o) => o.id == currentItem.id,
        orElse: () => currentItem, // New item, treat as changed
      );

      // Compare packed status
      if (currentItem.isPacked != originalItem.isPacked) {
        changedItems.add(currentItem);
      }
    }

    return changedItems;
  }

  /// Log a summary of items for debugging
  void _logItemsSummary(List<PackingItem> items) {
    final packed = items.where((item) => item.isPacked).length;
    final unpacked = items.length - packed;
    debugPrint(
        '📋 [UsePackingItems] Summary: $packed packed, $unpacked unpacked');

    if (kDebugMode && items.length <= 20) {
      for (final item in items) {
        debugPrint('  ${item.isPacked ? '✓' : '○'} ${item.name}');
      }
    }
  }
}
