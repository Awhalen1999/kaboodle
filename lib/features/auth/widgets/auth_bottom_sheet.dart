import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthBottomSheet extends StatelessWidget {
  final bool isSignUp;

  const AuthBottomSheet({
    super.key,
    required this.isSignUp,
  });

  void _handleGoogleAuth() {
    debugPrint('Google ${isSignUp ? "Sign up" : "Login"} clicked');
  }

  void _handleAppleAuth() {
    debugPrint('Apple ${isSignUp ? "Sign up" : "Login"} clicked');
  }

  void _handleEmailAuth() {
    // TODO: Implement email authentication
    debugPrint('Email ${isSignUp ? "Sign up" : "Login"} clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            isSignUp ? 'Sign up' : 'Login',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          // Google OAuth Button
          ElevatedButton(
            onPressed: _handleGoogleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logo
                SvgPicture.asset(
                  'assets/svg/google-logo.svg',
                  width: 20,
                  height: 20,
                  placeholderBuilder: (context) => const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Apple OAuth Button
          ElevatedButton(
            onPressed: _handleAppleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Apple logo
                SvgPicture.asset(
                  'assets/svg/apple-logo.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) => const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Apple',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Email sign up/login button
          TextButton(
            onPressed: _handleEmailAuth,
            child: Text(
              isSignUp ? 'Sign up with Email' : 'Login with Email',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
