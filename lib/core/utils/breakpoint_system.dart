import 'package:flutter/widgets.dart';

/// Named breakpoints used by the design system.
enum Breakpoint {
  /// < 600 dp — phones (covers all widths below the sm threshold).
  xs,

  /// 600 dp – 1023 dp — standard phones and small tablets.
  sm,

  /// 1024 dp – 1439 dp — tablets.
  md,

  /// 1440 dp – 1919 dp — laptops / small desktops.
  lg,

  /// ≥ 1920 dp — large desktops / TV.
  xl,
}

/// Breakpoint system for responsive layouts.
///
/// **Functional Requirements**: Section 3.30 - Responsive Layouts
///
/// Complements [ScreenSizeUtils] with finer-grained named breakpoints.
///
/// Example:
/// ```dart
/// final padding = BreakpointSystem.value<double>(
///   context,
///   xs: 8,
///   sm: 12,
///   md: 16,
///   lg: 24,
/// );
/// ```
class BreakpointSystem {
  BreakpointSystem._();

  // ── Raw pixel thresholds ───────────────────────────────────────────────────

  /// Minimum supported width (very small phones).
  static const double xs = 320.0;

  /// Small phones.
  static const double sm = 600.0;

  /// Tablets.
  static const double md = 1024.0;

  /// Laptops / small desktops.
  static const double lg = 1440.0;

  /// Large desktops.
  static const double xl = 1920.0;

  // ── Width-based predicates ─────────────────────────────────────────────────

  static bool isXs(double width) => width < sm;
  static bool isSm(double width) => width >= sm && width < md;
  static bool isMd(double width) => width >= md && width < lg;
  static bool isLg(double width) => width >= lg && width < xl;
  static bool isXl(double width) => width >= xl;

  // ── Context helpers ────────────────────────────────────────────────────────

  /// Returns the current screen width.
  static double currentWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Returns the active [Breakpoint] for the given [context].
  static Breakpoint current(BuildContext context) {
    final w = currentWidth(context);
    if (isXl(w)) return Breakpoint.xl;
    if (isLg(w)) return Breakpoint.lg;
    if (isMd(w)) return Breakpoint.md;
    if (isSm(w)) return Breakpoint.sm;
    return Breakpoint.xs;
  }

  // ── Value selector ─────────────────────────────────────────────────────────

  /// Returns the value that matches the current breakpoint, falling back to
  /// the next smaller breakpoint when a larger one is not provided.
  ///
  /// [xs] is required; all others are optional and cascade down.
  static T value<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final bp = current(context);
    switch (bp) {
      case Breakpoint.xl:
        return xl ?? lg ?? md ?? sm ?? xs;
      case Breakpoint.lg:
        return lg ?? md ?? sm ?? xs;
      case Breakpoint.md:
        return md ?? sm ?? xs;
      case Breakpoint.sm:
        return sm ?? xs;
      case Breakpoint.xs:
        return xs;
    }
  }
}
