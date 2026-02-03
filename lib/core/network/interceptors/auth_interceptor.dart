import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  ///
  /// Automatically handles 401 errors by refreshing the token and retrying
  /// Throws an exception after max retries are exhausted
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int retryCount = 0,
  }) async {
    try {
      return await operation();
    } on AuthException catch (e) {
      // Handle auth-specific errors
      if (e.statusCode == '401') {
        return await _handle401Error(operation, retryCount);
      }
      rethrow;
    } on PostgrestException catch (e) {
      // Handle Postgrest errors (includes auth errors)
      if (e.code == '401' || e.code == 'PGRST301') {
        return await _handle401Error(operation, retryCount);
      }
      rethrow;
    } catch (e) {
      // For other errors, retry with exponential backoff
      if (retryCount < _maxRetries) {
        final delay = _calculateRetryDelay(retryCount);
        debugPrint(
          '⚠️  Request failed, retrying in ${delay.inMilliseconds}ms (attempt ${retryCount + 1}/$_maxRetries)',
        );
        await Future.delayed(delay);
        return await executeWithRetry(operation, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /// Handle 401 errors by refreshing token and retrying
  Future<T> _handle401Error<T>(
    Future<T> Function() operation,
    int retryCount,
  ) async {
    if (retryCount >= _maxRetries) {
      debugPrint('❌ Max retries exceeded for 401 error, logging out');
      await _handleLogout();
      throw AuthException(
        'Authentication failed after $_maxRetries attempts',
      );
    }

    try {
      debugPrint('🔄 Refreshing token (attempt ${retryCount + 1}/$_maxRetries)');
      
      // Try to refresh the session
      final response = await _client.auth.refreshSession();
      
      if (response.session == null) {
        debugPrint('❌ Token refresh failed, no session returned');
        await _handleLogout();
        throw AuthException('Token refresh failed');
      }

      debugPrint('✅ Token refreshed successfully');
      
      // Retry the operation with the new token
      final delay = _calculateRetryDelay(retryCount);
      await Future.delayed(delay);
      return await executeWithRetry(operation, retryCount: retryCount + 1);
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      
      // If refresh fails, attempt one more time before logging out
      if (retryCount < _maxRetries - 1) {
        final delay = _calculateRetryDelay(retryCount);
        await Future.delayed(delay);
        return await _handle401Error(operation, retryCount + 1);
      }
      
      await _handleLogout();
      rethrow;
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
