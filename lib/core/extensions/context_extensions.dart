import 'package:flutter/material.dart';

/// Extension methods for BuildContext
///
/// Provides convenient shortcuts for accessing theme, MediaQuery,
/// Navigator, and ScaffoldMessenger from context.
extension ContextExtensions on BuildContext {
  // ============================================================
  // Theme Access
  // ============================================================

  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get the primary color
  Color get primaryColor => colorScheme.primary;

  /// Get the secondary color
  Color get secondaryColor => colorScheme.secondary;

  /// Get the background color
  Color get backgroundColor => colorScheme.surface;

  /// Get the error color
  Color get errorColor => colorScheme.error;

  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode is enabled
  bool get isLightMode => theme.brightness == Brightness.light;

  // ============================================================
  // MediaQuery Shortcuts
  // ============================================================

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get device pixel ratio
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Get text scale factor
  double get textScaleFactor => MediaQuery.of(this).textScaler.scale(1.0);

  /// Get screen orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Check if orientation is portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if orientation is landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Get safe area padding
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Get view padding
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ============================================================
  // Navigator Shortcuts
  // ============================================================

  /// Get the navigator
  NavigatorState get navigator => Navigator.of(this);

  /// Push a new route
  Future<T?> push<T extends Object?>(Route<T> route) {
    return navigator.push(route);
  }

  /// Push a named route
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }

  /// Pop the current route
  void pop<T extends Object?>([T? result]) {
    return navigator.pop(result);
  }

  /// Check if can pop
  bool get canPop => navigator.canPop();

  /// Pop until a predicate is satisfied
  void popUntil(bool Function(Route<dynamic>) predicate) {
    return navigator.popUntil(predicate);
  }

  /// Push and remove until
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigator.pushNamedAndRemoveUntil(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Push replacement
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> route, {
    TO? result,
  }) {
    return navigator.pushReplacement(route, result: result);
  }

  /// Push replacement named
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigator.pushReplacementNamed(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  // ============================================================
  // Scaffold Messenger Shortcuts
  // ============================================================

  /// Get scaffold messenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Show a snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show an error snackbar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: errorColor,
    );
  }

  /// Show a success snackbar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      message,
      duration: duration,
      backgroundColor: Colors.green,
    );
  }

  /// Hide current snackbar
  void hideCurrentSnackBar() {
    scaffoldMessenger.hideCurrentSnackBar();
  }

  // ============================================================
  // Focus Shortcuts
  // ============================================================

  /// Request focus on a node
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  /// Unfocus (dismiss keyboard)
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Check if a node has focus
  bool hasFocus(FocusNode node) {
    return FocusScope.of(this).hasFocus;
  }

  // ============================================================
  // Dialog Shortcuts
  // ============================================================

  /// Show a dialog
  Future<T?> showDialogCustom<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show a bottom sheet
  Future<T?> showBottomSheetCustom<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      builder: builder,
    );
  }

  /// Show alert dialog
  Future<bool?> showAlertDialog({
    required String title,
    required String message,
    String positiveButton = 'OK',
    String? negativeButton,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (negativeButton != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(negativeButton),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(positiveButton),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Responsive Helpers
  // ============================================================

  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (width >= 600 && width < 1024)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Check if device is desktop (width >= 1024)
  bool get isDesktop => screenWidth >= 1024;

  /// Get responsive value based on screen width
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  // ============================================================
  // Localization Shortcuts
  // ============================================================

  /// Get the current locale
  Locale get locale => Localizations.localeOf(this);

  /// Get the language code
  String get languageCode => locale.languageCode;
}
