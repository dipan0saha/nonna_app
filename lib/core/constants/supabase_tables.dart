/// Supabase table and column name constants
///
/// Prevents typos and makes refactoring easier by centralizing
/// all database table and column names.
class SupabaseTables {
  // Prevent instantiation
  SupabaseTables._();

  // ============================================================
  // Table Names
  // ============================================================
  
  // User-related tables
  static const String users = 'users';
  static const String userProfiles = 'user_profiles';
  static const String userStats = 'user_stats';
  
  // Baby profile tables
  static const String babyProfiles = 'baby_profiles';
  static const String babyMemberships = 'baby_memberships';
  static const String invitations = 'invitations';
  
  // Tile system tables
  static const String tileConfigs = 'tile_configs';
  static const String screenConfigs = 'screen_configs';
  
  // Calendar and events tables
  static const String events = 'events';
  static const String eventRsvps = 'event_rsvps';
  static const String eventComments = 'event_comments';
  
  // Registry tables
  static const String registryItems = 'registry_items';
  static const String registryPurchases = 'registry_purchases';
  
  // Photo gallery tables
  static const String photos = 'photos';
  static const String photoSquishes = 'photo_squishes';
  static const String photoComments = 'photo_comments';
  static const String photoTags = 'photo_tags';
  
  // Gamification tables
  static const String votes = 'votes';
  static const String nameSuggestions = 'name_suggestions';
  static const String nameSuggestionLikes = 'name_suggestion_likes';
  
  // Notifications and activity tables
  static const String notifications = 'notifications';
  static const String activityEvents = 'activity_events';
  
  // Supporting tables
  static const String ownerUpdateMarkers = 'owner_update_markers';
  
  // ============================================================
  // Common Column Names
  // ============================================================
  
  // Primary keys
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String babyProfileId = 'baby_profile_id';
  
  // Timestamps
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String deletedAt = 'deleted_at';
  
  // Common fields
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';
  static const String status = 'status';
  static const String type = 'type';
  static const String description = 'description';
  static const String imageUrl = 'image_url';
  static const String thumbnailUrl = 'thumbnail_url';
  
  // ============================================================
  // User Profile Columns
  // ============================================================
  
  static const String displayName = 'display_name';
  static const String avatarUrl = 'avatar_url';
  static const String phoneNumber = 'phone_number';
  static const String dateOfBirth = 'date_of_birth';
  
  // ============================================================
  // Baby Profile Columns
  // ============================================================
  
  static const String dueDate = 'due_date';
  static const String birthDate = 'birth_date';
  static const String gender = 'gender';
  static const String ownerId = 'owner_id';
  
  // ============================================================
  // Event Columns
  // ============================================================
  
  static const String title = 'title';
  static const String eventDate = 'event_date';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String location = 'location';
  static const String eventType = 'event_type';
  
  // ============================================================
  // Photo Columns
  // ============================================================
  
  static const String photoUrl = 'photo_url';
  static const String caption = 'caption';
  static const String likeCount = 'like_count';
  static const String commentCount = 'comment_count';
  
  // ============================================================
  // Registry Columns
  // ============================================================
  
  static const String productName = 'product_name';
  static const String productUrl = 'product_url';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String purchased = 'purchased';
  static const String purchasedBy = 'purchased_by';
  static const String purchasedAt = 'purchased_at';
  
  // ============================================================
  // Notification Columns
  // ============================================================
  
  static const String recipientId = 'recipient_id';
  static const String senderId = 'sender_id';
  static const String notificationType = 'notification_type';
  static const String message = 'message';
  static const String read = 'read';
  static const String readAt = 'read_at';
  static const String data = 'data';
  
  // ============================================================
  // Storage Buckets
  // ============================================================
  
  static const String profilePhotos = 'profile-photos';
  static const String babyPhotos = 'baby-photos';
  static const String eventPhotos = 'event-photos';
  static const String galleryPhotos = 'gallery-photos';
  static const String thumbnails = 'thumbnails';
}
