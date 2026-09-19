import 'package:flutter/material.dart';

import 'package:nonna_app/core/themes/colors.dart';

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

/// Static slide art presets (palette matches [AppTheme.lightTheme]).
class OnboardingCarouselSlideArt {
  static Widget homeIcon() => OnboardingCarouselArt(
        backgroundColor: AppColors.sageTint,
        child: Icon(
          Icons.home_outlined,
          size: 64,
          color: AppColors.primaryDark,
        ),
      );

  static Widget peopleIcon() => OnboardingCarouselArt(
        backgroundColor: AppColors.peachTint,
        child: Icon(
          Icons.people_outline,
          size: 64,
          color: AppColors.secondaryDark,
        ),
      );

  static Widget calendarIcon() => OnboardingCarouselArt(
        backgroundColor: AppColors.sageTint,
        child: Icon(
          Icons.calendar_month_outlined,
          size: 64,
          color: AppColors.primaryDark,
        ),
      );

  static Widget photoIcon() => OnboardingCarouselArt(
        backgroundColor: AppColors.peachTint,
        child: Icon(
          Icons.photo_library_outlined,
          size: 64,
          color: AppColors.secondaryDark,
        ),
      );
}
