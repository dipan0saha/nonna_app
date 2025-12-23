import '../models/permission.dart';
import '../models/role_permissions.dart';
import '../models/user_role.dart';
import '../models/user_role_assignment.dart';

/// Service for Role-Based Access Control (RBAC) operations.
///
/// This service provides methods to check permissions, manage role assignments,
/// and enforce access control policies throughout the application.
class RBACService {
  /// Storage for user role assignments
  /// In a real implementation, this would query from Supabase
  final Map<String, List<UserRoleAssignment>> _userRoleAssignments = {};

  /// Check if a user has a specific permission in a given context
  ///
  /// [userId] - The ID of the user to check
  /// [permission] - The permission to check for
  /// [ladderId] - Optional ladder context (required for ladder-specific permissions)
  ///
  /// Returns true if the user has the permission in the given context.
  bool hasPermission({
    required String userId,
    required Permission permission,
    String? ladderId,
  }) {
    final assignments = _userRoleAssignments[userId] ?? [];

    // Check global roles first (System Admin)
    for (final assignment in assignments) {
      if (assignment.isGlobalRole &&
          RolePermissions.roleHasPermission(assignment.role, permission)) {
        return true;
      }
    }

    // If a ladder context is provided, check ladder-specific roles
    if (ladderId != null) {
      for (final assignment in assignments) {
        if (assignment.ladderId == ladderId &&
            RolePermissions.roleHasPermission(assignment.role, permission)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if a user has a specific role in a given context
  ///
  /// [userId] - The ID of the user to check
  /// [role] - The role to check for
  /// [ladderId] - Optional ladder context (required for ladder-specific roles)
  ///
  /// Returns true if the user has the role in the given context.
  bool hasRole({
    required String userId,
    required UserRole role,
    String? ladderId,
  }) {
    final assignments = _userRoleAssignments[userId] ?? [];

    for (final assignment in assignments) {
      if (assignment.role == role) {
        // For global roles, ignore ladder context
        if (assignment.isGlobalRole) {
          return true;
        }
        // For ladder-specific roles, match the ladder ID
        if (ladderId != null && assignment.ladderId == ladderId) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get all role assignments for a user
  ///
  /// Returns a list of all role assignments for the specified user.
  List<UserRoleAssignment> getUserRoleAssignments(String userId) {
    return List.unmodifiable(_userRoleAssignments[userId] ?? []);
  }

  /// Get all permissions for a user in a specific context
  ///
  /// [userId] - The ID of the user
  /// [ladderId] - Optional ladder context
  ///
  /// Returns a set of all permissions the user has in the given context.
  Set<Permission> getUserPermissions({
    required String userId,
    String? ladderId,
  }) {
    final assignments = _userRoleAssignments[userId] ?? [];
    final permissions = <Permission>{};

    for (final assignment in assignments) {
      // Add permissions from global roles
      if (assignment.isGlobalRole) {
        permissions.addAll(RolePermissions.getPermissionsForRole(assignment.role));
      }
      // Add permissions from ladder-specific roles if context matches
      else if (ladderId != null && assignment.ladderId == ladderId) {
        permissions.addAll(RolePermissions.getPermissionsForRole(assignment.role));
      }
    }

    return permissions;
  }

  /// Assign a role to a user
  ///
  /// [assignment] - The role assignment to add
  ///
  /// Throws [ArgumentError] if the assignment is invalid.
  void assignRole(UserRoleAssignment assignment) {
    if (!assignment.isValid()) {
      throw ArgumentError('Invalid role assignment: ${assignment.toString()}');
    }

    final assignments = _userRoleAssignments[assignment.userId] ?? [];

    // Check if this exact role assignment already exists
    final exists = assignments.any((a) =>
        a.role == assignment.role && a.ladderId == assignment.ladderId);

    if (!exists) {
      assignments.add(assignment);
      _userRoleAssignments[assignment.userId] = assignments;
    }
  }

  /// Remove a role assignment from a user
  ///
  /// [userId] - The ID of the user
  /// [role] - The role to remove
  /// [ladderId] - Optional ladder context
  ///
  /// Returns true if a role was removed, false otherwise.
  bool removeRole({
    required String userId,
    required UserRole role,
    String? ladderId,
  }) {
    final assignments = _userRoleAssignments[userId];
    if (assignments == null) return false;

    final initialLength = assignments.length;
    assignments.removeWhere((a) =>
        a.role == role &&
        ((ladderId == null && a.ladderId == null) ||
            (ladderId != null && a.ladderId == ladderId)));

    _userRoleAssignments[userId] = assignments;
    return assignments.length < initialLength;
  }

  /// Check if a user is a System Admin
  bool isSystemAdmin(String userId) {
    return hasRole(userId: userId, role: UserRole.systemAdmin);
  }

  /// Check if a user is an Organizer of a specific ladder
  bool isLadderOrganizer(String userId, String ladderId) {
    return hasRole(userId: userId, role: UserRole.organizer, ladderId: ladderId);
  }

  /// Check if a user is a Player in a specific ladder
  bool isLadderPlayer(String userId, String ladderId) {
    return hasRole(userId: userId, role: UserRole.player, ladderId: ladderId);
  }

  /// Get all ladders where a user has a specific role
  ///
  /// Returns a list of ladder IDs.
  List<String> getLaddersForRole(String userId, UserRole role) {
    final assignments = _userRoleAssignments[userId] ?? [];
    return assignments
        .where((a) => a.role == role && a.ladderId != null)
        .map((a) => a.ladderId!)
        .toList();
  }

  /// Clear all role assignments (useful for testing)
  void clearAllAssignments() {
    _userRoleAssignments.clear();
  }

  /// Load role assignments from a data source
  ///
  /// In a real implementation, this would query from Supabase
  void loadRoleAssignments(List<UserRoleAssignment> assignments) {
    _userRoleAssignments.clear();
    for (final assignment in assignments) {
      if (assignment.isValid()) {
        final userAssignments = _userRoleAssignments[assignment.userId] ?? [];
        userAssignments.add(assignment);
        _userRoleAssignments[assignment.userId] = userAssignments;
      }
    }
  }
}
