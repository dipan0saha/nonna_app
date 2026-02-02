import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/vote_type.dart';

void main() {
  group('VoteType', () {
    test('has correct number of values', () {
      expect(VoteType.values.length, 2);
    });

    test('has gender and birthdate values', () {
      expect(VoteType.values, contains(VoteType.gender));
      expect(VoteType.values, contains(VoteType.birthdate));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(VoteType.gender.toJson(), 'gender');
        expect(VoteType.birthdate.toJson(), 'birthdate');
      });

      test('fromJson parses correct values', () {
        expect(VoteType.fromJson('gender'), VoteType.gender);
        expect(VoteType.fromJson('birthdate'), VoteType.birthdate);
      });

      test('fromJson is case insensitive', () {
        expect(VoteType.fromJson('GENDER'), VoteType.gender);
        expect(VoteType.fromJson('Birthdate'), VoteType.birthdate);
        expect(VoteType.fromJson('BirthDate'), VoteType.birthdate);
      });

      test('fromJson defaults to gender for invalid input', () {
        expect(VoteType.fromJson('invalid'), VoteType.gender);
        expect(VoteType.fromJson(''), VoteType.gender);
        expect(VoteType.fromJson('weight'), VoteType.gender);
        expect(VoteType.fromJson('name'), VoteType.gender);
      });

      test('toJson and fromJson are reversible', () {
        for (final voteType in VoteType.values) {
          final json = voteType.toJson();
          final parsed = VoteType.fromJson(json);
          expect(parsed, voteType);
        }
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(VoteType.gender.displayName, 'Gender');
        expect(VoteType.birthdate.displayName, 'Birthdate');
      });

      test('all display names are non-empty', () {
        for (final voteType in VoteType.values) {
          expect(voteType.displayName.isNotEmpty, true);
        }
      });

      test('display names are capitalized', () {
        for (final voteType in VoteType.values) {
          expect(
            voteType.displayName[0],
            equals(voteType.displayName[0].toUpperCase()),
          );
        }
      });
    });

    group('consistency', () {
      test('all vote types have unique display names', () {
        final displayNames =
            VoteType.values.map((v) => v.displayName).toSet();
        expect(displayNames.length, VoteType.values.length);
      });

      test('all vote types have unique toJson values', () {
        final jsonValues = VoteType.values.map((v) => v.toJson()).toSet();
        expect(jsonValues.length, VoteType.values.length);
      });

      test('toJson values match enum names', () {
        for (final voteType in VoteType.values) {
          expect(voteType.toJson(), voteType.name);
        }
      });
    });

    group('edge cases', () {
      test('handles all enum values', () {
        for (final voteType in VoteType.values) {
          expect(() => voteType.toJson(), returnsNormally);
          expect(() => voteType.displayName, returnsNormally);
        }
      });

      test('fromJson handles various casing', () {
        expect(VoteType.fromJson('gender'), VoteType.gender);
        expect(VoteType.fromJson('GENDER'), VoteType.gender);
        expect(VoteType.fromJson('Gender'), VoteType.gender);
        expect(VoteType.fromJson('gEnDeR'), VoteType.gender);

        expect(VoteType.fromJson('birthdate'), VoteType.birthdate);
        expect(VoteType.fromJson('BIRTHDATE'), VoteType.birthdate);
        expect(VoteType.fromJson('Birthdate'), VoteType.birthdate);
        expect(VoteType.fromJson('bIrThDaTe'), VoteType.birthdate);
      });

      test('fromJson handles whitespace in invalid values', () {
        expect(VoteType.fromJson('  gender  '), VoteType.gender);
        expect(VoteType.fromJson('  invalid  '), VoteType.gender);
      });
    });

    group('usage scenarios', () {
      test('can be used in lists', () {
        final votes = [VoteType.gender, VoteType.birthdate, VoteType.gender];
        expect(votes.length, 3);
        expect(votes[0], VoteType.gender);
        expect(votes[1], VoteType.birthdate);
        expect(votes[2], VoteType.gender);
      });

      test('can be used in maps', () {
        final voteCounts = {
          VoteType.gender: 10,
          VoteType.birthdate: 15,
        };
        expect(voteCounts[VoteType.gender], 10);
        expect(voteCounts[VoteType.birthdate], 15);
      });

      test('can be compared', () {
        expect(VoteType.gender == VoteType.gender, true);
        expect(VoteType.gender == VoteType.birthdate, false);
        expect(VoteType.birthdate == VoteType.birthdate, true);
      });

      test('can be used in switch statements', () {
        String getDescription(VoteType type) {
          switch (type) {
            case VoteType.gender:
              return 'Gender prediction';
            case VoteType.birthdate:
              return 'Birthdate prediction';
          }
        }

        expect(getDescription(VoteType.gender), 'Gender prediction');
        expect(getDescription(VoteType.birthdate), 'Birthdate prediction');
      });
    });

    group('serialization', () {
      test('can be serialized to JSON', () {
        final data = {
          'voteType': VoteType.gender.toJson(),
          'count': 5,
        };

        expect(data['voteType'], 'gender');
      });

      test('can be deserialized from JSON', () {
        final json = {'voteType': 'birthdate', 'count': 10};

        final voteType = VoteType.fromJson(json['voteType'] as String);
        expect(voteType, VoteType.birthdate);
      });

      test('handles deserialization with missing or invalid data', () {
        expect(VoteType.fromJson('null'), VoteType.gender);
        expect(VoteType.fromJson('undefined'), VoteType.gender);
      });
    });
  });
}
