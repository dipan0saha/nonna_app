import 'package:nonna_app/core/enums/user_role.dart';

/// Role checking and permission utilities
///
/// **Functional Requirements**: Section 3.3.5 - Role & Permission Helpers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides helper functions for role-based access control and permission checking:
/// - Role checking (isOwner, isFollower, hasRole, hasAnyRole)
/// - Permission calculations (canEdit, canDelete, canCreate, canView, canInvite)
/// - Feature permissions (canManageProfile, canManageEvents, canManageRegistry)
/// - Dual-role handling (hasDualRoles, getPrimaryRole)
/// - Role-specific UI helpers (getAvailableFeatures, hasFeature)
/// - Navigation helpers (getHomeScreenConfig, canAccessScreen)
/// - Validation helpers (validateRoleForAction, getUnauthorizedMessage)
///
/// Dependencies: None
class RoleHelpers {
  // Prevent instantiation
  RoleHelpers._();

  // ============================================================
  // Role Checking
  // ============================================================

  /// Check if user has owner role
  static bool isOwner(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user has follower role
  static bool isFollower(UserRole role) {
    return role == UserRole.follower;
  }

  /// Check if user has specific role
  static bool hasRole(UserRole userRole, UserRole requiredRole) {
    return userRole == requiredRole;
  }

  /// Check if user has any of the specified roles
  static bool hasAnyRole(UserRole userRole, List<UserRole> roles) {
    return roles.contains(userRole);
  }

  // ============================================================
  // Permission Calculations
  // ============================================================

  /// Check if user can edit content
  static bool canEdit(UserRole role, String? contentOwnerId, String? userId) {
    // Owners can edit their own content
    if (isOwner(role) && contentOwnerId == userId) {
      return true;
    }
    return false;
  }

  /// Check if user can delete content
  static bool canDelete(UserRole role, String? contentOwnerId, String? userId) {
    // Owners can delete their own content
    if (isOwner(role) && contentOwnerId == userId) {
      return true;
    }
    return false;
  }

  /// Check if user can create content
  static bool canCreate(UserRole role) {
    // Both owners and followers can create content
    // (though they might create different types)
    return true;
  }

  /// Check if user can view content
  static bool canView(UserRole role) {
    // All users can view content
    return true;
  }

  /// Check if user can comment
  static bool canComment(UserRole role) {
    // All users can comment
    return true;
  }

  /// Check if user can like/react
  static bool canReact(UserRole role) {
    // All users can react
    return true;
  }

  /// Check if user can invite others
  static bool canInvite(UserRole role) {
    // Only owners can invite
    return isOwner(role);
  }

  /// Check if user can manage baby profile
  static bool canManageProfile(
      UserRole role, String? profileOwnerId, String? userId) {
    // Only the owner of the profile can manage it
    return isOwner(role) && profileOwnerId == userId;
  }

  /// Check if user can manage events
  static bool canManageEvents(UserRole role) {
    // Only owners can fully manage events
    return isOwner(role);
  }

  /// Check if user can manage registry
  static bool canManageRegistry(UserRole role) {
    // Only owners can fully manage registry
    return isOwner(role);
  }

  /// Check if user can manage gallery
  static bool canManageGallery(UserRole role) {
    // Both can add photos, but only owners can manage settings
    return isOwner(role);
  }

  /// Check if user can upload photos
  static bool canUploadPhotos(UserRole role) {
    // All users can upload photos
    return true;
  }

  /// Check if user can RSVP to events
  static bool canRsvp(UserRole role) {
    // All users can RSVP
    return true;
  }

  /// Check if user can purchase registry items
  static bool canPurchaseRegistryItems(UserRole role) {
    // All users can purchase
    return true;
  }

  /// Check if user can suggest names
  static bool canSuggestNames(UserRole role) {
    // All users can suggest names
    return true;
  }

  /// Check if user can vote
  static bool canVote(UserRole role) {
    // All users can vote
    return true;
  }

  // ============================================================
  // Dual-Role Handling
  // ============================================================

  /// Check if user has dual roles (owner of one profile, follower of another)
  static bool hasDualRoles(List<UserRole> roles) {
    return roles.contains(UserRole.owner) && roles.contains(UserRole.follower);
  }

  /// Get primary role (when user has multiple roles)
  static UserRole getPrimaryRole(List<UserRole> roles) {
    // Owner takes precedence
    if (roles.contains(UserRole.owner)) {
      return UserRole.owner;
    }
    return UserRole.follower;
  }

  // ============================================================
  // Role-Specific UI Helpers
  // ============================================================

  /// Get UI features available for role
  static List<String> getAvailableFeatures(UserRole role) {
    if (isOwner(role)) {
      return [
        'view_content',
        'create_content',
        'edit_content',
        'delete_content',
        'invite_users',
        'manage_profile',
        'manage_events',
        'manage_registry',
        'manage_gallery',
        'upload_photos',
        'comment',
        'react',
        'rsvp',
        'vote',
        'suggest_names',
      ];
    } else {
      return [
        'view_content',
        'upload_photos',
        'comment',
        'react',
        'rsvp',
        'purchase_items',
        'vote',
        'suggest_names',
      ];
    }
  }

  /// Check if feature is available for role
  static bool hasFeature(UserRole role, String feature) {
    return getAvailableFeatures(role).contains(feature);
  }

  /// Get role display name
  static String getRoleDisplayName(UserRole role) {
    return role.displayName;
  }

  /// Get role description
  static String getRoleDescription(UserRole role) {
    return role.description;
  }

  // ============================================================
  // Navigation Helpers
  // ============================================================

  /// Get home screen configuration for role
  static Map<String, dynamic> getHomeScreenConfig(UserRole role) {
    if (isOwner(role)) {
      return {
        'showManagementOptions': true,
        'showInviteButton': true,
        'showProfileSettings': true,
        'defaultTiles': [
          'upcoming_events',
          'recent_photos',
          'registry_highlights',
          'invites_status',
        ],
      };
    } else {
      return {
        'showManagementOptions': false,
        'showInviteButton': false,
        'showProfileSettings': false,
        'defaultTiles': [
          'upcoming_events',
          'recent_photos',
          'notifications',
          'gallery_favorites',
        ],
      };
    }
  }

  /// Get accessible screens for role
  static List<String> getAccessibleScreens(UserRole role) {
    final commonScreens = [
      'home',
      'calendar',
      'gallery',
      'registry',
      'fun',
      'notifications',
    ];

    if (isOwner(role)) {
      return [
        ...commonScreens,
        'profile_settings',
        'baby_profile_management',
        'invite_management',
      ];
    } else {
      return commonScreens;
    }
  }

  /// Check if screen is accessible for role
  static bool canAccessScreen(UserRole role, String screenName) {
    return getAccessibleScreens(role).contains(screenName);
  }

  // ============================================================
  // Validation Helpers
  // ============================================================

  /// Validate role for action
  static bool validateRoleForAction(UserRole role, String action) {
    final ownerActions = [
      'invite',
      'manage_profile',
      'delete_baby_profile',
      'edit_settings',
    ];

    if (ownerActions.contains(action)) {
      return isOwner(role);
    }

    return true; // Default allow for other actions
  }

  /// Get error message for unauthorized action
  static String getUnauthorizedMessage(UserRole role, String action) {
    return 'As a ${role.displayName}, you do not have permission to $action.';
  }
}
