import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/services/subscription/subscription_service.dart';

/// Notifier for managing subscription state using AsyncNotifier pattern
///
/// Handles:
/// - Loading subscription status from API on initialization
/// - Refreshing subscription data (e.g., after purchase)
/// - Clearing subscription data (e.g., on logout)
class SubscriptionNotifier extends AsyncNotifier<SubscriptionStatus?> {
  final SubscriptionService _subscriptionService = SubscriptionService();

  @override
  Future<SubscriptionStatus?> build() async {
    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return null;
    }

    try {
      return await _subscriptionService.getSubscriptionStatus();
    } catch (e) {
      debugPrint('❌ [SubscriptionProvider] Error loading status: $e');
      rethrow;
    }
  }

  /// Refresh subscription status (force reload)
  ///
  /// Sets loading state first, then fetches fresh data from API.
  /// Use this after purchase to ensure user sees updated status.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        return null;
      }
      return await _subscriptionService.getSubscriptionStatus();
    });
  }

  /// Clear subscription state (used on logout to prevent stale data)
  ///
  /// Sets state to null immediately without triggering a rebuild/fetch.
  /// Call this BEFORE signing out to prevent race conditions.
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for subscription status
/// Usage: ref.watch(subscriptionProvider) to get AsyncValue<SubscriptionStatus?>
///        ref.read(subscriptionProvider.notifier) to call methods
final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionStatus?>(() {
  return SubscriptionNotifier();
});
