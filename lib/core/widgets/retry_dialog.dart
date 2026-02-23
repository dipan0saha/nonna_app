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
  /// [onCancel] is called when the user taps cancel or dismisses the dialog.
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

  /// Callback invoked when the user cancels.
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
      // maybePop avoids errors when the widget is used outside a navigator
      // route (e.g. inline in a scaffold body).
      Navigator.of(context).maybePop(false);
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
/// Returns `true` if the user tapped Retry, `false` if they cancelled.
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
      // _handleCancel calls maybePop(false) which closes the dialog and
      // causes showDialog to return false.
    ),
  );
}
