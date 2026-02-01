import 'package:flutter/material.dart';

import 'package:nonna_app/core/extensions/context_extensions.dart';

/// A consistent loading indicator with circular progress indicator.
///
/// Provides a customizable loading spinner that can be used throughout
/// the application to indicate loading states.
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator.
  ///
  /// The [size] determines the diameter of the circular progress indicator.
  /// The [color] can be customized to match different themes.
  /// The [strokeWidth] controls the thickness of the spinner line.
  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
  });

  /// The size (diameter) of the loading indicator
  final double size;

  /// The color of the loading indicator. Defaults to theme primary color.
  final Color? color;

  /// The width of the circular progress indicator stroke
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// A loading overlay that can be displayed over content.
///
/// Shows a semi-transparent backdrop with a loading indicator in the center.
class LoadingOverlay extends StatelessWidget {
  /// Creates a loading overlay.
  ///
  /// The [isLoading] parameter controls whether the overlay is visible.
  /// The [child] is the widget to display behind the overlay.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
    this.size = 40.0,
  });

  /// Whether the loading overlay should be visible
  final bool isLoading;

  /// The widget to display behind the overlay
  final Widget child;

  /// The color of the loading indicator
  final Color? color;

  /// The size of the loading indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: LoadingIndicator(
              size: size,
              color: color,
            ),
          ),
      ],
    );
  }
}
