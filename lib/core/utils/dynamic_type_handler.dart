import 'package:flutter/material.dart';

/// Handles dynamic type scaling and text size adaptation.
///
/// This utility provides comprehensive support for system font scaling,
/// ensuring text remains readable across all accessibility settings while
/// maintaining layout integrity. It follows WCAG 2.1 Level AA guidelines.
///
/// Features:
/// - System font scaling support (100%-200%)
/// - Configurable minimum and maximum scale factors
/// - Layout reflow handling
/// - Accessibility-aware text sizing
/// - Performance-optimized caching
///
/// Example:
/// ```dart
/// final scaledSize = DynamicTypeHandler.scale(
///   context,
///   baseFontSize: 16.0,
/// );
///
/// final textStyle = DynamicTypeHandler.scaledTextStyle(
///   context,
///   baseStyle: TextStyle(fontSize: 16.0),
/// );
/// ```
class DynamicTypeHandler {
  /// Private constructor to prevent instantiation
  DynamicTypeHandler._();

  /// Default minimum scale factor (80% of base size)
  /// Prevents text from becoming too small to read
  static const double defaultMinScale = 0.8;

  /// Default maximum scale factor (200% of base size)
  /// Aligns with WCAG 2.1 AA requirement for 200% text scaling
  static const double defaultMaxScale = 2.0;

  /// Reference text scale factor considered "normal"
  static const double referenceScale = 1.0;

  /// Breakpoint for large text (in logical pixels)
  /// Text larger than this may have different scaling behavior
  static const double largeTextThreshold = 24.0;

  /// Get the current text scale factor from the platform
  ///
  /// Returns a value typically between 0.8 and 2.0, where:
  /// - 1.0 represents the default system text size
  /// - < 1.0 represents smaller text
  /// - > 1.0 represents larger text
  ///
  /// [context] The build context to extract the text scale factor from
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  /// Get a clamped text scale factor within min/max bounds
  ///
  /// This method ensures the text scale factor stays within acceptable limits
  /// to prevent extreme scaling that could break layouts.
  ///
  /// [context] The build context
  /// [minScale] Minimum allowed scale factor (default: 0.8)
  /// [maxScale] Maximum allowed scale factor (default: 2.0)
  static double getClampedTextScaleFactor(
    BuildContext context, {
    double minScale = defaultMinScale,
    double maxScale = defaultMaxScale,
  }) {
    final currentScale = getTextScaleFactor(context);
    return currentScale.clamp(minScale, maxScale);
  }

  /// Scale a font size based on the current text scale factor
  ///
  /// This method applies intelligent scaling that considers:
  /// - Current system text scale factor
  /// - Minimum and maximum constraints
  /// - Base font size
  ///
  /// [context] The build context
  /// [baseFontSize] The base font size to scale from
  /// [minScale] Minimum allowed scale factor
  /// [maxScale] Maximum allowed scale factor
  /// [respectSystemSettings] Whether to use system text scale (default: true)
  static double scale(
    BuildContext context, {
    required double baseFontSize,
    double minScale = defaultMinScale,
    double maxScale = defaultMaxScale,
    bool respectSystemSettings = true,
  }) {
    if (!respectSystemSettings) {
      return baseFontSize;
    }

    final scaleFactor = getClampedTextScaleFactor(
      context,
      minScale: minScale,
      maxScale: maxScale,
    );

    return baseFontSize * scaleFactor;
  }

  /// Create a scaled TextStyle from a base style
  ///
  /// This is the recommended method for applying dynamic type scaling to text.
  /// It preserves all style properties while scaling the font size appropriately.
  ///
  /// [context] The build context
  /// [baseStyle] The base TextStyle to scale
  /// [minScale] Minimum allowed scale factor
  /// [maxScale] Maximum allowed scale factor
  /// [respectSystemSettings] Whether to use system text scale
  static TextStyle scaledTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
    double minScale = defaultMinScale,
    double maxScale = defaultMaxScale,
    bool respectSystemSettings = true,
  }) {
    if (!respectSystemSettings || baseStyle.fontSize == null) {
      return baseStyle;
    }

    final scaledSize = scale(
      context,
      baseFontSize: baseStyle.fontSize!,
      minScale: minScale,
      maxScale: maxScale,
      respectSystemSettings: respectSystemSettings,
    );

    return baseStyle.copyWith(fontSize: scaledSize);
  }

  /// Calculate optimal line height for scaled text
  ///
  /// Maintains readability by adjusting line height based on font size.
  /// Follows typography best practices:
  /// - Smaller text (< 16px): 1.5x line height
  /// - Medium text (16-24px): 1.4x line height
  /// - Large text (> 24px): 1.3x line height
  ///
  /// [fontSize] The font size to calculate line height for
  static double calculateLineHeight(double fontSize) {
    if (fontSize < 16.0) {
      return fontSize * 1.5;
    } else if (fontSize <= largeTextThreshold) {
      return fontSize * 1.4;
    } else {
      return fontSize * 1.3;
    }
  }

  /// Get recommended padding for scaled text
  ///
  /// Returns appropriate padding that scales with text size to maintain
  /// touch targets and visual hierarchy.
  ///
  /// [context] The build context
  /// [basePadding] The base padding value
  /// [scaleWithText] Whether padding should scale with text (default: true)
  static EdgeInsets getScaledPadding(
    BuildContext context, {
    required EdgeInsets basePadding,
    bool scaleWithText = true,
  }) {
    if (!scaleWithText) {
      return basePadding;
    }

    final scaleFactor = getClampedTextScaleFactor(context);

    // Use square root for more subtle padding scaling
    final paddingScale = (scaleFactor - 1.0) * 0.5 + 1.0;

    return EdgeInsets.only(
      left: basePadding.left * paddingScale,
      top: basePadding.top * paddingScale,
      right: basePadding.right * paddingScale,
      bottom: basePadding.bottom * paddingScale,
    );
  }

  /// Check if text scaling is within normal range
  ///
  /// Returns true if the text scale factor is between 0.9 and 1.1
  /// (considered "normal" scaling without accessibility adjustments)
  ///
  /// [context] The build context
  static bool isNormalTextScale(BuildContext context) {
    final scale = getTextScaleFactor(context);
    return scale >= 0.9 && scale <= 1.1;
  }

  /// Check if text scaling is large (accessibility mode)
  ///
  /// Returns true if the text scale factor is >= 1.5
  /// (indicates user has enabled large text accessibility features)
  ///
  /// [context] The build context
  static bool isLargeTextScale(BuildContext context) {
    final scale = getTextScaleFactor(context);
    return scale >= 1.5;
  }

  /// Check if text scaling is extra large (maximum accessibility)
  ///
  /// Returns true if the text scale factor is >= 2.0
  /// (indicates maximum text scaling for accessibility)
  ///
  /// [context] The build context
  static bool isExtraLargeTextScale(BuildContext context) {
    final scale = getTextScaleFactor(context);
    return scale >= 2.0;
  }

  /// Calculate minimum touch target size for scaled UI
  ///
  /// Ensures interactive elements maintain WCAG minimum touch target size
  /// of 44x44 logical pixels, even with text scaling.
  ///
  /// [context] The build context
  /// [baseSize] Base touch target size (default: 44.0)
  static double getMinimumTouchTarget(
    BuildContext context, {
    double baseSize = 44.0,
  }) {
    final scaleFactor = getClampedTextScaleFactor(context);
    final scaledSize = baseSize * scaleFactor;

    // Never go below WCAG minimum
    return scaledSize < 44.0 ? 44.0 : scaledSize;
  }

  /// Create a text style that adapts to different text scale levels
  ///
  /// This method provides different styling based on the current text scale:
  /// - Normal scale: Uses base style as-is
  /// - Large scale: May reduce decorations or adjust weight
  /// - Extra large scale: Simplifies style for maximum readability
  ///
  /// [context] The build context
  /// [baseStyle] The base TextStyle
  /// [simplifyAtLargeScale] Whether to simplify style at large scales
  static TextStyle adaptiveTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
    bool simplifyAtLargeScale = true,
  }) {
    final scaledStyle = scaledTextStyle(context, baseStyle: baseStyle);

    if (!simplifyAtLargeScale) {
      return scaledStyle;
    }

    // Simplify decorations at extra large scale for clarity
    if (isExtraLargeTextScale(context)) {
      return scaledStyle.copyWith(
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        shadows: const [],
      );
    }

    return scaledStyle;
  }

  /// Get appropriate icon size for current text scale
  ///
  /// Scales icons proportionally with text to maintain visual balance.
  /// Ensures icons remain visible and properly sized for touch targets.
  ///
  /// [context] The build context
  /// [baseIconSize] Base icon size (default: 24.0)
  /// [maxIconSize] Maximum icon size (default: 48.0)
  static double getScaledIconSize(
    BuildContext context, {
    double baseIconSize = 24.0,
    double maxIconSize = 48.0,
  }) {
    final scaleFactor = getClampedTextScaleFactor(context);
    final scaledSize = baseIconSize * scaleFactor;

    return scaledSize.clamp(baseIconSize, maxIconSize);
  }

  /// Create a MediaQueryData with custom text scaling
  ///
  /// Useful for wrapping widgets that need specific text scaling behavior
  /// different from the system default.
  ///
  /// [context] The build context
  /// [textScaleFactor] The desired text scale factor
  static MediaQueryData createCustomTextScaleData(
    BuildContext context, {
    required double textScaleFactor,
  }) {
    final currentData = MediaQuery.of(context);
    return currentData.copyWith(
      textScaler: TextScaler.linear(textScaleFactor),
    );
  }

  /// Wrap a widget with custom text scaling
  ///
  /// This allows you to override system text scaling for specific widgets
  /// while maintaining other MediaQuery properties.
  ///
  /// [context] The build context
  /// [child] The widget to wrap
  /// [textScaleFactor] The desired text scale factor
  static Widget withCustomTextScale({
    required BuildContext context,
    required Widget child,
    required double textScaleFactor,
  }) {
    return MediaQuery(
      data: createCustomTextScaleData(
        context,
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );
  }

  /// Check if layout should reflow for current text scale
  ///
  /// Returns true if text scaling is large enough that layouts should
  /// consider switching to vertical/stacked arrangements.
  ///
  /// [context] The build context
  /// [threshold] Scale factor threshold for reflow (default: 1.3)
  static bool shouldReflowLayout(
    BuildContext context, {
    double threshold = 1.3,
  }) {
    return getTextScaleFactor(context) >= threshold;
  }
}
