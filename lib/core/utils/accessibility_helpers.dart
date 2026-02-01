import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helpers for WCAG 2.1 Level AA compliance
///
/// Provides utilities for:
/// - Semantic labels
/// - Screen reader support
/// - Keyboard navigation
/// - Focus management
/// - Accessibility announcements
///
/// All helpers follow WCAG 2.1 Level AA guidelines.
class AccessibilityHelpers {
  // Prevent instantiation
  AccessibilityHelpers._();

  // ============================================================
  // Semantic Labels
  // ============================================================

  /// Create a semantic label for an image
  /// 
  /// Provides descriptive text for screen readers when displaying images.
  static Semantics imageSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      image: true,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create a semantic label for a button
  /// 
  /// Provides clear button descriptions for screen readers.
  static Semantics buttonSemantics({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Create a semantic label for a link
  static Semantics linkSemantics({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      link: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create a semantic label for a heading
  static Semantics headingSemantics({
    required Widget child,
    required String label,
    bool header = true,
  }) {
    return Semantics(
      label: label,
      header: header,
      child: child,
    );
  }

  /// Create a semantic label for a text field
  static Semantics textFieldSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool obscured = false,
    bool multiline = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      obscured: obscured,
      multiline: multiline,
      child: child,
    );
  }

  // ============================================================
  // Screen Reader Announcements
  // ============================================================

  /// Announce a message to screen readers
  /// 
  /// Use for important state changes or notifications.
  static void announce(
    BuildContext context,
    String message, {
    TextDirection? textDirection,
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    SemanticsService.announce(
      message,
      textDirection ?? Directionality.of(context),
      assertiveness: assertiveness,
    );
  }

  /// Announce a polite message (non-interrupting)
  static void announcePolite(BuildContext context, String message) {
    announce(context, message, assertiveness: Assertiveness.polite);
  }

  /// Announce an assertive message (interrupting)
  /// 
  /// Use sparingly for critical information only.
  static void announceAssertive(BuildContext context, String message) {
    announce(context, message, assertiveness: Assertiveness.assertive);
  }

  // ============================================================
  // Focus Management
  // ============================================================

  /// Request focus for a widget
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Remove focus from the current widget
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Get the next focusable node
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Get the previous focusable node
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Check if a widget has focus
  static bool hasFocus(BuildContext context, FocusNode focusNode) {
    return focusNode.hasFocus;
  }

  /// Check if any descendant has focus
  static bool hasFocusInSubtree(BuildContext context) {
    return FocusScope.of(context).hasFocus;
  }

  // ============================================================
  // Keyboard Navigation
  // ============================================================

  /// Create a keyboard-accessible button
  /// 
  /// Ensures buttons can be activated with Enter/Space keys.
  static Widget keyboardButton({
    required Widget child,
    required VoidCallback onPressed,
    FocusNode? focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) {
        if (event.logicalKey.keyLabel == ' ' ||
            event.logicalKey.keyLabel == 'Enter') {
          onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }

  /// Make a widget keyboard focusable
  static Widget focusable({
    required Widget child,
    FocusNode? focusNode,
    bool autofocus = false,
    ValueChanged<bool>? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      child: child,
    );
  }

  // ============================================================
  // ARIA-like Attributes
  // ============================================================

  /// Add expanded/collapsed state for screen readers
  static Semantics expandableSemantics({
    required Widget child,
    required bool expanded,
    String? label,
  }) {
    return Semantics(
      label: label,
      expanded: expanded,
      child: child,
    );
  }

  /// Add selected state for screen readers
  static Semantics selectableSemantics({
    required Widget child,
    required bool selected,
    String? label,
  }) {
    return Semantics(
      label: label,
      selected: selected,
      child: child,
    );
  }

  /// Add checked state for screen readers (checkboxes, radio buttons)
  static Semantics checkableSemantics({
    required Widget child,
    required bool checked,
    String? label,
    bool? mixed,
  }) {
    return Semantics(
      label: label,
      checked: checked,
      mixed: mixed,
      child: child,
    );
  }

  /// Add slider semantics
  static Semantics sliderSemantics({
    required Widget child,
    required double value,
    required double min,
    required double max,
    String? label,
    ValueChanged<double>? onIncrease,
    ValueChanged<double>? onDecrease,
  }) {
    return Semantics(
      label: label,
      value: value.toStringAsFixed(1),
      slider: true,
      onIncrease: onIncrease != null ? () => onIncrease(value + 1) : null,
      onDecrease: onDecrease != null ? () => onDecrease(value - 1) : null,
      child: child,
    );
  }

  // ============================================================
  // Touch Target Helpers
  // ============================================================

  /// Minimum touch target size per WCAG (44x44 logical pixels)
  static const double minimumTouchTarget = 44.0;

  /// Ensure a widget meets minimum touch target size
  /// 
  /// Wraps a widget with padding/sizing to meet accessibility requirements.
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = minimumTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Create a touch target wrapper with semantic label
  static Widget touchTarget({
    required Widget child,
    required String label,
    required VoidCallback onTap,
    String? hint,
    double minSize = minimumTouchTarget,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // Live Regions (for dynamic content)
  // ============================================================

  /// Create a live region for dynamic content announcements
  /// 
  /// Screen readers will announce changes to content in this region.
  static Semantics liveRegion({
    required Widget child,
    required String label,
    bool liveRegion = true,
  }) {
    return Semantics(
      label: label,
      liveRegion: liveRegion,
      child: child,
    );
  }

  // ============================================================
  // Group & Label Management
  // ============================================================

  /// Group related elements for screen readers
  static Semantics group({
    required Widget child,
    String? label,
    bool scopesRoute = false,
  }) {
    return Semantics(
      label: label,
      container: true,
      scopesRoute: scopesRoute,
      child: child,
    );
  }

  /// Hide decorative elements from screen readers
  static Widget hideFromSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  /// Merge semantics from children into parent
  static Widget mergeSemantics({
    required Widget child,
    String? label,
  }) {
    return MergeSemantics(
      child: label != null
          ? Semantics(
              label: label,
              child: child,
            )
          : child,
    );
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Check if animations should be disabled (reduce motion)
  static bool shouldDisableAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get the current text scale factor for accessibility
  static double getAccessibilityTextScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  // ============================================================
  // Common Semantic Patterns
  // ============================================================

  /// Create a loading indicator with semantic label
  static Widget loadingIndicator({
    required String label,
    Widget? child,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child ?? const CircularProgressIndicator(),
    );
  }

  /// Create an error message with semantic label
  static Widget errorMessage({
    required String message,
    Widget? child,
  }) {
    return Semantics(
      label: 'Error: $message',
      liveRegion: true,
      child: child ?? Text(message),
    );
  }

  /// Create a success message with semantic label
  static Widget successMessage({
    required String message,
    Widget? child,
  }) {
    return Semantics(
      label: 'Success: $message',
      liveRegion: true,
      child: child ?? Text(message),
    );
  }

  /// Create a badge with count for screen readers
  static Widget badge({
    required Widget child,
    required int count,
    String? label,
  }) {
    final semanticLabel = label ?? '$count unread items';
    return Semantics(
      label: semanticLabel,
      value: count.toString(),
      child: child,
    );
  }

  /// Create a progress indicator with percentage
  static Widget progress({
    required Widget child,
    required double value,
    String? label,
  }) {
    final percentage = (value * 100).toInt();
    return Semantics(
      label: label ?? 'Progress',
      value: '$percentage percent',
      child: child,
    );
  }
}
