import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/activity_event.dart';
import 'package:nonna_app/core/enums/activity_event_type.dart';

void main() {
  group('ActivityEvent', () {
    final now = DateTime.now();
    final activityEvent = ActivityEvent(
      id: 'activity-123',
      babyProfileId: 'baby-profile-123',
      actorUserId: 'user-123',
      type: ActivityEventType.photoUploaded,
      payload: {'photo_id': 'photo-456'},
      createdAt: now,
    );

    group('fromJson', () {
      test('creates ActivityEvent from valid JSON', () {
        final json = {
          'id': 'activity-123',
          'baby_profile_id': 'baby-profile-123',
          'actor_user_id': 'user-123',
          'type': 'photoUploaded',
          'payload': {'photo_id': 'photo-456'},
          'created_at': now.toIso8601String(),
        };

        final result = ActivityEvent.fromJson(json);

        expect(result.id, 'activity-123');
        expect(result.babyProfileId, 'baby-profile-123');
        expect(result.actorUserId, 'user-123');
        expect(result.type, ActivityEventType.photoUploaded);
        expect(result.payload, {'photo_id': 'photo-456'});
        expect(result.createdAt, now);
      });

      test('handles payload as JSON string', () {
        final json = {
          'id': 'activity-123',
          'baby_profile_id': 'baby-profile-123',
          'actor_user_id': 'user-123',
          'type': 'commentAdded',
          'payload': '{"comment_id": "comment-789"}',
          'created_at': now.toIso8601String(),
        };

        final result = ActivityEvent.fromJson(json);

        expect(result.payload, {'comment_id': 'comment-789'});
      });

      test('handles null payload', () {
        final json = {
          'id': 'activity-123',
          'baby_profile_id': 'baby-profile-123',
          'actor_user_id': 'user-123',
          'type': 'memberJoined',
          'payload': null,
          'created_at': now.toIso8601String(),
        };

        final result = ActivityEvent.fromJson(json);

        expect(result.payload, null);
        expect(result.hasPayload, false);
      });
    });

    group('toJson', () {
      test('converts ActivityEvent to JSON', () {
        final json = activityEvent.toJson();

        expect(json['id'], 'activity-123');
        expect(json['baby_profile_id'], 'baby-profile-123');
        expect(json['actor_user_id'], 'user-123');
        expect(json['type'], 'photoUploaded');
        expect(json['payload'], {'photo_id': 'photo-456'});
        expect(json['created_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid activity event', () {
        expect(activityEvent.validate(), null);
      });

      test('returns error for empty baby profile ID', () {
        final invalid = activityEvent.copyWith(babyProfileId: '');
        expect(invalid.validate(), 'Baby profile ID is required');
      });

      test('returns error for whitespace-only baby profile ID', () {
        final invalid = activityEvent.copyWith(babyProfileId: '   ');
        expect(invalid.validate(), 'Baby profile ID is required');
      });

      test('returns error for empty actor user ID', () {
        final invalid = activityEvent.copyWith(actorUserId: '');
        expect(invalid.validate(), 'Actor user ID is required');
      });

      test('returns error for whitespace-only actor user ID', () {
        final invalid = activityEvent.copyWith(actorUserId: '   ');
        expect(invalid.validate(), 'Actor user ID is required');
      });
    });

    group('hasPayload', () {
      test('returns true when payload exists', () {
        expect(activityEvent.hasPayload, true);
      });

      test('returns false when payload is null', () {
        final noPayload = activityEvent.copyWith(payload: null);
        expect(noPayload.hasPayload, false);
      });

      test('returns false when payload is empty', () {
        final emptyPayload = activityEvent.copyWith(payload: {});
        expect(emptyPayload.hasPayload, false);
      });
    });

    group('displayMessage', () {
      test('returns description for photoUploaded', () {
        final event = activityEvent.copyWith(
          type: ActivityEventType.photoUploaded,
        );
        expect(
          event.displayMessage,
          'A new photo was uploaded to the gallery',
        );
      });

      test('returns description for commentAdded', () {
        final event = activityEvent.copyWith(
          type: ActivityEventType.commentAdded,
        );
        expect(event.displayMessage, 'A comment was added');
      });

      test('returns description for rsvpYes', () {
        final event = activityEvent.copyWith(type: ActivityEventType.rsvpYes);
        expect(event.displayMessage, 'Someone responded yes to an event');
      });

      test('returns description for itemPurchased', () {
        final event = activityEvent.copyWith(
          type: ActivityEventType.itemPurchased,
        );
        expect(event.displayMessage, 'A registry item was purchased');
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final copy = activityEvent.copyWith(
          type: ActivityEventType.commentAdded,
          payload: {'comment_id': 'comment-999'},
        );

        expect(copy.id, activityEvent.id);
        expect(copy.type, ActivityEventType.commentAdded);
        expect(copy.payload, {'comment_id': 'comment-999'});
        expect(copy.babyProfileId, activityEvent.babyProfileId);
      });
    });

    group('equality', () {
      test('two activity events with same values are equal', () {
        final event1 = ActivityEvent(
          id: 'activity-123',
          babyProfileId: 'baby-123',
          actorUserId: 'user-123',
          type: ActivityEventType.voteCast,
          createdAt: now,
        );

        final event2 = ActivityEvent(
          id: 'activity-123',
          babyProfileId: 'baby-123',
          actorUserId: 'user-123',
          type: ActivityEventType.voteCast,
          createdAt: now,
        );

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('two activity events with different values are not equal', () {
        final event1 = activityEvent;
        final event2 = activityEvent.copyWith(
          type: ActivityEventType.commentAdded,
        );

        expect(event1, isNot(equals(event2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = activityEvent.toString();

        expect(str, contains('ActivityEvent'));
        expect(str, contains('activity-123'));
        expect(str, contains('baby-profile-123'));
        expect(str, contains('user-123'));
        expect(str, contains('photoUploaded'));
      });
    });
  });
}
