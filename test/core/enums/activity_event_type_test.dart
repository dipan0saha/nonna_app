import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/activity_event_type.dart';

void main() {
  group('ActivityEventType', () {
    test('has correct number of values', () {
      expect(ActivityEventType.values.length, 15);
    });

    test('has all expected values', () {
      expect(
          ActivityEventType.values, contains(ActivityEventType.photoUploaded));
      expect(
          ActivityEventType.values, contains(ActivityEventType.commentAdded));
      expect(ActivityEventType.values, contains(ActivityEventType.rsvpYes));
      expect(ActivityEventType.values, contains(ActivityEventType.rsvpNo));
      expect(ActivityEventType.values, contains(ActivityEventType.rsvpMaybe));
      expect(
          ActivityEventType.values, contains(ActivityEventType.itemPurchased));
      expect(
          ActivityEventType.values, contains(ActivityEventType.eventCreated));
      expect(
          ActivityEventType.values, contains(ActivityEventType.eventUpdated));
      expect(
          ActivityEventType.values, contains(ActivityEventType.photoSquished));
      expect(
          ActivityEventType.values, contains(ActivityEventType.nameSuggested));
      expect(ActivityEventType.values, contains(ActivityEventType.voteCast));
      expect(
          ActivityEventType.values, contains(ActivityEventType.memberInvited));
      expect(
          ActivityEventType.values, contains(ActivityEventType.memberJoined));
      expect(
          ActivityEventType.values, contains(ActivityEventType.profileUpdated));
      expect(ActivityEventType.values, contains(ActivityEventType.photoTagged));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(ActivityEventType.photoUploaded.toJson(), 'photoUploaded');
        expect(ActivityEventType.commentAdded.toJson(), 'commentAdded');
        expect(ActivityEventType.rsvpYes.toJson(), 'rsvpYes');
        expect(ActivityEventType.itemPurchased.toJson(), 'itemPurchased');
      });

      test('fromJson parses correct values', () {
        expect(ActivityEventType.fromJson('photouploaded'),
            ActivityEventType.photoUploaded);
        expect(ActivityEventType.fromJson('commentadded'),
            ActivityEventType.commentAdded);
        expect(
            ActivityEventType.fromJson('rsvpyes'), ActivityEventType.rsvpYes);
      });

      test('fromJson is case insensitive', () {
        expect(ActivityEventType.fromJson('PHOTOUPLOADED'),
            ActivityEventType.photoUploaded);
        expect(ActivityEventType.fromJson('CommentAdded'),
            ActivityEventType.commentAdded);
        expect(
            ActivityEventType.fromJson('RsvpYes'), ActivityEventType.rsvpYes);
      });

      test('fromJson defaults to commentAdded for invalid input', () {
        expect(ActivityEventType.fromJson('invalid'),
            ActivityEventType.commentAdded);
        expect(ActivityEventType.fromJson(''), ActivityEventType.commentAdded);
        expect(ActivityEventType.fromJson('unknown'),
            ActivityEventType.commentAdded);
      });

      test('toJson and fromJson are reversible', () {
        for (final type in ActivityEventType.values) {
          final json = type.toJson();
          final parsed = ActivityEventType.fromJson(json);
          expect(parsed, type);
        }
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(ActivityEventType.photoUploaded.displayName, 'Photo Uploaded');
        expect(ActivityEventType.commentAdded.displayName, 'Comment Added');
        expect(ActivityEventType.rsvpYes.displayName, 'RSVP Yes');
        expect(ActivityEventType.rsvpNo.displayName, 'RSVP No');
        expect(ActivityEventType.rsvpMaybe.displayName, 'RSVP Maybe');
        expect(ActivityEventType.itemPurchased.displayName, 'Item Purchased');
        expect(ActivityEventType.eventCreated.displayName, 'Event Created');
        expect(ActivityEventType.eventUpdated.displayName, 'Event Updated');
        expect(ActivityEventType.photoSquished.displayName, 'Photo Liked');
        expect(ActivityEventType.nameSuggested.displayName, 'Name Suggested');
        expect(ActivityEventType.voteCast.displayName, 'Vote Cast');
        expect(ActivityEventType.memberInvited.displayName, 'Member Invited');
        expect(ActivityEventType.memberJoined.displayName, 'Member Joined');
        expect(ActivityEventType.profileUpdated.displayName, 'Profile Updated');
        expect(ActivityEventType.photoTagged.displayName, 'Photo Tagged');
      });

      test('all display names are non-empty', () {
        for (final type in ActivityEventType.values) {
          expect(type.displayName.isNotEmpty, true);
        }
      });

      test('display names are properly capitalized', () {
        for (final type in ActivityEventType.values) {
          expect(
              type.displayName[0], equals(type.displayName[0].toUpperCase()));
        }
      });
    });

    group('description', () {
      test('returns correct descriptions', () {
        expect(
          ActivityEventType.photoUploaded.description,
          'A new photo was uploaded to the gallery',
        );
        expect(
          ActivityEventType.commentAdded.description,
          'A comment was added',
        );
        expect(
          ActivityEventType.rsvpYes.description,
          'Someone responded yes to an event',
        );
        expect(
          ActivityEventType.itemPurchased.description,
          'A registry item was purchased',
        );
      });

      test('all descriptions are non-empty', () {
        for (final type in ActivityEventType.values) {
          expect(type.description.isNotEmpty, true);
        }
      });

      test('descriptions provide meaningful context', () {
        expect(ActivityEventType.photoSquished.description.contains('liked'),
            true);
        expect(ActivityEventType.memberJoined.description.contains('joined'),
            true);
        expect(ActivityEventType.voteCast.description.contains('vote'), true);
      });
    });

    group('RSVP types', () {
      test('has all RSVP types', () {
        expect(ActivityEventType.values, contains(ActivityEventType.rsvpYes));
        expect(ActivityEventType.values, contains(ActivityEventType.rsvpNo));
        expect(ActivityEventType.values, contains(ActivityEventType.rsvpMaybe));
      });

      test('RSVP types have correct display names', () {
        expect(ActivityEventType.rsvpYes.displayName.contains('Yes'), true);
        expect(ActivityEventType.rsvpNo.displayName.contains('No'), true);
        expect(ActivityEventType.rsvpMaybe.displayName.contains('Maybe'), true);
      });
    });

    group('event management types', () {
      test('has event management types', () {
        expect(
            ActivityEventType.values, contains(ActivityEventType.eventCreated));
        expect(
            ActivityEventType.values, contains(ActivityEventType.eventUpdated));
      });
    });

    group('member management types', () {
      test('has member management types', () {
        expect(ActivityEventType.values,
            contains(ActivityEventType.memberInvited));
        expect(
            ActivityEventType.values, contains(ActivityEventType.memberJoined));
      });
    });

    group('photo interaction types', () {
      test('has photo interaction types', () {
        expect(ActivityEventType.values,
            contains(ActivityEventType.photoUploaded));
        expect(ActivityEventType.values,
            contains(ActivityEventType.photoSquished));
        expect(
            ActivityEventType.values, contains(ActivityEventType.photoTagged));
      });
    });

    group('edge cases', () {
      test('handles all enum values', () {
        for (final type in ActivityEventType.values) {
          expect(() => type.toJson(), returnsNormally);
          expect(() => type.displayName, returnsNormally);
          expect(() => type.description, returnsNormally);
        }
      });
    });
  });
}
