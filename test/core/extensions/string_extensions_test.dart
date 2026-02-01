import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('capitalize', () {
      test('capitalizes first letter', () {
        expect('hello'.capitalize, 'Hello');
        expect('world'.capitalize, 'World');
      });

      test('handles empty string', () {
        expect(''.capitalize, '');
      });
    });

    group('capitalizeWords', () {
      test('capitalizes each word', () {
        expect('hello world'.capitalizeWords, 'Hello World');
        expect('the quick brown fox'.capitalizeWords, 'The Quick Brown Fox');
      });
    });

    group('truncate', () {
      test('truncates long strings', () {
        expect('hello world'.truncate(8), 'hello...');
      });

      test('does not truncate short strings', () {
        expect('hello'.truncate(10), 'hello');
      });
    });

    group('isEmail', () {
      test('validates correct emails', () {
        expect('test@example.com'.isEmail, true);
        expect('user.name@domain.co.uk'.isEmail, true);
      });

      test('rejects invalid emails', () {
        expect('notanemail'.isEmail, false);
        expect('missing@domain'.isEmail, false);
      });
    });

    group('isUrl', () {
      test('validates correct URLs', () {
        expect('https://example.com'.isUrl, true);
        expect('http://example.com'.isUrl, true);
      });

      test('rejects invalid URLs', () {
        expect('notaurl'.isUrl, false);
      });
    });

    group('isPhoneNumber', () {
      test('validates phone numbers', () {
        expect('1234567890'.isPhoneNumber, true);
        expect('+1-555-123-4567'.isPhoneNumber, true);
      });

      test('rejects invalid phone numbers', () {
        expect('123'.isPhoneNumber, false);
        expect('abc'.isPhoneNumber, false);
      });
    });

    group('isNumeric', () {
      test('validates numeric strings', () {
        expect('123'.isNumeric, true);
        expect('456'.isNumeric, true);
      });

      test('rejects non-numeric strings', () {
        expect('123.45'.isNumeric, false);
        expect('abc'.isNumeric, false);
      });
    });

    group('isAlphabetic', () {
      test('validates alphabetic strings', () {
        expect('abc'.isAlphabetic, true);
        expect('ABC'.isAlphabetic, true);
      });

      test('rejects non-alphabetic strings', () {
        expect('abc123'.isAlphabetic, false);
        expect('abc-def'.isAlphabetic, false);
      });
    });

    group('removeWhitespace', () {
      test('removes all whitespace', () {
        expect('hello world'.removeWhitespace, 'helloworld');
        expect('a b c'.removeWhitespace, 'abc');
      });
    });

    group('removeExtraWhitespace', () {
      test('removes extra whitespace', () {
        expect('hello    world'.removeExtraWhitespace, 'hello world');
        expect('  a  b  c  '.removeExtraWhitespace, 'a b c');
      });
    });

    group('toIntOrNull', () {
      test('parses valid integers', () {
        expect('123'.toIntOrNull(), 123);
        expect('-10'.toIntOrNull(), -10);
      });

      test('returns null for invalid integers', () {
        expect('abc'.toIntOrNull(), isNull);
        expect('12.34'.toIntOrNull(), isNull);
      });
    });

    group('toDoubleOrNull', () {
      test('parses valid doubles', () {
        expect('123.45'.toDoubleOrNull(), 123.45);
        expect('-10.5'.toDoubleOrNull(), -10.5);
      });

      test('returns null for invalid doubles', () {
        expect('abc'.toDoubleOrNull(), isNull);
      });
    });

    group('toBoolOrNull', () {
      test('parses boolean values', () {
        expect('true'.toBoolOrNull(), true);
        expect('false'.toBoolOrNull(), false);
        expect('1'.toBoolOrNull(), true);
        expect('0'.toBoolOrNull(), false);
      });

      test('is case insensitive', () {
        expect('TRUE'.toBoolOrNull(), true);
        expect('False'.toBoolOrNull(), false);
      });

      test('returns null for invalid values', () {
        expect('maybe'.toBoolOrNull(), isNull);
      });
    });

    group('reverse', () {
      test('reverses string', () {
        expect('hello'.reverse, 'olleh');
        expect('123'.reverse, '321');
      });
    });

    group('countOccurrences', () {
      test('counts substring occurrences', () {
        expect('hello world'.countOccurrences('l'), 3);
        expect('aaa'.countOccurrences('a'), 3);
      });

      test('returns 0 for non-existent substring', () {
        expect('hello'.countOccurrences('x'), 0);
      });
    });

    group('containsAny', () {
      test('checks if contains any substring', () {
        expect('hello world'.containsAny(['hello', 'goodbye']), true);
        expect('hello world'.containsAny(['foo', 'bar']), false);
      });
    });

    group('containsAll', () {
      test('checks if contains all substrings', () {
        expect('hello world'.containsAll(['hello', 'world']), true);
        expect('hello world'.containsAll(['hello', 'foo']), false);
      });
    });

    group('toSnakeCase', () {
      test('converts to snake_case', () {
        expect('helloWorld'.toSnakeCase, 'hello_world');
        expect('HelloWorld'.toSnakeCase, 'hello_world');
      });
    });

    group('toKebabCase', () {
      test('converts to kebab-case', () {
        expect('helloWorld'.toKebabCase, 'hello-world');
        expect('HelloWorld'.toKebabCase, 'hello-world');
      });
    });

    group('mask', () {
      test('masks string except last characters', () {
        expect('1234567890'.mask(visibleChars: 4), '******7890');
      });
    });

    group('pluralize', () {
      test('pluralizes word based on count', () {
        expect('item'.pluralize(1), 'item');
        expect('item'.pluralize(2), 'items');
      });

      test('uses custom plural', () {
        expect('child'.pluralize(2, plural: 'children'), 'children');
      });
    });
  });

  group('NullableStringExtensions', () {
    test('isNullOrEmpty checks null and empty', () {
      expect(null.isNullOrEmpty, true);
      expect(''.isNullOrEmpty, true);
      expect('test'.isNullOrEmpty, false);
    });

    test('isNullOrWhitespace checks null, empty, and whitespace', () {
      expect(null.isNullOrWhitespace, true);
      expect(''.isNullOrWhitespace, true);
      expect('   '.isNullOrWhitespace, true);
      expect('test'.isNullOrWhitespace, false);
    });

    test('orDefault returns default for null or empty', () {
      expect(null.orDefault('default'), 'default');
      expect(''.orDefault('default'), 'default');
      expect('test'.orDefault('default'), 'test');
    });
  });
}
