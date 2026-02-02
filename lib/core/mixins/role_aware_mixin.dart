import 'package:flutter/material.dart';
import 'package:nonna_app/core/enums/user_role.dart';

/// Role-aware mixin for widgets
///
/// Provides role-based behavior and rendering helpers for widgets.
mixin RoleAwareMixin<T extends StatefulWidget> on State<T> {
  // Override this in the widget to provide the current user's role
  UserRole get currentRole;

  // Override this to provide the current user's ID
  String? get currentUserId => null;

  // ============================================================
  // Role Checks
  // ============================================================

  /// Check if current user is owner
  bool get isOwner => currentRole == UserRole.owner;

  /// Check if current user is follower
  bool get isFollower => currentRole == UserRole.follower;

  /// Check if current user has specific role
  bool hasRole(UserRole role) {
    return currentRole == role;
  }

  // ============================================================
  // Permission Checks
  // ============================================================

  /// Check if current user can edit content
  bool canEdit(String? contentOwnerId) {
    return isOwner && contentOwnerId == currentUserId;
  }

  /// Check if current user can delete content
  bool canDelete(String? contentOwnerId) {
    return isOwner && contentOwnerId == currentUserId;
  }

  /// Check if current user can create content
  bool get canCreate => true;

  /// Check if current user can invite others
  bool get canInvite => isOwner;

  /// Check if current user can manage settings
  bool get canManageSettings => isOwner;

  // ============================================================
  // Conditional Rendering
  // ============================================================

  /// Show widget only to owners
  Widget ownerOnly(Widget child) {
    return isOwner ? child : const SizedBox.shrink();
  }

  /// Show widget only to followers
  Widget followerOnly(Widget child) {
    return isFollower ? child : const SizedBox.shrink();
  }

  /// Show different widgets based on role
  Widget roleBasedWidget({
    required Widget ownerWidget,
    required Widget followerWidget,
  }) {
    return isOwner ? ownerWidget : followerWidget;
  }

  /// Show widget conditionally based on permission
  Widget showIf(bool condition, Widget child) {
    return condition ? child : const SizedBox.shrink();
  }

  // ============================================================
  // Role-Based Styling
  // ============================================================

  /// Get role-specific color
  Color getRoleColor(BuildContext context) {
    if (isOwner) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  /// Get role-specific icon
  IconData getRoleIcon() {
    return currentRole.icon;
  }

  // ============================================================
  // Navigation Helpers
  // ============================================================

  /// Check if screen is accessible
  bool canAccessScreen(String screenName) {
    // Implement based on role permissions
    final ownerOnlyScreens = [
      'profile_settings',
      'baby_profile_management',
      'invite_management',
    ];

    if (ownerOnlyScreens.contains(screenName)) {
      return isOwner;
    }

    return true;
  }

  /// Navigate if allowed
  Future<T?> navigateIfAllowed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (canAccessScreen(routeName)) {
      return Navigator.of(context)
          .pushNamed<T>(routeName, arguments: arguments);
    } else {
      // Show unauthorized message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to access this screen.'),
        ),
      );
      return null;
    }
  }

  // ============================================================
  // Action Helpers
  // ============================================================

  /// Execute action if allowed
  void executeIfAllowed(
    VoidCallback action, {
    VoidCallback? onUnauthorized,
  }) {
    if (canCreate) {
      action();
    } else {
      if (onUnauthorized != null) {
        onUnauthorized();
      } else {
        // Show default unauthorized message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('You do not have permission to perform this action.'),
            ),
          );
        }
      }
    }
  }

  /// Execute action with role check
  void executeWithRoleCheck(
    VoidCallback action, {
    required UserRole requiredRole,
    VoidCallback? onUnauthorized,
  }) {
    if (hasRole(requiredRole)) {
      action();
    } else {
      if (onUnauthorized != null) {
        onUnauthorized();
      }
    }
  }
}
