import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';

void main() {
  group('EventRsvp', () {
    final now = DateTime.now();
    final rsvp = EventRsvp(
      id: 'rsvp-123',
      eventId: 'event-456',
      userId: 'user-789',
      status: RsvpStatus.yes,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates EventRsvp from valid JSON', () {
        final json = {
          'id': 'rsvp-123',
          'event_id': 'event-456',
          'user_id': 'user-789',
          'status': 'yes',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = EventRsvp.fromJson(json);

        expect(result.id, 'rsvp-123');
        expect(result.eventId, 'event-456');
        expect(result.userId, 'user-789');
        expect(result.status, RsvpStatus.yes);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('parses different RSVP statuses correctly', () {
        final jsonYes = {
          'id': 'rsvp-1',
          'event_id': 'event-1',
          'user_id': 'user-1',
          'status': 'yes',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        final jsonNo = {
          'id': 'rsvp-2',
          'event_id': 'event-2',
          'user_id': 'user-2',
          'status': 'no',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        final jsonMaybe = {
          'id': 'rsvp-3',
          'event_id': 'event-3',
          'user_id': 'user-3',
          'status': 'maybe',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        expect(EventRsvp.fromJson(jsonYes).status, RsvpStatus.yes);
        expect(EventRsvp.fromJson(jsonNo).status, RsvpStatus.no);
        expect(EventRsvp.fromJson(jsonMaybe).status, RsvpStatus.maybe);
      });
    });

    group('toJson', () {
      test('converts EventRsvp to JSON', () {
        final json = rsvp.toJson();

        expect(json['id'], 'rsvp-123');
        expect(json['event_id'], 'event-456');
        expect(json['user_id'], 'user-789');
        expect(json['status'], 'yes');
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid RSVP', () {
        expect(rsvp.validate(), null);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = rsvp.copyWith(
          status: RsvpStatus.no,
          updatedAt: now.add(const Duration(hours: 1)),
        );

        expect(updated.id, rsvp.id);
        expect(updated.eventId, rsvp.eventId);
        expect(updated.userId, rsvp.userId);
        expect(updated.status, RsvpStatus.no);
        expect(updated.createdAt, rsvp.createdAt);
        expect(updated.updatedAt, now.add(const Duration(hours: 1)));
      });

      test('maintains original values when no updates provided', () {
        final copy = rsvp.copyWith();
        expect(copy, rsvp);
      });
    });

    group('equality', () {
      test('equal RSVPs are equal', () {
        final rsvp1 = EventRsvp(
          id: 'rsvp-123',
          eventId: 'event-456',
          userId: 'user-789',
          status: RsvpStatus.yes,
          createdAt: now,
          updatedAt: now,
        );
        final rsvp2 = EventRsvp(
          id: 'rsvp-123',
          eventId: 'event-456',
          userId: 'user-789',
          status: RsvpStatus.yes,
          createdAt: now,
          updatedAt: now,
        );

        expect(rsvp1, rsvp2);
        expect(rsvp1.hashCode, rsvp2.hashCode);
      });

      test('different RSVPs are not equal', () {
        final rsvp1 = EventRsvp(
          id: 'rsvp-123',
          eventId: 'event-456',
          userId: 'user-789',
          status: RsvpStatus.yes,
          createdAt: now,
          updatedAt: now,
        );
        final rsvp2 = EventRsvp(
          id: 'rsvp-456',
          eventId: 'event-789',
          userId: 'user-123',
          status: RsvpStatus.no,
          createdAt: now,
          updatedAt: now,
        );

        expect(rsvp1, isNot(rsvp2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = rsvp.toString();

        expect(str, contains('EventRsvp'));
        expect(str, contains('rsvp-123'));
        expect(str, contains('event-456'));
        expect(str, contains('user-789'));
      });
    });
  });
}
