import 'package:flutter/material.dart';

import 'app_metrics.dart';
import 'colors.dart';

/// @deprecated Use [AppColors], [AppMetrics], and [AppTheme.lightTheme] instead.
@Deprecated('Use AppColors and Theme.of(context)')
typedef OnboardingColors = _OnboardingColorsDeprecated;

/// @deprecated Use [AppMetrics] instead.
@Deprecated('Use AppMetrics')
typedef OnboardingMetrics = AppMetrics;

class _OnboardingColorsDeprecated {
  _OnboardingColorsDeprecated._();

  static const Color sage = AppColors.primary;
  static const Color sageDark = AppColors.primaryDark;
  static const Color sageTint = AppColors.sageTint;
  static const Color peach = AppColors.secondary;
  static const Color peachDark = AppColors.secondaryDark;
  static const Color peachTint = AppColors.peachTint;
  static const Color text = AppColors.textPrimary;
  static const Color muted = AppColors.muted;
  static const Color border = AppColors.border;
  static const Color surface = AppColors.surface;
  static const Color primaryButtonText = AppColors.primaryButtonForeground;
}

/// @deprecated Onboarding uses global [AppTheme.lightTheme].
@Deprecated('Use AppTheme.lightTheme')
class OnboardingTheme {
  OnboardingTheme._();

  @Deprecated('Use AppTheme.lightTheme')
  static ThemeData get themeData => throw UnsupportedError(
        'OnboardingTheme.themeData was removed; use AppTheme.lightTheme',
      );
}
