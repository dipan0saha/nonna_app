import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Observability service for crash reporting and error logging
///
/// Uses Firebase Crashlytics for crash reporting, error logging,
/// custom breadcrumbs, and user context.
class ObservabilityService {
  static bool _isInitialized = false;
  static String? _environment;

  /// Check if the service has been initialized
  static bool get isInitialized => _isInitialized;

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize the observability service
  ///
  /// [environment] Environment name (e.g., 'development', 'production')
  static Future<void> initialize({
    String environment = 'production',
  }) async {
    if (_isInitialized) {
      debugPrint('⚠️  ObservabilityService already initialized');
      return;
    }

    try {
      _environment = environment;

      // Disable Crashlytics collection in debug mode
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      _isInitialized = true;

      debugPrint('✅ ObservabilityService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing ObservabilityService: $e');
      rethrow;
    }
  }

  // ==========================================
  // Error Reporting
  // ==========================================

  /// Capture an exception
  ///
  /// [exception] The exception to capture
  /// [stackTrace] Optional stack trace
  /// [hint] Optional hint with additional context
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace as StackTrace?,
        reason: hint,
      );

      debugPrint('📊 Exception captured: $exception');
    } catch (e) {
      debugPrint('❌ Error capturing exception: $e');
    }
  }

  /// Capture a message
  ///
  /// [message] The message to capture
  static Future<void> captureMessage(String message) async {
    try {
      FirebaseCrashlytics.instance.log(message);
      debugPrint('📊 Message captured: $message');
    } catch (e) {
      debugPrint('❌ Error capturing message: $e');
    }
  }

  // ==========================================
  // Breadcrumbs
  // ==========================================

  /// Add a breadcrumb
  ///
  /// Breadcrumbs are trail of events that led to an error
  ///
  /// [message] Breadcrumb message
  /// [category] Breadcrumb category (e.g., 'navigation', 'http', 'user')
  /// [data] Additional data
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    try {
      final prefix = category != null ? '[$category] ' : '';
      FirebaseCrashlytics.instance.log('$prefix$message');
    } catch (e) {
      debugPrint('❌ Error adding breadcrumb: $e');
    }
  }

  /// Add navigation breadcrumb
  static void addNavigationBreadcrumb({
    required String from,
    required String to,
  }) {
    addBreadcrumb(
      message: 'Navigation: $from -> $to',
      category: 'navigation',
    );
  }

  /// Add HTTP breadcrumb
  static void addHttpBreadcrumb({
    required String method,
    required String url,
    int? statusCode,
  }) {
    addBreadcrumb(
      message: 'HTTP $method: $url${statusCode != null ? ' ($statusCode)' : ''}',
      category: 'http',
    );
  }

  /// Add user action breadcrumb
  static void addUserActionBreadcrumb({
    required String action,
    Map<String, dynamic>? data,
  }) {
    addBreadcrumb(
      message: 'User action: $action',
      category: 'user',
      data: data,
    );
  }

  // ==========================================
  // User Context
  // ==========================================

  /// Set user context
  ///
  /// [userId] User ID
  /// [email] User email
  /// [username] Username
  /// [extras] Additional user data
  static Future<void> setUser({
    String? userId,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    try {
      if (userId != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      }
      if (email != null) {
        await FirebaseCrashlytics.instance.setCustomKey('email', email);
      }
      if (username != null) {
        await FirebaseCrashlytics.instance.setCustomKey('username', username);
      }

      debugPrint('✅ User context set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting user context: $e');
    }
  }

  /// Clear user context (on logout)
  static Future<void> clearUser() async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier('');

      debugPrint('✅ User context cleared');
    } catch (e) {
      debugPrint('❌ Error clearing user context: $e');
    }
  }

  // ==========================================
  // Custom Context
  // ==========================================

  /// Set custom context
  ///
  /// [key] Context key
  /// [value] Context value (converted to String; complex objects use toString())
  static Future<void> setContext(String key, dynamic value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    } catch (e) {
      debugPrint('❌ Error setting context: $e');
    }
  }

  /// Remove custom context
  ///
  /// Firebase Crashlytics does not support removing custom keys;
  /// the value is overwritten with an empty string to clear it.
  static Future<void> removeContext(String key) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, '');
    } catch (e) {
      debugPrint('❌ Error removing context: $e');
    }
  }

  // ==========================================
  // Tags
  // ==========================================

  /// Set a tag
  ///
  /// Tags are key-value pairs for filtering and grouping
  ///
  /// [key] Tag key
  /// [value] Tag value
  static Future<void> setTag(String key, String value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      debugPrint('❌ Error setting tag: $e');
    }
  }

  /// Remove a tag
  ///
  /// Firebase Crashlytics does not support removing custom keys;
  /// the value is overwritten with an empty string to clear it.
  static Future<void> removeTag(String key) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, '');
    } catch (e) {
      debugPrint('❌ Error removing tag: $e');
    }
  }

  // ==========================================
  // Utility Methods
  // ==========================================

  /// Get the current environment
  static String? get environment => _environment;
}
