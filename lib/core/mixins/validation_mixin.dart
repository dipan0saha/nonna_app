/// Validation mixin for forms
///
/// **Functional Requirements**: Section 3.3.8 - Mixins
/// Reference: docs/Core_development_component_identification.md
///
/// Provides form validation utilities and error message generation:
/// - Form state management (getFieldError, hasFieldError, clearFieldError, hasErrors)
/// - Required field validation (validateRequired, validateRequiredBool)
/// - Email validation (validateEmail)
/// - Password validation (validatePassword, validatePasswordMatch)
/// - Length validation (validateMinLength, validateMaxLength)
/// - Numeric validation (validateNumeric, validateInteger, validatePositive)
/// - URL validation (validateUrl)
/// - Phone number validation (validatePhoneNumber)
/// - Date validation (validateNotFuture, validateNotPast)
/// - Composite validation (combineValidators, validateForm)
/// - Error message helpers (getFirstError, getAllErrors, formatErrors)
///
/// Dependencies: None
mixin ValidationMixin {
  // ============================================================
  // Form State Management
  // ============================================================

  /// Get validation error for a field
  String? getFieldError(Map<String, String?> errors, String fieldName) {
    return errors[fieldName];
  }

  /// Check if field has error
  bool hasFieldError(Map<String, String?> errors, String fieldName) {
    return errors[fieldName] != null;
  }

  /// Clear field error
  void clearFieldError(Map<String, String?> errors, String fieldName) {
    errors.remove(fieldName);
  }

  /// Clear all errors
  void clearAllErrors(Map<String, String?> errors) {
    errors.clear();
  }

  /// Check if form has any errors
  bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null);
  }

  // ============================================================
  // Required Field Validation
  // ============================================================

  /// Validate required field
  String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate required boolean field
  String? validateRequiredBool(bool? value, {String fieldName = 'This field'}) {
    if (value == null || !value) {
      return '$fieldName is required';
    }
    return null;
  }

  // ============================================================
  // Email Validation
  // ============================================================

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ============================================================
  // Password Validation
  // ============================================================

  /// Validate password strength
  String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validate password confirmation
  String? validatePasswordMatch(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // Length Validation
  // ============================================================

  /// Validate minimum length
  String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }

    return null;
  }

  // ============================================================
  // Numeric Validation
  // ============================================================

  /// Validate numeric input
  String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validate integer input
  String? validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }

    return null;
  }

  /// Validate positive number
  String? validatePositive(String? value) {
    // Return null for null or empty values (optional field)
    if (value == null || value.isEmpty) {
      return null;
    }

    final numError = validateNumeric(value);
    if (numError != null) return numError;

    final number = double.parse(value);
    if (number <= 0) {
      return 'Value must be positive';
    }

    return null;
  }

  // ============================================================
  // URL Validation
  // ============================================================

  /// Validate URL format
  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // ============================================================
  // Phone Number Validation
  // ============================================================

  /// Validate phone number
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // ============================================================
  // Date Validation
  // ============================================================

  /// Validate date is not in the future
  String? validateNotFuture(DateTime? value) {
    if (value == null) return null;

    if (value.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// Validate date is not in the past
  String? validateNotPast(DateTime? value) {
    if (value == null) return null;

    if (value.isBefore(DateTime.now())) {
      return 'Date cannot be in the past';
    }

    return null;
  }

  // ============================================================
  // Composite Validation
  // ============================================================

  /// Combine multiple validators
  String? combineValidators(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validate form fields
  bool validateForm(
    Map<String, String?> values,
    Map<String, String? Function(String?)> validators,
    Map<String, String?> errors,
  ) {
    errors.clear();
    bool isValid = true;

    validators.forEach((key, validator) {
      final error = validator(values[key]);
      if (error != null) {
        errors[key] = error;
        isValid = false;
      }
    });

    return isValid;
  }

  // ============================================================
  // Error Message Helpers
  // ============================================================

  /// Get first error message from errors map
  String? getFirstError(Map<String, String?> errors) {
    return errors.values.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );
  }

  /// Get all error messages
  List<String> getAllErrors(Map<String, String?> errors) {
    return errors.values
        .where((error) => error != null)
        .cast<String>()
        .toList();
  }

  /// Format error messages for display
  String formatErrors(Map<String, String?> errors, {String separator = '\n'}) {
    return getAllErrors(errors).join(separator);
  }
}
