import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/coowner/onboarding_coowner_invite_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/follower/onboarding_follower_invite_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/screens/shared/onboarding_invite_expired_screen.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_invite_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Placeholder shell for onboarding steps built in later phases.
class OnboardingStepPlaceholderScreen extends ConsumerStatefulWidget {
  const OnboardingStepPlaceholderScreen({
    super.key,
    required this.title,
    required this.step,
    this.showBack = true,
    this.continueLabel = 'Continue',
    this.nextRoute,
    this.routeLocation,
  });

  final String title;
  final OnboardingStep step;
  final bool showBack;
  final String continueLabel;
  final String? nextRoute;

  /// Current route path — used to sync coordinator step on entry.
  final String? routeLocation;

  @override
  ConsumerState<OnboardingStepPlaceholderScreen> createState() =>
      _OnboardingStepPlaceholderScreenState();
}

class _OnboardingStepPlaceholderScreenState
    extends ConsumerState<OnboardingStepPlaceholderScreen> {
  var _syncedStep = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    final location =
        widget.routeLocation ?? GoRouterState.of(context).matchedLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(location);
    });
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (route != null && mounted) context.go(route);
  }

  Future<void> _handleContinue() async {
    final nextRoute = widget.nextRoute;
    if (nextRoute == null) return;
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .advanceToRoute(nextRoute);
    if (mounted) context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: OnboardingScaffold(
        showBack: widget.showBack,
        onBack: _handleBack,
        bottom: OnboardingPrimaryButton(
          label: widget.continueLabel,
          onPressed: widget.nextRoute == null ? null : _handleContinue,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            OnboardingHeadline(widget.title),
            const SizedBox(height: 12),
            const OnboardingSupportText(
              'Phase 1 will replace this placeholder with the full prototype screen.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Path-aware complete-profile placeholder (owner / follower / co-owner).
class OnboardingCompleteProfilePlaceholder extends ConsumerWidget {
  const OnboardingCompleteProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(onboardingCoordinatorProvider).path;
    final nextRoute = OnboardingRoutes.nextRouteAfterCompleteProfile(path);
    return OnboardingStepPlaceholderScreen(
      title: 'Complete your profile',
      step: OnboardingStep.completeProfile,
      nextRoute: nextRoute,
      routeLocation: OnboardingRoutes.completeProfile,
    );
  }
}

/// Wrapper for `/invite-accept` — stores token and routes by role (Phase 0b).
class OnboardingInviteAcceptWrapper extends ConsumerStatefulWidget {
  const OnboardingInviteAcceptWrapper({
    super.key,
    required this.token,
    this.invitePath = OnboardingPath.follower,
  });

  final String token;
  final OnboardingPath invitePath;

  @override
  ConsumerState<OnboardingInviteAcceptWrapper> createState() =>
      _OnboardingInviteAcceptWrapperState();
}

class _OnboardingInviteAcceptWrapperState
    extends ConsumerState<OnboardingInviteAcceptWrapper> {
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized || widget.token.isEmpty) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(inviteAcceptProvider.notifier).lookupAndSyncCoordinator(
            token: widget.token,
            fallbackPath: widget.invitePath,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteAcceptProvider);

    if (widget.token.isEmpty ||
        inviteState.status == InviteAcceptStatus.notFound) {
      return const OnboardingInviteExpiredScreen(
        message:
            'We could not find this invitation. Check the link and try again.',
      );
    }

    if (inviteState.status == InviteAcceptStatus.expired) {
      return const OnboardingInviteExpiredScreen();
    }

    if (inviteState.status == InviteAcceptStatus.loading ||
        inviteState.status == InviteAcceptStatus.idle) {
      return const OnboardingScaffold(
        showBack: false,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (inviteState.status == InviteAcceptStatus.error) {
      return OnboardingInviteExpiredScreen(
        message: inviteState.error ??
            'Unable to load this invitation. Please try again later.',
      );
    }

    final path = resolveInvitePath(
      inviteState: inviteState,
      fallbackPath: widget.invitePath,
    );
    if (path == OnboardingPath.coOwner) {
      return const OnboardingCoOwnerInviteScreen();
    }
    return const OnboardingFollowerInviteScreen();
  }
}
