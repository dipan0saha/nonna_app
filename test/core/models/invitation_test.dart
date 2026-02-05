import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/models/invitation.dart';

void main() {
  group('Invitation', () {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));
    final invitation = Invitation(
      id: 'invite-123',
      babyProfileId: 'baby-456',
      invitedByUserId: 'user-789',
      inviteeEmail: 'invitee@example.com',
      tokenHash: 'hash123',
      expiresAt: expiresAt,
      status: InvitationStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates Invitation from valid JSON', () {
        final json = {
          'id': 'invite-123',
          'baby_profile_id': 'baby-456',
          'invited_by_user_id': 'user-789',
          'invitee_email': 'invitee@example.com',
          'token_hash': 'hash123',
          'expires_at': expiresAt.toIso8601String(),
          'status': 'pending',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = Invitation.fromJson(json);

        expect(result.id, 'invite-123');
        expect(result.babyProfileId, 'baby-456');
        expect(result.invitedByUserId, 'user-789');
        expect(result.inviteeEmail, 'invitee@example.com');
        expect(result.tokenHash, 'hash123');
        expect(result.expiresAt, expiresAt);
        expect(result.status, InvitationStatus.pending);
      });

      test('handles accepted invitation with accepted_by fields', () {
        final acceptedAt = now.add(const Duration(hours: 1));
        final json = {
          'id': 'invite-123',
          'baby_profile_id': 'baby-456',
          'invited_by_user_id': 'user-789',
          'invitee_email': 'invitee@example.com',
          'token_hash': 'hash123',
          'expires_at': expiresAt.toIso8601String(),
          'status': 'accepted',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'accepted_by_user_id': 'user-999',
          'accepted_at': acceptedAt.toIso8601String(),
        };

        final result = Invitation.fromJson(json);

        expect(result.status, InvitationStatus.accepted);
        expect(result.acceptedByUserId, 'user-999');
        expect(result.acceptedAt, acceptedAt);
      });
    });

    group('toJson', () {
      test('converts Invitation to JSON', () {
        final json = invitation.toJson();

        expect(json['id'], 'invite-123');
        expect(json['baby_profile_id'], 'baby-456');
        expect(json['invited_by_user_id'], 'user-789');
        expect(json['invitee_email'], 'invitee@example.com');
        expect(json['token_hash'], 'hash123');
        expect(json['expires_at'], expiresAt.toIso8601String());
        expect(json['status'], 'pending');
      });
    });

    group('validate', () {
      test('returns null for valid invitation', () {
        expect(invitation.validate(), null);
      });

      test('returns error for invalid email', () {
        final invalid = invitation.copyWith(inviteeEmail: 'invalid-email');
        expect(invalid.validate(), 'Invalid email address');
      });

      test('returns error for email exceeding 255 characters', () {
        final invalid =
            invitation.copyWith(inviteeEmail: '${'a' * 250}@example.com');
        expect(
            invalid.validate(), 'Email address must be 255 characters or less');
      });

      test('returns error for expiration more than 7 days', () {
        final invalid = invitation.copyWith(
          expiresAt: now.add(const Duration(days: 8)),
        );
        expect(
          invalid.validate(),
          'Expiration must be between 0 and 7 days from creation',
        );
      });

      test('returns error for accepted status without acceptedByUserId', () {
        final invalid = invitation.copyWith(
          status: InvitationStatus.accepted,
        );
        expect(
          invalid.validate(),
          'Accepted invitation must have acceptedByUserId',
        );
      });

      test('returns error for accepted status without acceptedAt', () {
        final invalid = invitation.copyWith(
          status: InvitationStatus.accepted,
          acceptedByUserId: 'user-999',
        );
        expect(
          invalid.validate(),
          'Accepted invitation must have acceptedAt',
        );
      });

      test('returns null for properly accepted invitation', () {
        final accepted = invitation.copyWith(
          status: InvitationStatus.accepted,
          acceptedByUserId: 'user-999',
          acceptedAt: now,
        );
        expect(accepted.validate(), null);
      });
    });

    group('isExpired', () {
      test('returns false for invitation not yet expired', () {
        expect(invitation.isExpired, false);
      });

      test('returns true for expired invitation', () {
        final expired = invitation.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(expired.isExpired, true);
      });
    });

    group('canBeAccepted', () {
      test('returns true for pending, non-expired invitation', () {
        expect(invitation.canBeAccepted, true);
      });

      test('returns false for expired invitation', () {
        final expired = invitation.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(expired.canBeAccepted, false);
      });

      test('returns false for accepted invitation', () {
        final accepted = invitation.copyWith(
          status: InvitationStatus.accepted,
        );
        expect(accepted.canBeAccepted, false);
      });

      test('returns false for revoked invitation', () {
        final revoked = invitation.copyWith(
          status: InvitationStatus.revoked,
        );
        expect(revoked.canBeAccepted, false);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = invitation.copyWith(
          status: InvitationStatus.accepted,
          acceptedByUserId: 'user-999',
        );

        expect(updated.id, invitation.id);
        expect(updated.status, InvitationStatus.accepted);
        expect(updated.acceptedByUserId, 'user-999');
      });
    });

    group('equality', () {
      test('equal invitations are equal', () {
        final invitation1 = Invitation(
          id: 'invite-123',
          babyProfileId: 'baby-456',
          invitedByUserId: 'user-789',
          inviteeEmail: 'invitee@example.com',
          tokenHash: 'hash123',
          expiresAt: expiresAt,
          status: InvitationStatus.pending,
          createdAt: now,
          updatedAt: now,
        );
        final invitation2 = Invitation(
          id: 'invite-123',
          babyProfileId: 'baby-456',
          invitedByUserId: 'user-789',
          inviteeEmail: 'invitee@example.com',
          tokenHash: 'hash123',
          expiresAt: expiresAt,
          status: InvitationStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        expect(invitation1, invitation2);
        expect(invitation1.hashCode, invitation2.hashCode);
      });

      test('different invitations are not equal', () {
        final invitation1 = Invitation(
          id: 'invite-123',
          babyProfileId: 'baby-456',
          invitedByUserId: 'user-789',
          inviteeEmail: 'invitee1@example.com',
          tokenHash: 'hash123',
          expiresAt: expiresAt,
          createdAt: now,
          updatedAt: now,
        );
        final invitation2 = Invitation(
          id: 'invite-456',
          babyProfileId: 'baby-456',
          invitedByUserId: 'user-789',
          inviteeEmail: 'invitee2@example.com',
          tokenHash: 'hash456',
          expiresAt: expiresAt,
          createdAt: now,
          updatedAt: now,
        );

        expect(invitation1, isNot(invitation2));
      });
    });
  });
}
