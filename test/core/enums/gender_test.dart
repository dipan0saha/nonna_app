import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';

void main() {
  group('Gender', () {
    test('has correct number of values', () {
      expect(Gender.values.length, 3);
    });

    test('has male, female, and unknown values', () {
      expect(Gender.values, contains(Gender.male));
      expect(Gender.values, contains(Gender.female));
      expect(Gender.values, contains(Gender.unknown));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(Gender.male.toJson(), 'male');
        expect(Gender.female.toJson(), 'female');
        expect(Gender.unknown.toJson(), 'unknown');
      });

      test('fromJson parses correct values', () {
        expect(Gender.fromJson('male'), Gender.male);
        expect(Gender.fromJson('female'), Gender.female);
        expect(Gender.fromJson('unknown'), Gender.unknown);
      });

      test('fromJson is case insensitive', () {
        expect(Gender.fromJson('MALE'), Gender.male);
        expect(Gender.fromJson('Female'), Gender.female);
        expect(Gender.fromJson('UnKnOwN'), Gender.unknown);
      });

      test('fromJson defaults to unknown for invalid input', () {
        expect(Gender.fromJson('invalid'), Gender.unknown);
        expect(Gender.fromJson(''), Gender.unknown);
        expect(Gender.fromJson('other'), Gender.unknown);
      });

      test('toJson and fromJson are reversible', () {
        for (final gender in Gender.values) {
          final json = gender.toJson();
          final parsed = Gender.fromJson(json);
          expect(parsed, gender);
        }
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(Gender.male.displayName, 'Male');
        expect(Gender.female.displayName, 'Female');
        expect(Gender.unknown.displayName, 'Unknown');
      });

      test('all display names are non-empty', () {
        for (final gender in Gender.values) {
          expect(gender.displayName.isNotEmpty, true);
        }
      });

      test('display names are capitalized', () {
        for (final gender in Gender.values) {
          expect(gender.displayName[0], equals(gender.displayName[0].toUpperCase()));
        }
      });
    });

    group('icon', () {
      test('returns correct icons', () {
        expect(Gender.male.icon, Icons.male);
        expect(Gender.female.icon, Icons.female);
        expect(Gender.unknown.icon, Icons.help_outline);
      });

      test('all icons are IconData', () {
        for (final gender in Gender.values) {
          expect(gender.icon, isA<IconData>());
        }
      });

      test('male and female have different icons', () {
        expect(Gender.male.icon, isNot(equals(Gender.female.icon)));
      });

      test('unknown has help icon', () {
        expect(Gender.unknown.icon, Icons.help_outline);
      });
    });

    group('color', () {
      test('returns correct colors', () {
        expect(Gender.male.color, Colors.blue);
        expect(Gender.female.color, Colors.pink);
        expect(Gender.unknown.color, Colors.grey);
      });

      test('all colors are Color objects', () {
        for (final gender in Gender.values) {
          expect(gender.color, isA<Color>());
        }
      });

      test('male and female have different colors', () {
        expect(Gender.male.color, isNot(equals(Gender.female.color)));
      });

      test('uses traditional gender colors', () {
        expect(Gender.male.color, Colors.blue);
        expect(Gender.female.color, Colors.pink);
      });

      test('unknown uses neutral color', () {
        expect(Gender.unknown.color, Colors.grey);
      });
    });

    group('consistency', () {
      test('all genders have unique display names', () {
        final displayNames = Gender.values.map((g) => g.displayName).toSet();
        expect(displayNames.length, Gender.values.length);
      });

      test('all genders have unique icons', () {
        final icons = Gender.values.map((g) => g.icon).toSet();
        expect(icons.length, Gender.values.length);
      });

      test('all genders have unique colors', () {
        final colors = Gender.values.map((g) => g.color).toSet();
        expect(colors.length, Gender.values.length);
      });
    });

    group('edge cases', () {
      test('handles all enum values', () {
        for (final gender in Gender.values) {
          expect(() => gender.toJson(), returnsNormally);
          expect(() => gender.displayName, returnsNormally);
          expect(() => gender.icon, returnsNormally);
          expect(() => gender.color, returnsNormally);
        }
      });
    });
  });
}
