import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Read-only relationship badge from invitation (#41 relationship_label).
class OnboardingRelationshipScreen extends ConsumerStatefulWidget {
  const OnboardingRelationshipScreen({super.key});

  @override
  ConsumerState<OnboardingRelationshipScreen> createState() =>
      _OnboardingRelationshipScreenState();
}

class _OnboardingRelationshipScreenState
    extends ConsumerState<OnboardingRelationshipScreen> {
  var _syncedStep = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.confirmRelationship);
    });
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  Future<void> _handleContinue() async {
    final nextRoute = OnboardingRoutes.followerCarousel;
    await ref
        .read(onboardingCoordinatorProvider.notifier)
        .advanceToRoute(nextRoute);
    if (mounted) context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteAcceptProvider);
    final babyName = inviteState.babyName ?? 'Baby';
    final inviterName = inviteState.inviterName ?? 'the owner';
    final relationship = inviteState.relationshipLabel ?? 'Family Friend';

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
          label: 'Continue',
          onPressed: _handleContinue,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            OnboardingHeadline(
              'Welcome to $babyName\'s circle',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OnboardingSupportText(
              '$inviterName added you as',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              decoration: BoxDecoration(
                color: OnboardingColors.sageTint,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: OnboardingColors.sageDark, width: 1.5),
              ),
              child: Text(
                relationship,
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: OnboardingColors.sageDark,
                ),
              ),
            ),
            const SizedBox(height: 22),
            OnboardingSupportText(
              'This is how you\'ll appear to the rest of the family. '
              '$inviterName can update it anytime from their side.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
