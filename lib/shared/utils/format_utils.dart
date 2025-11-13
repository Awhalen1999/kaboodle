import 'package:intl/intl.dart';

// Utility class for formatting text and dates
class FormatUtils {
  // Format member since date (e.g., "January 2024")
  static String formatMemberSince(DateTime? creationTime) {
    if (creationTime == null) return 'Unknown';
    return DateFormat('MMMM yyyy').format(creationTime);
  }

  // Format display name - shows name if available, otherwise email username
  // If display name exists, returns first name only
  // Otherwise, returns email username with ellipsis if too long
  static String formatDisplayName(String? displayName, String email) {
    // If display name exists, use first name only
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }

    // Otherwise, use email username with ellipsis if too long
    final username = email.split('@').first;
    if (username.length > 12) {
      return '${username.substring(0, 12)}...';
    }
    return username;
  }
}
