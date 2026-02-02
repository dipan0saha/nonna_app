import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatPhoneNumber', () {
      test('formats 10-digit US phone numbers', () {
        expect(Formatters.formatPhoneNumber('5551234567'), '(555) 123-4567');
        expect(Formatters.formatPhoneNumber('(555)1234567'), '(555) 123-4567');
      });

      test('formats 11-digit numbers with country code', () {
        expect(
            Formatters.formatPhoneNumber('15551234567'), '+1 (555) 123-4567');
      });
    });

    group('formatEmail', () {
      test('trims and lowercases email', () {
        expect(Formatters.formatEmail('Test@Example.Com'), 'test@example.com');
        expect(
            Formatters.formatEmail('  user@domain.com  '), 'user@domain.com');
      });
    });

    group('maskEmail', () {
      test('masks email username', () {
        expect(Formatters.maskEmail('john@example.com'), 'j***@example.com');
        expect(Formatters.maskEmail('alice@domain.com'), 'a****@domain.com');
      });

      test('handles short usernames', () {
        expect(Formatters.maskEmail('jo@example.com'), 'jo***@example.com');
      });
    });

    group('ensureUrlProtocol', () {
      test('adds https:// to URLs without protocol', () {
        expect(
            Formatters.ensureUrlProtocol('example.com'), 'https://example.com');
      });

      test('keeps existing protocol', () {
        expect(Formatters.ensureUrlProtocol('http://example.com'),
            'http://example.com');
        expect(Formatters.ensureUrlProtocol('https://example.com'),
            'https://example.com');
      });
    });

    group('formatUrlForDisplay', () {
      test('removes protocol and www', () {
        expect(Formatters.formatUrlForDisplay('https://www.example.com'),
            'example.com');
        expect(Formatters.formatUrlForDisplay('http://example.com'),
            'example.com');
      });
    });

    group('capitalizeName', () {
      test('capitalizes each word', () {
        expect(Formatters.capitalizeName('john doe'), 'John Doe');
        expect(Formatters.capitalizeName('JANE SMITH'), 'Jane Smith');
      });
    });

    group('getInitials', () {
      test('gets initials from name', () {
        expect(Formatters.getInitials('John Doe'), 'JD');
        expect(Formatters.getInitials('Alice Bob Charlie'), 'AB');
      });

      test('limits initials to maxInitials', () {
        expect(
            Formatters.getInitials('Alice Bob Charlie', maxInitials: 3), 'ABC');
      });
    });

    group('truncate', () {
      test('truncates long text', () {
        expect(Formatters.truncate('hello world', 8), 'hello...');
      });

      test('does not truncate short text', () {
        expect(Formatters.truncate('hello', 10), 'hello');
      });

      test('uses custom ellipsis', () {
        expect(
            Formatters.truncate('hello world', 8, ellipsis: '>>'), 'hello >>');
      });
    });

    group('formatNumber', () {
      test('formats numbers with thousand separators', () {
        expect(Formatters.formatNumber(1000), '1,000');
        expect(Formatters.formatNumber(1234567), '1,234,567');
      });

      test('handles decimal places', () {
        expect(
            Formatters.formatNumber(1234.5678, decimalPlaces: 2), '1,234.57');
      });
    });

    group('formatCurrency', () {
      test('formats currency with symbol', () {
        expect(Formatters.formatCurrency(1234.56), '\$1,234.56');
      });

      test('uses custom symbol', () {
        expect(Formatters.formatCurrency(1234.56, symbol: '€'), '€1,234.56');
      });
    });

    group('formatPercentage', () {
      test('formats percentage', () {
        expect(Formatters.formatPercentage(25.5), '25.5%');
        expect(Formatters.formatPercentage(100), '100.0%');
      });
    });

    group('formatFileSize', () {
      test('formats bytes', () {
        expect(Formatters.formatFileSize(500), '500 B');
      });

      test('formats kilobytes', () {
        expect(Formatters.formatFileSize(1024), '1.0 KB');
        expect(Formatters.formatFileSize(2048), '2.0 KB');
      });

      test('formats megabytes', () {
        expect(Formatters.formatFileSize(1024 * 1024), '1.0 MB');
        expect(Formatters.formatFileSize(5 * 1024 * 1024), '5.0 MB');
      });
    });

    group('formatCompactNumber', () {
      test('formats small numbers as-is', () {
        expect(Formatters.formatCompactNumber(999), '999');
      });

      test('formats thousands with K', () {
        expect(Formatters.formatCompactNumber(1500), '1.5K');
        expect(Formatters.formatCompactNumber(10000), '10.0K');
      });

      test('formats millions with M', () {
        expect(Formatters.formatCompactNumber(1500000), '1.5M');
      });

      test('formats billions with B', () {
        expect(Formatters.formatCompactNumber(1500000000), '1.5B');
      });
    });

    group('pluralize', () {
      test('returns singular for count of 1', () {
        expect(Formatters.pluralize('item', 1), 'item');
      });

      test('returns plural for other counts', () {
        expect(Formatters.pluralize('item', 2), 'items');
        expect(Formatters.pluralize('item', 0), 'items');
      });

      test('uses custom plural', () {
        expect(
            Formatters.pluralize('child', 2, plural: 'children'), 'children');
      });
    });

    group('formatCount', () {
      test('formats count with word', () {
        expect(Formatters.formatCount(1, 'item'), '1 item');
        expect(Formatters.formatCount(5, 'item'), '5 items');
      });
    });

    group('maskCreditCard', () {
      test('masks credit card number', () {
        expect(Formatters.maskCreditCard('1234567890123456'),
            '**** **** **** 3456');
      });
    });

    group('formatList', () {
      test('formats single item', () {
        expect(Formatters.formatList(['apple']), 'apple');
      });

      test('formats two items', () {
        expect(Formatters.formatList(['apple', 'banana']), 'apple and banana');
      });

      test('formats multiple items', () {
        expect(Formatters.formatList(['apple', 'banana', 'cherry']),
            'apple, banana, and cherry');
      });
    });
  });
}
