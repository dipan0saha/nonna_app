import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:nonna_app/core/navigation/navigation_service.dart';
import 'package:nonna_app/core/router/app_router.dart';

/// OneSignal push notification configuration
class OneSignalConfig {
  static String get appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

  /// Initialize OneSignal
  static Future<void> initialize({
    bool requestPermissionOnInit = false,
  }) async {
    if (appId.isEmpty) {
      debugPrint('⚠️ OneSignal App ID not found in .env file');
      return;
    }

    try {
      // Set OneSignal App ID
      OneSignal.initialize(appId);

      // Avoid forcing OS permission prompts during cold start.
      if (requestPermissionOnInit) {
        await OneSignal.Notifications.requestPermission(true);
      }

      // Set up notification clicked handler
      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationOpened(event);
      });

      // Set up notification will show in foreground handler
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        // Display notification even when app is in foreground
        event.notification.display();
      });

      debugPrint('✅ OneSignal initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing OneSignal: $e');
      rethrow;
    }
  }

  /// Handle notification opened event
  static void _handleNotificationOpened(OSNotificationClickEvent event) {
    final additionalData = event.notification.additionalData;

    if (additionalData != null) {
      final type = additionalData['type'];
      final babyProfileId = additionalData['baby_profile_id'];
      final photoId = additionalData['photo_id'];
      final eventId = additionalData['event_id'];

      debugPrint(
        'Notification opened - Type: $type, Baby Profile: $babyProfileId',
      );

      switch (type) {
        case 'new_photo':
        case 'new_comment':
        case 'photo_squish':
          if (photoId != null) {
            NavigationService.pushTo(AppRoutes.galleryPhotoRoute(photoId));
          } else {
            NavigationService.goTo(AppRoutes.gallery);
          }
          break;
        case 'event_rsvp':
        case 'event_reminder':
        case 'new_event':
          if (eventId != null) {
            NavigationService.pushTo(AppRoutes.calendarEventRoute(eventId));
          } else {
            NavigationService.goTo(AppRoutes.calendar);
          }
          break;
        case 'registry_purchase':
        case 'new_registry_item':
          NavigationService.goTo(AppRoutes.registry);
          break;
        case 'new_follower':
        case 'birth_announcement':
        case 'invitation':
          NavigationService.goTo(AppRoutes.babyProfile);
          break;
        default:
          debugPrint('Unknown notification type: $type');
          NavigationService.goTo(AppRoutes.home);
      }
    }
  }

  /// Set external user ID (link OneSignal to Supabase user)
  static Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting OneSignal external user ID: $e');
    }
  }

  /// Remove external user ID (on logout)
  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      debugPrint('✅ OneSignal external user ID removed');
    } catch (e) {
      debugPrint('❌ Error removing OneSignal external user ID: $e');
    }
  }

  /// Send tags to OneSignal for user segmentation
  static Future<void> sendTags(Map<String, dynamic> tags) async {
    try {
      // Convert all values to strings for OneSignal
      final stringTags =
          tags.map((key, value) => MapEntry(key, value.toString()));
      OneSignal.User.addTags(stringTags);
      debugPrint('✅ OneSignal tags sent: $tags');
    } catch (e) {
      debugPrint('❌ Error sending OneSignal tags: $e');
    }
  }

  /// Delete tags from OneSignal
  static Future<void> deleteTags(List<String> keys) async {
    try {
      OneSignal.User.removeTags(keys);
      debugPrint('✅ OneSignal tags deleted: $keys');
    } catch (e) {
      debugPrint('❌ Error deleting OneSignal tags: $e');
    }
  }
}
