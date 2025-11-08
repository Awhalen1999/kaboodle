import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  // Use the new signout method, passing context
  Future<void> _logout(BuildContext context) async {
    await AuthService().signout(context: context);
  }

  void _getUserInfo() {
    final User? user = AuthService().getCurrentUser();
    if (user != null) {
      debugPrint('--- CURRENT USER INFO ---');
      debugPrint('User ID: ${user.uid}');
      debugPrint('Email: ${user.email}');
      debugPrint('Display Name: ${user.displayName}');
      debugPrint('Photo URL: ${user.photoURL}');
      debugPrint('Email Verified: ${user.emailVerified}');
      debugPrint('--- END ---');
    } else {
      debugPrint('--- No user is currently signed in. ---');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('P R O F I L E'),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _getUserInfo,
            child: Text("Get User Info (Test)"),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => _logout(context),
            child: Text("Logout"),
          )
        ],
      ),
    );
  }
}
