import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Prototype design tokens for onboarding flows.
///
/// Isolated from [AppTheme] so onboarding screens match
/// La_Nonna_Onboarding_Prototype2.html without affecting the main shell.
class OnboardingColors {
  OnboardingColors._();

  static const Color sage = Color(0xFFA8C99B);
  static const Color sageDark = Color(0xFF7FAE6E);
  static const Color sageTint = Color(0xFFEAF3E4);
  static const Color peach = Color(0xFFF5B99B);
  static const Color peachDark = Color(0xFFEF9F76);
  static const Color peachTint = Color(0xFFFCE8DC);
  static const Color text = Color(0xFF2D2D2D);
  static const Color muted = Color(0xFF9B9B9B);
  static const Color border = Color(0xFFE9E9EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryButtonText = Color(0xFF1C2E17);
}

/// Typography and layout constants for onboarding screens.
class OnboardingMetrics {
  OnboardingMetrics._();

  static const double horizontalPadding = 26;
  static const double fieldRadius = 12;
  static const double buttonRadius = 999;
  static const double buttonVerticalPadding = 15;
  static const double headlineSize = 24;
  static const double supportTextSize = 14.5;
  static const double dotSize = 7;
  static const double activeDotWidth = 20;
  static const double activeDotRadius = 5;
}

/// ThemeData override for onboarding routes.
class OnboardingTheme {
  OnboardingTheme._();

  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: OnboardingColors.surface,
      colorScheme: const ColorScheme.light(
        primary: OnboardingColors.sage,
        onPrimary: OnboardingColors.primaryButtonText,
        secondary: OnboardingColors.peach,
        surface: OnboardingColors.surface,
        onSurface: OnboardingColors.text,
        outline: OnboardingColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: OnboardingColors.text,
        displayColor: OnboardingColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OnboardingColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OnboardingMetrics.fieldRadius),
          borderSide: const BorderSide(
            color: OnboardingColors.border,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OnboardingMetrics.fieldRadius),
          borderSide: const BorderSide(
            color: OnboardingColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OnboardingMetrics.fieldRadius),
          borderSide: const BorderSide(
            color: OnboardingColors.sageDark,
            width: 1.5,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          color: OnboardingColors.muted,
          fontSize: OnboardingMetrics.supportTextSize,
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: GoogleFonts.baloo2(
          fontSize: OnboardingMetrics.headlineSize,
          fontWeight: FontWeight.w700,
          color: OnboardingColors.text,
          height: 1.15,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: OnboardingMetrics.supportTextSize,
          color: OnboardingColors.muted,
          height: 1.45,
        ),
      ),
    );
  }
}
