import '../enums/invitation_status.dart';

/// Invitation model representing an invitation to join a baby profile
///
/// Maps to the `invitations` table in Supabase.
/// Manages the lifecycle of invitations from pending to accepted/revoked/expired.
class Invitation {
  /// Unique invitation identifier
  final String id;

  /// Associated baby profile ID
  final String babyProfileId;

  /// User ID of the person who sent the invitation
  final String invitedByUserId;

  /// Email address of the invitee
  final String inviteeEmail;

  /// Hashed token for secure invitation acceptance
  final String tokenHash;

  /// Timestamp when the invitation expires (typically 7 days from creation)
  final DateTime expiresAt;

  /// Current status of the invitation
  final InvitationStatus status;

  /// Timestamp when the invitation was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// User ID who accepted the invitation (null if not accepted)
  final String? acceptedByUserId;

  /// Timestamp when the invitation was accepted
  final DateTime? acceptedAt;

  /// Creates a new Invitation instance
  const Invitation({
    required this.id,
    required this.babyProfileId,
    required this.invitedByUserId,
    required this.inviteeEmail,
    required this.tokenHash,
    required this.expiresAt,
    this.status = InvitationStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedByUserId,
    this.acceptedAt,
  });

  /// Creates an Invitation from a JSON map
  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      invitedByUserId: json['invited_by_user_id'] as String,
      inviteeEmail: json['invitee_email'] as String,
      tokenHash: json['token_hash'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: InvitationStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      acceptedByUserId: json['accepted_by_user_id'] as String?,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
    );
  }

  /// Converts this Invitation to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'invited_by_user_id': invitedByUserId,
      'invitee_email': inviteeEmail,
      'token_hash': tokenHash,
      'expires_at': expiresAt.toIso8601String(),
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'accepted_by_user_id': acceptedByUserId,
      'accepted_at': acceptedAt?.toIso8601String(),
    };
  }

  /// Validates the invitation data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    // Basic email validation
    if (!inviteeEmail.contains('@')) {
      return 'Invalid email address';
    }
    if (inviteeEmail.length > 255) {
      return 'Email address must be 255 characters or less';
    }

    // Expiration validation (should be within 7 days from creation)
    final daysDifference = expiresAt.difference(createdAt).inDays;
    if (daysDifference < 0 || daysDifference > 7) {
      return 'Expiration must be between 0 and 7 days from creation';
    }

    // Status transition validation
    if (status == InvitationStatus.accepted && acceptedByUserId == null) {
      return 'Accepted invitation must have acceptedByUserId';
    }

    if (status == InvitationStatus.accepted && acceptedAt == null) {
      return 'Accepted invitation must have acceptedAt';
    }

    return null;
  }

  /// Checks if the invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Checks if the invitation is still actionable
  bool get canBeAccepted => status == InvitationStatus.pending && !isExpired;

  /// Creates a copy of this Invitation with the specified fields replaced
  Invitation copyWith({
    String? id,
    String? babyProfileId,
    String? invitedByUserId,
    String? inviteeEmail,
    String? tokenHash,
    DateTime? expiresAt,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? acceptedByUserId,
    DateTime? acceptedAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      tokenHash: tokenHash ?? this.tokenHash,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedByUserId: acceptedByUserId ?? this.acceptedByUserId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Invitation &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.invitedByUserId == invitedByUserId &&
        other.inviteeEmail == inviteeEmail &&
        other.tokenHash == tokenHash &&
        other.expiresAt == expiresAt &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.acceptedByUserId == acceptedByUserId &&
        other.acceptedAt == acceptedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        invitedByUserId.hashCode ^
        inviteeEmail.hashCode ^
        tokenHash.hashCode ^
        expiresAt.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        acceptedByUserId.hashCode ^
        acceptedAt.hashCode;
  }

  @override
  String toString() {
    return 'Invitation(id: $id, inviteeEmail: $inviteeEmail, status: $status, isExpired: $isExpired)';
  }
}
