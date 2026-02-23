import 'dart:async';

import 'package:flutter/material.dart';

/// Retry Dialog
///
/// **Functional Requirements**: Section 3.6.9 – Network Failure Handling
///
/// A confirmation dialog shown when a network operation fails, giving the
/// user the option to retry or cancel.
///
/// Features:
/// - Configurable title and error message
/// - Manual retry button
/// - Cancel button
/// - Loading state while a retry is in progress
///
/// Usage:
/// ```dart
/// final retry = await showRetryDialog(
///   context: context,
///   message: 'Could not load your profile.',
/// );
/// if (retry == true) {
///   await loadProfile();
/// }
/// ```
///
/// Or embed inline:
/// ```dart
/// RetryDialog(
///   message: 'Failed to save changes.',
///   onRetry: () => saveChanges(),
/// )
/// ```
class RetryDialog extends StatefulWidget {
  /// Creates a [RetryDialog].
  ///
  /// [message] is displayed below the title to describe the failure.
  /// [title] overrides the default "Connection Error" heading.
  /// [retryLabel] overrides the default "Retry" button label.
  /// [cancelLabel] overrides the default "Cancel" button label.
  /// [onRetry] is called when the user taps the retry button.
  ///           If it returns a [Future], a loading indicator is shown while
  ///           the future is pending.
  /// [onCancel] is called when the user taps the Cancel button.
  ///           Note: dismissals via the system back button or route pop are
  ///           **not** captured by this callback; handle those at the
  ///           call site if needed.
  const RetryDialog({
    super.key,
    required this.message,
    this.title = 'Connection Error',
    this.retryLabel = 'Retry',
    this.cancelLabel = 'Cancel',
    this.onRetry,
    this.onCancel,
  });

  /// Short description of the failure
  final String message;

  /// Dialog heading
  final String title;

  /// Label for the retry action button
  final String retryLabel;

  /// Label for the cancel/dismiss button
  final String cancelLabel;

  /// Callback invoked when the user requests a retry.
  ///
  /// May be synchronous (`void`) or asynchronous (`Future<void>`).
  /// When asynchronous, the button shows a loading indicator while waiting.
  final FutureOr<void> Function()? onRetry;

  /// Callback invoked when the user taps the Cancel button.
  ///
  /// Note: this is not called for system back-button dismissals or barrier
  /// taps. Use [PopScope] or handle those cases at the call site if needed.
  final VoidCallback? onCancel;

  @override
  State<RetryDialog> createState() => _RetryDialogState();
}

class _RetryDialogState extends State<RetryDialog> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying || widget.onRetry == null) return;

    setState(() => _isRetrying = true);
    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  void _handleCancel() {
    widget.onCancel?.call();
    if (mounted) {
      // Only pop when this widget is hosted inside a popup/dialog route.
      // This avoids accidentally navigating away when RetryDialog is
      // embedded inline in a Scaffold body.
      final route = ModalRoute.of(context);
      if (route is PopupRoute) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: colorScheme.error, size: 22),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: Text(widget.message),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isRetrying ? null : _handleCancel,
          child: Text(widget.cancelLabel),
        ),
        // Retry button
        if (widget.onRetry != null)
          FilledButton(
            onPressed: _isRetrying ? null : _handleRetry,
            child: _isRetrying
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(widget.retryLabel),
          ),
      ],
    );
  }
}

/// Shows a [RetryDialog] as a modal dialog.
///
/// Returns `true` if the user tapped Retry, `false` if they tapped Cancel,
/// or `null` if the dialog was dismissed by the system back button or (when
/// [barrierDismissible] is `true`) a barrier tap.
///
/// [context] The [BuildContext] used to show the dialog.
/// [message] Error message displayed in the dialog body.
/// [title] Optional dialog heading (defaults to "Connection Error").
/// [retryLabel] Optional retry button label (defaults to "Retry").
/// [cancelLabel] Optional cancel button label (defaults to "Cancel").
/// [onRetry] Optional callback executed when the user taps Retry.
///           The dialog remains open while an async callback is running.
/// [barrierDismissible] Whether tapping outside dismisses the dialog.
Future<bool?> showRetryDialog({
  required BuildContext context,
  required String message,
  String title = 'Connection Error',
  String retryLabel = 'Retry',
  String cancelLabel = 'Cancel',
  FutureOr<void> Function()? onRetry,
  bool barrierDismissible = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => RetryDialog(
      message: message,
      title: title,
      retryLabel: retryLabel,
      cancelLabel: cancelLabel,
      onRetry: onRetry != null
          ? () async {
              await onRetry();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(true);
              }
            }
          : null,
      // onCancel is intentionally omitted here; RetryDialog's internal
      // _handleCancel detects the PopupRoute and calls pop(false), which
      // causes showDialog to return false.
    ),
  );
}
