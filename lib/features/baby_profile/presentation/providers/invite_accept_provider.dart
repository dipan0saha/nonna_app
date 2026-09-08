import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_invite_helpers.dart';

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
    this.invitedRole = UserRole.follower,
    this.relationshipLabel,
    this.error,
  });

  static const _unset = Object();

  final InviteAcceptStatus status;
  final String? babyName;
  final String? inviterName;
  final String? babyProfileId;
  final String? inviteeEmail;
  final UserRole invitedRole;
  final String? relationshipLabel;
  final String? error;

  InviteAcceptState copyWith({
    InviteAcceptStatus? status,
    Object? babyName = _unset,
    Object? inviterName = _unset,
    Object? babyProfileId = _unset,
    Object? inviteeEmail = _unset,
    UserRole? invitedRole,
    Object? relationshipLabel = _unset,
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
      invitedRole: invitedRole ?? this.invitedRole,
      relationshipLabel: identical(relationshipLabel, _unset)
          ? this.relationshipLabel
          : relationshipLabel as String?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class InviteAcceptNotifier extends Notifier<InviteAcceptState> {
  @override
  InviteAcceptState build() => const InviteAcceptState();

  /// Fetches preview via RPC and syncs coordinator path/email from DB role.
  Future<void> lookupAndSyncCoordinator({
    required String token,
    OnboardingPath fallbackPath = OnboardingPath.follower,
  }) async {
    await lookupToken(token);
    if (!ref.mounted) return;

    final coordinator = ref.read(onboardingCoordinatorProvider.notifier);
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    if (state.status == InviteAcceptStatus.found) {
      final path = onboardingPathForInvitedRole(state.invitedRole);
      await coordinator.setPendingInviteToken(normalizedToken, path: path);
      await coordinator.setInviteeEmail(state.inviteeEmail);
      return;
    }

    await coordinator.setPendingInviteToken(
      normalizedToken,
      path: fallbackPath,
    );
  }

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
      relationshipLabel: null,
    );

    try {
      final preview = await _fetchPreview(normalizedToken);
      if (!ref.mounted) return;

      if (preview == null) {
        state = const InviteAcceptState(status: InviteAcceptStatus.notFound);
        return;
      }

      if (preview['status'] == 'expired') {
        state = const InviteAcceptState(status: InviteAcceptStatus.expired);
        return;
      }

      final invitedRole = UserRole.fromJson(
        (preview['invited_role'] as String?) ?? UserRole.follower.name,
      );

      state = state.copyWith(
        status: InviteAcceptStatus.found,
        babyProfileId: preview['baby_profile_id'] as String?,
        babyName: preview['baby_name'] as String? ?? 'Baby',
        inviterName:
            preview['inviter_display_name'] as String? ?? 'A family member',
        inviteeEmail: preview['invitee_email'] as String?,
        invitedRole: invitedRole,
        relationshipLabel: preview['relationship_label'] as String?,
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

    try {
      final result = await ref.read(databaseServiceProvider).rpc(
        'accept_invitation',
        params: {'p_token_hash': normalizedToken},
      );
      if (!ref.mounted) return;

      final data = _asMap(result);
      final error = data['error'] as String?;

      if (error == 'not_found') {
        state = const InviteAcceptState(status: InviteAcceptStatus.notFound);
        return;
      }
      if (error == 'expired') {
        state = const InviteAcceptState(status: InviteAcceptStatus.expired);
        return;
      }
      if (error == 'email_mismatch') {
        final inviteeEmail =
            data['invitee_email'] as String? ?? 'the invited email';
        state = state.copyWith(
          status: InviteAcceptStatus.error,
          error:
              'This invitation was sent to $inviteeEmail. Sign in with that email to accept.',
        );
        return;
      }
      if (error == 'max_owners') {
        state = state.copyWith(
          status: InviteAcceptStatus.error,
          error: 'This baby profile already has the maximum number of owners.',
        );
        return;
      }

      final babyProfileId = data['baby_profile_id'] as String?;
      final babyName = data['baby_name'] as String? ?? state.babyName ?? 'Baby';
      final role = UserRole.fromJson(
        (data['role'] as String?) ?? state.invitedRole.name,
      );
      final alreadyMember = data['already_member'] == true;

      if (babyProfileId != null) {
        ref.read(selectedBabyProfileProvider.notifier).select(babyProfileId);
      }

      state = state.copyWith(
        status: alreadyMember
            ? InviteAcceptStatus.alreadyMember
            : InviteAcceptStatus.accepted,
        babyProfileId: babyProfileId,
        babyName: babyName,
        invitedRole: role,
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

  Future<Map<String, dynamic>?> _fetchPreview(String token) async {
    final result = await ref.read(databaseServiceProvider).rpc(
      'get_invitation_preview',
      params: {'p_token_hash': token},
    );
    if (result == null) return null;
    return _asMap(result);
  }

  Map<String, dynamic> _asMap(dynamic result) {
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    return {};
  }
}

final inviteAcceptProvider =
    NotifierProvider<InviteAcceptNotifier, InviteAcceptState>(
  InviteAcceptNotifier.new,
);
