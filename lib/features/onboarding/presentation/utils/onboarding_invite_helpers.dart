import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Maps DB `invited_role` to onboarding path (authoritative over URL query).
OnboardingPath onboardingPathForInvitedRole(UserRole role) {
  return role.isOwner ? OnboardingPath.coOwner : OnboardingPath.follower;
}

/// Resolves invite path from preview state, falling back to query-param hint.
OnboardingPath resolveInvitePath({
  required InviteAcceptState inviteState,
  required OnboardingPath fallbackPath,
}) {
  if (inviteState.status == InviteAcceptStatus.found) {
    return onboardingPathForInvitedRole(inviteState.invitedRole);
  }
  return fallbackPath;
}

/// Loads invite preview when landing screens mount without the wrapper route.
Future<void> ensureInvitePreviewLoaded(
  WidgetRef ref, {
  required OnboardingPath fallbackPath,
}) async {
  final coordinator = ref.read(onboardingCoordinatorProvider);
  final token = coordinator.pendingInviteToken;
  if (token == null || token.isEmpty) return;

  final inviteState = ref.read(inviteAcceptProvider);
  if (inviteState.status == InviteAcceptStatus.found ||
      inviteState.status == InviteAcceptStatus.loading ||
      inviteState.status == InviteAcceptStatus.accepting) {
    return;
  }

  final pathHint = coordinator.path != OnboardingPath.owner
      ? coordinator.path
      : fallbackPath;

  await ref.read(inviteAcceptProvider.notifier).lookupAndSyncCoordinator(
        token: token,
        fallbackPath: pathHint,
      );
}

/// Post-frame helper for [ConsumerState] invite landing screens.
void scheduleInvitePreviewLoad(
  WidgetsBinding binding,
  VoidCallback loadPreview,
) {
  binding.addPostFrameCallback((_) => loadPreview());
}
