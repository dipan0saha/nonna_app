/// Invitation status enumeration
///
/// **Functional Requirements**: Section 3.3.9 - Enums & Type Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Defines the lifecycle states of invitations in the Nonna app.
///
/// Invitation lifecycle:
/// - pending: Invitation sent but not yet responded to
/// - accepted: Invitation accepted (user joined as follower)
/// - revoked: Invitation revoked by the sender
/// - expired: Invitation expired (7 days timeout)
///
/// Used to track invitation status and manage follower access.
/// Includes string conversion and display names.
///
/// Dependencies: None
enum InvitationStatus {
  /// Invitation has been sent but not yet responded to
  pending,

  /// Invitation has been accepted
  accepted,

  /// Invitation has been revoked by the sender
  revoked,

  /// Invitation has expired (7 days)
  expired;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create an InvitationStatus from a string
  static InvitationStatus fromJson(String value) {
    return InvitationStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => InvitationStatus.pending,
    );
  }

  /// Get a display-friendly name for the invitation status
  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.revoked:
        return 'Revoked';
      case InvitationStatus.expired:
        return 'Expired';
    }
  }

  /// Check if the invitation is still actionable
  bool get isActionable => this == InvitationStatus.pending;

  /// Check if the invitation is no longer valid
  bool get isInvalid =>
      this == InvitationStatus.revoked || this == InvitationStatus.expired;
}
