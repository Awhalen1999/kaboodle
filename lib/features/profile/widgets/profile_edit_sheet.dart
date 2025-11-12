import 'package:flutter/material.dart';

/// Reusable bottom sheet widget for profile editing
/// Provides a consistent header with title and close button
class ProfileEditSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const ProfileEditSheet({
    super.key,
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: SizedBox(
        height: height ?? MediaQuery.of(context).size.height * 0.91,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 24.0,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Spacer for centering
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
