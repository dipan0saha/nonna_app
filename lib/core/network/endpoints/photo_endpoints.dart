import '../../constants/supabase_tables.dart';

/// Photo endpoints for photo gallery operations
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Photo CRUD endpoints
/// - Photo squish (like) endpoints
/// - Photo comment endpoints
/// - Photo tag queries
///
/// Dependencies: SupabaseTables
class PhotoEndpoints {
  // Prevent instantiation
  PhotoEndpoints._();

  // ============================================================
  // Photo CRUD Operations
  // ============================================================

  /// Get all photos for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  static String getPhotos(String babyProfileId) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=created_at.desc';
  }

  /// Get a specific photo
  ///
  /// [photoId] Photo ID
  static String getPhoto(String photoId) {
    return '${SupabaseTables.photos}?id=eq.$photoId&select=*';
  }

  /// Get recent photos
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of photos to return
  static String getRecentPhotos(String babyProfileId, {int limit = 10}) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=created_at.desc&limit=$limit';
  }

  /// Create a new photo
  static String createPhoto() {
    return SupabaseTables.photos;
  }

  /// Update a photo
  ///
  /// [photoId] Photo ID
  static String updatePhoto(String photoId) {
    return '${SupabaseTables.photos}?id=eq.$photoId';
  }

  /// Delete a photo (soft delete)
  ///
  /// [photoId] Photo ID
  static String deletePhoto(String photoId) {
    return '${SupabaseTables.photos}?id=eq.$photoId';
  }

  // ============================================================
  // Photo Squishes (Likes)
  // ============================================================

  /// Get all squishes for a photo
  ///
  /// [photoId] Photo ID
  static String getPhotoSquishes(String photoId) {
    return '${SupabaseTables.photoSquishes}?photo_id=eq.$photoId&select=*';
  }

  /// Get user's squish for a photo
  ///
  /// [photoId] Photo ID
  /// [userId] User ID
  static String getUserSquish(String photoId, String userId) {
    return '${SupabaseTables.photoSquishes}?photo_id=eq.$photoId&user_id=eq.$userId&select=*';
  }

  /// Create a squish
  static String createSquish() {
    return SupabaseTables.photoSquishes;
  }

  /// Delete a squish
  ///
  /// [squishId] Squish ID
  static String deleteSquish(String squishId) {
    return '${SupabaseTables.photoSquishes}?id=eq.$squishId';
  }

  /// Get squish count for a photo
  ///
  /// [photoId] Photo ID
  static String getSquishCount(String photoId) {
    return '${SupabaseTables.photoSquishes}?photo_id=eq.$photoId&select=count';
  }

  // ============================================================
  // Photo Comments
  // ============================================================

  /// Get all comments for a photo
  ///
  /// [photoId] Photo ID
  static String getPhotoComments(String photoId) {
    return '${SupabaseTables.photoComments}?photo_id=eq.$photoId&select=*&order=created_at.desc';
  }

  /// Create a new comment
  static String createPhotoComment() {
    return SupabaseTables.photoComments;
  }

  /// Update a comment
  ///
  /// [commentId] Comment ID
  static String updatePhotoComment(String commentId) {
    return '${SupabaseTables.photoComments}?id=eq.$commentId';
  }

  /// Delete a comment
  ///
  /// [commentId] Comment ID
  static String deletePhotoComment(String commentId) {
    return '${SupabaseTables.photoComments}?id=eq.$commentId';
  }

  // ============================================================
  // Photo Tags
  // ============================================================

  /// Get all tags for a photo
  ///
  /// [photoId] Photo ID
  static String getPhotoTags(String photoId) {
    return '${SupabaseTables.photoTags}?photo_id=eq.$photoId&select=*';
  }

  /// Get photos by tag
  ///
  /// [babyProfileId] Baby profile ID
  /// [userId] User ID tagged in photos
  static String getPhotosByTag(String babyProfileId, String userId) {
    return '${SupabaseTables.photoTags}?photo_id.baby_profile_id=eq.$babyProfileId&tagged_user_id=eq.$userId&select=photo_id(*)';
  }

  /// Create a photo tag
  static String createPhotoTag() {
    return SupabaseTables.photoTags;
  }

  /// Delete a photo tag
  ///
  /// [tagId] Tag ID
  static String deletePhotoTag(String tagId) {
    return '${SupabaseTables.photoTags}?id=eq.$tagId';
  }

  // ============================================================
  // Photo Search & Filter
  // ============================================================

  /// Search photos by caption
  ///
  /// [babyProfileId] Baby profile ID
  /// [searchTerm] Search term
  static String searchPhotos(String babyProfileId, String searchTerm) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&caption=ilike.*$searchTerm*&is:deleted_at.null&select=*&order=created_at.desc';
  }

  /// Get photos by date range
  ///
  /// [babyProfileId] Baby profile ID
  /// [startDate] Start date in ISO format
  /// [endDate] End date in ISO format
  static String getPhotosByDateRange(
    String babyProfileId,
    String startDate,
    String endDate,
  ) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&created_at=gte.$startDate&created_at=lte.$endDate&is:deleted_at.null&select=*&order=created_at.desc';
  }

  /// Get photos uploaded by a user
  ///
  /// [babyProfileId] Baby profile ID
  /// [userId] User ID
  static String getPhotosByUploader(String babyProfileId, String userId) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&uploaded_by_user_id=eq.$userId&is:deleted_at.null&select=*&order=created_at.desc';
  }

  /// Get favorite photos (most squished)
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of photos to return
  static String getFavoritePhotos(String babyProfileId, {int limit = 10}) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=squish_count.desc&limit=$limit';
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Build photo query with pagination
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of photos to return
  /// [offset] Number of photos to skip
  static String getPhotosWithPagination(
    String babyProfileId, {
    int limit = 20,
    int offset = 0,
  }) {
    return '${SupabaseTables.photos}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=created_at.desc&limit=$limit&offset=$offset';
  }

  /// Get photo statistics
  ///
  /// [photoId] Photo ID
  static String getPhotoStats(String photoId) {
    return '${SupabaseTables.photos}?id=eq.$photoId&select=squish_count,comment_count';
  }
}
