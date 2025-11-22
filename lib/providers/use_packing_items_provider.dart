import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/packing_item.dart';
import '../services/trip/trip_service.dart';

/// Provider for managing use packing items state
/// Manages local state of packing items and handles batch updates to API
final usePackingItemsProvider = AsyncNotifierProvider.family<
    UsePackingItemsNotifier, List<PackingItem>, String>(
  () => UsePackingItemsNotifier(),
);

/// Notifier for managing packing items state
class UsePackingItemsNotifier
    extends FamilyAsyncNotifier<List<PackingItem>, String> {
  final TripService _tripService = TripService();

  /// Track which items have been modified locally
  final Set<String> _modifiedItemIds = {};

  @override
  Future<List<PackingItem>> build(String arg) async {
    debugPrint('📦 [UsePackingItems] Initializing provider for list: $arg');
    try {
      final result = await _tripService.getPackingListItems(packingListId: arg);
      if (result == null) {
        debugPrint('❌ [UsePackingItems] No data returned from API');
        throw Exception('Failed to load packing items');
      }

      final items = result['items'] as List<PackingItem>;
      debugPrint('📦 [UsePackingItems] Loaded ${items.length} items from API');
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
    debugPrint('🔄 [UsePackingItems] Toggling item: $itemId');

    state.whenData((items) {
      final itemIndex = items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        debugPrint('⚠️ [UsePackingItems] Item not found: $itemId');
        return;
      }

      final item = items[itemIndex];
      final newPackedState = !item.isPacked;

      debugPrint('📝 [UsePackingItems] Item "${item.name}" (${item.id}) changed: ${item.isPacked} → $newPackedState');

      final updatedItem = item.copyWith(isPacked: newPackedState);
      final updatedItems = [...items];
      updatedItems[itemIndex] = updatedItem;

      // Track this item as modified
      _modifiedItemIds.add(itemId);
      debugPrint('✏️ [UsePackingItems] Modified items count: ${_modifiedItemIds.length}');

      // Calculate stats for logging
      final packed = updatedItems.where((i) => i.isPacked).length;
      debugPrint('📊 [UsePackingItems] Stats: $packed/${updatedItems.length} packed (${updatedItems.length - packed} remaining)');

      state = AsyncData(updatedItems);
    });
  }

  /// Save all modified items to the API
  Future<bool> saveProgress() async {
    debugPrint('💾 [UsePackingItems] Starting save progress...');
    debugPrint('💾 [UsePackingItems] Modified items to save: ${_modifiedItemIds.length}');

    if (_modifiedItemIds.isEmpty) {
      debugPrint('⏭️ [UsePackingItems] No changes to save');
      return true;
    }

    return await state.when(
      data: (items) async {
        try {
          debugPrint('🚀 [UsePackingItems] Saving ${_modifiedItemIds.length} modified items to API');

          int successCount = 0;
          int failureCount = 0;

          // Update each modified item
          for (final itemId in _modifiedItemIds) {
            final item = items.firstWhere((i) => i.id == itemId);

            debugPrint('📤 [UsePackingItems] Updating item "${item.name}" (${item.id}): isPacked=${item.isPacked}');

            try {
              await _tripService.updateItem(
                itemId: item.id,
                isPacked: item.isPacked,
              );
              successCount++;
              debugPrint('✅ [UsePackingItems] Successfully updated item ${item.id}');
            } catch (e) {
              failureCount++;
              debugPrint('❌ [UsePackingItems] Failed to update item ${item.id}: $e');
              rethrow;
            }
          }

          debugPrint('🎉 [UsePackingItems] Save complete: $successCount succeeded, $failureCount failed');

          // Clear modified items after successful save
          _modifiedItemIds.clear();
          debugPrint('🧹 [UsePackingItems] Cleared modified items tracker');

          return true;
        } catch (e, stackTrace) {
          debugPrint('❌ [UsePackingItems] Error saving progress: $e');
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
  Future<void> refresh() async {
    debugPrint('🔄 [UsePackingItems] Refreshing items from API');

    if (_modifiedItemIds.isNotEmpty) {
      debugPrint('⚠️ [UsePackingItems] Warning: Discarding ${_modifiedItemIds.length} unsaved changes');
      _modifiedItemIds.clear();
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Check if there are unsaved changes
  bool hasUnsavedChanges() {
    final hasChanges = _modifiedItemIds.isNotEmpty;
    debugPrint('🔍 [UsePackingItems] Has unsaved changes: $hasChanges (${_modifiedItemIds.length} items)');
    return hasChanges;
  }

  /// Log a summary of items for debugging
  void _logItemsSummary(List<PackingItem> items) {
    final packed = items.where((item) => item.isPacked).length;
    final unpacked = items.length - packed;
    debugPrint('📋 [UsePackingItems] Items summary: $packed packed, $unpacked unpacked, ${items.length} total');

    // Log individual items in debug mode
    if (kDebugMode) {
      for (final item in items) {
        debugPrint('  ${item.isPacked ? '✓' : '○'} ${item.name} (${item.id})');
      }
    }
  }
}
