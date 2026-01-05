import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../config/firebase_config.dart';
import '../config/onesignal_config.dart';
import '../config/supabase_config.dart';

/// Service responsible for initializing all third-party integrations
/// This includes Supabase, OneSignal, Firebase Analytics, and Crashlytics
class AppInitializationService {
  /// Initialize all third-party services
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    try {
      // Initialize Supabase
      await _initializeSupabase();

      // Initialize Firebase (Analytics, Crashlytics, Performance)
      await _initializeFirebase();

      // Initialize OneSignal (Push Notifications)
      await _initializeOneSignal();

      debugPrint('✅ All third-party integrations initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing third-party integrations: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Initialize Supabase Backend-as-a-Service
  static Future<void> _initializeSupabase() async {
    try {
      await SupabaseConfig.initialize();
      debugPrint('✅ Supabase initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Initialize Firebase services (Analytics, Crashlytics, Performance)
  static Future<void> _initializeFirebase() async {
    try {
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
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      // Don't rethrow - Firebase is optional
    }
  }

  /// Initialize OneSignal Push Notifications
  static Future<void> _initializeOneSignal() async {
    try {
      await OneSignalConfig.initialize();
      debugPrint('✅ OneSignal initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize OneSignal: $e');
      // Don't rethrow - OneSignal is optional
    }
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
