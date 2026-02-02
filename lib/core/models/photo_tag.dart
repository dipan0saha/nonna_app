/// Photo tag model representing an individual tag on a photo
///
/// Maps to the `photo_tags` table in Supabase.
/// Supports tag popularity queries and tag-based photo searches.
class PhotoTag {
  /// Unique tag identifier
  final String id;

  /// Photo this tag is associated with
  final String photoId;

  /// Tag text/label
  final String tag;

  /// Timestamp when the tag was created
  final DateTime createdAt;

  /// Creates a new PhotoTag instance
  const PhotoTag({
    required this.id,
    required this.photoId,
    required this.tag,
    required this.createdAt,
  });

  /// Creates a PhotoTag from a JSON map
  factory PhotoTag.fromJson(Map<String, dynamic> json) {
    return PhotoTag(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      tag: json['tag'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this PhotoTag to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the tag data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (tag.trim().isEmpty) {
      return 'Tag cannot be empty';
    }
    if (tag.length > 50) {
      return 'Tag must be 50 characters or less';
    }
    return null;
  }

  /// Creates a copy of this PhotoTag with the specified fields replaced
  PhotoTag copyWith({
    String? id,
    String? photoId,
    String? tag,
    DateTime? createdAt,
  }) {
    return PhotoTag(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhotoTag &&
        other.id == id &&
        other.photoId == photoId &&
        other.tag == tag &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        photoId.hashCode ^
        tag.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'PhotoTag(id: $id, photoId: $photoId, tag: $tag)';
  }
}
