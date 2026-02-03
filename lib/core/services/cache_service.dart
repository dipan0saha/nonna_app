import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/owner_update_marker.dart';

/// Cache service for local data caching using Hive
/// 
/// Provides cache expiration (TTL), cache invalidation via owner_update_markers,
/// offline data access, and background sync
class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static const String _timestampKey = '_timestamp';

  Box<dynamic>? _cacheBox;
  Box<Map<dynamic, dynamic>>? _metadataBox;
  bool _isInitialized = false;

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize the cache service
  /// 
  /// Must be called before using the service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  CacheService already initialized');
      return;
    }

    try {
      await Hive.initFlutter();
      
      _cacheBox = await Hive.openBox(_cacheBoxName);
      _metadataBox = await Hive.openBox<Map>(_metadataBoxName);
      
      _isInitialized = true;
      
      debugPrint('✅ CacheService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing CacheService: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      await _metadataBox?.close();
      
      _cacheBox = null;
      _metadataBox = null;
      _isInitialized = false;
      
      debugPrint('✅ CacheService disposed');
    } catch (e) {
      debugPrint('❌ Error disposing CacheService: $e');
    }
  }

  // ==========================================
  // Cache Operations
  // ==========================================

  /// Save data to cache
  /// 
  /// [key] Cache key
  /// [data] Data to cache
  /// [ttlMinutes] Time-to-live in minutes (null = no expiration)
  Future<void> put(
    String key,
    dynamic data, {
    int? ttlMinutes,
  }) async {
    _ensureInitialized();

    try {
      await _cacheBox!.put(key, data);
      
      // Store metadata
      final metadata = <String, dynamic>{
        _timestampKey: DateTime.now().millisecondsSinceEpoch,
        if (ttlMinutes != null) 'ttl_minutes': ttlMinutes,
      };
      
      await _metadataBox!.put(key, metadata);
      
      debugPrint('✅ Cached data for key: $key');
    } catch (e) {
      debugPrint('❌ Error caching data for key $key: $e');
      rethrow;
    }
  }

  /// Get data from cache
  /// 
  /// [key] Cache key
  /// Returns cached data or null if not found or expired
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    try {
      // Check if key exists
      if (!_cacheBox!.containsKey(key)) {
        return null;
      }

      // Check if expired
      if (await _isExpired(key)) {
        await delete(key);
        return null;
      }

      final data = _cacheBox!.get(key);
      return data as T?;
    } catch (e) {
      debugPrint('❌ Error getting cached data for key $key: $e');
      return null;
    }
  }

  /// Delete data from cache
  /// 
  /// [key] Cache key
  Future<void> delete(String key) async {
    _ensureInitialized();

    try {
      await _cacheBox!.delete(key);
      await _metadataBox!.delete(key);
      
      debugPrint('✅ Deleted cache for key: $key');
    } catch (e) {
      debugPrint('❌ Error deleting cache for key $key: $e');
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    _ensureInitialized();

    try {
      await _cacheBox!.clear();
      await _metadataBox!.clear();
      
      debugPrint('✅ Cleared all cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Check if cache key exists and is not expired
  /// 
  /// [key] Cache key
  Future<bool> has(String key) async {
    _ensureInitialized();

    try {
      if (!_cacheBox!.containsKey(key)) {
        return false;
      }

      if (await _isExpired(key)) {
        await delete(key);
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking cache for key $key: $e');
      return false;
    }
  }

  // ==========================================
  // Cache Invalidation
  // ==========================================

  /// Invalidate cache based on owner update marker
  /// 
  /// [babyProfileId] Baby profile ID
  /// [ownerUpdateMarker] Latest owner update marker
  Future<void> invalidateByOwnerUpdate(
    String babyProfileId,
    OwnerUpdateMarker ownerUpdateMarker,
  ) async {
    _ensureInitialized();

    try {
      final prefix = 'baby_${babyProfileId}_';
      final keysToDelete = <String>[];

      // Find all keys for this baby profile
      for (final key in _cacheBox!.keys) {
        if (key.toString().startsWith(prefix)) {
          // Check if cache is older than owner update
          final metadata = _metadataBox!.get(key);
          if (metadata != null) {
            final cachedTimestamp = metadata[_timestampKey] as int?;
            if (cachedTimestamp != null) {
              final cachedDate = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
              if (cachedDate.isBefore(ownerUpdateMarker.tilesLastUpdatedAt)) {
                keysToDelete.add(key.toString());
              }
            }
          }
        }
      }

      // Delete invalid cache entries
      for (final key in keysToDelete) {
        await delete(key);
      }

      debugPrint('✅ Invalidated ${keysToDelete.length} cache entries for baby profile $babyProfileId');
    } catch (e) {
      debugPrint('❌ Error invalidating cache: $e');
    }
  }

  /// Invalidate all cache for a baby profile
  /// 
  /// [babyProfileId] Baby profile ID
  Future<void> invalidateByBabyProfile(String babyProfileId) async {
    _ensureInitialized();

    try {
      final prefix = 'baby_${babyProfileId}_';
      final keysToDelete = <String>[];

      for (final key in _cacheBox!.keys) {
        if (key.toString().startsWith(prefix)) {
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await delete(key);
      }

      debugPrint('✅ Invalidated ${keysToDelete.length} cache entries for baby profile $babyProfileId');
    } catch (e) {
      debugPrint('❌ Error invalidating cache for baby profile: $e');
    }
  }

  // ==========================================
  // Cache Management
  // ==========================================

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    _ensureInitialized();

    try {
      // This is an approximation
      return _cacheBox!.length * 1024; // Rough estimate
    } catch (e) {
      debugPrint('❌ Error getting cache size: $e');
      return 0;
    }
  }

  /// Clean up expired cache entries
  Future<void> cleanupExpired() async {
    _ensureInitialized();

    try {
      final keysToDelete = <String>[];

      for (final key in _cacheBox!.keys) {
        if (await _isExpired(key.toString())) {
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await delete(key);
      }

      debugPrint('✅ Cleaned up ${keysToDelete.length} expired cache entries');
    } catch (e) {
      debugPrint('❌ Error cleaning up expired cache: $e');
    }
  }

  /// Get all cache keys
  List<String> getAllKeys() {
    _ensureInitialized();
    return _cacheBox!.keys.map((k) => k.toString()).toList();
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  /// Check if cache entry is expired
  Future<bool> _isExpired(String key) async {
    final metadata = _metadataBox!.get(key);
    if (metadata == null) return false;

    final timestamp = metadata[_timestampKey] as int?;
    final ttlMinutes = metadata['ttl_minutes'] as int?;

    if (timestamp == null || ttlMinutes == null) {
      return false;
    }

    final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expiryDate = cachedDate.add(Duration(minutes: ttlMinutes));

    return DateTime.now().isAfter(expiryDate);
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('CacheService not initialized. Call initialize() first.');
    }
  }
}
