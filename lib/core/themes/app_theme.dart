import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/themes/text_styles.dart';

/// Main theme configuration for the Nonna app
///
/// Provides complete theme data for both light and dark modes, including:
/// - Color schemes
/// - Text themes
/// - Component themes (buttons, cards, inputs, etc.)
/// - System UI overlay styles
///
/// The theme is designed to match the demo app screenshots and
/// follows Material Design 3 guidelines while maintaining brand identity.
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ============================================================
  // Light Theme
  // ============================================================

  /// Get the light theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: _lightColorScheme,

      // Typography
      textTheme: AppTextStyles.textTheme,

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // App bar theme
      appBarTheme: _lightAppBarTheme,

      // Card theme
      cardTheme: _cardTheme,

      // Elevated button theme
      elevatedButtonTheme: _elevatedButtonTheme,

      // Outlined button theme
      outlinedButtonTheme: _outlinedButtonTheme,

      // Text button theme
      textButtonTheme: _textButtonTheme,

      // Icon button theme
      iconButtonTheme: _iconButtonTheme,

      // Input decoration theme
      inputDecorationTheme: _lightInputDecorationTheme,

      // Floating action button theme
      floatingActionButtonTheme: _fabTheme,

      // Bottom navigation bar theme
      bottomNavigationBarTheme: _bottomNavBarTheme,

      // Chip theme
      chipTheme: _chipTheme,

      // Dialog theme
      dialogTheme: _dialogTheme,

      // Divider theme
      dividerTheme: _dividerTheme,

      // List tile theme
      listTileTheme: _listTileTheme,

      // Switch theme
      switchTheme: _switchTheme,

      // Checkbox theme
      checkboxTheme: _checkboxTheme,

      // Radio theme
      radioTheme: _radioTheme,

      // Slider theme
      sliderTheme: _sliderTheme,

      // Snackbar theme
      snackBarTheme: _snackBarTheme,

      // Tab bar theme
      tabBarTheme: _tabBarTheme,

      // Tooltip theme
      tooltipTheme: _tooltipTheme,

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.gray700,
        size: 24.0,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24.0,
      ),
    );
  }

  // ============================================================
  // Dark Theme
  // ============================================================

  /// Get the dark theme for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: _darkColorScheme,

      // Typography
      textTheme: _darkTextTheme,

      // Scaffold
      scaffoldBackgroundColor: AppColors.gray900,

      // App bar theme
      appBarTheme: _darkAppBarTheme,

      // Card theme
      cardTheme: _darkCardTheme,

      // Elevated button theme
      elevatedButtonTheme: _elevatedButtonTheme,

      // Outlined button theme
      outlinedButtonTheme: _outlinedButtonTheme,

      // Text button theme
      textButtonTheme: _textButtonTheme,

      // Icon button theme
      iconButtonTheme: _iconButtonTheme,

      // Input decoration theme
      inputDecorationTheme: _darkInputDecorationTheme,

      // Floating action button theme
      floatingActionButtonTheme: _fabTheme,

      // Bottom navigation bar theme
      bottomNavigationBarTheme: _darkBottomNavBarTheme,

      // Chip theme
      chipTheme: _darkChipTheme,

      // Dialog theme
      dialogTheme: _darkDialogTheme,

      // Divider theme
      dividerTheme: _darkDividerTheme,

      // List tile theme
      listTileTheme: _darkListTileTheme,

      // Switch theme
      switchTheme: _switchTheme,

      // Checkbox theme
      checkboxTheme: _checkboxTheme,

      // Radio theme
      radioTheme: _radioTheme,

      // Slider theme
      sliderTheme: _sliderTheme,

      // Snackbar theme
      snackBarTheme: _darkSnackBarTheme,

      // Tab bar theme
      tabBarTheme: _darkTabBarTheme,

      // Tooltip theme
      tooltipTheme: _tooltipTheme,

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.gray300,
        size: 24.0,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24.0,
      ),
    );
  }

  // ============================================================
  // Color Schemes
  // ============================================================

  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.textOnPrimary,
    onSecondary: AppColors.textOnSecondary,
    onSurface: AppColors.textPrimary,
    onError: AppColors.white,
    shadow: AppColors.shadow,
    outline: AppColors.border,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryDark,
    surface: AppColors.gray800,
    error: AppColors.error,
    onPrimary: AppColors.textOnPrimary,
    onSecondary: AppColors.textOnSecondary,
    onSurface: AppColors.white,
    onError: AppColors.white,
    shadow: AppColors.shadow,
    outline: AppColors.gray600,
  );

  // ============================================================
  // App Bar Themes
  // ============================================================

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: AppTextStyles.h5,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.gray800,
    foregroundColor: AppColors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  // ============================================================
  // Card Themes
  // ============================================================

  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 2,
    shadowColor: AppColors.shadow,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    color: AppColors.surface,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  static final CardThemeData _darkCardTheme = CardThemeData(
    elevation: 2,
    shadowColor: AppColors.shadow,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    color: AppColors.gray800,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  // ============================================================
  // Button Themes
  // ============================================================

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      disabledBackgroundColor: AppColors.gray200,
      disabledForegroundColor: AppColors.textDisabled,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(88, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: AppTextStyles.buttonMedium,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabled,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(88, 44),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: AppTextStyles.buttonMedium,
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabled,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minimumSize: const Size(64, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: AppTextStyles.buttonMedium,
    ),
  );

  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabled,
      minimumSize: const Size(48, 48),
    ),
  );

  // ============================================================
  // Input Decoration Themes
  // ============================================================

  static final InputDecorationTheme _lightInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.gray100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
    ),
    labelStyle: AppTextStyles.label,
    hintStyle: AppTextStyles.placeholder,
    errorStyle: AppTextStyles.error,
  );

  static final InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.gray800,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.gray600, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.gray600, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.gray600.withValues(alpha: 0.5)),
    ),
    labelStyle: const TextStyle(color: AppColors.gray300),
    hintStyle: const TextStyle(color: AppColors.gray500),
    errorStyle: AppTextStyles.error,
  );

  // ============================================================
  // Other Component Themes
  // ============================================================

  static final FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.gray500,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static const BottomNavigationBarThemeData _darkBottomNavBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.gray800,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.gray500,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.gray100,
    deleteIconColor: AppColors.textSecondary,
    disabledColor: AppColors.gray200,
    selectedColor: AppColors.primaryLight,
    secondarySelectedColor: AppColors.secondaryLight,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: AppTextStyles.labelSmall,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  static final ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: AppColors.gray700,
    deleteIconColor: AppColors.gray300,
    disabledColor: AppColors.gray800,
    selectedColor: AppColors.primaryDark,
    secondarySelectedColor: AppColors.secondaryDark,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  static final DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    titleTextStyle: AppTextStyles.h4,
  );

  static final DialogThemeData _darkDialogTheme = DialogThemeData(
    backgroundColor: AppColors.gray800,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.gray700,
    thickness: 1,
    space: 1,
  );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minLeadingWidth: 40,
    iconColor: AppColors.gray600,
    textColor: AppColors.textPrimary,
  );

  static const ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minLeadingWidth: 40,
    iconColor: AppColors.gray400,
    textColor: AppColors.white,
  );

  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.white;
      }
      return AppColors.gray400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.gray300;
    }),
  );

  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.white),
    side: const BorderSide(color: AppColors.border, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  );

  static final RadioThemeData _radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.gray400;
    }),
  );

  static final SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.gray300,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary10,
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: const TextStyle(
      color: AppColors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.gray800,
    contentTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
  );

  static const SnackBarThemeData _darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.gray700,
    contentTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
  );

  static const TabBarThemeData _tabBarTheme = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: AppColors.divider,
  );

  static const TabBarThemeData _darkTabBarTheme = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.gray400,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: AppColors.gray700,
  );

  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.gray800,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    textStyle: TextStyle(
      color: AppColors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );

  // ============================================================
  // Dark Text Theme
  // ============================================================

  static TextTheme get _darkTextTheme {
    return AppTextStyles.textTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    );
  }
}
