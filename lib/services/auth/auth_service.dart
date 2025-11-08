import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
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
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
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
    } catch (_) {
      // Optional: Handle other exceptions
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
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
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
    } catch (_) {
      // Optional: Handle other exceptions
    }
  }

  Future<void> signout({
    required BuildContext context,
  }) async {
    // Perform async signout
    await _auth.signOut();

    // Delay if needed, then check if context is still valid before redirecting
    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;
    context.go('/login');
  }
}
