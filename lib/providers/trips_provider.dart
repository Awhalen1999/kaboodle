import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/packing_list.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing packing lists state using AsyncNotifier pattern
class PackingListsNotifier extends AsyncNotifier<List<PackingList>> {
  final TripService _tripService = TripService();

  @override
  Future<List<PackingList>> build() async {
    print(
        '📦 [PackingListsProvider] build() called - initializing packing lists data');

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print(
          '⚠️ [PackingListsProvider] No authenticated user, returning empty list');
      return [];
    }

    print('🔄 [PackingListsProvider] Loading packing lists from API...');
    try {
      final result = await _tripService.getPackingLists();

      if (result != null) {
        final packingLists = result['packingLists'] as List<PackingList>;
        print(
            '✅ [PackingListsProvider] Loaded ${packingLists.length} packing list(s)');
        return packingLists;
      }

      print(
          '❌ [PackingListsProvider] Failed to load packing lists (null returned)');
      return [];
    } catch (e, stackTrace) {
      print('❌ [PackingListsProvider] Error loading packing lists: $e');
      print('📍 [PackingListsProvider] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh packing lists (force reload)
  Future<void> refresh() async {
    print('🔄 [PackingListsProvider] refresh() called - forcing reload');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ [PackingListsProvider] No authenticated user during refresh');
        return <PackingList>[];
      }

      print('🔄 [PackingListsProvider] Refreshing packing lists from API...');
      final result = await _tripService.getPackingLists();
      if (result != null) {
        final packingLists = result['packingLists'] as List<PackingList>;
        print(
            '✅ [PackingListsProvider] Packing lists refreshed: ${packingLists.length} list(s)');
        return packingLists;
      }
      return <PackingList>[];
    });
  }

  /// Add a packing list to the local state
  /// Call this after successfully creating a packing list via API
  /// Idempotent: won't add duplicates if called multiple times
  void addPackingList(PackingList packingList) {
    print(
        '➕ [PackingListsProvider] addPackingList() called - adding: ${packingList.id}');

    // Only update if state is in a valid state (not loading/error)
    if (!state.hasValue) {
      print(
          '⚠️ [PackingListsProvider] Cannot add packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;

    // Prevent duplicates - check if list already exists
    if (currentLists.any((pl) => pl.id == packingList.id)) {
      print(
          '⚠️ [PackingListsProvider] Packing list ${packingList.id} already exists, updating instead');
      updatePackingList(packingList);
      return;
    }

    state = AsyncValue.data([...currentLists, packingList]);
    print(
        '✅ [PackingListsProvider] Packing list added. Total: ${currentLists.length + 1}');
  }

  /// Remove a packing list from local state
  /// Call this after successfully deleting a packing list via API
  void removePackingList(String packingListId) {
    print(
        '➖ [PackingListsProvider] removePackingList() called - removing: $packingListId');

    // Only update if state is in a valid state (not loading/error)
    if (!state.hasValue) {
      print(
          '⚠️ [PackingListsProvider] Cannot remove packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;
    final filteredLists =
        currentLists.where((pl) => pl.id != packingListId).toList();

    // Only update if the list was actually removed
    if (filteredLists.length == currentLists.length) {
      print(
          '⚠️ [PackingListsProvider] Packing list $packingListId not found, nothing to remove');
      return;
    }

    state = AsyncValue.data(filteredLists);
    print(
        '✅ [PackingListsProvider] Packing list removed. Total: ${filteredLists.length}');
  }

  /// Update a packing list in local state
  /// Call this after successfully updating a packing list via API
  /// If the list doesn't exist, it will be added instead
  void updatePackingList(PackingList updatedPackingList) {
    print(
        '✏️ [PackingListsProvider] updatePackingList() called - updating: ${updatedPackingList.id}');

    // Only update if state is in a valid state (not loading/error)
    if (!state.hasValue) {
      print(
          '⚠️ [PackingListsProvider] Cannot update packing list - state is not ready');
      return;
    }

    final currentLists = state.value!;
    final existingIndex =
        currentLists.indexWhere((pl) => pl.id == updatedPackingList.id);

    if (existingIndex == -1) {
      // List doesn't exist yet, add it instead
      print(
          '⚠️ [PackingListsProvider] Packing list ${updatedPackingList.id} not found, adding instead');
      addPackingList(updatedPackingList);
      return;
    }

    state = AsyncValue.data(
      currentLists
          .map((pl) => pl.id == updatedPackingList.id ? updatedPackingList : pl)
          .toList(),
    );
    print('✅ [PackingListsProvider] Packing list updated successfully');
  }
}

/// Provider for packing lists
/// Usage: ref.watch(packingListsProvider) to get AsyncValue<List<PackingList>>
///        ref.read(packingListsProvider.notifier) to call methods
final packingListsProvider =
    AsyncNotifierProvider<PackingListsNotifier, List<PackingList>>(() {
  return PackingListsNotifier();
});
