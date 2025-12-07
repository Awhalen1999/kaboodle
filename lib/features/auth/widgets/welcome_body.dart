import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:kaboodle_app/features/auth/widgets/auth_bottom_sheet.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Lottie.asset(
                'assets/lottie/main_cat.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Kaboodle', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text(
            'Packing doesn\'t need to be stressful',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
              CupertinoScaffold.showCupertinoModalBottomSheet(
                context: context,
                expand: false,
                builder: (context) => const AuthBottomSheet(isSignUp: true),
              );
            },
            child: Text(
              "Get Started",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
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
              CupertinoScaffold.showCupertinoModalBottomSheet(
                context: context,
                expand: false,
                builder: (context) => const AuthBottomSheet(isSignUp: false),
              );
            },
            child: Text(
              "I already have an account",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                children: [
                  const TextSpan(
                    text: "By continuing, you agree to Kaboodle's ",
                  ),
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
                        debugPrint('Terms of Service clicked');
                      },
                  ),
                  TextSpan(
                    text: ' and ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        debugPrint('Privacy Policy clicked');
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
