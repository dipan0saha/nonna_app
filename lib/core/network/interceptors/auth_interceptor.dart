import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../middleware/error_handler.dart';

/// Auth interceptor for handling JWT token injection, refresh, and retry logic
///
/// **Functional Requirements**: Section 3.2.5 - Network Layer
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Automatic JWT token injection into requests
/// - Token refresh on 401 errors
/// - Logout on persistent auth failures
/// - Request retry logic with exponential backoff
///
/// Dependencies: None
class AuthInterceptor {
  final SupabaseClient _client;
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(milliseconds: 500);

  /// Create an auth interceptor
  ///
  /// [client] Supabase client instance
  AuthInterceptor(this._client);

  /// Inject JWT token into request headers
  ///
  /// Returns a map of headers with the authorization token
  /// Returns empty map if no session is available
  Future<Map<String, String>> injectAuthHeaders() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        debugPrint('⚠️  No active session found for auth injection');
        return {};
      }

      final accessToken = session.accessToken;
      return {
        'Authorization': 'Bearer $accessToken',
        'apikey': _client.headers['apikey'] ?? '',
      };
    } catch (e) {
      debugPrint('❌ Error injecting auth headers: $e');
      return {};
    }
  }

  /// Execute a request with automatic retry and token refresh
  ///
  /// [operation] The async operation to execute
  /// [retryCount] Current retry attempt (default: 0)
  /// [operationName] Optional context for telemetry logging
  ///
  /// Automatically handles 401 errors by refreshing the token and retrying
  /// Throws an [AppException] after max retries are exhausted
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int retryCount = 0,
    String? operationName,
  }) async {
    try {
      return await operation();
    } on AuthException catch (e, stackTrace) {
      if (e.statusCode == '401') {
        return await _handle401Error(operation, retryCount, operationName);
      }
      return _throwAppException(e, stackTrace, operationName);
    } on PostgrestException catch (e, stackTrace) {
      if (e.code == '401' || e.code == 'PGRST301') {
        return await _handle401Error(operation, retryCount, operationName);
      }
      return _throwAppException(e, stackTrace, operationName);
    } catch (e, stackTrace) {
      // For other errors, check if retry is appropriate
      if (retryCount < _maxRetries && ErrorHandler.isRetryable(e)) {
        final delay = _calculateRetryDelay(retryCount);
        debugPrint(
          '⚠️  Request failed, retrying in ${delay.inMilliseconds}ms (attempt ${retryCount + 1}/$_maxRetries)',
        );
        await Future.delayed(delay);
        return await executeWithRetry(operation, retryCount: retryCount + 1, operationName: operationName);
      }
      return _throwAppException(e, stackTrace, operationName);
    }
  }

  Never _throwAppException(Object e, StackTrace stackTrace, String? operationName) {
    final message = ErrorHandler.mapErrorToMessage(e);
    final contextMsg = operationName != null ? 'Error in $operationName: $message' : message;
    
    debugPrint('❌ $contextMsg');
    ErrorHandler.reportWithContext(e, {'operation': operationName ?? 'unknown'}, stackTrace: stackTrace);
    
    throw AppException(
      message,
      originalException: e,
      stackTrace: stackTrace,
    );
  }

  /// Handle 401 errors by refreshing token and retrying
  Future<T> _handle401Error<T>(
    Future<T> Function() operation,
    int retryCount,
    String? operationName,
  ) async {
    if (retryCount >= _maxRetries) {
      debugPrint('❌ Max retries exceeded for 401 error, logging out');
      await _handleLogout();
      _throwAppException(AuthException('Authentication failed after $_maxRetries attempts'), StackTrace.current, operationName);
    }

    try {
      debugPrint(
          '🔄 Refreshing token (attempt ${retryCount + 1}/$_maxRetries)');

      // Try to refresh the session
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        debugPrint('❌ Token refresh failed, no session returned');
        await _handleLogout();
        _throwAppException(AuthException('Token refresh failed'), StackTrace.current, operationName);
      }

      debugPrint('✅ Token refreshed successfully');

      // Retry the operation with the new token
      final delay = _calculateRetryDelay(retryCount);
      await Future.delayed(delay);
      return await executeWithRetry(operation, retryCount: retryCount + 1, operationName: operationName);
    } catch (e, stackTrace) {
      debugPrint('❌ Error refreshing token: $e');

      // If refresh fails, attempt one more time before logging out
      if (retryCount < _maxRetries - 1) {
        final delay = _calculateRetryDelay(retryCount);
        await Future.delayed(delay);
        return await _handle401Error(operation, retryCount + 1, operationName);
      }

      await _handleLogout();
      return _throwAppException(e, stackTrace, operationName);
    }
  }

  /// Handle logout on persistent auth failures
  Future<void> _handleLogout() async {
    try {
      debugPrint('🚪 Logging out due to persistent auth failures');
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Calculate retry delay with exponential backoff
  Duration _calculateRetryDelay(int retryCount) {
    final milliseconds = _initialRetryDelay.inMilliseconds * (1 << retryCount);
    return Duration(milliseconds: milliseconds);
  }

  /// Check if the current session is valid
  ///
  /// Returns true if a valid session exists, false otherwise
  bool hasValidSession() {
    final session = _client.auth.currentSession;
    if (session == null) {
      return false;
    }

    // Check if token is expired
    final expiresAt = session.expiresAt;
    if (expiresAt == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < expiresAt;
  }

  /// Get the current access token
  ///
  /// Returns null if no session is available
  String? getAccessToken() {
    return _client.auth.currentSession?.accessToken;
  }

  /// Get the current user ID
  ///
  /// Returns null if no session is available
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}
