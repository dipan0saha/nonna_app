import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/utils/accessibility_helpers.dart';

/// A reusable error view widget that displays error messages with a retry button.
///
/// This widget provides a consistent way to display errors throughout the application,
/// with an error icon, message, and optional retry functionality.
class ErrorView extends StatelessWidget {
  /// Creates an error view.
  ///
  /// The [message] is the error message to display.
  /// The [onRetry] callback is invoked when the user taps the retry button.
  /// If [onRetry] is null, the retry button will not be shown.
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
  });

  /// The error message to display
  final String message;

  /// Callback invoked when the retry button is pressed
  final VoidCallback? onRetry;

  /// Optional title for the error. Defaults to "Error"
  final String? title;

  /// Optional custom icon. Defaults to error icon
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelpers.errorSemantics(
      errorMessage: message,
      onRetry: onRetry,
      child: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: context.errorColor,
              ),
              AppSpacing.verticalGapM,
              Text(
                title ?? 'Error',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalGapXS,
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceSecondary(context.colorScheme),
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                AppSpacing.verticalGapL,
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                      vertical: AppSpacing.s,
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact error view for displaying errors inline.
class InlineErrorView extends StatelessWidget {
  /// Creates an inline error view.
  const InlineErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// The error message to display
  final String message;

  /// Optional retry callback
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.compactPadding,
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: context.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: context.errorColor,
            size: 20,
          ),
          AppSpacing.horizontalGapS,
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.errorColor,
              ),
            ),
          ),
          if (onRetry != null) ...[
            AppSpacing.horizontalGapS,
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: context.errorColor,
            ),
          ],
        ],
      ),
    );
  }
}
