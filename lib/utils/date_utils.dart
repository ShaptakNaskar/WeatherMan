import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateTimeUtils {
  /// Format time as "3 PM" or "3:30 PM"
  static String formatHour(DateTime dateTime) {
    return DateFormat('h a').format(dateTime);
  }

  /// Format as "Now" if within current hour, else hour
  static String formatHourOrNow(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.hour == now.hour && dateTime.day == now.day) {
      return 'Now';
    }
    return formatHour(dateTime);
  }

  /// Format day name (Today, Tomorrow, Mon, Tue, etc.)
  static String formatDayName(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return 'Today';
    if (date == tomorrow) return 'Tomorrow';
    return DateFormat('EEE').format(dateTime);
  }

  /// Format full day name (Monday, Tuesday, etc.)
  static String formatFullDayName(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return 'Today';
    if (date == tomorrow) return 'Tomorrow';
    return DateFormat('EEEE').format(dateTime);
  }

  /// Format date as "Feb 8"
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }

  /// Format time as "7:30 AM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format relative time "3 min ago", "1 hour ago"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  /// Check if datetime is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;
  }
}
