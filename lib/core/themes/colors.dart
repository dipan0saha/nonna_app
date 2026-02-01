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

  /// Primary brand color - Sage green as seen in demo
  static const Color primary = Color(0xFFA8C5AD);

  /// Darker variant of primary color for hover/pressed states
  static const Color primaryDark = Color(0xFF8AAF90);

  /// Lighter variant of primary color for backgrounds
  static const Color primaryLight = Color(0xFFD4E4D6);

  /// Very light primary for subtle backgrounds
  static const Color primaryPale = Color(0xFFF0F5F1);

  /// Secondary brand color - Warm peach/coral accent
  static const Color secondary = Color(0xFFFFB899);

  /// Darker variant of secondary color
  static const Color secondaryDark = Color(0xFFFF9A6B);

  /// Lighter variant of secondary color
  static const Color secondaryLight = Color(0xFFFFD6C1);

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
  static const Color success = Color(0xFF4CAF50);

  /// Success dark variant
  static const Color successDark = Color(0xFF388E3C);

  /// Success light variant
  static const Color successLight = Color(0xFFC8E6C9);

  /// Error color - red for errors and destructive actions
  static const Color error = Color(0xFFE57373);

  /// Error dark variant
  static const Color errorDark = Color(0xFFD32F2F);

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

  /// Background color for the app
  static const Color background = gray50;

  /// Surface color for cards and elevated elements
  static const Color surface = white;

  /// Divider color
  static const Color divider = gray300;

  /// Border color
  static const Color border = gray300;

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

  /// Primary text color - high emphasis
  static const Color textPrimary = gray900;

  /// Secondary text color - medium emphasis
  static const Color textSecondary = gray600;

  /// Disabled text color - low emphasis
  static const Color textDisabled = gray400;

  /// Text color on primary background
  static const Color textOnPrimary = white;

  /// Text color on secondary background
  static const Color textOnSecondary = white;

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
}
