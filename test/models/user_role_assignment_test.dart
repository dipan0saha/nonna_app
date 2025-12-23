import 'package:test/test.dart';
import 'package:nonna_app/models/user_role.dart';
import 'package:nonna_app/models/user_role_assignment.dart';

void main() {
  group('UserRoleAssignment', () {
    group('constructor', () {
      test('creates assignment with required fields', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        expect(assignment.userId, equals('user123'));
        expect(assignment.role, equals(UserRole.player));
        expect(assignment.ladderId, equals('ladder456'));
        expect(assignment.createdAt, isNull);
        expect(assignment.updatedAt, isNull);
        expect(assignment.metadata, isNull);
      });

      test('creates assignment with all fields', () {
        final now = DateTime.now();
        final metadata = {'key': 'value'};
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder456',
          createdAt: now,
          updatedAt: now,
          metadata: metadata,
        );

        expect(assignment.userId, equals('user123'));
        expect(assignment.role, equals(UserRole.organizer));
        expect(assignment.ladderId, equals('ladder456'));
        expect(assignment.createdAt, equals(now));
        expect(assignment.updatedAt, equals(now));
        expect(assignment.metadata, equals(metadata));
      });
    });

    group('fromJson', () {
      test('deserializes from JSON map', () {
        final json = {
          'user_id': 'user123',
          'role': 'player',
          'ladder_id': 'ladder456',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'metadata': {'key': 'value'},
        };

        final assignment = UserRoleAssignment.fromJson(json);

        expect(assignment.userId, equals('user123'));
        expect(assignment.role, equals(UserRole.player));
        expect(assignment.ladderId, equals('ladder456'));
        expect(assignment.createdAt, isNotNull);
        expect(assignment.updatedAt, isNotNull);
        expect(assignment.metadata, equals({'key': 'value'}));
      });

      test('handles null optional fields', () {
        final json = {
          'user_id': 'user123',
          'role': 'system_admin',
        };

        final assignment = UserRoleAssignment.fromJson(json);

        expect(assignment.userId, equals('user123'));
        expect(assignment.role, equals(UserRole.systemAdmin));
        expect(assignment.ladderId, isNull);
        expect(assignment.createdAt, isNull);
        expect(assignment.updatedAt, isNull);
        expect(assignment.metadata, isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON map', () {
        final now = DateTime.parse('2024-01-15T10:30:00.000Z');
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
          createdAt: now,
          updatedAt: now,
          metadata: {'key': 'value'},
        );

        final json = assignment.toJson();

        expect(json['user_id'], equals('user123'));
        expect(json['role'], equals('player'));
        expect(json['ladder_id'], equals('ladder456'));
        expect(json['created_at'], equals('2024-01-15T10:30:00.000Z'));
        expect(json['updated_at'], equals('2024-01-15T10:30:00.000Z'));
        expect(json['metadata'], equals({'key': 'value'}));
      });

      test('handles null optional fields', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        final json = assignment.toJson();

        expect(json['user_id'], equals('user123'));
        expect(json['role'], equals('system_admin'));
        expect(json['ladder_id'], isNull);
        expect(json['created_at'], isNull);
        expect(json['updated_at'], isNull);
        expect(json['metadata'], isNull);
      });
    });

    group('helper properties', () {
      test('isGlobalRole returns true for assignments without ladder_id', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );
        expect(assignment.isGlobalRole, isTrue);
        expect(assignment.isLadderSpecific, isFalse);
      });

      test('isLadderSpecific returns true for assignments with ladder_id', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        expect(assignment.isGlobalRole, isFalse);
        expect(assignment.isLadderSpecific, isTrue);
      });
    });

    group('isValid', () {
      test('returns true for valid system admin assignment (no ladder)', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );
        expect(assignment.isValid(), isTrue);
      });

      test('returns false for system admin with ladder_id', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
          ladderId: 'ladder456',
        );
        expect(assignment.isValid(), isFalse);
      });

      test('returns true for valid organizer assignment (with ladder)', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder456',
        );
        expect(assignment.isValid(), isTrue);
      });

      test('returns false for organizer without ladder_id', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
        );
        expect(assignment.isValid(), isFalse);
      });

      test('returns true for valid player assignment (with ladder)', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        expect(assignment.isValid(), isTrue);
      });

      test('returns false for player without ladder_id', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
        );
        expect(assignment.isValid(), isFalse);
      });

      test('returns true for guest with or without ladder_id', () {
        final globalGuest = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.guest,
        );
        expect(globalGuest.isValid(), isTrue);

        final ladderGuest = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.guest,
          ladderId: 'ladder456',
        );
        expect(ladderGuest.isValid(), isTrue);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        final copy = original.copyWith(role: UserRole.organizer);

        expect(copy.userId, equals('user123'));
        expect(copy.role, equals(UserRole.organizer));
        expect(copy.ladderId, equals('ladder456'));
      });

      test('preserves unchanged fields', () {
        final now = DateTime.now();
        final original = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
          createdAt: now,
        );

        final copy = original.copyWith(role: UserRole.organizer);

        expect(copy.userId, equals(original.userId));
        expect(copy.ladderId, equals(original.ladderId));
        expect(copy.createdAt, equals(original.createdAt));
      });
    });

    group('equality', () {
      test('equal assignments are considered equal', () {
        final a1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final a2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        expect(a1, equals(a2));
        expect(a1.hashCode, equals(a2.hashCode));
      });

      test('different assignments are not equal', () {
        final a1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final a2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder789',
        );

        expect(a1, isNot(equals(a2)));
      });
    });

    group('toString', () {
      test('includes user id, role, and ladder info', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        final str = assignment.toString();
        expect(str, contains('user123'));
        expect(str, contains('player'));
        expect(str, contains('ladder456'));
      });

      test('indicates global role', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        final str = assignment.toString();
        expect(str, contains('Global'));
      });
    });
  });
}
