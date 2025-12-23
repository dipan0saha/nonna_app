import 'package:test/test.dart';
import 'package:nonna_app/models/permission.dart';
import 'package:nonna_app/models/user_role.dart';
import 'package:nonna_app/models/user_role_assignment.dart';
import 'package:nonna_app/services/rbac_service.dart';

void main() {
  late RBACService rbacService;

  setUp(() {
    rbacService = RBACService();
  });

  tearDown(() {
    rbacService.clearAllAssignments();
  });

  group('RBACService', () {
    group('assignRole', () {
      test('assigns a valid role to a user', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasRole(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder456',
          ),
          isTrue,
        );
      });

      test('throws error for invalid role assignment', () {
        // System admin with ladder_id is invalid
        final invalidAssignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
          ladderId: 'ladder456',
        );

        expect(
          () => rbacService.assignRole(invalidAssignment),
          throwsArgumentError,
        );
      });

      test('does not duplicate existing role assignments', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);
        rbacService.assignRole(assignment);

        final assignments = rbacService.getUserRoleAssignments('user123');
        expect(assignments.length, equals(1));
      });

      test('allows same role in different ladders', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final assignment2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder789',
        );

        rbacService.assignRole(assignment1);
        rbacService.assignRole(assignment2);

        final assignments = rbacService.getUserRoleAssignments('user123');
        expect(assignments.length, equals(2));
      });
    });

    group('removeRole', () {
      test('removes a role assignment', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);
        final removed = rbacService.removeRole(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        expect(removed, isTrue);
        expect(
          rbacService.hasRole(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder456',
          ),
          isFalse,
        );
      });

      test('returns false when role does not exist', () {
        final removed = rbacService.removeRole(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        expect(removed, isFalse);
      });

      test('removes only the specified role assignment', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final assignment2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder789',
        );

        rbacService.assignRole(assignment1);
        rbacService.assignRole(assignment2);

        rbacService.removeRole(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        expect(
          rbacService.hasRole(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder789',
          ),
          isTrue,
        );
      });
    });

    group('hasPermission', () {
      test('returns true for permission granted by global role', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.manageUsers,
          ),
          isTrue,
        );
      });

      test('returns true for permission granted by ladder-specific role', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.issueChallenges,
            ladderId: 'ladder456',
          ),
          isTrue,
        );
      });

      test('returns false when user lacks permission', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.guest,
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.issueChallenges,
          ),
          isFalse,
        );
      });

      test('returns false when ladder context does not match', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.issueChallenges,
            ladderId: 'ladder789', // Different ladder
          ),
          isFalse,
        );
      });
    });

    group('hasRole', () {
      test('returns true for global role', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasRole(userId: 'user123', role: UserRole.systemAdmin),
          isTrue,
        );
      });

      test('returns true for ladder-specific role with matching context', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasRole(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder456',
          ),
          isTrue,
        );
      });

      test('returns false for ladder-specific role without context', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasRole(
            userId: 'user123',
            role: UserRole.player,
          ),
          isFalse,
        );
      });
    });

    group('getUserRoleAssignments', () {
      test('returns all assignments for a user', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final assignment2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder789',
        );

        rbacService.assignRole(assignment1);
        rbacService.assignRole(assignment2);

        final assignments = rbacService.getUserRoleAssignments('user123');
        expect(assignments.length, equals(2));
      });

      test('returns empty list for user with no assignments', () {
        final assignments = rbacService.getUserRoleAssignments('user123');
        expect(assignments, isEmpty);
      });

      test('returns unmodifiable list', () {
        final assignments = rbacService.getUserRoleAssignments('user123');
        expect(() => assignments.add(UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        )), throwsUnsupportedError);
      });
    });

    group('getUserPermissions', () {
      test('returns all permissions from global roles', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        rbacService.assignRole(assignment);

        final permissions = rbacService.getUserPermissions(userId: 'user123');
        expect(permissions.contains(Permission.manageUsers), isTrue);
        expect(permissions.contains(Permission.viewPlatformAnalytics), isTrue);
      });

      test('returns permissions from ladder-specific roles with context', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        final permissions = rbacService.getUserPermissions(
          userId: 'user123',
          ladderId: 'ladder456',
        );
        expect(permissions.contains(Permission.issueChallenges), isTrue);
      });

      test('combines permissions from multiple roles', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );
        final assignment2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment1);
        rbacService.assignRole(assignment2);

        final permissions = rbacService.getUserPermissions(
          userId: 'user123',
          ladderId: 'ladder456',
        );
        expect(permissions.contains(Permission.manageUsers), isTrue);
        expect(permissions.contains(Permission.issueChallenges), isTrue);
      });
    });

    group('convenience methods', () {
      test('isSystemAdmin returns correct value', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.systemAdmin,
        );

        rbacService.assignRole(assignment);

        expect(rbacService.isSystemAdmin('user123'), isTrue);
        expect(rbacService.isSystemAdmin('user456'), isFalse);
      });

      test('isLadderOrganizer returns correct value', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(rbacService.isLadderOrganizer('user123', 'ladder456'), isTrue);
        expect(rbacService.isLadderOrganizer('user123', 'ladder789'), isFalse);
      });

      test('isLadderPlayer returns correct value', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        expect(rbacService.isLadderPlayer('user123', 'ladder456'), isTrue);
        expect(rbacService.isLadderPlayer('user123', 'ladder789'), isFalse);
      });
    });

    group('getLaddersForRole', () {
      test('returns all ladders where user has specified role', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );
        final assignment2 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder789',
        );
        final assignment3 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder999',
        );

        rbacService.assignRole(assignment1);
        rbacService.assignRole(assignment2);
        rbacService.assignRole(assignment3);

        final playerLadders = rbacService.getLaddersForRole('user123', UserRole.player);
        expect(playerLadders.length, equals(2));
        expect(playerLadders.contains('ladder456'), isTrue);
        expect(playerLadders.contains('ladder789'), isTrue);
        expect(playerLadders.contains('ladder999'), isFalse);
      });

      test('returns empty list when user has no roles', () {
        final ladders = rbacService.getLaddersForRole('user123', UserRole.player);
        expect(ladders, isEmpty);
      });
    });

    group('loadRoleAssignments', () {
      test('loads multiple assignments at once', () {
        final assignments = [
          UserRoleAssignment(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder456',
          ),
          UserRoleAssignment(
            userId: 'user456',
            role: UserRole.organizer,
            ladderId: 'ladder789',
          ),
        ];

        rbacService.loadRoleAssignments(assignments);

        expect(rbacService.getUserRoleAssignments('user123').length, equals(1));
        expect(rbacService.getUserRoleAssignments('user456').length, equals(1));
      });

      test('clears existing assignments before loading', () {
        final assignment1 = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment1);

        final newAssignments = [
          UserRoleAssignment(
            userId: 'user456',
            role: UserRole.organizer,
            ladderId: 'ladder789',
          ),
        ];

        rbacService.loadRoleAssignments(newAssignments);

        expect(rbacService.getUserRoleAssignments('user123'), isEmpty);
        expect(rbacService.getUserRoleAssignments('user456').length, equals(1));
      });

      test('skips invalid assignments', () {
        final assignments = [
          UserRoleAssignment(
            userId: 'user123',
            role: UserRole.player,
            ladderId: 'ladder456',
          ),
          UserRoleAssignment(
            userId: 'user456',
            role: UserRole.systemAdmin,
            ladderId: 'ladder789', // Invalid - system admin with ladder
          ),
        ];

        rbacService.loadRoleAssignments(assignments);

        expect(rbacService.getUserRoleAssignments('user123').length, equals(1));
        expect(rbacService.getUserRoleAssignments('user456'), isEmpty);
      });
    });

    group('complex scenarios', () {
      test('user can have different roles in different ladders', () {
        final organizerAssignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder456',
        );
        final playerAssignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.player,
          ladderId: 'ladder789',
        );

        rbacService.assignRole(organizerAssignment);
        rbacService.assignRole(playerAssignment);

        expect(rbacService.isLadderOrganizer('user123', 'ladder456'), isTrue);
        expect(rbacService.isLadderPlayer('user123', 'ladder789'), isTrue);
        expect(rbacService.isLadderOrganizer('user123', 'ladder789'), isFalse);
        expect(rbacService.isLadderPlayer('user123', 'ladder456'), isFalse);
      });

      test('system admin cannot interfere with match results', () {
        final assignment = UserRoleAssignment(
          userId: 'admin123',
          role: UserRole.systemAdmin,
        );

        rbacService.assignRole(assignment);

        expect(
          rbacService.hasPermission(
            userId: 'admin123',
            permission: Permission.modifyMatchResults,
            ladderId: 'ladder456',
          ),
          isFalse,
        );
      });

      test('organizer can do everything a player can in their ladder', () {
        final assignment = UserRoleAssignment(
          userId: 'user123',
          role: UserRole.organizer,
          ladderId: 'ladder456',
        );

        rbacService.assignRole(assignment);

        // Organizer permissions
        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.manageLadderMembers,
            ladderId: 'ladder456',
          ),
          isTrue,
        );

        // Player permissions
        expect(
          rbacService.hasPermission(
            userId: 'user123',
            permission: Permission.issueChallenges,
            ladderId: 'ladder456',
          ),
          isTrue,
        );
      });
    });
  });
}
