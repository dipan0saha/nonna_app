import 'package:flutter/material.dart';

/// App color palette definitions
///
/// Defines the complete color system for the Nonna app, including:
/// - Brand colors (sage green primary theme from demo)
/// - Semantic colors (success, error, warning, info)
/// - Role-specific colors
/// - Neutral grays
/// - Opacity variants
///
/// All colors are chosen to meet WCAG 2.1 Level AA contrast requirements.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================
  // Brand Colors (From Demo App)
  // ============================================================

  /// Primary brand color — sage (onboarding prototype)
  static const Color primary = Color(0xFFA8C99B);

  /// Darker sage for focus states and accents
  static const Color primaryDark = Color(0xFF7FAE6E);

  /// Light sage for selected backgrounds
  static const Color primaryLight = Color(0xFFEAF3E4);

  /// Very light sage tint
  static const Color primaryPale = Color(0xFFEAF3E4);

  /// Secondary brand color — peach (onboarding prototype)
  static const Color secondary = Color(0xFFF5B99B);

  /// Darker peach accent
  static const Color secondaryDark = Color(0xFFEF9F76);

  /// Light peach tint
  static const Color secondaryLight = Color(0xFFFCE8DC);

  /// Sage tint (alias for extension / cards)
  static const Color sageTint = primaryLight;

  /// Peach tint
  static const Color peachTint = secondaryLight;

  /// Muted supporting text (prototype)
  static const Color muted = Color(0xFF9B9B9B);

  /// Primary CTA label on sage buttons
  static const Color primaryButtonForeground = Color(0xFF1C2E17);

  // ============================================================
  // Neutral Colors
  // ============================================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Very light gray for backgrounds
  static const Color gray50 = Color(0xFFFAFAFA);

  /// Light gray for borders and dividers
  static const Color gray100 = Color(0xFFF5F5F5);

  /// Subtle gray for disabled states
  static const Color gray200 = Color(0xFFEEEEEE);

  /// Medium light gray
  static const Color gray300 = Color(0xFFE0E0E0);

  /// Medium gray
  static const Color gray400 = Color(0xFFBDBDBD);

  /// Medium dark gray
  static const Color gray500 = Color(0xFF9E9E9E);

  /// Dark gray for secondary text
  static const Color gray600 = Color(0xFF757575);

  /// Darker gray for primary text
  static const Color gray700 = Color(0xFF616161);

  /// Very dark gray
  static const Color gray800 = Color(0xFF424242);

  /// Almost black
  static const Color gray900 = Color(0xFF212121);

  // ============================================================
  // Semantic Colors
  // ============================================================

  /// Success color - green for positive actions
  /// Updated to meet WCAG AA contrast requirements (4.5:1 on white)
  static const Color success = Color(0xFF2E7D32);

  /// Success dark variant
  static const Color successDark = Color(0xFF1B5E20);

  /// Success light variant
  static const Color successLight = Color(0xFFC8E6C9);

  /// Error color - red for errors and destructive actions
  /// Updated to meet WCAG AA contrast requirements (4.5:1 on white)
  static const Color error = Color(0xFFD32F2F);

  /// Error dark variant
  static const Color errorDark = Color(0xFFC62828);

  /// Error light variant
  static const Color errorLight = Color(0xFFFFCDD2);

  /// Warning color - amber for warnings
  static const Color warning = Color(0xFFFFB74D);

  /// Warning dark variant
  static const Color warningDark = Color(0xFFF57C00);

  /// Warning light variant
  static const Color warningLight = Color(0xFFFFE0B2);

  /// Info color - blue for informational messages
  static const Color info = Color(0xFF64B5F6);

  /// Info dark variant
  static const Color infoDark = Color(0xFF1976D2);

  /// Info light variant
  static const Color infoLight = Color(0xFFBBDEFB);

  // ============================================================
  // Role-Specific Colors (for baby profile roles)
  // ============================================================

  /// Owner role color - distinct blue
  static const Color roleOwner = Color(0xFF5C7CFA);

  /// Partner role color - distinct purple
  static const Color rolePartner = Color(0xFF9775FA);

  /// Family role color - warm orange
  static const Color roleFamily = Color(0xFFFF922B);

  /// Friend role color - teal
  static const Color roleFriend = Color(0xFF20C997);

  // ============================================================
  // Special Purpose Colors
  // ============================================================

  /// App scaffold background (prototype `--bg`)
  static const Color background = Color(0xFFF6F6F7);

  /// Bottom nav inactive label/icon (prototype `.nav-item`)
  static const Color navInactive = Color(0xFFB0B0B2);

  /// Surface color for cards and elevated elements
  static const Color surface = white;

  /// Divider color
  static const Color divider = Color(0xFFE9E9EA);

  /// Border color (prototype)
  static const Color border = Color(0xFFE9E9EA);

  /// Shadow color
  static const Color shadow = Color(0x1A000000);

  /// Overlay color for modals and dialogs
  static const Color overlay = Color(0x80000000);

  /// Shimmer base color for loading states
  static const Color shimmerBase = gray100;

  /// Shimmer highlight color
  static const Color shimmerHighlight = gray50;

  // ============================================================
  // Text Colors
  // ============================================================

  /// Primary text color - high emphasis (prototype)
  static const Color textPrimary = Color(0xFF2D2D2D);

  /// Secondary text color - medium emphasis
  static const Color textSecondary = muted;

  /// Disabled text color - low emphasis
  static const Color textDisabled = gray400;

  /// Text color on primary (sage) background
  static const Color textOnPrimary = primaryButtonForeground;

  /// Text color on secondary background
  static const Color textOnSecondary = gray900;

  /// Text color on dark background
  static const Color textOnDark = white;

  // ============================================================
  // Opacity Variants
  // ============================================================

  /// Primary color with 10% opacity
  static Color get primary10 => primary.withValues(alpha: 0.1);

  /// Primary color with 20% opacity
  static Color get primary20 => primary.withValues(alpha: 0.2);

  /// Primary color with 30% opacity
  static Color get primary30 => primary.withValues(alpha: 0.3);

  /// Primary color with 50% opacity
  static Color get primary50 => primary.withValues(alpha: 0.5);

  /// Black with 5% opacity - subtle overlay
  static Color get black05 => black.withValues(alpha: 0.05);

  /// Black with 10% opacity
  static Color get black10 => black.withValues(alpha: 0.1);

  /// Black with 20% opacity
  static Color get black20 => black.withValues(alpha: 0.2);

  /// Black with 40% opacity
  static Color get black40 => black.withValues(alpha: 0.4);

  /// Black with 60% opacity
  static Color get black60 => black.withValues(alpha: 0.6);

  /// White with 10% opacity
  static Color get white10 => white.withValues(alpha: 0.1);

  /// White with 20% opacity
  static Color get white20 => white.withValues(alpha: 0.2);

  /// White with 50% opacity
  static Color get white50 => white.withValues(alpha: 0.5);

  /// White with 80% opacity
  static Color get white80 => white.withValues(alpha: 0.8);

  // ============================================================
  // Gradient Colors
  // ============================================================

  /// Primary gradient for special UI elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Shimmer gradient for loading states
  static final LinearGradient shimmerGradient = LinearGradient(
    colors: [
      shimmerBase,
      shimmerHighlight,
      shimmerBase,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // Surface Opacity Helper Methods
  // ============================================================
  // These helpers provide consistent opacity values for onSurface colors
  // following Material Design standards for disabled/hint/secondary text

  /// Get onSurface color with disabled opacity (38% - Material Design standard)
  ///
  /// Use for disabled text, icons, and UI elements
  static Color onSurfaceDisabled(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.38);

  /// Get onSurface color with hint opacity (50%)
  ///
  /// Use for hint text, placeholder text, and subtle labels
  static Color onSurfaceHint(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.5);

  /// Get onSurface color with secondary text opacity (70%)
  ///
  /// Use for secondary/supporting text that's less prominent than primary text
  static Color onSurfaceSecondary(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.7);

  /// Get onSurface color with subtle opacity (30%)
  ///
  /// Use for very subtle UI elements, borders, or backgrounds
  static Color onSurfaceSubtle(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.3);

  /// Get onSurface color with medium opacity (60%)
  ///
  /// Use for medium emphasis elements
  static Color onSurfaceMedium(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.6);

  /// Get disabled background color (12% - Material Design standard)
  ///
  /// Use for disabled button backgrounds and inactive elements
  static Color disabledBackground(ColorScheme colorScheme) =>
      colorScheme.onSurface.withValues(alpha: 0.12);
}
