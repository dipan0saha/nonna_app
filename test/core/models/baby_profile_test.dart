import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/baby_profile.dart';

void main() {
  group('BabyProfile', () {
    final now = DateTime.now();
    final expectedBirthDate = DateTime.now().add(const Duration(days: 30));
    final babyProfile = BabyProfile(
      id: 'baby-123',
      name: 'Baby Jane',
      defaultLastNameSource: 'mother',
      profilePhotoUrl: 'https://example.com/baby.jpg',
      expectedBirthDate: expectedBirthDate,
      gender: Gender.female,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates BabyProfile from valid JSON', () {
        final json = {
          'id': 'baby-123',
          'name': 'Baby Jane',
          'default_last_name_source': 'mother',
          'profile_photo_url': 'https://example.com/baby.jpg',
          'expected_birth_date': expectedBirthDate.toIso8601String(),
          'actual_birth_date': null,
          'gender': 'female',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        };

        final result = BabyProfile.fromJson(json);

        expect(result.id, 'baby-123');
        expect(result.name, 'Baby Jane');
        expect(result.defaultLastNameSource, 'mother');
        expect(result.profilePhotoUrl, 'https://example.com/baby.jpg');
        expect(result.expectedBirthDate, expectedBirthDate);
        expect(result.actualBirthDate, null);
        expect(result.gender, Gender.female);
        expect(result.deletedAt, null);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'baby-123',
          'name': 'Baby Jane',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = BabyProfile.fromJson(json);

        expect(result.defaultLastNameSource, null);
        expect(result.profilePhotoUrl, null);
        expect(result.expectedBirthDate, null);
        expect(result.actualBirthDate, null);
        expect(result.gender, Gender.unknown);
        expect(result.deletedAt, null);
      });
    });

    group('toJson', () {
      test('converts BabyProfile to JSON', () {
        final json = babyProfile.toJson();

        expect(json['id'], 'baby-123');
        expect(json['name'], 'Baby Jane');
        expect(json['default_last_name_source'], 'mother');
        expect(json['profile_photo_url'], 'https://example.com/baby.jpg');
        expect(json['expected_birth_date'], expectedBirthDate.toIso8601String());
        expect(json['actual_birth_date'], null);
        expect(json['gender'], 'female');
      });
    });

    group('validate', () {
      test('returns null for valid baby profile', () {
        expect(babyProfile.validate(), null);
      });

      test('returns error for empty name', () {
        final invalid = babyProfile.copyWith(name: '');
        expect(invalid.validate(), 'Baby name is required');
      });

      test('returns error for whitespace-only name', () {
        final invalid = babyProfile.copyWith(name: '   ');
        expect(invalid.validate(), 'Baby name is required');
      });

      test('returns error for name exceeding 100 characters', () {
        final invalid = babyProfile.copyWith(name: 'a' * 101);
        expect(invalid.validate(), 'Baby name must be 100 characters or less');
      });

      test('returns error for actual birth date in the future', () {
        final invalid = babyProfile.copyWith(
          actualBirthDate: DateTime.now().add(const Duration(days: 1)),
        );
        expect(invalid.validate(), 'Actual birth date cannot be in the future');
      });

      test('allows actual birth date before expected date within range', () {
        final expected = DateTime.now().add(const Duration(days: 30));
        final actual = DateTime.now().subtract(const Duration(days: 10));
        final profile = babyProfile.copyWith(
          expectedBirthDate: expected,
          actualBirthDate: actual,
        );
        expect(profile.validate(), null);
      });
    });

    group('isBorn', () {
      test('returns false when actualBirthDate is null', () {
        expect(babyProfile.isBorn, false);
      });

      test('returns true when actualBirthDate is set', () {
        final born = babyProfile.copyWith(
          actualBirthDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(born.isBorn, true);
      });
    });

    group('isDeleted', () {
      test('returns false when deletedAt is null', () {
        expect(babyProfile.isDeleted, false);
      });

      test('returns true when deletedAt is set', () {
        final deleted = babyProfile.copyWith(deletedAt: DateTime.now());
        expect(deleted.isDeleted, true);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = babyProfile.copyWith(
          name: 'Baby John',
          gender: Gender.male,
        );

        expect(updated.id, babyProfile.id);
        expect(updated.name, 'Baby John');
        expect(updated.gender, Gender.male);
        expect(updated.expectedBirthDate, babyProfile.expectedBirthDate);
      });
    });

    group('equality', () {
      test('equal profiles are equal', () {
        final profile1 = BabyProfile(
          id: 'baby-123',
          name: 'Baby Jane',
          gender: Gender.female,
          createdAt: now,
          updatedAt: now,
        );
        final profile2 = BabyProfile(
          id: 'baby-123',
          name: 'Baby Jane',
          gender: Gender.female,
          createdAt: now,
          updatedAt: now,
        );

        expect(profile1, profile2);
        expect(profile1.hashCode, profile2.hashCode);
      });

      test('different profiles are not equal', () {
        final profile1 = BabyProfile(
          id: 'baby-123',
          name: 'Baby Jane',
          createdAt: now,
          updatedAt: now,
        );
        final profile2 = BabyProfile(
          id: 'baby-456',
          name: 'Baby John',
          createdAt: now,
          updatedAt: now,
        );

        expect(profile1, isNot(profile2));
      });
    });
  });
}
