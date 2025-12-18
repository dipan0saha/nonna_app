import 'package:test/test.dart';
import 'package:nonna_app/services/compliance/gdpr_ccpa_compliance_service.dart';
import 'package:nonna_app/models/compliance/data_subject_right.dart';
import 'package:nonna_app/models/compliance/data_category.dart';
import 'package:nonna_app/models/compliance/consent_type.dart';
import 'package:nonna_app/models/compliance/user_data_item.dart';

void main() {
  late GdprCcpaComplianceService service;

  setUp(() {
    service = GdprCcpaComplianceService();
  });

  group('Email Validation', () {
    test('validates correct email format', () {
      final result = service.validateEmail('user@example.com');
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('rejects invalid email format', () {
      final result = service.validateEmail('invalid-email');
      expect(result.isCompliant, false);
      expect(result.violations, isNotEmpty);
      expect(result.violations.first, contains('Invalid email format'));
    });

    test('rejects email exceeding maximum length', () {
      final longEmail = '${'a' * 250}@example.com';
      final result = service.validateEmail(longEmail);
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('exceeds maximum length')), true);
    });

    test('warns about emails with sensitive keywords', () {
      final result = service.validateEmail('mypassword@example.com');
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('potentially sensitive keywords'));
    });
  });

  group('Photo Validation', () {
    test('validates photo within size limit', () {
      final result = service.validatePhoto(
        filename: 'photo.jpg',
        sizeInBytes: 5 * 1024 * 1024, // 5MB
        contentType: 'image/jpeg',
      );
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('rejects photo exceeding 10MB limit', () {
      final result = service.validatePhoto(
        filename: 'large.jpg',
        sizeInBytes: 15 * 1024 * 1024, // 15MB
        contentType: 'image/jpeg',
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('exceeds maximum limit')), true);
    });

    test('rejects invalid photo format', () {
      final result = service.validatePhoto(
        filename: 'photo.gif',
        sizeInBytes: 1024,
        contentType: 'image/gif',
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('JPEG or PNG format')), true);
    });

    test('accepts JPEG format', () {
      final result = service.validatePhoto(
        filename: 'photo.jpeg',
        sizeInBytes: 1024,
        contentType: 'image/jpeg',
      );
      expect(result.isCompliant, true);
    });

    test('accepts PNG format', () {
      final result = service.validatePhoto(
        filename: 'photo.png',
        sizeInBytes: 1024,
        contentType: 'image/png',
      );
      expect(result.isCompliant, true);
    });

    test('warns about GPS metadata in photos', () {
      final result = service.validatePhoto(
        filename: 'photo.jpg',
        sizeInBytes: 1024,
        contentType: 'image/jpeg',
        metadata: {'gps_latitude': '37.7749', 'gps_longitude': '-122.4194'},
      );
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('location information'));
    });
  });

  group('Profile Validation', () {
    test('validates correct profile data', () {
      final result = service.validateProfile(
        name: 'John Doe',
        email: 'john@example.com',
        bio: 'A loving parent',
      );
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('rejects name exceeding maximum length', () {
      final result = service.validateProfile(
        name: 'A' * 101,
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('Name exceeds')), true);
    });

    test('rejects bio exceeding maximum length', () {
      final result = service.validateProfile(
        name: 'John',
        bio: 'A' * 501,
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('Bio exceeds')), true);
    });

    test('warns about special characters in name', () {
      final result = service.validateProfile(
        name: 'John<script>',
      );
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('special characters'));
    });

    test('warns about potential PII in bio', () {
      final result = service.validateProfile(
        name: 'John',
        bio: 'My SSN is 123-45-6789',
      );
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('sensitive identifier'));
    });
  });

  group('Privacy Policy Validation', () {
    test('validates complete privacy policy', () {
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
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('rejects privacy policy missing data collection disclosure', () {
      final result = service.validatePrivacyPolicy(
        hasDataCollectionDisclosure: false,
        hasDataUsageDisclosure: true,
        hasDataSharingDisclosure: true,
        hasUserRightsSection: true,
        hasRetentionPolicySection: true,
        hasContactInformation: true,
        hasGdprCompliance: true,
        hasCcpaCompliance: true,
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('data is collected')), true);
    });

    test('rejects privacy policy missing user rights section', () {
      final result = service.validatePrivacyPolicy(
        hasDataCollectionDisclosure: true,
        hasDataUsageDisclosure: true,
        hasDataSharingDisclosure: true,
        hasUserRightsSection: false,
        hasRetentionPolicySection: true,
        hasContactInformation: true,
        hasGdprCompliance: true,
        hasCcpaCompliance: true,
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('user rights')), true);
    });

    test('warns about missing GDPR compliance information', () {
      final result = service.validatePrivacyPolicy(
        hasDataCollectionDisclosure: true,
        hasDataUsageDisclosure: true,
        hasDataSharingDisclosure: true,
        hasUserRightsSection: true,
        hasRetentionPolicySection: true,
        hasContactInformation: true,
        hasGdprCompliance: false,
        hasCcpaCompliance: true,
      );
      expect(result.isCompliant, true);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('GDPR'));
    });
  });

  group('Data Subject Request Validation', () {
    test('validates access request', () {
      final result = service.validateDataSubjectRequest(
        right: DataSubjectRight.access,
        userId: 'user123',
      );
      expect(result.isCompliant, true);
      expect(result.details['supported'], true);
    });

    test('validates erasure request', () {
      final result = service.validateDataSubjectRequest(
        right: DataSubjectRight.erasure,
        userId: 'user123',
      );
      expect(result.isCompliant, true);
      expect(result.details['supported'], true);
    });

    test('validates portability request', () {
      final result = service.validateDataSubjectRequest(
        right: DataSubjectRight.portability,
        userId: 'user123',
      );
      expect(result.isCompliant, true);
      expect(result.details['supported'], true);
    });

    test('rejects request with empty user ID', () {
      final result = service.validateDataSubjectRequest(
        right: DataSubjectRight.access,
        userId: '',
      );
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('User ID is required')), true);
    });

    test('warns about unsupported rights requiring manual processing', () {
      final result = service.validateDataSubjectRequest(
        right: DataSubjectRight.restrictProcessing,
        userId: 'user123',
      );
      expect(result.warnings, isNotEmpty);
      expect(result.details['supported'], false);
    });
  });

  group('Consent Records Validation', () {
    test('validates consent with required data processing consent', () {
      final consents = [
        ConsentRecord(
          type: ConsentType.dataProcessing,
          granted: true,
          timestamp: DateTime.now(),
        ),
        ConsentRecord(
          type: ConsentType.pushNotifications,
          granted: true,
          timestamp: DateTime.now(),
        ),
      ];
      final result = service.validateConsentRecords(consents);
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('rejects consents missing required data processing consent', () {
      final consents = [
        ConsentRecord(
          type: ConsentType.marketing,
          granted: true,
          timestamp: DateTime.now(),
        ),
      ];
      final result = service.validateConsentRecords(consents);
      expect(result.isCompliant, false);
      expect(result.violations.any((v) => v.contains('required consent')), true);
    });

    test('warns about outdated consents older than 2 years', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 800));
      final consents = [
        ConsentRecord(
          type: ConsentType.dataProcessing,
          granted: true,
          timestamp: DateTime.now(),
        ),
        ConsentRecord(
          type: ConsentType.marketing,
          granted: true,
          timestamp: oldDate,
        ),
      ];
      final result = service.validateConsentRecords(consents);
      expect(result.isCompliant, true);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('older than 2 years'));
    });

    test('counts granted consents correctly', () {
      final consents = [
        ConsentRecord(
          type: ConsentType.dataProcessing,
          granted: true,
          timestamp: DateTime.now(),
        ),
        ConsentRecord(
          type: ConsentType.marketing,
          granted: false,
          timestamp: DateTime.now(),
        ),
        ConsentRecord(
          type: ConsentType.analytics,
          granted: true,
          timestamp: DateTime.now(),
        ),
      ];
      final result = service.validateConsentRecords(consents);
      expect(result.details['total_consents'], 3);
      expect(result.details['granted_consents'], 2);
    });
  });

  group('Data Retention Validation', () {
    test('validates active data items', () {
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final result = service.validateDataRetention(items);
      expect(result.isCompliant, true);
      expect(result.details['active_items'], 1);
    });

    test('warns about items that can be permanently deleted', () {
      final oldDeletionDate = DateTime.now().subtract(const Duration(days: 2600)); // > 7 years
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'old@example.com',
          collectedAt: DateTime.now().subtract(const Duration(days: 3000)),
          isDeleted: true,
          deletedAt: oldDeletionDate,
        ),
      ];
      final result = service.validateDataRetention(items);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('permanently deleted'));
      expect(result.details['items_to_permanently_delete'], 1);
    });

    test('tracks soft deleted items within retention period', () {
      final recentDeletion = DateTime.now().subtract(const Duration(days: 30));
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: DateTime.now().subtract(const Duration(days: 365)),
          isDeleted: true,
          deletedAt: recentDeletion,
        ),
      ];
      final result = service.validateDataRetention(items);
      expect(result.isCompliant, true);
      expect(result.details['soft_deleted_items'], 1);
      expect(result.details['items_to_permanently_delete'], 0);
    });
  });

  group('User Data Export', () {
    test('generates user data export with all active items', () {
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: DateTime.now(),
          isDeleted: false,
        ),
        UserDataItem(
          dataType: 'photo',
          category: DataCategory.biometric,
          value: 'photo_url',
          collectedAt: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final export = service.generateUserDataExport(
        userId: 'user123',
        dataItems: items,
      );
      expect(export.userId, 'user123');
      expect(export.dataItems.length, 2);
      expect(export.metadata['export_format'], 'JSON');
      expect(export.metadata['gdpr_article'], contains('Article 20'));
    });

    test('excludes deleted items from export', () {
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: DateTime.now(),
          isDeleted: false,
        ),
        UserDataItem(
          dataType: 'old_email',
          category: DataCategory.identity,
          value: 'old@example.com',
          collectedAt: DateTime.now().subtract(const Duration(days: 365)),
          isDeleted: true,
          deletedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];
      final export = service.generateUserDataExport(
        userId: 'user123',
        dataItems: items,
      );
      expect(export.dataItems.length, 1);
      expect(export.dataItems.first.value, 'user@example.com');
    });

    test('includes additional metadata in export', () {
      final export = service.generateUserDataExport(
        userId: 'user123',
        dataItems: [],
        additionalMetadata: {'request_id': '12345', 'format_version': '1.0'},
      );
      expect(export.metadata['request_id'], '12345');
      expect(export.metadata['format_version'], '1.0');
    });
  });

  group('Comprehensive Compliance Check', () {
    test('performs comprehensive check with all valid data', () {
      final consents = [
        ConsentRecord(
          type: ConsentType.dataProcessing,
          granted: true,
          timestamp: DateTime.now(),
        ),
      ];
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final result = service.performComprehensiveCheck(
        userId: 'user123',
        email: 'user@example.com',
        consents: consents,
        userDataItems: items,
      );
      expect(result.isCompliant, true);
      expect(result.violations, isEmpty);
    });

    test('aggregates violations from multiple checks', () {
      final consents = [
        ConsentRecord(
          type: ConsentType.marketing,
          granted: true,
          timestamp: DateTime.now(),
        ),
      ];
      final result = service.performComprehensiveCheck(
        userId: 'user123',
        email: 'invalid-email',
        consents: consents,
      );
      expect(result.isCompliant, false);
      expect(result.violations.length, greaterThan(0));
    });

    test('includes details from all sub-checks', () {
      final result = service.performComprehensiveCheck(
        userId: 'user123',
        email: 'user@example.com',
      );
      expect(result.details['email_check'], isNotNull);
    });
  });
}
