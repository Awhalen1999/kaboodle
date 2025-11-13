import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/profile/widgets/color_mode_selector.dart';

// Hive box name for theme preferences
const String _themeBoxName = 'theme_preferences';
const String _themeModeKey = 'theme_mode';

// Theme service for managing theme preferences with Hive
class ThemeService {
  static Box? _box;

  // Initialize Hive box for theme preferences
  static Future<void> init() async {
    _box = await Hive.openBox(_themeBoxName);
  }

  // Get saved theme mode, defaults to system
  static ColorMode getThemeMode() {
    if (_box == null) {
      return ColorMode.system;
    }

    final savedValue = _box!.get(_themeModeKey);
    if (savedValue == null) {
      return ColorMode.system;
    }

    try {
      return ColorMode.values[savedValue as int];
    } catch (e) {
      return ColorMode.system;
    }
  }

  // Save theme mode preference
  static Future<void> setThemeMode(ColorMode mode) async {
    if (_box == null) return;
    await _box!.put(_themeModeKey, mode.index);
  }

  // Convert ColorMode to Flutter's ThemeMode
  static ThemeMode toThemeMode(ColorMode colorMode) {
    switch (colorMode) {
      case ColorMode.light:
        return ThemeMode.light;
      case ColorMode.dark:
        return ThemeMode.dark;
      case ColorMode.system:
        return ThemeMode.system;
    }
  }
}
