import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';

void main() {
  group('BabyMembership', () {
    final now = DateTime.now();

    final membership = BabyMembership(
      babyProfileId: 'baby-123',
      userId: 'user-456',
      role: UserRole.owner,
      relationshipLabel: 'Mother',
      createdAt: now,
    );

    group('fromJson', () {
      test('creates BabyMembership from valid JSON', () {
        final json = {
          'baby_profile_id': 'baby-123',
          'user_id': 'user-456',
          'role': 'owner',
          'relationship_label': 'Mother',
          'created_at': now.toIso8601String(),
          'removed_at': null,
        };

        final result = BabyMembership.fromJson(json);

        expect(result.babyProfileId, 'baby-123');
        expect(result.userId, 'user-456');
        expect(result.role, UserRole.owner);
        expect(result.relationshipLabel, 'Mother');
        expect(result.createdAt, now);
        expect(result.removedAt, null);
      });

      test('handles null relationship label', () {
        final json = {
          'baby_profile_id': 'baby-123',
          'user_id': 'user-456',
          'role': 'follower',
          'created_at': now.toIso8601String(),
        };

        final result = BabyMembership.fromJson(json);

        expect(result.relationshipLabel, null);
      });

      test('handles removed_at timestamp', () {
        final removedAt = DateTime.now();
        final json = {
          'baby_profile_id': 'baby-123',
          'user_id': 'user-456',
          'role': 'follower',
          'created_at': now.toIso8601String(),
          'removed_at': removedAt.toIso8601String(),
        };

        final result = BabyMembership.fromJson(json);

        expect(result.removedAt, removedAt);
      });
    });

    group('toJson', () {
      test('converts BabyMembership to JSON', () {
        final json = membership.toJson();

        expect(json['baby_profile_id'], 'baby-123');
        expect(json['user_id'], 'user-456');
        expect(json['role'], 'owner');
        expect(json['relationship_label'], 'Mother');
        expect(json['created_at'], now.toIso8601String());
        expect(json['removed_at'], null);
      });
    });

    group('validate', () {
      test('returns null for valid membership', () {
        expect(membership.validate(), null);
      });

      test('returns error for relationship label exceeding 50 characters', () {
        final invalid = membership.copyWith(
          relationshipLabel: 'a' * 51,
        );
        expect(
          invalid.validate(),
          'Relationship label must be 50 characters or less',
        );
      });

      test('returns null for null relationship label', () {
        final valid = membership.copyWith(relationshipLabel: null);
        expect(valid.validate(), null);
      });
    });

    group('isActive', () {
      test('returns true when removedAt is null', () {
        expect(membership.isActive, true);
      });

      test('returns false when removedAt is set', () {
        final removed = membership.copyWith(removedAt: DateTime.now());
        expect(removed.isActive, false);
      });
    });

    group('isRemoved', () {
      test('returns false when removedAt is null', () {
        expect(membership.isRemoved, false);
      });

      test('returns true when removedAt is set', () {
        final removed = membership.copyWith(removedAt: DateTime.now());
        expect(removed.isRemoved, true);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = membership.copyWith(
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
        );

        expect(updated.babyProfileId, membership.babyProfileId);
        expect(updated.userId, membership.userId);
        expect(updated.role, UserRole.follower);
        expect(updated.relationshipLabel, 'Aunt');
      });
    });

    group('equality', () {
      test('equal memberships are equal', () {
        final membership1 = BabyMembership(
          babyProfileId: 'baby-123',
          userId: 'user-456',
          role: UserRole.owner,
          relationshipLabel: 'Mother',
          createdAt: now,
        );
        final membership2 = BabyMembership(
          babyProfileId: 'baby-123',
          userId: 'user-456',
          role: UserRole.owner,
          relationshipLabel: 'Mother',
          createdAt: now,
        );

        expect(membership1, membership2);
        expect(membership1.hashCode, membership2.hashCode);
      });

      test('different memberships are not equal', () {
        final membership1 = BabyMembership(
          babyProfileId: 'baby-123',
          userId: 'user-456',
          role: UserRole.owner,
          createdAt: now,
        );
        final membership2 = BabyMembership(
          babyProfileId: 'baby-123',
          userId: 'user-789',
          role: UserRole.follower,
          createdAt: now,
        );

        expect(membership1, isNot(membership2));
      });
    });
  });
}
