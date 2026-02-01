import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: theme.colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}
