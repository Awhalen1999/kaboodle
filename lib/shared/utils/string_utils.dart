/// Utility class for string operations
class StringUtils {
  StringUtils._(); // Private constructor to prevent instantiation

  /// Capitalizes the first letter of a string
  /// Returns empty string if input is null or empty
  ///
  /// Example:
  /// ```dart
  /// StringUtils.capitalize('hello') // Returns 'Hello'
  /// StringUtils.capitalize('WORLD') // Returns 'WORLD'
  /// StringUtils.capitalize('') // Returns ''
  /// ```
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizes the first letter of each word in a string
  /// Returns empty string if input is null or empty
  ///
  /// Example:
  /// ```dart
  /// StringUtils.capitalizeWords('hello world') // Returns 'Hello World'
  /// ```
  static String capitalizeWords(String? text) {
    if (text == null || text.isEmpty) return '';
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Converts a list of strings to a comma-separated string with capitalized values
  /// Returns empty string if input is null or empty
  ///
  /// Example:
  /// ```dart
  /// StringUtils.joinCapitalized(['warm', 'cold']) // Returns 'Warm, Cold'
  /// ```
  static String joinCapitalized(List<dynamic>? items) {
    if (items == null || items.isEmpty) return '';
    return items.map((item) => capitalize(item.toString())).join(', ');
  }
}
