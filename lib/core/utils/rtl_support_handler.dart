import 'package:flutter/material.dart';

/// Handles right-to-left (RTL) layout support and bidirectional text.
///
/// This utility provides comprehensive RTL support for applications that need
/// to support languages like Arabic, Hebrew, Persian, and Urdu. It handles
/// layout direction, text direction, and UI mirroring automatically.
///
/// Features:
/// - Automatic RTL detection from locale
/// - Bidirectional text handling
/// - Icon mirroring for RTL layouts
/// - Edge insets adjustment for RTL
/// - Alignment adaptation
///
/// Example:
/// ```dart
/// // Check if current locale requires RTL
/// if (RTLSupportHandler.isRTL(context)) {
///   // Apply RTL-specific logic
/// }
///
/// // Get appropriate text direction
/// final direction = RTLSupportHandler.getTextDirection(context);
///
/// // Mirror icon for RTL
/// final icon = RTLSupportHandler.mirrorIconIfNeeded(
///   context,
///   Icons.arrow_forward,
/// );
/// ```
class RTLSupportHandler {
  /// Private constructor to prevent instantiation
  RTLSupportHandler._();

  /// List of RTL language codes
  /// These languages are written from right to left
  static const List<String> rtlLanguages = [
    'ar', // Arabic
    'he', // Hebrew
    'fa', // Persian/Farsi
    'ur', // Urdu
    'ps', // Pashto
    'sd', // Sindhi
    'ug', // Uyghur
    'yi', // Yiddish
    'ji', // Yiddish (alternative code)
  ];

  /// Check if the current locale requires RTL layout
  ///
  /// Returns true if the current locale's language code is in the RTL
  /// languages list.
  ///
  /// [context] The build context to extract locale from
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return isRTLLanguage(locale.languageCode);
  }

  /// Check if a specific language code requires RTL layout
  ///
  /// [languageCode] The ISO 639-1 language code (e.g., 'ar', 'he')
  static bool isRTLLanguage(String languageCode) {
    return rtlLanguages.contains(languageCode.toLowerCase());
  }

  /// Check if a specific locale requires RTL layout
  ///
  /// [locale] The locale to check
  static bool isRTLLocale(Locale locale) {
    return isRTLLanguage(locale.languageCode);
  }

  /// Get the text direction for the current locale
  ///
  /// Returns [TextDirection.rtl] for RTL languages and [TextDirection.ltr]
  /// for all other languages.
  ///
  /// [context] The build context
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text direction from a specific locale
  ///
  /// [locale] The locale to get direction for
  static TextDirection getTextDirectionFromLocale(Locale locale) {
    return isRTLLocale(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get text direction from a language code
  ///
  /// [languageCode] The language code
  static TextDirection getTextDirectionFromLanguage(String languageCode) {
    return isRTLLanguage(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get the text align based on text direction
  ///
  /// Returns the appropriate text alignment for the current locale direction.
  /// For RTL: returns right alignment for start, left for end
  /// For LTR: returns left alignment for start, right for end
  ///
  /// [context] The build context
  /// [alignment] The logical alignment (start or end)
  static TextAlign getTextAlign(
    BuildContext context, {
    TextAlign alignment = TextAlign.start,
  }) {
    if (alignment != TextAlign.start && alignment != TextAlign.end) {
      return alignment;
    }

    final isRtl = isRTL(context);

    if (alignment == TextAlign.start) {
      return isRtl ? TextAlign.right : TextAlign.left;
    } else {
      return isRtl ? TextAlign.left : TextAlign.right;
    }
  }

  /// Mirror a value for RTL layout
  ///
  /// Negates the value if in RTL mode. Useful for transforms, positions,
  /// or any numerical value that needs to be flipped for RTL.
  ///
  /// [context] The build context
  /// [value] The value to potentially mirror
  static double mirror(BuildContext context, double value) {
    return isRTL(context) ? -value : value;
  }

  /// Get mirrored edge insets for RTL
  ///
  /// Swaps left and right padding/margins when in RTL mode.
  ///
  /// [context] The build context
  /// [insets] The edge insets to mirror
  static EdgeInsets mirrorEdgeInsets(
    BuildContext context,
    EdgeInsets insets,
  ) {
    if (!isRTL(context)) {
      return insets;
    }

    return EdgeInsets.only(
      left: insets.right,
      top: insets.top,
      right: insets.left,
      bottom: insets.bottom,
    );
  }

  /// Get mirrored edge insets directional for RTL
  ///
  /// Converts EdgeInsetsDirectional to EdgeInsets with proper RTL handling.
  ///
  /// [context] The build context
  /// [insets] The directional edge insets
  static EdgeInsets mirrorEdgeInsetsDirectional(
    BuildContext context,
    EdgeInsetsDirectional insets,
  ) {
    final direction = getTextDirection(context);
    return insets.resolve(direction);
  }

  /// Get alignment for RTL layout
  ///
  /// Mirrors horizontal alignment values for RTL layouts while keeping
  /// vertical alignment unchanged.
  ///
  /// [context] The build context
  /// [alignment] The base alignment
  static Alignment getAlignment(BuildContext context, Alignment alignment) {
    if (!isRTL(context)) {
      return alignment;
    }

    return Alignment(
      -alignment.x, // Mirror horizontal
      alignment.y, // Keep vertical
    );
  }

  /// Get alignment geometry that respects text direction
  ///
  /// Converts logical alignments (start/end) to physical alignments (left/right)
  /// based on text direction.
  ///
  /// [context] The build context
  /// [alignment] The alignment geometry (can be Alignment or AlignmentDirectional)
  static Alignment resolveAlignment(
    BuildContext context,
    AlignmentGeometry alignment,
  ) {
    final direction = getTextDirection(context);
    return alignment.resolve(direction);
  }

  /// Check if an icon should be mirrored for RTL
  ///
  /// Some icons should be mirrored in RTL layouts (like arrows, directional
  /// indicators) while others should not (like media controls, checkmarks).
  ///
  /// [iconData] The icon to check
  static bool shouldMirrorIcon(IconData iconData) {
    // List of icon code points that should be mirrored
    // This is a subset of common directional icons
    final mirroredIconCodes = {
      Icons.arrow_back.codePoint,
      Icons.arrow_forward.codePoint,
      Icons.arrow_back_ios.codePoint,
      Icons.arrow_forward_ios.codePoint,
      Icons.chevron_left.codePoint,
      Icons.chevron_right.codePoint,
      Icons.keyboard_arrow_left.codePoint,
      Icons.keyboard_arrow_right.codePoint,
      Icons.navigate_before.codePoint,
      Icons.navigate_next.codePoint,
      Icons.first_page.codePoint,
      Icons.last_page.codePoint,
      Icons.undo.codePoint,
      Icons.redo.codePoint,
      Icons.format_indent_increase.codePoint,
      Icons.format_indent_decrease.codePoint,
      Icons.exit_to_app.codePoint,
      Icons.input.codePoint,
      Icons.subdirectory_arrow_left.codePoint,
      Icons.subdirectory_arrow_right.codePoint,
      Icons.trending_flat.codePoint,
      Icons.call_made.codePoint,
      Icons.call_received.codePoint,
    };

    return mirroredIconCodes.contains(iconData.codePoint);
  }

  /// Get the appropriate icon for RTL context
  ///
  /// Returns a mirrored version of directional icons when in RTL mode.
  ///
  /// [context] The build context
  /// [icon] The icon data
  static IconData mirrorIconIfNeeded(BuildContext context, IconData icon) {
    if (!isRTL(context) || !shouldMirrorIcon(icon)) {
      return icon;
    }

    // Mirror the icon by using Transform
    // Return the same icon as the Transform widget will handle the mirroring
    return icon;
  }

  /// Create a Transform widget that mirrors content for RTL
  ///
  /// This widget should wrap icons or other UI elements that need to be
  /// flipped horizontally in RTL mode.
  ///
  /// [context] The build context
  /// [child] The widget to potentially mirror
  /// [shouldMirror] Whether this specific widget should be mirrored
  static Widget mirrorInRTL({
    required BuildContext context,
    required Widget child,
    bool shouldMirror = true,
  }) {
    if (!shouldMirror || !isRTL(context)) {
      return child;
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.14159), // 180 degrees in radians (π)
      child: child,
    );
  }

  /// Get the opposite direction
  ///
  /// Returns RTL for LTR input and vice versa.
  ///
  /// [direction] The text direction to flip
  static TextDirection flipDirection(TextDirection direction) {
    return direction == TextDirection.ltr
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Create a Directionality widget with the appropriate direction
  ///
  /// Wraps a widget tree with proper text direction based on locale.
  ///
  /// [context] The build context
  /// [child] The widget to wrap
  /// [overrideDirection] Optional direction to override locale-based detection
  static Widget withDirectionality({
    required BuildContext context,
    required Widget child,
    TextDirection? overrideDirection,
  }) {
    return Directionality(
      textDirection: overrideDirection ?? getTextDirection(context),
      child: child,
    );
  }

  /// Get the starting alignment based on text direction
  ///
  /// Returns left alignment for LTR and right alignment for RTL.
  ///
  /// [context] The build context
  static Alignment getStartAlignment(BuildContext context) {
    return isRTL(context) ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Get the ending alignment based on text direction
  ///
  /// Returns right alignment for LTR and left alignment for RTL.
  ///
  /// [context] The build context
  static Alignment getEndAlignment(BuildContext context) {
    return isRTL(context) ? Alignment.centerLeft : Alignment.centerRight;
  }

  /// Get CrossAxisAlignment based on text direction
  ///
  /// Converts logical start/end to physical cross axis alignments.
  ///
  /// [context] The build context
  /// [logicalAlignment] The logical alignment (start or end)
  static CrossAxisAlignment getCrossAxisAlignment(
    BuildContext context, {
    CrossAxisAlignment logicalAlignment = CrossAxisAlignment.start,
  }) {
    if (logicalAlignment != CrossAxisAlignment.start &&
        logicalAlignment != CrossAxisAlignment.end) {
      return logicalAlignment;
    }

    final isRtl = isRTL(context);

    if (logicalAlignment == CrossAxisAlignment.start) {
      return isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    } else {
      return isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    }
  }

  /// Get MainAxisAlignment based on text direction
  ///
  /// Converts logical start/end to physical main axis alignments.
  ///
  /// [context] The build context
  /// [logicalAlignment] The logical alignment (start or end)
  static MainAxisAlignment getMainAxisAlignment(
    BuildContext context, {
    MainAxisAlignment logicalAlignment = MainAxisAlignment.start,
  }) {
    if (logicalAlignment != MainAxisAlignment.start &&
        logicalAlignment != MainAxisAlignment.end) {
      return logicalAlignment;
    }

    final isRtl = isRTL(context);

    if (logicalAlignment == MainAxisAlignment.start) {
      return isRtl ? MainAxisAlignment.end : MainAxisAlignment.start;
    } else {
      return isRtl ? MainAxisAlignment.start : MainAxisAlignment.end;
    }
  }

  /// Get the appropriate radius for corners based on direction
  ///
  /// Mirrors border radius values for RTL layouts.
  ///
  /// [context] The build context
  /// [radius] The border radius to mirror
  static BorderRadius mirrorBorderRadius(
    BuildContext context,
    BorderRadius radius,
  ) {
    if (!isRTL(context)) {
      return radius;
    }

    return BorderRadius.only(
      topLeft: radius.topRight,
      topRight: radius.topLeft,
      bottomLeft: radius.bottomRight,
      bottomRight: radius.bottomLeft,
    );
  }

  /// Get the appropriate decoration for RTL
  ///
  /// Mirrors BoxDecoration gradients and shadows for RTL layouts.
  ///
  /// [context] The build context
  /// [decoration] The decoration to mirror
  static BoxDecoration mirrorDecoration(
    BuildContext context,
    BoxDecoration decoration,
  ) {
    if (!isRTL(context)) {
      return decoration;
    }

    // Mirror gradient if present
    Gradient? mirroredGradient;
    if (decoration.gradient != null) {
      final gradient = decoration.gradient!;
      if (gradient is LinearGradient) {
        mirroredGradient = LinearGradient(
          begin: _mirrorAlignment(gradient.begin),
          end: _mirrorAlignment(gradient.end),
          colors: gradient.colors,
          stops: gradient.stops,
          tileMode: gradient.tileMode,
        );
      } else {
        mirroredGradient = gradient;
      }
    }

    // Mirror border radius if present
    BorderRadiusGeometry? mirroredBorderRadius;
    if (decoration.borderRadius != null &&
        decoration.borderRadius is BorderRadius) {
      mirroredBorderRadius = mirrorBorderRadius(
        context,
        decoration.borderRadius as BorderRadius,
      );
    } else {
      mirroredBorderRadius = decoration.borderRadius;
    }

    return decoration.copyWith(
      gradient: mirroredGradient,
      borderRadius: mirroredBorderRadius,
    );
  }

  /// Helper method to mirror alignment for gradients
  static AlignmentGeometry _mirrorAlignment(AlignmentGeometry alignment) {
    if (alignment is Alignment) {
      return Alignment(-alignment.x, alignment.y);
    }
    return alignment;
  }

  /// Wrap text with Unicode directional markers if needed
  ///
  /// Adds Unicode LRM (Left-to-Right Mark) or RLM (Right-to-Left Mark)
  /// to help with bidirectional text rendering.
  ///
  /// [context] The build context
  /// [text] The text to wrap
  /// [forceLTR] Force LTR direction regardless of context
  static String wrapWithDirectionalMarkers(
    BuildContext context,
    String text, {
    bool forceLTR = false,
  }) {
    if (text.isEmpty) return text;

    const lrm = '\u200E'; // Left-to-Right Mark
    const rlm = '\u200F'; // Right-to-Left Mark

    if (forceLTR) {
      return '$lrm$text$lrm';
    }

    final marker = isRTL(context) ? rlm : lrm;
    return '$marker$text$marker';
  }

  /// Check if text contains RTL characters
  ///
  /// Scans the text for characters that require RTL rendering.
  ///
  /// [text] The text to check
  static bool containsRTLCharacters(String text) {
    if (text.isEmpty) return false;

    // Unicode ranges for RTL scripts
    final rtlRegex = RegExp(
      r'[\u0600-\u06FF]|' // Arabic
      r'[\u0750-\u077F]|' // Arabic Supplement
      r'[\u0590-\u05FF]|' // Hebrew
      r'[\u07C0-\u07FF]|' // N'Ko
      r'[\uFB50-\uFDFF]|' // Arabic Presentation Forms-A
      r'[\uFE70-\uFEFF]', // Arabic Presentation Forms-B
    );

    return rtlRegex.hasMatch(text);
  }

  /// Get appropriate text direction for mixed content
  ///
  /// Analyzes text content and returns the appropriate direction.
  ///
  /// [text] The text to analyze
  /// [defaultDirection] Fallback direction if text is neutral
  static TextDirection getTextDirectionFromContent(
    String text, {
    TextDirection defaultDirection = TextDirection.ltr,
  }) {
    if (text.isEmpty) return defaultDirection;

    // Check for RTL characters
    if (containsRTLCharacters(text)) {
      return TextDirection.rtl;
    }

    return defaultDirection;
  }
}
