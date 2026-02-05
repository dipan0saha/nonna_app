import 'package:nonna_app/core/config/app_config.dart';

/// Social sharing and deep linking utilities
///
/// **Functional Requirements**: Section 3.3.5 - Role & Permission Helpers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides helpers for:
/// - Social sharing utilities
/// - Deep link generation
/// - Invitation link creation
/// - Share sheet integration
///
/// Dependencies: share_plus package (to be integrated)
/// Note: Currently has stub implementations with UnimplementedError
class ShareHelpers {
  // Prevent instantiation
  ShareHelpers._();

  // ============================================================
  // Deep Link Generation
  // ============================================================

  /// Generate deep link for baby profile
  static String generateProfileLink(String profileId) {
    return AppConfig.getFullUrl('/profile/$profileId');
  }

  /// Generate deep link for event
  static String generateEventLink(String profileId, String eventId) {
    return AppConfig.getFullUrl('/profile/$profileId/event/$eventId');
  }

  /// Generate deep link for photo
  static String generatePhotoLink(String profileId, String photoId) {
    return AppConfig.getFullUrl('/profile/$profileId/photo/$photoId');
  }

  /// Generate deep link for registry item
  static String generateRegistryItemLink(String profileId, String itemId) {
    return AppConfig.getFullUrl('/profile/$profileId/registry/$itemId');
  }

  /// Generate invitation link
  static String generateInvitationLink(String invitationCode) {
    return AppConfig.getFullUrl('/invite/$invitationCode');
  }

  // ============================================================
  // Share Text Generation
  // ============================================================

  /// Generate share text for baby profile
  static String generateProfileShareText(String babyName) {
    return 'Check out $babyName\'s profile on Nonna! 👶';
  }

  /// Generate share text for event
  static String generateEventShareText(String eventTitle, DateTime eventDate) {
    return 'You\'re invited to $eventTitle on ${eventDate.toString().split(' ')[0]}! 🎉';
  }

  /// Generate share text for photo
  static String generatePhotoShareText(String babyName, {String? caption}) {
    if (caption != null && caption.isNotEmpty) {
      return '$caption - $babyName on Nonna 📸';
    }
    return 'Check out this photo of $babyName on Nonna! 📸';
  }

  /// Generate share text for registry item
  static String generateRegistryShareText(String babyName) {
    return 'Check out $babyName\'s registry on Nonna! 🎁';
  }

  /// Generate invitation text
  static String generateInvitationText(String babyName, String inviterName) {
    return '$inviterName has invited you to follow $babyName\'s journey on Nonna! 👶';
  }

  // ============================================================
  // Share Subject Lines
  // ============================================================

  /// Generate email subject for profile share
  static String generateProfileSubject(String babyName) {
    return '$babyName on Nonna';
  }

  /// Generate email subject for event invitation
  static String generateEventSubject(String eventTitle) {
    return 'You\'re invited: $eventTitle';
  }

  /// Generate email subject for general invitation
  static String generateInvitationSubject(String babyName) {
    return 'You\'re invited to follow $babyName on Nonna';
  }

  // ============================================================
  // Share Functionality Stubs
  // ============================================================

  /// Share text content
  /// Note: Implement with share_plus package
  static Future<void> shareText(String text, {String? subject}) async {
    // TODO: Implement with share_plus package
    // Example: await Share.share(text, subject: subject);
    throw UnimplementedError('Requires share_plus package');
  }

  /// Share link
  /// Note: Implement with share_plus package
  static Future<void> shareLink(String link, {String? text}) async {
    // TODO: Implement with share_plus package
    // Example: await Share.share('$text\n$link');
    throw UnimplementedError('Requires share_plus package');
  }

  /// Share with specific apps (if needed)
  /// Note: Implement with share_plus package
  static Future<void> shareToApp(String text, String app) async {
    // TODO: Implement platform-specific sharing
    throw UnimplementedError('Requires share_plus package');
  }

  // ============================================================
  // Sharing Utilities
  // ============================================================

  /// Generate full share content (text + link)
  static String generateShareContent({
    required String text,
    required String link,
  }) {
    return '$text\n\n$link';
  }

  /// Format share content for email
  static String formatForEmail({
    required String subject,
    required String body,
    required String link,
  }) {
    return '''
Subject: $subject

$body

$link

---
Sent from Nonna App
''';
  }

  /// Format share content for SMS
  static String formatForSms(String text, String link) {
    // Keep it concise for SMS
    return '$text $link';
  }

  /// Format share content for social media
  static String formatForSocial(String text, String link,
      {List<String>? hashtags}) {
    final hashtagText = hashtags != null && hashtags.isNotEmpty
        ? ' ${hashtags.map((tag) => '#$tag').join(' ')}'
        : '';
    return '$text\n\n$link$hashtagText';
  }

  // ============================================================
  // Invitation Creation
  // ============================================================

  /// Create invitation data structure
  static Map<String, dynamic> createInvitation({
    required String profileId,
    required String inviterName,
    required String inviterEmail,
    String? recipientEmail,
    String? recipientPhone,
    String? personalMessage,
  }) {
    return {
      'profileId': profileId,
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'recipientEmail': recipientEmail,
      'recipientPhone': recipientPhone,
      'personalMessage': personalMessage,
      'invitationCode': _generateInvitationCode(),
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    };
  }

  /// Generate invitation code
  static String _generateInvitationCode() {
    // Generate a random 8-character code using timestamp and random component
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final code = List.generate(8, (index) {
      // Use both timestamp and index to ensure uniqueness
      final charIndex = ((random ~/ (index + 1)) + index * 7) % chars.length;
      return chars[charIndex];
    }).join();
    return code;
  }

  // ============================================================
  // Share Analytics
  // ============================================================

  /// Track share event
  static void trackShare({
    required String contentType,
    required String contentId,
    required String shareMethod,
  }) {
    // TODO: Implement analytics tracking
    // Example: Analytics.logEvent('share', {
    //   'content_type': contentType,
    //   'content_id': contentId,
    //   'method': shareMethod,
    // });
  }

  /// Track invitation sent
  static void trackInvitationSent({
    required String profileId,
    required String method,
  }) {
    // TODO: Implement analytics tracking
  }

  // ============================================================
  // URL Helpers
  // ============================================================

  /// Parse deep link parameters
  static Map<String, String>? parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) return null;

      final params = <String, String>{};

      // Extract path parameters
      if (pathSegments.contains('profile') && pathSegments.length > 1) {
        final profileIndex = pathSegments.indexOf('profile');
        params['profileId'] = pathSegments[profileIndex + 1];

        if (pathSegments.length > profileIndex + 2) {
          params['contentType'] = pathSegments[profileIndex + 2];
          if (pathSegments.length > profileIndex + 3) {
            params['contentId'] = pathSegments[profileIndex + 3];
          }
        }
      } else if (pathSegments.contains('invite') && pathSegments.length > 1) {
        final inviteIndex = pathSegments.indexOf('invite');
        params['invitationCode'] = pathSegments[inviteIndex + 1];
      }

      // Extract query parameters
      params.addAll(uri.queryParameters);

      return params.isEmpty ? null : params;
    } catch (e) {
      return null;
    }
  }

  /// Validate deep link format
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
