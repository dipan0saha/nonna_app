# Role-Based Access Control (RBAC) System

## Overview

This module implements a comprehensive Role-Based Access Control (RBAC) system for the Elite Tennis Ladder application. The system supports context-specific role assignments, allowing users to have different roles in different contexts (e.g., a user can be an Organizer of "Ladder X" but a Player in "Ladder Y").

## Key Features

- **Context-Specific Roles**: Users can have different roles in different ladders
- **Organizer Autonomy**: Each ladder organizer has full control over their ladder
- **System Admin Separation**: Clear distinction between platform management and ladder management
- **Granular Permissions**: Fine-grained access control with 20+ defined permissions
- **Validation**: Built-in validation ensures role assignments are correctly configured
- **Type Safety**: Strongly-typed enums for roles and permissions

## Quick Start

### 1. Import the Required Classes

```dart
import 'package:nonna_app/models/user_role.dart';
import 'package:nonna_app/models/permission.dart';
import 'package:nonna_app/models/user_role_assignment.dart';
import 'package:nonna_app/services/rbac_service.dart';
```

### 2. Initialize the RBAC Service

```dart
final rbacService = RBACService();
```

### 3. Assign a Role

```dart
// Assign a player role in a specific ladder
final assignment = UserRoleAssignment(
  userId: 'user123',
  role: UserRole.player,
  ladderId: 'ladder456',
);

rbacService.assignRole(assignment);
```

### 4. Check Permissions

```dart
// Check if user can issue challenges
if (rbacService.hasPermission(
  userId: 'user123',
  permission: Permission.issueChallenges,
  ladderId: 'ladder456',
)) {
  // Allow the action
}
```

## Roles

### System Admin (Global)
- Manages the SaaS platform
- Cannot interfere with match results in organizers' private ladders
- Access to platform-wide analytics and settings

### Tournament Organizer (Ladder-Specific)
- Owns and manages a specific ladder
- Can create/delete ladders, manage members, resolve disputes
- Inherits all Player permissions in their ladder

### Player (Ladder-Specific)
- Participates in ladder activities
- Can issue challenges, report scores, view rankings

### Guest (Global or Ladder-Specific)
- Read-only access to public content
- Cannot participate in ladder activities

## Permissions

The system defines 20+ permissions across four categories:

1. **Platform Management** (System Admin only)
   - manage_users, manage_subscriptions, view_platform_analytics

2. **Ladder Management** (Organizer only)
   - create_ladder, configure_ladder, manage_ladder_members, modify_match_results

3. **Player Actions** (Player and Organizer)
   - issue_challenges, report_match_scores, view_match_history

4. **Guest Actions** (Guest)
   - view_public_ladders, view_public_rankings

## API Reference

### UserRole (Enum)

```dart
enum UserRole {
  systemAdmin,  // Global platform admin
  organizer,    // Ladder-specific organizer
  player,       // Ladder-specific player
  guest,        // Guest/spectator
}
```

### Permission (Enum)

```dart
enum Permission {
  manageUsers,
  createLadder,
  issueChallenges,
  // ... 20+ permissions
}
```

### UserRoleAssignment (Model)

```dart
class UserRoleAssignment {
  final String userId;
  final UserRole role;
  final String? ladderId;  // null for global roles
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  bool isValid();  // Validates the assignment
  bool get isGlobalRole;
  bool get isLadderSpecific;
}
```

### RBACService (Service)

```dart
class RBACService {
  // Permission checking
  bool hasPermission({
    required String userId,
    required Permission permission,
    String? ladderId,
  });
  
  // Role checking
  bool hasRole({
    required String userId,
    required UserRole role,
    String? ladderId,
  });
  
  // Role management
  void assignRole(UserRoleAssignment assignment);
  bool removeRole({
    required String userId,
    required Userrole,
    String? ladderId,
  });
  
  // Convenience methods
  bool isSystemAdmin(String userId);
  bool isLadderOrganizer(String userId, String ladderId);
  bool isLadderPlayer(String userId, String ladderId);
  
  // Query methods
  List<UserRoleAssignment> getUserRoleAssignments(String userId);
  Set<Permission> getUserPermissions({
    required String userId,
    String? ladderId,
  });
  List<String> getLaddersForRole(String userId, UserRole role);
}
```

## Examples

### Example 1: Multi-Ladder Participation

```dart
// User organizes one ladder
rbacService.assignRole(UserRoleAssignment(
  userId: 'user123',
  role: UserRole.organizer,
  ladderId: 'ladder_abc',
));

// Same user plays in another ladder
rbacService.assignRole(UserRoleAssignment(
  userId: 'user123',
  role: UserRole.player,
  ladderId: 'ladder_xyz',
));

// Check permissions in each context
print(rbacService.isLadderOrganizer('user123', 'ladder_abc')); // true
print(rbacService.isLadderPlayer('user123', 'ladder_xyz'));     // true
```

### Example 2: Permission-Based UI

```dart
Widget buildActionButtons(String userId, String ladderId) {
  return Row(
    children: [
      if (rbacService.hasPermission(
        userId: userId,
        permission: Permission.issueChallenges,
        ladderId: ladderId,
      ))
        ElevatedButton(
          onPressed: () => showChallengeDialog(),
          child: Text('Challenge'),
        ),
      
      if (rbacService.isLadderOrganizer(userId, ladderId))
        ElevatedButton(
          onPressed: () => showAdminPanel(),
          child: Text('Manage Ladder'),
        ),
    ],
  );
}
```

### Example 3: Backend Validation

```dart
Future<void> deleteMatch(String matchId, String userId) async {
  final match = await getMatch(matchId);
  
  // Validate permission
  if (!rbacService.hasPermission(
    userId: userId,
    permission: Permission.modifyMatchResults,
    ladderId: match.ladderId,
  )) {
    throw UnauthorizedException('Cannot modify match results');
  }
  
  await _deleteMatch(matchId);
}
```

## Testing

The module includes comprehensive unit tests:

```bash
# Run all RBAC tests
flutter test test/models/
flutter test test/services/rbac_service_test.dart

# Run specific tests
flutter test test/models/user_role_test.dart
flutter test test/models/permission_test.dart
flutter test test/models/user_role_assignment_test.dart
flutter test test/models/role_permissions_test.dart
flutter test test/services/rbac_service_test.dart
```

## Database Setup

See the [Database Schema documentation](./database_schema.md) for:
- Complete database schema with RLS policies
- Migration scripts
- Helper functions
- Security considerations

## Documentation

- **[Implementation Guide](./implementation_guide.md)**: Comprehensive guide with usage examples
- **[Database Schema](./database_schema.md)**: Database design and migration scripts
- **[Issue #1.1](../../README.md)**: Original requirements and acceptance criteria

## Design Principles

1. **Role Separation**: Clear distinction between System Admin and Tournament Organizer
2. **Organizer Autonomy**: Organizers have full control over their ladders
3. **Context-Specific**: Roles are tied to specific ladder contexts
4. **Validation**: Built-in validation prevents invalid configurations
5. **Type Safety**: Strongly-typed enums prevent errors

## Acceptance Criteria

✅ **Role Separation**: Database schema supports users holding different roles in different contexts

✅ **Organizer Autonomy**: Tournament Organizers can change their ladder's scoring logic without affecting other ladders

✅ **Admin Security**: System Admins have a specific flag that is not accessible via standard registration

✅ **Guest Access**: "Spectator/Guest" state defined for non-logged-in users with read-only access to public ladders

## Future Enhancements

- **Supabase Integration**: Connect RBACService with Supabase backend
- **Caching**: Add permission caching for performance
- **Audit Logging**: Track role assignment changes
- **Role Expiration**: Support temporary role assignments
- **Custom Permissions**: Allow organizers to define custom permissions

## Contributing

When adding new features:

1. Define new permissions in `Permission` enum if needed
2. Update `RolePermissions` to assign permissions to roles
3. Add validation in `UserRoleAssignment.isValid()` if needed
4. Add tests for new functionality
5. Update documentation

## License

This module is part of the Nonna App project and follows the same license.

## Support

For questions or issues:
1. Check the [Implementation Guide](./implementation_guide.md)
2. Review the [Database Schema](./database_schema.md)
3. Run the test suite to verify functionality
4. Check the troubleshooting section in the Implementation Guide
