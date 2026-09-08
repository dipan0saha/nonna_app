import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_follower_helpers.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_buttons.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_carousel_art.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_fields.dart';
import 'package:nonna_app/features/onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Follower welcome carousel — 5 slides per prototype (#28, #60).
class FollowerCarouselScreen extends ConsumerStatefulWidget {
  const FollowerCarouselScreen({super.key});

  @override
  ConsumerState<FollowerCarouselScreen> createState() =>
      _FollowerCarouselScreenState();
}

class _FollowerCarouselScreenState
    extends ConsumerState<FollowerCarouselScreen> {
  PageController? _pageController;
  var _syncedStep = false;
  var _isBorn = false;
  var _loadedBaby = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_syncedStep) {
      _syncedStep = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(onboardingCoordinatorProvider.notifier)
            .syncStepForRoute(OnboardingRoutes.followerCarousel);
        _loadBabyBornStatus();
      });
    }
  }

  Future<void> _loadBabyBornStatus() async {
    if (_loadedBaby) return;
    final babyId = ref.read(inviteAcceptProvider).babyProfileId ??
        ref.read(selectedBabyProfileProvider);
    if (babyId == null) return;
    try {
      final row = await ref
          .read(databaseServiceProvider)
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyId)
          .maybeSingle();
      if (!mounted || row == null) return;
      setState(() {
        _isBorn = row['actual_birth_date'] != null;
        _loadedBaby = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loadedBaby = true);
    }
  }

  List<(String, String, Widget Function())> get _slides {
    final branchSlide = _isBorn
        ? (
            'Relive every milestone in the Gallery',
            'Baby is already here. See the first photos and everything since.',
            OnboardingCarouselSlideArt.photoIcon,
          )
        : (
            'Vote & guess in Family Fun',
            'Suggest names, vote on favorites, and guess the birthdate. Results reveal once baby arrives.',
            OnboardingCarouselSlideArt.photoIcon,
          );

    return [
      (
        "Welcome, you're in!",
        'A private space just for the family and friends closest to your circle.',
        OnboardingCarouselSlideArt.homeIcon,
      ),
      (
        'Squish photos & leave comments',
        'Tap the heart to "squish" any photo the family shares.',
        OnboardingCarouselSlideArt.peopleIcon,
      ),
      (
        'Never miss what\'s next',
        'See upcoming events, like gender reveals and baby showers, and RSVP right from the app.',
        OnboardingCarouselSlideArt.calendarIcon,
      ),
      branchSlide,
      (
        'Get updates your way',
        'Choose how often you hear from us: real-time, daily, or a weekly digest. You can change this anytime.',
        OnboardingCarouselSlideArt.calendarIcon,
      ),
    ];
  }

  Future<void> _skipToHome() async {
    await finishFollowerOnboardingAndGoHome(ref: ref, context: context);
  }

  Future<void> _handleBack() async {
    final route =
        await ref.read(onboardingCoordinatorProvider.notifier).goBack();
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final carouselIndex =
        ref.watch(onboardingCoordinatorProvider).carouselIndex;
    _pageController ??= PageController(initialPage: carouselIndex);
    final slides = _slides;
    final isLastSlide = carouselIndex == slides.length - 1;

    return PopScope(
      canPop: carouselIndex == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
        await _pageController?.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
      child: OnboardingScaffold(
        showSkip: !isLastSlide,
        onSkip: _skipToHome,
        bottom: OnboardingPrimaryButton(
          label: isLastSlide ? 'Get Started' : 'Next',
          onPressed: () {
            if (!isLastSlide) {
              _pageController?.nextPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
              ref
                  .read(onboardingCoordinatorProvider.notifier)
                  .setCarouselIndex(carouselIndex + 1);
              return;
            }
            _skipToHome();
          },
        ),
        body: OnboardingCarousel(
          itemCount: slides.length,
          currentIndex: carouselIndex,
          controller: _pageController,
          pageHeight: 420,
          onPageChanged: (index) => ref
              .read(onboardingCoordinatorProvider.notifier)
              .setCarouselIndex(index),
          itemBuilder: (context, index) {
            final slide = slides[index];
            return Column(
              children: [
                slide.$3(),
                const SizedBox(height: 28),
                OnboardingHeadline(slide.$1, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OnboardingSupportText(slide.$2, textAlign: TextAlign.center),
              ],
            );
          },
        ),
      ),
    );
  }
}
