import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/user_role.dart';

/// RLS (Row Level Security) Validator for development-mode testing
///
/// **Functional Requirements**: Section 3.2.7 - Middleware
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Development-mode RLS policy validation
/// - Access denial logging
/// - Role simulation
/// - Permission testing
///
/// Dependencies: UserRole enum
class RlsValidator {
  final SupabaseClient _client;
  bool _isEnabled = kDebugMode;

  RlsValidator(this._client);

  // ============================================================
  // Configuration
  // ============================================================

  /// Enable or disable RLS validation
  ///
  /// [enabled] Whether to enable validation
  void setEnabled(bool enabled) {
    _isEnabled = enabled && kDebugMode;
    debugPrint(
        _isEnabled ? '✅ RLS Validator enabled' : '⚠️  RLS Validator disabled');
  }

  /// Check if validator is enabled
  bool get isEnabled => _isEnabled;

  // ============================================================
  // Role Simulation
  // ============================================================

  /// Simulate access as a specific role
  ///
  /// [role] User role to simulate
  /// [babyProfileId] Baby profile ID for context
  /// [operation] Operation being performed
  /// Returns true if access should be granted
  Future<bool> simulateRoleAccess({
    required UserRole role,
    required String babyProfileId,
    required String operation,
  }) async {
    if (!_isEnabled) return true;

    debugPrint('🔐 Simulating RLS access: role=$role, operation=$operation');

    // Simulate role-based access rules
    switch (role) {
      case UserRole.owner:
        // Owners have full access
        debugPrint('✅ Owner access granted');
        return true;

      case UserRole.follower:
        // Followers have read access and limited write access
        if (_isAdminOperation(operation)) {
          debugPrint('❌ Follower denied admin operation: $operation');
          return false;
        }
        if (_isWriteOperation(operation) && _isRestrictedWrite(operation)) {
          debugPrint('❌ Follower denied restricted write: $operation');
          return false;
        }
        if (_isPrivateData(operation)) {
          debugPrint('❌ Follower denied private data access: $operation');
          return false;
        }
        debugPrint('✅ Follower access granted');
        return true;
    }
  }

  /// Check if operation is an admin operation
  bool _isAdminOperation(String operation) {
    const adminOps = [
      'delete_baby_profile',
      'transfer_ownership',
      'manage_memberships',
      'delete_user',
    ];
    return adminOps.any((op) => operation.contains(op));
  }

  /// Check if operation is a write operation
  bool _isWriteOperation(String operation) {
    const writeOps = ['create', 'update', 'delete', 'insert'];
    return writeOps.any((op) => operation.toLowerCase().contains(op));
  }

  /// Check if operation is a restricted write
  bool _isRestrictedWrite(String operation) {
    const restrictedOps = [
      'update_profile',
      'delete_event',
      'delete_photo',
      'manage_registry',
    ];
    return restrictedOps.any((op) => operation.contains(op));
  }

  /// Check if operation accesses private data
  bool _isPrivateData(String operation) {
    const privateOps = [
      'financial_data',
      'private_notes',
      'medical_records',
      'contact_info',
    ];
    return privateOps.any((op) => operation.contains(op));
  }

  // ============================================================
  // Access Validation
  // ============================================================

  /// Validate user access to a baby profile
  ///
  /// [userId] User ID
  /// [babyProfileId] Baby profile ID
  /// [operation] Operation being performed
  /// Returns true if access is valid
  Future<bool> validateBabyProfileAccess({
    required String userId,
    required String babyProfileId,
    required String operation,
  }) async {
    if (!_isEnabled) return true;

    try {
      debugPrint(
          '🔍 Validating baby profile access: user=$userId, operation=$operation');

      // Get user's role for the baby profile
      final role = await _getUserRole(userId, babyProfileId);

      if (role == null) {
        debugPrint('❌ User has no role for baby profile: $babyProfileId');
        _logAccessDenial(userId, babyProfileId, operation, 'No membership');
        return false;
      }

      // Simulate role-based access
      final hasAccess = await simulateRoleAccess(
        role: role,
        babyProfileId: babyProfileId,
        operation: operation,
      );

      if (!hasAccess) {
        _logAccessDenial(
            userId, babyProfileId, operation, 'Insufficient permissions');
      }

      return hasAccess;
    } catch (e) {
      debugPrint('❌ Error validating baby profile access: $e');
      _logAccessDenial(userId, babyProfileId, operation, 'Validation error');
      return false;
    }
  }

  /// Get user's role for a baby profile
  ///
  /// [userId] User ID
  /// [babyProfileId] Baby profile ID
  /// Returns the user's role or null if not a member
  Future<UserRole?> _getUserRole(String userId, String babyProfileId) async {
    try {
      // Check if user is the owner
      final profileResponse = await _client
          .from('baby_profiles')
          .select('owner_id')
          .eq('id', babyProfileId)
          .single();

      if (profileResponse['owner_id'] == userId) {
        return UserRole.owner;
      }

      // Check membership
      final membershipResponse = await _client
          .from('baby_memberships')
          .select('role')
          .eq('baby_profile_id', babyProfileId)
          .eq('user_id', userId)
          .maybeSingle();

      if (membershipResponse == null) {
        return null;
      }

      final roleString = membershipResponse['role'] as String;
      return UserRole.fromJson(roleString);
    } catch (e) {
      debugPrint('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Validate table-level access
  ///
  /// [userId] User ID
  /// [tableName] Table name
  /// [operation] Operation (select, insert, update, delete)
  /// Returns true if access is valid
  Future<bool> validateTableAccess({
    required String userId,
    required String tableName,
    required String operation,
  }) async {
    if (!_isEnabled) return true;

    debugPrint(
        '🔍 Validating table access: table=$tableName, operation=$operation');

    // Validate based on table RLS policies
    // This is a simplified simulation
    final currentUser = _client.auth.currentUser;

    if (currentUser == null || currentUser.id != userId) {
      debugPrint('❌ User not authenticated or mismatch');
      _logAccessDenial(userId, tableName, operation, 'Authentication mismatch');
      return false;
    }

    debugPrint('✅ Table access validated');
    return true;
  }

  // ============================================================
  // Access Logging
  // ============================================================

  /// Log an access denial
  ///
  /// [userId] User ID
  /// [resource] Resource being accessed
  /// [operation] Operation attempted
  /// [reason] Reason for denial
  void _logAccessDenial(
    String userId,
    String resource,
    String operation,
    String reason,
  ) {
    final timestamp = DateTime.now().toIso8601String();

    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ 🚫 ACCESS DENIED');
    debugPrint('│ Time: $timestamp');
    debugPrint('│ User: $userId');
    debugPrint('│ Resource: $resource');
    debugPrint('│ Operation: $operation');
    debugPrint('│ Reason: $reason');
    debugPrint('└─────────────────────────────────────────────────────────');

    // In production, this would be logged to a monitoring service
    if (kReleaseMode) {
      // TODO: Send to monitoring service
    }
  }

  /// Get access denial logs (for development)
  ///
  /// Returns a list of recent access denials
  List<Map<String, dynamic>> getAccessDenialLogs() {
    // Placeholder for actual implementation
    // In production, this would query a log storage
    return [];
  }

  // ============================================================
  // Permission Testing
  // ============================================================

  /// Test RLS policies for a user
  ///
  /// [userId] User ID
  /// [babyProfileId] Baby profile ID
  /// Returns a map of operation results
  Future<Map<String, bool>> testRlsPolicies({
    required String userId,
    required String babyProfileId,
  }) async {
    if (!_isEnabled) {
      // Return an empty result when disabled
      debugPrint('⚠️  RLS Validator is disabled');
      return {};
    }

    debugPrint('🧪 Testing RLS policies for user=$userId, baby=$babyProfileId');

    final results = <String, bool>{};

    // Test common operations
    final operations = [
      'read_profile',
      'update_profile',
      'delete_profile',
      'read_events',
      'create_event',
      'update_event',
      'delete_event',
      'read_photos',
      'upload_photo',
      'delete_photo',
      'read_registry',
      'manage_registry',
    ];

    for (final operation in operations) {
      try {
        final hasAccess = await validateBabyProfileAccess(
          userId: userId,
          babyProfileId: babyProfileId,
          operation: operation,
        );
        results[operation] = hasAccess;
      } catch (e) {
        results[operation] = false;
        debugPrint('❌ Error testing $operation: $e');
      }
    }

    debugPrint('✅ RLS policy test complete');
    return results;
  }
}
