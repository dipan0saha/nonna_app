/// Defines the core user roles in the Elite Tennis Ladder system.
///
/// The system supports a clear separation between platform administration
/// (System Admin) and user-driven tournament organization (Tournament Organizer).
enum UserRole {
  /// System Administrator - the "superuser" who manages the SaaS platform itself.
  ///
  /// Capabilities:
  /// - Manage global user database (ban/delete users)
  /// - Configure subscription plans (Free vs. Premium)
  /// - View platform-wide analytics (server load, total active ladders)
  /// - Note: Cannot interfere with match results inside a specific organizer's private ladder
  systemAdmin('system_admin', 'System Admin'),

  /// Tournament Organizer - a user who "owns" a specific ladder instance.
  ///
  /// Capabilities:
  /// - Create/Delete Ladders with custom rules (points per win, challenge range)
  /// - Member Management (approve/kick players from their specific ladder)
  /// - Dispute Resolution (overturn match results if players disagree)
  /// - Broadcasting (send email/in-app blasts to all players in their ladder)
  ///
  /// Note: This role is context-specific (tied to a specific ladder_id)
  organizer('organizer', 'Tournament Organizer'),

  /// Player - an end-user participating in a ladder.
  ///
  /// Capabilities:
  /// - Manage profile (stats, availability, home court location)
  /// - Issue challenges to other players within allowed rank range
  /// - Input match scores (Winner reports, Loser confirms)
  /// - View live rankings and match history
  ///
  /// Note: This role is context-specific (tied to a specific ladder_id)
  player('player', 'Player'),

  /// Guest/Spectator - a non-logged-in or limited-access user.
  ///
  /// Capabilities:
  /// - View public ladders (read-only)
  /// - View public rankings and match history
  /// - Cannot challenge other players or submit scores
  /// - Cannot access private ladders
  guest('guest', 'Guest');

  /// Database/API identifier for the role
  final String value;

  /// Human-readable display name for the role
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Convert a string value to a UserRole enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.guest,
    );
  }

  /// Check if this role is a System Admin
  bool get isSystemAdmin => this == UserRole.systemAdmin;

  /// Check if this role is a Tournament Organizer
  bool get isOrganizer => this == UserRole.organizer;

  /// Check if this role is a Player
  bool get isPlayer => this == UserRole.player;

  /// Check if this role is a Guest
  bool get isGuest => this == UserRole.guest;

  @override
  String toString() => displayName;
}
