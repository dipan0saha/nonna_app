import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/notification.dart';
import 'package:nonna_app/core/enums/notification_type.dart';

void main() {
  group('Notification', () {
    final now = DateTime.now();
    final notification = Notification(
      id: 'notif-123',
      recipientUserId: 'user-123',
      babyProfileId: 'baby-profile-123',
      type: NotificationType.photo,
      title: 'New Photo',
      body: 'A new photo was uploaded to the gallery',
      payload: {'photo_id': 'photo-456'},
      createdAt: now,
    );

    group('fromJson', () {
      test('creates Notification from valid JSON', () {
        final json = {
          'id': 'notif-123',
          'recipient_user_id': 'user-123',
          'baby_profile_id': 'baby-profile-123',
          'type': 'photo',
          'title': 'New Photo',
          'body': 'A new photo was uploaded to the gallery',
          'payload': {'photo_id': 'photo-456'},
          'read_at': null,
          'created_at': now.toIso8601String(),
        };

        final result = Notification.fromJson(json);

        expect(result.id, 'notif-123');
        expect(result.recipientUserId, 'user-123');
        expect(result.babyProfileId, 'baby-profile-123');
        expect(result.type, NotificationType.photo);
        expect(result.title, 'New Photo');
        expect(result.body, 'A new photo was uploaded to the gallery');
        expect(result.payload, {'photo_id': 'photo-456'});
        expect(result.readAt, null);
        expect(result.createdAt, now);
      });

      test('handles payload as JSON string', () {
        final json = {
          'id': 'notif-123',
          'recipient_user_id': 'user-123',
          'type': 'event',
          'title': 'Event Reminder',
          'body': 'Event is coming up',
          'payload': '{"event_id": "event-789"}',
          'created_at': now.toIso8601String(),
        };

        final result = Notification.fromJson(json);

        expect(result.payload, {'event_id': 'event-789'});
      });

      test('handles null payload', () {
        final json = {
          'id': 'notif-123',
          'recipient_user_id': 'user-123',
          'type': 'system',
          'title': 'System Notice',
          'body': 'System message',
          'payload': null,
          'created_at': now.toIso8601String(),
        };

        final result = Notification.fromJson(json);

        expect(result.payload, null);
        expect(result.hasPayload, false);
      });

      test('handles readAt timestamp', () {
        final readAt = DateTime.now().subtract(const Duration(hours: 1));
        final json = {
          'id': 'notif-123',
          'recipient_user_id': 'user-123',
          'type': 'comment',
          'title': 'New Comment',
          'body': 'Someone commented on your photo',
          'read_at': readAt.toIso8601String(),
          'created_at': now.toIso8601String(),
        };

        final result = Notification.fromJson(json);

        expect(result.readAt, readAt);
        expect(result.isRead, true);
      });

      test('handles null baby_profile_id', () {
        final json = {
          'id': 'notif-123',
          'recipient_user_id': 'user-123',
          'baby_profile_id': null,
          'type': 'system',
          'title': 'System Message',
          'body': 'General system notification',
          'created_at': now.toIso8601String(),
        };

        final result = Notification.fromJson(json);

        expect(result.babyProfileId, null);
      });
    });

    group('toJson', () {
      test('converts Notification to JSON', () {
        final json = notification.toJson();

        expect(json['id'], 'notif-123');
        expect(json['recipient_user_id'], 'user-123');
        expect(json['baby_profile_id'], 'baby-profile-123');
        expect(json['type'], 'photo');
        expect(json['title'], 'New Photo');
        expect(json['body'], 'A new photo was uploaded to the gallery');
        expect(json['payload'], {'photo_id': 'photo-456'});
        expect(json['read_at'], null);
        expect(json['created_at'], now.toIso8601String());
      });

      test('includes readAt when present', () {
        final readAt = DateTime.now();
        final read = notification.markAsRead(readAt);
        final json = read.toJson();

        expect(json['read_at'], readAt.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid notification', () {
        expect(notification.validate(), null);
      });

      test('returns error for empty title', () {
        final invalid = notification.copyWith(title: '');
        expect(invalid.validate(), 'Notification title is required');
      });

      test('returns error for whitespace-only title', () {
        final invalid = notification.copyWith(title: '   ');
        expect(invalid.validate(), 'Notification title is required');
      });

      test('returns error for title exceeding 100 characters', () {
        final invalid = notification.copyWith(title: 'a' * 101);
        expect(
          invalid.validate(),
          'Notification title must be 100 characters or less',
        );
      });

      test('returns error for empty body', () {
        final invalid = notification.copyWith(body: '');
        expect(invalid.validate(), 'Notification body is required');
      });

      test('returns error for whitespace-only body', () {
        final invalid = notification.copyWith(body: '   ');
        expect(invalid.validate(), 'Notification body is required');
      });

      test('returns error for body exceeding 500 characters', () {
        final invalid = notification.copyWith(body: 'a' * 501);
        expect(
          invalid.validate(),
          'Notification body must be 500 characters or less',
        );
      });
    });

    group('isRead', () {
      test('returns false when readAt is null', () {
        expect(notification.isRead, false);
      });

      test('returns true when readAt is set', () {
        final read = notification.markAsRead();
        expect(read.isRead, true);
      });
    });

    group('isUnread', () {
      test('returns true when readAt is null', () {
        expect(notification.isUnread, true);
      });

      test('returns false when readAt is set', () {
        final read = notification.markAsRead();
        expect(read.isUnread, false);
      });
    });

    group('hasPayload', () {
      test('returns true when payload exists', () {
        expect(notification.hasPayload, true);
      });

      test('returns false when payload is null', () {
        final noPayload = notification.copyWith(payload: null);
        expect(noPayload.hasPayload, false);
      });

      test('returns false when payload is empty', () {
        final emptyPayload = notification.copyWith(payload: {});
        expect(emptyPayload.hasPayload, false);
      });
    });

    group('markAsRead', () {
      test('sets readAt timestamp', () {
        final read = notification.markAsRead();

        expect(read.readAt, isNotNull);
        expect(read.isRead, true);
      });

      test('uses provided timestamp', () {
        final timestamp = DateTime.now().subtract(const Duration(hours: 2));
        final read = notification.markAsRead(timestamp);

        expect(read.readAt, timestamp);
      });
    });

    group('markAsUnread', () {
      test('clears readAt timestamp', () {
        final read = notification.markAsRead();
        final unread = read.markAsUnread();

        expect(unread.readAt, null);
        expect(unread.isUnread, true);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final copy = notification.copyWith(
          title: 'Updated Title',
          type: NotificationType.comment,
        );

        expect(copy.id, notification.id);
        expect(copy.title, 'Updated Title');
        expect(copy.type, NotificationType.comment);
        expect(copy.body, notification.body);
      });
    });

    group('equality', () {
      test('two notifications with same values are equal', () {
        final notif1 = Notification(
          id: 'notif-123',
          recipientUserId: 'user-123',
          type: NotificationType.like,
          title: 'New Like',
          body: 'Someone liked your photo',
          createdAt: now,
        );

        final notif2 = Notification(
          id: 'notif-123',
          recipientUserId: 'user-123',
          type: NotificationType.like,
          title: 'New Like',
          body: 'Someone liked your photo',
          createdAt: now,
        );

        expect(notif1, equals(notif2));
        expect(notif1.hashCode, equals(notif2.hashCode));
      });

      test('two notifications with different values are not equal', () {
        final notif1 = notification;
        final notif2 = notification.copyWith(title: 'Different Title');

        expect(notif1, isNot(equals(notif2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = notification.toString();

        expect(str, contains('Notification'));
        expect(str, contains('notif-123'));
        expect(str, contains('user-123'));
        expect(str, contains('photo'));
        expect(str, contains('New Photo'));
      });
    });
  });
}
