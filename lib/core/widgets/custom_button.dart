import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/core/themes/colors.dart';

/// Button style variants
enum ButtonVariant {
  /// Primary button with filled background
  primary,

  /// Secondary button with outlined style
  secondary,

  /// Tertiary button with text style
  tertiary,
}

/// A custom branded button component with multiple variants.
///
/// Supports primary, secondary, and tertiary styles, loading states,
/// disabled states, and optional icons.
class CustomButton extends StatelessWidget {
  /// Creates a custom button.
  ///
  /// The [onPressed] callback is invoked when the button is tapped.
  /// The [label] is the text displayed on the button.
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  });

  /// Callback invoked when the button is pressed
  final VoidCallback? onPressed;

  /// The text label for the button
  final String label;

  /// The button style variant
  final ButtonVariant variant;

  /// Whether the button is in a loading state
  final bool isLoading;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Whether the button should expand to full width
  final bool fullWidth;

  /// Optional custom padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(context, isDisabled),
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                AppSpacing.horizontalGapXS,
              ],
              Text(label),
            ],
          );

    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s);

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              padding: effectivePadding,
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              disabledBackgroundColor: AppColors.disabledBackground(context.colorScheme),
              disabledForegroundColor: AppColors.onSurfaceDisabled(context.colorScheme),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              padding: effectivePadding,
              foregroundColor: context.colorScheme.primary,
              side: BorderSide(
                color: isDisabled
                    ? AppColors.disabledBackground(context.colorScheme)
                    : context.colorScheme.primary,
              ),
              disabledForegroundColor: AppColors.onSurfaceDisabled(context.colorScheme),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.tertiary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              padding: effectivePadding,
              foregroundColor: context.colorScheme.primary,
              disabledForegroundColor: AppColors.onSurfaceDisabled(context.colorScheme),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Color _getTextColor(BuildContext context, bool isDisabled) {
    if (isDisabled) {
      return AppColors.onSurfaceDisabled(context.colorScheme);
    }

    switch (variant) {
      case ButtonVariant.primary:
        return context.colorScheme.onPrimary;
      case ButtonVariant.secondary:
      case ButtonVariant.tertiary:
        return context.colorScheme.primary;
    }
  }
}

/// A custom icon button with consistent styling.
class CustomIconButton extends StatelessWidget {
  /// Creates a custom icon button.
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 24.0,
    this.color,
  });

  /// The icon to display
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Optional tooltip
  final String? tooltip;

  /// Size of the icon
  final double size;

  /// Optional color override
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      color: color ?? context.colorScheme.primary,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
