/// Input validation utilities
///
/// **Functional Requirements**: Section 3.3.3 - Validators
/// Reference: docs/Core_development_component_identification.md
///
/// Provides validation rules for:
/// - Email validation
/// - Password strength
/// - Required field checks
/// - Length validators
/// - URL validation
/// - Date range validation
///
/// No external dependencies
class Validators {
  // Prevent instantiation
  Validators._();

  // ============================================================
  // Required Field Validation
  // ============================================================

  /// Validate that a field is not empty
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  // ============================================================
  // Email Validation
  // ============================================================

  /// Validate email address format
  static String? email(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate email with additional checks
  static String? emailStrict(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    // Basic format check
    final basicCheck = email(value, message: message);
    if (basicCheck != null) return basicCheck;

    // Additional checks
    final parts = value.split('@');
    final domain = parts[1];

    // Check for common typos in popular domains
    final similarDomains = {
      'gmial.com': 'gmail.com',
      'gmai.com': 'gmail.com',
      'yahooo.com': 'yahoo.com',
      'hotmial.com': 'hotmail.com',
    };

    if (similarDomains.containsKey(domain)) {
      return 'Did you mean ${similarDomains[domain]}?';
    }

    return null;
  }

  // ============================================================
  // Password Validation
  // ============================================================

  /// Validate password strength (minimum 8 characters)
  static String? password(String? value, {int minLength = 8, String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return message ?? 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate strong password
  static String? passwordStrong(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
      return message ??
          'Password must contain uppercase, lowercase, number, and special character';
    }

    return null;
  }

  /// Validate password confirmation matches
  static String? passwordConfirm(String? value, String? originalPassword,
      {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value != originalPassword) {
      return message ?? 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // Length Validation
  // ============================================================

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return message ?? 'Must be at least $min characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return message ?? 'Must be at most $max characters';
    }

    return null;
  }

  /// Validate length range
  static String? lengthRange(String? value, int min, int max,
      {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min || value.length > max) {
      return message ?? 'Must be between $min and $max characters';
    }

    return null;
  }

  // ============================================================
  // URL Validation
  // ============================================================

  /// Validate URL format
  static String? url(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid URL';
    }

    return null;
  }

  // ============================================================
  // Phone Number Validation
  // ============================================================

  /// Validate phone number format (basic)
  static String? phoneNumber(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');

    if (!phoneRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate US phone number
  static String? phoneNumberUS(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid 10-digit US number
    if (digits.length != 10 || !digits.startsWith(RegExp(r'[2-9]'))) {
      return message ?? 'Please enter a valid 10-digit US phone number';
    }

    return null;
  }

  // ============================================================
  // Numeric Validation
  // ============================================================

  /// Validate numeric input
  static String? numeric(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return message ?? 'Please enter a valid number';
    }

    return null;
  }

  /// Validate integer input
  static String? integer(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    if (int.tryParse(value) == null) {
      return message ?? 'Please enter a valid integer';
    }

    return null;
  }

  /// Validate minimum value
  static String? minValue(String? value, num min, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < min) {
      return message ?? 'Must be at least $min';
    }

    return null;
  }

  /// Validate maximum value
  static String? maxValue(String? value, num max, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number > max) {
      return message ?? 'Must be at most $max';
    }

    return null;
  }

  /// Validate value range
  static String? valueRange(String? value, num min, num max,
      {String? message}) {
    if (value == null || value.isEmpty) return null;

    final number = num.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < min || number > max) {
      return message ?? 'Must be between $min and $max';
    }

    return null;
  }

  // ============================================================
  // Date Validation
  // ============================================================

  /// Validate date format
  static String? date(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return message ?? 'Please enter a valid date';
    }
  }

  /// Validate date is in the past
  static String? datePast(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return message ?? 'Date must be in the past';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validate date is in the future
  static String? dateFuture(String? value, {String? message}) {
    if (value == null || value.isEmpty) return null;

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return message ?? 'Date must be in the future';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validate date range
  static String? dateRange(String? value, DateTime start, DateTime end,
      {String? message}) {
    if (value == null || value.isEmpty) return null;

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(start) || date.isAfter(end)) {
        return message ??
            'Date must be between ${start.toString().split(' ')[0]} and ${end.toString().split(' ')[0]}';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // ============================================================
  // Pattern Matching
  // ============================================================

  /// Validate against a custom regex pattern
  static String? pattern(String? value, String pattern, {String? message}) {
    if (value == null || value.isEmpty) return null;

    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message ?? 'Invalid format';
    }

    return null;
  }

  /// Validate alphabetic only
  static String? alphabetic(String? value, {String? message}) {
    return pattern(value, r'^[a-zA-Z]+$',
        message: message ?? 'Only letters are allowed');
  }

  /// Validate alphanumeric only
  static String? alphanumeric(String? value, {String? message}) {
    return pattern(value, r'^[a-zA-Z0-9]+$',
        message: message ?? 'Only letters and numbers are allowed');
  }

  // ============================================================
  // Composite Validators
  // ============================================================

  /// Combine multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
