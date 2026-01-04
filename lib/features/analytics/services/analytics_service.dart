import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics service wrapper for Firebase Analytics
/// Provides methods to track user events and properties
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _isEnabled = false;

  /// Get Firebase Analytics observer for navigation tracking
  static FirebaseAnalyticsObserver get observer {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Enable analytics collection (with user consent)
  static Future<void> enable() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _isEnabled = true;
      debugPrint('✅ Analytics enabled');
    } catch (e) {
      debugPrint('❌ Error enabling analytics: $e');
    }
  }

  /// Disable analytics collection (user opt-out)
  static Future<void> disable() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(false);
      _isEnabled = false;
      debugPrint('✅ Analytics disabled');
    } catch (e) {
      debugPrint('❌ Error disabling analytics: $e');
    }
  }

  /// Check if analytics is enabled
  static bool get isEnabled => _isEnabled;

  // ==========================================
  // Authentication Events
  // ==========================================

  /// Log user signup event
  static Future<void> logSignUp({required String signUpMethod}) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      debugPrint('Error logging signup: $e');
    }
  }

  /// Log user login event
  static Future<void> logLogin({required String loginMethod}) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
    } catch (e) {
      debugPrint('Error logging login: $e');
    }
  }

  // ==========================================
  // Baby Profile Events
  // ==========================================

  /// Log baby profile created event
  static Future<void> logBabyProfileCreated({
    required String babyProfileId,
    required bool hasPhoto,
    String? gender,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'baby_profile_created',
        parameters: {
          'baby_profile_id': babyProfileId,
          'has_photo': hasPhoto,
          if (gender != null) 'gender': gender,
        },
      );
    } catch (e) {
      debugPrint('Error logging baby profile created: $e');
    }
  }

  /// Log baby profile followed event
  static Future<void> logBabyProfileFollowed({
    required String babyProfileId,
    required String invitationMethod,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'baby_profile_followed',
        parameters: {
          'baby_profile_id': babyProfileId,
          'invitation_method': invitationMethod,
        },
      );
    } catch (e) {
      debugPrint('Error logging baby profile followed: $e');
    }
  }

  // ==========================================
  // Photo Events
  // ==========================================

  /// Log photo uploaded event
  static Future<void> logPhotoUploaded({
    required String babyProfileId,
    required bool hasCaption,
    required bool hasTags,
    required int fileSizeKb,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'photo_uploaded',
        parameters: {
          'baby_profile_id': babyProfileId,
          'has_caption': hasCaption,
          'has_tags': hasTags,
          'file_size_kb': fileSizeKb,
        },
      );
    } catch (e) {
      debugPrint('Error logging photo uploaded: $e');
    }
  }

  /// Log photo viewed event
  static Future<void> logPhotoViewed({
    required String photoId,
    required String babyProfileId,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'photo_viewed',
        parameters: {
          'photo_id': photoId,
          'baby_profile_id': babyProfileId,
        },
      );
    } catch (e) {
      debugPrint('Error logging photo viewed: $e');
    }
  }

  /// Log photo commented event
  static Future<void> logPhotoCommented({
    required String photoId,
    required String babyProfileId,
    required int commentLength,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'photo_commented',
        parameters: {
          'photo_id': photoId,
          'baby_profile_id': babyProfileId,
          'comment_length': commentLength,
        },
      );
    } catch (e) {
      debugPrint('Error logging photo commented: $e');
    }
  }

  /// Log photo squished (liked) event
  static Future<void> logPhotoSquished({
    required String photoId,
    required String babyProfileId,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'photo_squished',
        parameters: {
          'photo_id': photoId,
          'baby_profile_id': babyProfileId,
        },
      );
    } catch (e) {
      debugPrint('Error logging photo squished: $e');
    }
  }

  // ==========================================
  // Event Events
  // ==========================================

  /// Log event created
  static Future<void> logEventCreated({
    required String eventId,
    required String babyProfileId,
    required bool hasLocation,
    required bool hasCoverPhoto,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'event_created',
        parameters: {
          'event_id': eventId,
          'baby_profile_id': babyProfileId,
          'has_location': hasLocation,
          'has_cover_photo': hasCoverPhoto,
        },
      );
    } catch (e) {
      debugPrint('Error logging event created: $e');
    }
  }

  /// Log event RSVP
  static Future<void> logEventRsvp({
    required String eventId,
    required String babyProfileId,
    required String rsvpStatus,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'event_rsvp',
        parameters: {
          'event_id': eventId,
          'baby_profile_id': babyProfileId,
          'rsvp_status': rsvpStatus,
        },
      );
    } catch (e) {
      debugPrint('Error logging event RSVP: $e');
    }
  }

  // ==========================================
  // Registry Events
  // ==========================================

  /// Log registry item added
  static Future<void> logRegistryItemAdded({
    required String itemId,
    required String babyProfileId,
    required bool hasUrl,
    required int priority,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'registry_item_added',
        parameters: {
          'item_id': itemId,
          'baby_profile_id': babyProfileId,
          'has_url': hasUrl,
          'priority': priority,
        },
      );
    } catch (e) {
      debugPrint('Error logging registry item added: $e');
    }
  }

  /// Log registry item purchased
  static Future<void> logRegistryItemPurchased({
    required String itemId,
    required String babyProfileId,
    required int quantity,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'registry_item_purchased',
        parameters: {
          'item_id': itemId,
          'baby_profile_id': babyProfileId,
          'quantity': quantity,
        },
      );
    } catch (e) {
      debugPrint('Error logging registry item purchased: $e');
    }
  }

  // ==========================================
  // Invitation Events
  // ==========================================

  /// Log invitation sent
  static Future<void> logInvitationSent({
    required String babyProfileId,
    required String relationshipType,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'invitation_sent',
        parameters: {
          'baby_profile_id': babyProfileId,
          'relationship_type': relationshipType,
        },
      );
    } catch (e) {
      debugPrint('Error logging invitation sent: $e');
    }
  }

  /// Log invitation accepted
  static Future<void> logInvitationAccepted({
    required String babyProfileId,
    required int timeToAcceptHours,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logEvent(
        name: 'invitation_accepted',
        parameters: {
          'baby_profile_id': babyProfileId,
          'time_to_accept_hours': timeToAcceptHours,
        },
      );
    } catch (e) {
      debugPrint('Error logging invitation accepted: $e');
    }
  }

  // ==========================================
  // User Properties
  // ==========================================

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    if (!_isEnabled) return;
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  // ==========================================
  // Screen Tracking
  // ==========================================

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }
}
