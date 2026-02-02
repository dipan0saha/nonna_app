import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';

void main() {
  group('InvitationStatus', () {
    test('has correct number of values', () {
      expect(InvitationStatus.values.length, 4);
    });

    test('has pending, accepted, revoked, and expired values', () {
      expect(InvitationStatus.values, contains(InvitationStatus.pending));
      expect(InvitationStatus.values, contains(InvitationStatus.accepted));
      expect(InvitationStatus.values, contains(InvitationStatus.revoked));
      expect(InvitationStatus.values, contains(InvitationStatus.expired));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(InvitationStatus.pending.toJson(), 'pending');
        expect(InvitationStatus.accepted.toJson(), 'accepted');
        expect(InvitationStatus.revoked.toJson(), 'revoked');
        expect(InvitationStatus.expired.toJson(), 'expired');
      });

      test('fromJson parses correct values', () {
        expect(InvitationStatus.fromJson('pending'), InvitationStatus.pending);
        expect(InvitationStatus.fromJson('accepted'), InvitationStatus.accepted);
        expect(InvitationStatus.fromJson('revoked'), InvitationStatus.revoked);
        expect(InvitationStatus.fromJson('expired'), InvitationStatus.expired);
      });

      test('fromJson is case insensitive', () {
        expect(InvitationStatus.fromJson('PENDING'), InvitationStatus.pending);
        expect(InvitationStatus.fromJson('Accepted'), InvitationStatus.accepted);
        expect(InvitationStatus.fromJson('REVOKED'), InvitationStatus.revoked);
        expect(InvitationStatus.fromJson('Expired'), InvitationStatus.expired);
      });

      test('fromJson defaults to pending for invalid input', () {
        expect(InvitationStatus.fromJson('invalid'), InvitationStatus.pending);
        expect(InvitationStatus.fromJson(''), InvitationStatus.pending);
        expect(InvitationStatus.fromJson('unknown'), InvitationStatus.pending);
      });

      test('toJson and fromJson are reversible', () {
        for (final status in InvitationStatus.values) {
          final json = status.toJson();
          final parsed = InvitationStatus.fromJson(json);
          expect(parsed, status);
        }
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(InvitationStatus.pending.displayName, 'Pending');
        expect(InvitationStatus.accepted.displayName, 'Accepted');
        expect(InvitationStatus.revoked.displayName, 'Revoked');
        expect(InvitationStatus.expired.displayName, 'Expired');
      });

      test('all display names are non-empty', () {
        for (final status in InvitationStatus.values) {
          expect(status.displayName.isNotEmpty, true);
        }
      });

      test('display names are capitalized', () {
        for (final status in InvitationStatus.values) {
          expect(status.displayName[0], equals(status.displayName[0].toUpperCase()));
        }
      });
    });

    group('isActionable', () {
      test('returns true only for pending', () {
        expect(InvitationStatus.pending.isActionable, true);
        expect(InvitationStatus.accepted.isActionable, false);
        expect(InvitationStatus.revoked.isActionable, false);
        expect(InvitationStatus.expired.isActionable, false);
      });

      test('pending is the only actionable status', () {
        final actionableCount = InvitationStatus.values
            .where((status) => status.isActionable)
            .length;
        expect(actionableCount, 1);
      });
    });

    group('isInvalid', () {
      test('returns true for revoked and expired', () {
        expect(InvitationStatus.pending.isInvalid, false);
        expect(InvitationStatus.accepted.isInvalid, false);
        expect(InvitationStatus.revoked.isInvalid, true);
        expect(InvitationStatus.expired.isInvalid, true);
      });

      test('invalid statuses cannot be actioned', () {
        for (final status in InvitationStatus.values) {
          if (status.isInvalid) {
            expect(status.isActionable, false);
          }
        }
      });
    });

    group('invitation lifecycle', () {
      test('pending represents initial state', () {
        expect(InvitationStatus.pending.isActionable, true);
        expect(InvitationStatus.pending.isInvalid, false);
      });

      test('accepted represents successful outcome', () {
        expect(InvitationStatus.accepted.isActionable, false);
        expect(InvitationStatus.accepted.isInvalid, false);
      });

      test('revoked represents manual cancellation', () {
        expect(InvitationStatus.revoked.isInvalid, true);
        expect(InvitationStatus.revoked.isActionable, false);
      });

      test('expired represents automatic timeout', () {
        expect(InvitationStatus.expired.isInvalid, true);
        expect(InvitationStatus.expired.isActionable, false);
      });
    });

    group('consistency', () {
      test('all statuses have unique display names', () {
        final displayNames =
            InvitationStatus.values.map((s) => s.displayName).toSet();
        expect(displayNames.length, InvitationStatus.values.length);
      });

      test('actionable and invalid are mutually exclusive', () {
        for (final status in InvitationStatus.values) {
          if (status.isActionable) {
            expect(status.isInvalid, false);
          }
        }
      });
    });

    group('edge cases', () {
      test('handles all enum values', () {
        for (final status in InvitationStatus.values) {
          expect(() => status.toJson(), returnsNormally);
          expect(() => status.displayName, returnsNormally);
          expect(() => status.isActionable, returnsNormally);
          expect(() => status.isInvalid, returnsNormally);
        }
      });
    });
  });
}
