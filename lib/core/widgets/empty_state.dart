import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
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
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
