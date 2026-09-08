import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/onboarding_integration_keys.dart';
import 'package:nonna_app/features/onboarding/presentation/l10n/onboarding_l10n.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel_art.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Owner value carousel — 4 slides with prototype copy.
class OwnerCarouselScreen extends ConsumerStatefulWidget {
  const OwnerCarouselScreen({super.key});

  @override
  ConsumerState<OwnerCarouselScreen> createState() =>
      _OwnerCarouselScreenState();
}

class _OwnerCarouselScreenState extends ConsumerState<OwnerCarouselScreen> {
  static const _slideArt = [
    OnboardingCarouselSlideArt.homeIcon,
    OnboardingCarouselSlideArt.peopleIcon,
    OnboardingCarouselSlideArt.calendarIcon,
    OnboardingCarouselSlideArt.photoIcon,
  ];

  PageController? _pageController;
  var _syncedStep = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedStep) return;
    _syncedStep = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCoordinatorProvider.notifier)
          .syncStepForRoute(OnboardingRoutes.ownerCarousel);
    });
  }

  Future<void> _goToSignup() async {
    final coordinator = ref.read(onboardingCoordinatorProvider.notifier);
    await coordinator.setPath(OnboardingPath.owner);
    await coordinator.goToStep(OnboardingStep.signup);
    if (mounted)
      context.go(OnboardingRoutes.signupPathFor(OnboardingPath.owner));
  }

  @override
  Widget build(BuildContext context) {
    final carouselIndex =
        ref.watch(onboardingCoordinatorProvider).carouselIndex;
    _pageController ??= PageController(initialPage: carouselIndex);
    final isLastSlide = carouselIndex == _slideArt.length - 1;
    final l10n = context.onboardingL10n;

    return PopScope(
      canPop: carouselIndex == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
        await _pageController?.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
      child: OnboardingScaffold(
        showSkip: !isLastSlide,
        onSkip: _goToSignup,
        bottom: OnboardingPrimaryButton(
          buttonKey: OnboardingIntegrationKeys.ownerCarouselPrimary,
          label: isLastSlide
              ? l10n.onboarding_carousel_get_started
              : l10n.onboarding_carousel_next,
          onPressed: () {
            if (!isLastSlide) {
              _pageController?.nextPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            } else {
              _goToSignup();
            }
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            OnboardingCarousel(
              itemCount: _slideArt.length,
              currentIndex: carouselIndex,
              controller: _pageController,
              pageHeight: 420,
              onPageChanged: (index) {
                ref
                    .read(onboardingCoordinatorProvider.notifier)
                    .setCarouselIndex(index);
              },
              itemBuilder: (context, index) {
                final slide = onboardingOwnerCarouselSlide(l10n, index);
                return Column(
                  children: [
                    _slideArt[index](),
                    const SizedBox(height: 28),
                    OnboardingHeadline(slide.$1, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OnboardingSupportText(slide.$2,
                        textAlign: TextAlign.center),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
