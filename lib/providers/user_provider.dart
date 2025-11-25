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
    debugPrint('📦 [UserProvider] build() called - initializing user data');

    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      debugPrint('⚠️ [UserProvider] No authenticated user, returning null');
      return null;
    }

    debugPrint('🔄 [UserProvider] Loading user profile from API...');
    try {
      final user = await _userService.getUserProfile();
      if (user != null) {
        debugPrint(
            '✅ [UserProvider] User profile loaded: ${user.displayName ?? user.email}');
      } else {
        debugPrint(
            '❌ [UserProvider] Failed to load user profile (null returned)');
      }
      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserProvider] Error loading user profile: $e');
      debugPrint('📍 [UserProvider] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh user profile (force reload)
  ///
  /// Sets loading state first, then fetches fresh data from API.
  /// Use this after login to ensure user sees a loading indicator.
  Future<void> refresh() async {
    debugPrint('🔄 [UserProvider] refresh() called - forcing reload');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        debugPrint('⚠️ [UserProvider] No authenticated user during refresh');
        return null;
      }
      debugPrint('🔄 [UserProvider] Refreshing user profile from API...');
      final user = await _userService.getUserProfile();
      if (user != null) {
        debugPrint(
            '✅ [UserProvider] User profile refreshed: ${user.displayName ?? user.email}');
      }
      return user;
    });
  }

  /// Clear user state (used on logout to prevent stale data)
  ///
  /// Sets state to null immediately without triggering a rebuild/fetch.
  /// Call this BEFORE signing out to prevent race conditions.
  void clear() {
    debugPrint('🧹 [UserProvider] clear() called - clearing user data');
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
    debugPrint('📝 [UserProvider] updateUserProfile() called');
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
        debugPrint('✅ [UserProvider] User profile updated successfully');
        state = AsyncValue.data(updatedUser);
        return true;
      } else {
        debugPrint(
            '❌ [UserProvider] Failed to update user profile (null returned)');
        state = previousState;
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [UserProvider] Error updating user profile: $e');
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
