# GDPR/CCPA Compliance Module

This module provides comprehensive GDPR (General Data Protection Regulation) and CCPA (California Consumer Privacy Act) compliance utilities for the Nonna app.

## Overview

The compliance module helps ensure that user data handling meets GDPR and CCPA requirements, including:

- **Data subject rights** (access, rectification, erasure, portability)
- **User data validation** (email, photos, profiles)
- **Privacy policy compliance checks**
- **Consent management**
- **Data retention policy enforcement** (7-year requirement)

## Components

### Models

#### `DataSubjectRight`
Enum representing GDPR/CCPA data subject rights:
- `access` - Right to access personal data (GDPR Art. 15, CCPA)
- `rectification` - Right to correct incorrect data (GDPR Art. 16, CCPA)
- `erasure` - Right to be forgotten (GDPR Art. 17, CCPA)
- `portability` - Right to data portability (GDPR Art. 20, CCPA)
- `restrictProcessing` - Right to restrict processing (GDPR Art. 18)
- `objectToProcessing` - Right to object (GDPR Art. 21)
- `optOutOfSale` - Right to opt-out of sale (CCPA)
- `withdrawConsent` - Right to withdraw consent (GDPR)

#### `DataCategory`
Enum classifying types of personal data:
- `identity` - Basic identity information (name, email)
- `contact` - Contact information
- `biometric` - Photos, videos, images
- `userContent` - Comments, posts, captions
- `behavioral` - App usage data
- `technical` - Device info, IP address
- `location` - Location data
- `sensitive` - Special categories requiring extra protection

#### `ConsentType`
Enum representing types of user consent:
- `dataProcessing` - Required for core app functionality
- `marketing` - Marketing communications
- `pushNotifications` - Push notifications
- `analytics` - Analytics and monitoring
- `thirdPartySharing` - Sharing with third parties
- `mediaStorage` - Photo and media storage

#### `ConsentRecord`
Class representing a user's consent:
```dart
ConsentRecord(
  type: ConsentType.pushNotifications,
  granted: true,
  timestamp: DateTime.now(),
  purpose: 'Receive baby milestone notifications',
);
```

#### `UserDataItem`
Class representing tracked user data:
```dart
UserDataItem(
  dataType: 'email',
  category: DataCategory.identity,
  value: 'user@example.com',
  collectedAt: DateTime.now(),
  legalBasis: 'Consent',
  isDeleted: false,
);
```

#### `UserDataExport`
Class for GDPR/CCPA data portability exports:
```dart
UserDataExport(
  userId: 'user123',
  exportedAt: DateTime.now(),
  dataItems: userDataItems,
  metadata: {'format': 'JSON'},
);
```

### Services

#### `GdprCcpaComplianceService`

Main service providing compliance validation and operations.

##### Email Validation
```dart
final service = GdprCcpaComplianceService();
final result = service.validateEmail('user@example.com');

if (!result.isCompliant) {
  print('Violations: ${result.violations}');
}
if (result.hasWarnings) {
  print('Warnings: ${result.warnings}');
}
```

##### Photo Validation
```dart
final result = service.validatePhoto(
  filename: 'baby_photo.jpg',
  sizeInBytes: 5 * 1024 * 1024, // 5MB
  contentType: 'image/jpeg',
  metadata: exifData,
);
```

Validates:
- File size (max 10MB per requirements)
- File format (JPEG/PNG only)
- Metadata for sensitive location data

##### Profile Validation
```dart
final result = service.validateProfile(
  name: 'John Doe',
  email: 'john@example.com',
  bio: 'Proud parent',
);
```

##### Privacy Policy Validation
```dart
final result = service.validatePrivacyPolicy(
  hasDataCollectionDisclosure: true,
  hasDataUsageDisclosure: true,
  hasDataSharingDisclosure: true,
  hasUserRightsSection: true,
  hasRetentionPolicySection: true,
  hasContactInformation: true,
  hasGdprCompliance: true,
  hasCcpaCompliance: true,
);
```

##### Data Subject Request Validation
```dart
final result = service.validateDataSubjectRequest(
  right: DataSubjectRight.access,
  userId: 'user123',
);
```

##### Consent Validation
```dart
final consents = [
  ConsentRecord(
    type: ConsentType.dataProcessing,
    granted: true,
    timestamp: DateTime.now(),
  ),
  // ... more consents
];

final result = service.validateConsentRecords(consents);
```

Checks:
- Required consents are present
- Consents are not outdated (> 2 years)

##### Data Retention Validation
```dart
final result = service.validateDataRetention(userDataItems);
```

Enforces 7-year retention policy per requirements:
- Identifies data within retention period
- Flags data eligible for permanent deletion

##### User Data Export Generation
```dart
final export = service.generateUserDataExport(
  userId: 'user123',
  dataItems: userDataItems,
  additionalMetadata: {'request_id': '12345'},
);

// Convert to JSON for download
final json = export.toJson();
```

##### Comprehensive Compliance Check
```dart
final result = service.performComprehensiveCheck(
  userId: 'user123',
  email: 'user@example.com',
  consents: userConsents,
  userDataItems: userData,
);

if (result.isCompliant) {
  print('User data is compliant!');
} else {
  print('Violations found: ${result.violations}');
  print('Warnings: ${result.warnings}');
}
```

## Compliance Features

### GDPR Compliance

1. **Data Subject Rights**: Support for all GDPR rights (Articles 15-21)
2. **Lawful Basis**: Track legal basis for data processing
3. **Data Portability**: JSON export functionality (Article 20)
4. **Right to Erasure**: Soft delete with 7-year retention
5. **Consent Management**: Granular consent tracking and withdrawal

### CCPA Compliance

1. **Right to Know**: Data export functionality
2. **Right to Delete**: Deletion with retention policy
3. **Right to Opt-Out**: Opt-out of data sale tracking
4. **Privacy Policy**: Required disclosure validation

### Data Retention

Per requirements: "User data must be retained for 7 years post-account deletion"

Implementation:
- **Soft delete pattern**: Data marked as deleted but retained
- **Retention period**: 2,557 days (7 years)
- **Automatic cleanup**: Flags data past retention period

### Security Measures

1. **Email validation**: Prevents data leakage in email addresses
2. **Photo metadata**: Warns about GPS/location data in EXIF
3. **PII detection**: Warns about sensitive info in profiles
4. **Size limits**: Enforces 10MB photo limit

## Testing

Comprehensive test coverage includes:
- Model serialization/deserialization
- Validation logic for all data types
- Retention period calculations
- Consent management
- Data export generation

Run tests:
```bash
# Run all compliance tests
dart test test/services/compliance/
dart test test/models/compliance/

# Run specific test file
dart test test/services/compliance/gdpr_ccpa_compliance_service_test.dart
```

## Integration Example

```dart
import 'package:nonna_app/services/compliance/gdpr_ccpa_compliance_service.dart';
import 'package:nonna_app/models/compliance/consent_type.dart';
import 'package:nonna_app/models/compliance/data_subject_right.dart';

class UserService {
  final complianceService = GdprCcpaComplianceService();

  Future<void> handleUserSignup(String email, String name) async {
    // Validate email
    final emailCheck = complianceService.validateEmail(email);
    if (!emailCheck.isCompliant) {
      throw Exception('Invalid email: ${emailCheck.violations.join(', ')}');
    }

    // Validate profile
    final profileCheck = complianceService.validateProfile(name: name, email: email);
    if (!profileCheck.isCompliant) {
      throw Exception('Invalid profile: ${profileCheck.violations.join(', ')}');
    }

    // Create required consent record
    final consent = ConsentRecord(
      type: ConsentType.dataProcessing,
      granted: true,
      timestamp: DateTime.now(),
      purpose: 'Account creation and app functionality',
    );

    // Store user with consent...
  }

  Future<UserDataExport> handleDataAccessRequest(String userId) async {
    // Fetch user data items from database
    final userDataItems = await fetchUserDataItems(userId);

    // Generate export
    return complianceService.generateUserDataExport(
      userId: userId,
      dataItems: userDataItems,
    );
  }

  Future<void> handlePhotoUpload(String filename, int size, String contentType) async {
    final photoCheck = complianceService.validatePhoto(
      filename: filename,
      sizeInBytes: size,
      contentType: contentType,
    );

    if (!photoCheck.isCompliant) {
      throw Exception('Invalid photo: ${photoCheck.violations.join(', ')}');
    }

    if (photoCheck.hasWarnings) {
      // Log warnings for review
      print('Photo warnings: ${photoCheck.warnings.join(', ')}');
    }

    // Proceed with upload...
  }
}
```

## Requirements Alignment

This implementation aligns with the following requirements:

1. **Data Retention** (Section 6): 7-year retention enforced via `DataCategory.retentionPeriodDays`
2. **Security** (Section 4.2): Validation of user data to prevent leaks
3. **Privacy**: GDPR/CCPA rights implementation
4. **Photo Gallery** (Section 3.5): 10MB limit, JPEG/PNG validation
5. **Email Verification** (Section 3.1): Email format validation

## Future Enhancements

Potential improvements for future versions:
- Database integration for audit logging
- Automated consent refresh notifications
- Privacy impact assessment tools
- Cookie consent management
- Third-party data processor tracking
- Breach notification workflows

## References

- [GDPR Official Text](https://gdpr-info.eu/)
- [CCPA Official Text](https://oag.ca.gov/privacy/ccpa)
- [Supabase GDPR Compliance](https://supabase.com/docs/guides/platform/compliance)
