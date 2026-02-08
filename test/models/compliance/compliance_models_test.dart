import 'package:test/test.dart';
import 'package:nonna_app/models/compliance/data_subject_right.dart';
import 'package:nonna_app/models/compliance/data_category.dart';
import 'package:nonna_app/models/compliance/consent_type.dart';
import 'package:nonna_app/models/compliance/user_data_item.dart';

void main() {
  group('DataSubjectRight', () {
    test('has correct descriptions', () {
      expect(DataSubjectRight.access.description, contains('access'));
      expect(DataSubjectRight.erasure.description, contains('erasure'));
      expect(DataSubjectRight.portability.description, contains('portability'));
    });

    test('identifies GDPR-specific rights', () {
      expect(DataSubjectRight.restrictProcessing.isGDPR, true);
      expect(DataSubjectRight.objectToProcessing.isGDPR, true);
      expect(DataSubjectRight.withdrawConsent.isGDPR, true);
      expect(DataSubjectRight.access.isGDPR, false);
    });

    test('identifies CCPA-specific rights', () {
      expect(DataSubjectRight.optOutOfSale.isCCPA, true);
      expect(DataSubjectRight.access.isCCPA, false);
    });
  });

  group('DataCategory', () {
    test('has correct descriptions', () {
      expect(DataCategory.identity.description, contains('Identity'));
      expect(DataCategory.biometric.description, contains('Biometric'));
      expect(DataCategory.sensitive.description, contains('Sensitive'));
    });

    test('identifies data requiring special protection', () {
      expect(DataCategory.sensitive.requiresSpecialProtection, true);
      expect(DataCategory.biometric.requiresSpecialProtection, true);
      expect(DataCategory.identity.requiresSpecialProtection, false);
      expect(DataCategory.contact.requiresSpecialProtection, false);
    });

    test('has correct retention period (7 years)', () {
      // 7 years = 365.25 * 7 ≈ 2557 days
      expect(DataCategory.identity.retentionPeriodDays, 2557);
      expect(DataCategory.biometric.retentionPeriodDays, 2557);
    });
  });

  group('ConsentType', () {
    test('has correct descriptions', () {
      expect(ConsentType.dataProcessing.description, contains('personal data'));
      expect(ConsentType.pushNotifications.description, contains('Push notifications'));
    });

    test('identifies required consents', () {
      expect(ConsentType.dataProcessing.isRequired, true);
      expect(ConsentType.marketing.isRequired, false);
      expect(ConsentType.pushNotifications.isRequired, false);
    });

    test('identifies withdrawable consents', () {
      expect(ConsentType.marketing.canWithdraw, true);
      expect(ConsentType.pushNotifications.canWithdraw, true);
      expect(ConsentType.dataProcessing.canWithdraw, false);
    });
  });

  group('ConsentRecord', () {
    test('creates consent record with all fields', () {
      final now = DateTime.now();
      final record = ConsentRecord(
        type: ConsentType.marketing,
        granted: true,
        timestamp: now,
        purpose: 'Marketing emails',
      );

      expect(record.type, ConsentType.marketing);
      expect(record.granted, true);
      expect(record.timestamp, now);
      expect(record.purpose, 'Marketing emails');
    });

    test('converts to and from JSON', () {
      final now = DateTime.now();
      final record = ConsentRecord(
        type: ConsentType.pushNotifications,
        granted: true,
        timestamp: now,
        purpose: 'Receive updates',
      );

      final json = record.toJson();
      expect(json['type'], 'pushNotifications');
      expect(json['granted'], true);
      expect(json['purpose'], 'Receive updates');

      final restored = ConsentRecord.fromJson(json);
      expect(restored.type, record.type);
      expect(restored.granted, record.granted);
      expect(restored.purpose, record.purpose);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = ConsentRecord(
        type: ConsentType.marketing,
        granted: false,
        timestamp: DateTime.now(),
      );

      final updated = original.copyWith(granted: true, purpose: 'New purpose');
      expect(updated.granted, true);
      expect(updated.purpose, 'New purpose');
      expect(updated.type, original.type);
      expect(original.granted, false); // Original unchanged
    });
  });

  group('UserDataItem', () {
    test('creates user data item with all fields', () {
      final now = DateTime.now();
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        value: 'user@example.com',
        collectedAt: now,
        legalBasis: 'Consent',
        isDeleted: false,
      );

      expect(item.dataType, 'email');
      expect(item.category, DataCategory.identity);
      expect(item.value, 'user@example.com');
      expect(item.legalBasis, 'Consent');
      expect(item.isDeleted, false);
    });

    test('converts to and from JSON', () {
      final now = DateTime.now();
      final item = UserDataItem(
        dataType: 'photo',
        category: DataCategory.biometric,
        value: 'photo_url',
        collectedAt: now,
        legalBasis: 'Contract',
        isDeleted: false,
      );

      final json = item.toJson();
      expect(json['dataType'], 'photo');
      expect(json['category'], 'biometric');
      expect(json['value'], 'photo_url');

      final restored = UserDataItem.fromJson(json);
      expect(restored.dataType, item.dataType);
      expect(restored.category, item.category);
      expect(restored.value, item.value);
    });

    test('isWithinRetentionPeriod returns true for active data', () {
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now(),
        isDeleted: false,
      );

      expect(item.isWithinRetentionPeriod(DateTime.now()), true);
    });

    test('isWithinRetentionPeriod returns true for recently deleted data', () {
      final deletedRecently = DateTime.now().subtract(const Duration(days: 365));
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now().subtract(const Duration(days: 400)),
        isDeleted: true,
        deletedAt: deletedRecently,
      );

      expect(item.isWithinRetentionPeriod(DateTime.now()), true);
    });

    test('isWithinRetentionPeriod returns false for old deleted data', () {
      final deletedLongAgo = DateTime.now().subtract(const Duration(days: 2600)); // > 7 years
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now().subtract(const Duration(days: 3000)),
        isDeleted: true,
        deletedAt: deletedLongAgo,
      );

      expect(item.isWithinRetentionPeriod(DateTime.now()), false);
    });

    test('canPermanentlyDelete returns true for old deleted data', () {
      final deletedLongAgo = DateTime.now().subtract(const Duration(days: 2600));
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now().subtract(const Duration(days: 3000)),
        isDeleted: true,
        deletedAt: deletedLongAgo,
      );

      expect(item.canPermanentlyDelete(DateTime.now()), true);
    });

    test('canPermanentlyDelete returns false for active data', () {
      final item = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now(),
        isDeleted: false,
      );

      expect(item.canPermanentlyDelete(DateTime.now()), false);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = UserDataItem(
        dataType: 'email',
        category: DataCategory.identity,
        collectedAt: DateTime.now(),
        isDeleted: false,
      );

      final updated = original.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );

      expect(updated.isDeleted, true);
      expect(updated.deletedAt, isNotNull);
      expect(original.isDeleted, false);
    });
  });

  group('UserDataExport', () {
    test('creates user data export', () {
      final now = DateTime.now();
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: now,
        ),
      ];

      final export = UserDataExport(
        userId: 'user123',
        exportedAt: now,
        dataItems: items,
        metadata: {'format': 'JSON'},
      );

      expect(export.userId, 'user123');
      expect(export.dataItems.length, 1);
      expect(export.metadata['format'], 'JSON');
    });

    test('converts to and from JSON', () {
      final now = DateTime.now();
      final items = [
        UserDataItem(
          dataType: 'email',
          category: DataCategory.identity,
          value: 'user@example.com',
          collectedAt: now,
        ),
      ];

      final export = UserDataExport(
        userId: 'user123',
        exportedAt: now,
        dataItems: items,
        metadata: {'version': '1.0'},
      );

      final json = export.toJson();
      expect(json['userId'], 'user123');
      expect(json['dataItems'], isList);
      expect(json['metadata']['version'], '1.0');

      final restored = UserDataExport.fromJson(json);
      expect(restored.userId, export.userId);
      expect(restored.dataItems.length, export.dataItems.length);
      expect(restored.metadata['version'], '1.0');
    });

    test('handles empty metadata', () {
      final export = UserDataExport(
        userId: 'user123',
        exportedAt: DateTime.now(),
        dataItems: [],
      );

      expect(export.metadata, isEmpty);

      final json = export.toJson();
      final restored = UserDataExport.fromJson(json);
      expect(restored.metadata, isEmpty);
    });
  });
}
