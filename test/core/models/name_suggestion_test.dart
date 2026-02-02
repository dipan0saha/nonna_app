import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';
import 'package:nonna_app/core/enums/gender.dart';

void main() {
  group('NameSuggestion', () {
    final now = DateTime.now();
    final nameSuggestion = NameSuggestion(
      id: 'suggestion-123',
      babyProfileId: 'baby-profile-123',
      userId: 'user-123',
      gender: Gender.male,
      suggestedName: 'Oliver',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates NameSuggestion from valid JSON', () {
        final json = {
          'id': 'suggestion-123',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-123',
          'gender': 'male',
          'suggested_name': 'Oliver',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        };

        final result = NameSuggestion.fromJson(json);

        expect(result.id, 'suggestion-123');
        expect(result.babyProfileId, 'baby-profile-123');
        expect(result.userId, 'user-123');
        expect(result.gender, Gender.male);
        expect(result.suggestedName, 'Oliver');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, null);
      });

      test('handles deleted_at timestamp', () {
        final deletedAt = DateTime.now().subtract(const Duration(days: 1));
        final json = {
          'id': 'suggestion-123',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-123',
          'gender': 'female',
          'suggested_name': 'Emma',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': deletedAt.toIso8601String(),
        };

        final result = NameSuggestion.fromJson(json);

        expect(result.deletedAt, deletedAt);
        expect(result.isDeleted, true);
      });

      test('handles unknown gender', () {
        final json = {
          'id': 'suggestion-123',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-123',
          'gender': 'unknown',
          'suggested_name': 'Alex',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = NameSuggestion.fromJson(json);

        expect(result.gender, Gender.unknown);
      });
    });

    group('toJson', () {
      test('converts NameSuggestion to JSON', () {
        final json = nameSuggestion.toJson();

        expect(json['id'], 'suggestion-123');
        expect(json['baby_profile_id'], 'baby-profile-123');
        expect(json['user_id'], 'user-123');
        expect(json['gender'], 'male');
        expect(json['suggested_name'], 'Oliver');
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
        expect(json['deleted_at'], null);
      });

      test('includes deleted_at when present', () {
        final deletedAt = DateTime.now();
        final deleted = nameSuggestion.copyWith(deletedAt: deletedAt);
        final json = deleted.toJson();

        expect(json['deleted_at'], deletedAt.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid name suggestion', () {
        expect(nameSuggestion.validate(), null);
      });

      test('returns error for empty suggested name', () {
        final invalid = nameSuggestion.copyWith(suggestedName: '');
        expect(invalid.validate(), 'Suggested name is required');
      });

      test('returns error for whitespace-only suggested name', () {
        final invalid = nameSuggestion.copyWith(suggestedName: '   ');
        expect(invalid.validate(), 'Suggested name is required');
      });

      test('returns error for suggested name exceeding 100 characters', () {
        final invalid = nameSuggestion.copyWith(suggestedName: 'a' * 101);
        expect(
          invalid.validate(),
          'Suggested name must be 100 characters or less',
        );
      });

      test('returns error for name not starting with letter', () {
        final invalid = nameSuggestion.copyWith(suggestedName: '123Name');
        expect(
          invalid.validate(),
          'Suggested name must start with a letter',
        );
      });

      test('accepts name with spaces', () {
        final valid = nameSuggestion.copyWith(suggestedName: 'Mary Jane');
        expect(valid.validate(), null);
      });

      test('accepts name with hyphens', () {
        final valid = nameSuggestion.copyWith(suggestedName: 'Mary-Jane');
        expect(valid.validate(), null);
      });
    });

    group('isDeleted', () {
      test('returns false when deletedAt is null', () {
        expect(nameSuggestion.isDeleted, false);
      });

      test('returns true when deletedAt is set', () {
        final deleted = nameSuggestion.copyWith(
          deletedAt: DateTime.now(),
        );
        expect(deleted.isDeleted, true);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final copy = nameSuggestion.copyWith(
          suggestedName: 'William',
          gender: Gender.male,
        );

        expect(copy.id, nameSuggestion.id);
        expect(copy.suggestedName, 'William');
        expect(copy.gender, Gender.male);
        expect(copy.babyProfileId, nameSuggestion.babyProfileId);
      });
    });

    group('equality', () {
      test('two suggestions with same values are equal', () {
        final suggestion1 = NameSuggestion(
          id: 'suggestion-123',
          babyProfileId: 'baby-123',
          userId: 'user-123',
          gender: Gender.female,
          suggestedName: 'Sophia',
          createdAt: now,
          updatedAt: now,
        );

        final suggestion2 = NameSuggestion(
          id: 'suggestion-123',
          babyProfileId: 'baby-123',
          userId: 'user-123',
          gender: Gender.female,
          suggestedName: 'Sophia',
          createdAt: now,
          updatedAt: now,
        );

        expect(suggestion1, equals(suggestion2));
        expect(suggestion1.hashCode, equals(suggestion2.hashCode));
      });

      test('two suggestions with different values are not equal', () {
        final suggestion1 = nameSuggestion;
        final suggestion2 = nameSuggestion.copyWith(suggestedName: 'William');

        expect(suggestion1, isNot(equals(suggestion2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = nameSuggestion.toString();

        expect(str, contains('NameSuggestion'));
        expect(str, contains('suggestion-123'));
        expect(str, contains('baby-profile-123'));
        expect(str, contains('Oliver'));
        expect(str, contains('male'));
      });
    });
  });
}
