import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../config/firebase_config.dart';
import '../config/onesignal_config.dart';
import '../config/supabase_config.dart';

/// Result of the app initialization process.
///
/// Contains structured information about what succeeded and what failed,
/// so callers can make informed decisions (e.g. show an error screen when
/// [success] is `false`).
class InitializationResult {
  /// Whether the critical initialization path (Supabase) succeeded.
  final bool success;

  /// Human-readable names of optional services whose initialization failed
  /// silently (e.g. `['Firebase', 'OneSignal']`).
  final List<String> warnings;

  /// The error message when the critical path failed, or `null` on success.
  final String? criticalError;

  const InitializationResult({
    required this.success,
    this.warnings = const [],
    this.criticalError,
  });

  /// Whether any optional services failed during initialization.
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() {
    if (success && !hasWarnings) return 'InitializationResult(success)';
    if (success) return 'InitializationResult(success, warnings: $warnings)';
    return 'InitializationResult(failed: $criticalError)';
  }
}

/// Service responsible for initializing all third-party integrations
/// This includes Supabase, OneSignal, Firebase Analytics, and Crashlytics
class AppInitializationService {
  /// Maximum time to wait for Supabase initialization before aborting.
  static const _supabaseTimeout = Duration(seconds: 30);

  /// Initialize all third-party services.
  ///
  /// Returns an [InitializationResult] describing what succeeded and what
  /// failed. The caller should inspect [InitializationResult.success] to
  /// decide whether the app can start normally.
  ///
  /// Call this in `main()` before `runApp()`.
  static Future<InitializationResult> initialize() async {
    final warnings = <String>[];

    // ── Critical path: Supabase ──────────────────────────────────────
    try {
      await _initializeSupabase();
    } catch (e, stackTrace) {
      debugPrint('❌ Critical initialization failure (Supabase): $e');
      debugPrint('Stack trace: $stackTrace');
      return InitializationResult(
        success: false,
        criticalError: e.toString(),
      );
    }

    // ── Optional: Firebase ───────────────────────────────────────────
    try {
      await _initializeFirebase();
    } catch (e) {
      debugPrint('⚠️  Optional service failed (Firebase): $e');
      warnings.add('Firebase');
    }

    // ── Optional: OneSignal ──────────────────────────────────────────
    try {
      await _initializeOneSignal();
    } catch (e) {
      debugPrint('⚠️  Optional service failed (OneSignal): $e');
      warnings.add('OneSignal');
    }

    if (warnings.isEmpty) {
      debugPrint('✅ All third-party integrations initialized successfully');
    } else {
      debugPrint(
        '⚠️  Initialization complete with warnings: ${warnings.join(", ")}',
      );
    }

    return InitializationResult(success: true, warnings: warnings);
  }

  /// Initialize Supabase Backend-as-a-Service.
  ///
  /// Protected by a [_supabaseTimeout] to prevent infinite hangs when the
  /// network is unreachable or DNS resolution stalls.
  static Future<void> _initializeSupabase() async {
    try {
      await SupabaseConfig.initialize().timeout(
        _supabaseTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Supabase initialization timed out after '
            '${_supabaseTimeout.inSeconds}s',
          );
        },
      );
      debugPrint('✅ Supabase initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Initialize Firebase services (Analytics, Crashlytics, Performance)
  static Future<void> _initializeFirebase() async {
    // Initialize Firebase Core
    await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);

    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    // Set up Flutter error handling for Crashlytics
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint(
      '✅ Firebase initialized (Analytics, Crashlytics, Performance)',
    );
  }

  /// Initialize OneSignal Push Notifications
  static Future<void> _initializeOneSignal() async {
    await OneSignalConfig.initialize();
    debugPrint('✅ OneSignal initialized');
  }

  /// Set user ID for analytics and crash reporting
  /// Call this after user authentication
  static Future<void> setUserId(String userId) async {
    try {
      // Set user ID for Firebase Analytics
      await FirebaseAnalytics.instance.setUserId(id: userId);

      // Set user ID for Crashlytics
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);

      // Set external user ID for OneSignal
      await OneSignal.login(userId);

      debugPrint('✅ User ID set for all services: $userId');
    } catch (e) {
      debugPrint('❌ Failed to set user ID: $e');
    }
  }

  /// Clear user ID on logout
  /// Call this when user signs out
  static Future<void> clearUserId() async {
    try {
      // Clear Firebase Analytics user ID
      await FirebaseAnalytics.instance.setUserId(id: null);

      // Clear Crashlytics user ID
      await FirebaseCrashlytics.instance.setUserIdentifier('');

      // Remove external user ID from OneSignal
      await OneSignal.logout();

      debugPrint('✅ User ID cleared from all services');
    } catch (e) {
      debugPrint('❌ Failed to clear user ID: $e');
    }
  }
}

/// Exception thrown when an operation exceeds its time limit.
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
