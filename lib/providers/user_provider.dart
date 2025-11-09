import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/providers/user_state.dart';
import 'package:kaboodle_app/services/user/user_service.dart';

/// Notifier for managing user state
class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService = UserService();

  UserNotifier() : super(const UserState()) {
    // Auto-fetch user profile when provider is created
    loadUserProfile();
  }

  /// Load user profile from the API
  Future<void> loadUserProfile() async {
    // Don't reload if already loading
    if (state.isLoading) return;

    // Check if user is authenticated before making API call
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      print('⚠️ [UserProvider] User not authenticated, skipping load');
      state = state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
      );
      return;
    }

    print('👤 [UserProvider] Loading user profile...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _userService.getUserProfile();

      if (user != null) {
        print('✅ [UserProvider] User profile loaded: ${user.displayName ?? user.email}');
        state = UserState(user: user, isLoading: false);
      } else {
        print('❌ [UserProvider] Failed to load user profile');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load user profile',
        );
      }
    } catch (e) {
      print('❌ [UserProvider] Error loading user profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh user profile (force reload)
  Future<void> refreshUserProfile() async {
    // Force refresh by resetting loading state first
    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
    await loadUserProfile();
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    print('📝 [UserProvider] Updating user profile...');

    try {
      final updatedUser = await _userService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
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
    state = const UserState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for user
/// Usage: ref.watch(userProvider) to get state
///        ref.read(userProvider.notifier) to call methods
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
