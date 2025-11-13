import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/shared/constants/theme_constants.dart';
import 'package:kaboodle_app/providers/theme_provider.dart';

/// Shows an iOS-style action sheet for selecting theme mode
class ThemeSwitch {
  /// Displays a CupertinoActionSheet with theme mode options
  static void show(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.light);
            },
            child: Text(
              'Light',
              style: TextStyle(color: textColor),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.dark);
            },
            child: Text(
              'Dark',
              style: TextStyle(color: textColor),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.system);
            },
            child: Text(
              'System default',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
