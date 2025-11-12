import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/providers/user_state.dart';
import 'package:kaboodle_app/services/user/user_service.dart';

/// Notifier for managing user state
class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService = UserService();
  int _authCheckAttempts = 0;
  static const int _maxAuthCheckAttempts = 3;

  UserNotifier() : super(const UserState()) {
    print('🏗️ [UserProvider] Provider initialized');
    // Don't auto-fetch - let widgets trigger load on demand (TanStack Query pattern)
  }

  /// Load user profile from the API
  Future<void> loadUserProfile() async {
    print('🔄 [UserProvider] loadUserProfile() called');

    // Don't reload if already loading
    if (state.isLoading) {
      print('⏭️ [UserProvider] Already loading, skipping');
      return;
    }

    // Check if already loaded
    if (state.hasLoaded) {
      print('✨ [UserProvider] Already loaded, using cached data');
      return;
    }

    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      _authCheckAttempts++;
      print(
          '⚠️ [UserProvider] User not authenticated (attempt $_authCheckAttempts/$_maxAuthCheckAttempts)');

      // After max attempts, mark as loaded to prevent infinite loops
      if (_authCheckAttempts >= _maxAuthCheckAttempts) {
        print(
            '🛑 [UserProvider] Max auth check attempts reached, stopping retries');
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

    print('👤 [UserProvider] Starting API call...');
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _userService.getUserProfile();

      if (user != null) {
        print(
            '✅ [UserProvider] User profile loaded: ${user.displayName ?? user.email}');
        state = UserState(user: user, isLoading: false, hasLoaded: true);
      } else {
        print('❌ [UserProvider] Failed to load user profile');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load user profile',
          hasLoaded: true,
        );
      }
    } catch (e) {
      print('❌ [UserProvider] Error loading user profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoaded: true,
      );
    }
  }

  /// Refresh user profile (force reload)
  Future<void> refreshUserProfile() async {
    print('🔄 [UserProvider] refreshUserProfile() called - forcing reload');
    // Force refresh by resetting hasLoaded to trigger fresh load
    state = state.copyWith(hasLoaded: false);
    await loadUserProfile();
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? country,
  }) async {
    print('📝 [UserProvider] Updating user profile...');

    try {
      final updatedUser = await _userService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        country: country,
      );

      if (updatedUser != null) {
        print('✅ [UserProvider] User profile updated');
        state = UserState(user: updatedUser, isLoading: false);
        return true;
      } else {
        print('❌ [UserProvider] Failed to update user profile');
        return false;
      }
    } catch (e) {
      print('❌ [UserProvider] Error updating user profile: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear user state (for logout)
  void clearUser() {
    print('🧹 [UserProvider] Clearing user state');
    state = const UserState();
  }

  /// Clear error state
  void clearError() {
    print('🧹 [UserProvider] Clearing error state');
    state = state.copyWith(clearError: true);
  }
}

/// Provider for user
/// Usage: ref.watch(userProvider) to get state
///        ref.read(userProvider.notifier) to call methods
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
