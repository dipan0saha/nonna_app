import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/photo_comment.dart';

void main() {
  group('PhotoComment', () {
    final now = DateTime.now();
    final comment = PhotoComment(
      id: 'comment-123',
      photoId: 'photo-456',
      userId: 'user-789',
      body: 'Such a beautiful moment!',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates PhotoComment from valid JSON', () {
        final json = {
          'id': 'comment-123',
          'photo_id': 'photo-456',
          'user_id': 'user-789',
          'body': 'Such a beautiful moment!',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
          'deleted_by_user_id': null,
        };

        final result = PhotoComment.fromJson(json);

        expect(result.id, 'comment-123');
        expect(result.photoId, 'photo-456');
        expect(result.userId, 'user-789');
        expect(result.body, 'Such a beautiful moment!');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, null);
        expect(result.deletedByUserId, null);
      });

      test('handles deleted comment', () {
        final deletedAt = now.add(const Duration(hours: 1));
        final json = {
          'id': 'comment-123',
          'photo_id': 'photo-456',
          'user_id': 'user-789',
          'body': 'Such a beautiful moment!',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': deletedAt.toIso8601String(),
          'deleted_by_user_id': 'user-moderator',
        };

        final result = PhotoComment.fromJson(json);

        expect(result.deletedAt, deletedAt);
        expect(result.deletedByUserId, 'user-moderator');
      });
    });

    group('toJson', () {
      test('converts PhotoComment to JSON', () {
        final json = comment.toJson();

        expect(json['id'], 'comment-123');
        expect(json['photo_id'], 'photo-456');
        expect(json['user_id'], 'user-789');
        expect(json['body'], 'Such a beautiful moment!');
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
        expect(json['deleted_at'], null);
        expect(json['deleted_by_user_id'], null);
      });
    });

    group('validate', () {
      test('returns null for valid comment', () {
        expect(comment.validate(), null);
      });

      test('returns error for empty body', () {
        final invalidComment = comment.copyWith(body: '');
        expect(invalidComment.validate(), 'Comment body is required');
      });

      test('returns error for whitespace-only body', () {
        final invalidComment = comment.copyWith(body: '   ');
        expect(invalidComment.validate(), 'Comment body is required');
      });

      test('returns error for body exceeding 1000 characters', () {
        final invalidComment = comment.copyWith(body: 'a' * 1001);
        expect(
          invalidComment.validate(),
          'Comment body must be 1000 characters or less',
        );
      });

      test('returns error when deleted but no deletedByUserId', () {
        final invalidComment = comment.copyWith(
          deletedAt: now,
          deletedByUserId: null,
        );
        expect(
          invalidComment.validate(),
          'Deleted by user ID is required when comment is deleted',
        );
      });
    });

    group('getters', () {
      test('isDeleted returns false when deletedAt is null', () {
        expect(comment.isDeleted, false);
      });

      test('isDeleted returns true when deletedAt is set', () {
        final deletedComment = comment.copyWith(deletedAt: now);
        expect(deletedComment.isDeleted, true);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = comment.copyWith(
          body: 'Updated comment text',
          updatedAt: now.add(const Duration(hours: 1)),
        );

        expect(updated.id, comment.id);
        expect(updated.photoId, comment.photoId);
        expect(updated.userId, comment.userId);
        expect(updated.body, 'Updated comment text');
        expect(updated.createdAt, comment.createdAt);
        expect(updated.updatedAt, now.add(const Duration(hours: 1)));
      });

      test('maintains original values when no updates provided', () {
        final copy = comment.copyWith();
        expect(copy, comment);
      });
    });

    group('equality', () {
      test('equal comments are equal', () {
        final comment1 = PhotoComment(
          id: 'comment-123',
          photoId: 'photo-456',
          userId: 'user-789',
          body: 'Such a beautiful moment!',
          createdAt: now,
          updatedAt: now,
        );
        final comment2 = PhotoComment(
          id: 'comment-123',
          photoId: 'photo-456',
          userId: 'user-789',
          body: 'Such a beautiful moment!',
          createdAt: now,
          updatedAt: now,
        );

        expect(comment1, comment2);
        expect(comment1.hashCode, comment2.hashCode);
      });

      test('different comments are not equal', () {
        final comment1 = PhotoComment(
          id: 'comment-123',
          photoId: 'photo-456',
          userId: 'user-789',
          body: 'Such a beautiful moment!',
          createdAt: now,
          updatedAt: now,
        );
        final comment2 = PhotoComment(
          id: 'comment-456',
          photoId: 'photo-789',
          userId: 'user-123',
          body: 'Different comment',
          createdAt: now,
          updatedAt: now,
        );

        expect(comment1, isNot(comment2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = comment.toString();

        expect(str, contains('PhotoComment'));
        expect(str, contains('comment-123'));
        expect(str, contains('photo-456'));
        expect(str, contains('user-789'));
      });
    });
  });
}
