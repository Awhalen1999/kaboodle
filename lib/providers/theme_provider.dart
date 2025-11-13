import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/features/profile/widgets/color_mode_selector.dart';
import 'package:kaboodle_app/services/theme/theme_service.dart';

// Theme provider state
class ThemeState {
  final ColorMode colorMode;
  final ThemeMode themeMode;

  const ThemeState({
    required this.colorMode,
    required this.themeMode,
  });

  ThemeState copyWith({
    ColorMode? colorMode,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      colorMode: colorMode ?? this.colorMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

// Theme notifier for managing theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          colorMode: ThemeService.getThemeMode(),
          themeMode: ThemeService.toThemeMode(ThemeService.getThemeMode()),
        ));

  // Update theme mode and save to Hive
  Future<void> setThemeMode(ColorMode colorMode) async {
    await ThemeService.setThemeMode(colorMode);
    state = ThemeState(
      colorMode: colorMode,
      themeMode: ThemeService.toThemeMode(colorMode),
    );
  }
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
