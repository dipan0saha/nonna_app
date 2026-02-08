import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'local_storage_service.dart';
import 'supabase_service.dart';

/// Abstract interface for persistence strategies
///
/// **Functional Requirements**: Section 3.5.5 - State Persistence
/// Reference: docs/Core_development_component_identification.md
///
/// Defines persistence strategy interface:
/// - Save/load/delete operations
/// - TTL (Time-To-Live) management
/// - Eviction policies
///
/// Implementations:
/// - MemoryPersistenceStrategy: In-memory cache (fastest)
/// - DiskPersistenceStrategy: Local disk storage (persistent)
/// - SupabasePersistenceStrategy: Remote cloud storage (sync across devices)
///
/// Dependencies: CacheService, LocalStorageService, SupabaseService
abstract class PersistenceStrategy {
  /// Save data with optional TTL
  Future<void> save(String key, Map<String, dynamic> data, {Duration? ttl});

  /// Load data by key
  Future<Map<String, dynamic>?> load(String key);

  /// Delete data by key
  Future<void> delete(String key);

  /// Check if key exists
  Future<bool> has(String key);

  /// Clear all data
  Future<void> clear();

  /// Get all keys
  Future<List<String>> getAllKeys();
}

/// In-memory persistence strategy
///
/// Fastest strategy but data is lost when app closes.
/// Ideal for temporary state that doesn't need to persist across app restarts.
class MemoryPersistenceStrategy implements PersistenceStrategy {
  final Map<String, _CacheEntry> _cache = {};

  @override
  Future<void> save(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    final expiresAt = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _CacheEntry(data, expiresAt);
    debugPrint('💾 Memory: Saved $key (TTL: ${ttl?.inMinutes}min)');
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    final entry = _cache[key];
    if (entry == null) {
      debugPrint('💾 Memory: $key not found');
      return null;
    }

    // Check if expired
    if (entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!)) {
      _cache.remove(key);
      debugPrint('💾 Memory: $key expired');
      return null;
    }

    debugPrint('💾 Memory: Loaded $key');
    return entry.data;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
    debugPrint('💾 Memory: Deleted $key');
  }

  @override
  Future<bool> has(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    // Check if expired
    if (entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    debugPrint('💾 Memory: Cleared all data');
  }

  @override
  Future<List<String>> getAllKeys() async {
    // Remove expired entries
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      return entry.expiresAt != null && now.isAfter(entry.expiresAt!);
    });

    return _cache.keys.toList();
  }

  /// Remove expired entries
  void evict() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cache.forEach((key, entry) {
      if (entry.expiresAt != null && now.isAfter(entry.expiresAt!)) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('💾 Memory: Evicted ${expiredKeys.length} expired entries');
    }
  }
}

/// Disk persistence strategy using LocalStorageService
///
/// Data persists across app restarts.
/// Slower than memory but provides offline persistence.
class DiskPersistenceStrategy implements PersistenceStrategy {
  final LocalStorageService _localStorage;
  static const String _keyPrefix = 'state_';
  static const String _ttlSuffix = '_ttl';

  DiskPersistenceStrategy(this._localStorage);

  @override
  Future<void> save(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    final storageKey = _keyPrefix + key;
    final jsonData = jsonEncode(data);

    await _localStorage.setString(storageKey, jsonData);

    if (ttl != null) {
      final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _localStorage.setInt(storageKey + _ttlSuffix, expiresAt);
    }

    debugPrint('💾 Disk: Saved $key (TTL: ${ttl?.inMinutes}min)');
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    final storageKey = _keyPrefix + key;
    final jsonData = _localStorage.getString(storageKey);

    if (jsonData == null) {
      debugPrint('💾 Disk: $key not found');
      return null;
    }

    // Check TTL
    final ttl = _localStorage.getInt(storageKey + _ttlSuffix);
    if (ttl != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(ttl);
      if (DateTime.now().isAfter(expiresAt)) {
        await delete(key);
        debugPrint('💾 Disk: $key expired');
        return null;
      }
    }

    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      debugPrint('💾 Disk: Loaded $key');
      return data;
    } catch (e) {
      debugPrint('❌ Disk: Error parsing $key: $e');
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    final storageKey = _keyPrefix + key;
    await _localStorage.remove(storageKey);
    await _localStorage.remove(storageKey + _ttlSuffix);
    debugPrint('💾 Disk: Deleted $key');
  }

  @override
  Future<bool> has(String key) async {
    final storageKey = _keyPrefix + key;
    final jsonData = _localStorage.getString(storageKey);

    if (jsonData == null) return false;

    // Check TTL
    final ttl = _localStorage.getInt(storageKey + _ttlSuffix);
    if (ttl != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(ttl);
      if (DateTime.now().isAfter(expiresAt)) {
        await delete(key);
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> clear() async {
    final keys = await getAllKeys();
    for (final key in keys) {
      await delete(key);
    }
    debugPrint('💾 Disk: Cleared all data');
  }

  @override
  Future<List<String>> getAllKeys() async {
    final allKeys = _localStorage.getAllKeys();
    return allKeys
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .toList();
  }
}

/// Supabase persistence strategy for cloud sync
///
/// Data syncs across devices.
/// Slowest strategy but provides cross-device synchronization.
/// Requires authentication and network connection.
class SupabasePersistenceStrategy implements PersistenceStrategy {
  final SupabaseService _supabase;
  static const String _tableName = 'user_state_persistence';

  SupabasePersistenceStrategy(this._supabase);

  @override
  Future<void> save(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        debugPrint('⚠️  Supabase: Cannot save $key - user not authenticated');
        return;
      }

      final expiresAt = ttl != null
          ? DateTime.now().add(ttl).toIso8601String()
          : null;

      final payload = {
        'user_id': userId,
        'key': key,
        'data': data,
        'expires_at': expiresAt,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert - insert or update if exists
      await _supabase.client
          .from(_tableName)
          .upsert(payload, onConflict: 'user_id,key');

      debugPrint('💾 Supabase: Saved $key (TTL: ${ttl?.inMinutes}min)');
    } catch (e) {
      debugPrint('❌ Supabase: Error saving $key: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        debugPrint('⚠️  Supabase: Cannot load $key - user not authenticated');
        return null;
      }

      final response = await _supabase.client
          .from(_tableName)
          .select('data, expires_at')
          .eq('user_id', userId)
          .eq('key', key)
          .maybeSingle();

      if (response == null) {
        debugPrint('💾 Supabase: $key not found');
        return null;
      }

      // Check if expired
      final expiresAtStr = response['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          await delete(key);
          debugPrint('💾 Supabase: $key expired');
          return null;
        }
      }

      final data = response['data'] as Map<String, dynamic>;
      debugPrint('💾 Supabase: Loaded $key');
      return data;
    } catch (e) {
      debugPrint('❌ Supabase: Error loading $key: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        debugPrint('⚠️  Supabase: Cannot delete $key - user not authenticated');
        return;
      }

      await _supabase.client
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .eq('key', key);

      debugPrint('💾 Supabase: Deleted $key');
    } catch (e) {
      debugPrint('❌ Supabase: Error deleting $key: $e');
    }
  }

  @override
  Future<bool> has(String key) async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return false;

      final response = await _supabase.client
          .from(_tableName)
          .select('expires_at')
          .eq('user_id', userId)
          .eq('key', key)
          .maybeSingle();

      if (response == null) return false;

      // Check if expired
      final expiresAtStr = response['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          await delete(key);
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Supabase: Error checking $key: $e');
      return false;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        debugPrint('⚠️  Supabase: Cannot clear - user not authenticated');
        return;
      }

      await _supabase.client
          .from(_tableName)
          .delete()
          .eq('user_id', userId);

      debugPrint('💾 Supabase: Cleared all data');
    } catch (e) {
      debugPrint('❌ Supabase: Error clearing: $e');
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        debugPrint('⚠️  Supabase: Cannot get keys - user not authenticated');
        return [];
      }

      final response = await _supabase.client
          .from(_tableName)
          .select('key, expires_at')
          .eq('user_id', userId);

      final keys = <String>[];
      final now = DateTime.now();

      for (final row in response) {
        final key = row['key'] as String;
        final expiresAtStr = row['expires_at'] as String?;

        if (expiresAtStr != null) {
          final expiresAt = DateTime.parse(expiresAtStr);
          if (now.isAfter(expiresAt)) {
            await delete(key);
            continue;
          }
        }

        keys.add(key);
      }

      return keys;
    } catch (e) {
      debugPrint('❌ Supabase: Error getting keys: $e');
      return [];
    }
  }
}

/// Cache entry with TTL support
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime? expiresAt;

  _CacheEntry(this.data, this.expiresAt);
}
