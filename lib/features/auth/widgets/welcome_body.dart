import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:kaboodle_app/features/auth/widgets/auth_bottom_sheet.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder for animation - will be replaced later
          // Expanded fills remaining space and pushes content down
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.rocket_launch,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Kaboodle', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text('Packing doesn\'t need to be stressful',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AuthBottomSheet(isSignUp: true),
              );
            },
            child: Text("Get Started",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AuthBottomSheet(isSignUp: false),
              );
            },
            child: Text("I already have an account",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    )),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                children: [
                  const TextSpan(
                      text: "By continuing, you agree to Kaboodle's "),
                  TextSpan(
                    text: 'Terms of Service',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Navigate to Terms of Service page
                        // context.push('/terms-of-service');
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Navigate to Privacy Policy page
                        // context.push('/privacy-policy');
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
