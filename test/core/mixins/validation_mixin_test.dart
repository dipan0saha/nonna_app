import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/mixins/validation_mixin.dart';

// Test class that uses ValidationMixin
class TestValidator with ValidationMixin {}

void main() {
  late TestValidator validator;

  setUp(() {
    validator = TestValidator();
  });

  group('ValidationMixin', () {
    group('Form State Management', () {
      test('getFieldError returns error for field', () {
        final errors = {'email': 'Invalid email', 'password': null};

        expect(validator.getFieldError(errors, 'email'), 'Invalid email');
        expect(validator.getFieldError(errors, 'password'), null);
        expect(validator.getFieldError(errors, 'name'), null);
      });

      test('hasFieldError checks if field has error', () {
        final errors = {'email': 'Invalid email', 'password': null};

        expect(validator.hasFieldError(errors, 'email'), true);
        expect(validator.hasFieldError(errors, 'password'), false);
        expect(validator.hasFieldError(errors, 'name'), false);
      });

      test('clearFieldError removes error from field', () {
        final errors = <String, String?>{'email': 'Invalid email', 'name': 'Required'};

        validator.clearFieldError(errors, 'email');

        expect(errors.containsKey('email'), false);
        expect(errors['name'], 'Required');
      });

      test('clearAllErrors removes all errors', () {
        final errors = <String, String?>{
          'email': 'Invalid email',
          'password': 'Too short',
          'name': 'Required',
        };

        validator.clearAllErrors(errors);

        expect(errors.isEmpty, true);
      });

      test('hasErrors checks if any field has error', () {
        final emptyErrors = <String, String?>{};
        final errorsWithNull = <String, String?>{'email': null, 'name': null};
        final errorsWithValues = <String, String?>{'email': 'Invalid', 'name': null};

        expect(validator.hasErrors(emptyErrors), false);
        expect(validator.hasErrors(errorsWithNull), false);
        expect(validator.hasErrors(errorsWithValues), true);
      });
    });

    group('Required Field Validation', () {
      test('validateRequired returns error for null', () {
        expect(
          validator.validateRequired(null),
          'This field is required',
        );
      });

      test('validateRequired returns error for empty string', () {
        expect(
          validator.validateRequired(''),
          'This field is required',
        );
      });

      test('validateRequired returns error for whitespace only', () {
        expect(
          validator.validateRequired('   '),
          'This field is required',
        );
      });

      test('validateRequired returns null for valid value', () {
        expect(validator.validateRequired('test'), null);
        expect(validator.validateRequired('  test  '), null);
      });

      test('validateRequired uses custom field name', () {
        expect(
          validator.validateRequired(null, fieldName: 'Email'),
          'Email is required',
        );
      });

      test('validateRequiredBool returns error for null', () {
        expect(
          validator.validateRequiredBool(null),
          'This field is required',
        );
      });

      test('validateRequiredBool returns error for false', () {
        expect(
          validator.validateRequiredBool(false),
          'This field is required',
        );
      });

      test('validateRequiredBool returns null for true', () {
        expect(validator.validateRequiredBool(true), null);
      });
    });

    group('Email Validation', () {
      test('validateEmail returns null for null or empty', () {
        expect(validator.validateEmail(null), null);
        expect(validator.validateEmail(''), null);
      });

      test('validateEmail returns error for invalid email', () {
        expect(
          validator.validateEmail('invalid'),
          'Please enter a valid email address',
        );
        expect(
          validator.validateEmail('test@'),
          'Please enter a valid email address',
        );
        expect(
          validator.validateEmail('@example.com'),
          'Please enter a valid email address',
        );
        expect(
          validator.validateEmail('test@example'),
          'Please enter a valid email address',
        );
      });

      test('validateEmail returns null for valid email', () {
        expect(validator.validateEmail('test@example.com'), null);
        expect(validator.validateEmail('user.name@example.co.uk'), null);
        expect(validator.validateEmail('test+tag@example.com'), null);
      });
    });

    group('Password Validation', () {
      test('validatePassword returns null for null or empty', () {
        expect(validator.validatePassword(null), null);
        expect(validator.validatePassword(''), null);
      });

      test('validatePassword returns error for short password', () {
        expect(
          validator.validatePassword('short'),
          'Password must be at least 8 characters',
        );
        expect(
          validator.validatePassword('1234567'),
          'Password must be at least 8 characters',
        );
      });

      test('validatePassword returns null for valid password', () {
        expect(validator.validatePassword('12345678'), null);
        expect(validator.validatePassword('securepassword'), null);
      });

      test('validatePassword respects custom minLength', () {
        expect(
          validator.validatePassword('abc', minLength: 5),
          'Password must be at least 5 characters',
        );
        expect(validator.validatePassword('abcde', minLength: 5), null);
      });

      test('validatePasswordMatch returns null for null or empty', () {
        expect(validator.validatePasswordMatch(null, 'password'), null);
        expect(validator.validatePasswordMatch('', 'password'), null);
      });

      test('validatePasswordMatch returns error for non-matching passwords',
          () {
        expect(
          validator.validatePasswordMatch('password1', 'password2'),
          'Passwords do not match',
        );
      });

      test('validatePasswordMatch returns null for matching passwords', () {
        expect(validator.validatePasswordMatch('password', 'password'), null);
      });
    });

    group('Length Validation', () {
      test('validateMinLength returns null for null or empty', () {
        expect(validator.validateMinLength(null, 5), null);
        expect(validator.validateMinLength('', 5), null);
      });

      test('validateMinLength returns error for short string', () {
        expect(
          validator.validateMinLength('abc', 5),
          'This field must be at least 5 characters',
        );
      });

      test('validateMinLength returns null for valid length', () {
        expect(validator.validateMinLength('abcde', 5), null);
        expect(validator.validateMinLength('abcdef', 5), null);
      });

      test('validateMinLength uses custom field name', () {
        expect(
          validator.validateMinLength('abc', 5, fieldName: 'Username'),
          'Username must be at least 5 characters',
        );
      });

      test('validateMaxLength returns null for null or empty', () {
        expect(validator.validateMaxLength(null, 10), null);
        expect(validator.validateMaxLength('', 10), null);
      });

      test('validateMaxLength returns error for long string', () {
        expect(
          validator.validateMaxLength('this is too long', 10),
          'This field must be at most 10 characters',
        );
      });

      test('validateMaxLength returns null for valid length', () {
        expect(validator.validateMaxLength('short', 10), null);
        expect(validator.validateMaxLength('exactly10!', 10), null);
      });

      test('validateMaxLength uses custom field name', () {
        expect(
          validator.validateMaxLength('too long text', 5, fieldName: 'Bio'),
          'Bio must be at most 5 characters',
        );
      });
    });

    group('Numeric Validation', () {
      test('validateNumeric returns null for null or empty', () {
        expect(validator.validateNumeric(null), null);
        expect(validator.validateNumeric(''), null);
      });

      test('validateNumeric returns error for non-numeric', () {
        expect(
          validator.validateNumeric('abc'),
          'Please enter a valid number',
        );
        expect(
          validator.validateNumeric('12.34.56'),
          'Please enter a valid number',
        );
      });

      test('validateNumeric returns null for valid numbers', () {
        expect(validator.validateNumeric('123'), null);
        expect(validator.validateNumeric('12.34'), null);
        expect(validator.validateNumeric('-5.67'), null);
        expect(validator.validateNumeric('0'), null);
      });

      test('validateInteger returns null for null or empty', () {
        expect(validator.validateInteger(null), null);
        expect(validator.validateInteger(''), null);
      });

      test('validateInteger returns error for non-integer', () {
        expect(
          validator.validateInteger('12.34'),
          'Please enter a valid integer',
        );
        expect(
          validator.validateInteger('abc'),
          'Please enter a valid integer',
        );
      });

      test('validateInteger returns null for valid integers', () {
        expect(validator.validateInteger('123'), null);
        expect(validator.validateInteger('-456'), null);
        expect(validator.validateInteger('0'), null);
      });

      test('validatePositive returns null for null or empty', () {
        expect(validator.validatePositive(null), null);
        expect(validator.validatePositive(''), null);
      });

      test('validatePositive returns error for non-numeric', () {
        expect(
          validator.validatePositive('abc'),
          'Please enter a valid number',
        );
      });

      test('validatePositive returns error for zero or negative', () {
        expect(validator.validatePositive('0'), 'Value must be positive');
        expect(validator.validatePositive('-5'), 'Value must be positive');
        expect(validator.validatePositive('-0.1'), 'Value must be positive');
      });

      test('validatePositive returns null for positive numbers', () {
        expect(validator.validatePositive('1'), null);
        expect(validator.validatePositive('0.1'), null);
        expect(validator.validatePositive('999.99'), null);
      });
    });

    group('URL Validation', () {
      test('validateUrl returns null for null or empty', () {
        expect(validator.validateUrl(null), null);
        expect(validator.validateUrl(''), null);
      });

      test('validateUrl returns error for invalid URL', () {
        expect(
          validator.validateUrl('not a url'),
          'Please enter a valid URL',
        );
        expect(
          validator.validateUrl('http://'),
          'Please enter a valid URL',
        );
      });

      test('validateUrl returns null for valid URLs', () {
        expect(validator.validateUrl('https://example.com'), null);
        expect(validator.validateUrl('http://www.example.com'), null);
        expect(validator.validateUrl('example.com'), null);
        expect(validator.validateUrl('https://example.com/path'), null);
        expect(validator.validateUrl('www.example.co.uk'), null);
      });
    });

    group('Phone Number Validation', () {
      test('validatePhoneNumber returns null for null or empty', () {
        expect(validator.validatePhoneNumber(null), null);
        expect(validator.validatePhoneNumber(''), null);
      });

      test('validatePhoneNumber returns error for invalid phone', () {
        expect(
          validator.validatePhoneNumber('123'),
          'Please enter a valid phone number',
        );
        expect(
          validator.validatePhoneNumber('abc-defg-hijk'),
          'Please enter a valid phone number',
        );
      });

      test('validatePhoneNumber returns null for valid phones', () {
        expect(validator.validatePhoneNumber('1234567890'), null);
        expect(validator.validatePhoneNumber('+1 234 567 8900'), null);
        expect(validator.validatePhoneNumber('(123) 456-7890'), null);
        expect(validator.validatePhoneNumber('+44 20 1234 5678'), null);
      });
    });

    group('Date Validation', () {
      test('validateNotFuture returns null for null', () {
        expect(validator.validateNotFuture(null), null);
      });

      test('validateNotFuture returns error for future date', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(
          validator.validateNotFuture(futureDate),
          'Date cannot be in the future',
        );
      });

      test('validateNotFuture returns null for past or current date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(validator.validateNotFuture(pastDate), null);
      });

      test('validateNotPast returns null for null', () {
        expect(validator.validateNotPast(null), null);
      });

      test('validateNotPast returns error for past date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(
          validator.validateNotPast(pastDate),
          'Date cannot be in the past',
        );
      });

      test('validateNotPast returns null for future or current date', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(validator.validateNotPast(futureDate), null);
      });
    });

    group('Composite Validation', () {
      test('combineValidators returns first error', () {
        final validators = [
          (String? value) => validator.validateRequired(value),
          (String? value) => validator.validateEmail(value),
        ];

        expect(
          validator.combineValidators(null, validators),
          'This field is required',
        );
        expect(
          validator.combineValidators('invalid', validators),
          'Please enter a valid email address',
        );
      });

      test('combineValidators returns null if all pass', () {
        final validators = [
          (String? value) => validator.validateRequired(value),
          (String? value) => validator.validateEmail(value),
        ];

        expect(
          validator.combineValidators('test@example.com', validators),
          null,
        );
      });

      test('validateForm validates all fields', () {
        final values = <String, String?>{
          'email': 'invalid',
          'password': '123',
          'name': 'John',
        };

        final validators = <String, String? Function(String?)>{
          'email': (value) => validator.validateEmail(value),
          'password': (value) => validator.validateMinLength(value, 8),
          'name': (value) => validator.validateRequired(value),
        };

        final errors = <String, String?>{};

        final isValid = validator.validateForm(values, validators, errors);

        expect(isValid, false);
        expect(errors['email'], isNotNull);
        expect(errors['password'], isNotNull);
        expect(errors['name'], null);
      });

      test('validateForm returns true when all fields are valid', () {
        final values = <String, String?>{
          'email': 'test@example.com',
          'password': '12345678',
          'name': 'John',
        };

        final validators = <String, String? Function(String?)>{
          'email': (value) => validator.validateEmail(value),
          'password': (value) => validator.validateMinLength(value, 8),
          'name': (value) => validator.validateRequired(value),
        };

        final errors = <String, String?>{};

        final isValid = validator.validateForm(values, validators, errors);

        expect(isValid, true);
        expect(errors.isEmpty, true);
      });

      test('validateForm clears previous errors', () {
        final values = <String, String?>{
          'email': 'test@example.com',
        };

        final validators = <String, String? Function(String?)>{
          'email': (value) => validator.validateEmail(value),
        };

        final errors = <String, String?>{'email': 'Old error', 'name': 'Another error'};

        validator.validateForm(values, validators, errors);

        expect(errors['name'], null);
        expect(errors.containsKey('name'), false);
      });
    });

    group('Error Message Helpers', () {
      test('getFirstError returns first non-null error', () {
        final errors = <String, String?>{
          'name': null,
          'email': 'Invalid email',
          'password': 'Too short',
        };

        // The first non-null error (order may vary based on map iteration)
        final firstError = validator.getFirstError(errors);
        expect(firstError, isNotNull);
        expect(['Invalid email', 'Too short'], contains(firstError));
      });

      test('getFirstError returns null for empty or all-null errors', () {
        expect(validator.getFirstError(<String, String?>{}), null);
        expect(
          validator.getFirstError(<String, String?>{'email': null}),
          null,
        );
      });

      test('getAllErrors returns list of non-null errors', () {
        final errors = <String, String?>{
          'name': null,
          'email': 'Invalid email',
          'password': 'Too short',
        };

        final allErrors = validator.getAllErrors(errors);
        expect(allErrors.length, 2);
        expect(allErrors, contains('Invalid email'));
        expect(allErrors, contains('Too short'));
      });

      test('getAllErrors returns empty list for no errors', () {
        expect(validator.getAllErrors(<String, String?>{}), isEmpty);
        expect(
          validator.getAllErrors(<String, String?>{'email': null}),
          isEmpty,
        );
      });

      test('formatErrors joins errors with separator', () {
        final errors = <String, String?>{
          'email': 'Invalid email',
          'password': 'Too short',
        };

        final formatted = validator.formatErrors(errors, separator: '; ');
        expect(formatted, contains('Invalid email'));
        expect(formatted, contains('Too short'));
        expect(formatted, contains(';'));
      });

      test('formatErrors uses newline as default separator', () {
        final errors = <String, String?>{
          'email': 'Invalid email',
          'password': 'Too short',
        };

        final formatted = validator.formatErrors(errors);
        expect(formatted, contains('\n'));
      });
    });
  });
}
