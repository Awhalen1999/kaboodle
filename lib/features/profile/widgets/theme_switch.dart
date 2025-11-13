import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/features/profile/widgets/color_mode_selector.dart';
import 'package:kaboodle_app/providers/theme_provider.dart';

/// Shows an iOS-style action sheet for selecting theme mode
class ThemeSwitch {
  /// Displays a CupertinoActionSheet with theme mode options
  static void show(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.light);
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.dark);
            },
            child: const Text('Dark'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(themeProvider.notifier).setThemeMode(ColorMode.system);
            },
            child: const Text('System default'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
