import '../../models/compliance/data_category.dart';
import '../../models/compliance/data_subject_right.dart';
import '../../models/compliance/consent_type.dart';
import '../../models/compliance/user_data_item.dart';

/// Exception thrown when a compliance operation fails
class ComplianceException implements Exception {
  final String message;
  final DataSubjectRight? right;

  const ComplianceException(this.message, [this.right]);

  @override
  String toString() => 'ComplianceException: $message';
}

/// Result of a compliance check
class ComplianceCheckResult {
  final bool isCompliant;
  final List<String> violations;
  final List<String> warnings;
  final Map<String, dynamic> details;

  const ComplianceCheckResult({
    required this.isCompliant,
    this.violations = const [],
    this.warnings = const [],
    this.details = const {},
  });

  /// Returns true if there are any violations
  bool get hasViolations => violations.isNotEmpty;

  /// Returns true if there are any warnings
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Service for GDPR/CCPA compliance checks and operations
class GdprCcpaComplianceService {
  /// Validates email for compliance (privacy and data protection)
  /// Ensures email is valid and doesn't contain sensitive information
  ComplianceCheckResult validateEmail(String email) {
    final violations = <String>[];
    final warnings = <String>[];

    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      violations.add('Invalid email format');
    }

    // Check email length (reasonable limit)
    if (email.length > 254) {
      violations.add('Email exceeds maximum length (254 characters)');
    }

    // Check for suspicious patterns that might indicate data leakage
    if (email.contains('password') ||
        email.contains('secret') ||
        email.contains('token')) {
      warnings.add('Email contains potentially sensitive keywords');
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {'email_length': email.length},
    );
  }

  /// Validates photo/media for compliance
  /// Ensures photo metadata doesn't leak sensitive information
  ComplianceCheckResult validatePhoto({
    required String filename,
    required int sizeInBytes,
    String? contentType,
    Map<String, dynamic>? metadata,
  }) {
    final violations = <String>[];
    final warnings = <String>[];

    // Check file size (10MB limit as per requirements)
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    if (sizeInBytes > maxSizeBytes) {
      violations.add('Photo size exceeds maximum limit of 10MB');
    }

    // Validate content type
    if (contentType != null) {
      final allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
      if (!allowedTypes.contains(contentType.toLowerCase())) {
        violations.add('Photo must be JPEG or PNG format');
      }
    }

    // Check for sensitive metadata (EXIF data can contain GPS coordinates)
    if (metadata != null) {
      final sensitiveKeys = ['gps', 'location', 'coordinates', 'latitude', 'longitude'];
      for (final key in metadata.keys) {
        if (sensitiveKeys.any((sensitive) => key.toLowerCase().contains(sensitive))) {
          warnings.add('Photo metadata contains potentially sensitive location information');
        }
      }
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {
        'size_mb': (sizeInBytes / (1024 * 1024)).toStringAsFixed(2),
        'content_type': contentType,
      },
    );
  }

  /// Validates user profile data for compliance
  ComplianceCheckResult validateProfile({
    required String? name,
    String? email,
    String? bio,
    Map<String, dynamic>? additionalData,
  }) {
    final violations = <String>[];
    final warnings = <String>[];

    // Validate name
    if (name != null && name.isNotEmpty) {
      if (name.length > 100) {
        violations.add('Name exceeds maximum length (100 characters)');
      }
      // Check for potentially problematic characters
      if (name.contains(RegExp(r'[<>{}]'))) {
        warnings.add('Name contains special characters that may cause issues');
      }
    }

    // Validate bio
    if (bio != null && bio.isNotEmpty) {
      if (bio.length > 500) {
        violations.add('Bio exceeds maximum length (500 characters)');
      }
      // Check for PII in bio
      if (bio.contains(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'))) {
        warnings.add('Bio may contain SSN or similar sensitive identifier');
      }
    }

    // Validate email if provided
    if (email != null && email.isNotEmpty) {
      final emailValidation = validateEmail(email);
      violations.addAll(emailValidation.violations);
      warnings.addAll(emailValidation.warnings);
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {
        'has_name': name != null && name.isNotEmpty,
        'has_email': email != null && email.isNotEmpty,
        'has_bio': bio != null && bio.isNotEmpty,
      },
    );
  }

  /// Validates privacy policy compliance
  /// Ensures all required elements are present in the privacy policy
  ComplianceCheckResult validatePrivacyPolicy({
    required bool hasDataCollectionDisclosure,
    required bool hasDataUsageDisclosure,
    required bool hasDataSharingDisclosure,
    required bool hasUserRightsSection,
    required bool hasRetentionPolicySection,
    required bool hasContactInformation,
    required bool hasGdprCompliance,
    required bool hasCcpaCompliance,
  }) {
    final violations = <String>[];
    final warnings = <String>[];

    // GDPR/CCPA required disclosures
    if (!hasDataCollectionDisclosure) {
      violations.add('Privacy policy must disclose what data is collected');
    }

    if (!hasDataUsageDisclosure) {
      violations.add('Privacy policy must disclose how data is used');
    }

    if (!hasDataSharingDisclosure) {
      violations.add('Privacy policy must disclose if/how data is shared with third parties');
    }

    if (!hasUserRightsSection) {
      violations.add('Privacy policy must include user rights section (GDPR/CCPA)');
    }

    if (!hasRetentionPolicySection) {
      violations.add('Privacy policy must include data retention policy');
    }

    if (!hasContactInformation) {
      violations.add('Privacy policy must include contact information for privacy inquiries');
    }

    // Specific compliance checks
    if (!hasGdprCompliance) {
      warnings.add('Privacy policy should include GDPR-specific compliance information');
    }

    if (!hasCcpaCompliance) {
      warnings.add('Privacy policy should include CCPA-specific compliance information');
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {
        'gdpr_compliant': hasGdprCompliance,
        'ccpa_compliant': hasCcpaCompliance,
      },
    );
  }

  /// Checks if a user data request can be fulfilled
  ComplianceCheckResult validateDataSubjectRequest({
    required DataSubjectRight right,
    required String userId,
    DateTime? requestDate,
  }) {
    final violations = <String>[];
    final warnings = <String>[];
    final now = requestDate ?? DateTime.now();

    // Validate user ID
    if (userId.isEmpty) {
      violations.add('User ID is required for data subject requests');
    }

    // Check if the right is supported
    final supportedRights = [
      DataSubjectRight.access,
      DataSubjectRight.rectification,
      DataSubjectRight.erasure,
      DataSubjectRight.portability,
      DataSubjectRight.withdrawConsent,
    ];

    if (!supportedRights.contains(right)) {
      warnings.add('${right.description} may require manual processing');
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {
        'right': right.name,
        'request_date': now.toIso8601String(),
        'supported': supportedRights.contains(right),
      },
    );
  }

  /// Validates consent records for compliance
  ComplianceCheckResult validateConsentRecords(List<ConsentRecord> consents) {
    final violations = <String>[];
    final warnings = <String>[];

    // Check if required consent is present
    final hasRequiredConsent = consents.any(
      (c) => c.type == ConsentType.dataProcessing && c.granted,
    );

    if (!hasRequiredConsent) {
      violations.add('Missing required consent for data processing');
    }

    // Check for outdated consents (older than 2 years)
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    final outdatedConsents = consents.where(
      (c) => c.granted && c.timestamp.isBefore(twoYearsAgo),
    ).toList();

    if (outdatedConsents.isNotEmpty) {
      warnings.add('${outdatedConsents.length} consent(s) are older than 2 years and should be refreshed');
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: {
        'total_consents': consents.length,
        'granted_consents': consents.where((c) => c.granted).length,
        'outdated_consents': outdatedConsents.length,
      },
    );
  }

  /// Validates data retention compliance
  /// Ensures data is retained or deleted according to the 7-year policy
  ComplianceCheckResult validateDataRetention(List<UserDataItem> dataItems) {
    final violations = <String>[];
    final warnings = <String>[];
    final now = DateTime.now();

    // Check for data that should be permanently deleted
    final itemsToDelete = dataItems.where((item) => item.canPermanentlyDelete(now)).toList();

    if (itemsToDelete.isNotEmpty) {
      warnings.add('${itemsToDelete.length} item(s) can be permanently deleted (retention period expired)');
    }

    // Check for active data in deleted accounts (soft delete pattern)
    final deletedButActive = dataItems.where(
      (item) => item.isDeleted && item.isWithinRetentionPeriod(now),
    ).toList();

    // This is actually expected behavior - soft deleted data within retention period
    // Just track it for reporting
    final details = {
      'total_items': dataItems.length,
      'active_items': dataItems.where((item) => !item.isDeleted).length,
      'soft_deleted_items': deletedButActive.length,
      'items_to_permanently_delete': itemsToDelete.length,
    };

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      details: details,
    );
  }

  /// Generates a user data export for portability (GDPR Art. 20, CCPA)
  UserDataExport generateUserDataExport({
    required String userId,
    required List<UserDataItem> dataItems,
    Map<String, dynamic>? additionalMetadata,
  }) {
    final metadata = <String, dynamic>{
      'export_format': 'JSON',
      'gdpr_article': 'Article 20 - Right to data portability',
      'ccpa_section': 'CCPA 1798.100 - Right to Know',
      ...?additionalMetadata,
    };

    return UserDataExport(
      userId: userId,
      exportedAt: DateTime.now(),
      dataItems: dataItems.where((item) => !item.isDeleted).toList(),
      metadata: metadata,
    );
  }

  /// Performs a comprehensive compliance check
  ComplianceCheckResult performComprehensiveCheck({
    required String userId,
    String? email,
    List<ConsentRecord>? consents,
    List<UserDataItem>? userDataItems,
  }) {
    final allViolations = <String>[];
    final allWarnings = <String>[];
    final allDetails = <String, dynamic>{};

    // Validate email if provided
    if (email != null) {
      final emailCheck = validateEmail(email);
      allViolations.addAll(emailCheck.violations);
      allWarnings.addAll(emailCheck.warnings);
      allDetails['email_check'] = emailCheck.details;
    }

    // Validate consents if provided
    if (consents != null && consents.isNotEmpty) {
      final consentCheck = validateConsentRecords(consents);
      allViolations.addAll(consentCheck.violations);
      allWarnings.addAll(consentCheck.warnings);
      allDetails['consent_check'] = consentCheck.details;
    }

    // Validate data retention if data items provided
    if (userDataItems != null && userDataItems.isNotEmpty) {
      final retentionCheck = validateDataRetention(userDataItems);
      allViolations.addAll(retentionCheck.violations);
      allWarnings.addAll(retentionCheck.warnings);
      allDetails['retention_check'] = retentionCheck.details;
    }

    return ComplianceCheckResult(
      isCompliant: allViolations.isEmpty,
      violations: allViolations,
      warnings: allWarnings,
      details: allDetails,
    );
  }
}
