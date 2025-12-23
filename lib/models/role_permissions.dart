import 'permission.dart';
import 'user_role.dart';

/// Maps roles to their associated permissions.
///
/// This class defines the default permission sets for each role in the system.
class RolePermissions {
  RolePermissions._(); // Private constructor to prevent instantiation

  /// Get all permissions for a given role
  static Set<Permission> getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return _systemAdminPermissions;
      case UserRole.organizer:
        return _organizerPermissions;
      case UserRole.player:
        return _playerPermissions;
      case UserRole.guest:
        return _guestPermissions;
    }
  }

  /// System Admin permissions - full platform management
  static final Set<Permission> _systemAdminPermissions = {
    Permission.manageUsers,
    Permission.manageSubscriptions,
    Permission.viewPlatformAnalytics,
    Permission.managePlatformSettings,
    // System Admins can also view ladders but cannot interfere with match results
    Permission.viewLadder,
    Permission.viewPublicLadders,
    Permission.viewPublicRankings,
    Permission.viewLadderAnalytics,
  };

  /// Tournament Organizer permissions - ladder management and moderation
  static final Set<Permission> _organizerPermissions = {
    Permission.createLadder,
    Permission.deleteLadder,
    Permission.configureLadder,
    Permission.manageLadderMembers,
    Permission.resolveDisputes,
    Permission.modifyMatchResults,
    Permission.sendBroadcasts,
    Permission.viewLadderAnalytics,
    // Organizers can also do everything a player can in their own ladder
    Permission.viewLadder,
    Permission.issueChallenges,
    Permission.reportMatchScores,
    Permission.confirmMatchScores,
    Permission.manageOwnProfile,
    Permission.viewMatchHistory,
  };

  /// Player permissions - participate in ladder activities
  static final Set<Permission> _playerPermissions = {
    Permission.viewLadder,
    Permission.issueChallenges,
    Permission.reportMatchScores,
    Permission.confirmMatchScores,
    Permission.manageOwnProfile,
    Permission.viewMatchHistory,
  };

  /// Guest/Spectator permissions - read-only access to public content
  static final Set<Permission> _guestPermissions = {
    Permission.viewPublicLadders,
    Permission.viewPublicRankings,
  };

  /// Check if a role has a specific permission
  static bool roleHasPermission(UserRole role, Permission permission) {
    final permissions = getPermissionsForRole(role);
    return permissions.contains(permission);
  }

  /// Get a human-readable description of what a role can do
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return 'The "Superuser" who manages the SaaS platform itself. Can manage global user database, configure subscription plans, and view platform-wide analytics. Cannot interfere with match results inside specific organizers\' private ladders.';
      case UserRole.organizer:
        return 'A user who "owns" a specific ladder instance. Can create/delete ladders, manage members, resolve disputes, overturn match results, and send broadcasts to their ladder members.';
      case UserRole.player:
        return 'An end-user participating in a ladder. Can manage their profile, issue challenges within the allowed rank range, report match scores, and view rankings and match history.';
      case UserRole.guest:
        return 'A non-logged-in or limited-access user. Can view public ladders and rankings but cannot challenge players or submit scores.';
    }
  }

  /// Get all available roles with their permissions (useful for documentation)
  static Map<UserRole, Set<Permission>> getAllRolePermissions() {
    return {
      UserRole.systemAdmin: _systemAdminPermissions,
      UserRole.organizer: _organizerPermissions,
      UserRole.player: _playerPermissions,
      UserRole.guest: _guestPermissions,
    };
  }

  /// Check if a set of permissions is sufficient for a role
  ///
  /// Returns true if the provided permissions include all required permissions
  /// for the given role.
  static bool hasRequiredPermissionsForRole(
    UserRole role,
    Set<Permission> userPermissions,
  ) {
    final requiredPermissions = getPermissionsForRole(role);
    return requiredPermissions.every((perm) => userPermissions.contains(perm));
  }
}
