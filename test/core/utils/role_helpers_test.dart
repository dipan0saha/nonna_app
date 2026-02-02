import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/utils/role_helpers.dart';

void main() {
  group('RoleHelpers', () {
    group('role checking', () {
      test('isOwner returns correct value', () {
        expect(RoleHelpers.isOwner(UserRole.owner), true);
        expect(RoleHelpers.isOwner(UserRole.follower), false);
      });

      test('isFollower returns correct value', () {
        expect(RoleHelpers.isFollower(UserRole.follower), true);
        expect(RoleHelpers.isFollower(UserRole.owner), false);
      });

      test('hasRole checks specific role', () {
        expect(RoleHelpers.hasRole(UserRole.owner, UserRole.owner), true);
        expect(RoleHelpers.hasRole(UserRole.owner, UserRole.follower), false);
      });

      test('hasAnyRole checks multiple roles', () {
        expect(
            RoleHelpers.hasAnyRole(
                UserRole.owner, [UserRole.owner, UserRole.follower]),
            true);
        expect(
            RoleHelpers.hasAnyRole(UserRole.owner, [UserRole.follower]), false);
      });
    });

    group('permissions', () {
      test('canEdit checks ownership', () {
        expect(RoleHelpers.canEdit(UserRole.owner, 'user1', 'user1'), true);
        expect(RoleHelpers.canEdit(UserRole.owner, 'user1', 'user2'), false);
        expect(RoleHelpers.canEdit(UserRole.follower, 'user1', 'user1'), false);
      });

      test('canDelete checks ownership', () {
        expect(RoleHelpers.canDelete(UserRole.owner, 'user1', 'user1'), true);
        expect(RoleHelpers.canDelete(UserRole.owner, 'user1', 'user2'), false);
        expect(
            RoleHelpers.canDelete(UserRole.follower, 'user1', 'user1'), false);
      });

      test('canCreate allows all users', () {
        expect(RoleHelpers.canCreate(UserRole.owner), true);
        expect(RoleHelpers.canCreate(UserRole.follower), true);
      });

      test('canInvite allows only owners', () {
        expect(RoleHelpers.canInvite(UserRole.owner), true);
        expect(RoleHelpers.canInvite(UserRole.follower), false);
      });

      test('canManageProfile checks ownership', () {
        expect(RoleHelpers.canManageProfile(UserRole.owner, 'user1', 'user1'),
            true);
        expect(RoleHelpers.canManageProfile(UserRole.owner, 'user1', 'user2'),
            false);
        expect(
            RoleHelpers.canManageProfile(UserRole.follower, 'user1', 'user1'),
            false);
      });

      test('canManageEvents allows only owners', () {
        expect(RoleHelpers.canManageEvents(UserRole.owner), true);
        expect(RoleHelpers.canManageEvents(UserRole.follower), false);
      });

      test('canUploadPhotos allows all users', () {
        expect(RoleHelpers.canUploadPhotos(UserRole.owner), true);
        expect(RoleHelpers.canUploadPhotos(UserRole.follower), true);
      });
    });

    group('dual roles', () {
      test('hasDualRoles checks for both roles', () {
        expect(RoleHelpers.hasDualRoles([UserRole.owner, UserRole.follower]),
            true);
        expect(RoleHelpers.hasDualRoles([UserRole.owner]), false);
        expect(RoleHelpers.hasDualRoles([UserRole.follower]), false);
      });

      test('getPrimaryRole returns owner if present', () {
        expect(RoleHelpers.getPrimaryRole([UserRole.owner, UserRole.follower]),
            UserRole.owner);
        expect(
            RoleHelpers.getPrimaryRole([UserRole.follower]), UserRole.follower);
      });
    });

    group('features', () {
      test('getAvailableFeatures returns features for role', () {
        final ownerFeatures = RoleHelpers.getAvailableFeatures(UserRole.owner);
        final followerFeatures =
            RoleHelpers.getAvailableFeatures(UserRole.follower);

        expect(ownerFeatures.length, greaterThan(followerFeatures.length));
        expect(ownerFeatures.contains('invite_users'), true);
        expect(followerFeatures.contains('invite_users'), false);
      });

      test('hasFeature checks feature availability', () {
        expect(RoleHelpers.hasFeature(UserRole.owner, 'invite_users'), true);
        expect(
            RoleHelpers.hasFeature(UserRole.follower, 'invite_users'), false);
        expect(RoleHelpers.hasFeature(UserRole.follower, 'view_content'), true);
      });
    });

    group('home screen configuration', () {
      test('returns correct config for owner', () {
        final config = RoleHelpers.getHomeScreenConfig(UserRole.owner);
        expect(config['showManagementOptions'], true);
        expect(config['showInviteButton'], true);
      });

      test('returns correct config for follower', () {
        final config = RoleHelpers.getHomeScreenConfig(UserRole.follower);
        expect(config['showManagementOptions'], false);
        expect(config['showInviteButton'], false);
      });
    });

    group('accessible screens', () {
      test('owner has more accessible screens', () {
        final ownerScreens = RoleHelpers.getAccessibleScreens(UserRole.owner);
        final followerScreens =
            RoleHelpers.getAccessibleScreens(UserRole.follower);

        expect(ownerScreens.length, greaterThan(followerScreens.length));
      });

      test('canAccessScreen checks screen accessibility', () {
        expect(RoleHelpers.canAccessScreen(UserRole.owner, 'profile_settings'),
            true);
        expect(
            RoleHelpers.canAccessScreen(UserRole.follower, 'profile_settings'),
            false);
      });
    });

    group('validation', () {
      test('validateRoleForAction checks role permissions', () {
        expect(
            RoleHelpers.validateRoleForAction(UserRole.owner, 'invite'), true);
        expect(RoleHelpers.validateRoleForAction(UserRole.follower, 'invite'),
            false);
      });

      test('getUnauthorizedMessage returns error message', () {
        final message =
            RoleHelpers.getUnauthorizedMessage(UserRole.follower, 'invite');
        expect(message.contains('Follower'), true);
        expect(message.contains('invite'), true);
      });
    });
  });
}
