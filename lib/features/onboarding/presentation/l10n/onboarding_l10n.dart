import 'package:flutter/material.dart';

import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

/// Onboarding copy from [AppLocalizations] — ARB source of truth for EN (#52).
extension OnboardingL10n on BuildContext {
  AppLocalizations get onboardingL10n => AppLocalizations.of(this);
}

/// Owner carousel slide copy (indexes 0–3).
(String title, String body) onboardingOwnerCarouselSlide(
  AppLocalizations l10n,
  int index,
) {
  switch (index) {
    case 0:
      return (
        l10n.onboarding_owner_carousel_slide1_title,
        l10n.onboarding_owner_carousel_slide1_body,
      );
    case 1:
      return (
        l10n.onboarding_owner_carousel_slide2_title,
        l10n.onboarding_owner_carousel_slide2_body,
      );
    case 2:
      return (
        l10n.onboarding_owner_carousel_slide3_title,
        l10n.onboarding_owner_carousel_slide3_body,
      );
    case 3:
    default:
      return (
        l10n.onboarding_owner_carousel_slide4_title,
        l10n.onboarding_owner_carousel_slide4_body,
      );
  }
}
