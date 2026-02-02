/// Photo squish model representing a like/favorite on a photo
///
/// Maps to the `photo_squishes` table in Supabase.
/// Each user can squish a photo only once (unique per user/photo).
/// Supports toggle functionality (can un-squish).
class PhotoSquish {
  /// Unique squish identifier
  final String id;

  /// Photo that was squished
  final String photoId;

  /// User who squished the photo
  final String userId;

  /// Timestamp when the squish was created
  final DateTime createdAt;

  /// Creates a new PhotoSquish instance
  const PhotoSquish({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.createdAt,
  });

  /// Creates a PhotoSquish from a JSON map
  factory PhotoSquish.fromJson(Map<String, dynamic> json) {
    return PhotoSquish(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this PhotoSquish to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the squish data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    // No specific validation needed beyond type checks
    return null;
  }

  /// Creates a copy of this PhotoSquish with the specified fields replaced
  PhotoSquish copyWith({
    String? id,
    String? photoId,
    String? userId,
    DateTime? createdAt,
  }) {
    return PhotoSquish(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhotoSquish &&
        other.id == id &&
        other.photoId == photoId &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        photoId.hashCode ^
        userId.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'PhotoSquish(id: $id, photoId: $photoId, userId: $userId)';
  }
}
