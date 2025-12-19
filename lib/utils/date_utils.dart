import 'package:intl/intl.dart';

/// Utility class for date and time formatting operations.
///
/// Provides common date/time formatting patterns and helper methods
/// for consistent date/time handling across the application.
class DateUtils {
  DateUtils._(); // Private constructor to prevent instantiation

  // Common date format patterns
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm:ss';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String timeOnlyFormat = 'hh:mm a';

  /// Formats a [DateTime] to a string using the default date format (yyyy-MM-dd).
  ///
  /// Returns null if [date] is null.
  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat(defaultDateFormat).format(date);
  }

  /// Formats a [DateTime] to a string using the default time format (HH:mm:ss).
  ///
  /// Returns null if [time] is null.
  static String? formatTime(DateTime? time) {
    if (time == null) return null;
    return DateFormat(defaultTimeFormat).format(time);
  }

  /// Formats a [DateTime] to a string using the default date-time format (yyyy-MM-dd HH:mm:ss).
  ///
  /// Returns null if [dateTime] is null.
  static String? formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat(defaultDateTimeFormat).format(dateTime);
  }

  /// Formats a [DateTime] to a user-friendly display format (MMM dd, yyyy).
  ///
  /// Example: "Jan 15, 2024"
  /// Returns null if [date] is null.
  static String? formatDisplayDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat(displayDateFormat).format(date);
  }

  /// Formats a [DateTime] to a user-friendly display format with time (MMM dd, yyyy hh:mm a).
  ///
  /// Example: "Jan 15, 2024 03:30 PM"
  /// Returns null if [dateTime] is null.
  static String? formatDisplayDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat(displayDateTimeFormat).format(dateTime);
  }

  /// Formats a [DateTime] to display only the time in 12-hour format (hh:mm a).
  ///
  /// Example: "03:30 PM"
  /// Returns null if [time] is null.
  static String? formatTimeOnly(DateTime? time) {
    if (time == null) return null;
    return DateFormat(timeOnlyFormat).format(time);
  }

  /// Formats a [DateTime] using a custom format pattern.
  ///
  /// [dateTime] - The date/time to format
  /// [pattern] - The custom format pattern (e.g., 'yyyy/MM/dd')
  ///
  /// Returns null if [dateTime] is null.
  static String? formatCustom(DateTime? dateTime, String pattern) {
    if (dateTime == null) return null;
    return DateFormat(pattern).format(dateTime);
  }

  /// Parses a date string in the default format (yyyy-MM-dd) to a [DateTime].
  ///
  /// Throws [FormatException] if the string cannot be parsed.
  /// Returns null if [dateString] is null or empty.
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateFormat(defaultDateFormat).parse(dateString);
  }

  /// Parses a date-time string in the default format (yyyy-MM-dd HH:mm:ss) to a [DateTime].
  ///
  /// Throws [FormatException] if the string cannot be parsed.
  /// Returns null if [dateTimeString] is null or empty.
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    return DateFormat(defaultDateTimeFormat).parse(dateTimeString);
  }

  /// Parses a date string using a custom format pattern.
  ///
  /// [dateString] - The date string to parse
  /// [pattern] - The format pattern of the input string
  ///
  /// Throws [FormatException] if the string cannot be parsed.
  /// Returns null if [dateString] is null or empty.
  static DateTime? parseCustom(String? dateString, String pattern) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateFormat(pattern).parse(dateString);
  }

  /// Returns a human-readable relative time string (e.g., "2 hours ago", "in 3 days").
  ///
  /// [dateTime] - The date/time to compare with now
  ///
  /// Returns null if [dateTime] is null.
  static String? getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      // Future date
      final futureDiff = dateTime.difference(now);
      if (futureDiff.inSeconds < 60) {
        return 'in ${futureDiff.inSeconds} seconds';
      } else if (futureDiff.inMinutes < 60) {
        return 'in ${futureDiff.inMinutes} minutes';
      } else if (futureDiff.inHours < 24) {
        return 'in ${futureDiff.inHours} hours';
      } else if (futureDiff.inDays < 30) {
        return 'in ${futureDiff.inDays} days';
      } else if (futureDiff.inDays < 365) {
        return 'in ${(futureDiff.inDays / 30).floor()} months';
      } else {
        return 'in ${(futureDiff.inDays / 365).floor()} years';
      }
    } else {
      // Past date
      if (difference.inSeconds < 60) {
        return '${difference.inSeconds} seconds ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${(difference.inDays / 365).floor()} years ago';
      }
    }
  }

  /// Checks if two dates are on the same day (ignoring time).
  ///
  /// Returns false if either date is null.
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if a date is today.
  ///
  /// Returns false if [date] is null.
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    return isSameDay(date, DateTime.now());
  }

  /// Checks if a date is yesterday.
  ///
  /// Returns false if [date] is null.
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Checks if a date is tomorrow.
  ///
  /// Returns false if [date] is null.
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Returns the start of day (00:00:00) for the given date.
  ///
  /// Returns null if [date] is null.
  static DateTime? startOfDay(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of day (23:59:59.999) for the given date.
  ///
  /// Returns null if [date] is null.
  static DateTime? endOfDay(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Adds a duration to a date.
  ///
  /// Returns null if [date] is null.
  static DateTime? addDuration(DateTime? date, Duration duration) {
    if (date == null) return null;
    return date.add(duration);
  }

  /// Subtracts a duration from a date.
  ///
  /// Returns null if [date] is null.
  static DateTime? subtractDuration(DateTime? date, Duration duration) {
    if (date == null) return null;
    return date.subtract(duration);
  }
}
