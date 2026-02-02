/// Text formatting utilities
///
/// **Functional Requirements**: Section 3.3.2 - Formatters
/// Reference: docs/Core_development_component_identification.md
///
/// Provides formatters for:
/// - Phone number formatting
/// - Email validation
/// - URL formatting
/// - Name capitalization
/// - Text truncation
/// - Pluralization helpers
///
/// No external dependencies
class Formatters {
  // Prevent instantiation
  Formatters._();

  // ============================================================
  // Phone Number Formatting
  // ============================================================

  /// Format phone number as (XXX) XXX-XXXX
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    } else {
      return phoneNumber; // Return original if format is unknown
    }
  }

  /// Format phone number for international display
  static String formatInternationalPhone(
      String phoneNumber, String countryCode) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '+$countryCode $digits';
  }

  // ============================================================
  // Email Formatting
  // ============================================================

  /// Validate and format email address
  static String formatEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Mask email for privacy (e.g., j***@example.com)
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '$username***@$domain';
    }

    final visibleChars = username[0];
    final maskedChars = '*' * (username.length - 1);
    return '$visibleChars$maskedChars@$domain';
  }

  // ============================================================
  // URL Formatting
  // ============================================================

  /// Ensure URL has protocol (http/https)
  static String ensureUrlProtocol(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  /// Format URL for display (remove protocol)
  static String formatUrlForDisplay(String url) {
    return url
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .replaceFirst('www.', '');
  }

  /// Get domain from URL
  static String? getDomain(String url) {
    try {
      final uri = Uri.parse(ensureUrlProtocol(url));
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Name Formatting
  // ============================================================

  /// Capitalize first letter of each word
  static String capitalizeName(String name) {
    if (name.isEmpty) return name;

    return name
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Format full name from first and last name
  static String formatFullName({
    required String firstName,
    String? middleName,
    required String lastName,
  }) {
    final parts = [
      firstName,
      if (middleName != null && middleName.isNotEmpty) middleName,
      lastName,
    ];
    return parts.join(' ');
  }

  /// Get initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    final words = name.trim().split(' ').where((word) => word.isNotEmpty);
    final initials =
        words.take(maxInitials).map((word) => word[0].toUpperCase());
    return initials.join();
  }

  // ============================================================
  // Text Truncation
  // ============================================================

  /// Truncate text to maximum length with ellipsis
  static String truncate(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Truncate at word boundary
  static String truncateWords(String text, int maxWords,
      {String ellipsis = '...'}) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}$ellipsis';
  }

  /// Smart truncate - tries to break at sentence or word
  static String smartTruncate(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;

    // Try to find a sentence break
    final truncated = text.substring(0, maxLength - ellipsis.length);
    final sentenceBreak = truncated.lastIndexOf('. ');
    if (sentenceBreak > maxLength / 2) {
      return '${truncated.substring(0, sentenceBreak + 1)}$ellipsis';
    }

    // Fall back to word break
    final wordBreak = truncated.lastIndexOf(' ');
    if (wordBreak > 0) {
      return '${truncated.substring(0, wordBreak)}$ellipsis';
    }

    return '$truncated$ellipsis';
  }

  // ============================================================
  // Number Formatting
  // ============================================================

  /// Format number with thousand separators
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    final formatted = number.toStringAsFixed(decimalPlaces);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return decimalPart.isEmpty ? buffer.toString() : '$buffer.$decimalPart';
  }

  /// Format currency
  static String formatCurrency(num amount,
      {String symbol = '\$', int decimalPlaces = 2}) {
    return '$symbol${formatNumber(amount, decimalPlaces: decimalPlaces)}';
  }

  /// Format percentage
  static String formatPercentage(num value, {int decimalPlaces = 1}) {
    return '${formatNumber(value, decimalPlaces: decimalPlaces)}%';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  /// Format large numbers (e.g., 1.5K, 2.3M)
  static String formatCompactNumber(num number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
  }

  // ============================================================
  // Pluralization Helpers
  // ============================================================

  /// Pluralize a word based on count
  static String pluralize(String word, int count, {String? plural}) {
    if (count == 1) return word;
    return plural ?? '${word}s';
  }

  /// Format count with pluralized word (e.g., "1 item", "2 items")
  static String formatCount(int count, String singular, {String? plural}) {
    return '$count ${pluralize(singular, count, plural: plural)}';
  }

  // ============================================================
  // Credit Card Formatting
  // ============================================================

  /// Format credit card number with spaces
  static String formatCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  /// Mask credit card number (show only last 4 digits)
  static String maskCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return cardNumber;

    final last4 = digits.substring(digits.length - 4);
    return '**** **** **** $last4';
  }

  // ============================================================
  // Time Duration Formatting
  // ============================================================

  /// Format duration as "Xh Ym"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Format duration in long form
  static String formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add(formatCount(hours, 'hour'));
    if (minutes > 0) parts.add(formatCount(minutes, 'minute'));
    if (seconds > 0 && hours == 0) parts.add(formatCount(seconds, 'second'));

    return parts.join(', ');
  }

  // ============================================================
  // List Formatting
  // ============================================================

  /// Format list as comma-separated string with "and" before last item
  static String formatList(List<String> items, {String separator = 'and'}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length == 2) return '${items[0]} $separator ${items[1]}';

    final allButLast = items.sublist(0, items.length - 1).join(', ');
    return '$allButLast, $separator ${items.last}';
  }
}
