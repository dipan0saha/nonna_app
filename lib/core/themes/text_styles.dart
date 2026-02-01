import 'package:flutter/material.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Typography system for the Nonna app
///
/// Provides a comprehensive text style system with:
/// - Heading styles (H1-H6)
/// - Body text styles (large, medium, small)
/// - Caption and label styles
/// - Button text styles
/// - Special purpose styles
///
/// All text styles support dynamic type scaling and maintain
/// WCAG 2.1 Level AA readability standards.
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // ============================================================
  // Font Configuration
  // ============================================================

  /// Default font family for the app
  static const String fontFamily = 'SF Pro Display';

  /// Fallback font families
  static const List<String> fontFamilyFallback = [
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  // ============================================================
  // Heading Styles
  // ============================================================

  /// H1 heading - largest heading
  /// Use for: Page titles, major section headers
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// H2 heading - large heading
  /// Use for: Screen titles, major headings
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// H3 heading - medium-large heading
  /// Use for: Section titles, dialog titles
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// H4 heading - medium heading
  /// Use for: Subsection titles, card headers
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// H5 heading - small-medium heading
  /// Use for: List item titles, form section headers
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// H6 heading - smallest heading
  /// Use for: Minor headings, emphasized labels
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // Body Text Styles
  // ============================================================

  /// Large body text
  /// Use for: Important content, highlighted text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Medium body text (default)
  /// Use for: Main content, descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Small body text
  /// Use for: Secondary content, metadata
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// Bold body text variations
  static const TextStyle bodyLargeBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmallBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // Caption & Label Styles
  // ============================================================

  /// Caption text - largest caption
  /// Use for: Image captions, hints, helper text
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  /// Small caption text
  /// Use for: Timestamps, meta information
  static const TextStyle captionSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  /// Tiny caption text
  /// Use for: Very small metadata, badges
  static const TextStyle captionTiny = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  /// Label text - for form labels
  /// Use for: Input labels, form field labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Small label text
  /// Use for: Compact form labels, tags
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // ============================================================
  // Button Text Styles
  // ============================================================

  /// Large button text
  /// Use for: Primary action buttons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Medium button text (default)
  /// Use for: Standard buttons
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Small button text
  /// Use for: Compact buttons, inline actions
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  // ============================================================
  // Special Purpose Styles
  // ============================================================

  /// Tile title style
  /// Use for: Tile headers and titles
  static const TextStyle tileTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// Tile subtitle style
  /// Use for: Tile descriptions and subtitles
  static const TextStyle tileSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// Number display style - large
  /// Use for: Stats, counts, metrics
  static const TextStyle numberLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  /// Number display style - medium
  /// Use for: Smaller stats, inline numbers
  static const TextStyle numberMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Number display style - small
  /// Use for: Compact number displays
  static const TextStyle numberSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Link text style
  /// Use for: Hyperlinks, clickable text
  static const TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Link text style - small
  static const TextStyle linkSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Error text style
  /// Use for: Error messages, validation errors
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.error,
  );

  /// Success text style
  /// Use for: Success messages, confirmations
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.success,
  );

  /// Placeholder text style
  /// Use for: Input placeholders, empty states
  static const TextStyle placeholder = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textDisabled,
  );

  /// Overline text style
  /// Use for: Section labels, category tags
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // Text Theme for MaterialApp
  // ============================================================

  /// Get the complete TextTheme for use in MaterialApp
  static TextTheme get textTheme => const TextTheme(
        displayLarge: h1,
        displayMedium: h2,
        displaySmall: h3,
        headlineLarge: h2,
        headlineMedium: h3,
        headlineSmall: h4,
        titleLarge: h4,
        titleMedium: h5,
        titleSmall: h6,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonLarge,
        labelMedium: buttonMedium,
        labelSmall: buttonSmall,
      );

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Apply color to a text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply font weight to a text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply font size to a text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply line height to a text style
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Apply letter spacing to a text style
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  /// Create a style with primary color
  static TextStyle primary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// Create a style with secondary color
  static TextStyle secondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }

  /// Create a disabled style
  static TextStyle disabled(TextStyle style) {
    return style.copyWith(color: AppColors.textDisabled);
  }

  /// Create a style for text on primary background
  static TextStyle onPrimary(TextStyle style) {
    return style.copyWith(color: AppColors.textOnPrimary);
  }

  /// Create a style for text on dark background
  static TextStyle onDark(TextStyle style) {
    return style.copyWith(color: AppColors.textOnDark);
  }
}
