/// Extension methods for String
///
/// **Functional Requirements**: Section 3.3.2 - Formatters
/// Reference: docs/Core_development_component_identification.md
///
/// Provides convenient extension methods for string manipulation and validation
/// including:
/// - Capitalization helpers (capitalize, capitalizeWords, toTitleCase, toSentenceCase)
/// - Truncation methods (truncate, truncateWords)
/// - Validation helpers (isEmail, isUrl, isPhoneNumber, isNumeric, isAlphabetic)
/// - Cleaning & trimming (removeWhitespace, removeExtraWhitespace)
/// - Null safety helpers (isNullOrEmpty, isNullOrWhitespace, orElse)
/// - Parsing utilities (toIntOrNull, toDoubleOrNull, toBoolOrNull)
/// - Case conversions (toSnakeCase, toKebabCase, toCamelCase, toPascalCase)
/// - Formatting methods (mask, formatPhoneNumber, pluralize)
///
/// Dependencies: None
extension StringExtensions on String {
  // ============================================================
  // Capitalization
  // ============================================================

  /// Capitalize the first letter of the string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize the first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to title case
  String get toTitleCase => capitalizeWords;

  /// Convert to sentence case (only first letter capitalized)
  String get toSentenceCase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // ============================================================
  // Truncation
  // ============================================================

  /// Truncate string to a maximum length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Truncate string to the nearest word boundary
  String truncateWords(int maxWords, {String ellipsis = '...'}) {
    final words = split(' ');
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$ellipsis';
  }

  // ============================================================
  // Validation
  // ============================================================

  /// Check if string is a valid email address
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number (basic check)
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Check if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Check if string contains only alphabetic characters
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string contains only alphanumeric characters
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  // ============================================================
  // Cleaning & Trimming
  // ============================================================

  /// Remove all whitespace from the string
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Remove extra whitespace (multiple spaces become single space)
  String get removeExtraWhitespace => replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Remove all non-alphanumeric characters
  String get removeNonAlphanumeric => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// Remove HTML tags
  String get removeHtmlTags => replaceAll(RegExp(r'<[^>]*>'), '');

  // ============================================================
  // Null Safety Helpers
  // ============================================================

  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is null, empty, or contains only whitespace
  bool get isNullOrWhitespace => trim().isEmpty;

  /// Return this string or a default value if empty
  String orElse(String defaultValue) {
    return isEmpty ? defaultValue : this;
  }

  // ============================================================
  // Parsing
  // ============================================================

  /// Parse string to int, return null if invalid
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Parse string to double, return null if invalid
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Parse string to bool (case-insensitive)
  bool? toBoolOrNull() {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
    return null;
  }

  // ============================================================
  // String Manipulation
  // ============================================================

  /// Reverse the string
  String get reverse => split('').reversed.join('');

  /// Count occurrences of a substring
  int countOccurrences(String substring) {
    if (substring.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }
    return count;
  }

  /// Check if string contains any of the given substrings
  bool containsAny(List<String> substrings) {
    return substrings.any((substring) => contains(substring));
  }

  /// Check if string contains all of the given substrings
  bool containsAll(List<String> substrings) {
    return substrings.every((substring) => contains(substring));
  }

  /// Wrap string in quotes
  String get quote => '"$this"';

  /// Wrap string in single quotes
  String get singleQuote => "'$this'";

  /// Add prefix if not already present
  String ensurePrefix(String prefix) {
    return startsWith(prefix) ? this : '$prefix$this';
  }

  /// Add suffix if not already present
  String ensureSuffix(String suffix) {
    return endsWith(suffix) ? this : '$this$suffix';
  }

  // ============================================================
  // Case Conversions
  // ============================================================

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to kebab-case
  String get toKebabCase {
    return replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '-${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^-'), '');
  }

  /// Convert to camelCase
  String get toCamelCase {
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize).join('');
  }

  /// Convert to PascalCase
  String get toPascalCase {
    final words = split(RegExp(r'[\s_-]+'));
    return words.map((word) => word.capitalize).join('');
  }

  // ============================================================
  // Formatting
  // ============================================================

  /// Mask sensitive information (e.g., credit cards, passwords)
  String mask({int visibleChars = 4, String maskChar = '*'}) {
    if (length <= visibleChars) return this;
    final visible = substring(length - visibleChars);
    final masked = maskChar * (length - visibleChars);
    return '$masked$visible';
  }

  /// Format as a phone number (assumes 10-digit US number)
  String get formatPhoneNumber {
    final digits = removeNonAlphanumeric;
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return this;
  }

  /// Pluralize a word based on count
  String pluralize(int count, {String? plural}) {
    if (count == 1) return this;
    return plural ?? '${this}s';
  }

  // ============================================================
  // Encoding/Decoding
  // ============================================================

  /// Encode special HTML characters
  String get encodeHtml {
    return replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Remove leading/trailing quotes
  String get unquote {
    String result = this;
    if (result.startsWith('"') && result.endsWith('"')) {
      result = result.substring(1, result.length - 1);
    } else if (result.startsWith("'") && result.endsWith("'")) {
      result = result.substring(1, result.length - 1);
    }
    return result;
  }
}

/// Extension methods for nullable String
extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is null, empty, or contains only whitespace
  bool get isNullOrWhitespace => this == null || this!.trim().isEmpty;

  /// Return string or default value if null or empty
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}
