import 'package:flutter/widgets.dart';

/// App-wide spacing constants for consistent layout
///
/// Provides a systematic spacing scale to ensure visual consistency
/// across all screens and components. Based on an 8px base unit.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.m),
///   child: ...
/// )
/// ```
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  // ============================================================
  // Spacing Scale (8px base unit)
  // ============================================================

  /// Extra small spacing - 8px
  /// Use for: tight spacing between related elements
  static const double xs = 8.0;

  /// Small spacing - 12px
  /// Use for: compact layouts, dense lists
  static const double s = 12.0;

  /// Medium spacing - 16px (default)
  /// Use for: standard padding, general spacing
  static const double m = 16.0;

  /// Large spacing - 24px
  /// Use for: section spacing, screen padding
  static const double l = 24.0;

  /// Extra large spacing - 32px
  /// Use for: major section breaks, screen top/bottom padding
  static const double xl = 32.0;

  /// Extra extra large spacing - 48px
  /// Use for: significant visual separation
  static const double xxl = 48.0;

  // ============================================================
  // Common EdgeInsets Presets
  // ============================================================

  /// Screen padding - EdgeInsets.all(24.0)
  /// Use for: main screen content padding
  static const screenPadding = EdgeInsets.all(l);

  /// Card padding - EdgeInsets.all(16.0)
  /// Use for: card/tile content padding
  static const cardPadding = EdgeInsets.all(m);

  /// Compact padding - EdgeInsets.all(12.0)
  /// Use for: dense UI elements
  static const compactPadding = EdgeInsets.all(s);

  /// Horizontal padding - EdgeInsets.symmetric(horizontal: 16.0)
  /// Use for: horizontal content margins
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: m);

  /// Vertical padding - EdgeInsets.symmetric(vertical: 16.0)
  /// Use for: vertical content spacing
  static const verticalPadding = EdgeInsets.symmetric(vertical: m);

  // ============================================================
  // Common SizedBox Presets
  // ============================================================

  /// Vertical gap - 8px
  static const verticalGapXS = SizedBox(height: xs);

  /// Vertical gap - 12px
  static const verticalGapS = SizedBox(height: s);

  /// Vertical gap - 16px
  static const verticalGapM = SizedBox(height: m);

  /// Vertical gap - 24px
  static const verticalGapL = SizedBox(height: l);

  /// Vertical gap - 32px
  static const verticalGapXL = SizedBox(height: xl);

  /// Horizontal gap - 8px
  static const horizontalGapXS = SizedBox(width: xs);

  /// Horizontal gap - 12px
  static const horizontalGapS = SizedBox(width: s);

  /// Horizontal gap - 16px
  static const horizontalGapM = SizedBox(width: m);

  /// Horizontal gap - 24px
  static const horizontalGapL = SizedBox(width: l);

  /// Horizontal gap - 32px
  static const horizontalGapXL = SizedBox(width: xl);
}
