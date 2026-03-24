import 'package:intl/intl.dart';

/// Utility class for consistent date/time formatting.
class DateFormatter {
  DateFormatter._();

  /// "Mon, 28 Apr 2025 • 10:00 AM"
  static String full(DateTime dt) {
    return DateFormat("EEE, dd MMM yyyy • hh:mm a").format(dt);
  }

  /// "28 Apr 2025"
  static String dateOnly(DateTime dt) {
    return DateFormat("dd MMM yyyy").format(dt);
  }

  /// "10:00 AM"
  static String timeOnly(DateTime dt) {
    return DateFormat("hh:mm a").format(dt);
  }

  /// "28 Apr"
  static String shortDate(DateTime dt) {
    return DateFormat("dd MMM").format(dt);
  }

  /// Relative description — "Today", "Tomorrow", or formatted date.
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today • ${timeOnly(dt)}';
    if (diff == 1) return 'Tomorrow • ${timeOnly(dt)}';
    return full(dt);
  }
}
