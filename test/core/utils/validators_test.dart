import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });

      test('returns null for non-empty string', () {
        expect(Validators.required('test'), isNull);
      });

      test('uses custom message if provided', () {
        final result = Validators.required(null, message: 'Custom error');
        expect(result, 'Custom error');
      });
    });

    group('email', () {
      test('returns null for valid emails', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co.uk'), isNull);
        expect(Validators.email('user+tag@example.com'), isNull);
      });

      test('returns error for invalid emails', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@domain'), isNotNull);
        expect(Validators.email('@example.com'), isNotNull);
        expect(Validators.email('user@'), isNotNull);
      });

      test('returns null for empty input', () {
        expect(Validators.email(''), isNull);
        expect(Validators.email(null), isNull);
      });
    });

    group('password', () {
      test('returns error for password shorter than min length', () {
        expect(Validators.password('short', minLength: 8), isNotNull);
      });

      test('returns null for password meeting min length', () {
        expect(Validators.password('password123', minLength: 8), isNull);
      });

      test('respects custom min length', () {
        expect(Validators.password('pass', minLength: 4), isNull);
        expect(Validators.password('pas', minLength: 4), isNotNull);
      });
    });

    group('passwordStrong', () {
      test('returns error for weak passwords', () {
        expect(Validators.passwordStrong('password'), isNotNull);
        expect(Validators.passwordStrong('12345678'), isNotNull);
        expect(Validators.passwordStrong('PASSWORD'), isNotNull);
      });

      test('returns null for strong passwords', () {
        expect(Validators.passwordStrong('Password123!'), isNull);
        expect(Validators.passwordStrong('MyP@ssw0rd'), isNull);
      });
    });

    group('passwordConfirm', () {
      test('returns error when passwords do not match', () {
        expect(Validators.passwordConfirm('pass1', 'pass2'), isNotNull);
      });

      test('returns null when passwords match', () {
        expect(Validators.passwordConfirm('password', 'password'), isNull);
      });
    });

    group('minLength', () {
      test('returns error for string shorter than min', () {
        expect(Validators.minLength('hi', 3), isNotNull);
      });

      test('returns null for string meeting min length', () {
        expect(Validators.minLength('hello', 3), isNull);
      });

      test('returns null for empty input', () {
        expect(Validators.minLength('', 3), isNull);
        expect(Validators.minLength(null, 3), isNull);
      });
    });

    group('maxLength', () {
      test('returns error for string longer than max', () {
        expect(Validators.maxLength('hello world', 5), isNotNull);
      });

      test('returns null for string within max length', () {
        expect(Validators.maxLength('hi', 5), isNull);
      });
    });

    group('lengthRange', () {
      test('returns error for string outside range', () {
        expect(Validators.lengthRange('hi', 3, 10), isNotNull);
        expect(Validators.lengthRange('hello world', 3, 5), isNotNull);
      });

      test('returns null for string within range', () {
        expect(Validators.lengthRange('hello', 3, 10), isNull);
      });
    });

    group('url', () {
      test('returns null for valid URLs', () {
        expect(Validators.url('https://example.com'), isNull);
        expect(Validators.url('http://example.com'), isNull);
        expect(Validators.url('example.com'), isNull);
      });

      test('returns error for invalid URLs', () {
        expect(Validators.url('notaurl'), isNotNull);
        expect(Validators.url('ht!tp://example'), isNotNull);
      });
    });

    group('phoneNumber', () {
      test('returns null for valid phone numbers', () {
        expect(Validators.phoneNumber('1234567890'), isNull);
        expect(Validators.phoneNumber('+1 (555) 123-4567'), isNull);
        expect(Validators.phoneNumber('+44 20 1234 5678'), isNull);
      });

      test('returns error for invalid phone numbers', () {
        expect(Validators.phoneNumber('123'), isNotNull);
        expect(Validators.phoneNumber('abc'), isNotNull);
      });
    });

    group('numeric', () {
      test('returns null for valid numbers', () {
        expect(Validators.numeric('123'), isNull);
        expect(Validators.numeric('123.45'), isNull);
        expect(Validators.numeric('-10.5'), isNull);
      });

      test('returns error for non-numeric values', () {
        expect(Validators.numeric('abc'), isNotNull);
        expect(Validators.numeric('12.34.56'), isNotNull);
      });
    });

    group('integer', () {
      test('returns null for valid integers', () {
        expect(Validators.integer('123'), isNull);
        expect(Validators.integer('-10'), isNull);
      });

      test('returns error for non-integer values', () {
        expect(Validators.integer('123.45'), isNotNull);
        expect(Validators.integer('abc'), isNotNull);
      });
    });

    group('minValue', () {
      test('returns error for value less than min', () {
        expect(Validators.minValue('5', 10), isNotNull);
      });

      test('returns null for value meeting min', () {
        expect(Validators.minValue('10', 10), isNull);
        expect(Validators.minValue('15', 10), isNull);
      });
    });

    group('maxValue', () {
      test('returns error for value greater than max', () {
        expect(Validators.maxValue('15', 10), isNotNull);
      });

      test('returns null for value within max', () {
        expect(Validators.maxValue('10', 10), isNull);
        expect(Validators.maxValue('5', 10), isNull);
      });
    });

    group('valueRange', () {
      test('returns error for value outside range', () {
        expect(Validators.valueRange('5', 10, 20), isNotNull);
        expect(Validators.valueRange('25', 10, 20), isNotNull);
      });

      test('returns null for value within range', () {
        expect(Validators.valueRange('15', 10, 20), isNull);
        expect(Validators.valueRange('10', 10, 20), isNull);
        expect(Validators.valueRange('20', 10, 20), isNull);
      });
    });

    group('alphabetic', () {
      test('returns null for alphabetic strings', () {
        expect(Validators.alphabetic('abc'), isNull);
        expect(Validators.alphabetic('ABC'), isNull);
      });

      test('returns error for non-alphabetic strings', () {
        expect(Validators.alphabetic('abc123'), isNotNull);
        expect(Validators.alphabetic('abc def'), isNotNull);
      });
    });

    group('alphanumeric', () {
      test('returns null for alphanumeric strings', () {
        expect(Validators.alphanumeric('abc123'), isNull);
        expect(Validators.alphanumeric('ABC'), isNull);
      });

      test('returns error for strings with special characters', () {
        expect(Validators.alphanumeric('abc-123'), isNotNull);
        expect(Validators.alphanumeric('abc 123'), isNotNull);
      });
    });

    group('combine', () {
      test('runs all validators and returns first error', () {
        final validator = Validators.combine([
          (v) => Validators.required(v),
          (v) => Validators.minLength(v, 5),
        ]);

        expect(validator(''), isNotNull);
        expect(validator('hi'), isNotNull);
        expect(validator('hello'), isNull);
      });

      test('returns null if all validators pass', () {
        final validator = Validators.combine([
          (v) => Validators.required(v),
          (v) => Validators.email(v),
        ]);

        expect(validator('test@example.com'), isNull);
      });
    });
  });
}
