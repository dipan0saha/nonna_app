import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/performance_limits.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../tiles/new_baby_welcome/providers/new_baby_welcome_provider.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/enums/invitation_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/models/baby_membership.dart';
import '../../../../core/models/baby_profile.dart';
import '../../../../core/models/invitation.dart';
import '../../../../core/services/database_service.dart';

/// Baby Profile Provider for managing baby profile state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Baby profile management
/// - CRUD operations
/// - Membership management
/// - Owner operations (invitations, followers)
/// - Profile photo upload
///
/// Dependencies: DatabaseService, CacheService, StorageService, BabyProfile model

/// Baby profile screen state model
class BabyProfileState {
  final BabyProfile? profile;
  final List<BabyMembership> memberships;
  final List<Invitation> invitations;
  final bool isLoading;
  final bool isSaving;
  final bool isEditMode;
  final String? error;
  final String? saveError;
  final bool saveSuccess;
  final bool isOwner;

  const BabyProfileState({
    this.profile,
    this.memberships = const [],
    this.invitations = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isEditMode = false,
    this.error,
    this.saveError,
    this.saveSuccess = false,
    this.isOwner = false,
  });

  BabyProfileState copyWith({
    BabyProfile? profile,
    List<BabyMembership>? memberships,
    List<Invitation>? invitations,
    bool? isLoading,
    bool? isSaving,
    bool? isEditMode,
    String? error,
    String? saveError,
    bool? saveSuccess,
    bool? isOwner,
  }) {
    return BabyProfileState(
      profile: profile ?? this.profile,
      memberships: memberships ?? this.memberships,
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditMode: isEditMode ?? this.isEditMode,
      error: error,
      saveError: saveError,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  /// Get follower memberships
  List<BabyMembership> get followers {
    return memberships.where((m) => m.role == UserRole.follower).toList();
  }

  /// Get owner memberships
  List<BabyMembership> get owners {
    return memberships.where((m) => m.role == UserRole.owner).toList();
  }

  /// Get only pending invitations.
  List<Invitation> get pendingInvitations {
    return invitations
        .where((inv) => inv.status == InvitationStatus.pending)
        .toList();
  }
}

/// Baby Profile Provider Notifier
class BabyProfileNotifier extends Notifier<BabyProfileState> {
  @override
  BabyProfileState build() {
    return const BabyProfileState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'baby_profile';

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load baby profile
  Future<void> loadProfile({
    required String babyProfileId,
    required String currentUserId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final databaseService = ref.read(databaseServiceProvider);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedProfile = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
        if (cachedProfile != null) {
          final isOwner = await _checkIsOwner(
              babyProfileId, currentUserId, databaseService);
          if (!ref.mounted) return;
          state = state.copyWith(
            profile: cachedProfile,
            isLoading: false,
            isOwner: isOwner,
            invitations: isOwner ? state.invitations : const [],
          );
          // Load memberships in background
          _loadMemberships(babyProfileId, databaseService);
          if (isOwner) {
            _loadInvitations(babyProfileId, databaseService);
          }
          return;
        }
      }

      // Fetch from database
      final response = await databaseService
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyProfileId)
          .isFilter(SupabaseTables.deletedAt, null)
          .maybeSingle();
      if (!ref.mounted) return;

      if (response == null) {
        throw Exception('Baby profile not found');
      }

      final profile = BabyProfile.fromJson(response);

      // Check if current user is owner
      final isOwner =
          await _checkIsOwner(babyProfileId, currentUserId, databaseService);
      if (!ref.mounted) return;

      // Save to cache
      await _saveToCache(babyProfileId, profile);
      if (!ref.mounted) return;

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isOwner: isOwner,
      );

      // Load memberships
      await _loadMemberships(babyProfileId, databaseService);
      if (!ref.mounted) return;

      if (isOwner) {
        await _loadInvitations(babyProfileId, databaseService);
        if (!ref.mounted) return;
      } else {
        state = state.copyWith(invitations: const []);
      }

      debugPrint('✅ Loaded baby profile: $babyProfileId');
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to load baby profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Check if user is owner
  Future<bool> _checkIsOwner(String babyProfileId, String userId,
      DatabaseService databaseService) async {
    try {
      final response = await databaseService
          .select(SupabaseTables.babyMemberships)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .eq('user_id', userId)
          .eq('role', UserRole.owner.name)
          .isFilter('removed_at', null)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('⚠️  Failed to check owner status: $e');
      return false;
    }
  }

  /// Load memberships
  Future<void> _loadMemberships(
      String babyProfileId, DatabaseService databaseService) async {
    try {
      final response = await databaseService
          .select(SupabaseTables.babyMemberships)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .order('created_at', ascending: true);

      final memberships = (response as List)
          .map((json) => BabyMembership.fromJson(json as Map<String, dynamic>))
          .toList();
      if (!ref.mounted) return;

      state = state.copyWith(memberships: memberships);
      debugPrint('✅ Loaded ${memberships.length} memberships');
    } catch (e) {
      debugPrint('⚠️  Failed to load memberships: $e');
    }
  }

  /// Load invitations for the current baby profile.
  Future<void> _loadInvitations(
      String babyProfileId, DatabaseService databaseService) async {
    try {
      final response = await databaseService
          .select(SupabaseTables.invitations)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .order(SupabaseTables.createdAt, ascending: false);

      final invitations = (response as List)
          .map((json) => Invitation.fromJson(json as Map<String, dynamic>))
          .toList();
      if (!ref.mounted) return;

      state = state.copyWith(invitations: invitations);
      debugPrint('✅ Loaded ${invitations.length} invitations');
    } catch (e) {
      debugPrint('⚠️  Failed to load invitations: $e');
    }
  }

  /// Enable edit mode
  void enterEditMode() {
    if (!state.isOwner) {
      debugPrint('⚠️  Only owners can edit baby profile');
      return;
    }
    state =
        state.copyWith(isEditMode: true, saveError: null, saveSuccess: false);
    debugPrint('✅ Entered edit mode');
  }

  /// Cancel edit mode
  void cancelEdit() {
    state =
        state.copyWith(isEditMode: false, saveError: null, saveSuccess: false);
    debugPrint('✅ Cancelled edit mode');
  }

  /// Create baby profile
  Future<BabyProfile?> createProfile({
    required String name,
    required String userId,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    Gender? gender,
    String? profilePhotoUrl,
    String? defaultLastNameSource,
  }) async {
    try {
      state =
          state.copyWith(isSaving: true, saveError: null, saveSuccess: false);

      // Validate
      if (name.trim().isEmpty) {
        throw Exception('Baby name is required');
      }

      // Create profile in database
      final databaseService = ref.read(databaseServiceProvider);

      final profileData = {
        'name': name,
        'expected_birth_date': expectedBirthDate?.toIso8601String(),
        'actual_birth_date': actualBirthDate?.toIso8601String(),
        'gender': gender?.toJson() ?? Gender.unknown.toJson(),
        'profile_photo_url': profilePhotoUrl,
        'default_last_name_source': defaultLastNameSource,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await databaseService.insert(
          SupabaseTables.babyProfiles, profileData);

      final profile = BabyProfile.fromJson(response.first);

      // Create owner membership
      await databaseService.insert(SupabaseTables.babyMemberships, {
        'baby_profile_id': profile.id,
        'user_id': userId,
        'role': UserRole.owner.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (!ref.mounted) return null;

      state = state.copyWith(
        profile: profile,
        isSaving: false,
        saveSuccess: true,
        isOwner: true,
      );

      debugPrint('✅ Baby profile created: ${profile.id}');
      return profile;
    } catch (e) {
      if (!ref.mounted) return null;
      final errorMessage = 'Failed to create baby profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isSaving: false,
        saveError: errorMessage,
        saveSuccess: false,
      );
      return null;
    }
  }

  /// Update baby profile
  Future<void> updateProfile({
    required String babyProfileId,
    required String name,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    Gender? gender,
    String? profilePhotoUrl,
    String? defaultLastNameSource,
    double? birthWeightKg,
    double? birthHeightCm,
  }) async {
    if (!state.isOwner) {
      state = state.copyWith(saveError: 'Only owners can update baby profile');
      return;
    }

    try {
      state =
          state.copyWith(isSaving: true, saveError: null, saveSuccess: false);

      // Validate
      if (name.trim().isEmpty) {
        throw Exception('Baby name is required');
      }

      final databaseService = ref.read(databaseServiceProvider);

      // Update in database
      final updateData = {
        'name': name,
        'expected_birth_date': expectedBirthDate?.toIso8601String(),
        'actual_birth_date': actualBirthDate?.toIso8601String(),
        'gender': gender?.toJson(),
        'profile_photo_url': profilePhotoUrl,
        'default_last_name_source': defaultLastNameSource,
        'birth_weight_kg': birthWeightKg,
        'birth_height_cm': birthHeightCm,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await databaseService
          .update(SupabaseTables.babyProfiles, updateData)
          .eq('id', babyProfileId);

      // Reload profile
      final response = await databaseService
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyProfileId)
          .isFilter(SupabaseTables.deletedAt, null)
          .single();
      if (!ref.mounted) return;

      final profile = BabyProfile.fromJson(response);

      // Update cache
      await _saveToCache(babyProfileId, profile);
      if (!ref.mounted) return;

      // Bust the NewBabyWelcome tile's own Hive cache so the tile
      // immediately reflects any field changes (e.g. gender, weight, height).
      ref.read(newBabyWelcomeProvider.notifier).refresh(
            babyProfileId: babyProfileId,
          );

      state = state.copyWith(
        profile: profile,
        isSaving: false,
        isEditMode: false,
        saveSuccess: true,
      );

      debugPrint('✅ Baby profile updated successfully');
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to update baby profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isSaving: false,
        saveError: errorMessage,
        saveSuccess: false,
      );
    }
  }

  /// Delete baby profile (soft delete)
  Future<bool> deleteProfile({
    required String babyProfileId,
  }) async {
    if (!state.isOwner) {
      debugPrint('⚠️  Only owners can delete baby profile');
      return false;
    }

    try {
      final databaseService = ref.read(databaseServiceProvider);

      await databaseService.update(SupabaseTables.babyProfiles, {
        'deleted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', babyProfileId);

      debugPrint('✅ Baby profile deleted: $babyProfileId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete baby profile: $e');
      return false;
    }
  }

  /// Upload profile photo
  Future<String?> uploadProfilePhoto({
    required String babyProfileId,
    required String filePath,
  }) async {
    try {
      debugPrint('📤 Uploading profile photo...');

      final storageService = ref.read(storageServiceProvider);
      final storageKey =
          'baby_profiles/$babyProfileId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final photoUrl = await storageService.uploadFile(
        filePath: filePath,
        storageKey: storageKey,
        bucket: 'baby_profiles',
      );
      if (!ref.mounted) return null;

      debugPrint('✅ Profile photo uploaded: $photoUrl');
      return photoUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload profile photo: $e');
      return null;
    }
  }

  /// Remove follower (owner only)
  Future<bool> removeFollower({
    required String babyProfileId,
    required String membershipId,
  }) async {
    if (!state.isOwner) {
      debugPrint('⚠️  Only owners can remove followers');
      return false;
    }

    try {
      final databaseService = ref.read(databaseServiceProvider);

      await databaseService
          .delete(SupabaseTables.babyMemberships)
          .eq('id', membershipId);

      // Reload memberships
      await _loadMemberships(babyProfileId, databaseService);
      if (!ref.mounted) return false;

      debugPrint('✅ Follower removed');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to remove follower: $e');
      return false;
    }
  }

  /// Send a follower invitation by email.
  Future<Invitation> sendInvitation({
    required String babyProfileId,
    required String invitedByUserId,
    required String email,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(trimmedEmail)) {
      throw Exception('Enter a valid email address');
    }

    final normalizedEmail = trimmedEmail.toLowerCase();
    final databaseService = ref.read(databaseServiceProvider);

    final isOwner =
        await _checkIsOwner(babyProfileId, invitedByUserId, databaseService);
    if (!isOwner) {
      throw Exception('Only profile owners can invite followers');
    }

    final existingPending = await databaseService
        .select(SupabaseTables.invitations, columns: 'id')
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .eq('invitee_email', normalizedEmail)
        .eq(SupabaseTables.status, InvitationStatus.pending.toJson())
        .maybeSingle();

    if (existingPending != null) {
      throw Exception('An active invitation already exists for this email');
    }

    final now = DateTime.now();
    final tokenHash = const Uuid().v4();
    final response = await databaseService.insert(SupabaseTables.invitations, {
      SupabaseTables.id: const Uuid().v4(),
      SupabaseTables.babyProfileId: babyProfileId,
      'invited_by_user_id': invitedByUserId,
      'invitee_email': normalizedEmail,
      'token_hash': tokenHash,
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
      SupabaseTables.status: InvitationStatus.pending.toJson(),
      SupabaseTables.createdAt: now.toIso8601String(),
      SupabaseTables.updatedAt: now.toIso8601String(),
    });

    final invitation = Invitation.fromJson(response.first);

    try {
      await _sendInvitationEmail(
        invitation: invitation,
        babyProfileId: babyProfileId,
        invitedByUserId: invitedByUserId,
      );
    } catch (e) {
      try {
        await databaseService
            .delete(SupabaseTables.invitations)
            .eq(SupabaseTables.id, invitation.id);
      } catch (rollbackError) {
        debugPrint('⚠️  Failed to rollback invitation after email error: '
            '$rollbackError');
      }
      rethrow;
    }

    await _loadInvitations(babyProfileId, databaseService);
    return invitation;
  }

  Future<void> _sendInvitationEmail({
    required Invitation invitation,
    required String babyProfileId,
    required String invitedByUserId,
  }) async {
    final databaseService = ref.read(databaseServiceProvider);
    final supabaseClient = ref.read(supabaseClientProvider);

    final inviterName = await _resolveInviterName(
      databaseService: databaseService,
      invitedByUserId: invitedByUserId,
    );
    final babyName = await _resolveBabyName(
      databaseService: databaseService,
      babyProfileId: babyProfileId,
    );

    final inviteUrl =
        AppConfig.getFullUrl('/invite?token=${invitation.tokenHash}');

    final response = await supabaseClient.functions.invoke(
      'send-invitation-email',
      body: {
        'email': invitation.inviteeEmail,
        'inviterName': inviterName,
        'babyName': babyName,
        'inviteUrl': inviteUrl,
      },
    );

    if (response.status < 200 || response.status >= 300) {
      throw Exception('Unable to send invitation email right now');
    }

    final data = response.data;
    if (data is Map) {
      final message = data['message'] as String?;
      final error = data['error'] as String?;

      if (error != null && error.isNotEmpty) {
        throw Exception(error);
      }

      if (message != null && message.toLowerCase().contains('mock email')) {
        throw Exception('Invitation email service is not configured');
      }
    }
  }

  Future<String> _resolveInviterName({
    required DatabaseService databaseService,
    required String invitedByUserId,
  }) async {
    try {
      final response = await databaseService
          .select(
            SupabaseTables.userProfiles,
            columns: SupabaseTables.displayName,
          )
          .eq(SupabaseTables.userId, invitedByUserId)
          .maybeSingle();

      final displayName = response?[SupabaseTables.displayName] as String?;
      if (displayName != null && displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
    } catch (e) {
      debugPrint('⚠️  Failed to resolve inviter name: $e');
    }

    return 'A family member';
  }

  Future<String> _resolveBabyName({
    required DatabaseService databaseService,
    required String babyProfileId,
  }) async {
    final currentProfile = state.profile;
    if (currentProfile != null && currentProfile.id == babyProfileId) {
      final currentName = currentProfile.name.trim();
      if (currentName.isNotEmpty) {
        return currentName;
      }
    }

    try {
      final response = await databaseService
          .select(
            SupabaseTables.babyProfiles,
            columns: SupabaseTables.name,
          )
          .eq(SupabaseTables.id, babyProfileId)
          .maybeSingle();

      final babyName = response?[SupabaseTables.name] as String?;
      if (babyName != null && babyName.trim().isNotEmpty) {
        return babyName.trim();
      }
    } catch (e) {
      debugPrint('⚠️  Failed to resolve baby name: $e');
    }

    return 'your baby';
  }

  /// Revoke a pending invitation (owner only).
  Future<bool> revokeInvitation({
    required String invitationId,
    required String babyProfileId,
    required String currentUserId,
  }) async {
    final databaseService = ref.read(databaseServiceProvider);
    final isOwner =
        await _checkIsOwner(babyProfileId, currentUserId, databaseService);
    if (!isOwner) {
      debugPrint('⚠️  Only owners can revoke invitations');
      return false;
    }

    try {
      await databaseService.update(SupabaseTables.invitations, {
        SupabaseTables.status: InvitationStatus.revoked.toJson(),
        SupabaseTables.updatedAt: DateTime.now().toIso8601String(),
      }).eq(SupabaseTables.id, invitationId);

      await _loadInvitations(babyProfileId, databaseService);
      if (!ref.mounted) return false;

      debugPrint('✅ Invitation revoked');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to revoke invitation: $e');
      return false;
    }
  }

  /// Refresh profile
  Future<void> refresh(String babyProfileId, String currentUserId) async {
    await loadProfile(
      babyProfileId: babyProfileId,
      currentUserId: currentUserId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load profile from cache
  Future<BabyProfile?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return BabyProfile.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save profile to cache
  Future<void> _saveToCache(String babyProfileId, BabyProfile profile) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      await cacheService.put(
        cacheKey,
        profile.toJson(),
        ttlMinutes: PerformanceLimits.profileCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  bool _isValidEmail(String input) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input);
  }
}

/// Baby profile provider
///
/// Usage:
/// ```dart
/// final babyProfileState = ref.watch(babyProfileProvider);
/// final notifier = ref.read(babyProfileProvider.notifier);
/// await notifier.loadProfile(babyProfileId: 'abc', currentUserId: 'user123');
/// ```
final babyProfileProvider =
    NotifierProvider.autoDispose<BabyProfileNotifier, BabyProfileState>(
        BabyProfileNotifier.new);
