import 'package:flutter/material.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/utils/accessibility_helpers.dart';

/// A reusable empty state widget for displaying when there's no data.
///
/// This widget provides a consistent way to show empty states throughout
/// the application with an icon, message, and optional call-to-action button.
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [message] is the main message to display.
  /// The [icon] is the icon to show above the message.
  /// The [onAction] callback is invoked when the action button is pressed.
  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.description,
  });

  /// The main message to display
  final String message;

  /// Optional title above the message
  final String? title;

  /// The icon to display
  final IconData icon;

  /// Optional label for the action button
  final String? actionLabel;

  /// Optional callback for the action button
  final VoidCallback? onAction;

  /// Optional additional description
  final String? description;

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelpers.emptyStateSemantics(
      message: message,
      child: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: AppColors.onSurfaceSubtle(context.colorScheme),
              ),
              AppSpacing.verticalGapM,
              if (title != null) ...[
                Text(
                  title!,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalGapXS,
              ],
              Text(
                message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceSecondary(context.colorScheme),
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                AppSpacing.verticalGapXS,
                Text(
                  description!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceHint(context.colorScheme),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                AppSpacing.verticalGapL,
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                      vertical: AppSpacing.s,
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact empty state for displaying in smaller areas.
class CompactEmptyState extends StatelessWidget {
  /// Creates a compact empty state.
  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  /// The message to display
  final String message;

  /// The icon to display
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.onSurfaceSubtle(context.colorScheme),
            ),
            AppSpacing.verticalGapXS,
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceHint(context.colorScheme),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
