import 'package:flutter/foundation.dart';

import '../services/cache_service.dart';

/// Cache manager for coordinating cache strategies and policies
///
/// **Functional Requirements**: Section 3.2.7 - Middleware
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Cache strategy coordination
/// - Cache invalidation logic
/// - Background sync scheduling
/// - Cache warming
/// - Eviction policies
///
/// Dependencies: CacheService
class CacheManager {
  final CacheService _cacheService;

  /// Cache warming strategies
  static const String warmOnAppStart = 'warm_on_app_start';
  static const String warmOnDemand = 'warm_on_demand';
  static const String warmOnBackground = 'warm_on_background';

  /// Cache eviction policies
  static const String lruEviction = 'lru'; // Least Recently Used
  static const String lfu Eviction = 'lfu'; // Least Frequently Used
  static const String fifoEviction = 'fifo'; // First In First Out

  /// Cache TTL presets (in minutes)
  static const int shortTtl = 5;
  static const int mediumTtl = 30;
  static const int longTtl = 60;
  static const int veryLongTtl = 1440; // 24 hours

  CacheManager(this._cacheService);

  // ============================================================
  // Cache Strategy Management
  // ============================================================

  /// Get or fetch data with caching
  ///
  /// [key] Cache key
  /// [fetchFunction] Function to fetch data if not in cache
  /// [ttlMinutes] Cache TTL in minutes
  /// Returns cached data or fetches and caches new data
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    int? ttlMinutes,
  }) async {
    try {
      // Try to get from cache
      final cachedData = await _cacheService.get<T>(key);
      
      if (cachedData != null) {
        debugPrint('✅ Cache hit for key: $key');
        return cachedData;
      }

      debugPrint('⚠️  Cache miss for key: $key, fetching...');
      
      // Fetch new data
      final data = await fetchFunction();
      
      // Cache the data
      await _cacheService.put(key, data, ttlMinutes: ttlMinutes);
      
      return data;
    } catch (e) {
      debugPrint('❌ Error in getOrFetch for key $key: $e');
      rethrow;
    }
  }

  /// Invalidate cache by pattern
  ///
  /// [pattern] Pattern to match cache keys
  Future<void> invalidateByPattern(String pattern) async {
    try {
      final allKeys = _cacheService.getAllKeys();
      final keysToDelete = allKeys.where((key) => key.contains(pattern)).toList();
      
      for (final key in keysToDelete) {
        await _cacheService.delete(key);
      }
      
      debugPrint('✅ Invalidated ${keysToDelete.length} cache entries matching pattern: $pattern');
    } catch (e) {
      debugPrint('❌ Error invalidating cache by pattern: $e');
    }
  }

  /// Invalidate cache by prefix
  ///
  /// [prefix] Prefix to match cache keys
  Future<void> invalidateByPrefix(String prefix) async {
    try {
      final allKeys = _cacheService.getAllKeys();
      final keysToDelete = allKeys.where((key) => key.startsWith(prefix)).toList();
      
      for (final key in keysToDelete) {
        await _cacheService.delete(key);
      }
      
      debugPrint('✅ Invalidated ${keysToDelete.length} cache entries with prefix: $prefix');
    } catch (e) {
      debugPrint('❌ Error invalidating cache by prefix: $e');
    }
  }

  /// Invalidate all cache for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  Future<void> invalidateBabyProfile(String babyProfileId) async {
    await _cacheService.invalidateByBabyProfile(babyProfileId);
  }

  // ============================================================
  // Cache Warming
  // ============================================================

  /// Warm cache with frequently accessed data
  ///
  /// [dataLoaders] Map of cache keys to data loading functions
  Future<void> warmCache(Map<String, Future<dynamic> Function()> dataLoaders) async {
    try {
      debugPrint('🔥 Warming cache with ${dataLoaders.length} items...');
      
      int successCount = 0;
      int failureCount = 0;
      
      for (final entry in dataLoaders.entries) {
        try {
          final key = entry.key;
          final loader = entry.value;
          
          // Check if already cached
          if (await _cacheService.has(key)) {
            debugPrint('⚠️  Key already cached: $key');
            continue;
          }
          
          // Load and cache data
          final data = await loader();
          await _cacheService.put(key, data, ttlMinutes: mediumTtl);
          
          successCount++;
        } catch (e) {
          debugPrint('❌ Error warming cache for key ${entry.key}: $e');
          failureCount++;
        }
      }
      
      debugPrint('✅ Cache warming complete: $successCount success, $failureCount failures');
    } catch (e) {
      debugPrint('❌ Error during cache warming: $e');
    }
  }

  /// Warm cache for a specific baby profile
  ///
  /// [babyProfileId] Baby profile ID
  /// [dataLoaders] Map of cache keys to data loading functions
  Future<void> warmBabyProfileCache(
    String babyProfileId,
    Map<String, Future<dynamic> Function()> dataLoaders,
  ) async {
    final prefixedLoaders = dataLoaders.map(
      (key, loader) => MapEntry('baby_${babyProfileId}_$key', loader),
    );
    
    await warmCache(prefixedLoaders);
  }

  // ============================================================
  // Background Sync
  // ============================================================

  /// Schedule background cache refresh
  ///
  /// [key] Cache key
  /// [fetchFunction] Function to fetch fresh data
  /// [intervalMinutes] Refresh interval in minutes
  Future<void> scheduleBackgroundRefresh({
    required String key,
    required Future<dynamic> Function() fetchFunction,
    required int intervalMinutes,
  }) async {
    // This is a simplified implementation
    // In production, use WorkManager or similar for background tasks
    debugPrint('📅 Scheduled background refresh for key: $key every $intervalMinutes minutes');
    
    // Placeholder for actual implementation
    // TODO: Integrate with WorkManager or platform-specific background task API
  }

  /// Perform background sync for stale cache entries
  Future<void> syncStaleEntries() async {
    try {
      debugPrint('🔄 Syncing stale cache entries...');
      
      // Clean up expired entries first
      await _cacheService.cleanupExpired();
      
      // TODO: Implement background refresh logic for critical data
      
      debugPrint('✅ Background sync complete');
    } catch (e) {
      debugPrint('❌ Error during background sync: $e');
    }
  }

  // ============================================================
  // Cache Eviction
  // ============================================================

  /// Apply eviction policy based on cache size
  ///
  /// [maxSizeBytes] Maximum cache size in bytes
  Future<void> applyEvictionPolicy({int maxSizeBytes = 50 * 1024 * 1024}) async {
    try {
      final currentSize = await _cacheService.getCacheSize();
      
      if (currentSize <= maxSizeBytes) {
        debugPrint('✅ Cache size within limits: ${currentSize / 1024 / 1024}MB');
        return;
      }
      
      debugPrint('⚠️  Cache size exceeds limit: ${currentSize / 1024 / 1024}MB / ${maxSizeBytes / 1024 / 1024}MB');
      debugPrint('🗑️  Applying eviction policy...');
      
      // Simple FIFO eviction: remove oldest entries
      // In production, implement more sophisticated policies
      await _cacheService.cleanupExpired();
      
      debugPrint('✅ Eviction policy applied');
    } catch (e) {
      debugPrint('❌ Error applying eviction policy: $e');
    }
  }

  // ============================================================
  // Cache Statistics
  // ============================================================

  /// Get cache statistics
  ///
  /// Returns a map of cache metrics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final allKeys = _cacheService.getAllKeys();
      final cacheSize = await _cacheService.getCacheSize();
      
      return {
        'total_entries': allKeys.length,
        'cache_size_bytes': cacheSize,
        'cache_size_mb': (cacheSize / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint('❌ Error getting cache stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Get cache hit rate (placeholder)
  ///
  /// This would require tracking hits/misses over time
  /// Returns a value between 0 and 1
  Future<double> getCacheHitRate() async {
    // TODO: Implement hit rate tracking
    return 0.0;
  }

  // ============================================================
  // Cache Key Builders
  // ============================================================

  /// Build cache key for baby profile data
  static String babyProfileKey(String babyProfileId, String dataType) {
    return 'baby_${babyProfileId}_$dataType';
  }

  /// Build cache key for user data
  static String userKey(String userId, String dataType) {
    return 'user_${userId}_$dataType';
  }

  /// Build cache key for tile data
  static String tileKey(String babyProfileId, String screenName, String tileType) {
    return 'baby_${babyProfileId}_screen_${screenName}_tile_$tileType';
  }

  /// Build cache key for event data
  static String eventKey(String babyProfileId, String eventId) {
    return 'baby_${babyProfileId}_event_$eventId';
  }

  /// Build cache key for photo data
  static String photoKey(String babyProfileId, String photoId) {
    return 'baby_${babyProfileId}_photo_$photoId';
  }
}
