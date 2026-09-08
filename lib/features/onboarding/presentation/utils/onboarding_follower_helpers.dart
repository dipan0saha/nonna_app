import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/user_baby_profiles_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/first_run_home_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_analytics.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Result of accepting an invitation during follower onboarding.
class FollowerAcceptResult {
  const FollowerAcceptResult({
    required this.success,
    this.wrongEmail = false,
    this.alreadyMember = false,
    this.errorMessage,
  });

  final bool success;
  final bool wrongEmail;
  final bool alreadyMember;
  final String? errorMessage;
}

/// Accepts pending invite after complete-profile (#30, #67).
Future<FollowerAcceptResult> acceptPendingFollowerInvite(WidgetRef ref) async {
  final token = ref.read(onboardingCoordinatorProvider).pendingInviteToken;
  if (token == null || token.isEmpty) {
    return const FollowerAcceptResult(
      success: false,
      errorMessage: 'Invitation not found. Open the invite link again.',
    );
  }

  await ref.read(inviteAcceptProvider.notifier).accept(token);
  final state = ref.read(inviteAcceptProvider);

  if (state.status == InviteAcceptStatus.error) {
    final message = state.error ?? 'Unable to accept invitation.';
    final wrongEmail = message.contains('invitation was sent to');
    return FollowerAcceptResult(
      success: false,
      wrongEmail: wrongEmail,
      errorMessage: message,
    );
  }

  if (state.status == InviteAcceptStatus.notFound ||
      state.status == InviteAcceptStatus.expired) {
    return FollowerAcceptResult(
      success: false,
      errorMessage: 'This invitation is no longer valid.',
    );
  }

  if (state.status == InviteAcceptStatus.alreadyMember) {
    return const FollowerAcceptResult(success: true, alreadyMember: true);
  }

  if (state.status == InviteAcceptStatus.accepted) {
    return const FollowerAcceptResult(success: true);
  }

  return const FollowerAcceptResult(
    success: false,
    errorMessage: 'Unable to accept invitation right now.',
  );
}

/// Navigate from follower invite landing when user taps Accept (#21, #41).
Future<void> navigateFromFollowerInviteAccept({
  required WidgetRef ref,
  required BuildContext context,
}) async {
  final coordinator = ref.read(onboardingCoordinatorProvider);
  final inviteState = ref.read(inviteAcceptProvider);
  final inviteeEmail =
      coordinator.inviteeEmail ?? inviteState.inviteeEmail?.toLowerCase();
  final user = ref.read(currentAuthUserProvider);

  await ref
      .read(onboardingCoordinatorProvider.notifier)
      .setPath(OnboardingPath.follower);
  if (inviteeEmail != null) {
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .setInviteeEmail(inviteeEmail);
  }

  if (user != null) {
    final signedInEmail = user.email?.trim().toLowerCase();
    if (inviteeEmail != null &&
        signedInEmail != null &&
        signedInEmail != inviteeEmail) {
      if (context.mounted) context.go(OnboardingRoutes.wrongEmail);
      return;
    }
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .goToStep(OnboardingStep.completeProfile);
    if (context.mounted) context.go(OnboardingRoutes.completeProfile);
    return;
  }

  await ref
      .read(onboardingCoordinatorProvider.notifier)
      .goToStep(OnboardingStep.signup);
  if (context.mounted) {
    context.go(OnboardingRoutes.signupPathFor(OnboardingPath.follower));
  }
}

/// Marks onboarding complete, bootstraps follower home, navigates to `/home`.
Future<void> finishFollowerOnboardingAndGoHome({
  required WidgetRef ref,
  required BuildContext context,
}) async {
  final babyId = ref.read(inviteAcceptProvider).babyProfileId ??
      ref.read(selectedBabyProfileProvider);

  if (babyId != null) {
    ref.read(selectedBabyProfileProvider.notifier).select(babyId);
  }

  final storage = ref.read(localStorageServiceProvider);
  if (babyId != null && storage.isInitialized) {
    await storage.setString(
      OnboardingStorageKeys.firstRunPendingBabyId,
      babyId,
    );
    ref.read(firstRunHomeProvider.notifier).reload();
  }

  if (babyId != null) {
    await ref.read(onboardingAnalyticsProvider).trackInvitationAccepted(
          babyProfileId: babyId,
        );
  }

  await ref.read(onboardingCoordinatorProvider.notifier).completeOnboarding();
  ref.invalidate(userBabyProfilesProvider);

  if (babyId != null) {
    await ref.read(homeScreenProvider.notifier).loadTiles(
          babyProfileId: babyId,
          role: UserRole.follower,
        );
  }

  if (context.mounted) context.go('/home');
}
