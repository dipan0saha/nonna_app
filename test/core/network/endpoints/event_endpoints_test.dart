import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/event_endpoints.dart';

void main() {
  group('EventEndpoints', () {
    const testBabyProfileId = 'baby_123';
    const testEventId = 'event_456';
    const testUserId = 'user_789';
    const testCommentId = 'comment_101';
    const testCurrentDate = '2024-06-15T00:00:00.000Z';
    const testStartDate = '2024-01-01T00:00:00.000Z';
    const testEndDate = '2024-12-31T23:59:59.999Z';

    group('Event CRUD Operations', () {
      test('generates correct getEvents endpoint', () {
        final endpoint = EventEndpoints.getEvents(testBabyProfileId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=starts_at.asc'));
      });

      test('generates correct getEvent endpoint', () {
        final endpoint = EventEndpoints.getEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getUpcomingEvents endpoint', () {
        final endpoint =
            EventEndpoints.getUpcomingEvents(testBabyProfileId, testCurrentDate);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('starts_at=gte.$testCurrentDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.asc'));
      });

      test('generates correct getPastEvents endpoint', () {
        final endpoint =
            EventEndpoints.getPastEvents(testBabyProfileId, testCurrentDate);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('starts_at=lt.$testCurrentDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.desc'));
      });

      test('generates correct createEvent endpoint', () {
        final endpoint = EventEndpoints.createEvent();

        expect(endpoint, equals('events'));
      });

      test('generates correct updateEvent endpoint', () {
        final endpoint = EventEndpoints.updateEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
      });

      test('generates correct deleteEvent endpoint', () {
        final endpoint = EventEndpoints.deleteEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
      });
    });

    group('RSVP Operations', () {
      test('generates correct getRsvps endpoint', () {
        final endpoint = EventEndpoints.getRsvps(testEventId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getUserRsvp endpoint', () {
        final endpoint = EventEndpoints.getUserRsvp(testEventId, testUserId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('user_id=eq.$testUserId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct upsertRsvp endpoint', () {
        final endpoint = EventEndpoints.upsertRsvp();

        expect(endpoint, equals('event_rsvps'));
      });

      test('generates correct getRsvpCounts endpoint', () {
        final endpoint = EventEndpoints.getRsvpCounts(testEventId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('select=status'));
      });
    });

    group('Event Comments', () {
      test('generates correct getEventComments endpoint', () {
        final endpoint = EventEndpoints.getEventComments(testEventId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('select=*'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('generates correct createEventComment endpoint', () {
        final endpoint = EventEndpoints.createEventComment();

        expect(endpoint, equals('event_comments'));
      });

      test('generates correct updateEventComment endpoint', () {
        final endpoint = EventEndpoints.updateEventComment(testCommentId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });

      test('generates correct deleteEventComment endpoint', () {
        final endpoint = EventEndpoints.deleteEventComment(testCommentId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });
    });

    group('Event Search & Filter', () {
      test('generates correct searchEvents endpoint', () {
        const searchTerm = 'baby shower';
        final endpoint = EventEndpoints.searchEvents(testBabyProfileId, searchTerm);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('title=ilike.'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('select=*'));
      });

      test('encodes special characters in search term', () {
        const searchTerm = 'test & special chars!';
        final endpoint = EventEndpoints.searchEvents(testBabyProfileId, searchTerm);

        expect(endpoint, contains('title=ilike.'));
        // Should be URL encoded
        expect(endpoint, isNot(contains('&')));
      });

      test('generates correct getEventsByDateRange endpoint', () {
        final endpoint = EventEndpoints.getEventsByDateRange(
          testBabyProfileId,
          testStartDate,
          testEndDate,
        );

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('starts_at=gte.$testStartDate'));
        expect(endpoint, contains('starts_at=lte.$testEndDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.asc'));
      });

      test('generates correct getEventsByCreator endpoint', () {
        final endpoint = EventEndpoints.getEventsByCreator(testBabyProfileId, testUserId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('created_by_user_id=eq.$testUserId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });
    });

    group('Helper Methods', () {
      test('generates correct getEventsWithPagination endpoint with defaults', () {
        final endpoint = EventEndpoints.getEventsWithPagination(testBabyProfileId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.desc'));
        expect(endpoint, contains('limit=10'));
        expect(endpoint, contains('offset=0'));
      });

      test('generates correct getEventsWithPagination endpoint with custom values', () {
        final endpoint = EventEndpoints.getEventsWithPagination(
          testBabyProfileId,
          limit: 25,
          offset: 50,
        );

        expect(endpoint, contains('limit=25'));
        expect(endpoint, contains('offset=50'));
      });
    });
  });
}
