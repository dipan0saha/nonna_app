import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/invitation_status.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

/// Acceptance status for an invitation deep link.
enum InviteAcceptStatus {
  idle,
  loading,
  found,
  accepting,
  accepted,
  alreadyMember,
  expired,
  notFound,
  error,
}

/// UI state for invitation acceptance.
class InviteAcceptState {
  const InviteAcceptState({
    this.status = InviteAcceptStatus.idle,
    this.babyName,
    this.inviterName,
    this.babyProfileId,
    this.inviteeEmail,
    this.error,
  });

  static const _unset = Object();

  final InviteAcceptStatus status;
  final String? babyName;
  final String? inviterName;
  final String? babyProfileId;
  final String? inviteeEmail;
  final String? error;

  InviteAcceptState copyWith({
    InviteAcceptStatus? status,
    Object? babyName = _unset,
    Object? inviterName = _unset,
    Object? babyProfileId = _unset,
    Object? inviteeEmail = _unset,
    Object? error = _unset,
  }) {
    return InviteAcceptState(
      status: status ?? this.status,
      babyName:
          identical(babyName, _unset) ? this.babyName : babyName as String?,
      inviterName: identical(inviterName, _unset)
          ? this.inviterName
          : inviterName as String?,
      babyProfileId: identical(babyProfileId, _unset)
          ? this.babyProfileId
          : babyProfileId as String?,
      inviteeEmail: identical(inviteeEmail, _unset)
          ? this.inviteeEmail
          : inviteeEmail as String?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class InviteAcceptNotifier extends Notifier<InviteAcceptState> {
  @override
  InviteAcceptState build() => const InviteAcceptState();

  Future<void> lookupToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      state = const InviteAcceptState(status: InviteAcceptStatus.notFound);
      return;
    }

    state = state.copyWith(
      status: InviteAcceptStatus.loading,
      error: null,
      babyName: null,
      inviterName: null,
      babyProfileId: null,
      inviteeEmail: null,
    );

    try {
      final invitation = await _fetchInvitation(normalizedToken);
      if (!ref.mounted) return;

      if (invitation == null) {
        state = const InviteAcceptState(status: InviteAcceptStatus.notFound);
        return;
      }

      if (_isExpiredOrInactive(invitation)) {
        state = const InviteAcceptState(status: InviteAcceptStatus.expired);
        return;
      }

      final babyProfileId = invitation[SupabaseTables.babyProfileId] as String;
      final inviterUserId = invitation['invited_by_user_id'] as String;
      final babyName = await _resolveBabyName(babyProfileId);
      final inviterName = await _resolveInviterName(inviterUserId);
      if (!ref.mounted) return;

      state = state.copyWith(
        status: InviteAcceptStatus.found,
        babyProfileId: babyProfileId,
        babyName: babyName,
        inviterName: inviterName,
        inviteeEmail: invitation['invitee_email'] as String?,
        error: null,
      );
    } catch (e) {
      if (!ref.mounted) return;
      debugPrint('❌ Failed to look up invitation token: $e');
      state = state.copyWith(
        status: InviteAcceptStatus.error,
        error: 'Unable to load invitation details. Please try again.',
      );
    }
  }

  Future<void> accept(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      state = state.copyWith(
        status: InviteAcceptStatus.notFound,
        error: null,
      );
      return;
    }

    final currentUser = ref.read(currentAuthUserProvider);
    if (currentUser == null) {
      state = state.copyWith(
        status: InviteAcceptStatus.error,
        error: 'Please sign in to accept this invitation.',
      );
      return;
    }

    state = state.copyWith(status: InviteAcceptStatus.accepting, error: null);

    final database = ref.read(databaseServiceProvider);

    try {
      final invitation = await _fetchInvitation(normalizedToken);
      if (!ref.mounted) return;

      if (invitation == null) {
        state = const InviteAcceptState(status: InviteAcceptStatus.notFound);
        return;
      }

      if (_isExpiredOrInactive(invitation)) {
        state = const InviteAcceptState(status: InviteAcceptStatus.expired);
        return;
      }

      final babyProfileId = invitation[SupabaseTables.babyProfileId] as String;
      final inviterUserId = invitation['invited_by_user_id'] as String;
      final babyName = await _resolveBabyName(babyProfileId);
      final inviterName = await _resolveInviterName(inviterUserId);
      if (!ref.mounted) return;

      final existingMembership = await database
          .select(SupabaseTables.babyMemberships, columns: SupabaseTables.id)
          .eq(SupabaseTables.userId, currentUser.id)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .isFilter('removed_at', null)
          .maybeSingle();
      if (!ref.mounted) return;

      if (existingMembership != null) {
        ref.read(selectedBabyProfileProvider.notifier).select(babyProfileId);
        state = state.copyWith(
          status: InviteAcceptStatus.alreadyMember,
          babyProfileId: babyProfileId,
          babyName: babyName,
          inviterName: inviterName,
          inviteeEmail: invitation['invitee_email'] as String?,
          error: null,
        );
        return;
      }

      final now = DateTime.now().toIso8601String();
      final insertedMembership =
          await database.insert(SupabaseTables.babyMemberships, {
        SupabaseTables.babyProfileId: babyProfileId,
        SupabaseTables.userId: currentUser.id,
        SupabaseTables.role: UserRole.follower.name,
        SupabaseTables.createdAt: now,
        SupabaseTables.updatedAt: now,
      });

      try {
        await database.update(SupabaseTables.invitations, {
          SupabaseTables.status: InvitationStatus.accepted.toJson(),
          'accepted_at': now,
          'accepted_by_user_id': currentUser.id,
          SupabaseTables.updatedAt: now,
        }).eq('token_hash', normalizedToken);
      } catch (e) {
        final membershipId =
            (insertedMembership.firstOrNull?[SupabaseTables.id] as String?);
        if (membershipId != null && membershipId.isNotEmpty) {
          try {
            await database
                .delete(SupabaseTables.babyMemberships)
                .eq(SupabaseTables.id, membershipId);
          } catch (rollbackError) {
            debugPrint(
                '⚠️ Failed to rollback membership insert: $rollbackError');
          }
        }
        rethrow;
      }

      if (!ref.mounted) return;
      ref.read(selectedBabyProfileProvider.notifier).select(babyProfileId);

      state = state.copyWith(
        status: InviteAcceptStatus.accepted,
        babyProfileId: babyProfileId,
        babyName: babyName,
        inviterName: inviterName,
        inviteeEmail: invitation['invitee_email'] as String?,
        error: null,
      );
    } catch (e) {
      if (!ref.mounted) return;
      debugPrint('❌ Failed to accept invitation: $e');
      state = state.copyWith(
        status: InviteAcceptStatus.error,
        error: 'Unable to accept invitation right now. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchInvitation(String token) {
    return ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.invitations)
        .eq('token_hash', token)
        .maybeSingle();
  }

  bool _isExpiredOrInactive(Map<String, dynamic> invitation) {
    final rawStatus = invitation[SupabaseTables.status] as String?;
    final expiresAtRaw = invitation['expires_at'] as String?;

    if (rawStatus != InvitationStatus.pending.toJson()) {
      return true;
    }

    if (expiresAtRaw == null) {
      return true;
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      return true;
    }

    return DateTime.now().isAfter(expiresAt);
  }

  Future<String> _resolveBabyName(String babyProfileId) async {
    try {
      final response = await ref
          .read(databaseServiceProvider)
          .select(
            SupabaseTables.babyProfiles,
            columns: SupabaseTables.name,
          )
          .eq(SupabaseTables.id, babyProfileId)
          .maybeSingle();

      final name = response?[SupabaseTables.name] as String?;
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to resolve baby name for invite acceptance: $e');
    }

    return 'your baby';
  }

  Future<String> _resolveInviterName(String inviterUserId) async {
    try {
      final response = await ref
          .read(databaseServiceProvider)
          .select(
            SupabaseTables.userProfiles,
            columns: SupabaseTables.displayName,
          )
          .eq(SupabaseTables.userId, inviterUserId)
          .maybeSingle();

      final displayName = response?[SupabaseTables.displayName] as String?;
      if (displayName != null && displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to resolve inviter name for invite acceptance: $e');
    }

    return 'A family member';
  }
}

final inviteAcceptProvider =
    NotifierProvider.autoDispose<InviteAcceptNotifier, InviteAcceptState>(
  InviteAcceptNotifier.new,
);
