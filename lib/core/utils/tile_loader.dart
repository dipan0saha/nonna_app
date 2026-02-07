import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/supabase_tables.dart';
import '../di/providers.dart';
import '../enums/user_role.dart';
import '../models/tile_config.dart';
import '../services/cache_service.dart';
import '../services/database_service.dart';

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

  /// Cache configuration
  static const String _cacheKeyPrefix = 'tile_configs';
  static const int _cacheTtlMinutes = 30; // 30 minutes for consistency

  /// Load tile configurations for a specific screen
  ///
  /// This method loads tiles directly from the database service,
  /// avoiding the need to depend on tileConfigProvider.
  ///
  /// [ref] WidgetRef for accessing providers
  /// [screenId] The screen identifier (e.g., 'home', 'calendar')
  /// [role] The user role (owner or follower)
  /// [forceRefresh] Whether to bypass cache
  ///
  /// Returns: List of enabled and sorted tile configurations
  static Future<List<TileConfig>> loadForScreen({
    required Ref ref,
    required String screenId,
    required UserRole role,
    bool forceRefresh = false,
  }) async {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);

    // Try cache first
    if (!forceRefresh) {
      final cacheKey = _getCacheKey(screenId, role);
      final cached = await cacheService.get<List<Map<String, dynamic>>>(cacheKey);
      
      if (cached != null) {
        try {
          final configs = cached.map((json) => TileConfig.fromJson(json)).toList();
          return _filterAndSortConfigs(configs);
        } catch (e) {
          // Cache corrupted, continue to fetch from DB
        }
      }
    }

    // Fetch from database
    final query = databaseService
        .from(SupabaseTables.tileConfigs)
        .select()
        .eq('screen_id', screenId)
        .eq('role', role.name);

    final response = await query as List<dynamic>;
    final configs = response.map((json) => TileConfig.fromJson(json as Map<String, dynamic>)).toList();

    // Cache the results
    final cacheKey = _getCacheKey(screenId, role);
    await cacheService.set(
      cacheKey,
      configs.map((c) => c.toJson()).toList(),
      ttl: Duration(minutes: _cacheTtlMinutes),
    );

    return _filterAndSortConfigs(configs);
  }

  /// Filter enabled tiles and sort by order
  static List<TileConfig> _filterAndSortConfigs(List<TileConfig> configs) {
    return configs
        .where((config) => config.isEnabled)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Generate cache key for screen and role
  static String _getCacheKey(String screenId, UserRole role) {
    return '${_cacheKeyPrefix}_${screenId}_${role.name}';
  }

  /// Clear cache for a specific screen
  static Future<void> clearCache({
    required CacheService cacheService,
    required String screenId,
    required UserRole role,
  }) async {
    final cacheKey = _getCacheKey(screenId, role);
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
          screenId: screen,
          role: role,
        );
      }
    }
  }
}
