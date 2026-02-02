/// Photo model representing a photo in the gallery
///
/// Maps to the `photos` table in Supabase.
/// Photos are tied to a baby profile and support tags, comments, and squishes (likes).
class Photo {
  /// Unique photo identifier
  final String id;

  /// Baby profile this photo is associated with
  final String babyProfileId;

  /// User who uploaded this photo
  final String uploadedByUserId;

  /// Storage path to the photo in Supabase Storage
  final String storagePath;

  /// Storage path to the thumbnail version of the photo
  final String? thumbnailPath;

  /// Photo caption/description
  final String? caption;

  /// List of tags associated with the photo (max 5)
  final List<String> tags;

  /// Timestamp when the photo was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the photo was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// Creates a new Photo instance
  const Photo({
    required this.id,
    required this.babyProfileId,
    required this.uploadedByUserId,
    required this.storagePath,
    this.thumbnailPath,
    this.caption,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Creates a Photo from a JSON map
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      uploadedByUserId: json['uploaded_by_user_id'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      caption: json['caption'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this Photo to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'uploaded_by_user_id': uploadedByUserId,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Validates the photo data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (storagePath.trim().isEmpty) {
      return 'Storage path is required';
    }
    if (caption != null && caption!.length > 500) {
      return 'Caption must be 500 characters or less';
    }
    if (tags.length > 5) {
      return 'Maximum 5 tags allowed';
    }
    for (final tag in tags) {
      if (tag.trim().isEmpty) {
        return 'Tags cannot be empty';
      }
      if (tag.length > 50) {
        return 'Each tag must be 50 characters or less';
      }
    }
    return null;
  }

  /// Checks if the photo is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Checks if the photo has any tags
  bool get hasTags => tags.isNotEmpty;

  /// Checks if the photo has a caption
  bool get hasCaption => caption != null && caption!.isNotEmpty;

  /// Creates a copy of this Photo with the specified fields replaced
  Photo copyWith({
    String? id,
    String? babyProfileId,
    String? uploadedByUserId,
    String? storagePath,
    String? thumbnailPath,
    String? caption,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
      storagePath: storagePath ?? this.storagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Photo &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.uploadedByUserId == uploadedByUserId &&
        other.storagePath == storagePath &&
        other.thumbnailPath == thumbnailPath &&
        other.caption == caption &&
        _listEquals(other.tags, tags) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        uploadedByUserId.hashCode ^
        storagePath.hashCode ^
        thumbnailPath.hashCode ^
        caption.hashCode ^
        Object.hashAll(tags) ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'Photo(id: $id, babyProfileId: $babyProfileId, hasTags: $hasTags, hasCaption: $hasCaption)';
  }

  /// Helper method to compare two lists for equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
