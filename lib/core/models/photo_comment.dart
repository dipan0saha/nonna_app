/// Photo comment model representing a comment on a photo
///
/// Maps to the `photo_comments` table in Supabase.
/// Supports soft deletion with moderation tracking.
class PhotoComment {
  /// Unique comment identifier
  final String id;

  /// Photo this comment is associated with
  final String photoId;

  /// User who created this comment
  final String userId;

  /// Comment body/text
  final String body;

  /// Timestamp when the comment was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the comment was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// User who deleted this comment (null if not deleted)
  final String? deletedByUserId;

  /// Creates a new PhotoComment instance
  const PhotoComment({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserId,
  });

  /// Creates a PhotoComment from a JSON map
  factory PhotoComment.fromJson(Map<String, dynamic> json) {
    return PhotoComment(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deletedByUserId: json['deleted_by_user_id'] as String?,
    );
  }

  /// Converts this PhotoComment to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by_user_id': deletedByUserId,
    };
  }

  /// Validates the comment data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (body.trim().isEmpty) {
      return 'Comment body is required';
    }
    if (body.length > 1000) {
      return 'Comment body must be 1000 characters or less';
    }
    if (deletedAt != null && deletedByUserId == null) {
      return 'Deleted by user ID is required when comment is deleted';
    }
    return null;
  }

  /// Checks if the comment is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Creates a copy of this PhotoComment with the specified fields replaced
  PhotoComment copyWith({
    String? id,
    String? photoId,
    String? userId,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedByUserId,
  }) {
    return PhotoComment(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedByUserId: deletedByUserId ?? this.deletedByUserId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhotoComment &&
        other.id == id &&
        other.photoId == photoId &&
        other.userId == userId &&
        other.body == body &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.deletedByUserId == deletedByUserId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        photoId.hashCode ^
        userId.hashCode ^
        body.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode ^
        deletedByUserId.hashCode;
  }

  @override
  String toString() {
    return 'PhotoComment(id: $id, photoId: $photoId, userId: $userId, isDeleted: $isDeleted)';
  }
}
