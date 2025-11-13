import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/services/user/user_service.dart';

/// Notifier for managing user state using AsyncNotifier pattern
class UserNotifier extends AsyncNotifier<User?> {
  final UserService _userService = UserService();

  @override
  Future<User?> build() async {
    print('📦 [UserProvider] build() called - initializing user data');

    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      print('⚠️ [UserProvider] No authenticated user, returning null');
      return null;
    }

    print('🔄 [UserProvider] Loading user profile from API...');
    try {
      final user = await _userService.getUserProfile();
      if (user != null) {
        print(
            '✅ [UserProvider] User profile loaded: ${user.displayName ?? user.email}');
      } else {
        print('❌ [UserProvider] Failed to load user profile (null returned)');
      }
      return user;
    } catch (e, stackTrace) {
      print('❌ [UserProvider] Error loading user profile: $e');
      print('📍 [UserProvider] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh user profile (force reload)
  Future<void> refresh() async {
    print('🔄 [UserProvider] refresh() called - forcing reload');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        print('⚠️ [UserProvider] No authenticated user during refresh');
        return null;
      }
      print('🔄 [UserProvider] Refreshing user profile from API...');
      final user = await _userService.getUserProfile();
      if (user != null) {
        print(
            '✅ [UserProvider] User profile refreshed: ${user.displayName ?? user.email}');
      }
      return user;
    });
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? country,
  }) async {
    print('📝 [UserProvider] updateUserProfile() called');
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
        print('✅ [UserProvider] User profile updated successfully');
        // Update state with new user data
        state = AsyncValue.data(updatedUser);
        return true;
      } else {
        print('❌ [UserProvider] Failed to update user profile (null returned)');
        // Restore previous state on failure
        state = previousState;
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ [UserProvider] Error updating user profile: $e');
      // Restore previous state and show error
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
