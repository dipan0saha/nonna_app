import 'package:intl/intl.dart';

/// Date and time helper functions
///
/// Provides utilities for date formatting, calculations, and timezone handling.
class DateHelpers {
  // Prevent instantiation
  DateHelpers._();

  // ============================================================
  // Date Formatting
  // ============================================================

  /// Format date as "Jan 1, 2024"
  static String formatShort(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format date as "January 1, 2024"
  static String formatLong(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  /// Format date as "Monday, January 1, 2024"
  static String formatFull(DateTime date) {
    return DateFormat.yMMMMEEEEd().format(date);
  }

  /// Format date as "1/1/2024"
  static String formatNumeric(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  /// Format time as "3:45 PM"
  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Format date and time as "Jan 1, 2024 3:45 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Format with custom pattern
  static String formatCustom(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  // ============================================================
  // Relative Date Formatting
  // ============================================================

  /// Get relative date string (e.g., "Today", "Yesterday", "2 days ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '$difference days ago';
    } else if (difference < -1 && difference >= -7) {
      return 'in ${-difference} days';
    } else if (date.year == now.year) {
      return DateFormat.MMMd().format(date);
    } else {
      return formatShort(date);
    }
  }

  /// Get relative time string with time included (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      final futureDifference = difference.abs();
      if (futureDifference.inDays > 0) {
        return 'in ${futureDifference.inDays} ${futureDifference.inDays == 1 ? 'day' : 'days'}';
      } else if (futureDifference.inHours > 0) {
        return 'in ${futureDifference.inHours} ${futureDifference.inHours == 1 ? 'hour' : 'hours'}';
      } else if (futureDifference.inMinutes > 0) {
        return 'in ${futureDifference.inMinutes} ${futureDifference.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'in a few seconds';
      }
    } else {
      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'just now';
      }
    }
  }

  /// Get concise relative time (e.g., "2h", "3d")
  static String formatRelativeConcise(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // ============================================================
  // Due Date Calculations
  // ============================================================

  /// Calculate days until a due date
  static int daysUntil(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  /// Calculate weeks until a due date
  static int weeksUntil(DateTime dueDate) {
    return (daysUntil(dueDate) / 7).floor();
  }

  /// Calculate months until a due date
  static int monthsUntil(DateTime dueDate) {
    final now = DateTime.now();
    int months = (dueDate.year - now.year) * 12 + (dueDate.month - now.month);
    if (dueDate.day < now.day) {
      months--;
    }
    return months;
  }

  /// Get countdown string for due date
  static String getCountdown(DateTime dueDate) {
    final days = daysUntil(dueDate);
    
    if (days < 0) {
      return 'Overdue by ${-days} ${-days == 1 ? 'day' : 'days'}';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else if (days <= 7) {
      return '$days days remaining';
    } else if (days <= 30) {
      final weeks = weeksUntil(dueDate);
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} remaining';
    } else {
      final months = monthsUntil(dueDate);
      return '$months ${months == 1 ? 'month' : 'months'} remaining';
    }
  }

  // ============================================================
  // Age Calculations
  // ============================================================

  /// Calculate age in years from birth date
  static int calculateAgeYears(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculate age in months from birth date
  static int calculateAgeMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  /// Calculate age in days from birth date
  static int calculateAgeDays(DateTime birthDate) {
    return DateTime.now().difference(birthDate).inDays;
  }

  /// Get formatted age string (e.g., "2 years, 3 months")
  static String getAgeString(DateTime birthDate) {
    final years = calculateAgeYears(birthDate);
    final months = calculateAgeMonths(birthDate) % 12;

    if (years > 0) {
      if (months > 0) {
        return '$years ${years == 1 ? 'year' : 'years'}, $months ${months == 1 ? 'month' : 'months'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'}';
      }
    } else if (months > 0) {
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final days = calculateAgeDays(birthDate);
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }

  // ============================================================
  // Date Range Utilities
  // ============================================================

  /// Check if date is in range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }

  /// Get all dates in a range
  static List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Get number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.abs();
  }

  // ============================================================
  // Timezone Handling
  // ============================================================

  /// Convert to UTC
  static DateTime toUtc(DateTime date) {
    return date.toUtc();
  }

  /// Convert to local timezone
  static DateTime toLocal(DateTime date) {
    return date.toLocal();
  }

  /// Parse ISO 8601 string
  static DateTime? parseIso8601(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format as ISO 8601 string
  static String toIso8601(DateTime date) {
    return date.toIso8601String();
  }

  // ============================================================
  // Special Date Checks
  // ============================================================

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if date is a weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Check if date is a weekday
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  // ============================================================
  // Date Construction
  // ============================================================

  /// Get current date without time
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get yesterday's date
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// Get tomorrow's date
  static DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  /// Get start of current week (Monday)
  static DateTime get startOfWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// Get end of current week (Sunday)
  static DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6));
  }

  /// Get start of current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get end of current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }
}
