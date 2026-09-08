import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_coowner_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Co-owner welcome screen after accept — crown + owner capabilities (#50).
class OnboardingCoOwnerWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardingCoOwnerWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardingCoOwnerWelcomeScreen> createState() =>
      _OnboardingCoOwnerWelcomeScreenState();
}

class _OnboardingCoOwnerWelcomeScreenState
    extends ConsumerState<OnboardingCoOwnerWelcomeScreen> {
  var _syncedStep = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.coOwnerWelcome);
    });
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  Future<void> _goHome() async {
    await finishCoOwnerOnboardingAndGoHome(ref: ref, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final babyName = ref.watch(inviteAcceptProvider).babyName ?? 'Baby';
    final inviterName =
        ref.watch(inviteAcceptProvider).inviterName ?? 'the other owner';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: OnboardingScaffold(
        showBack: true,
        onBack: _handleBack,
        bottom: OnboardingPrimaryButton(
          label: 'Go to Home',
          onPressed: _goHome,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    OnboardingColors.peachTint.withValues(alpha: 0.6),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: OnboardingColors.peachDark.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    "You're officially an Owner!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You now have full access to edit $babyName\'s profile, add events, manage the registry, and invite others, just like $inviterName.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: OnboardingColors.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
