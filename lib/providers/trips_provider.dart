import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/packing_list.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing packing lists state using AsyncNotifier pattern
///
/// Handles:
/// - Loading packing lists from API on initialization
/// - Refreshing data (e.g., after login)
/// - Clearing data (e.g., on logout)
/// - Local CRUD operations (add, update, remove)
class PackingListsNotifier extends AsyncNotifier<List<PackingList>> {
  final TripService _tripService = TripService();

  @override
  Future<List<PackingList>> build() async {
    debugPrint(
        '📦 [PackingListsProvider] build() called - initializing packing lists data');

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint(
          '⚠️ [PackingListsProvider] No authenticated user, returning empty list');
      return [];
    }

    debugPrint('🔄 [PackingListsProvider] Loading packing lists from API...');
    try {
      final result = await _tripService.getPackingLists();

      if (result != null) {
        final packingLists = result['packingLists'] as List<PackingList>;
        debugPrint(
            '✅ [PackingListsProvider] Loaded ${packingLists.length} packing list(s)');
        return packingLists;
      }

      debugPrint(
          '❌ [PackingListsProvider] Failed to load packing lists (null returned)');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ [PackingListsProvider] Error loading packing lists: $e');
      debugPrint('📍 [PackingListsProvider] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clear packing lists state (used on logout to prevent stale data)
  ///
  /// Sets state to empty list immediately without triggering a rebuild/fetch.
  /// Call this BEFORE signing out to prevent race conditions.
  void clear() {
    debugPrint(
        '🧹 [PackingListsProvider] clear() called - clearing packing lists');
    state = const AsyncValue.data([]);
  }

  /// Refresh packing lists (force reload)
  ///
  /// Sets loading state first, then fetches fresh data from API.
  /// Use this after login to ensure user sees a loading indicator.
  Future<void> refresh() async {
    debugPrint('🔄 [PackingListsProvider] refresh() called - forcing reload');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint(
            '⚠️ [PackingListsProvider] No authenticated user during refresh');
        return <PackingList>[];
      }

      debugPrint(
          '🔄 [PackingListsProvider] Refreshing packing lists from API...');
      final result = await _tripService.getPackingLists();
      if (result != null) {
        final packingLists = result['packingLists'] as List<PackingList>;
        debugPrint(
            '✅ [PackingListsProvider] Packing lists refreshed: ${packingLists.length} list(s)');
        return packingLists;
      }
      return <PackingList>[];
    });
  }

  /// Add a packing list to the local state
  ///
  /// Call this after successfully creating a packing list via API.
  /// Idempotent: won't add duplicates if called multiple times.
  void addPackingList(PackingList packingList) {
    debugPrint(
        '➕ [PackingListsProvider] addPackingList() called - adding: ${packingList.id}');

    if (!state.hasValue) {
      debugPrint(
          '⚠️ [PackingListsProvider] Cannot add packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;

    // Prevent duplicates
    if (currentLists.any((pl) => pl.id == packingList.id)) {
      debugPrint(
          '⚠️ [PackingListsProvider] Packing list ${packingList.id} already exists, updating instead');
      updatePackingList(packingList);
      return;
    }

    state = AsyncValue.data([...currentLists, packingList]);
    debugPrint(
        '✅ [PackingListsProvider] Packing list added. Total: ${currentLists.length + 1}');
  }

  /// Remove a packing list from local state
  ///
  /// Call this after successfully deleting a packing list via API.
  void removePackingList(String packingListId) {
    debugPrint(
        '➖ [PackingListsProvider] removePackingList() called - removing: $packingListId');

    if (!state.hasValue) {
      debugPrint(
          '⚠️ [PackingListsProvider] Cannot remove packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;
    final filteredLists =
        currentLists.where((pl) => pl.id != packingListId).toList();

    if (filteredLists.length == currentLists.length) {
      debugPrint(
          '⚠️ [PackingListsProvider] Packing list $packingListId not found, nothing to remove');
      return;
    }

    state = AsyncValue.data(filteredLists);
    debugPrint(
        '✅ [PackingListsProvider] Packing list removed. Total: ${filteredLists.length}');
  }

  /// Update a packing list in local state
  ///
  /// Call this after successfully updating a packing list via API.
  /// If the list doesn't exist, it will be added instead.
  void updatePackingList(PackingList updatedPackingList) {
    debugPrint(
        '✏️ [PackingListsProvider] updatePackingList() called - updating: ${updatedPackingList.id}');

    if (!state.hasValue) {
      debugPrint(
          '⚠️ [PackingListsProvider] Cannot update packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;
    final existingIndex =
        currentLists.indexWhere((pl) => pl.id == updatedPackingList.id);

    if (existingIndex == -1) {
      debugPrint(
          '⚠️ [PackingListsProvider] Packing list ${updatedPackingList.id} not found, adding instead');
      addPackingList(updatedPackingList);
      return;
    }

    state = AsyncValue.data(
      currentLists
          .map((pl) => pl.id == updatedPackingList.id ? updatedPackingList : pl)
          .toList(),
    );
    debugPrint('✅ [PackingListsProvider] Packing list updated successfully');
  }
}

/// Provider for packing lists
/// Usage: ref.watch(packingListsProvider) to get AsyncValue<List<PackingList>>
///        ref.read(packingListsProvider.notifier) to call methods
final packingListsProvider =
    AsyncNotifierProvider<PackingListsNotifier, List<PackingList>>(() {
  return PackingListsNotifier();
});
