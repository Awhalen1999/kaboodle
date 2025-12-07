import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';

/// Service for handling authentication operations
///
/// Handles:
/// - Email/password signup and signin
/// - Password reset via email
/// - Google Sign-In
/// - Sign out with proper provider state management
/// - Firebase token management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get Firebase ID token for API requests
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  /// Show error toast notification
  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(message),
    );
  }

  /// Show success toast notification
  void _showSuccessToast(BuildContext context, String message) {
    if (!context.mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(message),
    );
  }

  /// Refresh providers after successful authentication
  void _refreshProvidersAfterAuth(WidgetRef ref) {
    ref.read(userProvider.notifier).refresh();
    ref.read(packingListsProvider.notifier).refresh();
  }

  /// Clear providers before signing out
  void _clearProvidersBeforeSignout(WidgetRef ref) {
    ref.read(packingListsProvider.notifier).clear();
    ref.read(userProvider.notifier).clear();
  }

  /// Sign up with email and password
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('📝 [AuthService] Starting signup...');

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ [AuthService] Signup successful, refreshing providers...');
      _refreshProvidersAfterAuth(ref);

      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'weak-password' => 'The password provided is too weak.',
        'email-already-in-use' => 'An account already exists with that email.',
        'invalid-email' => 'The email address is invalid.',
        'operation-not-allowed' => 'Email/password accounts are not enabled.',
        _ => e.message ?? 'An error occurred during sign up.',
      };
      _showErrorToast(context, message);
    } catch (e) {
      _showErrorToast(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('🔑 [AuthService] Starting signin...');

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ [AuthService] Signin successful, refreshing providers...');
      _refreshProvidersAfterAuth(ref);

      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-email' => 'The email address is invalid.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' => 'No user found for that email.',
        'wrong-password' ||
        'invalid-credential' =>
          'Wrong password provided for that user.',
        'too-many-requests' =>
          'Too many failed attempts. Please try again later.',
        _ => e.message ?? 'An error occurred during sign in.',
      };
      _showErrorToast(context, message);
    } catch (e) {
      _showErrorToast(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out from Firebase and Google
  ///
  /// Clears provider state BEFORE signing out to prevent race conditions.
  Future<void> signout({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('🚪 [AuthService] Starting signout...');

      // Step 1: Clear provider state BEFORE signing out
      // This prevents race conditions where providers rebuild with stale auth
      debugPrint('🧹 [AuthService] Clearing provider state...');
      _clearProvidersBeforeSignout(ref);

      // Step 2: Perform async signout
      debugPrint('🔐 [AuthService] Signing out from Firebase & Google...');
      await _auth.signOut();
      await _googleSignIn.signOut();

      debugPrint('✅ [AuthService] Signout complete');

      // Step 3: Redirect to welcome page
      if (!context.mounted) return;
      context.go('/welcome');
    } catch (e) {
      debugPrint('❌ [AuthService] Error during signout: $e');
      // Still try to redirect even if signout fails
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset({
    required String email,
    required BuildContext context,
  }) async {
    try {
      debugPrint('📧 [AuthService] Sending password reset email...');

      await _auth.sendPasswordResetEmail(email: email);

      debugPrint('✅ [AuthService] Password reset email sent successfully');
      _showSuccessToast(
        context,
        'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'invalid-email' => 'The email address is invalid.',
        'user-not-found' => 'No account found with that email address.',
        'too-many-requests' => 'Too many requests. Please try again later.',
        _ => e.message ?? 'An error occurred while sending the reset email.',
      };
      _showErrorToast(context, message);
    } catch (e) {
      _showErrorToast(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('🔑 [AuthService] Starting Google signin...');

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ [AuthService] Google signin cancelled by user');
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);

      debugPrint(
          '✅ [AuthService] Google signin successful, refreshing providers...');
      _refreshProvidersAfterAuth(ref);

      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'account-exists-with-different-credential' =>
          'An account already exists with a different sign-in method.',
        'invalid-credential' => 'The credential is invalid.',
        'operation-not-allowed' => 'Google sign-in is not enabled.',
        _ => e.message ?? 'An error occurred during Google sign in.',
      };
      _showErrorToast(context, message);
    } catch (e) {
      _showErrorToast(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
