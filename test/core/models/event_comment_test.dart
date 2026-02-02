import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/event_comment.dart';

void main() {
  group('EventComment', () {
    final now = DateTime.now();
    final comment = EventComment(
      id: 'comment-123',
      eventId: 'event-456',
      userId: 'user-789',
      body: 'Looking forward to this event!',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates EventComment from valid JSON', () {
        final json = {
          'id': 'comment-123',
          'event_id': 'event-456',
          'user_id': 'user-789',
          'body': 'Looking forward to this event!',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
          'deleted_by_user_id': null,
        };

        final result = EventComment.fromJson(json);

        expect(result.id, 'comment-123');
        expect(result.eventId, 'event-456');
        expect(result.userId, 'user-789');
        expect(result.body, 'Looking forward to this event!');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, null);
        expect(result.deletedByUserId, null);
      });

      test('handles deleted comment', () {
        final deletedAt = now.add(const Duration(hours: 1));
        final json = {
          'id': 'comment-123',
          'event_id': 'event-456',
          'user_id': 'user-789',
          'body': 'Looking forward to this event!',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': deletedAt.toIso8601String(),
          'deleted_by_user_id': 'user-moderator',
        };

        final result = EventComment.fromJson(json);

        expect(result.deletedAt, deletedAt);
        expect(result.deletedByUserId, 'user-moderator');
      });
    });

    group('toJson', () {
      test('converts EventComment to JSON', () {
        final json = comment.toJson();

        expect(json['id'], 'comment-123');
        expect(json['event_id'], 'event-456');
        expect(json['user_id'], 'user-789');
        expect(json['body'], 'Looking forward to this event!');
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
        expect(updated.eventId, comment.eventId);
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
        final comment1 = EventComment(
          id: 'comment-123',
          eventId: 'event-456',
          userId: 'user-789',
          body: 'Looking forward to this event!',
          createdAt: now,
          updatedAt: now,
        );
        final comment2 = EventComment(
          id: 'comment-123',
          eventId: 'event-456',
          userId: 'user-789',
          body: 'Looking forward to this event!',
          createdAt: now,
          updatedAt: now,
        );

        expect(comment1, comment2);
        expect(comment1.hashCode, comment2.hashCode);
      });

      test('different comments are not equal', () {
        final comment1 = EventComment(
          id: 'comment-123',
          eventId: 'event-456',
          userId: 'user-789',
          body: 'Looking forward to this event!',
          createdAt: now,
          updatedAt: now,
        );
        final comment2 = EventComment(
          id: 'comment-456',
          eventId: 'event-789',
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

        expect(str, contains('EventComment'));
        expect(str, contains('comment-123'));
        expect(str, contains('event-456'));
        expect(str, contains('user-789'));
      });
    });
  });
}
