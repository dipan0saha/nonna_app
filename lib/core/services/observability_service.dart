import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Observability service for crash reporting and error logging
/// 
/// Uses Sentry for crash reporting, error logging, performance monitoring,
/// custom breadcrumbs, user context, and release tracking
class ObservabilityService {
  static bool _isInitialized = false;
  static String? _environment;

  /// Check if the service has been initialized
  static bool get isInitialized => _isInitialized;

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize Sentry
  /// 
  /// [dsn] Sentry DSN (Data Source Name)
  /// [environment] Environment name (e.g., 'development', 'production')
  /// [tracesSampleRate] Percentage of transactions to trace (0.0 - 1.0)
  static Future<void> initialize({
    required String dsn,
    String environment = 'production',
    double tracesSampleRate = 0.1,
  }) async {
    if (_isInitialized) {
      debugPrint('⚠️  ObservabilityService already initialized');
      return;
    }

    try {
      _environment = environment;

      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.environment = environment;
          options.tracesSampleRate = tracesSampleRate;
          
          // Enable performance monitoring
          options.enableAutoPerformanceTracing = true;
          
          // Attach stack traces to all messages
          options.attachStacktrace = true;
          
          // Send default PII (Personally Identifiable Information)
          options.sendDefaultPii = false;
          
          // Debug mode only in development
          options.debug = kDebugMode;
          
          // Release version - should match pubspec.yaml version
          // TODO: Extract from pubspec.yaml or pass as parameter
          options.release = 'nonna_app@1.0.0';
          
          // Distribution identifier - should be based on build environment
          // TODO: Extract from environment or build configuration
          options.dist = '1';
          
          // Before send callback for filtering events
          options.beforeSend = _beforeSend;
        },
      );

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
    if (!_isInitialized) {
      debugPrint('⚠️  ObservabilityService not initialized');
      return;
    }

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'hint': hint}) : null,
      );
      
      debugPrint('📊 Exception captured: $exception');
    } catch (e) {
      debugPrint('❌ Error capturing exception: $e');
    }
  }

  /// Capture a message
  /// 
  /// [message] The message to capture
  /// [level] Severity level
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️  ObservabilityService not initialized');
      return;
    }

    try {
      await Sentry.captureMessage(message, level: level);
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
  /// [level] Severity level
  /// [data] Additional data
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          level: level,
          data: data,
        ),
      );
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
      data: {'from': from, 'to': to},
    );
  }

  /// Add HTTP breadcrumb
  static void addHttpBreadcrumb({
    required String method,
    required String url,
    int? statusCode,
  }) {
    addBreadcrumb(
      message: 'HTTP $method: $url',
      category: 'http',
      data: {
        'method': method,
        'url': url,
        if (statusCode != null) 'status_code': statusCode,
      },
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
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: userId,
            email: email,
            username: username,
            data: extras,
          ),
        );
      });
      
      debugPrint('✅ User context set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting user context: $e');
    }
  }

  /// Clear user context (on logout)
  static Future<void> clearUser() async {
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });
      
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
  /// [value] Context value
  static Future<void> setContext(String key, dynamic value) async {
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setContexts(key, value);
      });
    } catch (e) {
      debugPrint('❌ Error setting context: $e');
    }
  }

  /// Remove custom context
  static Future<void> removeContext(String key) async {
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.removeContext(key);
      });
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
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.setTag(key, value);
      });
    } catch (e) {
      debugPrint('❌ Error setting tag: $e');
    }
  }

  /// Remove a tag
  static Future<void> removeTag(String key) async {
    if (!_isInitialized) return;

    try {
      await Sentry.configureScope((scope) {
        scope.removeTag(key);
      });
    } catch (e) {
      debugPrint('❌ Error removing tag: $e');
    }
  }

  // ==========================================
  // Performance Monitoring
  // ==========================================

  /// Start a transaction for performance monitoring
  /// 
  /// [name] Transaction name
  /// [operation] Operation name
  static ISentrySpan? startTransaction({
    required String name,
    required String operation,
  }) {
    if (!_isInitialized) return null;

    try {
      final transaction = Sentry.startTransaction(name, operation);
      return transaction;
    } catch (e) {
      debugPrint('❌ Error starting transaction: $e');
      return null;
    }
  }

  /// Start a child span within a transaction
  /// 
  /// [transaction] Parent transaction
  /// [operation] Operation name
  /// [description] Optional description
  static ISentrySpan? startChildSpan({
    required ISentrySpan transaction,
    required String operation,
    String? description,
  }) {
    try {
      return transaction.startChild(operation, description: description);
    } catch (e) {
      debugPrint('❌ Error starting child span: $e');
      return null;
    }
  }

  // ==========================================
  // Event Filtering
  // ==========================================

  /// Before send callback for filtering events
  static SentryEvent? _beforeSend(SentryEvent event, {Hint? hint}) {
    // Filter out events in development if needed
    if (kDebugMode && _environment == 'development') {
      // You can choose to not send events in development
      // return null;
    }

    // Filter out specific errors
    if (event.message?.formatted?.contains('SocketException') ?? false) {
      // Don't send socket exceptions in certain cases
      // return null;
    }

    return event;
  }

  // ==========================================
  // Utility Methods
  // ==========================================

  /// Close Sentry (for clean shutdown)
  static Future<void> close() async {
    if (!_isInitialized) return;

    try {
      await Sentry.close();
      _isInitialized = false;
      debugPrint('✅ ObservabilityService closed');
    } catch (e) {
      debugPrint('❌ Error closing ObservabilityService: $e');
    }
  }

  /// Get the current environment
  static String? get environment => _environment;
}
