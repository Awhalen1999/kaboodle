import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('W E L C O M E'),
          TextButton(
            onPressed: () => context.push('/signup'),
            child: Text("Sign Up"),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/login'),
            child: Text("Login"),
          )
        ],
      ),
    );
  }
}
