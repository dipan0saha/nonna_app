# Role-Based Access Control (RBAC) Implementation Guide

## Overview

This guide provides comprehensive documentation for implementing and using the Elite Tennis Ladder Role-Based Access Control (RBAC) system. The system enables context-specific role assignments where users can have different roles in different contexts (e.g., a user can be an Organizer of "Ladder X" but a Player in "Ladder Y").

## Table of Contents

1. [Role Definitions](#role-definitions)
2. [Permission Model](#permission-model)
3. [Architecture](#architecture)
4. [Usage Examples](#usage-examples)
5. [Database Setup](#database-setup)
6. [Best Practices](#best-practices)
7. [Security Considerations](#security-considerations)

## Role Definitions

### System Admin

**Scope**: Global (platform-wide)

**Responsibilities**:
- Manage the SaaS platform itself
- Global user database management (ban/delete users)
- Configure subscription plans (Free vs. Premium)
- View platform-wide analytics (server load, total active ladders)

**Key Constraints**:
- **Cannot** interfere with match results inside a specific organizer's private ladder
- This ensures organizer autonomy and privacy
- System Admin role is assigned manually and cannot be self-assigned

**Permissions**:
- `manage_users`
- `manage_subscriptions`
- `view_platform_analytics`
- `manage_platform_settings`
- `view_ladder` (read-only)
- `view_public_ladders`
- `view_public_rankings`
- `view_ladder_analytics`

### Tournament Organizer

**Scope**: Context-specific (tied to a specific `ladder_id`)

**Responsibilities**:
- "Own" and manage a specific ladder instance
- Create/Delete Ladders with custom rules (points per win, challenge range)
- Member Management (approve/kick players from their specific ladder)
- Dispute Resolution (overturn match results if players disagree)
- Broadcasting (send email/in-app blasts to all players in their ladder)

**Permissions**:
- All Player permissions (organizers can participate in their own ladder)
- `create_ladder`
- `delete_ladder`
- `configure_ladder`
- `manage_ladder_members`
- `resolve_disputes`
- `modify_match_results`
- `send_broadcasts`
- `view_ladder_analytics`

### Player

**Scope**: Context-specific (tied to a specific `ladder_id`)

**Responsibilities**:
- Participate in ladder activities
- Manage own profile (stats, availability, home court location)
- Issue challenges to other players within allowed rank range
- Input match scores (Winner reports, Loser confirms)
- View live rankings and match history

**Permissions**:
- `view_ladder`
- `issue_challenges`
- `report_match_scores`
- `confirm_match_scores`
- `manage_own_profile`
- `view_match_history`

### Guest/Spectator

**Scope**: Global or context-specific

**Responsibilities**:
- View public content without full participation
- Non-logged-in or limited-access users
- Can view public ladders but cannot challenge

**Permissions**:
- `view_public_ladders`
- `view_public_rankings`

## Permission Model

### Permission Categories

1. **Platform Management**: System-level operations (System Admin only)
2. **Ladder Management**: Ladder-level operations (Organizer only)
3. **Player Actions**: Participant-level operations (Player and Organizer)
4. **Guest Actions**: Public read-only operations (Guest)

### Permission Hierarchy

```
System Admin (Global)
├── Platform management permissions
└── Read-only ladder viewing

Organizer (Ladder-specific)
├── All Player permissions
└── Ladder management permissions

Player (Ladder-specific)
└── Player action permissions

Guest (Global or Ladder-specific)
└── Public viewing permissions
```

## Architecture

### Class Structure

```
UserRole (enum)
  - systemAdmin
  - organizer
  - player
  - guest

Permission (enum)
  - manageUsers
  - createLadder
  - issueChallenges
  - ... (all permissions)

UserRoleAssignment (model)
  - userId: String
  - role: UserRole
  - ladderId: String? (null for global roles)
  - createdAt: DateTime?
  - updatedAt: DateTime?

RolePermissions (static mapping)
  - Maps each role to its permissions
  - Provides permission checking methods

RBACService (service)
  - Permission checking
  - Role assignment management
  - Context-aware access control
```

### Data Flow

```
User Action Request
    ↓
RBACService.hasPermission()
    ↓
Check UserRoleAssignment(s)
    ↓
Lookup RolePermissions
    ↓
Return: Allowed / Denied
```

## Usage Examples

### 1. Basic Role Assignment

```dart
import 'package:nonna_app/models/user_role.dart';
import 'package:nonna_app/models/user_role_assignment.dart';
import 'package:nonna_app/services/rbac_service.dart';

final rbacService = RBACService();

// Assign a player role to a user in a specific ladder
final playerAssignment = UserRoleAssignment(
  userId: 'user123',
  role: UserRole.player,
  ladderId: 'ladder456',
);

rbacService.assignRole(playerAssignment);
```

### 2. Check Permission

```dart
// Check if user can issue challenges in a specific ladder
final canChallenge = rbacService.hasPermission(
  userId: 'user123',
  permission: Permission.issueChallenges,
  ladderId: 'ladder456',
);

if (canChallenge) {
  // Allow user to issue challenge
} else {
  // Show error message
}
```

### 3. Multiple Roles in Different Ladders

```dart
// User is an organizer of one ladder
final organizerAssignment = UserRoleAssignment(
  userId: 'user123',
  role: UserRole.organizer,
  ladderId: 'ladder_abc',
);

// Same user is a player in another ladder
final playerAssignment = UserRoleAssignment(
  userId: 'user123',
  role: UserRole.player,
  ladderId: 'ladder_xyz',
);

rbacService.assignRole(organizerAssignment);
rbacService.assignRole(playerAssignment);

// Check permissions in each context
print(rbacService.isLadderOrganizer('user123', 'ladder_abc')); // true
print(rbacService.isLadderPlayer('user123', 'ladder_xyz'));     // true
print(rbacService.isLadderOrganizer('user123', 'ladder_xyz')); // false
```

### 4. Get User Permissions

```dart
// Get all permissions for a user in a specific ladder
final permissions = rbacService.getUserPermissions(
  userId: 'user123',
  ladderId: 'ladder456',
);

print('User has ${permissions.length} permissions in this ladder');
```

### 5. List Ladders by Role

```dart
// Get all ladders where user is an organizer
final organizerLadders = rbacService.getLaddersForRole(
  'user123',
  UserRole.organizer,
);

// Get all ladders where user is a player
final playerLadders = rbacService.getLaddersForRole(
  'user123',
  UserRole.player,
);
```

### 6. System Admin Assignment

```dart
// System Admin is a global role (no ladder context)
final adminAssignment = UserRoleAssignment(
  userId: 'admin123',
  role: UserRole.systemAdmin,
  // No ladderId - global role
);

rbacService.assignRole(adminAssignment);

// Check if user is system admin
if (rbacService.isSystemAdmin('admin123')) {
  // Show admin dashboard
}
```

### 7. Validation

```dart
// Invalid: System Admin with ladder_id
final invalidAssignment = UserRoleAssignment(
  userId: 'user123',
  role: UserRole.systemAdmin,
  ladderId: 'ladder456', // Invalid!
);

print(invalidAssignment.isValid()); // false

// Throws ArgumentError
try {
  rbacService.assignRole(invalidAssignment);
} catch (e) {
  print('Invalid role assignment: $e');
}
```

### 8. UI Permission Checks

```dart
// In a widget
Widget build(BuildContext context) {
  final userId = getCurrentUserId();
  final ladderId = getCurrentLadderId();
  
  return Column(
    children: [
      // Show challenge button only if user has permission
      if (rbacService.hasPermission(
        userId: userId,
        permission: Permission.issueChallenges,
        ladderId: ladderId,
      ))
        ElevatedButton(
          onPressed: () => showChallengeDialog(),
          child: Text('Challenge Player'),
        ),
      
      // Show admin panel only for organizers
      if (rbacService.isLadderOrganizer(userId, ladderId))
        AdminPanelWidget(),
    ],
  );
}
```

## Database Setup

### Step 1: Run Migration Script

Execute the migration script from the [Database Schema documentation](./database_schema.md) to create all necessary tables, constraints, and RLS policies.

```bash
# Using Supabase CLI
supabase db push

# Or execute the SQL directly in Supabase Dashboard
# SQL Editor > New Query > Paste migration script > Run
```

### Step 2: Verify Tables

Check that all tables are created:
- `users`
- `roles`
- `permissions`
- `role_permissions`
- `user_roles`
- `ladders` (placeholder)

### Step 3: Verify Default Data

```sql
-- Check roles
SELECT * FROM roles;

-- Check permissions
SELECT * FROM permissions;

-- Check role-permission mappings
SELECT r.display_name, p.display_name
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.id
JOIN permissions p ON rp.permission_id = p.id
ORDER BY r.display_name, p.display_name;
```

### Step 4: Create First System Admin

```sql
-- Manually set a user as system admin
UPDATE users
SET is_system_admin = TRUE
WHERE email = 'admin@example.com';

-- Assign system admin role
INSERT INTO user_roles (user_id, role_id)
SELECT id, (SELECT id FROM roles WHERE name = 'system_admin')
FROM users
WHERE email = 'admin@example.com';
```

## Best Practices

### 1. Always Check Permissions in Backend

Never rely solely on UI permission checks. Always validate permissions in backend/API calls:

```dart
// Backend API handler
Future<void> deleteMatch(String matchId, String userId) async {
  final match = await getMatch(matchId);
  
  // Verify user has permission
  final canModify = rbacService.hasPermission(
    userId: userId,
    permission: Permission.modifyMatchResults,
    ladderId: match.ladderId,
  );
  
  if (!canModify) {
    throw UnauthorizedException('You do not have permission to modify match results');
  }
  
  await _deleteMatch(matchId);
}
```

### 2. Use Convenience Methods

The RBACService provides convenience methods for common checks:

```dart
// Instead of:
rbacService.hasRole(userId: userId, role: UserRole.systemAdmin)

// Use:
rbacService.isSystemAdmin(userId)

// Instead of:
rbacService.hasRole(userId: userId, role: UserRole.organizer, ladderId: ladderId)

// Use:
rbacService.isLadderOrganizer(userId, ladderId)
```

### 3. Validate Role Assignments

Always validate assignments before persisting:

```dart
final assignment = UserRoleAssignment(
  userId: userId,
  role: role,
  ladderId: ladderId,
);

if (!assignment.isValid()) {
  throw ArgumentError('Invalid role assignment configuration');
}

rbacService.assignRole(assignment);
```

### 4. Load Roles on App Start

Load user roles when the app starts or when user logs in:

```dart
Future<void> initializeUserRoles(String userId) async {
  // Fetch from Supabase
  final response = await supabase
    .from('user_roles')
    .select('''
      *,
      role:roles(*)
    ''')
    .eq('user_id', userId);
  
  // Parse and load into RBACService
  final assignments = response.map((data) => 
    UserRoleAssignment.fromJson(data)
  ).toList();
  
  rbacService.loadRoleAssignments(assignments);
}
```

### 5. Cache Permission Checks

For frequently accessed permissions, consider caching:

```dart
class CachedRBACService {
  final RBACService _rbacService;
  final Map<String, bool> _cache = {};
  
  bool hasPermission({
    required String userId,
    required Permission permission,
    String? ladderId,
  }) {
    final cacheKey = '$userId:${permission.value}:$ladderId';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    final result = _rbacService.hasPermission(
      userId: userId,
      permission: permission,
      ladderId: ladderId,
    );
    
    _cache[cacheKey] = result;
    return result;
  }
  
  void invalidateCache() {
    _cache.clear();
  }
}
```

## Security Considerations

### 1. Row Level Security (RLS)

All database tables have RLS policies enabled. These policies enforce access control at the database level, providing defense in depth.

### 2. System Admin Protection

The `is_system_admin` flag in the users table is protected:
- Cannot be modified by regular users
- Only database admins can set this flag
- RLS policies prevent unauthorized access

### 3. Organizer Autonomy

System Admins deliberately **cannot** modify match results in organizers' private ladders. This design ensures:
- Organizer privacy and autonomy
- Trust in the platform
- Clear separation of concerns

### 4. Context Validation

Always validate that role assignments have the correct context:
- System Admin: No ladder context (global)
- Organizer/Player: Must have ladder context
- Guest: Can be either global or ladder-specific

### 5. Principle of Least Privilege

Assign the minimum permissions necessary:
- Don't assign Organizer role when Player is sufficient
- Don't assign System Admin unless absolutely necessary
- Regularly audit role assignments

## Testing

### Unit Tests

Run the comprehensive unit tests:

```bash
# Run all RBAC tests
flutter test test/models/
flutter test test/services/rbac_service_test.dart

# Run specific test file
flutter test test/models/user_role_test.dart
```

### Integration Tests

Test the full flow with actual database:

```dart
// integration_test/rbac_integration_test.dart
testWidgets('User can challenge players in their ladder', (tester) async {
  final userId = await createTestUser();
  final ladderId = await createTestLadder();
  
  await assignRole(userId, UserRole.player, ladderId);
  
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Challenge'));
  
  // Verify challenge was created
  expect(find.text('Challenge Sent'), findsOneWidget);
});
```

## Troubleshooting

### Issue: Permission check returns false unexpectedly

**Possible causes**:
1. User doesn't have the role assigned
2. Ladder context doesn't match
3. Role assignments weren't loaded

**Solution**:
```dart
// Debug permission check
final assignments = rbacService.getUserRoleAssignments(userId);
print('User has ${assignments.length} role assignments');

final permissions = rbacService.getUserPermissions(
  userId: userId,
  ladderId: ladderId,
);
print('User permissions: ${permissions.map((p) => p.value).toList()}');
```

### Issue: Invalid role assignment error

**Cause**: Role assignment doesn't meet validation rules

**Solution**:
```dart
final assignment = UserRoleAssignment(...);
print('Is valid: ${assignment.isValid()}');

// Check specific rules
if (assignment.role.isSystemAdmin && assignment.ladderId != null) {
  print('Error: System Admin cannot have ladder context');
}
```

### Issue: RLS policy blocks access

**Cause**: Row Level Security policy is blocking the operation

**Solution**:
1. Check RLS policies in Supabase Dashboard
2. Verify user's auth.uid() matches expected user_id
3. Check if role assignments are correct in database

```sql
-- Check user's role assignments
SELECT ur.*, r.name as role_name
FROM user_roles ur
JOIN roles r ON ur.role_id = r.id
WHERE ur.user_id = 'user-uuid';
```

## Next Steps

1. **Epic 27**: Implement the full Ladder model with feature flags
2. **Epic 24**: Integrate RBAC with Authentication system
3. **Epic 29**: Use RBAC for Baby Profile management (can be adapted for Ladder management)
4. **Integration**: Connect RBACService with Supabase backend

## References

- [Database Schema Documentation](./database_schema.md)
- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
