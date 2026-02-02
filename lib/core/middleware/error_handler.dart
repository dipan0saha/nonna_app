import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global error handler for network, auth, and validation errors
///
/// **Functional Requirements**: Section 3.2.7 - Middleware
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Global error handling and mapping
/// - User-friendly error messages
/// - Retry strategies for transient errors
/// - Error reporting to monitoring services
///
/// Dependencies: None
class ErrorHandler {
  // Prevent instantiation
  ErrorHandler._();

  // ============================================================
  // Error Types
  // ============================================================

  /// Network error types
  static const String networkError = 'network_error';
  static const String authError = 'auth_error';
  static const String validationError = 'validation_error';
  static const String serverError = 'server_error';
  static const String permissionError = 'permission_error';
  static const String notFoundError = 'not_found_error';
  static const String unknownError = 'unknown_error';

  // ============================================================
  // Error Handling
  // ============================================================

  /// Handle an error and return a user-friendly message
  ///
  /// [error] The error object
  /// [stackTrace] Optional stack trace
  /// Returns a formatted error message
  static String handleError(Object error, {StackTrace? stackTrace}) {
    debugPrint('❌ ErrorHandler: ${error.toString()}');
    
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: ${stackTrace.toString()}');
    }

    // Map error to user-friendly message
    final message = mapErrorToMessage(error);
    
    // Report to monitoring service in production
    if (kReleaseMode) {
      _reportError(error, stackTrace);
    }

    return message;
  }

  /// Map an error object to a user-friendly message
  ///
  /// [error] The error object
  /// Returns a user-friendly error message
  static String mapErrorToMessage(Object error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else if (error is FormatException) {
      return _handleValidationError(error);
    } else if (error is TypeError) {
      return 'Data format error. Please try again.';
    } else {
      return _handleUnknownError(error);
    }
  }

  /// Handle authentication errors
  static String _handleAuthError(AuthException error) {
    final statusCode = error.statusCode;
    final message = error.message.toLowerCase();

    if (statusCode == '400') {
      if (message.contains('invalid') || message.contains('credentials')) {
        return 'Invalid email or password. Please try again.';
      } else if (message.contains('email')) {
        return 'Invalid email address. Please check and try again.';
      } else if (message.contains('password')) {
        return 'Password does not meet requirements.';
      }
      return 'Invalid request. Please check your information.';
    } else if (statusCode == '401') {
      return 'Session expired. Please sign in again.';
    } else if (statusCode == '403') {
      return 'Access denied. You do not have permission to perform this action.';
    } else if (statusCode == '422') {
      if (message.contains('email') && message.contains('exists')) {
        return 'This email is already registered. Please sign in or use a different email.';
      }
      return 'Invalid data provided. Please check your information.';
    } else if (statusCode == '429') {
      return 'Too many attempts. Please try again later.';
    }

    return error.message.isNotEmpty 
        ? error.message 
        : 'Authentication failed. Please try again.';
  }

  /// Handle Postgrest (database) errors
  static String _handlePostgrestError(PostgrestException error) {
    final code = error.code;
    final message = error.message.toLowerCase();

    if (code == '23505') {
      // Unique constraint violation
      return 'This item already exists. Please use a different value.';
    } else if (code == '23503') {
      // Foreign key violation
      return 'Cannot complete operation. Related data does not exist.';
    } else if (code == '42P01') {
      // Table does not exist
      return 'Data source not found. Please contact support.';
    } else if (code == 'PGRST116') {
      // No rows found
      return 'Item not found.';
    } else if (code == 'PGRST301') {
      // JWT expired
      return 'Session expired. Please sign in again.';
    } else if (code == 'PGRST302') {
      // JWT invalid
      return 'Invalid session. Please sign in again.';
    } else if (message.contains('permission')) {
      return 'You do not have permission to access this data.';
    } else if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Database error. Please try again.';
  }

  /// Handle storage errors
  static String _handleStorageError(StorageException error) {
    final message = error.message.toLowerCase();

    if (message.contains('not found')) {
      return 'File not found.';
    } else if (message.contains('permission')) {
      return 'You do not have permission to access this file.';
    } else if (message.contains('size') || message.contains('large')) {
      return 'File is too large. Please choose a smaller file.';
    } else if (message.contains('type') || message.contains('format')) {
      return 'Invalid file type. Please choose a supported format.';
    } else if (message.contains('quota')) {
      return 'Storage quota exceeded. Please free up space or upgrade your plan.';
    }

    return 'File operation failed. Please try again.';
  }

  /// Handle validation errors
  static String _handleValidationError(FormatException error) {
    final message = error.message.toLowerCase();

    if (message.contains('email')) {
      return 'Invalid email format.';
    } else if (message.contains('phone')) {
      return 'Invalid phone number format.';
    } else if (message.contains('date')) {
      return 'Invalid date format.';
    } else if (message.contains('url')) {
      return 'Invalid URL format.';
    }

    return 'Invalid data format. Please check your input.';
  }

  /// Handle unknown errors
  static String _handleUnknownError(Object error) {
    debugPrint('⚠️  Unknown error type: ${error.runtimeType}');
    
    if (kDebugMode) {
      return 'Error: ${error.toString()}';
    }
    
    return 'Something went wrong. Please try again.';
  }

  // ============================================================
  // Retry Strategies
  // ============================================================

  /// Check if an error is retryable
  ///
  /// [error] The error object
  /// Returns true if the error is retryable
  static bool isRetryable(Object error) {
    if (error is PostgrestException) {
      // Retry on timeout or temporary server errors
      final message = error.message.toLowerCase();
      return message.contains('timeout') || 
             message.contains('temporary') ||
             message.contains('unavailable');
    }
    
    if (error is AuthException) {
      // Retry on token refresh errors
      return error.statusCode == '401';
    }

    return false;
  }

  /// Get retry delay for an error
  ///
  /// [retryCount] Current retry attempt
  /// Returns the delay duration
  static Duration getRetryDelay(int retryCount) {
    // Exponential backoff: 500ms, 1s, 2s, 4s, etc.
    final milliseconds = 500 * (1 << retryCount);
    return Duration(milliseconds: milliseconds);
  }

  // ============================================================
  // Error Reporting
  // ============================================================

  /// Report error to monitoring service
  ///
  /// This is a placeholder for integration with services like Sentry
  static void _reportError(Object error, StackTrace? stackTrace) {
    // TODO: Integrate with Sentry or other monitoring service
    debugPrint('📊 Reporting error to monitoring service');
    debugPrint('Error: ${error.toString()}');
    
    if (stackTrace != null) {
      debugPrint('Stack trace: ${stackTrace.toString()}');
    }
  }

  /// Report error with custom context
  ///
  /// [error] The error object
  /// [context] Additional context information
  /// [stackTrace] Optional stack trace
  static void reportWithContext(
    Object error, 
    Map<String, dynamic> context, {
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) {
      debugPrint('📊 Reporting error with context: $context');
      _reportError(error, stackTrace);
    }
  }

  // ============================================================
  // Error Classification
  // ============================================================

  /// Classify an error by type
  ///
  /// [error] The error object
  /// Returns the error type string
  static String classifyError(Object error) {
    if (error is AuthException) {
      return authError;
    } else if (error is PostgrestException) {
      if (error.code == 'PGRST301' || error.code == 'PGRST302') {
        return authError;
      } else if (error.code == 'PGRST116') {
        return notFoundError;
      } else if (error.message.toLowerCase().contains('permission')) {
        return permissionError;
      }
      return serverError;
    } else if (error is StorageException) {
      return serverError;
    } else if (error is FormatException) {
      return validationError;
    } else if (error.toString().toLowerCase().contains('network')) {
      return networkError;
    }
    
    return unknownError;
  }
}
