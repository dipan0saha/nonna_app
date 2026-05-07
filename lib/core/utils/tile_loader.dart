import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/performance_limits.dart';
import '../constants/supabase_tables.dart';
import '../di/providers.dart';
import '../enums/user_role.dart';
import '../models/tile_config.dart';
import '../services/cache_service.dart';

/// Utility class for loading tile configurations
///
/// **Purpose**: Decouple homeScreenProvider from tileConfigProvider
/// **Issue #3.21**: Fix tight coupling between providers
///
/// This utility provides a shared way to load tile configurations
/// without creating direct provider-to-provider dependencies.
class TileLoader {
  // Private constructor to prevent instantiation
  TileLoader._();

  static const Set<String> _supportedComponentNames = {
    'RecentPhotosTile',
    'UpcomingEventsTile',
    'RegistryHighlightsTile',
    'RegistryListTile',
    'CountdownTile',
    'ChecklistTile',
    'ActivityListTile',
    'GalleryFavoritesTile',
    'InvitesStatusTile',
    'NewFollowersTile',
    'NotificationsTile',
    'RecentPurchasesTile',
    'RsvpTasksTile',
    'StorageUsageTile',
    'SystemAnnouncementsTile',
    'NameSuggestionsTile',
    'PredictionVotesTile',
  };

  /// Cache configuration
  static const String _cacheKeyPrefix = 'tile_configs_v3';

  /// Load tile configurations for a specific screen
  ///
  /// This method uses an edge-first strategy via `tile-configs`,
  /// falling back to direct database joins if the function fails.
  ///
  /// [ref] WidgetRef for accessing providers
  /// [babyProfileId] Baby profile used for content-aware filtering
  /// [screenId] The screen identifier (e.g., 'home', 'calendar')
  /// [role] The user role (owner or follower)
  /// [forceRefresh] Whether to bypass cache
  ///
  /// Returns: List of enabled and sorted tile configurations
  static Future<List<TileConfig>> loadForScreen({
    required Ref ref,
    required String babyProfileId,
    required String screenId,
    required UserRole role,
    bool forceRefresh = false,
  }) async {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final supabaseClient = ref.watch(supabaseClientProvider);

    // Try cache first
    final cacheKey = _getCacheKey(
      babyProfileId: babyProfileId,
      screenId: screenId,
      role: role,
    );
    if (!forceRefresh) {
      final cached = await cacheService.get(cacheKey);

      if (cached != null) {
        try {
          final configs = (cached as List)
              .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
              .toList();
          return _filterAndSortConfigs(configs);
        } catch (e) {
          // Cache corrupted, continue to fetch from DB
        }
      }
    }

    final edgeConfigs = await _fetchFromEdgeFunction(
      supabaseClient: supabaseClient,
      babyProfileId: babyProfileId,
      screenId: screenId,
      role: role,
    );

    if (edgeConfigs != null) {
      await cacheService.put(
        cacheKey,
        edgeConfigs.map((c) => c.toJson()).toList(),
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
      return _filterAndSortConfigs(edgeConfigs);
    }

    // Fetch from database using inner join on screens table and tile_definitions table
    // screenId is actually screen_name (e.g. 'home', 'calendar')
    final response = await databaseService
        .select(SupabaseTables.tileConfigs,
            columns:
                '*, screens!inner(screen_name), tile_definitions!inner(tile_type)')
        .eq('screens.screen_name', screenId)
        .eq('role', role.name);

    final configs = (response as List)
        .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
        .toList();

    // Cache the results using standardized TTL from PerformanceLimits
    await cacheService.put(
      cacheKey,
      configs.map((c) => c.toJson()).toList(),
      ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
    );

    return _filterAndSortConfigs(configs);
  }

  static Future<List<TileConfig>?> _fetchFromEdgeFunction({
    required SupabaseClient supabaseClient,
    required String babyProfileId,
    required String screenId,
    required UserRole role,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'tile-configs',
        body: {
          'babyProfileId': babyProfileId,
          'userRole': role.name,
          'screenName': screenId,
        },
      );

      if (response.status < 200 || response.status >= 300) {
        return null;
      }

      final payload = response.data;
      List? tilesJson;
      if (payload is List) {
        tilesJson = payload;
      } else if (payload is Map && payload['tiles'] is List) {
        tilesJson = payload['tiles'] as List;
      }

      if (tilesJson == null) return null;

      return tilesJson
          .whereType<Map>()
          .map((json) => TileConfig.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      // Fail open to DB query path if the edge function is unavailable.
      return null;
    }
  }

  /// Filter enabled tiles and sort by order
  static List<TileConfig> _filterAndSortConfigs(List<TileConfig> configs) {
    return configs
        .where(
          (config) =>
              config.isVisible &&
              config.componentName != null &&
              _supportedComponentNames.contains(config.componentName),
        )
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Generate cache key for screen and role
  static String _getCacheKey({
    required String babyProfileId,
    required String screenId,
    required UserRole role,
  }) {
    return '${_cacheKeyPrefix}_${babyProfileId}_${screenId}_${role.name}';
  }

  /// Clear cache for a specific screen
  static Future<void> clearCache({
    required CacheService cacheService,
    required String babyProfileId,
    required String screenId,
    required UserRole role,
  }) async {
    final cacheKey = _getCacheKey(
      babyProfileId: babyProfileId,
      screenId: screenId,
      role: role,
    );
    await cacheService.delete(cacheKey);
  }

  /// Clear all tile caches
  static Future<void> clearAllCaches({
    required CacheService cacheService,
  }) async {
    // Note: This would require CacheService to support prefix-based deletion
    // For now, we'd need to clear specific known combinations
    for (final screen in ['home', 'calendar', 'gallery', 'registry']) {
      for (final role in UserRole.values) {
        await clearCache(
          cacheService: cacheService,
          babyProfileId: '*',
          screenId: screen,
          role: role,
        );
      }
    }
  }
}
