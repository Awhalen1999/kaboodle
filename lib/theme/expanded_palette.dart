import 'package:flutter/material.dart';

/// Expanded color palette for category-based theming
/// Backend categories: "clothing" | "toiletries" | "electronics" | "documents" | "sports" | "medications" | "accessories"
class ExpandedPalette {
  // Light Mode Category Colors
  static const Color clothingLight = Color(0xFFE53935); // Red
  static const Color toiletriesLight = Color(0xFF1E88E5); // Blue
  static const Color electronicsLight = Color(0xFFFFB300); // Amber
  static const Color documentsLight = Color(0xFF43A047); // Green
  static const Color accessoriesLight = Color(0xFF8E24AA); // Purple
  static const Color medicationsLight = Color(0xFFFF6F00); // Deep Orange
  static const Color sportsLight = Color(0xFF00ACC1); // Cyan

  // Dark Mode Category Colors
  static const Color clothingDark = Color(0xFFEF5350); // Lighter Red
  static const Color toiletriesDark = Color(0xFF42A5F5); // Lighter Blue
  static const Color electronicsDark = Color(0xFFFFCA28); // Lighter Amber
  static const Color documentsDark = Color(0xFF66BB6A); // Lighter Green
  static const Color accessoriesDark = Color(0xFFAB47BC); // Lighter Purple
  static const Color medicationsDark = Color(0xFFFF8A50); // Lighter Deep Orange
  static const Color sportsDark = Color(0xFF26C6DA); // Lighter Cyan

  // Color Maps
  static const Map<String, Color> lightModeColors = {
    'clothing': clothingLight,
    'toiletries': toiletriesLight,
    'electronics': electronicsLight,
    'documents': documentsLight,
    'accessories': accessoriesLight,
    'medications': medicationsLight,
    'sports': sportsLight,
  };

  static const Map<String, Color> darkModeColors = {
    'clothing': clothingDark,
    'toiletries': toiletriesDark,
    'electronics': electronicsDark,
    'documents': documentsDark,
    'accessories': accessoriesDark,
    'medications': medicationsDark,
    'sports': sportsDark,
  };

  /// Get category color based on category name and dark mode setting
  static Color getCategoryColor(String category, bool isDarkMode) {
    final colorMap = isDarkMode ? darkModeColors : lightModeColors;

    // Try exact match first (lowercase from backend)
    if (colorMap.containsKey(category)) {
      return colorMap[category]!;
    }

    // Try case-insensitive match for any display name variations
    final lowerCategory = category.toLowerCase();
    if (colorMap.containsKey(lowerCategory)) {
      return colorMap[lowerCategory]!;
    }

    // Fallback to grey for unknown categories
    return isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
  }

  /// Get category color with BuildContext for automatic dark mode detection
  static Color getCategoryColorWithContext(String category, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return getCategoryColor(category, isDarkMode);
  }
}
