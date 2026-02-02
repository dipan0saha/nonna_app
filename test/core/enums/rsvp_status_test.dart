import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';

void main() {
  group('RsvpStatus', () {
    test('has correct number of values', () {
      expect(RsvpStatus.values.length, 3);
    });

    test('has yes, no, and maybe values', () {
      expect(RsvpStatus.values, contains(RsvpStatus.yes));
      expect(RsvpStatus.values, contains(RsvpStatus.no));
      expect(RsvpStatus.values, contains(RsvpStatus.maybe));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(RsvpStatus.yes.toJson(), 'yes');
        expect(RsvpStatus.no.toJson(), 'no');
        expect(RsvpStatus.maybe.toJson(), 'maybe');
      });

      test('fromJson parses correct values', () {
        expect(RsvpStatus.fromJson('yes'), RsvpStatus.yes);
        expect(RsvpStatus.fromJson('no'), RsvpStatus.no);
        expect(RsvpStatus.fromJson('maybe'), RsvpStatus.maybe);
      });

      test('fromJson is case insensitive', () {
        expect(RsvpStatus.fromJson('YES'), RsvpStatus.yes);
        expect(RsvpStatus.fromJson('No'), RsvpStatus.no);
        expect(RsvpStatus.fromJson('MaYbE'), RsvpStatus.maybe);
      });

      test('fromJson defaults to maybe for invalid input', () {
        expect(RsvpStatus.fromJson('invalid'), RsvpStatus.maybe);
        expect(RsvpStatus.fromJson(''), RsvpStatus.maybe);
        expect(RsvpStatus.fromJson('unknown'), RsvpStatus.maybe);
      });

      test('toJson and fromJson are reversible', () {
        for (final status in RsvpStatus.values) {
          final json = status.toJson();
          final parsed = RsvpStatus.fromJson(json);
          expect(parsed, status);
        }
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(RsvpStatus.yes.displayName, 'Yes');
        expect(RsvpStatus.no.displayName, 'No');
        expect(RsvpStatus.maybe.displayName, 'Maybe');
      });

      test('all display names are non-empty', () {
        for (final status in RsvpStatus.values) {
          expect(status.displayName.isNotEmpty, true);
        }
      });

      test('display names are capitalized', () {
        for (final status in RsvpStatus.values) {
          expect(status.displayName[0], equals(status.displayName[0].toUpperCase()));
        }
      });
    });

    group('icon', () {
      test('returns correct icons', () {
        expect(RsvpStatus.yes.icon, Icons.check_circle);
        expect(RsvpStatus.no.icon, Icons.cancel);
        expect(RsvpStatus.maybe.icon, Icons.help);
      });

      test('all icons are IconData', () {
        for (final status in RsvpStatus.values) {
          expect(status.icon, isA<IconData>());
        }
      });

      test('all statuses have different icons', () {
        final icons = RsvpStatus.values.map((s) => s.icon).toSet();
        expect(icons.length, RsvpStatus.values.length);
      });

      test('yes uses positive icon', () {
        expect(RsvpStatus.yes.icon, Icons.check_circle);
      });

      test('no uses negative icon', () {
        expect(RsvpStatus.no.icon, Icons.cancel);
      });

      test('maybe uses uncertain icon', () {
        expect(RsvpStatus.maybe.icon, Icons.help);
      });
    });

    group('color', () {
      test('returns correct colors', () {
        expect(RsvpStatus.yes.color, Colors.green);
        expect(RsvpStatus.no.color, Colors.red);
        expect(RsvpStatus.maybe.color, Colors.orange);
      });

      test('all colors are Color objects', () {
        for (final status in RsvpStatus.values) {
          expect(status.color, isA<Color>());
        }
      });

      test('all statuses have different colors', () {
        final colors = RsvpStatus.values.map((s) => s.color).toSet();
        expect(colors.length, RsvpStatus.values.length);
      });

      test('yes uses positive color', () {
        expect(RsvpStatus.yes.color, Colors.green);
      });

      test('no uses negative color', () {
        expect(RsvpStatus.no.color, Colors.red);
      });

      test('maybe uses warning color', () {
        expect(RsvpStatus.maybe.color, Colors.orange);
      });
    });

    group('consistency', () {
      test('all statuses have unique display names', () {
        final displayNames = RsvpStatus.values.map((s) => s.displayName).toSet();
        expect(displayNames.length, RsvpStatus.values.length);
      });

      test('all statuses have unique icons', () {
        final icons = RsvpStatus.values.map((s) => s.icon).toSet();
        expect(icons.length, RsvpStatus.values.length);
      });

      test('all statuses have unique colors', () {
        final colors = RsvpStatus.values.map((s) => s.color).toSet();
        expect(colors.length, RsvpStatus.values.length);
      });
    });

    group('semantic meaning', () {
      test('yes represents confirmed attendance', () {
        expect(RsvpStatus.yes.displayName, 'Yes');
        expect(RsvpStatus.yes.color, Colors.green);
      });

      test('no represents declined attendance', () {
        expect(RsvpStatus.no.displayName, 'No');
        expect(RsvpStatus.no.color, Colors.red);
      });

      test('maybe represents uncertain attendance', () {
        expect(RsvpStatus.maybe.displayName, 'Maybe');
        expect(RsvpStatus.maybe.color, Colors.orange);
      });
    });

    group('edge cases', () {
      test('handles all enum values', () {
        for (final status in RsvpStatus.values) {
          expect(() => status.toJson(), returnsNormally);
          expect(() => status.displayName, returnsNormally);
          expect(() => status.icon, returnsNormally);
          expect(() => status.color, returnsNormally);
        }
      });
    });
  });
}
