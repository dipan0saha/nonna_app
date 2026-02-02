import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/event.dart';

void main() {
  group('Event', () {
    final now = DateTime.now();
    final startsAt = now.add(const Duration(days: 1));
    final endsAt = startsAt.add(const Duration(hours: 2));
    final event = Event(
      id: 'event-123',
      babyProfileId: 'baby-456',
      createdByUserId: 'user-789',
      title: 'Baby Shower',
      startsAt: startsAt,
      endsAt: endsAt,
      description: 'A wonderful celebration',
      location: '123 Main St',
      videoLink: 'https://zoom.us/j/123456',
      coverPhotoUrl: 'https://example.com/photo.jpg',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates Event from valid JSON', () {
        final json = {
          'id': 'event-123',
          'baby_profile_id': 'baby-456',
          'created_by_user_id': 'user-789',
          'title': 'Baby Shower',
          'starts_at': startsAt.toIso8601String(),
          'ends_at': endsAt.toIso8601String(),
          'description': 'A wonderful celebration',
          'location': '123 Main St',
          'video_link': 'https://zoom.us/j/123456',
          'cover_photo_url': 'https://example.com/photo.jpg',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        };

        final result = Event.fromJson(json);

        expect(result.id, 'event-123');
        expect(result.babyProfileId, 'baby-456');
        expect(result.createdByUserId, 'user-789');
        expect(result.title, 'Baby Shower');
        expect(result.startsAt, startsAt);
        expect(result.endsAt, endsAt);
        expect(result.description, 'A wonderful celebration');
        expect(result.location, '123 Main St');
        expect(result.videoLink, 'https://zoom.us/j/123456');
        expect(result.coverPhotoUrl, 'https://example.com/photo.jpg');
        expect(result.deletedAt, null);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'event-123',
          'baby_profile_id': 'baby-456',
          'created_by_user_id': 'user-789',
          'title': 'Baby Shower',
          'starts_at': startsAt.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Event.fromJson(json);

        expect(result.endsAt, null);
        expect(result.description, null);
        expect(result.location, null);
        expect(result.videoLink, null);
        expect(result.coverPhotoUrl, null);
        expect(result.deletedAt, null);
      });
    });

    group('toJson', () {
      test('converts Event to JSON', () {
        final json = event.toJson();

        expect(json['id'], 'event-123');
        expect(json['baby_profile_id'], 'baby-456');
        expect(json['created_by_user_id'], 'user-789');
        expect(json['title'], 'Baby Shower');
        expect(json['starts_at'], startsAt.toIso8601String());
        expect(json['ends_at'], endsAt.toIso8601String());
        expect(json['description'], 'A wonderful celebration');
        expect(json['location'], '123 Main St');
        expect(json['video_link'], 'https://zoom.us/j/123456');
        expect(json['cover_photo_url'], 'https://example.com/photo.jpg');
      });
    });

    group('validate', () {
      test('returns null for valid event', () {
        expect(event.validate(), null);
      });

      test('returns error for empty title', () {
        final invalidEvent = event.copyWith(title: '');
        expect(invalidEvent.validate(), 'Event title is required');
      });

      test('returns error for whitespace-only title', () {
        final invalidEvent = event.copyWith(title: '   ');
        expect(invalidEvent.validate(), 'Event title is required');
      });

      test('returns error for title exceeding 200 characters', () {
        final invalidEvent = event.copyWith(title: 'a' * 201);
        expect(
          invalidEvent.validate(),
          'Event title must be 200 characters or less',
        );
      });

      test('returns error when end time is before start time', () {
        final invalidEvent = event.copyWith(
          startsAt: now.add(const Duration(days: 1)),
          endsAt: now,
        );
        expect(
          invalidEvent.validate(),
          'Event end time must be after start time',
        );
      });

      test('returns error for event more than a year in the past', () {
        final invalidEvent = event.copyWith(
          startsAt: now.subtract(const Duration(days: 366)),
        );
        expect(
          invalidEvent.validate(),
          'Event start time cannot be more than a year in the past',
        );
      });

      test('returns error for description exceeding 2000 characters', () {
        final invalidEvent = event.copyWith(description: 'a' * 2001);
        expect(
          invalidEvent.validate(),
          'Event description must be 2000 characters or less',
        );
      });

      test('returns error for location exceeding 500 characters', () {
        final invalidEvent = event.copyWith(location: 'a' * 501);
        expect(
          invalidEvent.validate(),
          'Event location must be 500 characters or less',
        );
      });
    });

    group('getters', () {
      test('isDeleted returns false when deletedAt is null', () {
        expect(event.isDeleted, false);
      });

      test('isDeleted returns true when deletedAt is set', () {
        final deletedEvent = event.copyWith(deletedAt: now);
        expect(deletedEvent.isDeleted, true);
      });

      test('hasEnded returns true for past events', () {
        final pastEvent = event.copyWith(
          startsAt: now.subtract(const Duration(days: 1)),
          endsAt: now.subtract(const Duration(hours: 1)),
        );
        expect(pastEvent.hasEnded, true);
      });

      test('hasEnded returns false for future events', () {
        expect(event.hasEnded, false);
      });

      test('isOngoing returns true for current events', () {
        final ongoingEvent = event.copyWith(
          startsAt: now.subtract(const Duration(hours: 1)),
          endsAt: now.add(const Duration(hours: 1)),
        );
        expect(ongoingEvent.isOngoing, true);
      });

      test('isOngoing returns false for future events', () {
        expect(event.isOngoing, false);
      });

      test('isUpcoming returns true for future events', () {
        expect(event.isUpcoming, true);
      });

      test('isUpcoming returns false for past events', () {
        final pastEvent = event.copyWith(
          startsAt: now.subtract(const Duration(days: 1)),
        );
        expect(pastEvent.isUpcoming, false);
      });

      test('duration returns correct duration when endsAt is set', () {
        expect(event.duration, const Duration(hours: 2));
      });

      test('duration returns null when endsAt is not set', () {
        final eventWithoutEnd = Event(
          id: event.id,
          babyProfileId: event.babyProfileId,
          createdByUserId: event.createdByUserId,
          title: event.title,
          startsAt: event.startsAt,
          endsAt: null,
          createdAt: event.createdAt,
          updatedAt: event.updatedAt,
        );
        expect(eventWithoutEnd.duration, null);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = event.copyWith(
          title: 'Gender Reveal',
          location: '456 Oak Ave',
        );

        expect(updated.id, event.id);
        expect(updated.title, 'Gender Reveal');
        expect(updated.location, '456 Oak Ave');
        expect(updated.startsAt, event.startsAt);
      });

      test('maintains original values when no updates provided', () {
        final copy = event.copyWith();
        expect(copy, event);
      });
    });

    group('equality', () {
      test('equal events are equal', () {
        final event1 = Event(
          id: 'event-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          title: 'Baby Shower',
          startsAt: startsAt,
          endsAt: endsAt,
          createdAt: now,
          updatedAt: now,
        );
        final event2 = Event(
          id: 'event-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          title: 'Baby Shower',
          startsAt: startsAt,
          endsAt: endsAt,
          createdAt: now,
          updatedAt: now,
        );

        expect(event1, event2);
        expect(event1.hashCode, event2.hashCode);
      });

      test('different events are not equal', () {
        final event1 = Event(
          id: 'event-123',
          babyProfileId: 'baby-456',
          createdByUserId: 'user-789',
          title: 'Baby Shower',
          startsAt: startsAt,
          createdAt: now,
          updatedAt: now,
        );
        final event2 = Event(
          id: 'event-456',
          babyProfileId: 'baby-789',
          createdByUserId: 'user-123',
          title: 'Gender Reveal',
          startsAt: startsAt,
          createdAt: now,
          updatedAt: now,
        );

        expect(event1, isNot(event2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = event.toString();

        expect(str, contains('Event'));
        expect(str, contains('event-123'));
        expect(str, contains('Baby Shower'));
      });
    });
  });
}
