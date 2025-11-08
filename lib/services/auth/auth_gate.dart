import 'package:kaboodle_app/features/auth/pages/welcome_view.dart';
import 'package:kaboodle_app/features/profile/pages/profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const ProfileView();
          } else {
            return const WelcomeView();
          }
        },
      ),
    );
  }
}
