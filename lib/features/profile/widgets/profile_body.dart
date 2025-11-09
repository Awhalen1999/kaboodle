import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  // Use the new signout method, passing context and ref
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await AuthService().signout(context: context, ref: ref);
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
      debugPrint(
          '✅ Health Check PASSED - Backend is running on http://localhost:9000');
    } else {
      debugPrint('❌ Health Check FAILED - Backend is not reachable');
      debugPrint('Make sure backend is running on http://localhost:9000');
    }

    debugPrint('--- END ---');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('P R O F I L E'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _getUserInfo,
            child: const Text("Get User Info"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _testBackendConnection(context),
            child: const Text("Test Backend API health check"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _logout(context, ref),
            child: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
