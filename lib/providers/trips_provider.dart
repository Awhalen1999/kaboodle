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
    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final result = await _tripService.getPackingLists();

      if (result != null) {
        return result['packingLists'] as List<PackingList>;
      }

      return [];
    } catch (e) {
      debugPrint('❌ [PackingListsProvider] Error loading lists: $e');
      rethrow;
    }
  }

  /// Clear packing lists state (used on logout to prevent stale data)
  ///
  /// Sets state to empty list immediately without triggering a rebuild/fetch.
  /// Call this BEFORE signing out to prevent race conditions.
  void clear() {
    state = const AsyncValue.data([]);
  }

  /// Refresh packing lists (force reload)
  ///
  /// Sets loading state first, then fetches fresh data from API.
  /// Use this after login to ensure user sees a loading indicator.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return <PackingList>[];
      }

      final result = await _tripService.getPackingLists();
      if (result != null) {
        return result['packingLists'] as List<PackingList>;
      }
      return <PackingList>[];
    });
  }

  /// Add a packing list to the local state
  ///
  /// Call this after successfully creating a packing list via API.
  /// Idempotent: won't add duplicates if called multiple times.
  void addPackingList(PackingList packingList) {
    final currentLists = state.valueOrNull;
    if (currentLists == null) {
      return;
    }

    // Prevent duplicates
    if (currentLists.any((pl) => pl.id == packingList.id)) {
      updatePackingList(packingList);
      return;
    }

    state = AsyncValue.data([...currentLists, packingList]);
  }

  /// Remove a packing list from local state
  ///
  /// Call this after successfully deleting a packing list via API.
  void removePackingList(String packingListId) {
    final currentLists = state.valueOrNull;
    if (currentLists == null) {
      return;
    }

    final filteredLists =
        currentLists.where((pl) => pl.id != packingListId).toList();

    if (filteredLists.length == currentLists.length) {
      return;
    }

    state = AsyncValue.data(filteredLists);
  }

  /// Update a packing list in local state
  ///
  /// Call this after successfully updating a packing list via API.
  /// If the list doesn't exist, it will be added instead.
  void updatePackingList(PackingList updatedPackingList) {
    final currentLists = state.valueOrNull;
    if (currentLists == null) {
      return;
    }

    final existingIndex =
        currentLists.indexWhere((pl) => pl.id == updatedPackingList.id);

    if (existingIndex == -1) {
      addPackingList(updatedPackingList);
      return;
    }

    state = AsyncValue.data(
      currentLists
          .map((pl) => pl.id == updatedPackingList.id ? updatedPackingList : pl)
          .toList(),
    );
  }
}

/// Provider for packing lists
/// Usage: ref.watch(packingListsProvider) to get AsyncValue<List<PackingList>>
///        ref.read(packingListsProvider.notifier) to call methods
final packingListsProvider =
    AsyncNotifierProvider<PackingListsNotifier, List<PackingList>>(() {
  return PackingListsNotifier();
});
