import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/vote.dart';
import 'package:nonna_app/core/enums/vote_type.dart';

void main() {
  group('Vote', () {
    final now = DateTime.now();
    final genderVote = Vote(
      id: 'vote-123',
      babyProfileId: 'baby-profile-123',
      userId: 'user-123',
      voteType: VoteType.gender,
      valueText: 'male',
      isAnonymous: false,
      createdAt: now,
      updatedAt: now,
    );

    final birthdateVote = Vote(
      id: 'vote-456',
      babyProfileId: 'baby-profile-123',
      userId: 'user-456',
      voteType: VoteType.birthdate,
      valueDate: DateTime(2026, 6, 15),
      isAnonymous: true,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates Vote from valid JSON for gender vote', () {
        final json = {
          'id': 'vote-123',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-123',
          'vote_type': 'gender',
          'value_text': 'male',
          'value_date': null,
          'is_anonymous': false,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Vote.fromJson(json);

        expect(result.id, 'vote-123');
        expect(result.babyProfileId, 'baby-profile-123');
        expect(result.userId, 'user-123');
        expect(result.voteType, VoteType.gender);
        expect(result.valueText, 'male');
        expect(result.valueDate, null);
        expect(result.isAnonymous, false);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('creates Vote from valid JSON for birthdate vote', () {
        final birthdate = DateTime(2026, 6, 15);
        final json = {
          'id': 'vote-456',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-456',
          'vote_type': 'birthdate',
          'value_text': null,
          'value_date': birthdate.toIso8601String(),
          'is_anonymous': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Vote.fromJson(json);

        expect(result.id, 'vote-456');
        expect(result.voteType, VoteType.birthdate);
        expect(result.valueText, null);
        expect(result.valueDate, birthdate);
        expect(result.isAnonymous, true);
      });

      test('defaults isAnonymous to false when missing', () {
        final json = {
          'id': 'vote-123',
          'baby_profile_id': 'baby-profile-123',
          'user_id': 'user-123',
          'vote_type': 'gender',
          'value_text': 'female',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Vote.fromJson(json);

        expect(result.isAnonymous, false);
      });
    });

    group('toJson', () {
      test('converts gender Vote to JSON', () {
        final json = genderVote.toJson();

        expect(json['id'], 'vote-123');
        expect(json['baby_profile_id'], 'baby-profile-123');
        expect(json['user_id'], 'user-123');
        expect(json['vote_type'], 'gender');
        expect(json['value_text'], 'male');
        expect(json['value_date'], null);
        expect(json['is_anonymous'], false);
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
      });

      test('converts birthdate Vote to JSON', () {
        final json = birthdateVote.toJson();

        expect(json['vote_type'], 'birthdate');
        expect(json['value_date'], DateTime(2026, 6, 15).toIso8601String());
        expect(json['is_anonymous'], true);
      });
    });

    group('validate', () {
      test('returns null for valid gender vote', () {
        expect(genderVote.validate(), null);
      });

      test('returns null for valid birthdate vote', () {
        expect(birthdateVote.validate(), null);
      });

      test('returns error for gender vote without text value', () {
        final invalidVote = genderVote.copyWith(valueText: null);
        expect(invalidVote.validate(), 'Gender vote must have a text value');
      });

      test('returns error for gender vote with empty text value', () {
        final invalidVote = genderVote.copyWith(valueText: '   ');
        expect(invalidVote.validate(), 'Gender vote must have a text value');
      });

      test('returns error for birthdate vote without date value', () {
        final invalidVote = birthdateVote.copyWith(valueDate: null);
        expect(invalidVote.validate(), 'Birthdate vote must have a date value');
      });
    });

    group('hasTextValue', () {
      test('returns true when text value exists', () {
        expect(genderVote.hasTextValue, true);
      });

      test('returns false when text value is null', () {
        expect(birthdateVote.hasTextValue, false);
      });

      test('returns false when text value is empty', () {
        final emptyVote = genderVote.copyWith(valueText: '');
        expect(emptyVote.hasTextValue, false);
      });
    });

    group('hasDateValue', () {
      test('returns true when date value exists', () {
        expect(birthdateVote.hasDateValue, true);
      });

      test('returns false when date value is null', () {
        expect(genderVote.hasDateValue, false);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final copy = genderVote.copyWith(
          valueText: 'female',
          isAnonymous: true,
        );

        expect(copy.id, genderVote.id);
        expect(copy.valueText, 'female');
        expect(copy.isAnonymous, true);
        expect(copy.babyProfileId, genderVote.babyProfileId);
      });
    });

    group('equality', () {
      test('two votes with same values are equal', () {
        final vote1 = Vote(
          id: 'vote-123',
          babyProfileId: 'baby-123',
          userId: 'user-123',
          voteType: VoteType.gender,
          valueText: 'male',
          createdAt: now,
          updatedAt: now,
        );

        final vote2 = Vote(
          id: 'vote-123',
          babyProfileId: 'baby-123',
          userId: 'user-123',
          voteType: VoteType.gender,
          valueText: 'male',
          createdAt: now,
          updatedAt: now,
        );

        expect(vote1, equals(vote2));
        expect(vote1.hashCode, equals(vote2.hashCode));
      });

      test('two votes with different values are not equal', () {
        final vote1 = genderVote;
        final vote2 = birthdateVote;

        expect(vote1, isNot(equals(vote2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = genderVote.toString();

        expect(str, contains('Vote'));
        expect(str, contains('vote-123'));
        expect(str, contains('baby-profile-123'));
        expect(str, contains('user-123'));
        expect(str, contains('gender'));
      });
    });
  });
}
