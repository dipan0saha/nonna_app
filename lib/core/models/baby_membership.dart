import '../enums/user_role.dart';

/// Baby membership model representing a user's role in a baby profile
///
/// Maps to the `baby_memberships` table in Supabase.
/// Links users to baby profiles with specific roles (owner or follower).
class BabyMembership {
  /// Associated baby profile ID
  final String babyProfileId;

  /// Associated user ID
  final String userId;

  /// User's role for this baby profile
  final UserRole role;

  /// Optional relationship label (e.g., "Mother", "Father", "Aunt")
  final String? relationshipLabel;

  /// Timestamp when the membership was created
  final DateTime createdAt;

  /// Timestamp when the membership was removed (null if active)
  final DateTime? removedAt;

  /// Creates a new BabyMembership instance
  const BabyMembership({
    required this.babyProfileId,
    required this.userId,
    required this.role,
    this.relationshipLabel,
    required this.createdAt,
    this.removedAt,
  });

  /// Creates a BabyMembership from a JSON map
  factory BabyMembership.fromJson(Map<String, dynamic> json) {
    return BabyMembership(
      babyProfileId: json['baby_profile_id'] as String,
      userId: json['user_id'] as String,
      role: UserRole.fromJson(json['role'] as String),
      relationshipLabel: json['relationship_label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      removedAt: json['removed_at'] != null
          ? DateTime.parse(json['removed_at'] as String)
          : null,
    );
  }

  /// Converts this BabyMembership to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'baby_profile_id': babyProfileId,
      'user_id': userId,
      'role': role.toJson(),
      'relationship_label': relationshipLabel,
      'created_at': createdAt.toIso8601String(),
      'removed_at': removedAt?.toIso8601String(),
    };
  }

  /// Validates the baby membership data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (relationshipLabel != null && relationshipLabel!.length > 50) {
      return 'Relationship label must be 50 characters or less';
    }
    return null;
  }

  /// Checks if the membership is active
  bool get isActive => removedAt == null;

  /// Checks if the membership is removed
  bool get isRemoved => removedAt != null;

  /// Creates a copy of this BabyMembership with the specified fields replaced
  BabyMembership copyWith({
    String? babyProfileId,
    String? userId,
    UserRole? role,
    String? relationshipLabel,
    DateTime? createdAt,
    DateTime? removedAt,
  }) {
    return BabyMembership(
      babyProfileId: babyProfileId ?? this.babyProfileId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      relationshipLabel: relationshipLabel ?? this.relationshipLabel,
      createdAt: createdAt ?? this.createdAt,
      removedAt: removedAt ?? this.removedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BabyMembership &&
        other.babyProfileId == babyProfileId &&
        other.userId == userId &&
        other.role == role &&
        other.relationshipLabel == relationshipLabel &&
        other.createdAt == createdAt &&
        other.removedAt == removedAt;
  }

  @override
  int get hashCode {
    return babyProfileId.hashCode ^
        userId.hashCode ^
        role.hashCode ^
        relationshipLabel.hashCode ^
        createdAt.hashCode ^
        removedAt.hashCode;
  }

  @override
  String toString() {
    return 'BabyMembership(babyProfileId: $babyProfileId, userId: $userId, role: $role, isActive: $isActive)';
  }
}
