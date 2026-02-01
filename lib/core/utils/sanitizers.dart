/// Input sanitization utilities
///
/// Provides functions to clean and sanitize user input to prevent
/// security vulnerabilities like XSS, SQL injection, and other attacks.
class Sanitizers {
  // Prevent instantiation
  Sanitizers._();

  // ============================================================
  // XSS Prevention
  // ============================================================

  /// Encode HTML special characters to prevent XSS
  static String encodeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('/', '&#x2F;');
  }

  /// Remove all HTML tags from input
  static String stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Sanitize HTML input (encode and strip tags)
  static String sanitizeHtml(String input) {
    return encodeHtml(stripHtmlTags(input));
  }

  /// Remove script tags and their content
  static String removeScriptTags(String input) {
    return input.replaceAll(RegExp(r'<script[^>]*>.*?<\/script>', caseSensitive: false, multiLine: true), '');
  }

  /// Remove potentially dangerous HTML attributes
  static String removeDangerousAttributes(String input) {
    final dangerousAttrs = ['onclick', 'onload', 'onerror', 'onmouseover', 'onfocus', 'onblur'];
    var sanitized = input;
    
    for (final attr in dangerousAttrs) {
      sanitized = sanitized.replaceAll(RegExp('$attr\\s*=\\s*["\'][^"\']*["\']', caseSensitive: false), '');
    }
    
    return sanitized;
  }

  // ============================================================
  // SQL Injection Prevention
  // ============================================================

  /// Escape single quotes for SQL (basic escaping)
  /// Note: Use prepared statements/parameterized queries instead
  static String escapeSql(String input) {
    return input.replaceAll("'", "''");
  }

  /// Remove SQL keywords that could be used for injection
  static String sanitizeSql(String input) {
    final sqlKeywords = [
      'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER',
      'EXEC', 'EXECUTE', 'UNION', 'WHERE', 'FROM', 'TABLE', 'DATABASE',
      '--', ';', '/*', '*/', 'xp_', 'sp_'
    ];
    
    var sanitized = input;
    for (final keyword in sqlKeywords) {
      sanitized = sanitized.replaceAll(RegExp(keyword, caseSensitive: false), '');
    }
    
    return sanitized.trim();
  }

  // ============================================================
  // Whitespace Handling
  // ============================================================

  /// Trim leading and trailing whitespace
  static String trim(String input) {
    return input.trim();
  }

  /// Remove extra whitespace (multiple spaces become single space)
  static String removeExtraWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Remove all whitespace
  static String removeAllWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s'), '');
  }

  /// Normalize line breaks to \n
  static String normalizeLineBreaks(String input) {
    return input.replaceAll(RegExp(r'\r\n|\r'), '\n');
  }

  // ============================================================
  // Special Character Handling
  // ============================================================

  /// Remove all special characters (keep only alphanumeric and spaces)
  static String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Allow only specific characters
  static String allowOnly(String input, String allowedChars) {
    final regex = RegExp('[^$allowedChars]');
    return input.replaceAll(regex, '');
  }

  /// Remove control characters
  static String removeControlCharacters(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  // ============================================================
  // URL Sanitization
  // ============================================================

  /// Sanitize URL to prevent javascript: and data: schemes
  static String sanitizeUrl(String url) {
    final trimmed = url.trim().toLowerCase();
    
    // Block dangerous schemes
    final dangerousSchemes = ['javascript:', 'data:', 'vbscript:', 'file:'];
    for (final scheme in dangerousSchemes) {
      if (trimmed.startsWith(scheme)) {
        return ''; // Return empty string for dangerous URLs
      }
    }
    
    // Ensure URL starts with http:// or https:// or is relative
    if (!trimmed.startsWith('http://') && 
        !trimmed.startsWith('https://') && 
        !trimmed.startsWith('/')) {
      return 'https://$url';
    }
    
    return url;
  }

  /// Encode URL components
  static String encodeUrlComponent(String component) {
    return Uri.encodeComponent(component);
  }

  // ============================================================
  // Email Sanitization
  // ============================================================

  /// Sanitize email address
  static String sanitizeEmail(String email) {
    // Trim and convert to lowercase
    var sanitized = email.trim().toLowerCase();
    
    // Remove any potentially dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9@._+-]'), '');
    
    return sanitized;
  }

  // ============================================================
  // File Path Sanitization
  // ============================================================

  /// Sanitize file name to prevent path traversal
  static String sanitizeFileName(String fileName) {
    // Remove path separators and dangerous characters
    var sanitized = fileName.replaceAll(RegExp(r'[/\\:*?"<>|]'), '');
    
    // Remove leading dots (hidden files)
    sanitized = sanitized.replaceAll(RegExp(r'^\.+'), '');
    
    // Remove path traversal attempts
    sanitized = sanitized.replaceAll('..', '');
    
    return sanitized.trim();
  }

  /// Sanitize file path
  static String sanitizeFilePath(String path) {
    // Remove path traversal attempts
    var sanitized = path.replaceAll('..', '');
    
    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');
    
    return sanitized.trim();
  }

  // ============================================================
  // JSON Sanitization
  // ============================================================

  /// Escape JSON special characters
  static String escapeJson(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  // ============================================================
  // Phone Number Sanitization
  // ============================================================

  /// Sanitize phone number (remove all non-digits)
  static String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }

  /// Format and sanitize phone number
  static String sanitizePhoneNumberFormatted(String phoneNumber) {
    final digits = sanitizePhoneNumber(phoneNumber);
    
    // Keep only valid length phone numbers
    if (digits.length < 10 || digits.length > 15) {
      return '';
    }
    
    return digits;
  }

  // ============================================================
  // Credit Card Sanitization
  // ============================================================

  /// Sanitize credit card number (remove all non-digits)
  static String sanitizeCreditCard(String cardNumber) {
    return cardNumber.replaceAll(RegExp(r'\D'), '');
  }

  // ============================================================
  // General Text Sanitization
  // ============================================================

  /// General purpose text sanitization
  static String sanitizeText(String input, {
    bool trimWhitespace = true,
    bool removeExtraSpaces = true,
    bool encodeHtmlChars = false,
    bool removeControlChars = true,
  }) {
    var sanitized = input;
    
    if (removeControlChars) {
      sanitized = removeControlCharacters(sanitized);
    }
    
    if (trimWhitespace) {
      sanitized = sanitized.trim();
    }
    
    if (removeExtraSpaces) {
      sanitized = removeExtraWhitespace(sanitized);
    }
    
    if (encodeHtmlChars) {
      sanitized = encodeHtml(sanitized);
    }
    
    return sanitized;
  }

  /// Sanitize user input for safe display
  static String sanitizeForDisplay(String input) {
    return sanitizeText(
      input,
      trimWhitespace: true,
      removeExtraSpaces: true,
      encodeHtmlChars: true,
      removeControlChars: true,
    );
  }

  /// Sanitize user input for database storage
  static String sanitizeForStorage(String input) {
    return sanitizeText(
      input,
      trimWhitespace: true,
      removeExtraSpaces: true,
      encodeHtmlChars: false,
      removeControlChars: true,
    );
  }

  // ============================================================
  // Length Limiting
  // ============================================================

  /// Truncate input to maximum length
  static String truncate(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength);
  }

  /// Sanitize and truncate
  static String sanitizeAndTruncate(String input, int maxLength) {
    return truncate(sanitizeForStorage(input), maxLength);
  }
}
