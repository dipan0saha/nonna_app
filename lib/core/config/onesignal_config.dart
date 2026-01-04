import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification configuration
class OneSignalConfig {
  static String get appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

  /// Initialize OneSignal
  static Future<void> initialize() async {
    if (appId.isEmpty) {
      debugPrint('⚠️ OneSignal App ID not found in .env file');
      return;
    }

    try {
      // Set OneSignal App ID
      OneSignal.shared.setAppId(appId);

      // Request notification permission (iOS)
      OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
        debugPrint('OneSignal: User accepted notifications: $accepted');
      });

      // Set up notification opened handler
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
        _handleNotificationOpened(result);
      });

      // Set up notification will show in foreground handler
      OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
          // Display notification even when app is in foreground
          event.complete(event.notification);
        },
      );

      debugPrint('✅ OneSignal initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing OneSignal: $e');
      rethrow;
    }
  }

  /// Handle notification opened event
  static void _handleNotificationOpened(OSNotificationOpenedResult result) {
    final additionalData = result.notification.additionalData;
    
    if (additionalData != null) {
      final type = additionalData['type'];
      final babyProfileId = additionalData['baby_profile_id'];
      final photoId = additionalData['photo_id'];
      final eventId = additionalData['event_id'];
      
      debugPrint('Notification opened - Type: $type, Baby Profile: $babyProfileId');
      
      // TODO: Navigate to appropriate screen based on notification type
      // This will be implemented when navigation is set up
      switch (type) {
        case 'new_photo':
          debugPrint('Navigate to photo detail: $photoId');
          break;
        case 'new_comment':
          debugPrint('Navigate to photo with comment: $photoId');
          break;
        case 'event_rsvp':
          debugPrint('Navigate to event: $eventId');
          break;
        case 'registry_purchase':
          debugPrint('Navigate to registry: $babyProfileId');
          break;
        case 'new_follower':
          debugPrint('Navigate to baby profile: $babyProfileId');
          break;
        case 'birth_announcement':
          debugPrint('Navigate to baby profile: $babyProfileId');
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    }
  }

  /// Set external user ID (link OneSignal to Supabase user)
  static Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.shared.setExternalUserId(userId);
      debugPrint('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting OneSignal external user ID: $e');
    }
  }

  /// Remove external user ID (on logout)
  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.shared.removeExternalUserId();
      debugPrint('✅ OneSignal external user ID removed');
    } catch (e) {
      debugPrint('❌ Error removing OneSignal external user ID: $e');
    }
  }

  /// Send tags to OneSignal for user segmentation
  static Future<void> sendTags(Map<String, dynamic> tags) async {
    try {
      await OneSignal.shared.sendTags(tags);
      debugPrint('✅ OneSignal tags sent: $tags');
    } catch (e) {
      debugPrint('❌ Error sending OneSignal tags: $e');
    }
  }

  /// Delete tags from OneSignal
  static Future<void> deleteTags(List<String> keys) async {
    try {
      await OneSignal.shared.deleteTags(keys);
      debugPrint('✅ OneSignal tags deleted: $keys');
    } catch (e) {
      debugPrint('❌ Error deleting OneSignal tags: $e');
    }
  }
}
