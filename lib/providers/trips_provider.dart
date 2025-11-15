import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/packing_list.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing packing lists state using AsyncNotifier pattern
class PackingListsNotifier extends AsyncNotifier<List<PackingList>> {
  final TripService _tripService = TripService();

  @override
  Future<List<PackingList>> build() async {
    print('📦 [PackingListsProvider] build() called - initializing packing lists data');

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ [PackingListsProvider] No authenticated user, returning empty list');
      return [];
    }

    print('🔄 [PackingListsProvider] Loading packing lists from API...');
    try {
      final result = await _tripService.getPackingLists();

      if (result != null) {
        final packingLists = result['packingLists'] as List<PackingList>;
        print('✅ [PackingListsProvider] Loaded ${packingLists.length} packing list(s)');
        return packingLists;
      }

      print('❌ [PackingListsProvider] Failed to load packing lists (null returned)');
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
        print('✅ [PackingListsProvider] Packing lists refreshed: ${packingLists.length} list(s)');
        return packingLists;
      }
      return <PackingList>[];
    });
  }

  /// Add a packing list to the local state
  /// Call this after successfully creating a packing list via API
  void addPackingList(PackingList packingList) {
    print('➕ [PackingListsProvider] addPackingList() called - adding: ${packingList.id}');
    final currentLists = state.value ?? [];
    state = AsyncValue.data([...currentLists, packingList]);
    print('✅ [PackingListsProvider] Packing list added. Total: ${currentLists.length + 1}');
  }

  /// Remove a packing list from local state
  /// Call this after successfully deleting a packing list via API
  void removePackingList(String packingListId) {
    print('➖ [PackingListsProvider] removePackingList() called - removing: $packingListId');
    final currentLists = state.value ?? [];
    state = AsyncValue.data(
      currentLists.where((pl) => pl.id != packingListId).toList(),
    );
    print('✅ [PackingListsProvider] Packing list removed. Total: ${currentLists.length - 1}');
  }

  /// Update a packing list in local state
  /// Call this after successfully updating a packing list via API
  void updatePackingList(PackingList updatedPackingList) {
    print('✏️ [PackingListsProvider] updatePackingList() called - updating: ${updatedPackingList.id}');
    final currentLists = state.value ?? [];
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
final packingListsProvider = AsyncNotifierProvider<PackingListsNotifier, List<PackingList>>(() {
  return PackingListsNotifier();
});
