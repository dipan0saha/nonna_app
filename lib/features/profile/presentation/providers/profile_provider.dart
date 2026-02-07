import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/user_stats.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/storage_service.dart';

/// Profile Provider for managing user profile state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - User profile state management
/// - Edit mode handling
/// - Profile validation
/// - Save state tracking
/// - Avatar upload
///
/// Dependencies: DatabaseService, CacheService, StorageService, User model

/// Profile screen state model
class ProfileState {
  final User? profile;
  final UserStats? stats;
  final bool isLoading;
  final bool isSaving;
  final bool isEditMode;
  final String? error;
  final String? saveError;
  final bool saveSuccess;

  const ProfileState({
    this.profile,
    this.stats,
    this.isLoading = false,
    this.isSaving = false,
    this.isEditMode = false,
    this.error,
    this.saveError,
    this.saveSuccess = false,
  });

  ProfileState copyWith({
    User? profile,
    UserStats? stats,
    bool? isLoading,
    bool? isSaving,
    bool? isEditMode,
    String? error,
    String? saveError,
    bool? saveSuccess,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditMode: isEditMode ?? this.isEditMode,
      error: error,
      saveError: saveError,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

/// Profile Provider Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final DatabaseService _databaseService;
  final CacheService _cacheService;
  final StorageService _storageService;

  ProfileNotifier({
    required DatabaseService databaseService,
    required CacheService cacheService,
    required StorageService storageService,
  })  : _databaseService = databaseService,
        _cacheService = cacheService,
        _storageService = storageService,
        super(const ProfileState());

  // Configuration
  static const String _cacheKeyPrefix = 'user_profile';
  static const int _cacheTtlMinutes = 60;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load user profile
  Future<void> loadProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedProfile = await _loadFromCache(userId);
        if (cachedProfile != null) {
          state = state.copyWith(
            profile: cachedProfile,
            isLoading: false,
          );
          // Load stats in background
          _loadUserStats(userId);
          return;
        }
      }

      // Fetch from database
      final response = await _databaseService
          .select(SupabaseTables.profiles)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Profile not found');
      }

      final profile = User.fromJson(response as Map<String, dynamic>);

      // Save to cache
      await _saveToCache(userId, profile);

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );

      // Load stats
      await _loadUserStats(userId);

      debugPrint('✅ Loaded profile for user: $userId');
    } catch (e) {
      final errorMessage = 'Failed to load profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Load user stats
  Future<void> _loadUserStats(String userId) async {
    try {
      final response = await _databaseService
          .select(SupabaseTables.userStats)
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final stats = UserStats.fromJson(response as Map<String, dynamic>);
        state = state.copyWith(stats: stats);
        debugPrint('✅ Loaded user stats');
      }
    } catch (e) {
      debugPrint('⚠️  Failed to load user stats: $e');
    }
  }

  /// Enable edit mode
  void enterEditMode() {
    state = state.copyWith(isEditMode: true, saveError: null, saveSuccess: false);
    debugPrint('✅ Entered edit mode');
  }

  /// Cancel edit mode
  void cancelEdit() {
    state = state.copyWith(isEditMode: false, saveError: null, saveSuccess: false);
    debugPrint('✅ Cancelled edit mode');
  }

  /// Update profile
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isSaving: true, saveError: null, saveSuccess: false);

      // Validate
      if (displayName.trim().isEmpty) {
        throw Exception('Display name is required');
      }
      if (displayName.length > 100) {
        throw Exception('Display name must be 100 characters or less');
      }

      // Update in database
      final updateData = {
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await _databaseService
          .update(SupabaseTables.profiles, updateData)
          .eq('user_id', userId);

      // Reload profile
      await loadProfile(userId: userId, forceRefresh: true);

      state = state.copyWith(
        isSaving: false,
        isEditMode: false,
        saveSuccess: true,
      );

      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      final errorMessage = 'Failed to update profile: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isSaving: false,
        saveError: errorMessage,
        saveSuccess: false,
      );
    }
  }

  /// Upload avatar
  Future<String?> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      debugPrint('📤 Uploading avatar...');

      final storageKey = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final avatarUrl = await _storageService.uploadFile(
        filePath: filePath,
        storageKey: storageKey,
        bucket: 'avatars',
      );

      debugPrint('✅ Avatar uploaded: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload avatar: $e');
      return null;
    }
  }

  /// Toggle biometric
  Future<void> toggleBiometric({
    required String userId,
    required bool enabled,
  }) async {
    try {
      await _databaseService
          .update(SupabaseTables.profiles, {
            'biometric_enabled': enabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Reload profile
      await loadProfile(userId: userId, forceRefresh: true);

      debugPrint('✅ Biometric ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Failed to toggle biometric: $e');
      throw Exception('Failed to update biometric setting');
    }
  }

  /// Refresh profile
  Future<void> refresh(String userId) async {
    await loadProfile(userId: userId, forceRefresh: true);
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load profile from cache
  Future<User?> _loadFromCache(String userId) async {
    if (!_cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(userId);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return User.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save profile to cache
  Future<void> _saveToCache(String userId, User profile) async {
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(userId);
      await _cacheService.put(cacheKey, profile.toJson(), ttlMinutes: _cacheTtlMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String userId) {
    return '${_cacheKeyPrefix}_$userId';
  }
}

/// Profile provider
///
/// Usage:
/// ```dart
/// final profileState = ref.watch(profileProvider);
/// final notifier = ref.read(profileProvider.notifier);
/// await notifier.loadProfile(userId: 'abc');
/// ```
final profileProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final storageService = ref.watch(storageServiceProvider);

    return ProfileNotifier(
      databaseService: databaseService,
      cacheService: cacheService,
      storageService: storageService,
    );
  },
);
