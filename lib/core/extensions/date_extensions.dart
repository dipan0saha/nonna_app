import 'package:intl/intl.dart';

/// Extension methods for DateTime
///
/// **Functional Requirements**: Section 3.3.1 - Date/Time Helpers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides extension methods on DateTime:
/// - isToday, isFuture, isPast checks
/// - add/subtract helpers
/// - format shortcuts
///
/// No external dependencies
extension DateTimeExtensions on DateTime {
  // ============================================================
  // Date Comparison
  // ============================================================

  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if this date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if this date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if this date is in the current week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)).startOfDay;
    final weekEnd = weekStart.add(const Duration(days: 7));
    return (isAfter(weekStart) || isAtSameMomentAs(weekStart)) && isBefore(weekEnd);
  }

  /// Check if this date is in the current month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if this date is in the current year
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  // ============================================================
  // Date Manipulation
  // ============================================================

  /// Add days to this date
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days from this date
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add months to this date
  DateTime addMonths(int months) {
    int newMonth = month + months;
    int newYear = year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }

    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    // Handle day overflow (e.g., Jan 31 -> Feb 28 or Feb 29 -> Feb 28 in non-leap years)
    int maxDaysInMonth = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = day > maxDaysInMonth ? maxDaysInMonth : day;

    return DateTime(
        newYear, newMonth, newDay, hour, minute, second, millisecond);
  }

  /// Subtract months from this date
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Add years to this date
  DateTime addYears(int years) => DateTime(
        year + years,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
      );

  /// Subtract years from this date
  DateTime subtractYears(int years) => addYears(-years);

  /// Get the start of the day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get the end of the day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get the start of the week (Monday)
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  /// Get the end of the week (Sunday)
  DateTime get endOfWeek => add(Duration(days: 7 - weekday)).endOfDay;

  /// Get the start of the month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get the end of the month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Get the start of the year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get the end of the year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // ============================================================
  // Date Formatting Shortcuts
  // ============================================================

  /// Format as "Jan 1, 2024"
  String get formatShort => DateFormat.yMMMd().format(this);

  /// Format as "January 1, 2024"
  String get formatLong => DateFormat.yMMMMd().format(this);

  /// Format as "Monday, January 1, 2024"
  String get formatFull => DateFormat.yMMMMEEEEd().format(this);

  /// Format as "1/1/2024"
  String get formatNumeric => DateFormat.yMd().format(this);

  /// Format as "3:45 PM"
  String get formatTime => DateFormat.jm().format(this);

  /// Format as "Jan 1, 2024 3:45 PM"
  String get formatDateTime => DateFormat.yMMMd().add_jm().format(this);

  /// Format as ISO 8601 string
  String get formatIso8601 => toIso8601String();

  // ============================================================
  // Relative Time
  // ============================================================

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future date
      final futureDifference = difference.abs();
      if (futureDifference.inDays > 365) {
        final years = (futureDifference.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      } else if (futureDifference.inDays > 30) {
        final months = (futureDifference.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else if (futureDifference.inDays > 0) {
        return 'in ${futureDifference.inDays} ${futureDifference.inDays == 1 ? 'day' : 'days'}';
      } else if (futureDifference.inHours > 0) {
        return 'in ${futureDifference.inHours} ${futureDifference.inHours == 1 ? 'hour' : 'hours'}';
      } else if (futureDifference.inMinutes > 0) {
        return 'in ${futureDifference.inMinutes} ${futureDifference.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'in a few seconds';
      }
    } else {
      // Past date
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
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

  // ============================================================
  // Age Calculation
  // ============================================================

  /// Get age in years from this date
  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Get age in months from this date
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - year) * 12 + (now.month - month);
    if (now.day < day) {
      months--;
    }
    return months;
  }

  /// Get age in days from this date
  int get ageInDays => DateTime.now().difference(this).inDays;

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Check if this date is on the same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is on the same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if this date is on the same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Get the number of days in this month
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Check if this is a leap year
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get the day of the year (1-366)
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }

  /// Get the week of the year (1-53)
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceStart = difference(firstDayOfYear).inDays;
    return ((daysSinceStart + firstDayOfYear.weekday) / 7).ceil();
  }
}
