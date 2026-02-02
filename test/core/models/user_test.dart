import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/user.dart';

void main() {
  group('User', () {
    final now = DateTime.now();
    final user = User(
      userId: 'user-123',
      displayName: 'John Doe',
      avatarUrl: 'https://example.com/avatar.jpg',
      biometricEnabled: true,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates User from valid JSON', () {
        final json = {
          'user_id': 'user-123',
          'display_name': 'John Doe',
          'avatar_url': 'https://example.com/avatar.jpg',
          'biometric_enabled': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = User.fromJson(json);

        expect(result.userId, 'user-123');
        expect(result.displayName, 'John Doe');
        expect(result.avatarUrl, 'https://example.com/avatar.jpg');
        expect(result.biometricEnabled, true);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('handles null avatarUrl', () {
        final json = {
          'user_id': 'user-123',
          'display_name': 'John Doe',
          'avatar_url': null,
          'biometric_enabled': false,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = User.fromJson(json);

        expect(result.avatarUrl, null);
      });

      test('defaults biometric_enabled to false when missing', () {
        final json = {
          'user_id': 'user-123',
          'display_name': 'John Doe',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = User.fromJson(json);

        expect(result.biometricEnabled, false);
      });
    });

    group('toJson', () {
      test('converts User to JSON', () {
        final json = user.toJson();

        expect(json['user_id'], 'user-123');
        expect(json['display_name'], 'John Doe');
        expect(json['avatar_url'], 'https://example.com/avatar.jpg');
        expect(json['biometric_enabled'], true);
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid user', () {
        expect(user.validate(), null);
      });

      test('returns error for empty display name', () {
        final invalidUser = user.copyWith(displayName: '');
        expect(invalidUser.validate(), 'Display name is required');
      });

      test('returns error for whitespace-only display name', () {
        final invalidUser = user.copyWith(displayName: '   ');
        expect(invalidUser.validate(), 'Display name is required');
      });

      test('returns error for display name exceeding 100 characters', () {
        final invalidUser = user.copyWith(displayName: 'a' * 101);
        expect(
          invalidUser.validate(),
          'Display name must be 100 characters or less',
        );
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = user.copyWith(
          displayName: 'Jane Doe',
          biometricEnabled: false,
        );

        expect(updated.userId, user.userId);
        expect(updated.displayName, 'Jane Doe');
        expect(updated.biometricEnabled, false);
        expect(updated.avatarUrl, user.avatarUrl);
      });

      test('maintains original values when no updates provided', () {
        final copy = user.copyWith();

        expect(copy, user);
      });
    });

    group('equality', () {
      test('equal users are equal', () {
        final user1 = User(
          userId: 'user-123',
          displayName: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          biometricEnabled: true,
          createdAt: now,
          updatedAt: now,
        );
        final user2 = User(
          userId: 'user-123',
          displayName: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          biometricEnabled: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(user1, user2);
        expect(user1.hashCode, user2.hashCode);
      });

      test('different users are not equal', () {
        final user1 = User(
          userId: 'user-123',
          displayName: 'John Doe',
          createdAt: now,
          updatedAt: now,
        );
        final user2 = User(
          userId: 'user-456',
          displayName: 'Jane Doe',
          createdAt: now,
          updatedAt: now,
        );

        expect(user1, isNot(user2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = user.toString();

        expect(str, contains('User'));
        expect(str, contains('user-123'));
        expect(str, contains('John Doe'));
      });
    });
  });
}
