import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/services/user/user_service.dart';

/// Notifier for managing user state using AsyncNotifier pattern
///
/// Handles:
/// - Loading user profile from API on initialization
/// - Refreshing user data (e.g., after login)
/// - Clearing user data (e.g., on logout)
/// - Updating user profile
class UserNotifier extends AsyncNotifier<User?> {
  final UserService _userService = UserService();

  @override
  Future<User?> build() async {
    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return null;
    }

    try {
      return await _userService.getUserProfile();
    } catch (e) {
      debugPrint('❌ [UserProvider] Error loading profile: $e');
      rethrow;
    }
  }

  /// Refresh user profile (force reload)
  ///
  /// Sets loading state first, then fetches fresh data from API.
  /// Use this after login to ensure user sees a loading indicator.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        return null;
      }
      return await _userService.getUserProfile();
    });
  }

  /// Clear user state (used on logout to prevent stale data)
  ///
  /// Sets state to null immediately without triggering a rebuild/fetch.
  /// Call this BEFORE signing out to prevent race conditions.
  void clear() {
    state = const AsyncValue.data(null);
  }

  /// Update user profile
  ///
  /// Returns true if update was successful, false otherwise.
  /// Restores previous state on failure.
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? country,
  }) async {
    final previousState = state;

    // Show loading state
    state = const AsyncValue.loading();

    try {
      final updatedUser = await _userService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        country: country,
      );

      if (updatedUser != null) {
        state = AsyncValue.data(updatedUser);
        return true;
      } else {
        state = previousState;
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [UserProvider] Error updating profile: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

/// Provider for user
/// Usage: ref.watch(userProvider) to get AsyncValue<User?>
///        ref.read(userProvider.notifier) to call methods
final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});
