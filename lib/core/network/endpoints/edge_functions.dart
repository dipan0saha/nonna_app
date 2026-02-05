/// Edge Functions endpoints for Supabase serverless functions
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Supabase Edge Function URLs
/// - Function invocation helpers
/// - Payload builders for common operations
///
/// Dependencies: None
class EdgeFunctions {
  // Prevent instantiation
  EdgeFunctions._();

  // ============================================================
  // Edge Function Paths
  // ============================================================

  /// Base path for edge functions
  static const String _functionsBasePath = '/functions/v1';

  /// Tile configuration function
  static const String tileConfigFunction = '$_functionsBasePath/tile-configs';

  /// Notification trigger function
  static const String notificationTriggerFunction =
      '$_functionsBasePath/notification-trigger';

  /// Image processing function
  static const String imageProcessingFunction =
      '$_functionsBasePath/image-processing';

  /// User analytics function
  static const String analyticsFunction = '$_functionsBasePath/analytics';

  /// Data export function
  static const String dataExportFunction = '$_functionsBasePath/data-export';

  /// Webhook handler function
  static const String webhookFunction = '$_functionsBasePath/webhook';

  // ============================================================
  // Tile Config Function Helpers
  // ============================================================

  /// Build payload for fetching tile configs
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name
  static Map<String, dynamic> getTileConfigsPayload({
    required String babyProfileId,
    String? screenName,
  }) {
    return {
      'action': 'get_configs',
      'baby_profile_id': babyProfileId,
      if (screenName != null) 'screen_name': screenName,
    };
  }

  /// Build payload for updating tile order
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name
  /// [tileOrders] List of tile IDs in desired order
  static Map<String, dynamic> updateTileOrderPayload({
    required String babyProfileId,
    required String screenName,
    required List<String> tileOrders,
  }) {
    return {
      'action': 'update_order',
      'baby_profile_id': babyProfileId,
      'screen_name': screenName,
      'tile_orders': tileOrders,
    };
  }

  /// Build payload for resetting tile configs to default
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name (optional, resets all screens if not provided)
  static Map<String, dynamic> resetTileConfigsPayload({
    required String babyProfileId,
    String? screenName,
  }) {
    return {
      'action': 'reset_configs',
      'baby_profile_id': babyProfileId,
      if (screenName != null) 'screen_name': screenName,
    };
  }

  // ============================================================
  // Notification Function Helpers
  // ============================================================

  /// Build payload for triggering a notification
  ///
  /// [recipientId] User ID to receive notification
  /// [type] Notification type
  /// [data] Notification data
  static Map<String, dynamic> sendNotificationPayload({
    required String recipientId,
    required String type,
    Map<String, dynamic>? data,
  }) {
    return {
      'action': 'send',
      'recipient_id': recipientId,
      'type': type,
      if (data != null) 'data': data,
    };
  }

  /// Build payload for bulk notification sending
  ///
  /// [recipientIds] List of user IDs
  /// [type] Notification type
  /// [data] Notification data
  static Map<String, dynamic> sendBulkNotificationsPayload({
    required List<String> recipientIds,
    required String type,
    Map<String, dynamic>? data,
  }) {
    return {
      'action': 'send_bulk',
      'recipient_ids': recipientIds,
      'type': type,
      if (data != null) 'data': data,
    };
  }

  // ============================================================
  // Image Processing Function Helpers
  // ============================================================

  /// Build payload for image processing
  ///
  /// [imageUrl] URL of the image to process
  /// [operations] List of operations to perform
  static Map<String, dynamic> processImagePayload({
    required String imageUrl,
    required List<String> operations,
    Map<String, dynamic>? options,
  }) {
    return {
      'action': 'process',
      'image_url': imageUrl,
      'operations': operations,
      if (options != null) 'options': options,
    };
  }

  /// Build payload for thumbnail generation
  ///
  /// [imageUrl] URL of the image
  /// [width] Thumbnail width
  /// [height] Thumbnail height
  static Map<String, dynamic> generateThumbnailPayload({
    required String imageUrl,
    int width = 200,
    int height = 200,
  }) {
    return {
      'action': 'thumbnail',
      'image_url': imageUrl,
      'width': width,
      'height': height,
    };
  }

  /// Build payload for image compression
  ///
  /// [imageUrl] URL of the image
  /// [quality] Compression quality (0-100)
  static Map<String, dynamic> compressImagePayload({
    required String imageUrl,
    int quality = 80,
  }) {
    return {
      'action': 'compress',
      'image_url': imageUrl,
      'quality': quality,
    };
  }

  // ============================================================
  // Analytics Function Helpers
  // ============================================================

  /// Build payload for tracking an event
  ///
  /// [userId] User ID
  /// [eventName] Event name
  /// [properties] Event properties
  static Map<String, dynamic> trackEventPayload({
    required String userId,
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    return {
      'action': 'track',
      'user_id': userId,
      'event_name': eventName,
      if (properties != null) 'properties': properties,
    };
  }

  /// Build payload for getting user analytics
  ///
  /// [userId] User ID
  /// [startDate] Start date for analytics
  /// [endDate] End date for analytics
  static Map<String, dynamic> getUserAnalyticsPayload({
    required String userId,
    String? startDate,
    String? endDate,
  }) {
    return {
      'action': 'get_analytics',
      'user_id': userId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };
  }

  // ============================================================
  // Data Export Function Helpers
  // ============================================================

  /// Build payload for exporting user data
  ///
  /// [userId] User ID
  /// [babyProfileId] Baby profile ID
  /// [format] Export format (json, csv, etc.)
  static Map<String, dynamic> exportDataPayload({
    required String userId,
    String? babyProfileId,
    String format = 'json',
  }) {
    return {
      'action': 'export',
      'user_id': userId,
      if (babyProfileId != null) 'baby_profile_id': babyProfileId,
      'format': format,
    };
  }

  // ============================================================
  // Webhook Function Helpers
  // ============================================================

  /// Build payload for webhook processing
  ///
  /// [source] Webhook source
  /// [event] Event type
  /// [data] Webhook data
  static Map<String, dynamic> webhookPayload({
    required String source,
    required String event,
    required Map<String, dynamic> data,
  }) {
    return {
      'source': source,
      'event': event,
      'data': data,
    };
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Get full function URL
  ///
  /// [baseUrl] Supabase project URL
  /// [functionPath] Function path
  static String getFunctionUrl(String baseUrl, String functionPath) {
    return '$baseUrl$functionPath';
  }

  /// Build invocation headers
  ///
  /// [apiKey] Supabase API key
  /// [accessToken] User access token (optional)
  static Map<String, String> buildInvocationHeaders({
    required String apiKey,
    String? accessToken,
  }) {
    return {
      'Content-Type': 'application/json',
      'apikey': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }
}
