import 'package:kaboodle_app/features/auth/widgets/welcome_body.dart';
import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WelcomeBody(),
      ),
    );
  }
}
