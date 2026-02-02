/// Performance limits and thresholds
///
/// **Functional Requirements**: Section 3.3.7 - Constants
/// Reference: docs/Core_development_component_identification.md
///
/// Defines performance-related constants to optimize app behavior:
/// - Cache TTL values (userProfileCacheDuration, babyProfileCacheDuration, etc.)
/// - Query limits (defaultQueryLimit, maxQueryLimit, notificationQueryLimit, etc.)
/// - Pagination sizes (defaultPageSize, galleryPageSize, eventPageSize, etc.)
/// - Timeout durations (defaultTimeout, imageUploadTimeout, authTimeout, etc.)
/// - Batch sizes (defaultBatchSize, imageUploadBatchSize, notificationBatchSize)
/// - File size limits (maxImageSizeBytes, maxVideoSizeBytes, thumbnailMaxWidth, etc.)
/// - Rate limiting (maxRequestsPerMinute, maxUploadsPerHour, minRequestDelayMs)
/// - UI performance (maxListRenderItems, searchDebounceDelay, animationDuration)
/// - Retry configuration (maxRetryAttempts, initialRetryDelay, retryBackoffMultiplier)
///
/// Dependencies: None
class PerformanceLimits {
  // Prevent instantiation
  PerformanceLimits._();

  // ============================================================
  // Cache TTL (Time To Live) Values
  // ============================================================

  /// Cache duration for user profile data (15 minutes)
  static const Duration userProfileCacheDuration = Duration(minutes: 15);

  /// Cache duration for baby profile data (10 minutes)
  static const Duration babyProfileCacheDuration = Duration(minutes: 10);

  /// Cache duration for tile configurations (30 minutes)
  static const Duration tileConfigCacheDuration = Duration(minutes: 30);

  /// Cache duration for static assets (1 hour)
  static const Duration assetCacheDuration = Duration(hours: 1);

  /// Cache duration for API responses (5 minutes)
  static const Duration apiCacheDuration = Duration(minutes: 5);

  /// Cache duration for images (1 day)
  static const Duration imageCacheDuration = Duration(days: 1);

  // ============================================================
  // Query Limits
  // ============================================================

  /// Default limit for database queries
  static const int defaultQueryLimit = 50;

  /// Maximum number of items in a single query
  static const int maxQueryLimit = 100;

  /// Minimum number of items in a query
  static const int minQueryLimit = 10;

  /// Default limit for notification queries
  static const int notificationQueryLimit = 20;

  /// Default limit for event queries
  static const int eventQueryLimit = 30;

  /// Default limit for photo queries
  static const int photoQueryLimit = 20;

  /// Default limit for registry item queries
  static const int registryQueryLimit = 50;

  /// Default limit for search results
  static const int searchResultLimit = 25;

  // ============================================================
  // Pagination Sizes
  // ============================================================

  /// Default page size for pagination
  static const int defaultPageSize = 20;

  /// Page size for photo gallery
  static const int galleryPageSize = 12;

  /// Page size for event list
  static const int eventPageSize = 10;

  /// Page size for notification list
  static const int notificationPageSize = 15;

  /// Page size for comment list
  static const int commentPageSize = 20;

  /// Page size for follower list
  static const int followerPageSize = 30;

  // ============================================================
  // Timeout Durations
  // ============================================================

  /// Default API request timeout
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Short timeout for quick operations
  static const Duration shortTimeout = Duration(seconds: 10);

  /// Long timeout for large uploads
  static const Duration longTimeout = Duration(minutes: 2);

  /// Image upload timeout
  static const Duration imageUploadTimeout = Duration(minutes: 1);

  /// File download timeout
  static const Duration downloadTimeout = Duration(minutes: 3);

  /// Authentication timeout
  static const Duration authTimeout = Duration(seconds: 15);

  // ============================================================
  // Batch Sizes
  // ============================================================

  /// Default batch size for bulk operations
  static const int defaultBatchSize = 10;

  /// Maximum batch size
  static const int maxBatchSize = 50;

  /// Batch size for image uploads
  static const int imageUploadBatchSize = 5;

  /// Batch size for notifications
  static const int notificationBatchSize = 20;

  // ============================================================
  // File Size Limits
  // ============================================================

  /// Maximum file size for images (10 MB)
  static const int maxImageSizeBytes = 10 * 1024 * 1024;

  /// Maximum file size for videos (50 MB)
  static const int maxVideoSizeBytes = 50 * 1024 * 1024;

  /// Maximum file size for documents (5 MB)
  static const int maxDocumentSizeBytes = 5 * 1024 * 1024;

  /// Thumbnail maximum dimensions
  static const int thumbnailMaxWidth = 300;
  static const int thumbnailMaxHeight = 300;

  /// Preview image maximum dimensions
  static const int previewMaxWidth = 800;
  static const int previewMaxHeight = 800;

  // ============================================================
  // Rate Limiting
  // ============================================================

  /// Maximum number of API requests per minute
  static const int maxRequestsPerMinute = 60;

  /// Maximum number of uploads per hour
  static const int maxUploadsPerHour = 100;

  /// Minimum delay between requests (milliseconds)
  static const int minRequestDelayMs = 100;

  // ============================================================
  // UI Performance
  // ============================================================

  /// Maximum number of items to render in a list at once
  static const int maxListRenderItems = 100;

  /// Number of items to load initially
  static const int initialLoadCount = 20;

  /// Number of items to load on scroll
  static const int loadMoreCount = 10;

  /// Debounce duration for search input
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  /// Throttle duration for scroll events
  static const Duration scrollThrottleDelay = Duration(milliseconds: 100);

  /// Animation duration for UI transitions
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ============================================================
  // Retry Configuration
  // ============================================================

  /// Maximum number of retry attempts
  static const int maxRetryAttempts = 3;

  /// Initial retry delay
  static const Duration initialRetryDelay = Duration(seconds: 1);

  /// Maximum retry delay
  static const Duration maxRetryDelay = Duration(seconds: 10);

  /// Retry backoff multiplier
  static const double retryBackoffMultiplier = 2.0;
}
