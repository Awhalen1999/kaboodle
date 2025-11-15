import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  // Get Firebase ID token for API requests
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Perform async signup
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful signup, check if the context is still valid before redirecting
      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with that email.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = e.message ?? 'An error occurred during sign up.';
      }

      // Ensure context is valid before showing toast
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(message),
        );
      }
    } catch (e) {
      // Handle other exceptions
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('An unexpected error occurred: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Perform async signin
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if context is valid before redirecting
      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Wrong password provided for that user.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'An error occurred during sign in.';
      }

      // Ensure context is valid before showing toast
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(message),
        );
      }
    } catch (e) {
      // Handle other exceptions
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('An unexpected error occurred: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> signout({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // Perform async signout first
    await _auth.signOut();
    await _googleSignIn.signOut();

    // Invalidate providers after signout to clear state and prevent data sharing across accounts
    // This order prevents the providers from trying to load data while user is still authenticated
    ref.invalidate(packingListsProvider);
    ref.invalidate(userProvider);

    // Redirect immediately after signout
    if (!context.mounted) return;
    context.go('/welcome');
  }

  Future<void> signInWithGoogle({
    required BuildContext context,
  }) async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
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

      // Check if context is valid before redirecting
      if (!context.mounted) return;
      context.go('/my-packing-lists');
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          message = 'The credential is invalid.';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in is not enabled.';
          break;
        default:
          message = e.message ?? 'An error occurred during Google sign in.';
      }

      // Ensure context is valid before showing toast
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(message),
        );
      }
    } catch (e) {
      // Handle other exceptions
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('An unexpected error occurred: ${e.toString()}'),
        );
      }
    }
  }
}
