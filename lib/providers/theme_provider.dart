import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/shared/constants/theme_constants.dart';
import 'package:kaboodle_app/services/theme/theme_service.dart';

/// Immutable state class for theme configuration
///
/// Stores both the app's [ColorMode] (light/dark/system) and Flutter's
/// corresponding [ThemeMode] for use with MaterialApp.
class ThemeState {
  final ColorMode colorMode;
  final ThemeMode themeMode;

  const ThemeState({
    required this.colorMode,
    required this.themeMode,
  });

  /// Create a copy of this state with some fields replaced
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

/// Notifier for managing theme state
///
/// Handles:
/// - Loading saved theme preference from storage on initialization
/// - Updating and persisting theme preference changes
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          colorMode: ThemeService.getThemeMode(),
          themeMode: ThemeService.toThemeMode(ThemeService.getThemeMode()),
        ));

  /// Update theme mode and persist to storage
  Future<void> setThemeMode(ColorMode colorMode) async {
    await ThemeService.setThemeMode(colorMode);
    state = ThemeState(
      colorMode: colorMode,
      themeMode: ThemeService.toThemeMode(colorMode),
    );
  }
}

/// Provider for theme state
/// Usage: ref.watch(themeProvider) to get ThemeState
///        ref.read(themeProvider.notifier).setThemeMode() to change theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
