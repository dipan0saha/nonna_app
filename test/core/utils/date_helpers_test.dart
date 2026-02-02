import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/date_helpers.dart';

void main() {
  group('DateHelpers', () {
    group('formatShort', () {
      test('formats date as short format', () {
        final date = DateTime(2024, 1, 15);
        expect(DateHelpers.formatShort(date), 'Jan 15, 2024');
      });

      test('handles different months', () {
        final date = DateTime(2024, 12, 25);
        expect(DateHelpers.formatShort(date), 'Dec 25, 2024');
      });
    });

    group('formatLong', () {
      test('formats date as long format', () {
        final date = DateTime(2024, 1, 15);
        expect(DateHelpers.formatLong(date), 'January 15, 2024');
      });
    });

    group('formatFull', () {
      test('formats date with day of week', () {
        final date = DateTime(2024, 1, 15);
        expect(DateHelpers.formatFull(date), 'Monday, January 15, 2024');
      });
    });

    group('formatNumeric', () {
      test('formats date as numeric', () {
        final date = DateTime(2024, 1, 15);
        expect(DateHelpers.formatNumeric(date), '1/15/2024');
      });
    });

    group('formatTime', () {
      test('formats time in 12-hour format', () {
        final date = DateTime(2024, 1, 15, 15, 45);
        expect(DateHelpers.formatTime(date), '3:45 PM');
      });

      test('formats morning time', () {
        final date = DateTime(2024, 1, 15, 9, 30);
        expect(DateHelpers.formatTime(date), '9:30 AM');
      });
    });

    group('formatDateTime', () {
      test('formats date and time together', () {
        final date = DateTime(2024, 1, 15, 15, 45);
        expect(DateHelpers.formatDateTime(date), 'Jan 15, 2024 3:45 PM');
      });
    });

    group('formatCustom', () {
      test('formats with custom pattern', () {
        final date = DateTime(2024, 1, 15);
        expect(DateHelpers.formatCustom(date, 'yyyy-MM-dd'), '2024-01-15');
      });
    });

    group('formatRelative', () {
      test('returns "Today" for current date', () {
        final today = DateTime.now();
        expect(DateHelpers.formatRelative(today), 'Today');
      });

      test('returns "Yesterday" for previous day', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.formatRelative(yesterday), 'Yesterday');
      });

      test('returns "Tomorrow" for next day', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(DateHelpers.formatRelative(tomorrow), 'Tomorrow');
      });

      test('returns days ago for recent past dates', () {
        final date = DateTime.now().subtract(const Duration(days: 3));
        expect(DateHelpers.formatRelative(date), '3 days ago');
      });

      test('returns days until for near future dates', () {
        final date = DateTime.now().add(const Duration(days: 4));
        expect(DateHelpers.formatRelative(date), 'in 4 days');
      });

      test('returns formatted date for dates beyond 7 days', () {
        final date = DateTime.now().subtract(const Duration(days: 10));
        final result = DateHelpers.formatRelative(date);
        expect(result, isNot('Today'));
        expect(result, isNot(contains('days ago')));
      });
    });

    group('formatRelativeTime', () {
      test('returns "just now" for very recent time', () {
        final now = DateTime.now();
        expect(DateHelpers.formatRelativeTime(now), 'just now');
      });

      test('returns minutes ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        expect(DateHelpers.formatRelativeTime(date), '5 minutes ago');
      });

      test('returns single minute ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 1));
        expect(DateHelpers.formatRelativeTime(date), '1 minute ago');
      });

      test('returns hours ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 3));
        expect(DateHelpers.formatRelativeTime(date), '3 hours ago');
      });

      test('returns single hour ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 1));
        expect(DateHelpers.formatRelativeTime(date), '1 hour ago');
      });

      test('returns days ago', () {
        final date = DateTime.now().subtract(const Duration(days: 2));
        expect(DateHelpers.formatRelativeTime(date), '2 days ago');
      });

      test('returns future time in minutes', () {
        final date = DateTime.now().add(const Duration(minutes: 10));
        expect(DateHelpers.formatRelativeTime(date), 'in 10 minutes');
      });

      test('returns future time in hours', () {
        final date = DateTime.now().add(const Duration(hours: 2));
        expect(DateHelpers.formatRelativeTime(date), 'in 2 hours');
      });

      test('returns future time in days', () {
        final date = DateTime.now().add(const Duration(days: 3));
        expect(DateHelpers.formatRelativeTime(date), 'in 3 days');
      });
    });

    group('formatRelativeConcise', () {
      test('returns "now" for current time', () {
        final now = DateTime.now();
        expect(DateHelpers.formatRelativeConcise(now), 'now');
      });

      test('returns minutes in concise format', () {
        final date = DateTime.now().subtract(const Duration(minutes: 15));
        expect(DateHelpers.formatRelativeConcise(date), '15m');
      });

      test('returns hours in concise format', () {
        final date = DateTime.now().subtract(const Duration(hours: 5));
        expect(DateHelpers.formatRelativeConcise(date), '5h');
      });

      test('returns days in concise format', () {
        final date = DateTime.now().subtract(const Duration(days: 10));
        expect(DateHelpers.formatRelativeConcise(date), '10d');
      });

      test('returns months in concise format', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(DateHelpers.formatRelativeConcise(date), '2mo');
      });

      test('returns years in concise format', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        expect(DateHelpers.formatRelativeConcise(date), '1y');
      });
    });

    group('daysUntil', () {
      test('calculates days until future date', () {
        final future = DateTime.now().add(const Duration(days: 5));
        expect(DateHelpers.daysUntil(future), 5);
      });

      test('returns 0 for today', () {
        final today = DateTime.now();
        expect(DateHelpers.daysUntil(today), 0);
      });

      test('returns negative for past dates', () {
        final past = DateTime.now().subtract(const Duration(days: 3));
        expect(DateHelpers.daysUntil(past), -3);
      });
    });

    group('weeksUntil', () {
      test('calculates weeks until future date', () {
        final future = DateTime.now().add(const Duration(days: 14));
        expect(DateHelpers.weeksUntil(future), 2);
      });

      test('returns 0 for dates within a week', () {
        final near = DateTime.now().add(const Duration(days: 6));
        expect(DateHelpers.weeksUntil(near), 0);
      });
    });

    group('monthsUntil', () {
      test('calculates months until future date', () {
        final now = DateTime.now();
        final future = DateTime(now.year, now.month + 3, now.day);
        expect(DateHelpers.monthsUntil(future), 3);
      });

      test('handles year boundary', () {
        final now = DateTime(2024, 11, 15);
        final future = DateTime(2025, 2, 15);
        expect(DateHelpers.monthsUntil(future), 3);
      });

      test('adjusts for day of month', () {
        final now = DateTime(2024, 1, 15);
        final future = DateTime(2024, 2, 10);
        expect(DateHelpers.monthsUntil(future), 0);
      });
    });

    group('getCountdown', () {
      test('returns "Due today" for today', () {
        final today = DateTime.now();
        expect(DateHelpers.getCountdown(today), 'Due today');
      });

      test('returns "Due tomorrow" for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(DateHelpers.getCountdown(tomorrow), 'Due tomorrow');
      });

      test('returns days remaining for near future', () {
        final future = DateTime.now().add(const Duration(days: 5));
        expect(DateHelpers.getCountdown(future), '5 days remaining');
      });

      test('returns weeks remaining for medium future', () {
        final future = DateTime.now().add(const Duration(days: 14));
        expect(DateHelpers.getCountdown(future), '2 weeks remaining');
      });

      test('returns overdue message for past dates', () {
        final past = DateTime.now().subtract(const Duration(days: 3));
        expect(DateHelpers.getCountdown(past), 'Overdue by 3 days');
      });

      test('returns singular form for one day overdue', () {
        final past = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.getCountdown(past), 'Overdue by 1 day');
      });
    });

    group('calculateAgeYears', () {
      test('calculates age in years', () {
        final birthDate = DateTime(2000, 1, 1);
        final age = DateHelpers.calculateAgeYears(birthDate);
        expect(age, greaterThanOrEqualTo(24));
      });

      test('handles birthday not yet occurred this year', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 25, now.month + 1, now.day);
        final age = DateHelpers.calculateAgeYears(birthDate);
        expect(age, 24);
      });

      test('calculates age for leap year birth', () {
        final birthDate = DateTime(2000, 2, 29);
        final age = DateHelpers.calculateAgeYears(birthDate);
        expect(age, greaterThanOrEqualTo(23));
      });
    });

    group('calculateAgeMonths', () {
      test('calculates age in months', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 1, now.month, now.day);
        expect(DateHelpers.calculateAgeMonths(birthDate), 12);
      });

      test('handles partial months', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year, now.month - 3, now.day + 1);
        expect(DateHelpers.calculateAgeMonths(birthDate), 2);
      });
    });

    group('calculateAgeDays', () {
      test('calculates age in days', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 100));
        expect(DateHelpers.calculateAgeDays(birthDate), 100);
      });
    });

    group('getAgeString', () {
      test('returns years and months for adults', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 2, now.month - 3, now.day);
        final ageString = DateHelpers.getAgeString(birthDate);
        expect(ageString, contains('year'));
        expect(ageString, contains('month'));
      });

      test('returns months only for infants', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year, now.month - 6, now.day);
        final ageString = DateHelpers.getAgeString(birthDate);
        expect(ageString, contains('month'));
        expect(ageString, isNot(contains('year')));
      });

      test('returns days for newborns', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 15));
        final ageString = DateHelpers.getAgeString(birthDate);
        expect(ageString, contains('day'));
      });

      test('uses singular form for one year', () {
        final now = DateTime.now();
        final birthDate = DateTime(now.year - 1, now.month, now.day);
        expect(DateHelpers.getAgeString(birthDate), '1 year');
      });
    });

    group('isInRange', () {
      test('returns true for date in range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        final date = DateTime(2024, 6, 15);
        expect(DateHelpers.isInRange(date, start, end), true);
      });

      test('returns true for start date', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        expect(DateHelpers.isInRange(start, start, end), true);
      });

      test('returns true for end date', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        expect(DateHelpers.isInRange(end, start, end), true);
      });

      test('returns false for date before range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        final date = DateTime(2023, 12, 31);
        expect(DateHelpers.isInRange(date, start, end), false);
      });

      test('returns false for date after range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 12, 31);
        final date = DateTime(2025, 1, 1);
        expect(DateHelpers.isInRange(date, start, end), false);
      });
    });

    group('getDatesInRange', () {
      test('returns all dates in range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 5);
        final dates = DateHelpers.getDatesInRange(start, end);
        expect(dates.length, 5);
        expect(dates.first.day, 1);
        expect(dates.last.day, 5);
      });

      test('returns single date when start equals end', () {
        final date = DateTime(2024, 1, 1);
        final dates = DateHelpers.getDatesInRange(date, date);
        expect(dates.length, 1);
      });
    });

    group('daysBetween', () {
      test('calculates days between two dates', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 10);
        expect(DateHelpers.daysBetween(start, end), 9);
      });

      test('returns 0 for same date', () {
        final date = DateTime(2024, 1, 1);
        expect(DateHelpers.daysBetween(date, date), 0);
      });

      test('returns absolute value', () {
        final start = DateTime(2024, 1, 10);
        final end = DateTime(2024, 1, 1);
        expect(DateHelpers.daysBetween(start, end), 9);
      });
    });

    group('timezone handling', () {
      test('toUtc converts to UTC', () {
        final local = DateTime(2024, 1, 15, 12, 0);
        final utc = DateHelpers.toUtc(local);
        expect(utc.isUtc, true);
      });

      test('toLocal converts to local timezone', () {
        final utc = DateTime.utc(2024, 1, 15, 12, 0);
        final local = DateHelpers.toLocal(utc);
        expect(local.isUtc, false);
      });

      test('parseIso8601 parses valid ISO string', () {
        final result = DateHelpers.parseIso8601('2024-01-15T12:00:00Z');
        expect(result, isNotNull);
        expect(result!.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
      });

      test('parseIso8601 returns null for invalid string', () {
        final result = DateHelpers.parseIso8601('invalid');
        expect(result, isNull);
      });

      test('toIso8601 formats as ISO string', () {
        final date = DateTime.utc(2024, 1, 15, 12, 0);
        final iso = DateHelpers.toIso8601(date);
        expect(iso, '2024-01-15T12:00:00.000Z');
      });
    });

    group('special date checks', () {
      test('isToday returns true for today', () {
        final today = DateTime.now();
        expect(DateHelpers.isToday(today), true);
      });

      test('isToday returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.isToday(yesterday), false);
      });

      test('isPast returns true for past dates', () {
        final past = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.isPast(past), true);
      });

      test('isPast returns false for future dates', () {
        final future = DateTime.now().add(const Duration(days: 1));
        expect(DateHelpers.isPast(future), false);
      });

      test('isFuture returns true for future dates', () {
        final future = DateTime.now().add(const Duration(days: 1));
        expect(DateHelpers.isFuture(future), true);
      });

      test('isFuture returns false for past dates', () {
        final past = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.isFuture(past), false);
      });

      test('isWeekend returns true for Saturday', () {
        final saturday = DateTime(2024, 1, 6); // Known Saturday
        expect(DateHelpers.isWeekend(saturday), true);
      });

      test('isWeekend returns true for Sunday', () {
        final sunday = DateTime(2024, 1, 7); // Known Sunday
        expect(DateHelpers.isWeekend(sunday), true);
      });

      test('isWeekend returns false for weekday', () {
        final monday = DateTime(2024, 1, 8); // Known Monday
        expect(DateHelpers.isWeekend(monday), false);
      });

      test('isWeekday returns true for Monday', () {
        final monday = DateTime(2024, 1, 8); // Known Monday
        expect(DateHelpers.isWeekday(monday), true);
      });

      test('isWeekday returns false for Saturday', () {
        final saturday = DateTime(2024, 1, 6); // Known Saturday
        expect(DateHelpers.isWeekday(saturday), false);
      });
    });

    group('date construction', () {
      test('today returns current date without time', () {
        final today = DateHelpers.today;
        final now = DateTime.now();
        expect(today.year, now.year);
        expect(today.month, now.month);
        expect(today.day, now.day);
        expect(today.hour, 0);
        expect(today.minute, 0);
      });

      test('yesterday returns previous day', () {
        final yesterday = DateHelpers.yesterday;
        final expected = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.day, expected.day);
      });

      test('tomorrow returns next day', () {
        final tomorrow = DateHelpers.tomorrow;
        final expected = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.day, expected.day);
      });

      test('startOfWeek returns Monday', () {
        final startOfWeek = DateHelpers.startOfWeek;
        expect(startOfWeek.weekday, DateTime.monday);
      });

      test('endOfWeek returns Sunday', () {
        final endOfWeek = DateHelpers.endOfWeek;
        expect(endOfWeek.weekday, DateTime.sunday);
      });

      test('startOfMonth returns first day', () {
        final startOfMonth = DateHelpers.startOfMonth;
        expect(startOfMonth.day, 1);
      });

      test('endOfMonth returns last day', () {
        final endOfMonth = DateHelpers.endOfMonth;
        expect(endOfMonth.day, greaterThanOrEqualTo(28));
        expect(endOfMonth.day, lessThanOrEqualTo(31));
      });
    });

    group('edge cases', () {
      test('handles leap year dates correctly', () {
        final leapDay = DateTime(2024, 2, 29);
        expect(DateHelpers.formatShort(leapDay), 'Feb 29, 2024');
      });

      test('handles year boundaries', () {
        final newYear = DateTime(2024, 1, 1);
        final oldYear = DateTime(2023, 12, 31);
        expect(DateHelpers.daysBetween(oldYear, newYear), 1);
      });

      test('handles very old dates', () {
        final oldDate = DateTime(1900, 1, 1);
        expect(DateHelpers.formatShort(oldDate), isNotEmpty);
      });

      test('handles far future dates', () {
        final futureDate = DateTime(2100, 12, 31);
        expect(DateHelpers.formatShort(futureDate), isNotEmpty);
      });
    });
  });
}
