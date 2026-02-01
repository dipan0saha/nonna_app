import 'package:flutter/material.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Tile styling system for consistent card and tile design
///
/// Provides standardized styling for tiles/cards throughout the app:
/// - Container properties (padding, margin, decoration)
/// - Header styles
/// - Shadow and elevation
/// - Border radius
/// - Tile variants (default, compact, expanded)
///
/// All tiles maintain consistent design language from the demo app.
class TileStyles {
  // Prevent instantiation
  TileStyles._();

  // ============================================================
  // Border Radius
  // ============================================================

  /// Default tile border radius - matches demo app
  static const double borderRadius = 16.0;

  /// Small border radius for compact tiles
  static const double borderRadiusSmall = 12.0;

  /// Large border radius for prominent tiles
  static const double borderRadiusLarge = 20.0;

  /// Circular border radius
  static const double borderRadiusCircular = 999.0;

  // ============================================================
  // Padding
  // ============================================================

  /// Default tile content padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);

  /// Compact tile padding
  static const EdgeInsets compactPadding = EdgeInsets.all(12.0);

  /// Expanded tile padding
  static const EdgeInsets expandedPadding = EdgeInsets.all(20.0);

  /// Tile header padding
  static const EdgeInsets headerPadding = EdgeInsets.only(
    left: 16.0,
    right: 16.0,
    top: 16.0,
    bottom: 12.0,
  );

  /// Tile footer padding
  static const EdgeInsets footerPadding = EdgeInsets.only(
    left: 16.0,
    right: 16.0,
    top: 12.0,
    bottom: 16.0,
  );

  /// Horizontal padding only
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
  );

  /// Vertical padding only
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(
    vertical: 16.0,
  );

  // ============================================================
  // Spacing
  // ============================================================

  /// Space between tiles in a list
  static const double tileSeparation = 12.0;

  /// Space between tile header and content
  static const double headerContentGap = 12.0;

  /// Space between tile content and footer
  static const double contentFooterGap = 12.0;

  /// Space within tile content sections
  static const double contentGap = 8.0;

  // ============================================================
  // Elevation & Shadow
  // ============================================================

  /// Default tile elevation
  static const double elevation = 2.0;

  /// Hover/pressed tile elevation
  static const double elevationHover = 4.0;

  /// Prominent tile elevation
  static const double elevationProminent = 8.0;

  /// Default tile shadow
  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8.0,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  /// Hover/pressed tile shadow
  static List<BoxShadow> get hoverShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 12.0,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Prominent tile shadow
  static List<BoxShadow> get prominentShadow => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 16.0,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  /// No shadow
  static List<BoxShadow> get noShadow => [];

  // ============================================================
  // Decoration Presets
  // ============================================================

  /// Default tile decoration
  static BoxDecoration get defaultDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadow,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Compact tile decoration
  static BoxDecoration get compactDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        boxShadow: defaultShadow,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Expanded tile decoration
  static BoxDecoration get expandedDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        boxShadow: prominentShadow,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  /// Flat tile decoration (no shadow)
  static BoxDecoration get flatDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      );

  /// Outlined tile decoration
  static BoxDecoration get outlinedDecoration => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      );

  /// Primary colored tile decoration
  static BoxDecoration get primaryDecoration => BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadow,
      );

  /// Primary light colored tile decoration
  static BoxDecoration get primaryLightDecoration => BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadow,
      );

  /// Pale/subtle tile decoration
  static BoxDecoration get paleDecoration => BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.1),
          width: 1.0,
        ),
      );

  // ============================================================
  // Interactive States
  // ============================================================

  /// Decoration for pressed/tapped state
  static BoxDecoration get pressedDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hoverShadow,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      );

  /// Decoration for disabled state
  static BoxDecoration get disabledDecoration => BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
      );

  /// Decoration for selected state
  static BoxDecoration get selectedDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadow,
        border: Border.all(
          color: AppColors.primary,
          width: 2.0,
        ),
      );

  /// Decoration for error state
  static BoxDecoration get errorDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadow,
        border: Border.all(
          color: AppColors.error,
          width: 1.5,
        ),
      );

  // ============================================================
  // Tile Container Widget
  // ============================================================

  /// Create a standard tile container
  static Widget container({
    required Widget child,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    VoidCallback? onTap,
  }) {
    final container = Container(
      padding: padding ?? defaultPadding,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }

  /// Create a compact tile container
  static Widget compactContainer({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return container(
      padding: padding ?? compactPadding,
      decoration: compactDecoration,
      onTap: onTap,
      child: child,
    );
  }

  /// Create an expanded tile container
  static Widget expandedContainer({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return container(
      padding: padding ?? expandedPadding,
      decoration: expandedDecoration,
      onTap: onTap,
      child: child,
    );
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Create decoration with custom color
  static BoxDecoration decorationWithColor(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: defaultShadow,
    );
  }

  /// Create decoration with custom border radius
  static BoxDecoration decorationWithRadius(double radius) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: defaultShadow,
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.1),
        width: 1.0,
      ),
    );
  }

  /// Create decoration with gradient
  static BoxDecoration decorationWithGradient(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: defaultShadow,
    );
  }

  /// Get border radius with custom value
  static BorderRadius customBorderRadius(double radius) {
    return BorderRadius.circular(radius);
  }

  /// Get asymmetric border radius (top only)
  static BorderRadius topBorderRadius([double? radius]) {
    return BorderRadius.vertical(
      top: Radius.circular(radius ?? borderRadius),
    );
  }

  /// Get asymmetric border radius (bottom only)
  static BorderRadius bottomBorderRadius([double? radius]) {
    return BorderRadius.vertical(
      bottom: Radius.circular(radius ?? borderRadius),
    );
  }

  /// Get spacing between tiles
  static SizedBox tileSeparator() {
    return const SizedBox(height: tileSeparation);
  }

  /// Get gap between header and content
  static SizedBox headerGap() {
    return const SizedBox(height: headerContentGap);
  }

  /// Get gap between content and footer
  static SizedBox footerGap() {
    return const SizedBox(height: contentFooterGap);
  }

  /// Get gap within content
  static SizedBox contentSeparator() {
    return const SizedBox(height: contentGap);
  }
}
