import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/models/baby_membership.dart';
import '../../../../core/models/baby_profile.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/storage_service.dart';

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
}

/// Baby Profile Provider Notifier
class BabyProfileNotifier extends StateNotifier<BabyProfileState> {
  final DatabaseService _databaseService;
  final CacheService _cacheService;
  final StorageService _storageService;

  BabyProfileNotifier({
    required DatabaseService databaseService,
    required CacheService cacheService,
    required StorageService storageService,
  })  : _databaseService = databaseService,
        _cacheService = cacheService,
        _storageService = storageService,
        super(const BabyProfileState());

  // Configuration
  static const String _cacheKeyPrefix = 'baby_profile';
  static const int _cacheTtlMinutes = 60;

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

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedProfile = await _loadFromCache(babyProfileId);
        if (cachedProfile != null) {
          final isOwner = await _checkIsOwner(babyProfileId, currentUserId);
          state = state.copyWith(
            profile: cachedProfile,
            isLoading: false,
            isOwner: isOwner,
          );
          // Load memberships in background
          _loadMemberships(babyProfileId);
          return;
        }
      }

      // Fetch from database
      final response = await _databaseService
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyProfileId)
          .isNull(SupabaseTables.deletedAt)
          .maybeSingle();

      if (response == null) {
        throw Exception('Baby profile not found');
      }

      final profile = BabyProfile.fromJson(response as Map<String, dynamic>);

      // Check if current user is owner
      final isOwner = await _checkIsOwner(babyProfileId, currentUserId);

      // Save to cache
      await _saveToCache(babyProfileId, profile);

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isOwner: isOwner,
      );

      // Load memberships
      await _loadMemberships(babyProfileId);

      debugPrint('✅ Loaded baby profile: $babyProfileId');
    } catch (e) {
      final errorMessage = 'Failed to load baby profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Check if user is owner
  Future<bool> _checkIsOwner(String babyProfileId, String userId) async {
    try {
      final response = await _databaseService
          .select(SupabaseTables.babyMemberships)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .eq('user_id', userId)
          .eq('role', 'owner')
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('⚠️  Failed to check owner status: $e');
      return false;
    }
  }

  /// Load memberships
  Future<void> _loadMemberships(String babyProfileId) async {
    try {
      final response = await _databaseService
          .select(SupabaseTables.babyMemberships)
          .eq(SupabaseTables.babyProfileId, babyProfileId)
          .order('created_at', ascending: true);

      final memberships = (response as List)
          .map((json) => BabyMembership.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(memberships: memberships);
      debugPrint('✅ Loaded ${memberships.length} memberships');
    } catch (e) {
      debugPrint('⚠️  Failed to load memberships: $e');
    }
  }

  /// Enable edit mode
  void enterEditMode() {
    if (!state.isOwner) {
      debugPrint('⚠️  Only owners can edit baby profile');
      return;
    }
    state = state.copyWith(isEditMode: true, saveError: null, saveSuccess: false);
    debugPrint('✅ Entered edit mode');
  }

  /// Cancel edit mode
  void cancelEdit() {
    state = state.copyWith(isEditMode: false, saveError: null, saveSuccess: false);
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
      state = state.copyWith(isSaving: true, saveError: null, saveSuccess: false);

      // Validate
      if (name.trim().isEmpty) {
        throw Exception('Baby name is required');
      }

      // Create profile in database
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

      final response = await _databaseService
          .insert(SupabaseTables.babyProfiles, profileData)
          .select()
          .single();

      final profile = BabyProfile.fromJson(response as Map<String, dynamic>);

      // Create owner membership
      await _databaseService.insert(SupabaseTables.babyMemberships, {
        'baby_profile_id': profile.id,
        'user_id': userId,
        'role': 'owner',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(
        profile: profile,
        isSaving: false,
        saveSuccess: true,
        isOwner: true,
      );

      debugPrint('✅ Baby profile created: ${profile.id}');
      return profile;
    } catch (e) {
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
  }) async {
    if (!state.isOwner) {
      state = state.copyWith(saveError: 'Only owners can update baby profile');
      return;
    }

    try {
      state = state.copyWith(isSaving: true, saveError: null, saveSuccess: false);

      // Validate
      if (name.trim().isEmpty) {
        throw Exception('Baby name is required');
      }

      // Update in database
      final updateData = {
        'name': name,
        'expected_birth_date': expectedBirthDate?.toIso8601String(),
        'actual_birth_date': actualBirthDate?.toIso8601String(),
        'gender': gender?.toJson(),
        'profile_photo_url': profilePhotoUrl,
        'default_last_name_source': defaultLastNameSource,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _databaseService
          .update(SupabaseTables.babyProfiles, updateData)
          .eq('id', babyProfileId);

      // Reload profile
      final response = await _databaseService
          .select(SupabaseTables.babyProfiles)
          .eq('id', babyProfileId)
          .isNull(SupabaseTables.deletedAt)
          .single();

      final profile = BabyProfile.fromJson(response as Map<String, dynamic>);

      // Update cache
      await _saveToCache(babyProfileId, profile);

      state = state.copyWith(
        profile: profile,
        isSaving: false,
        isEditMode: false,
        saveSuccess: true,
      );

      debugPrint('✅ Baby profile updated successfully');
    } catch (e) {
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
      await _databaseService
          .update(SupabaseTables.babyProfiles, {
            'deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', babyProfileId);

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

      final storageKey = 'baby_profiles/$babyProfileId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final photoUrl = await _storageService.uploadFile(
        filePath: filePath,
        storageKey: storageKey,
        bucket: 'baby_profiles',
      );

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
      await _databaseService
          .delete(SupabaseTables.babyMemberships)
          .eq('id', membershipId);

      // Reload memberships
      await _loadMemberships(babyProfileId);

      debugPrint('✅ Follower removed');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to remove follower: $e');
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
    if (!_cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return BabyProfile.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save profile to cache
  Future<void> _saveToCache(String babyProfileId, BabyProfile profile) async {
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      await _cacheService.put(cacheKey, profile.toJson(), ttlMinutes: _cacheTtlMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
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
final babyProfileProvider = StateNotifierProvider.autoDispose<
    BabyProfileNotifier, BabyProfileState>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final storageService = ref.watch(storageServiceProvider);

    return BabyProfileNotifier(
      databaseService: databaseService,
      cacheService: cacheService,
      storageService: storageService,
    );
  },
);
