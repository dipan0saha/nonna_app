// Example integration file showing how to use the RBAC system in a Flutter app
// This file is for reference only and should be adapted to your specific needs

import 'package:flutter/material.dart';
import 'package:nonna_app/models/user_role.dart';
import 'package:nonna_app/models/permission.dart';
import 'package:nonna_app/models/user_role_assignment.dart';
import 'package:nonna_app/services/rbac_service.dart';

/// Example: Global RBAC service instance
/// In a real app, this would be provided via dependency injection (Provider, GetIt, etc.)
final rbacService = RBACService();

/// Example 1: Initialize user roles on app start
Future<void> initializeUserRoles(String userId) async {
  // In a real implementation, fetch from Supabase
  // final response = await supabase
  //   .from('user_roles')
  //   .select('*, role:roles(*)')
  //   .eq('user_id', userId);
  
  // For this example, mock data
  final mockAssignments = [
    UserRoleAssignment(
      userId: userId,
      role: UserRole.organizer,
      ladderId: 'ladder_abc',
    ),
    UserRoleAssignment(
      userId: userId,
      role: UserRole.player,
      ladderId: 'ladder_xyz',
    ),
  ];
  
  rbacService.loadRoleAssignments(mockAssignments);
  
  print('Loaded ${mockAssignments.length} role assignments for user $userId');
}

/// Example 2: Permission-based UI widget
class LadderActionsWidget extends StatelessWidget {
  final String userId;
  final String ladderId;
  
  const LadderActionsWidget({
    Key? key,
    required this.userId,
    required this.ladderId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show challenge button only if user can issue challenges
        if (rbacService.hasPermission(
          userId: userId,
          permission: Permission.issueChallenges,
          ladderId: ladderId,
        ))
          ElevatedButton(
            onPressed: () => _showChallengeDialog(context),
            child: const Text('Challenge Player'),
          ),
        
        const SizedBox(height: 8),
        
        // Show admin panel only for organizers
        if (rbacService.isLadderOrganizer(userId, ladderId))
          ElevatedButton.icon(
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Manage Ladder'),
            onPressed: () => _showAdminPanel(context),
          ),
        
        const SizedBox(height: 8),
        
        // Show system admin tools only for system admins
        if (rbacService.isSystemAdmin(userId))
          OutlinedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Platform Settings'),
            onPressed: () => _showPlatformSettings(context),
          ),
      ],
    );
  }
  
  void _showChallengeDialog(BuildContext context) {
    // Implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Challenge Player'),
        content: const Text('Select a player to challenge...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit challenge
              Navigator.pop(context);
            },
            child: const Text('Send Challenge'),
          ),
        ],
      ),
    );
  }
  
  void _showAdminPanel(BuildContext context) {
    // Implementation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LadderAdminPanel(ladderId: ladderId),
      ),
    );
  }
  
  void _showPlatformSettings(BuildContext context) {
    // Implementation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlatformSettingsScreen(),
      ),
    );
  }
}

/// Example 3: Backend API call with permission check
class LadderService {
  final RBACService rbacService;
  
  LadderService(this.rbacService);
  
  Future<void> deleteMatch(String matchId, String userId) async {
    // Fetch match details
    final match = await _getMatch(matchId);
    
    // Verify user has permission to modify match results
    final canModify = rbacService.hasPermission(
      userId: userId,
      permission: Permission.modifyMatchResults,
      ladderId: match['ladder_id'] as String,
    );
    
    if (!canModify) {
      throw Exception('You do not have permission to modify match results');
    }
    
    // Proceed with deletion
    // await supabase.from('matches').delete().eq('id', matchId);
    
    print('Match $matchId deleted by user $userId');
  }
  
  Future<void> updateLadderSettings(
    String ladderId,
    Map<String, dynamic> settings,
    String userId,
  ) async {
    // Verify user is organizer of this ladder
    if (!rbacService.isLadderOrganizer(userId, ladderId)) {
      throw Exception('Only the ladder organizer can update settings');
    }
    
    // Update ladder settings
    // await supabase.from('ladders').update(settings).eq('id', ladderId);
    
    print('Ladder $ladderId settings updated by organizer $userId');
  }
  
  Future<Map<String, dynamic>> _getMatch(String matchId) async {
    // Mock implementation
    return {
      'id': matchId,
      'ladder_id': 'ladder_abc',
      'winner_id': 'user123',
      'loser_id': 'user456',
    };
  }
}

/// Example 4: User dashboard showing all ladders by role
class UserDashboardScreen extends StatelessWidget {
  final String userId;
  
  const UserDashboardScreen({Key? key, required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get all ladders where user is an organizer
    final organizerLadders = rbacService.getLaddersForRole(
      userId,
      UserRole.organizer,
    );
    
    // Get all ladders where user is a player
    final playerLadders = rbacService.getLaddersForRole(
      userId,
      UserRole.player,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ladders'),
        actions: [
          if (rbacService.isSystemAdmin(userId))
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Navigate to admin dashboard
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (organizerLadders.isNotEmpty) ...[
            const Text(
              'Ladders I Organize',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...organizerLadders.map((ladderId) => LadderCard(
              ladderId: ladderId,
              role: 'Organizer',
            )),
            const SizedBox(height: 24),
          ],
          
          if (playerLadders.isNotEmpty) ...[
            const Text(
              'Ladders I Play In',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...playerLadders.map((ladderId) => LadderCard(
              ladderId: ladderId,
              role: 'Player',
            )),
          ],
          
          if (organizerLadders.isEmpty && playerLadders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'You are not part of any ladders yet.\nCreate one or join an existing ladder!',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create ladder screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Ladder'),
      ),
    );
  }
}

/// Example 5: Middleware for route protection
class RouteGuard {
  final RBACService rbacService;
  
  RouteGuard(this.rbacService);
  
  bool canAccessRoute(String userId, String route, {String? ladderId}) {
    // Define route permissions
    const routePermissions = {
      '/admin': Permission.managePlatformSettings,
      '/ladder/settings': Permission.configureLadder,
      '/ladder/members': Permission.manageLadderMembers,
      '/challenge/create': Permission.issueChallenges,
    };
    
    final requiredPermission = routePermissions[route];
    if (requiredPermission == null) {
      return true; // Public route
    }
    
    return rbacService.hasPermission(
      userId: userId,
      permission: requiredPermission,
      ladderId: ladderId,
    );
  }
}

/// Example 6: Role assignment flow (for admins/organizers)
class AssignRoleDialog extends StatefulWidget {
  final String targetUserId;
  final String ladderId;
  final String currentUserId;
  
  const AssignRoleDialog({
    Key? key,
    required this.targetUserId,
    required this.ladderId,
    required this.currentUserId,
  }) : super(key: key);
  
  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  UserRole? selectedRole;
  
  @override
  Widget build(BuildContext context) {
    // Check if current user can assign roles
    final canManageMembers = rbacService.hasPermission(
      userId: widget.currentUserId,
      permission: Permission.manageLadderMembers,
      ladderId: widget.ladderId,
    );
    
    if (!canManageMembers) {
      return AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('You do not have permission to manage ladder members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }
    
    return AlertDialog(
      title: const Text('Assign Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select a role for this user:'),
          const SizedBox(height: 16),
          DropdownButton<UserRole>(
            value: selectedRole,
            hint: const Text('Select Role'),
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: UserRole.player,
                child: Text(UserRole.player.displayName),
              ),
              // Organizers can only assign player roles in their ladder
              // System admin assignment requires higher privileges
            ],
            onChanged: (role) {
              setState(() {
                selectedRole = role;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedRole == null ? null : () async {
            final assignment = UserRoleAssignment(
              userId: widget.targetUserId,
              role: selectedRole!,
              ladderId: widget.ladderId,
            );
            
            try {
              rbacService.assignRole(assignment);
              
              // In real app, sync with Supabase
              // await supabase.from('user_roles').insert(assignment.toJson());
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role assigned successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

// Mock widgets for examples
class LadderCard extends StatelessWidget {
  final String ladderId;
  final String role;
  
  const LadderCard({Key? key, required this.ladderId, required this.role}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Ladder $ladderId'),
        subtitle: Text('Role: $role'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to ladder details
        },
      ),
    );
  }
}

class LadderAdminPanel extends StatelessWidget {
  final String ladderId;
  
  const LadderAdminPanel({Key? key, required this.ladderId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ladder Admin')),
      body: const Center(child: Text('Admin Panel')),
    );
  }
}

class PlatformSettingsScreen extends StatelessWidget {
  const PlatformSettingsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Settings')),
      body: const Center(child: Text('Platform Settings')),
    );
  }
}
