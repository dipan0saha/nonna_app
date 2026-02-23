import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';

/// Categories of network errors that the handler can recognise
enum NetworkErrorType {
  /// No internet connection detected
  noConnection,

  /// The request timed out
  timeout,

  /// The server returned a 5xx status
  serverError,

  /// The client sent an invalid request (4xx)
  clientError,

  /// An unexpected error that does not fit any other category
  unknown,
}

/// Immutable result of a network operation managed by [NetworkErrorHandler]
class NetworkResult<T> {
  const NetworkResult._({
    this.data,
    this.error,
    this.errorType,
    this.attempts = 0,
  });

  /// Creates a successful result.
  const NetworkResult.success(T data, {int attempts = 1})
      : this._(data: data, attempts: attempts);

  /// Creates a failure result.
  const NetworkResult.failure(
    Object error,
    NetworkErrorType errorType, {
    int attempts = 0,
  }) : this._(error: error, errorType: errorType, attempts: attempts);

  /// The result value when the operation succeeded
  final T? data;

  /// The error thrown on failure
  final Object? error;

  /// Categorised error type (null on success)
  final NetworkErrorType? errorType;

  /// Total number of attempts that were made
  final int attempts;

  /// Whether the operation succeeded
  bool get isSuccess => error == null;

  /// Whether the operation failed
  bool get isFailure => !isSuccess;
}

/// Network Error Handler
///
/// **Functional Requirements**: Section 3.6.9 – Network Failure Handling
///
/// Features:
/// - Network error detection and categorisation
/// - Configurable request timeout
/// - Automatic retry with exponential back-off
/// - User notification callbacks for network events
///
/// Dependencies:
/// - Flutter `foundation.dart` (`debugPrint`) for diagnostic logging
///
/// Usage:
/// ```dart
/// final handler = NetworkErrorHandler();
///
/// final result = await handler.execute(() => fetchData());
/// if (result.isSuccess) {
///   use(result.data);
/// } else {
///   print('Failed after ${result.attempts} attempts: ${result.error}');
/// }
/// ```
class NetworkErrorHandler {
  /// Creates a [NetworkErrorHandler].
  ///
  /// [timeout] Duration before a request is considered timed-out.
  ///           Defaults to 30 seconds.
  /// [maxRetries] Maximum number of retry attempts (not counting the first
  ///              attempt). Defaults to 3.
  /// [initialBackoff] The initial back-off delay applied before the first
  ///                  retry. Subsequent delays are doubled (exponential).
  ///                  Defaults to 1 second.
  /// [onNetworkError] Optional callback invoked whenever a network error is
  ///                  detected. Useful for showing snackbars or banners.
  /// [onRetrying] Optional callback invoked just before each retry attempt.
  ///              Receives the attempt number (1-based) and the error that
  ///              triggered the retry.
  NetworkErrorHandler({
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    Duration initialBackoff = const Duration(seconds: 1),
    void Function(NetworkErrorType type, Object error)? onNetworkError,
    void Function(int attempt, Object error)? onRetrying,
  })  : _timeout = timeout,
        _maxRetries = maxRetries,
        _initialBackoff = initialBackoff,
        _onNetworkError = onNetworkError,
        _onRetrying = onRetrying;

  final Duration _timeout;
  final int _maxRetries;
  final Duration _initialBackoff;
  final void Function(NetworkErrorType type, Object error)? _onNetworkError;
  final void Function(int attempt, Object error)? _onRetrying;

  // ============================================================
  // Public API
  // ============================================================

  /// Execute [operation] with automatic timeout, retry, and error handling.
  ///
  /// The operation is retried up to [_maxRetries] times using exponential
  /// back-off starting at [_initialBackoff].  All error categories except
  /// [NetworkErrorType.clientError] are treated as retryable (including
  /// [NetworkErrorType.unknown]).  Client errors (4xx) are considered permanent
  /// and returned immediately without further attempts.
  ///
  /// Returns a [NetworkResult] that is either a success wrapping the returned
  /// value or a failure containing the last error and its category.
  Future<NetworkResult<T>> execute<T>(
    Future<T> Function() operation,
  ) async {
    Object? lastError;
    NetworkErrorType? lastErrorType;
    int attempt = 0;

    while (attempt <= _maxRetries) {
      try {
        final result = await operation().timeout(_timeout);
        debugPrint(
          '✅ NetworkErrorHandler: succeeded on attempt ${attempt + 1}',
        );
        return NetworkResult<T>.success(result, attempts: attempt + 1);
      } catch (error) {
        attempt++;
        lastError = error;
        lastErrorType = _categorise(error);

        debugPrint(
          '❌ NetworkErrorHandler: attempt $attempt failed '
          '(${lastErrorType.name}): $error',
        );

        _onNetworkError?.call(lastErrorType, error);

        // Do not retry permanent client errors.
        if (lastErrorType == NetworkErrorType.clientError) {
          break;
        }

        if (attempt <= _maxRetries) {
          final delay = _backoffDelay(attempt);
          debugPrint(
            '🔄 NetworkErrorHandler: retrying in ${delay.inMilliseconds}ms '
            '(attempt $attempt of $_maxRetries)…',
          );
          _onRetrying?.call(attempt, error);
          await Future<void>.delayed(delay);
        }
      }
    }

    return NetworkResult<T>.failure(
      lastError!,
      lastErrorType ?? NetworkErrorType.unknown,
      attempts: attempt,
    );
  }

  /// Categorise a raw [error] into a [NetworkErrorType].
  NetworkErrorType categoriseError(Object error) => _categorise(error);

  // ============================================================
  // Private helpers
  // ============================================================

  NetworkErrorType _categorise(Object error) {
    if (error is TimeoutException) return NetworkErrorType.timeout;

    if (error is SocketException || error is NetworkException) {
      return NetworkErrorType.noConnection;
    }

    // HttpException carries status codes in its message; parse when possible.
    if (error is HttpException) {
      final msg = error.message.toLowerCase();
      if (RegExp(r'\b5\d{2}\b').hasMatch(msg))
        return NetworkErrorType.serverError;
      if (RegExp(r'\b4\d{2}\b').hasMatch(msg))
        return NetworkErrorType.clientError;
      return NetworkErrorType.serverError;
    }

    // Generic string-based heuristic (e.g. from HTTP client packages).
    final msg = error.toString().toLowerCase();
    if (msg.contains('timeout')) return NetworkErrorType.timeout;
    if (msg.contains('socket') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated') ||
        msg.contains('failed host lookup')) {
      return NetworkErrorType.noConnection;
    }
    if (RegExp(r'\b5\d{2}\b').hasMatch(msg))
      return NetworkErrorType.serverError;
    if (RegExp(r'\b4\d{2}\b').hasMatch(msg))
      return NetworkErrorType.clientError;

    return NetworkErrorType.unknown;
  }

  /// Exponential back-off: `initialBackoff * 2^(attempt - 1)`, capped at
  /// 32 × [_initialBackoff].
  ///
  /// Exposed for unit testing via [backoffDelay].
  Duration _backoffDelay(int attempt) {
    final factor = 1 << (attempt - 1); // 2^(attempt-1)
    return _initialBackoff * min(factor, 32);
  }

  /// Returns the back-off [Duration] for a given retry [attempt] (1-based).
  ///
  /// Exposed for unit testing.
  @visibleForTesting
  Duration backoffDelay(int attempt) => _backoffDelay(attempt);
}

/// Thrown by platform code on platforms that do not use [SocketException] for
/// connectivity failures (e.g. web).
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);

  /// Human-readable message
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
