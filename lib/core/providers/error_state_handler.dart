import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../middleware/error_handler.dart';

/// Error state handler for centralized error management
///
/// **Functional Requirements**: Section 3.5.6 - Error & Loading State Handlers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Centralized error state management
/// - Error recovery mechanisms
/// - User notifications
/// - Retry logic with exponential backoff
/// - Error history tracking
/// - Error categorization
///
/// Dependencies: ErrorHandler
///
/// Usage:
/// ```dart
/// final errorHandler = ref.read(errorStateHandlerProvider.notifier);
///
/// // Handle an error
/// errorHandler.handleError(
///   error: exception,
///   key: 'fetch_data',
///   userMessage: 'Failed to load data',
///   onRetry: () => fetchData(),
/// );
///
/// // Check for errors
/// final hasError = errorHandler.hasError('fetch_data');
///
/// // Clear error
/// errorHandler.clearError('fetch_data');
/// ```
class ErrorStateHandler extends Notifier<ErrorState> {
  @override
  ErrorState build() {
    return ErrorState.initial();
  }

  // Maximum retry attempts
  static const int maxRetryAttempts = 3;

  // Retry delays (exponential backoff)
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  // ==========================================
  // Error Handling
  // ==========================================

  /// Handle an error
  ///
  /// [error] The error object
  /// [key] Optional key to identify the error context
  /// [userMessage] Optional custom user-friendly message
  /// [stackTrace] Optional stack trace
  /// [onRetry] Optional retry callback
  /// [retryable] Whether the error is retryable (default: true)
  void handleError({
    required Object error,
    String? key,
    String? userMessage,
    StackTrace? stackTrace,
    Future<void> Function()? onRetry,
    bool retryable = true,
  }) {
    final errorKey = key ?? 'global';

    // Map error to user-friendly message
    final message = userMessage ?? ErrorHandler.mapErrorToMessage(error);

    // Create error info
    final errorInfo = ErrorInfo(
      error: error,
      message: message,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      key: errorKey,
      onRetry: onRetry,
      retryable: retryable && onRetry != null,
    );

    // Add to state
    final errors = Map<String, ErrorInfo>.from(state.errors);
    final existingError = errors[errorKey];

    // Preserve retry attempts from existing error
    final retryAttempts = existingError?.retryAttempts ?? 0;

    errors[errorKey] = errorInfo.copyWith(retryAttempts: retryAttempts);

    // Add to history
    final history = List<ErrorInfo>.from(state.history);
    history.insert(0, errorInfo);

    // Keep only last 50 errors in history
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    state = state.copyWith(
      errors: errors,
      history: history,
    );

    debugPrint('❌ Error handled: $errorKey - $message');
  }

  /// Clear a specific error
  ///
  /// [key] Error key to clear (default: 'global')
  void clearError([String key = 'global']) {
    final errors = Map<String, ErrorInfo>.from(state.errors);
    errors.remove(key);

    state = state.copyWith(errors: errors);

    debugPrint('✅ Error cleared: $key');
  }

  /// Clear all errors
  void clearAllErrors() {
    state = state.copyWith(errors: {});
    debugPrint('✅ All errors cleared');
  }

  /// Check if there's an error for a specific key
  ///
  /// [key] Error key to check (default: 'global')
  bool hasError([String key = 'global']) {
    return state.errors.containsKey(key);
  }

  /// Get error for a specific key
  ///
  /// [key] Error key (default: 'global')
  ErrorInfo? getError([String key = 'global']) {
    return state.errors[key];
  }

  /// Get error message for a specific key
  ///
  /// [key] Error key (default: 'global')
  String? getErrorMessage([String key = 'global']) {
    return state.errors[key]?.message;
  }

  // ==========================================
  // Retry Logic
  // ==========================================

  /// Retry a failed operation with exponential backoff
  ///
  /// [key] Error key to retry (default: 'global')
  Future<void> retry([String key = 'global']) async {
    final errorInfo = state.errors[key];
    if (errorInfo == null || !errorInfo.retryable) {
      debugPrint('⚠️  Cannot retry: No retryable error for $key');
      return;
    }

    if (errorInfo.onRetry == null) {
      debugPrint('⚠️  Cannot retry: No retry callback for $key');
      return;
    }

    final attempt = errorInfo.retryAttempts + 1;

    if (attempt > maxRetryAttempts) {
      debugPrint('⚠️  Max retry attempts reached for $key');
      handleError(
        error: 'Max retry attempts reached',
        key: key,
        userMessage:
            'Failed after $maxRetryAttempts attempts. Please try again later.',
        retryable: false,
      );
      return;
    }

    // Update retry attempt
    final errors = Map<String, ErrorInfo>.from(state.errors);
    errors[key] = errorInfo.copyWith(retryAttempts: attempt);
    state = state.copyWith(errors: errors);

    // Apply exponential backoff delay
    final delayIndex = attempt - 1;
    final delay = delayIndex < retryDelays.length
        ? retryDelays[delayIndex]
        : retryDelays.last;

    debugPrint('🔄 Retrying $key (attempt $attempt) after ${delay.inSeconds}s');

    await Future.delayed(delay);

    try {
      // Clear error before retry
      clearError(key);

      // Execute retry
      await errorInfo.onRetry!();

      debugPrint('✅ Retry successful for $key');
    } catch (e, stackTrace) {
      debugPrint('❌ Retry failed for $key: $e');

      // Handle retry failure
      handleError(
        error: e,
        key: key,
        stackTrace: stackTrace,
        onRetry: errorInfo.onRetry,
      );
    }
  }

  /// Execute an operation with automatic error handling
  ///
  /// [operation] The async operation to execute
  /// [key] Error key for tracking
  /// [userMessage] Custom error message
  /// [retryable] Whether the operation is retryable
  Future<T?> executeWithErrorHandling<T>({
    required Future<T> Function() operation,
    String key = 'global',
    String? userMessage,
    bool retryable = true,
  }) async {
    try {
      // Clear any existing error
      clearError(key);

      // Execute operation
      final result = await operation();
      return result;
    } catch (e, stackTrace) {
      // Handle error
      handleError(
        error: e,
        key: key,
        userMessage: userMessage,
        stackTrace: stackTrace,
        onRetry: retryable ? operation : null,
        retryable: retryable,
      );
      return null;
    }
  }

  // ==========================================
  // Error Recovery
  // ==========================================

  /// Reset error state for recovery
  ///
  /// [key] Error key to reset (default: 'global')
  void reset([String key = 'global']) {
    final errors = Map<String, ErrorInfo>.from(state.errors);
    final errorInfo = errors[key];

    if (errorInfo != null) {
      // Reset retry attempts
      errors[key] = errorInfo.copyWith(retryAttempts: 0);
      state = state.copyWith(errors: errors);
      debugPrint('🔄 Error reset: $key');
    }
  }

  /// Reset all errors for recovery
  void resetAll() {
    final errors = Map<String, ErrorInfo>.from(state.errors);

    // Reset all retry attempts
    for (final key in errors.keys) {
      final errorInfo = errors[key]!;
      errors[key] = errorInfo.copyWith(retryAttempts: 0);
    }

    state = state.copyWith(errors: errors);
    debugPrint('🔄 All errors reset');
  }

  // ==========================================
  // Error History
  // ==========================================

  /// Get error history
  List<ErrorInfo> getHistory() {
    return state.history;
  }

  /// Clear error history
  void clearHistory() {
    state = state.copyWith(history: []);
    debugPrint('🗑️  Error history cleared');
  }
}

/// Error state
class ErrorState {
  /// Map of active errors by key
  final Map<String, ErrorInfo> errors;

  /// Error history (most recent first)
  final List<ErrorInfo> history;

  const ErrorState({
    required this.errors,
    required this.history,
  });

  factory ErrorState.initial() {
    return const ErrorState(
      errors: {},
      history: [],
    );
  }

  /// Check if there are any errors
  bool get hasAnyErrors => errors.isNotEmpty;

  /// Get count of active errors
  int get errorCount => errors.length;

  ErrorState copyWith({
    Map<String, ErrorInfo>? errors,
    List<ErrorInfo>? history,
  }) {
    return ErrorState(
      errors: errors ?? this.errors,
      history: history ?? this.history,
    );
  }
}

/// Error information
class ErrorInfo {
  /// The error object
  final Object error;

  /// User-friendly error message
  final String message;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Error key/context
  final String key;

  /// Retry callback
  final Future<void> Function()? onRetry;

  /// Number of retry attempts
  final int retryAttempts;

  /// Whether the error is retryable
  final bool retryable;

  const ErrorInfo({
    required this.error,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    required this.key,
    this.onRetry,
    this.retryAttempts = 0,
    this.retryable = false,
  });

  ErrorInfo copyWith({
    Object? error,
    String? message,
    StackTrace? stackTrace,
    DateTime? timestamp,
    String? key,
    Future<void> Function()? onRetry,
    int? retryAttempts,
    bool? retryable,
  }) {
    return ErrorInfo(
      error: error ?? this.error,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      key: key ?? this.key,
      onRetry: onRetry ?? this.onRetry,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      retryable: retryable ?? this.retryable,
    );
  }
}

/// Provider for error state handler
final errorStateHandlerProvider =
    NotifierProvider<ErrorStateHandler, ErrorState>(ErrorStateHandler.new);
