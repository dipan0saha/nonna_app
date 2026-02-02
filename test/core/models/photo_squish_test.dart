import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/photo_squish.dart';

void main() {
  group('PhotoSquish', () {
    final now = DateTime.now();
    final squish = PhotoSquish(
      id: 'squish-123',
      photoId: 'photo-456',
      userId: 'user-789',
      createdAt: now,
    );

    group('fromJson', () {
      test('creates PhotoSquish from valid JSON', () {
        final json = {
          'id': 'squish-123',
          'photo_id': 'photo-456',
          'user_id': 'user-789',
          'created_at': now.toIso8601String(),
        };

        final result = PhotoSquish.fromJson(json);

        expect(result.id, 'squish-123');
        expect(result.photoId, 'photo-456');
        expect(result.userId, 'user-789');
        expect(result.createdAt, now);
      });
    });

    group('toJson', () {
      test('converts PhotoSquish to JSON', () {
        final json = squish.toJson();

        expect(json['id'], 'squish-123');
        expect(json['photo_id'], 'photo-456');
        expect(json['user_id'], 'user-789');
        expect(json['created_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid squish', () {
        expect(squish.validate(), null);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = squish.copyWith(
          photoId: 'photo-new',
        );

        expect(updated.id, squish.id);
        expect(updated.photoId, 'photo-new');
        expect(updated.userId, squish.userId);
        expect(updated.createdAt, squish.createdAt);
      });

      test('maintains original values when no updates provided', () {
        final copy = squish.copyWith();
        expect(copy, squish);
      });
    });

    group('equality', () {
      test('equal squishes are equal', () {
        final squish1 = PhotoSquish(
          id: 'squish-123',
          photoId: 'photo-456',
          userId: 'user-789',
          createdAt: now,
        );
        final squish2 = PhotoSquish(
          id: 'squish-123',
          photoId: 'photo-456',
          userId: 'user-789',
          createdAt: now,
        );

        expect(squish1, squish2);
        expect(squish1.hashCode, squish2.hashCode);
      });

      test('different squishes are not equal', () {
        final squish1 = PhotoSquish(
          id: 'squish-123',
          photoId: 'photo-456',
          userId: 'user-789',
          createdAt: now,
        );
        final squish2 = PhotoSquish(
          id: 'squish-456',
          photoId: 'photo-789',
          userId: 'user-123',
          createdAt: now,
        );

        expect(squish1, isNot(squish2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = squish.toString();

        expect(str, contains('PhotoSquish'));
        expect(str, contains('squish-123'));
        expect(str, contains('photo-456'));
        expect(str, contains('user-789'));
      });
    });
  });
}
