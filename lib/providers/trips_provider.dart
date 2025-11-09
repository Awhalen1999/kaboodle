import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaboodle_app/models/trip.dart';
import 'package:kaboodle_app/providers/trips_state.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

/// Notifier for managing trips state
class TripsNotifier extends StateNotifier<TripsState> {
  final TripService _tripService = TripService();
  int _authCheckAttempts = 0;
  static const int _maxAuthCheckAttempts = 3;

  TripsNotifier() : super(const TripsState()) {
    print('🏗️ [TripsProvider] Provider initialized');
    // Don't auto-fetch - let widgets trigger load on demand (TanStack Query pattern)
  }

  /// Load all trips from the API
  Future<void> loadTrips({String status = 'all'}) async {
    print('🔄 [TripsProvider] loadTrips() called (status: $status)');

    // Don't reload if already loading
    if (state.isLoading) {
      print('⏭️ [TripsProvider] Already loading, skipping');
      return;
    }

    // Check if already loaded
    if (state.hasLoaded) {
      print('✨ [TripsProvider] Already loaded, using cached data (${state.trips.length} trips)');
      return;
    }

    // Check if user is authenticated before making API call
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _authCheckAttempts++;
      print('⚠️ [TripsProvider] User not authenticated (attempt $_authCheckAttempts/$_maxAuthCheckAttempts)');

      // After max attempts, mark as loaded to prevent infinite loops
      if (_authCheckAttempts >= _maxAuthCheckAttempts) {
        print('🛑 [TripsProvider] Max auth check attempts reached, stopping retries');
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
          hasLoaded: true,
        );
      }
      return;
    }

    // Reset counter on successful auth
    _authCheckAttempts = 0;

    print('📦 [TripsProvider] Starting API call...');
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _tripService.getTrips(
        status: status,
        // Note: context not passed here - errors won't show toasts
        // We'll handle errors in UI if needed
      );

      if (result != null) {
        final trips = result['trips'] as List<Trip>;
        print('✅ [TripsProvider] Loaded ${trips.length} trip(s)');
        state = TripsState(trips: trips, isLoading: false, hasLoaded: true);
      } else {
        print('❌ [TripsProvider] Failed to load trips');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load trips',
          hasLoaded: true,
        );
      }
    } catch (e) {
      print('❌ [TripsProvider] Error loading trips: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoaded: true,
      );
    }
  }

  /// Refresh trips (force reload, bypasses loading guard)
  Future<void> refreshTrips() async {
    print('🔄 [TripsProvider] refreshTrips() called - forcing reload');
    // Force refresh by resetting hasLoaded to trigger fresh load
    state = state.copyWith(hasLoaded: false);
    await loadTrips();
  }

  /// Add a trip to the local state
  /// Call this after successfully creating a trip via API
  void addTrip(Trip trip) {
    print('➕ [TripsProvider] Adding trip to cache: ${trip.id}');
    state = state.copyWith(
      trips: [...state.trips, trip],
    );
  }

  /// Remove a trip from local state
  /// Call this after successfully deleting a trip via API
  void removeTrip(String tripId) {
    print('➖ [TripsProvider] Removing trip from cache: $tripId');
    state = state.copyWith(
      trips: state.trips.where((t) => t.id != tripId).toList(),
    );
  }

  /// Update a trip in local state
  /// Call this after successfully updating a trip via API
  void updateTrip(Trip updatedTrip) {
    print('✏️ [TripsProvider] Updating trip in cache: ${updatedTrip.id}');
    state = state.copyWith(
      trips: state.trips.map((t) {
        return t.id == updatedTrip.id ? updatedTrip : t;
      }).toList(),
    );
  }

  /// Clear error state
  void clearError() {
    print('🧹 [TripsProvider] Clearing error state');
    state = state.copyWith(clearError: true);
  }
}

/// Provider for trips
/// Usage: ref.watch(tripsProvider) to get state
///        ref.read(tripsProvider.notifier) to call methods
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier();
});
