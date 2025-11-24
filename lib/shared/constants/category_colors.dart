import 'package:flutter/material.dart';

class CategoryColors {
  // Backend categories: "clothing" | "toiletries" | "electronics" | "documents" | "sports" | "medications" | "accessories"
  static const Map<String, Color> lightModeColors = {
    'clothing': Color(0xFFE53935), // Red
    'toiletries': Color(0xFF1E88E5), // Blue
    'electronics': Color(0xFFFFB300), // Amber
    'documents': Color(0xFF43A047), // Green
    'accessories': Color(0xFF8E24AA), // Purple
    'medications': Color(0xFFFF6F00), // Deep Orange
    'sports': Color(0xFF00ACC1), // Cyan
  };

  static const Map<String, Color> darkModeColors = {
    'clothing': Color(0xFFEF5350), // Lighter Red
    'toiletries': Color(0xFF42A5F5), // Lighter Blue
    'electronics': Color(0xFFFFCA28), // Lighter Amber
    'documents': Color(0xFF66BB6A), // Lighter Green
    'accessories': Color(0xFFAB47BC), // Lighter Purple
    'medications': Color(0xFFFF8A50), // Lighter Deep Orange
    'sports': Color(0xFF26C6DA), // Lighter Cyan
  };

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

  static Color getCategoryColorWithContext(String category, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return getCategoryColor(category, isDarkMode);
  }
}
