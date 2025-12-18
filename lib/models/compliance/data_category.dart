/// Represents categories of personal data under GDPR/CCPA
enum DataCategory {
  /// Basic identity information (name, email)
  identity,

  /// Contact information
  contact,

  /// Biometric data (photos, videos)
  biometric,

  /// User-generated content (comments, posts)
  userContent,

  /// Usage and behavioral data
  behavioral,

  /// Device and technical data
  technical,

  /// Location data
  location,

  /// Special categories of data (GDPR Art. 9) / Sensitive personal information (CCPA)
  sensitive,
}

extension DataCategoryExtension on DataCategory {
  /// Returns a human-readable description of the data category
  String get description {
    switch (this) {
      case DataCategory.identity:
        return 'Identity information (name, email, user ID)';
      case DataCategory.contact:
        return 'Contact information (email, phone)';
      case DataCategory.biometric:
        return 'Biometric data (photos, videos, images)';
      case DataCategory.userContent:
        return 'User-generated content (comments, posts, captions)';
      case DataCategory.behavioral:
        return 'Behavioral data (app usage, interactions)';
      case DataCategory.technical:
        return 'Technical data (IP address, device info)';
      case DataCategory.location:
        return 'Location data';
      case DataCategory.sensitive:
        return 'Sensitive personal information';
    }
  }

  /// Returns true if this is a sensitive data category requiring special handling
  bool get requiresSpecialProtection {
    return this == DataCategory.sensitive || this == DataCategory.biometric;
  }

  /// Returns the minimum retention period in days for this category
  /// Based on the requirement: "User data must be retained for 7 years post-account deletion"
  int get retentionPeriodDays {
    // 7 years = 365.25 * 7 ≈ 2557 days
    return 2557;
  }
}
