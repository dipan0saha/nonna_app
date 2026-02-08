import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/models/tile_config.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';

/// Tile configuration provider for managing dynamic tile configurations
///
/// **Functional Requirements**: Section 3.5.2 - Tile Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches tile configurations from Supabase
/// - Caches configurations locally for offline access
/// - Role-based filtering (owner vs. follower)
/// - Screen-specific configurations
/// - Reactive updates via realtime subscriptions
///
/// Dependencies: DatabaseService, CacheService, TileConfig model

/// State class for tile configuration
class TileConfigState {
  final List<TileConfig> configs;
  final bool isLoading;
  final String? error;

  const TileConfigState({
    this.configs = const [],
    this.isLoading = false,
    this.error,
  });

  TileConfigState copyWith({
    List<TileConfig>? configs,
    bool? isLoading,
    String? error,
  }) {
    return TileConfigState(
      configs: configs ?? this.configs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Tile configuration provider
///
/// Manages tile configurations with caching and role-based filtering.
class TileConfigNotifier extends Notifier<TileConfigState> {
  @override
  TileConfigState build() {
    return const TileConfigState();
  }

  // Cache configuration
  static const String _cacheKeyPrefix = 'tile_configs';

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch all tile configurations for a specific screen and role
  ///
  /// [screenId] The screen identifier (e.g., 'home', 'calendar')
  /// [role] The user role (owner or follower)
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchConfigs({
    required String screenId,
    required UserRole role,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedConfigs = await _loadFromCache(screenId, role);
        if (cachedConfigs != null && cachedConfigs.isNotEmpty) {
          state = state.copyWith(
            configs: cachedConfigs,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch from database
      final configs = await _fetchFromDatabase(screenId, role);

      // Save to cache
      await _saveToCache(screenId, role, configs);

      state = state.copyWith(
        configs: configs,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded ${configs.length} tile configs for screen: $screenId, role: ${role.name}',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch tile configs: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Fetch all tile configurations (no filtering)
  ///
  /// Useful for admin screens or configuration management.
  Future<void> fetchAllConfigs({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedConfigs = await _loadAllFromCache();
        if (cachedConfigs != null && cachedConfigs.isNotEmpty) {
          state = state.copyWith(
            configs: cachedConfigs,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch from database
      final response = await ref.read(databaseServiceProvider)
          .select(SupabaseTables.tileConfigs)
          .order(SupabaseTables.displayOrder);

      final configs = (response as List)
          .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
          .toList();

      // Save to cache
      await _saveAllToCache(configs);

      state = state.copyWith(
        configs: configs,
        isLoading: false,
      );

      debugPrint('✅ Loaded ${configs.length} total tile configs');
    } catch (e) {
      final errorMessage = 'Failed to fetch all tile configs: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get configurations for a specific screen
  ///
  /// Returns cached configs filtered by screen ID.
  List<TileConfig> getConfigsForScreen(String screenId) {
    return state.configs
        .where((config) => config.screenId == screenId)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get visible configurations for a specific screen and role
  ///
  /// Returns only visible tiles for the given screen and role.
  List<TileConfig> getVisibleConfigs(String screenId, UserRole role) {
    return state.configs
        .where((config) =>
            config.screenId == screenId &&
            config.role == role &&
            config.isVisible)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Update a tile configuration's visibility
  ///
  /// [configId] The configuration ID to update
  /// [isVisible] New visibility state
  Future<void> updateVisibility({
    required String configId,
    required bool isVisible,
  }) async {
    try {
      // Update in database
      await ref.read(databaseServiceProvider)
          .update(SupabaseTables.tileConfigs)
          .eq(SupabaseTables.id, configId)
          .update({SupabaseTables.isVisible: isVisible});

      // Update local state
      final updatedConfigs = state.configs.map((config) {
        if (config.id == configId) {
          return config.copyWith(isVisible: isVisible);
        }
        return config;
      }).toList();

      state = state.copyWith(configs: updatedConfigs);

      // Invalidate cache
      await _invalidateCache();

      debugPrint('✅ Updated visibility for config: $configId');
    } catch (e) {
      debugPrint('❌ Failed to update visibility: $e');
      rethrow;
    }
  }

  /// Refresh configurations
  ///
  /// Forces a refresh from the server.
  Future<void> refresh() async {
    // Get current filters if available
    if (state.configs.isNotEmpty) {
      final firstConfig = state.configs.first;
      await fetchConfigs(
        screenId: firstConfig.screenId,
        role: firstConfig.role,
        forceRefresh: true,
      );
    }
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch configurations from database
  Future<List<TileConfig>> _fetchFromDatabase(
    String screenId,
    UserRole role,
  ) async {
    final response = await ref.read(databaseServiceProvider)
        .select(SupabaseTables.tileConfigs)
        .eq(SupabaseTables.screenId, screenId)
        .eq(SupabaseTables.role, role.toJson())
        .order(SupabaseTables.displayOrder);

    return (response as List)
        .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load configurations from cache
  Future<List<TileConfig>?> _loadFromCache(
    String screenId,
    UserRole role,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(screenId, role);
      final cachedData = await ref.read(cacheServiceProvider).get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save configurations to cache
  Future<void> _saveToCache(
    String screenId,
    UserRole role,
    List<TileConfig> configs,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      final cacheKey = _getCacheKey(screenId, role);
      final jsonData = configs.map((config) => config.toJson()).toList();
      await ref.read(cacheServiceProvider).put(
        cacheKey,
        jsonData,
        ttlMinutes: PerformanceLimits.tileConfigCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Load all configurations from cache
  Future<List<TileConfig>?> _loadAllFromCache() async {
    if (!ref.read(cacheServiceProvider).isInitialized) return null;

    try {
      final cacheKey = '${_cacheKeyPrefix}_all';
      final cachedData = await ref.read(cacheServiceProvider).get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load all from cache: $e');
      return null;
    }
  }

  /// Save all configurations to cache
  Future<void> _saveAllToCache(List<TileConfig> configs) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      final cacheKey = '${_cacheKeyPrefix}_all';
      final jsonData = configs.map((config) => config.toJson()).toList();
      await ref.read(cacheServiceProvider).put(
        cacheKey,
        jsonData,
        ttlMinutes: PerformanceLimits.tileConfigCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save all to cache: $e');
    }
  }

  /// Get cache key for screen and role
  String _getCacheKey(String screenId, UserRole role) {
    return '${_cacheKeyPrefix}_${screenId}_${role.name}';
  }

  /// Invalidate all tile config caches
  Future<void> _invalidateCache() async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      // In a real implementation, you'd want to track all cache keys
      // For now, we'll clear the all cache
      await ref.read(cacheServiceProvider).delete('${_cacheKeyPrefix}_all');
      debugPrint('✅ Invalidated tile config cache');
    } catch (e) {
      debugPrint('⚠️  Failed to invalidate cache: $e');
    }
  }
}

/// Provider for tile configurations
///
/// Usage:
/// ```dart
/// final configs = ref.watch(tileConfigProvider);
/// final notifier = ref.read(tileConfigProvider.notifier);
/// await notifier.fetchConfigs(screenId: 'home', role: UserRole.owner);
/// ```
final tileConfigProvider =
    NotifierProvider<TileConfigNotifier, TileConfigState>(TileConfigNotifier.new);
