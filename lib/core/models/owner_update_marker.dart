/// Owner update marker model for cache invalidation tracking
///
/// Maps to the `owner_update_markers` table in Supabase.
/// Tracks when tiles need to be refreshed due to owner updates.
/// Has a 1:1 relationship with baby_profile.
class OwnerUpdateMarker {
  /// Unique marker identifier
  final String id;

  /// Baby profile this marker is associated with
  final String babyProfileId;

  /// Timestamp of last tile update by owner
  final DateTime tilesLastUpdatedAt;

  /// User who made the update
  final String updatedByUserId;

  /// Reason for the update
  final String? reason;

  /// Timestamp when the marker was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new OwnerUpdateMarker instance
  const OwnerUpdateMarker({
    required this.id,
    required this.babyProfileId,
    required this.tilesLastUpdatedAt,
    required this.updatedByUserId,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an OwnerUpdateMarker from a JSON map
  factory OwnerUpdateMarker.fromJson(Map<String, dynamic> json) {
    return OwnerUpdateMarker(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      tilesLastUpdatedAt:
          DateTime.parse(json['tiles_last_updated_at'] as String),
      updatedByUserId: json['updated_by_user_id'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this OwnerUpdateMarker to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'tiles_last_updated_at': tilesLastUpdatedAt.toIso8601String(),
      'updated_by_user_id': updatedByUserId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the owner update marker data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (babyProfileId.trim().isEmpty) {
      return 'Baby profile ID is required';
    }
    if (updatedByUserId.trim().isEmpty) {
      return 'Updated by user ID is required';
    }
    if (reason != null && reason!.length > 500) {
      return 'Reason must be 500 characters or less';
    }
    return null;
  }

  /// Checks if the marker has a reason
  bool get hasReason => reason != null && reason!.isNotEmpty;

  /// Checks if tiles need refresh based on a given timestamp
  bool needsRefresh(DateTime lastFetched) {
    return tilesLastUpdatedAt.isAfter(lastFetched);
  }

  /// Creates a copy of this OwnerUpdateMarker with the specified fields replaced
  OwnerUpdateMarker copyWith({
    String? id,
    String? babyProfileId,
    DateTime? tilesLastUpdatedAt,
    String? updatedByUserId,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerUpdateMarker(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      tilesLastUpdatedAt: tilesLastUpdatedAt ?? this.tilesLastUpdatedAt,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OwnerUpdateMarker &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.tilesLastUpdatedAt == tilesLastUpdatedAt &&
        other.updatedByUserId == updatedByUserId &&
        other.reason == reason &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        tilesLastUpdatedAt.hashCode ^
        updatedByUserId.hashCode ^
        reason.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'OwnerUpdateMarker(id: $id, babyProfileId: $babyProfileId, tilesLastUpdatedAt: $tilesLastUpdatedAt, hasReason: $hasReason)';
  }
}
