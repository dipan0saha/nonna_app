import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

const _oauthDisplayNameKeys = ['full_name', 'name', 'display_name'];
const _oauthAvatarUrlKeys = ['avatar_url', 'picture'];

/// Email-prefix placeholder for sign-up before complete-profile collects the real name (#38).
String onboardingEmailDisplayNamePlaceholder(String email) {
  final local = email.trim().split('@').first;
  if (local.isEmpty) return 'User';
  return local;
}

/// Resolves onboarding path from signup route query (`?path=owner|follower|coOwner`).
OnboardingPath onboardingPathFromRoute(Uri uri) {
  return onboardingPathFromStorage(uri.queryParameters['path']) ??
      OnboardingPath.owner;
}

/// Post-auth navigation for onboarding signup/login (email + OAuth).
Future<void> navigateAfterOnboardingAuth({
  required WidgetRef ref,
  required BuildContext context,
  required bool usedOAuth,
  required bool isSignUp,
}) async {
  if (!context.mounted) return;

  final coordinator = ref.read(onboardingCoordinatorProvider.notifier);
  final path = ref.read(onboardingCoordinatorProvider).path;

  if (usedOAuth) {
    await coordinator.setUsedOAuth(true);
    await coordinator.goToStep(OnboardingStep.completeProfile);
    if (context.mounted) context.go(OnboardingRoutes.completeProfile);
    return;
  }

  if (isSignUp) {
    await coordinator.goToStep(OnboardingStep.emailVerify);
    if (context.mounted) context.go(OnboardingRoutes.emailVerify);
    return;
  }

  // Login — mid-invite (#27) or owner signup "Log in".
  if (ref.read(onboardingCoordinatorProvider).pendingInviteToken != null) {
    await coordinator.goToStep(OnboardingStep.completeProfile);
    if (context.mounted) context.go(OnboardingRoutes.completeProfile);
    return;
  }

  if (path == OnboardingPath.owner) {
    await coordinator.goToStep(OnboardingStep.completeProfile);
    if (context.mounted) context.go(OnboardingRoutes.completeProfile);
    return;
  }

  await coordinator.goToStep(OnboardingStep.completeProfile);
  if (context.mounted) context.go(OnboardingRoutes.completeProfile);
}

/// OAuth display name from Supabase user metadata (#42).
String? onboardingDisplayNameFromMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  for (final key in _oauthDisplayNameKeys) {
    final value = metadata[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

/// OAuth avatar URL from Supabase user metadata (#42).
String? onboardingAvatarUrlFromMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  for (final key in _oauthAvatarUrlKeys) {
    final value = metadata[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? validateDisplayName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Display name is required';
  if (trimmed.length > 100)
    return 'Display name must be 100 characters or less';
  return null;
}

String onboardingSignupBackRoute(OnboardingPath path) {
  switch (path) {
    case OnboardingPath.owner:
      return OnboardingRoutes.ownerCarousel;
    case OnboardingPath.follower:
      return OnboardingRoutes.followerInvite;
    case OnboardingPath.coOwner:
      return OnboardingRoutes.coOwnerInvite;
  }
}
