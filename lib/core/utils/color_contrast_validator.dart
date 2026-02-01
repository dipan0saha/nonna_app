import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Color contrast validator for WCAG 2.1 compliance
///
/// Provides utilities for:
/// - WCAG contrast ratio calculations
/// - Color pair validation
/// - Accessible color suggestions
/// - Contrast checking for text and UI elements
///
/// Follows WCAG 2.1 Level AA requirements:
/// - Normal text: minimum contrast ratio of 4.5:1
/// - Large text: minimum contrast ratio of 3:1
/// - UI components: minimum contrast ratio of 3:1
class ColorContrastValidator {
  // Prevent instantiation
  ColorContrastValidator._();

  // ============================================================
  // WCAG Contrast Ratio Requirements
  // ============================================================

  /// Minimum contrast ratio for normal text (WCAG Level AA)
  static const double minContrastNormalText = 4.5;

  /// Minimum contrast ratio for large text (WCAG Level AA)
  static const double minContrastLargeText = 3.0;

  /// Minimum contrast ratio for UI components (WCAG Level AA)
  static const double minContrastUI = 3.0;

  /// Minimum contrast ratio for normal text (WCAG Level AAA)
  static const double minContrastNormalTextAAA = 7.0;

  /// Minimum contrast ratio for large text (WCAG Level AAA)
  static const double minContrastLargeTextAAA = 4.5;

  /// Font size threshold for "large text" (18pt or 14pt bold)
  static const double largeTextSizeThreshold = 18.0;

  /// Font size threshold for large bold text (14pt)
  static const double largeBoldTextSizeThreshold = 14.0;

  // ============================================================
  // Contrast Ratio Calculation
  // ============================================================

  /// Calculate the relative luminance of a color
  /// 
  /// Based on WCAG 2.1 formula:
  /// https://www.w3.org/WAI/GL/wiki/Relative_luminance
  static double _relativeLuminance(Color color) {
    // Convert RGB values to sRGB
    final r = _sRGB(color.red / 255.0);
    final g = _sRGB(color.green / 255.0);
    final b = _sRGB(color.blue / 255.0);

    // Calculate relative luminance
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Convert RGB value to sRGB color space
  static double _sRGB(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Calculate contrast ratio between two colors
  /// 
  /// Returns a value between 1:1 and 21:1, where:
  /// - 1:1 means no contrast (same color)
  /// - 21:1 means maximum contrast (black on white)
  /// 
  /// Formula: (L1 + 0.05) / (L2 + 0.05)
  /// where L1 is the lighter color and L2 is the darker color
  static double contrastRatio(Color color1, Color color2) {
    final lum1 = _relativeLuminance(color1);
    final lum2 = _relativeLuminance(color2);

    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // ============================================================
  // Validation Methods
  // ============================================================

  /// Check if two colors meet WCAG Level AA contrast for normal text
  static bool isValidNormalText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastNormalText;
  }

  /// Check if two colors meet WCAG Level AA contrast for large text
  static bool isValidLargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastLargeText;
  }

  /// Check if two colors meet WCAG Level AA contrast for UI components
  static bool isValidUI(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastUI;
  }

  /// Check if two colors meet WCAG Level AAA contrast for normal text
  static bool isValidNormalTextAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastNormalTextAAA;
  }

  /// Check if two colors meet WCAG Level AAA contrast for large text
  static bool isValidLargeTextAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastLargeTextAAA;
  }

  /// Check if a text style meets contrast requirements
  /// 
  /// Automatically determines if text is "large" based on font size and weight.
  static bool isValidTextStyle({
    required TextStyle textStyle,
    required Color foreground,
    required Color background,
    bool requireAAA = false,
  }) {
    final fontSize = textStyle.fontSize ?? 14.0;
    final fontWeight = textStyle.fontWeight ?? FontWeight.normal;
    
    final isLargeText = fontSize >= largeTextSizeThreshold ||
        (fontSize >= largeBoldTextSizeThreshold && 
         fontWeight.index >= FontWeight.w700.index);

    if (requireAAA) {
      return isLargeText
          ? isValidLargeTextAAA(foreground, background)
          : isValidNormalTextAAA(foreground, background);
    } else {
      return isLargeText
          ? isValidLargeText(foreground, background)
          : isValidNormalText(foreground, background);
    }
  }

  // ============================================================
  // Contrast Level Classification
  // ============================================================

  /// Get the WCAG compliance level for a color pair
  static ContrastLevel getContrastLevel(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);

    if (ratio >= minContrastNormalTextAAA) {
      return ContrastLevel.aaa;
    } else if (ratio >= minContrastNormalText) {
      return ContrastLevel.aa;
    } else if (ratio >= minContrastLargeText) {
      return ContrastLevel.aaLarge;
    } else {
      return ContrastLevel.fail;
    }
  }

  /// Get a human-readable description of contrast quality
  static String describeContrast(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);
    
    if (ratio >= 7.0) {
      return 'Excellent (AAA)';
    } else if (ratio >= 4.5) {
      return 'Good (AA)';
    } else if (ratio >= 3.0) {
      return 'Acceptable for large text';
    } else if (ratio >= 2.0) {
      return 'Poor';
    } else {
      return 'Very poor';
    }
  }

  // ============================================================
  // Color Adjustment & Suggestions
  // ============================================================

  /// Darken a color to meet minimum contrast ratio
  /// 
  /// Returns a darker version of the color that meets the target ratio
  /// against the background, or null if not possible.
  static Color? darkenToMeetContrast(
    Color color,
    Color background, {
    double targetRatio = minContrastNormalText,
    int maxIterations = 100,
  }) {
    var testColor = color;
    var iteration = 0;

    while (iteration < maxIterations) {
      if (contrastRatio(testColor, background) >= targetRatio) {
        return testColor;
      }

      // Darken by reducing each channel by 5%
      testColor = Color.fromARGB(
        testColor.alpha,
        math.max(0, (testColor.red * 0.95).round()),
        math.max(0, (testColor.green * 0.95).round()),
        math.max(0, (testColor.blue * 0.95).round()),
      );

      // If we've reached pure black, we can't go darker
      if (testColor.red == 0 && testColor.green == 0 && testColor.blue == 0) {
        break;
      }

      iteration++;
    }

    // Return null if we couldn't meet the target
    return null;
  }

  /// Lighten a color to meet minimum contrast ratio
  /// 
  /// Returns a lighter version of the color that meets the target ratio
  /// against the background, or null if not possible.
  static Color? lightenToMeetContrast(
    Color color,
    Color background, {
    double targetRatio = minContrastNormalText,
    int maxIterations = 100,
  }) {
    var testColor = color;
    var iteration = 0;

    while (iteration < maxIterations) {
      if (contrastRatio(testColor, background) >= targetRatio) {
        return testColor;
      }

      // Lighten by increasing each channel by 5%
      testColor = Color.fromARGB(
        testColor.alpha,
        math.min(255, (testColor.red + (255 - testColor.red) * 0.05).round()),
        math.min(255, (testColor.green + (255 - testColor.green) * 0.05).round()),
        math.min(255, (testColor.blue + (255 - testColor.blue) * 0.05).round()),
      );

      // If we've reached pure white, we can't go lighter
      if (testColor.red == 255 && 
          testColor.green == 255 && 
          testColor.blue == 255) {
        break;
      }

      iteration++;
    }

    // Return null if we couldn't meet the target
    return null;
  }

  /// Get an accessible text color for a given background
  /// 
  /// Returns either black or white, whichever has better contrast.
  static Color getAccessibleTextColor(Color background) {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);

    final blackContrast = contrastRatio(black, background);
    final whiteContrast = contrastRatio(white, background);

    return blackContrast > whiteContrast ? black : white;
  }

  /// Suggest an accessible alternative color
  /// 
  /// Attempts to find a color that meets contrast requirements by
  /// trying both darkening and lightening.
  static Color suggestAccessibleColor(
    Color color,
    Color background, {
    double targetRatio = minContrastNormalText,
  }) {
    // Try the original color first
    if (contrastRatio(color, background) >= targetRatio) {
      return color;
    }

    // Try darkening
    final darkened = darkenToMeetContrast(
      color,
      background,
      targetRatio: targetRatio,
    );
    if (darkened != null) {
      return darkened;
    }

    // Try lightening
    final lightened = lightenToMeetContrast(
      color,
      background,
      targetRatio: targetRatio,
    );
    if (lightened != null) {
      return lightened;
    }

    // If all else fails, return black or white based on which is better
    return getAccessibleTextColor(background);
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Format contrast ratio as a string (e.g., "4.5:1")
  static String formatRatio(double ratio) {
    return '${ratio.toStringAsFixed(2)}:1';
  }

  /// Check if a color is light or dark
  static bool isLightColor(Color color) {
    return _relativeLuminance(color) > 0.5;
  }

  /// Check if a color is dark
  static bool isDarkColor(Color color) {
    return !isLightColor(color);
  }

  /// Get the perceived brightness of a color (0-255)
  /// 
  /// Uses the YIQ color space formula for perceived brightness.
  static double getPerceivedBrightness(Color color) {
    return (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
  }

  // ============================================================
  // Debugging & Testing
  // ============================================================

  /// Generate a contrast report for a color pair
  static ContrastReport analyzeContrast(
    Color foreground,
    Color background,
  ) {
    final ratio = contrastRatio(foreground, background);
    final level = getContrastLevel(foreground, background);

    return ContrastReport(
      foreground: foreground,
      background: background,
      ratio: ratio,
      level: level,
      passesAANormalText: isValidNormalText(foreground, background),
      passesAALargeText: isValidLargeText(foreground, background),
      passesAAANormalText: isValidNormalTextAAA(foreground, background),
      passesAAALargeText: isValidLargeTextAAA(foreground, background),
    );
  }
}

/// WCAG contrast level enumeration
enum ContrastLevel {
  /// Passes WCAG Level AAA (7:1 for normal text)
  aaa,

  /// Passes WCAG Level AA (4.5:1 for normal text)
  aa,

  /// Passes WCAG Level AA for large text only (3:1)
  aaLarge,

  /// Fails all WCAG requirements
  fail,
}

/// Contrast analysis report
class ContrastReport {
  /// Creates a contrast report
  const ContrastReport({
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.level,
    required this.passesAANormalText,
    required this.passesAALargeText,
    required this.passesAAANormalText,
    required this.passesAAALargeText,
  });

  /// Foreground color
  final Color foreground;

  /// Background color
  final Color background;

  /// Contrast ratio
  final double ratio;

  /// WCAG compliance level
  final ContrastLevel level;

  /// Passes AA for normal text
  final bool passesAANormalText;

  /// Passes AA for large text
  final bool passesAALargeText;

  /// Passes AAA for normal text
  final bool passesAAANormalText;

  /// Passes AAA for large text
  final bool passesAAALargeText;

  @override
  String toString() {
    return 'ContrastReport(\n'
        '  ratio: ${ColorContrastValidator.formatRatio(ratio)}\n'
        '  level: $level\n'
        '  AA Normal: $passesAANormalText\n'
        '  AA Large: $passesAALargeText\n'
        '  AAA Normal: $passesAAANormalText\n'
        '  AAA Large: $passesAAALargeText\n'
        ')';
  }
}
