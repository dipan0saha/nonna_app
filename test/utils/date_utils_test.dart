import 'package:test/test.dart';
import 'package:nonna_app/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    group('formatDate', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 1, 15, 14, 30, 45);
        expect(DateUtils.formatDate(date), equals('2024-01-15'));
      });

      test('returns null for null input', () {
        expect(DateUtils.formatDate(null), isNull);
      });
    });

    group('formatTime', () {
      test('formats time correctly', () {
        final time = DateTime(2024, 1, 15, 14, 30, 45);
        expect(DateUtils.formatTime(time), equals('14:30:45'));
      });

      test('returns null for null input', () {
        expect(DateUtils.formatTime(null), isNull);
      });
    });

    group('formatDateTime', () {
      test('formats date-time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
        expect(
          DateUtils.formatDateTime(dateTime),
          equals('2024-01-15 14:30:45'),
        );
      });

      test('returns null for null input', () {
        expect(DateUtils.formatDateTime(null), isNull);
      });
    });

    group('formatDisplayDate', () {
      test('formats date in display format', () {
        final date = DateTime(2024, 1, 15);
        expect(DateUtils.formatDisplayDate(date), equals('Jan 15, 2024'));
      });

      test('returns null for null input', () {
        expect(DateUtils.formatDisplayDate(null), isNull);
      });
    });

    group('formatDisplayDateTime', () {
      test('formats date-time in display format', () {
        final dateTime = DateTime(2024, 1, 15, 15, 30);
        expect(
          DateUtils.formatDisplayDateTime(dateTime),
          equals('Jan 15, 2024 03:30 PM'),
        );
      });

      test('returns null for null input', () {
        expect(DateUtils.formatDisplayDateTime(null), isNull);
      });
    });

    group('formatTimeOnly', () {
      test('formats time in 12-hour format', () {
        final time = DateTime(2024, 1, 15, 15, 30);
        expect(DateUtils.formatTimeOnly(time), equals('03:30 PM'));
      });

      test('formats morning time correctly', () {
        final time = DateTime(2024, 1, 15, 9, 15);
        expect(DateUtils.formatTimeOnly(time), equals('09:15 AM'));
      });

      test('returns null for null input', () {
        expect(DateUtils.formatTimeOnly(null), isNull);
      });
    });

    group('formatCustom', () {
      test('formats date with custom pattern', () {
        final date = DateTime(2024, 1, 15);
        expect(
          DateUtils.formatCustom(date, 'yyyy/MM/dd'),
          equals('2024/01/15'),
        );
      });

      test('formats date with different custom pattern', () {
        final date = DateTime(2024, 1, 15);
        expect(
          DateUtils.formatCustom(date, 'dd-MM-yyyy'),
          equals('15-01-2024'),
        );
      });

      test('returns null for null input', () {
        expect(DateUtils.formatCustom(null, 'yyyy-MM-dd'), isNull);
      });
    });

    group('parseDate', () {
      test('parses date string correctly', () {
        final parsed = DateUtils.parseDate('2024-01-15');
        expect(parsed, isNotNull);
        expect(parsed!.year, equals(2024));
        expect(parsed.month, equals(1));
        expect(parsed.day, equals(15));
      });

      test('returns null for null input', () {
        expect(DateUtils.parseDate(null), isNull);
      });

      test('returns null for empty string', () {
        expect(DateUtils.parseDate(''), isNull);
      });

      test('throws FormatException for invalid format', () {
        expect(() => DateUtils.parseDate('invalid'), throwsFormatException);
      });
    });

    group('parseDateTime', () {
      test('parses date-time string correctly', () {
        final parsed = DateUtils.parseDateTime('2024-01-15 14:30:45');
        expect(parsed, isNotNull);
        expect(parsed!.year, equals(2024));
        expect(parsed.month, equals(1));
        expect(parsed.day, equals(15));
        expect(parsed.hour, equals(14));
        expect(parsed.minute, equals(30));
        expect(parsed.second, equals(45));
      });

      test('returns null for null input', () {
        expect(DateUtils.parseDateTime(null), isNull);
      });

      test('returns null for empty string', () {
        expect(DateUtils.parseDateTime(''), isNull);
      });

      test('throws FormatException for invalid format', () {
        expect(() => DateUtils.parseDateTime('invalid'), throwsFormatException);
      });
    });

    group('parseCustom', () {
      test('parses date with custom pattern', () {
        final parsed = DateUtils.parseCustom('2024/01/15', 'yyyy/MM/dd');
        expect(parsed, isNotNull);
        expect(parsed!.year, equals(2024));
        expect(parsed.month, equals(1));
        expect(parsed.day, equals(15));
      });

      test('returns null for null input', () {
        expect(DateUtils.parseCustom(null, 'yyyy-MM-dd'), isNull);
      });

      test('returns null for empty string', () {
        expect(DateUtils.parseCustom('', 'yyyy-MM-dd'), isNull);
      });
    });

    group('getRelativeTime', () {
      test('returns "X seconds ago" for recent past', () {
        final time = DateTime.now().subtract(const Duration(seconds: 30));
        final result = DateUtils.getRelativeTime(time);
        expect(result, contains('seconds ago'));
      });

      test('returns "X minutes ago" for minutes', () {
        final time = DateTime.now().subtract(const Duration(minutes: 5));
        final result = DateUtils.getRelativeTime(time);
        expect(result, equals('5 minutes ago'));
      });

      test('returns "X hours ago" for hours', () {
        final time = DateTime.now().subtract(const Duration(hours: 3));
        final result = DateUtils.getRelativeTime(time);
        expect(result, equals('3 hours ago'));
      });

      test('returns "X days ago" for days', () {
        final time = DateTime.now().subtract(const Duration(days: 2));
        final result = DateUtils.getRelativeTime(time);
        expect(result, equals('2 days ago'));
      });

      test('returns "in X seconds" for near future', () {
        final time = DateTime.now().add(const Duration(seconds: 30));
        final result = DateUtils.getRelativeTime(time);
        expect(result, contains('in'));
        expect(result, contains('seconds'));
      });

      test('returns "in X minutes" for future minutes', () {
        final time = DateTime.now().add(const Duration(minutes: 5));
        final result = DateUtils.getRelativeTime(time);
        // Allow for execution time - could be 4 or 5 minutes
        expect(result, anyOf(equals('in 4 minutes'), equals('in 5 minutes')));
      });

      test('returns null for null input', () {
        expect(DateUtils.getRelativeTime(null), isNull);
      });
    });

    group('isSameDay', () {
      test('returns true for same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 18, 45);
        expect(DateUtils.isSameDay(date1, date2), isTrue);
      });

      test('returns false for different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        expect(DateUtils.isSameDay(date1, date2), isFalse);
      });

      test('returns false if either date is null', () {
        final date = DateTime(2024, 1, 15);
        expect(DateUtils.isSameDay(date, null), isFalse);
        expect(DateUtils.isSameDay(null, date), isFalse);
        expect(DateUtils.isSameDay(null, null), isFalse);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        final today = DateTime.now();
        expect(DateUtils.isToday(today), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateUtils.isToday(yesterday), isFalse);
      });

      test('returns false for null', () {
        expect(DateUtils.isToday(null), isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateUtils.isYesterday(yesterday), isTrue);
      });

      test('returns false for today', () {
        final today = DateTime.now();
        expect(DateUtils.isYesterday(today), isFalse);
      });

      test('returns false for null', () {
        expect(DateUtils.isYesterday(null), isFalse);
      });
    });

    group('isTomorrow', () {
      test('returns true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(DateUtils.isTomorrow(tomorrow), isTrue);
      });

      test('returns false for today', () {
        final today = DateTime.now();
        expect(DateUtils.isTomorrow(today), isFalse);
      });

      test('returns false for null', () {
        expect(DateUtils.isTomorrow(null), isFalse);
      });
    });

    group('startOfDay', () {
      test('returns start of day', () {
        final date = DateTime(2024, 1, 15, 14, 30, 45);
        final start = DateUtils.startOfDay(date);
        expect(start, isNotNull);
        expect(start!.year, equals(2024));
        expect(start.month, equals(1));
        expect(start.day, equals(15));
        expect(start.hour, equals(0));
        expect(start.minute, equals(0));
        expect(start.second, equals(0));
      });

      test('returns null for null input', () {
        expect(DateUtils.startOfDay(null), isNull);
      });
    });

    group('endOfDay', () {
      test('returns end of day', () {
        final date = DateTime(2024, 1, 15, 14, 30, 45);
        final end = DateUtils.endOfDay(date);
        expect(end, isNotNull);
        expect(end!.year, equals(2024));
        expect(end.month, equals(1));
        expect(end.day, equals(15));
        expect(end.hour, equals(23));
        expect(end.minute, equals(59));
        expect(end.second, equals(59));
        expect(end.millisecond, equals(999));
      });

      test('returns null for null input', () {
        expect(DateUtils.endOfDay(null), isNull);
      });
    });

    group('addDuration', () {
      test('adds duration correctly', () {
        final date = DateTime(2024, 1, 15, 10, 30);
        final result = DateUtils.addDuration(date, const Duration(hours: 2));
        expect(result, isNotNull);
        expect(result!.hour, equals(12));
        expect(result.minute, equals(30));
      });

      test('returns null for null input', () {
        expect(DateUtils.addDuration(null, const Duration(hours: 1)), isNull);
      });
    });

    group('subtractDuration', () {
      test('subtracts duration correctly', () {
        final date = DateTime(2024, 1, 15, 10, 30);
        final result = DateUtils.subtractDuration(
          date,
          const Duration(hours: 2),
        );
        expect(result, isNotNull);
        expect(result!.hour, equals(8));
        expect(result.minute, equals(30));
      });

      test('returns null for null input', () {
        expect(
          DateUtils.subtractDuration(null, const Duration(hours: 1)),
          isNull,
        );
      });
    });
  });
}
