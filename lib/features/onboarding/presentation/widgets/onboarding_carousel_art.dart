import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/onboarding_theme.dart';

/// Decorative icon blob for owner carousel slides (prototype art).
class OnboardingCarouselArt extends StatelessWidget {
  const OnboardingCarouselArt({
    super.key,
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(36),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class OnboardingCarouselSlideArt {
  static Widget homeIcon() => const OnboardingCarouselArt(
        backgroundColor: OnboardingColors.sageTint,
        child: Icon(Icons.home_outlined,
            size: 64, color: OnboardingColors.sageDark),
      );

  static Widget peopleIcon() => const OnboardingCarouselArt(
        backgroundColor: OnboardingColors.peachTint,
        child: Icon(Icons.people_outline,
            size: 64, color: OnboardingColors.peachDark),
      );

  static Widget calendarIcon() => const OnboardingCarouselArt(
        backgroundColor: OnboardingColors.sageTint,
        child: Icon(Icons.calendar_month_outlined,
            size: 64, color: OnboardingColors.sageDark),
      );

  static Widget photoIcon() => const OnboardingCarouselArt(
        backgroundColor: OnboardingColors.peachTint,
        child: Icon(Icons.photo_library_outlined,
            size: 64, color: OnboardingColors.peachDark),
      );
}
