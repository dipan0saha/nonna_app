import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/event_endpoints.dart';

void main() {
  group('EventEndpoints', () {
    const testBabyProfileId = 'baby-123';
    const testEventId = 'event-456';
    const testUserId = 'user-789';
    const testCommentId = 'comment-101';
    const testCurrentDate = '2024-01-01T00:00:00Z';
    const testStartDate = '2024-01-01T00:00:00Z';
    const testEndDate = '2024-12-31T23:59:59Z';

    group('Event CRUD Operations', () {
      test('getEvents returns correct endpoint', () {
        final endpoint = EventEndpoints.getEvents(testBabyProfileId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.asc'));
      });

      test('getEvent returns correct endpoint', () {
        final endpoint = EventEndpoints.getEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
      });

      test('getUpcomingEvents returns correct endpoint', () {
        final endpoint =
            EventEndpoints.getUpcomingEvents(testBabyProfileId, testCurrentDate);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('starts_at=gte.$testCurrentDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.asc'));
      });

      test('getPastEvents returns correct endpoint', () {
        final endpoint =
            EventEndpoints.getPastEvents(testBabyProfileId, testCurrentDate);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('starts_at=lt.$testCurrentDate'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=starts_at.desc'));
      });

      test('createEvent returns correct endpoint', () {
        final endpoint = EventEndpoints.createEvent();

        expect(endpoint, equals('events'));
      });

      test('updateEvent returns correct endpoint', () {
        final endpoint = EventEndpoints.updateEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
      });

      test('deleteEvent returns correct endpoint', () {
        final endpoint = EventEndpoints.deleteEvent(testEventId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('id=eq.$testEventId'));
      });
    });

    group('RSVP Operations', () {
      test('getRsvps returns correct endpoint', () {
        final endpoint = EventEndpoints.getRsvps(testEventId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
      });

      test('getUserRsvp returns correct endpoint', () {
        final endpoint = EventEndpoints.getUserRsvp(testEventId, testUserId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('user_id=eq.$testUserId'));
      });

      test('upsertRsvp returns correct endpoint', () {
        final endpoint = EventEndpoints.upsertRsvp();

        expect(endpoint, equals('event_rsvps'));
      });

      test('getRsvpCounts returns correct endpoint', () {
        final endpoint = EventEndpoints.getRsvpCounts(testEventId);

        expect(endpoint, contains('event_rsvps'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('select=status'));
      });
    });

    group('Event Comments', () {
      test('getEventComments returns correct endpoint', () {
        final endpoint = EventEndpoints.getEventComments(testEventId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('event_id=eq.$testEventId'));
        expect(endpoint, contains('order=created_at.desc'));
      });

      test('createEventComment returns correct endpoint', () {
        final endpoint = EventEndpoints.createEventComment();

        expect(endpoint, equals('event_comments'));
      });

      test('updateEventComment returns correct endpoint', () {
        final endpoint = EventEndpoints.updateEventComment(testCommentId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });

      test('deleteEventComment returns correct endpoint', () {
        final endpoint = EventEndpoints.deleteEventComment(testCommentId);

        expect(endpoint, contains('event_comments'));
        expect(endpoint, contains('id=eq.$testCommentId'));
      });
    });

    group('Event Search & Filter', () {
      test('searchEvents returns correct endpoint with encoded search term', () {
        const searchTerm = 'birthday party';
        final endpoint = EventEndpoints.searchEvents(testBabyProfileId, searchTerm);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('title=ilike.'));
        expect(endpoint, contains('is:deleted_at.null'));
        // Search term should be encoded
        expect(endpoint, isNot(contains(' ')));
      });

      test('searchEvents encodes special characters', () {
        const searchTerm = 'event & party!';
        final endpoint = EventEndpoints.searchEvents(testBabyProfileId, searchTerm);

        expect(endpoint, contains('events'));
        expect(endpoint, isNot(contains('&')));
        expect(endpoint, isNot(contains('!')));
      });

      test('getEventsByDateRange returns correct endpoint', () {
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

      test('getEventsByCreator returns correct endpoint', () {
        final endpoint =
            EventEndpoints.getEventsByCreator(testBabyProfileId, testUserId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('created_by_user_id=eq.$testUserId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('order=created_at.desc'));
      });
    });

    group('Helper Methods', () {
      test('getEventsWithPagination uses default values', () {
        final endpoint =
            EventEndpoints.getEventsWithPagination(testBabyProfileId);

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('is:deleted_at.null'));
        expect(endpoint, contains('limit=10'));
        expect(endpoint, contains('offset=0'));
        expect(endpoint, contains('order=starts_at.desc'));
      });

      test('getEventsWithPagination uses custom values', () {
        final endpoint = EventEndpoints.getEventsWithPagination(
          testBabyProfileId,
          limit: 25,
          offset: 50,
        );

        expect(endpoint, contains('events'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('limit=25'));
        expect(endpoint, contains('offset=50'));
      });

      test('getEventsWithPagination handles large offset', () {
        final endpoint = EventEndpoints.getEventsWithPagination(
          testBabyProfileId,
          limit: 100,
          offset: 1000,
        );

        expect(endpoint, contains('limit=100'));
        expect(endpoint, contains('offset=1000'));
      });
    });
  });
}
