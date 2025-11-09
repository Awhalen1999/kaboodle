import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/trip.dart';
import 'package:kaboodle_app/providers/trips_state.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing trips state
class TripsNotifier extends StateNotifier<TripsState> {
  final TripService _tripService = TripService();

  TripsNotifier() : super(const TripsState()) {
    // Auto-fetch trips when provider is created
    loadTrips();
  }

  /// Load all trips from the API
  Future<void> loadTrips({String status = 'all'}) async {
    // Don't reload if already loading
    if (state.isLoading) return;

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ [TripsProvider] User not authenticated, skipping load');
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return;
    }

    print('📦 [TripsProvider] Loading trips (status: $status)...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _tripService.getTrips(
        status: status,
        // Note: context not passed here - errors won't show toasts
        // We'll handle errors in UI if needed
      );

      if (result != null) {
        final trips = result['trips'] as List<Trip>;
        print('✅ [TripsProvider] Loaded ${trips.length} trip(s)');
        state = TripsState(trips: trips, isLoading: false);
      } else {
        print('❌ [TripsProvider] Failed to load trips');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load trips',
        );
      }
    } catch (e) {
      print('❌ [TripsProvider] Error loading trips: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh trips (force reload, bypasses loading guard)
  Future<void> refreshTrips() async {
    // Force refresh by resetting loading state first
    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
    await loadTrips();
  }

  /// Add a trip to the local state
  /// Call this after successfully creating a trip via API
  void addTrip(Trip trip) {
    state = state.copyWith(
      trips: [...state.trips, trip],
    );
  }

  /// Remove a trip from local state
  /// Call this after successfully deleting a trip via API
  void removeTrip(String tripId) {
    state = state.copyWith(
      trips: state.trips.where((t) => t.id != tripId).toList(),
    );
  }

  /// Update a trip in local state
  /// Call this after successfully updating a trip via API
  void updateTrip(Trip updatedTrip) {
    state = state.copyWith(
      trips: state.trips.map((t) {
        return t.id == updatedTrip.id ? updatedTrip : t;
      }).toList(),
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for trips
/// Usage: ref.watch(tripsProvider) to get state
///        ref.read(tripsProvider.notifier) to call methods
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier();
});
