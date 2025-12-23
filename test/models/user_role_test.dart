import 'package:test/test.dart';
import 'package:nonna_app/models/user_role.dart';

void main() {
  group('UserRole', () {
    group('enum values', () {
      test('has correct string values', () {
        expect(UserRole.systemAdmin.value, equals('system_admin'));
        expect(UserRole.organizer.value, equals('organizer'));
        expect(UserRole.player.value, equals('player'));
        expect(UserRole.guest.value, equals('guest'));
      });

      test('has correct display names', () {
        expect(UserRole.systemAdmin.displayName, equals('System Admin'));
        expect(UserRole.organizer.displayName, equals('Tournament Organizer'));
        expect(UserRole.player.displayName, equals('Player'));
        expect(UserRole.guest.displayName, equals('Guest'));
      });
    });

    group('fromString', () {
      test('converts valid string to UserRole', () {
        expect(UserRole.fromString('system_admin'), equals(UserRole.systemAdmin));
        expect(UserRole.fromString('organizer'), equals(UserRole.organizer));
        expect(UserRole.fromString('player'), equals(UserRole.player));
        expect(UserRole.fromString('guest'), equals(UserRole.guest));
      });

      test('returns guest for invalid string', () {
        expect(UserRole.fromString('invalid'), equals(UserRole.guest));
        expect(UserRole.fromString(''), equals(UserRole.guest));
      });
    });

    group('helper properties', () {
      test('isSystemAdmin returns correct value', () {
        expect(UserRole.systemAdmin.isSystemAdmin, isTrue);
        expect(UserRole.organizer.isSystemAdmin, isFalse);
        expect(UserRole.player.isSystemAdmin, isFalse);
        expect(UserRole.guest.isSystemAdmin, isFalse);
      });

      test('isOrganizer returns correct value', () {
        expect(UserRole.systemAdmin.isOrganizer, isFalse);
        expect(UserRole.organizer.isOrganizer, isTrue);
        expect(UserRole.player.isOrganizer, isFalse);
        expect(UserRole.guest.isOrganizer, isFalse);
      });

      test('isPlayer returns correct value', () {
        expect(UserRole.systemAdmin.isPlayer, isFalse);
        expect(UserRole.organizer.isPlayer, isFalse);
        expect(UserRole.player.isPlayer, isTrue);
        expect(UserRole.guest.isPlayer, isFalse);
      });

      test('isGuest returns correct value', () {
        expect(UserRole.systemAdmin.isGuest, isFalse);
        expect(UserRole.organizer.isGuest, isFalse);
        expect(UserRole.player.isGuest, isFalse);
        expect(UserRole.guest.isGuest, isTrue);
      });
    });

    group('toString', () {
      test('returns display name', () {
        expect(UserRole.systemAdmin.toString(), equals('System Admin'));
        expect(UserRole.organizer.toString(), equals('Tournament Organizer'));
        expect(UserRole.player.toString(), equals('Player'));
        expect(UserRole.guest.toString(), equals('Guest'));
      });
    });
  });
}
