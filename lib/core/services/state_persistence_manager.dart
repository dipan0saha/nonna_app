import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_storage_service.dart';
import 'persistence_strategies.dart';
import 'supabase_service.dart';

/// State Persistence Manager for Riverpod
///
/// **Functional Requirements**: Section 3.5.5 - State Persistence
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Persists Riverpod state to local storage
/// - Hydration on app start
/// - Selective persistence (opt-in per provider)
/// - Background sync
/// - Multiple persistence strategies (memory, disk, cloud)
/// - TTL management
///
/// Dependencies: CacheService, LocalStorageService, SupabaseService
///
/// Usage:
/// ```dart
/// // Initialize
/// final persistenceManager = StatePersistenceManager(
///   diskStrategy: DiskPersistenceStrategy(localStorageService),
/// );
/// await persistenceManager.initialize();
///
/// // Save state
/// await persistenceManager.saveState('my_provider', {'count': 42});
///
/// // Load state
/// final state = await persistenceManager.loadState('my_provider');
/// ```
class StatePersistenceManager {
  final PersistenceStrategy _memoryStrategy = MemoryPersistenceStrategy();
  final PersistenceStrategy? _diskStrategy;
  final PersistenceStrategy? _cloudStrategy;

  bool _isInitialized = false;
  Timer? _syncTimer;
  Timer? _evictionTimer;

  /// Background sync interval (default: 5 minutes)
  final Duration syncInterval;

  /// Eviction check interval (default: 1 minute)
  final Duration evictionInterval;

  /// Check if the manager has been initialized
  bool get isInitialized => _isInitialized;

  /// Creates a state persistence manager
  ///
  /// [diskStrategy] Optional disk persistence strategy
  /// [cloudStrategy] Optional cloud persistence strategy
  /// [syncInterval] Background sync interval (default: 5 minutes)
  /// [evictionInterval] Eviction check interval (default: 1 minute)
  StatePersistenceManager({
    PersistenceStrategy? diskStrategy,
    PersistenceStrategy? cloudStrategy,
    this.syncInterval = const Duration(minutes: 5),
    this.evictionInterval = const Duration(minutes: 1),
  })  : _diskStrategy = diskStrategy,
        _cloudStrategy = cloudStrategy;

  /// Factory constructor for easy setup with LocalStorageService and SupabaseService
  factory StatePersistenceManager.withServices({
    LocalStorageService? localStorage,
    SupabaseService? supabase,
    Duration syncInterval = const Duration(minutes: 5),
    Duration evictionInterval = const Duration(minutes: 1),
  }) {
    return StatePersistenceManager(
      diskStrategy: localStorage != null
          ? DiskPersistenceStrategy(localStorage)
          : null,
      cloudStrategy: supabase != null
          ? SupabasePersistenceStrategy(supabase)
          : null,
      syncInterval: syncInterval,
      evictionInterval: evictionInterval,
    );
  }

  // ==========================================
  // Initialization
  // ==========================================

  /// Initialize the persistence manager
  ///
  /// Starts background sync and eviction timers.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  StatePersistenceManager already initialized');
      return;
    }

    try {
      // Start background sync timer
      _startBackgroundSync();

      // Start eviction timer
      _startEvictionTimer();

      _isInitialized = true;
      debugPrint('✅ StatePersistenceManager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing StatePersistenceManager: $e');
      rethrow;
    }
  }

  /// Dispose the persistence manager
  Future<void> dispose() async {
    _syncTimer?.cancel();
    _evictionTimer?.cancel();
    _isInitialized = false;
    debugPrint('✅ StatePersistenceManager disposed');
  }

  // ==========================================
  // State Persistence
  // ==========================================

  /// Save state to persistence
  ///
  /// [key] State key (usually provider name)
  /// [data] State data to persist
  /// [ttl] Time-to-live for the state
  /// [strategy] Persistence strategy to use (default: all available)
  Future<void> saveState(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
    PersistenceLevel strategy = PersistenceLevel.all,
  }) async {
    _ensureInitialized();

    try {
      // Save to memory (always)
      if (strategy == PersistenceLevel.memory ||
          strategy == PersistenceLevel.all) {
        await _memoryStrategy.save(key, data, ttl: ttl);
      }

      // Save to disk if available and requested
      if (_diskStrategy != null &&
          (strategy == PersistenceLevel.disk ||
              strategy == PersistenceLevel.all)) {
        await _diskStrategy.save(key, data, ttl: ttl);
      }

      // Save to cloud if available and requested
      if (_cloudStrategy != null &&
          (strategy == PersistenceLevel.cloud ||
              strategy == PersistenceLevel.all)) {
        await _cloudStrategy.save(key, data, ttl: ttl);
      }

      debugPrint('💾 State saved: $key');
    } catch (e) {
      debugPrint('❌ Error saving state for $key: $e');
      rethrow;
    }
  }

  /// Load state from persistence
  ///
  /// [key] State key to load
  /// [strategy] Persistence strategy to check (default: fallback from cloud → disk → memory)
  ///
  /// Returns the state data or null if not found
  Future<Map<String, dynamic>?> loadState(
    String key, {
    PersistenceLevel? strategy,
  }) async {
    _ensureInitialized();

    try {
      // If specific strategy requested, use it
      if (strategy != null) {
        return await _loadFromStrategy(key, strategy);
      }

      // Fallback order: cloud → disk → memory
      if (_cloudStrategy != null) {
        final cloudData = await _cloudStrategy.load(key);
        if (cloudData != null) {
          // Sync to lower levels
          if (_diskStrategy != null) {
            await _diskStrategy.save(key, cloudData);
          }
          await _memoryStrategy.save(key, cloudData);
          return cloudData;
        }
      }

      if (_diskStrategy != null) {
        final diskData = await _diskStrategy.load(key);
        if (diskData != null) {
          // Sync to memory
          await _memoryStrategy.save(key, diskData);
          return diskData;
        }
      }

      return await _memoryStrategy.load(key);
    } catch (e) {
      debugPrint('❌ Error loading state for $key: $e');
      return null;
    }
  }

  /// Delete state from persistence
  ///
  /// [key] State key to delete
  /// [strategy] Persistence strategy to delete from (default: all)
  Future<void> deleteState(
    String key, {
    PersistenceLevel strategy = PersistenceLevel.all,
  }) async {
    _ensureInitialized();

    try {
      if (strategy == PersistenceLevel.memory ||
          strategy == PersistenceLevel.all) {
        await _memoryStrategy.delete(key);
      }

      if (_diskStrategy != null &&
          (strategy == PersistenceLevel.disk ||
              strategy == PersistenceLevel.all)) {
        await _diskStrategy.delete(key);
      }

      if (_cloudStrategy != null &&
          (strategy == PersistenceLevel.cloud ||
              strategy == PersistenceLevel.all)) {
        await _cloudStrategy.delete(key);
      }

      debugPrint('💾 State deleted: $key');
    } catch (e) {
      debugPrint('❌ Error deleting state for $key: $e');
    }
  }

  /// Check if state exists
  ///
  /// [key] State key to check
  /// [strategy] Persistence strategy to check (default: any)
  Future<bool> hasState(
    String key, {
    PersistenceLevel? strategy,
  }) async {
    _ensureInitialized();

    try {
      if (strategy == null) {
        // Check any strategy
        if (await _memoryStrategy.has(key)) return true;
        if (_diskStrategy != null && await _diskStrategy.has(key)) {
          return true;
        }
        if (_cloudStrategy != null && await _cloudStrategy.has(key)) {
          return true;
        }
        return false;
      }

      return await _hasStateInStrategy(key, strategy);
    } catch (e) {
      debugPrint('❌ Error checking state for $key: $e');
      return false;
    }
  }

  /// Clear all state
  ///
  /// [strategy] Persistence strategy to clear (default: all)
  Future<void> clearAll({
    PersistenceLevel strategy = PersistenceLevel.all,
  }) async {
    _ensureInitialized();

    try {
      if (strategy == PersistenceLevel.memory ||
          strategy == PersistenceLevel.all) {
        await _memoryStrategy.clear();
      }

      if (_diskStrategy != null &&
          (strategy == PersistenceLevel.disk ||
              strategy == PersistenceLevel.all)) {
        await _diskStrategy.clear();
      }

      if (_cloudStrategy != null &&
          (strategy == PersistenceLevel.cloud ||
              strategy == PersistenceLevel.all)) {
        await _cloudStrategy.clear();
      }

      debugPrint('💾 All state cleared');
    } catch (e) {
      debugPrint('❌ Error clearing state: $e');
    }
  }

  /// Get all state keys
  ///
  /// [strategy] Persistence strategy to query (default: memory)
  Future<List<String>> getAllKeys({
    PersistenceLevel strategy = PersistenceLevel.memory,
  }) async {
    _ensureInitialized();

    try {
      switch (strategy) {
        case PersistenceLevel.memory:
          return await _memoryStrategy.getAllKeys();
        case PersistenceLevel.disk:
          if (_diskStrategy != null) {
            return await _diskStrategy.getAllKeys();
          }
          return [];
        case PersistenceLevel.cloud:
          if (_cloudStrategy != null) {
            return await _cloudStrategy.getAllKeys();
          }
          return [];
        case PersistenceLevel.all:
          // Combine all keys (deduplicated)
          final keys = <String>{};
          keys.addAll(await _memoryStrategy.getAllKeys());
          if (_diskStrategy != null) {
            keys.addAll(await _diskStrategy.getAllKeys());
          }
          if (_cloudStrategy != null) {
            keys.addAll(await _cloudStrategy.getAllKeys());
          }
          return keys.toList();
      }
    } catch (e) {
      debugPrint('❌ Error getting keys: $e');
      return [];
    }
  }

  // ==========================================
  // Background Sync
  // ==========================================

  /// Start background sync timer
  void _startBackgroundSync() {
    if (_diskStrategy == null && _cloudStrategy == null) {
      return; // No sync needed if only memory
    }

    _syncTimer = Timer.periodic(syncInterval, (_) async {
      await _syncStates();
    });

    debugPrint('🔄 Background sync started (interval: ${syncInterval.inMinutes}min)');
  }

  /// Sync states between strategies
  Future<void> _syncStates() async {
    if (!_isInitialized) return;

    try {
      // Get all keys from memory
      final memoryKeys = await _memoryStrategy.getAllKeys();

      for (final key in memoryKeys) {
        final data = await _memoryStrategy.load(key);
        if (data == null) continue;

        // Sync to disk
        if (_diskStrategy != null) {
          final hasDisk = await _diskStrategy.has(key);
          if (!hasDisk) {
            await _diskStrategy.save(key, data);
          }
        }

        // Sync to cloud
        if (_cloudStrategy != null) {
          final hasCloud = await _cloudStrategy.has(key);
          if (!hasCloud) {
            await _cloudStrategy.save(key, data);
          }
        }
      }

      debugPrint('🔄 Background sync completed');
    } catch (e) {
      debugPrint('❌ Background sync error: $e');
    }
  }

  /// Manually trigger sync
  Future<void> sync() async {
    await _syncStates();
  }

  // ==========================================
  // Eviction
  // ==========================================

  /// Start eviction timer
  void _startEvictionTimer() {
    _evictionTimer = Timer.periodic(evictionInterval, (_) {
      _evictExpiredEntries();
    });

    debugPrint('🗑️  Eviction timer started (interval: ${evictionInterval.inMinutes}min)');
  }

  /// Evict expired entries from memory
  void _evictExpiredEntries() {
    if (!_isInitialized) return;

    if (_memoryStrategy is MemoryPersistenceStrategy) {
      _memoryStrategy.evict();
    }
  }

  // ==========================================
  // Hydration Helpers
  // ==========================================

  /// Hydrate a provider with persisted state
  ///
  /// [ref] Ref to override
  /// [key] State key to load
  /// [fromJson] Function to convert JSON to provider state
  ///
  /// Returns the hydrated state or null if not found
  Future<T?> hydrateProvider<T>(
    Ref ref,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final data = await loadState(key);
    if (data == null) return null;

    try {
      return fromJson(data);
    } catch (e) {
      debugPrint('❌ Error hydrating provider $key: $e');
      return null;
    }
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'StatePersistenceManager not initialized. Call initialize() first.',
      );
    }
  }

  Future<Map<String, dynamic>?> _loadFromStrategy(
    String key,
    PersistenceLevel strategy,
  ) async {
    switch (strategy) {
      case PersistenceLevel.memory:
        return await _memoryStrategy.load(key);
      case PersistenceLevel.disk:
        if (_diskStrategy != null) {
          return await _diskStrategy.load(key);
        }
        return null;
      case PersistenceLevel.cloud:
        if (_cloudStrategy != null) {
          return await _cloudStrategy.load(key);
        }
        return null;
      case PersistenceLevel.all:
        // Check all strategies (cloud first)
        if (_cloudStrategy != null) {
          final data = await _cloudStrategy.load(key);
          if (data != null) return data;
        }
        if (_diskStrategy != null) {
          final data = await _diskStrategy.load(key);
          if (data != null) return data;
        }
        return await _memoryStrategy.load(key);
    }
  }

  Future<bool> _hasStateInStrategy(
    String key,
    PersistenceLevel strategy,
  ) async {
    switch (strategy) {
      case PersistenceLevel.memory:
        return await _memoryStrategy.has(key);
      case PersistenceLevel.disk:
        if (_diskStrategy != null) {
          return await _diskStrategy.has(key);
        }
        return false;
      case PersistenceLevel.cloud:
        if (_cloudStrategy != null) {
          return await _cloudStrategy.has(key);
        }
        return false;
      case PersistenceLevel.all:
        // Check any strategy
        if (await _memoryStrategy.has(key)) return true;
        if (_diskStrategy != null && await _diskStrategy.has(key)) {
          return true;
        }
        if (_cloudStrategy != null && await _cloudStrategy.has(key)) {
          return true;
        }
        return false;
    }
  }
}

/// Persistence level enum
enum PersistenceLevel {
  /// Memory only (fastest, not persistent)
  memory,

  /// Disk storage (persistent across restarts)
  disk,

  /// Cloud storage (syncs across devices)
  cloud,

  /// All levels (memory + disk + cloud)
  all,
}
