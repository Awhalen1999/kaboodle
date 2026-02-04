import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/providers/subscription_provider.dart';
import 'package:kaboodle_app/shared/utils/app_toast.dart';

/// Service for handling authentication operations
///
/// Handles:
/// - Email/password signup and signin
/// - Password reset via email
/// - Google Sign-In
/// - Apple Sign-In
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
    AppToast.error(context, message);
  }

  /// Show success toast notification
  void _showSuccessToast(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  /// Refresh providers after successful authentication
  void _refreshProvidersAfterAuth(WidgetRef ref) {
    ref.read(userProvider.notifier).refresh();
    ref.read(packingListsProvider.notifier).refresh();
    ref.read(subscriptionProvider.notifier).refresh();
  }

  /// Clear providers before signing out
  void _clearProvidersBeforeSignout(WidgetRef ref) {
    ref.read(packingListsProvider.notifier).clear();
    ref.read(userProvider.notifier).clear();
    ref.read(subscriptionProvider.notifier).clear();
  }

  /// Identify RevenueCat user and PostHog with Firebase user ID
  Future<void> _identifyRevenueCatUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await Purchases.logIn(user.uid);
        await Posthog().identify(
          userId: user.uid,
        );
      } catch (e) {
        debugPrint('⚠️ [AuthService] Failed to identify RevenueCat user: $e');
        // Don't throw - this shouldn't block authentication
      }
    }
  }

  /// Sign up with email and password
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Identify RevenueCat user with Firebase user ID
      await _identifyRevenueCatUser();

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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Identify RevenueCat user with Firebase user ID
      await _identifyRevenueCatUser();

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
      // Step 1: Clear provider state BEFORE signing out
      // This prevents race conditions where providers rebuild with stale auth
      _clearProvidersBeforeSignout(ref);

      // Step 2: Perform async signout
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Sign out from RevenueCat and PostHog
      try {
        await Purchases.logOut();
        await Posthog().reset();
      } catch (e) {
        debugPrint('⚠️ [AuthService] Failed to log out user: $e');
        // Don't throw - this shouldn't block signout
      }

      // Step 3: Redirect to welcome page
      if (!context.mounted) return;
      context.go('/welcome');
    } catch (e) {
      debugPrint('❌ [AuthService] Signout error: $e');
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
      await _auth.sendPasswordResetEmail(email: email);

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
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return; // User cancelled
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

      // Identify RevenueCat user with Firebase user ID
      await _identifyRevenueCatUser();

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

  /// Sign in with Apple
  ///
  /// Uses Firebase's signInWithProvider for cleaner implementation
  /// that handles the OAuth flow automatically.
  Future<void> signInWithApple({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      // Sign in to Firebase with Apple provider
      await _auth.signInWithProvider(appleProvider);

      // Identify RevenueCat user with Firebase user ID
      await _identifyRevenueCatUser();

      _refreshProvidersAfterAuth(ref);

      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] Firebase auth error code: ${e.code}');
      debugPrint('❌ [AuthService] Firebase auth error message: ${e.message}');

      // Check if user cancelled
      if (e.code == 'canceled' || e.message?.contains('canceled') == true) {
        return; // User cancelled, no toast needed
      }

      final message = switch (e.code) {
        'account-exists-with-different-credential' =>
          'An account already exists with a different sign-in method.',
        'invalid-credential' =>
          'Invalid credential. Please check Firebase Console: Apple Sign In must be enabled and bundle ID must match.',
        'operation-not-allowed' =>
          'Apple sign-in is not enabled in Firebase Console.',
        _ => e.message ?? 'An error occurred during Apple sign in.',
      };
      _showErrorToast(context, message);
    } catch (e) {
      debugPrint('❌ [AuthService] Apple signin error: $e');

      // Check if user cancelled (can come as a different exception type)
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return; // User cancelled, no toast needed
      }

      _showErrorToast(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
