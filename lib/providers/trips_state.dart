import 'package:kaboodle_app/models/trip.dart';

/// State class for managing trips data
class TripsState {
  final List<Trip> trips;
  final bool isLoading;
  final String? error;
  final bool hasLoaded; // Track if we've attempted to load data

  const TripsState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
  });

  /// Create a copy of this state with some fields replaced
  TripsState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasLoaded,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }

  /// Helper to check if trips are empty and not loading
  bool get isEmpty => trips.isEmpty && !isLoading;

  /// Helper to check if we have trips
  bool get hasTrips => trips.isNotEmpty;
}
