import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/extensions/date_extensions.dart';

void main() {
  group('DateTimeExtensions', () {
    group('date comparison', () {
      test('isToday returns true for today', () {
        final now = DateTime.now();
        expect(now.isToday, true);
      });

      test('isToday returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, false);
      });

      test('isYesterday returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, true);
      });

      test('isYesterday returns false for today', () {
        final now = DateTime.now();
        expect(now.isYesterday, false);
      });

      test('isTomorrow returns true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isTomorrow, true);
      });

      test('isTomorrow returns false for today', () {
        final now = DateTime.now();
        expect(now.isTomorrow, false);
      });

      test('isPast returns true for past dates', () {
        final past = DateTime(2020, 1, 1);
        expect(past.isPast, true);
      });

      test('isFuture returns true for future dates', () {
        final future = DateTime.now().add(const Duration(days: 365));
        expect(future.isFuture, true);
      });

      test('isThisWeek returns true for dates in current week', () {
        final now = DateTime.now();
        expect(now.isThisWeek, true);
      });

      test('isThisMonth returns true for dates in current month', () {
        final now = DateTime.now();
        expect(now.isThisMonth, true);
      });

      test('isThisMonth returns false for last month', () {
        final lastMonth = DateTime.now().subtract(const Duration(days: 32));
        expect(lastMonth.isThisMonth, false);
      });

      test('isThisYear returns true for dates in current year', () {
        final now = DateTime.now();
        expect(now.isThisYear, true);
      });

      test('isThisYear returns false for last year', () {
        final lastYear = DateTime.now().subtract(const Duration(days: 400));
        expect(lastYear.isThisYear, false);
      });
    });

    group('date manipulation', () {
      test('addDays adds days correctly', () {
        final date = DateTime(2024, 1, 1);
        final result = date.addDays(5);
        expect(result.day, 6);
        expect(result.month, 1);
        expect(result.year, 2024);
      });

      test('subtractDays subtracts days correctly', () {
        final date = DateTime(2024, 1, 10);
        final result = date.subtractDays(5);
        expect(result.day, 5);
      });

      test('addMonths adds months correctly', () {
        final date = DateTime(2024, 1, 15);
        final result = date.addMonths(3);
        expect(result.month, 4);
        expect(result.year, 2024);
      });

      test('addMonths handles year overflow', () {
        final date = DateTime(2024, 11, 15);
        final result = date.addMonths(3);
        expect(result.month, 2);
        expect(result.year, 2025);
      });

      test('subtractMonths subtracts months correctly', () {
        final date = DateTime(2024, 5, 15);
        final result = date.subtractMonths(2);
        expect(result.month, 3);
      });

      test('addYears adds years correctly', () {
        final date = DateTime(2024, 1, 15);
        final result = date.addYears(2);
        expect(result.year, 2026);
      });

      test('subtractYears subtracts years correctly', () {
        final date = DateTime(2024, 1, 15);
        final result = date.subtractYears(2);
        expect(result.year, 2022);
      });

      test('startOfDay returns midnight', () {
        final date = DateTime(2024, 1, 15, 14, 30, 45);
        final result = date.startOfDay;
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.day, 15);
      });

      test('endOfDay returns last moment of day', () {
        final date = DateTime(2024, 1, 15, 10, 30);
        final result = date.endOfDay;
        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });

      test('startOfWeek returns Monday', () {
        final date = DateTime(2024, 1, 17); // Wednesday
        final result = date.startOfWeek;
        expect(result.weekday, DateTime.monday);
      });

      test('endOfWeek returns Sunday', () {
        final date = DateTime(2024, 1, 17); // Wednesday
        final result = date.endOfWeek;
        expect(result.weekday, DateTime.sunday);
      });

      test('startOfMonth returns first day of month', () {
        final date = DateTime(2024, 1, 15);
        final result = date.startOfMonth;
        expect(result.day, 1);
        expect(result.month, 1);
      });

      test('endOfMonth returns last day of month', () {
        final date = DateTime(2024, 1, 15);
        final result = date.endOfMonth;
        expect(result.day, 31);
        expect(result.month, 1);
      });

      test('startOfYear returns January 1', () {
        final date = DateTime(2024, 6, 15);
        final result = date.startOfYear;
        expect(result.month, 1);
        expect(result.day, 1);
      });

      test('endOfYear returns December 31', () {
        final date = DateTime(2024, 6, 15);
        final result = date.endOfYear;
        expect(result.month, 12);
        expect(result.day, 31);
      });
    });

    group('date formatting', () {
      final testDate = DateTime(2024, 1, 15, 14, 30);

      test('formatShort returns short date format', () {
        expect(testDate.formatShort.isNotEmpty, true);
      });

      test('formatLong returns long date format', () {
        expect(testDate.formatLong.isNotEmpty, true);
      });

      test('formatFull returns full date format', () {
        expect(testDate.formatFull.isNotEmpty, true);
      });

      test('formatNumeric returns numeric date format', () {
        expect(testDate.formatNumeric.isNotEmpty, true);
      });

      test('formatTime returns time format', () {
        expect(testDate.formatTime.isNotEmpty, true);
      });

      test('formatDateTime returns date and time format', () {
        expect(testDate.formatDateTime.isNotEmpty, true);
      });

      test('formatIso8601 returns ISO 8601 format', () {
        expect(testDate.formatIso8601.contains('2024'), true);
      });
    });

    group('relative time', () {
      test('returns "just now" for very recent dates', () {
        final recent = DateTime.now().subtract(const Duration(seconds: 5));
        expect(recent.relativeTime, 'just now');
      });

      test('returns minutes ago for recent minutes', () {
        final recent = DateTime.now().subtract(const Duration(minutes: 5));
        expect(recent.relativeTime.contains('minute'), true);
      });

      test('returns hours ago for recent hours', () {
        final recent = DateTime.now().subtract(const Duration(hours: 2));
        expect(recent.relativeTime.contains('hour'), true);
      });

      test('returns days ago for recent days', () {
        final recent = DateTime.now().subtract(const Duration(days: 3));
        expect(recent.relativeTime.contains('day'), true);
      });

      test('returns months ago for past months', () {
        final recent = DateTime.now().subtract(const Duration(days: 40));
        expect(recent.relativeTime.contains('month'), true);
      });

      test('returns years ago for past years', () {
        final recent = DateTime.now().subtract(const Duration(days: 400));
        expect(recent.relativeTime.contains('year'), true);
      });

      test('returns "in X days" for future dates', () {
        final future = DateTime.now().add(const Duration(days: 5));
        expect(future.relativeTime.contains('in'), true);
        expect(future.relativeTime.contains('day'), true);
      });

      test('returns "in X hours" for near future', () {
        final future = DateTime.now().add(const Duration(hours: 3));
        expect(future.relativeTime.contains('in'), true);
        expect(future.relativeTime.contains('hour'), true);
      });
    });

    group('age calculation', () {
      test('ageInYears calculates age correctly', () {
        final birthDate = DateTime(2020, 1, 1);
        expect(birthDate.ageInYears, greaterThanOrEqualTo(3));
      });

      test('ageInYears handles birthday not yet occurred', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 5, now.month + 1, 1);
        expect(birthDate.ageInYears, 4);
      });

      test('ageInMonths calculates months correctly', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 60));
        expect(birthDate.ageInMonths, greaterThanOrEqualTo(1));
      });

      test('ageInDays calculates days correctly', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 10));
        expect(birthDate.ageInDays, 10);
      });
    });

    group('utility methods', () {
      test('isSameDay returns true for same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 18, 45);
        expect(date1.isSameDay(date2), true);
      });

      test('isSameDay returns false for different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        expect(date1.isSameDay(date2), false);
      });

      test('isSameMonth returns true for same month', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 25);
        expect(date1.isSameMonth(date2), true);
      });

      test('isSameMonth returns false for different months', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 2, 15);
        expect(date1.isSameMonth(date2), false);
      });

      test('isSameYear returns true for same year', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 6, 25);
        expect(date1.isSameYear(date2), true);
      });

      test('isSameYear returns false for different years', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2025, 1, 15);
        expect(date1.isSameYear(date2), false);
      });

      test('daysInMonth returns correct number of days', () {
        expect(DateTime(2024, 1, 1).daysInMonth, 31);
        expect(DateTime(2024, 2, 1).daysInMonth, 29); // Leap year
        expect(DateTime(2023, 2, 1).daysInMonth, 28);
        expect(DateTime(2024, 4, 1).daysInMonth, 30);
      });

      test('isLeapYear returns true for leap years', () {
        expect(DateTime(2024, 1, 1).isLeapYear, true);
        expect(DateTime(2000, 1, 1).isLeapYear, true);
      });

      test('isLeapYear returns false for non-leap years', () {
        expect(DateTime(2023, 1, 1).isLeapYear, false);
        expect(DateTime(1900, 1, 1).isLeapYear, false);
      });

      test('dayOfYear calculates correct day of year', () {
        expect(DateTime(2024, 1, 1).dayOfYear, 1);
        expect(DateTime(2024, 12, 31).dayOfYear, 366); // Leap year
        expect(DateTime(2023, 12, 31).dayOfYear, 365);
      });

      test('weekOfYear calculates week number', () {
        final date = DateTime(2024, 1, 15);
        expect(date.weekOfYear, greaterThan(0));
        expect(date.weekOfYear, lessThanOrEqualTo(53));
      });
    });

    group('edge cases', () {
      test('handles leap year edge cases in addMonths', () {
        final date = DateTime(2024, 2, 29);
        final result = date.addMonths(12);
        expect(result.year, 2025);
        expect(result.month, 2);
      });

      test('handles month overflow correctly', () {
        final date = DateTime(2024, 12, 15);
        final result = date.addMonths(2);
        expect(result.year, 2025);
        expect(result.month, 2);
      });

      test('handles negative month operations', () {
        final date = DateTime(2024, 3, 15);
        final result = date.addMonths(-5);
        expect(result.year, 2023);
        expect(result.month, 10);
      });
    });
  });
}
