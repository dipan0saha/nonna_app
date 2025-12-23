import 'package:test/test.dart';
import 'package:nonna_app/models/permission.dart';
import 'package:nonna_app/models/role_permissions.dart';
import 'package:nonna_app/models/user_role.dart';

void main() {
  group('RolePermissions', () {
    group('getPermissionsForRole', () {
      test('returns correct permissions for system admin', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRole.systemAdmin);

        expect(permissions.contains(Permission.manageUsers), isTrue);
        expect(permissions.contains(Permission.manageSubscriptions), isTrue);
        expect(permissions.contains(Permission.viewPlatformAnalytics), isTrue);
        expect(permissions.contains(Permission.managePlatformSettings), isTrue);
        expect(permissions.contains(Permission.viewLadder), isTrue);

        // System admin should NOT have permission to modify match results
        expect(permissions.contains(Permission.modifyMatchResults), isFalse);
      });

      test('returns correct permissions for organizer', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRole.organizer);

        expect(permissions.contains(Permission.createLadder), isTrue);
        expect(permissions.contains(Permission.deleteLadder), isTrue);
        expect(permissions.contains(Permission.configureLadder), isTrue);
        expect(permissions.contains(Permission.manageLadderMembers), isTrue);
        expect(permissions.contains(Permission.resolveDisputes), isTrue);
        expect(permissions.contains(Permission.modifyMatchResults), isTrue);
        expect(permissions.contains(Permission.sendBroadcasts), isTrue);

        // Organizer can also do player actions
        expect(permissions.contains(Permission.issueChallenges), isTrue);
        expect(permissions.contains(Permission.reportMatchScores), isTrue);
      });

      test('returns correct permissions for player', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRole.player);

        expect(permissions.contains(Permission.viewLadder), isTrue);
        expect(permissions.contains(Permission.issueChallenges), isTrue);
        expect(permissions.contains(Permission.reportMatchScores), isTrue);
        expect(permissions.contains(Permission.confirmMatchScores), isTrue);
        expect(permissions.contains(Permission.manageOwnProfile), isTrue);
        expect(permissions.contains(Permission.viewMatchHistory), isTrue);

        // Player should NOT have organizer permissions
        expect(permissions.contains(Permission.createLadder), isFalse);
        expect(permissions.contains(Permission.modifyMatchResults), isFalse);
      });

      test('returns correct permissions for guest', () {
        final permissions = RolePermissions.getPermissionsForRole(UserRole.guest);

        expect(permissions.contains(Permission.viewPublicLadders), isTrue);
        expect(permissions.contains(Permission.viewPublicRankings), isTrue);

        // Guest should NOT have any write permissions
        expect(permissions.contains(Permission.issueChallenges), isFalse);
        expect(permissions.contains(Permission.reportMatchScores), isFalse);
        expect(permissions.contains(Permission.createLadder), isFalse);
      });
    });

    group('roleHasPermission', () {
      test('returns true when role has permission', () {
        expect(
          RolePermissions.roleHasPermission(
            UserRole.systemAdmin,
            Permission.manageUsers,
          ),
          isTrue,
        );
        expect(
          RolePermissions.roleHasPermission(
            UserRole.organizer,
            Permission.createLadder,
          ),
          isTrue,
        );
        expect(
          RolePermissions.roleHasPermission(
            UserRole.player,
            Permission.issueChallenges,
          ),
          isTrue,
        );
      });

      test('returns false when role does not have permission', () {
        expect(
          RolePermissions.roleHasPermission(
            UserRole.guest,
            Permission.issueChallenges,
          ),
          isFalse,
        );
        expect(
          RolePermissions.roleHasPermission(
            UserRole.player,
            Permission.createLadder,
          ),
          isFalse,
        );
        expect(
          RolePermissions.roleHasPermission(
            UserRole.systemAdmin,
            Permission.modifyMatchResults,
          ),
          isFalse,
        );
      });
    });

    group('getRoleDescription', () {
      test('returns non-empty description for all roles', () {
        for (final role in UserRole.values) {
          final description = RolePermissions.getRoleDescription(role);
          expect(description.isNotEmpty, isTrue);
          expect(description.length, greaterThan(50));
        }
      });

      test('system admin description mentions platform management', () {
        final description = RolePermissions.getRoleDescription(UserRole.systemAdmin);
        expect(description.toLowerCase(), contains('platform'));
        expect(description.toLowerCase(), contains('cannot interfere'));
      });

      test('organizer description mentions ladder ownership', () {
        final description = RolePermissions.getRoleDescription(UserRole.organizer);
        expect(description.toLowerCase(), contains('ladder'));
        expect(description.toLowerCase(), contains('owns'));
      });
    });

    group('getAllRolePermissions', () {
      test('returns permissions for all roles', () {
        final allPermissions = RolePermissions.getAllRolePermissions();

        expect(allPermissions.length, equals(4));
        expect(allPermissions.containsKey(UserRole.systemAdmin), isTrue);
        expect(allPermissions.containsKey(UserRole.organizer), isTrue);
        expect(allPermissions.containsKey(UserRole.player), isTrue);
        expect(allPermissions.containsKey(UserRole.guest), isTrue);
      });

      test('each role has at least one permission', () {
        final allPermissions = RolePermissions.getAllRolePermissions();

        for (final entry in allPermissions.entries) {
          expect(entry.value.isNotEmpty, isTrue);
        }
      });
    });

    group('hasRequiredPermissionsForRole', () {
      test('returns true when user has all required permissions', () {
        final userPermissions = RolePermissions.getPermissionsForRole(UserRole.player);
        expect(
          RolePermissions.hasRequiredPermissionsForRole(
            UserRole.player,
            userPermissions,
          ),
          isTrue,
        );
      });

      test('returns true when user has more than required permissions', () {
        final organizerPermissions = RolePermissions.getPermissionsForRole(UserRole.organizer);
        // Organizer includes all player permissions
        expect(
          RolePermissions.hasRequiredPermissionsForRole(
            UserRole.player,
            organizerPermissions,
          ),
          isTrue,
        );
      });

      test('returns false when user lacks required permissions', () {
        final guestPermissions = RolePermissions.getPermissionsForRole(UserRole.guest);
        expect(
          RolePermissions.hasRequiredPermissionsForRole(
            UserRole.player,
            guestPermissions,
          ),
          isFalse,
        );
      });

      test('returns false when user has some but not all required permissions', () {
        final partialPermissions = {
          Permission.viewLadder,
          Permission.viewMatchHistory,
        };
        expect(
          RolePermissions.hasRequiredPermissionsForRole(
            UserRole.player,
            partialPermissions,
          ),
          isFalse,
        );
      });
    });

    group('permission hierarchy', () {
      test('organizer has all player permissions', () {
        final organizerPerms = RolePermissions.getPermissionsForRole(UserRole.organizer);
        final playerPerms = RolePermissions.getPermissionsForRole(UserRole.player);

        for (final perm in playerPerms) {
          expect(
            organizerPerms.contains(perm),
            isTrue,
            reason: 'Organizer should have permission: ${perm.value}',
          );
        }
      });

      test('system admin does not have organizer-specific permissions', () {
        final adminPerms = RolePermissions.getPermissionsForRole(UserRole.systemAdmin);

        // System admin should not be able to modify match results or manage ladder members
        expect(adminPerms.contains(Permission.modifyMatchResults), isFalse);
        expect(adminPerms.contains(Permission.manageLadderMembers), isFalse);
        expect(adminPerms.contains(Permission.resolveDisputes), isFalse);
      });

      test('guest has minimal permissions', () {
        final guestPerms = RolePermissions.getPermissionsForRole(UserRole.guest);

        // Guest should only have read-only permissions
        expect(guestPerms.length, lessThanOrEqualTo(3));
        for (final perm in guestPerms) {
          expect(perm.value.contains('view') || perm.value.contains('public'), isTrue);
        }
      });
    });
  });
}
