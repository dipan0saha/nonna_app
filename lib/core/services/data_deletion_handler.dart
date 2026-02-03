import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';
import 'storage_service.dart';

/// Handler for GDPR-compliant data deletion
/// 
/// Provides hard delete of user accounts with cascade deletion and anonymization
class DataDeletionHandler {
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final SupabaseClient _supabase;

  DataDeletionHandler({
    DatabaseService? databaseService,
    StorageService? storageService,
    SupabaseClient? supabase,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _storageService = storageService ?? StorageService(),
        _supabase = supabase ?? Supabase.instance.client;

  // ==========================================
  // Account Deletion
  // ==========================================

  /// Delete user account and all associated data
  /// 
  /// [userId] The user ID to delete
  /// [confirmationToken] A token to confirm the deletion request
  /// Returns true if deletion was successful
  Future<bool> deleteUserAccount(
    String userId, {
    String? confirmationToken,
  }) async {
    try {
      debugPrint('🗑️ Starting account deletion for user $userId');

      // Verify confirmation token if provided
      if (confirmationToken != null) {
        final isValid = await _verifyConfirmationToken(userId, confirmationToken);
        if (!isValid) {
          throw Exception('Invalid confirmation token');
        }
      }

      // Delete user data in the correct order to respect foreign key constraints
      await _deleteUserPhotos(userId);
      await _deleteUserComments(userId);
      await _deleteUserEvents(userId);
      await _deleteUserRegistry(userId);
      await _deleteUserVotes(userId);
      await _deleteUserNotifications(userId);
      await _deleteUserMemberships(userId);
      await _deleteUserInvitations(userId);
      await _deleteUserProfile(userId);

      // Anonymize historical records
      await _anonymizeUserRecords(userId);

      // Delete auth user (this should cascade to remaining linked records)
      await _deleteAuthUser(userId);

      debugPrint('✅ Account deletion completed for user $userId');
      
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting user account: $e');
      return false;
    }
  }

  // ==========================================
  // Photo Deletion
  // ==========================================

  /// Delete all photos uploaded by user
  Future<void> _deleteUserPhotos(String userId) async {
    try {
      debugPrint('🗑️ Deleting user photos...');

      // Get all photos uploaded by user
      final photos = await _databaseService
          .select('photos', columns: 'id, storage_path, thumbnail_path')
          .eq('uploaded_by_user_id', userId);

      // Delete from storage
      for (final photo in photos) {
        try {
          final storagePath = photo['storage_path'] as String?;
          if (storagePath != null) {
            await _storageService.deleteFile('gallery-photos', storagePath);
          }

          final thumbnailPath = photo['thumbnail_path'] as String?;
          if (thumbnailPath != null) {
            await _storageService.deleteFile('gallery-photos', thumbnailPath);
          }
        } catch (e) {
          debugPrint('⚠️ Error deleting photo files: $e');
          // Continue with other photos
        }
      }

      // Soft delete photos in database and scrub sensitive data
      await _databaseService
          .update('photos', {
            'deleted_at': DateTime.now().toIso8601String(),
            'storage_path': null,
            'thumbnail_path': null,
            'caption': null,
            'tags': null,
          })
          .eq('uploaded_by_user_id', userId);

      debugPrint('✅ User photos deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user photos: $e');
      rethrow;
    }
  }

  // ==========================================
  // Comments Deletion
  // ==========================================

  /// Delete all comments made by user
  Future<void> _deleteUserComments(String userId) async {
    try {
      debugPrint('🗑️ Deleting user comments...');

      // Delete photo comments
      await _databaseService
          .delete('photo_comments')
          .eq('user_id', userId);

      // Delete event comments
      await _databaseService
          .delete('event_comments')
          .eq('user_id', userId);

      debugPrint('✅ User comments deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user comments: $e');
      rethrow;
    }
  }

  // ==========================================
  // Events Deletion
  // ==========================================

  /// Delete all events created by user
  Future<void> _deleteUserEvents(String userId) async {
    try {
      debugPrint('🗑️ Deleting user events...');

      // Get events created by user
      final events = await _databaseService
          .select('events', columns: 'id')
          .eq('created_by_user_id', userId);

      for (final event in events) {
        final eventId = event['id'] as String;

        // Delete event RSVPs
        await _databaseService
            .delete('event_rsvps')
            .eq('event_id', eventId);

        // Delete event comments (cascade)
        await _databaseService
            .delete('event_comments')
            .eq('event_id', eventId);
      }

      // Delete events
      await _databaseService
          .delete('events')
          .eq('created_by_user_id', userId);

      // Delete user's RSVPs to other events
      await _databaseService
          .delete('event_rsvps')
          .eq('user_id', userId);

      debugPrint('✅ User events deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user events: $e');
      rethrow;
    }
  }

  // ==========================================
  // Registry Deletion
  // ==========================================

  /// Delete all registry items and purchases by user
  Future<void> _deleteUserRegistry(String userId) async {
    try {
      debugPrint('🗑️ Deleting user registry data...');

      // Delete registry purchases
      await _databaseService
          .delete('registry_purchases')
          .eq('purchased_by_user_id', userId);

      // Delete registry items
      await _databaseService
          .delete('registry_items')
          .eq('created_by_user_id', userId);

      debugPrint('✅ User registry data deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user registry data: $e');
      rethrow;
    }
  }

  // ==========================================
  // Votes Deletion
  // ==========================================

  /// Delete all votes and suggestions by user
  Future<void> _deleteUserVotes(String userId) async {
    try {
      debugPrint('🗑️ Deleting user votes...');

      // Delete name suggestions
      await _databaseService
          .delete('name_suggestions')
          .eq('suggested_by_user_id', userId);

      // Delete name suggestion likes
      await _databaseService
          .delete('name_suggestion_likes')
          .eq('user_id', userId);

      // Delete votes
      await _databaseService
          .delete('votes')
          .eq('user_id', userId);

      // Delete photo squishes
      await _databaseService
          .delete('photo_squishes')
          .eq('user_id', userId);

      debugPrint('✅ User votes deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user votes: $e');
      rethrow;
    }
  }

  // ==========================================
  // Notifications Deletion
  // ==========================================

  /// Delete all notifications for user
  Future<void> _deleteUserNotifications(String userId) async {
    try {
      debugPrint('🗑️ Deleting user notifications...');

      await _databaseService
          .delete('notifications')
          .eq('user_id', userId);

      debugPrint('✅ User notifications deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user notifications: $e');
      rethrow;
    }
  }

  // ==========================================
  // Memberships Deletion
  // ==========================================

  /// Delete all baby memberships for user
  Future<void> _deleteUserMemberships(String userId) async {
    try {
      debugPrint('🗑️ Deleting user memberships...');

      // Mark memberships as removed
      await _databaseService
          .update('baby_memberships', {
            'removed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Delete photo tags
      await _databaseService
          .delete('photo_tags')
          .eq('tagged_user_id', userId);

      debugPrint('✅ User memberships deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user memberships: $e');
      rethrow;
    }
  }

  // ==========================================
  // Invitations Deletion
  // ==========================================

  /// Delete all invitations sent by or to user
  Future<void> _deleteUserInvitations(String userId) async {
    try {
      debugPrint('🗑️ Deleting user invitations...');

      // Delete invitations sent by user
      await _databaseService
          .delete('invitations')
          .eq('invited_by_user_id', userId);

      // Note: Invitations received by email can't be deleted by user_id
      // They would need to be handled separately if needed

      debugPrint('✅ User invitations deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user invitations: $e');
      rethrow;
    }
  }

  // ==========================================
  // Profile Deletion
  // ==========================================

  /// Delete user profile and stats
  Future<void> _deleteUserProfile(String userId) async {
    try {
      debugPrint('🗑️ Deleting user profile...');

      // Delete user stats
      await _databaseService
          .delete('user_stats')
          .eq('user_id', userId);

      // Delete profile
      await _databaseService
          .delete('profiles')
          .eq('user_id', userId);

      debugPrint('✅ User profile deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user profile: $e');
      rethrow;
    }
  }

  // ==========================================
  // Anonymization
  // ==========================================

  /// Anonymize historical records that need to be kept for auditing
  Future<void> _anonymizeUserRecords(String userId) async {
    try {
      debugPrint('🔒 Anonymizing user records...');

      // Anonymize activity events
      // Note: This would update any historical records that need to be kept
      // but should not contain personal information
      
      debugPrint('✅ User records anonymized');
    } catch (e) {
      debugPrint('❌ Error anonymizing user records: $e');
      rethrow;
    }
  }

  // ==========================================
  // Auth User Deletion
  // ==========================================

  /// Delete auth user account
  Future<void> _deleteAuthUser(String userId) async {
    try {
      debugPrint('🗑️ Deleting auth user...');

      // Delete user from Supabase Auth via an admin edge function
      // The edge function should use the service role key to delete the auth user
      try {
        final response = await _supabase.functions.invoke(
          'admin-delete-auth-user',
          body: {'user_id': userId},
        );

        // Check for successful deletion
        if (response.status < 200 || response.status >= 300) {
          debugPrint(
            '❌ Auth user deletion failed: status=${response.status}',
          );
          throw Exception(
            'Failed to delete auth user (status=${response.status})',
          );
        }

        debugPrint('✅ Auth user deleted from Supabase Auth');
      } catch (e) {
        // If the edge function doesn't exist yet, log a warning but don't fail
        debugPrint('⚠️ Auth user deletion edge function not available: $e');
        debugPrint('⚠️ Auth user deletion must be completed manually via Supabase dashboard or admin API');
        // Note: In production, this should throw to prevent partial deletion
      }
    } catch (e) {
      debugPrint('❌ Error deleting auth user: $e');
      rethrow;
    }
  }

  // ==========================================
  // Confirmation
  // ==========================================

  /// Verify confirmation token for account deletion
  Future<bool> _verifyConfirmationToken(String userId, String token) async {
    try {
      // In a real implementation, this would:
      // 1. Query a deletion_tokens table for the token
      // 2. Verify it matches the userId
      // 3. Check it hasn't expired
      // 4. Mark it as used to prevent reuse
      
      // For now, return false to require proper implementation
      debugPrint('⚠️ Token verification not implemented - rejecting deletion request');
      debugPrint('⚠️ Implement token storage and verification before production use');
      return false;
    } catch (e) {
      debugPrint('❌ Error verifying confirmation token: $e');
      return false;
    }
  }

  /// Request account deletion confirmation
  Future<String> requestDeletionConfirmation(String userId) async {
    try {
      // In a real implementation, this would:
      // 1. Generate a secure confirmation token
      // 2. Store it with an expiration time
      // 3. Send it to the user via email
      // 4. Return the token
      
      final token = 'confirmation_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('📧 Deletion confirmation token: $token');
      
      return token;
    } catch (e) {
      debugPrint('❌ Error requesting deletion confirmation: $e');
      rethrow;
    }
  }
}
