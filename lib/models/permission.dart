/// Defines granular permissions for the Elite Tennis Ladder system.
///
/// Permissions are fine-grained access controls that can be assigned to roles.
/// This enables flexible Role-Based Access Control (RBAC).
enum Permission {
  // ========== Platform Management (System Admin only) ==========
  /// Manage global user accounts (ban, delete, restore users)
  manageUsers('manage_users', 'Manage Users'),

  /// Configure subscription plans and pricing
  manageSubscriptions('manage_subscriptions', 'Manage Subscriptions'),

  /// View platform-wide analytics and metrics
  viewPlatformAnalytics('view_platform_analytics', 'View Platform Analytics'),

  /// Manage global platform settings
  managePlatformSettings('manage_platform_settings', 'Manage Platform Settings'),

  // ========== Ladder Management (Organizer) ==========
  /// Create new ladder instances
  createLadder('create_ladder', 'Create Ladder'),

  /// Delete ladder instances
  deleteLadder('delete_ladder', 'Delete Ladder'),

  /// Configure ladder rules and settings
  configureLadder('configure_ladder', 'Configure Ladder'),

  /// Manage ladder members (approve, kick)
  manageLadderMembers('manage_ladder_members', 'Manage Ladder Members'),

  /// Resolve match disputes
  resolveDisputes('resolve_disputes', 'Resolve Disputes'),

  /// Overturn or modify match results
  modifyMatchResults('modify_match_results', 'Modify Match Results'),

  /// Send broadcasts to ladder members
  sendBroadcasts('send_broadcasts', 'Send Broadcasts'),

  /// View ladder analytics
  viewLadderAnalytics('view_ladder_analytics', 'View Ladder Analytics'),

  // ========== Player Actions ==========
  /// View ladder details and rankings
  viewLadder('view_ladder', 'View Ladder'),

  /// Issue challenges to other players
  issueChallenges('issue_challenges', 'Issue Challenges'),

  /// Report match scores
  reportMatchScores('report_match_scores', 'Report Match Scores'),

  /// Confirm match scores reported by opponent
  confirmMatchScores('confirm_match_scores', 'Confirm Match Scores'),

  /// Manage own player profile
  manageOwnProfile('manage_own_profile', 'Manage Own Profile'),

  /// View match history
  viewMatchHistory('view_match_history', 'View Match History'),

  // ========== Guest/Spectator Actions ==========
  /// View public ladders (read-only)
  viewPublicLadders('view_public_ladders', 'View Public Ladders'),

  /// View public rankings
  viewPublicRankings('view_public_rankings', 'View Public Rankings');

  /// Database/API identifier for the permission
  final String value;

  /// Human-readable display name for the permission
  final String displayName;

  const Permission(this.value, this.displayName);

  /// Convert a string value to a Permission enum
  static Permission? fromString(String value) {
    try {
      return Permission.values.firstWhere((perm) => perm.value == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => displayName;
}
