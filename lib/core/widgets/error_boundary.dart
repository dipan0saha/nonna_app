import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nonna_app/core/services/observability_service.dart';

/// A widget that displays a fallback UI when [error] is set.
///
/// **Functional Requirements**: Section 3.30 - Error Boundaries & Recovery
///
/// `ErrorBoundary` is a UI-only wrapper. It shows fallback UI when an error
/// is explicitly surfaced to it (via [_ErrorBoundaryState.setError] from
/// [GlobalErrorBoundary]). It does **not** override [FlutterError.onError]
/// itself — that responsibility belongs to [GlobalErrorBoundary] to avoid
/// multiple instances competing for the global handler.
///
/// Usage:
/// ```dart
/// ErrorBoundary(
///   child: MyWidget(),
///   fallback: (error, stack) => Text('Something went wrong'),
///   onError: (error, stack) => log(error),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  /// The widget subtree to protect.
  final Widget child;

  /// Builder for the fallback UI shown when an error is caught.
  ///
  /// If `null`, a default recovery card is shown.
  final Widget Function(Object error, StackTrace? stack)? fallback;

  /// Optional callback invoked when an error is caught.
  final void Function(Object error, StackTrace? stack)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  /// Surface an error to this boundary so it renders the fallback UI.
  void setError(Object error, StackTrace? stack) {
    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stack;
      });
      widget.onError?.call(error, stack);
    }
  }

  void _recover() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(_error!, _stackTrace) ??
          _DefaultErrorCard(error: _error!, onRecover: _recover);
    }
    return widget.child;
  }
}

class _DefaultErrorCard extends StatelessWidget {
  const _DefaultErrorCard({
    required this.error,
    required this.onRecover,
  });

  final Object error;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Only reveal technical details in debug builds to avoid
          // leaking internal error information or PII in production.
          if (kDebugMode)
            Text(
              error.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRecover,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

/// App-level error boundary that wraps the entire widget tree.
///
/// - Intercepts [FlutterError.onError] to catch all framework errors.
/// - Reports caught errors to [ObservabilityService] (Sentry).
/// - Shows a full-screen recovery UI with a restart button.
///
/// Only one `GlobalErrorBoundary` should exist in the widget tree to avoid
/// multiple handlers competing for [FlutterError.onError].
class GlobalErrorBoundary extends StatefulWidget {
  const GlobalErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  Object? _error;
  int _resetKey = 0;

  FlutterExceptionHandler? _previousHandler;

  @override
  void initState() {
    super.initState();
    _previousHandler = FlutterError.onError;
    FlutterError.onError = _handleFlutterError;
  }

  @override
  void dispose() {
    FlutterError.onError = _previousHandler;
    super.dispose();
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    _previousHandler?.call(details);
    ObservabilityService.captureException(
      details.exception,
      stackTrace: details.stack,
    );
    if (mounted) {
      setState(() {
        _error = details.exception;
      });
    }
  }

  void _reset() {
    setState(() {
      _error = null;
      _resetKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: _DefaultErrorCard(error: _error!, onRecover: _reset),
      );
    }
    return KeyedSubtree(
      key: ValueKey(_resetKey),
      child: widget.child,
    );
  }
}
