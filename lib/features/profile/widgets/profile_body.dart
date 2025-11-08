import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

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

  Future<void> _testBackendConnection(BuildContext context) async {
    final tripService = TripService();

    debugPrint('--- TESTING BACKEND CONNECTION ---');
    debugPrint('Testing health check...');

    final isHealthy = await tripService.healthCheck();

    if (isHealthy) {
      debugPrint('✅ Health Check PASSED - Backend is running on http://localhost:9000');
    } else {
      debugPrint('❌ Health Check FAILED - Backend is not reachable');
      debugPrint('Make sure backend is running on http://localhost:9000');
    }

    debugPrint('--- END ---');
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
            child: const Text("Get User Info (Test)"),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _testBackendConnection(context),
            icon: const Icon(Icons.cloud),
            label: const Text("Test Backend API"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => _logout(context),
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }
}
