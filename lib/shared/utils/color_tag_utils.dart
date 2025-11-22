import 'package:flutter/material.dart';

/// Utility class for converting color tag strings to Color objects
class ColorTagUtils {
  ColorTagUtils._(); // Private constructor to prevent instantiation

  /// Default fallback colors for when colorTag is null or unknown
  static const List<Color> defaultColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  /// Convert colorTag string to Color object
  ///
  /// Returns the corresponding Color for the colorTag string.
  /// Falls back to a default color from the defaultColors list based on index
  /// if colorTag is null or unknown.
  ///
  /// Supported color tags: 'red', 'blue', 'green', 'purple', 'orange', 'pink', 'grey', 'gray'
  static Color getColorFromTag(String? colorTag, [int fallbackIndex = 0]) {
    if (colorTag != null) {
      switch (colorTag.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'purple':
          return Colors.purple;
        case 'orange':
          return Colors.orange;
        case 'pink':
          return Colors.pink;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          // Fall through to fallback color
          break;
      }
    }

    // Fallback to index-based colors if colorTag is null or unknown
    return defaultColors[fallbackIndex % defaultColors.length];
  }
}
