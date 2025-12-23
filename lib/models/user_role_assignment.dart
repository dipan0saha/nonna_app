import 'user_role.dart';

/// Represents a user's role assignment in a specific context.
///
/// This class enables context-specific role assignment, where a user can have
/// different roles in different contexts (e.g., a user can be an Organizer of
/// "Ladder X" but a Player in "Ladder Y").
///
/// For System Admin roles, the ladderId should be null as it's a global role.
class UserRoleAssignment {
  /// The unique identifier of the user
  final String userId;

  /// The role assigned to the user
  final UserRole role;

  /// The ladder ID this role applies to (null for global roles like System Admin)
  ///
  /// For context-specific roles (Organizer, Player), this must be provided.
  /// For global roles (System Admin), this should be null.
  final String? ladderId;

  /// When this role assignment was created
  final DateTime? createdAt;

  /// When this role assignment was last updated
  final DateTime? updatedAt;

  /// Optional metadata for the role assignment
  final Map<String, dynamic>? metadata;

  const UserRoleAssignment({
    required this.userId,
    required this.role,
    this.ladderId,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Create a UserRoleAssignment from a JSON map
  factory UserRoleAssignment.fromJson(Map<String, dynamic> json) {
    return UserRoleAssignment(
      userId: json['user_id'] as String,
      role: UserRole.fromString(json['role'] as String),
      ladderId: json['ladder_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert this UserRoleAssignment to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role.value,
      'ladder_id': ladderId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if this role assignment is for a global role (no ladder context)
  bool get isGlobalRole => ladderId == null;

  /// Check if this role assignment is for a specific ladder
  bool get isLadderSpecific => ladderId != null;

  /// Validate that the role assignment is properly configured
  ///
  /// Returns true if valid, false otherwise.
  /// Rules:
  /// - System Admin should not have a ladder_id (global role)
  /// - Organizer and Player should have a ladder_id (context-specific)
  /// - Guest can be either global or ladder-specific
  bool isValid() {
    if (role.isSystemAdmin && ladderId != null) {
      return false; // System Admin should be global
    }
    if ((role.isOrganizer || role.isPlayer) && ladderId == null) {
      return false; // Organizer and Player must be ladder-specific
    }
    return true;
  }

  /// Create a copy of this UserRoleAssignment with updated fields
  UserRoleAssignment copyWith({
    String? userId,
    UserRole? role,
    String? ladderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserRoleAssignment(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      ladderId: ladderId ?? this.ladderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRoleAssignment &&
        other.userId == userId &&
        other.role == role &&
        other.ladderId == ladderId;
  }

  @override
  int get hashCode => Object.hash(userId, role, ladderId);

  @override
  String toString() {
    final ladderInfo = ladderId != null ? ' (Ladder: $ladderId)' : ' (Global)';
    return 'UserRoleAssignment(userId: $userId, role: ${role.value}$ladderInfo)';
  }
}
