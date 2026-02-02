import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'analytics_service.dart';
import 'local_storage_service.dart';

/// Notification service for managing push notifications via OneSignal
/// 
/// Provides push notification registration, payload handling,
/// deep-linking, notification preferences, and badge count management
class NotificationService {
  static bool _isInitialized = false;
  static String? _playerId;
  static final LocalStorageService _localStorage = LocalStorageService();

  // Notification click handler
  static final StreamController<Map<String, dynamic>> _notificationClickController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of notification clicks for deep-linking
  static Stream<Map<String, dynamic>> get notificationClickStream =>
      _notificationClickController.stream;

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize OneSignal
  /// 
  /// [appId] OneSignal App ID
  /// [requiresUserPrivacyConsent] Whether to require user consent
  static Future<void> initialize({
    required String appId,
    bool requiresUserPrivacyConsent = true,
  }) async {
    if (_isInitialized) {
      debugPrint('⚠️  NotificationService already initialized');
      return;
    }

    try {
      // Initialize local storage if needed
      if (!_localStorage.isInitialized) {
        await _localStorage.initialize();
      }

      // Set log level for debugging (only in debug mode)
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      } else {
        OneSignal.Debug.setLogLevel(OSLogLevel.info);
      }

      // Initialize OneSignal
      OneSignal.initialize(appId);

      // Set privacy consent requirement
      if (requiresUserPrivacyConsent) {
        OneSignal.consentRequired(true);
      }

      // Request notification permissions
      final hasPermission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('📱 Notification permission granted: $hasPermission');

      // Get player ID
      _playerId = OneSignal.User.pushSubscription.id;
      debugPrint('📱 OneSignal Player ID: $_playerId');

      // Set up notification click handler
      OneSignal.Notifications.addClickListener(_handleNotificationClick);

      // Set up notification will show listener
      OneSignal.Notifications.addForegroundWillDisplayListener(
        _handleNotificationWillShow,
      );

      _isInitialized = true;

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Check if the service has been initialized
  static bool get isInitialized => _isInitialized;

  // ==========================================
  // User Management
  // ==========================================

  /// Set external user ID (for targeting specific users)
  /// 
  /// [userId] The user ID from your backend
  static Future<void> setExternalUserId(String userId) async {
    try {
      OneSignal.login(userId);
      debugPrint('✅ Set OneSignal external user ID: $userId');
    } catch (e) {
      debugPrint('❌ Error setting external user ID: $e');
    }
  }

  /// Remove external user ID (on logout)
  static Future<void> removeExternalUserId() async {
    try {
      OneSignal.logout();
      debugPrint('✅ Removed OneSignal external user ID');
    } catch (e) {
      debugPrint('❌ Error removing external user ID: $e');
    }
  }

  /// Get player ID
  static String? get playerId => _playerId;

  // ==========================================
  // Tags (for targeted notifications)
  // ==========================================

  /// Set user tags
  /// 
  /// [tags] Key-value pairs for targeting
  /// Example: {'role': 'owner', 'baby_profile_id': '123'}
  static Future<void> setTags(Map<String, String> tags) async {
    try {
      for (final entry in tags.entries) {
        OneSignal.User.addTag(entry.key, entry.value);
      }
      debugPrint('✅ Set OneSignal tags: $tags');
    } catch (e) {
      debugPrint('❌ Error setting tags: $e');
    }
  }

  /// Remove tags
  /// 
  /// [keys] Tag keys to remove
  static Future<void> removeTags(List<String> keys) async {
    try {
      for (final key in keys) {
        OneSignal.User.removeTag(key);
      }
      debugPrint('✅ Removed OneSignal tags: $keys');
    } catch (e) {
      debugPrint('❌ Error removing tags: $e');
    }
  }

  /// Get all tags
  static Future<Map<String, dynamic>> getTags() async {
    try {
      final tags = OneSignal.User.getTags();
      return tags;
    } catch (e) {
      debugPrint('❌ Error getting tags: $e');
      return {};
    }
  }

  // ==========================================
  // Notification Preferences
  // ==========================================

  /// Enable push notifications
  static Future<void> enableNotifications() async {
    try {
      OneSignal.Notifications.requestPermission(true);
      await _localStorage.setNotificationsEnabled(true);
      
      // Track analytics
      await AnalyticsService.logNotificationPreferenceChanged(enabled: true);
      
      debugPrint('✅ Notifications enabled');
    } catch (e) {
      debugPrint('❌ Error enabling notifications: $e');
    }
  }

  /// Disable push notifications
  static Future<void> disableNotifications() async {
    try {
      OneSignal.Notifications.requestPermission(false);
      await _localStorage.setNotificationsEnabled(false);
      
      // Track analytics
      await AnalyticsService.logNotificationPreferenceChanged(enabled: false);
      
      debugPrint('✅ Notifications disabled');
    } catch (e) {
      debugPrint('❌ Error disabling notifications: $e');
    }
  }

  /// Check if notifications are enabled
  static bool get areNotificationsEnabled {
    return _localStorage.isNotificationsEnabled;
  }

  /// Check notification permission status
  static Future<bool> hasPermission() async {
    try {
      return OneSignal.Notifications.permission;
    } catch (e) {
      debugPrint('❌ Error checking permission: $e');
      return false;
    }
  }

  // ==========================================
  // Privacy & Consent
  // ==========================================

  /// Provide user privacy consent
  static Future<void> provideConsent() async {
    try {
      OneSignal.consentGiven(true);
      debugPrint('✅ User consent provided');
    } catch (e) {
      debugPrint('❌ Error providing consent: $e');
    }
  }

  /// Revoke user privacy consent
  static Future<void> revokeConsent() async {
    try {
      OneSignal.consentGiven(false);
      debugPrint('✅ User consent revoked');
    } catch (e) {
      debugPrint('❌ Error revoking consent: $e');
    }
  }

  // ==========================================
  // Badge Count
  // ==========================================

  /// Set badge count
  /// 
  /// [count] Badge count to display
  static Future<void> setBadgeCount(int count) async {
    try {
      // OneSignal doesn't have direct badge API in Flutter
      // Badge is typically managed by notification count
      debugPrint('📱 Badge count set to: $count');
    } catch (e) {
      debugPrint('❌ Error setting badge count: $e');
    }
  }

  /// Clear badge count
  static Future<void> clearBadges() async {
    try {
      OneSignal.Notifications.clearAll();
      debugPrint('✅ Cleared all badges');
    } catch (e) {
      debugPrint('❌ Error clearing badges: $e');
    }
  }

  // ==========================================
  // Notification Handlers
  // ==========================================

  /// Handle notification click
  static void _handleNotificationClick(OSNotificationClickEvent event) {
    debugPrint('📱 Notification clicked: ${event.notification.notificationId}');
    
    // Extract additional data for deep-linking
    final additionalData = event.notification.additionalData ?? {};
    
    // Add notification click to stream for deep-linking
    _notificationClickController.add({
      'notification_id': event.notification.notificationId,
      'title': event.notification.title,
      'body': event.notification.body,
      'additional_data': additionalData,
    });
    
    // Track analytics
    AnalyticsService.logNotificationOpened(
      notificationId: event.notification.notificationId ?? '',
      title: event.notification.title ?? '',
    );
  }

  /// Handle notification will show (when app is in foreground)
  static void _handleNotificationWillShow(OSNotificationWillDisplayEvent event) {
    debugPrint('📱 Notification received in foreground');
    
    // You can modify or prevent the notification from displaying
    // For now, we'll just display it
    event.notification.display();
  }

  // ==========================================
  // Send Test Notification
  // ==========================================

  /// Send a test notification (for development)
  static Future<void> sendTestNotification() async {
    try {
      // This would typically be done from your backend
      // But OneSignal provides a REST API for testing
      debugPrint('📱 Test notification would be sent via OneSignal REST API');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }

  // ==========================================
  // Cleanup
  // ==========================================

  /// Dispose the notification service
  static Future<void> dispose() async {
    await _notificationClickController.close();
    _isInitialized = false;
    debugPrint('✅ NotificationService disposed');
  }
}
