import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/trip.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing trips state using AsyncNotifier pattern
class TripsNotifier extends AsyncNotifier<List<Trip>> {
  final TripService _tripService = TripService();

  @override
  Future<List<Trip>> build() async {
    print('📦 [TripsProvider] build() called - initializing trips data');

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ [TripsProvider] No authenticated user, returning empty list');
      return [];
    }

    print('🔄 [TripsProvider] Loading trips from API...');
    try {
      final result = await _tripService.getTrips(status: 'all');

      if (result != null) {
        final trips = result['trips'] as List<Trip>;
        print('✅ [TripsProvider] Loaded ${trips.length} trip(s)');
        return trips;
      }

      print('❌ [TripsProvider] Failed to load trips (null returned)');
      return [];
    } catch (e, stackTrace) {
      print('❌ [TripsProvider] Error loading trips: $e');
      print('📍 [TripsProvider] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh trips (force reload)
  Future<void> refresh() async {
    print('🔄 [TripsProvider] refresh() called - forcing reload');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ [TripsProvider] No authenticated user during refresh');
        return <Trip>[];
      }

      print('🔄 [TripsProvider] Refreshing trips from API...');
      final result = await _tripService.getTrips(status: 'all');
      if (result != null) {
        final trips = result['trips'] as List<Trip>;
        print('✅ [TripsProvider] Trips refreshed: ${trips.length} trip(s)');
        return trips;
      }
      return <Trip>[];
    });
  }

  /// Add a trip to the local state
  /// Call this after successfully creating a trip via API
  void addTrip(Trip trip) {
    print('➕ [TripsProvider] addTrip() called - adding trip: ${trip.id}');
    final currentTrips = state.value ?? [];
    state = AsyncValue.data([...currentTrips, trip]);
    print(
        '✅ [TripsProvider] Trip added. Total trips: ${currentTrips.length + 1}');
  }

  /// Remove a trip from local state
  /// Call this after successfully deleting a trip via API
  void removeTrip(String tripId) {
    print('➖ [TripsProvider] removeTrip() called - removing trip: $tripId');
    final currentTrips = state.value ?? [];
    state = AsyncValue.data(
      currentTrips.where((t) => t.id != tripId).toList(),
    );
    print(
        '✅ [TripsProvider] Trip removed. Total trips: ${currentTrips.length - 1}');
  }

  /// Update a trip in local state
  /// Call this after successfully updating a trip via API
  void updateTrip(Trip updatedTrip) {
    print(
        '✏️ [TripsProvider] updateTrip() called - updating trip: ${updatedTrip.id}');
    final currentTrips = state.value ?? [];
    state = AsyncValue.data(
      currentTrips
          .map((t) => t.id == updatedTrip.id ? updatedTrip : t)
          .toList(),
    );
    print('✅ [TripsProvider] Trip updated successfully');
  }
}

/// Provider for trips
/// Usage: ref.watch(tripsProvider) to get AsyncValue<List<Trip>>
///        ref.read(tripsProvider.notifier) to call methods
final tripsProvider = AsyncNotifierProvider<TripsNotifier, List<Trip>>(() {
  return TripsNotifier();
});
