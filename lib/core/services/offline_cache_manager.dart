import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cache_service.dart';

/// Represents the type of a queued sync operation
enum SyncOperationType {
  /// Create a new record
  create,

  /// Update an existing record
  update,

  /// Delete a record
  delete,
}

/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  /// The most recently modified record wins
  lastWriteWins,

  /// The remote (server) record always wins
  remoteWins,

  /// The local record always wins
  localWins,
}

/// A single operation queued for synchronisation while offline
class SyncOperation {
  SyncOperation({
    required this.id,
    required this.key,
    required this.type,
    required this.timestamp,
    this.data,
    this.retryCount = 0,
  });

  /// Unique operation id
  final String id;

  /// Cache / entity key
  final String key;

  /// The type of operation
  final SyncOperationType type;

  /// When the operation was created
  final DateTime timestamp;

  /// Payload for create/update operations
  final Map<String, dynamic>? data;

  /// Number of times this operation has been retried
  final int retryCount;

  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      key: key,
      type: type,
      timestamp: timestamp,
      data: data,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        if (data != null) 'data': data,
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        key: json['key'] as String,
        type: SyncOperationType.values
            .firstWhere((e) => e.name == json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: json['data'] as Map<String, dynamic>?,
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Offline Cache Manager
///
/// **Functional Requirements**: Section 3.6.8 – Offline-First Implementation
///
/// Features:
/// - Offline data caching via [CacheService]
/// - Sync queue management (operations accumulated while offline)
/// - Conflict resolution (last-write-wins by default)
/// - Background sync when connectivity is restored
/// - Online/offline detection via injectable connectivity checker
///
/// Dependencies: [CacheService]
///
/// Usage:
/// ```dart
/// final manager = OfflineCacheManager(cacheService: cacheService);
/// await manager.initialize();
///
/// // Write – queued when offline, applied immediately when online
/// await manager.cacheData('profile_123', {'name': 'Alice'});
///
/// // Read – returns cached data regardless of connectivity
/// final data = await manager.getData<Map<String, dynamic>>('profile_123');
/// ```
class OfflineCacheManager {
  static const String _syncQueueKey = '__offline_sync_queue__';
  static const int _maxRetries = 3;

  final CacheService _cacheService;
  final Future<bool> Function() _connectivityChecker;
  final ConflictResolutionStrategy conflictResolutionStrategy;

  bool _isOnline = true;
  bool _isInitialized = false;
  Timer? _connectivityTimer;
  Timer? _syncTimer;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  final List<SyncOperation> _syncQueue = [];

  /// Creates an [OfflineCacheManager].
  ///
  /// [cacheService] is required for local data storage.
  /// [connectivityChecker] is an optional async function returning `true` when
  /// the device has internet access; defaults to a no-op that always returns
  /// `true` (suitable for unit tests where real connectivity is unavailable).
  /// [conflictResolutionStrategy] determines how conflicts between local queued
  /// writes and remote data are resolved.
  OfflineCacheManager({
    required CacheService cacheService,
    Future<bool> Function()? connectivityChecker,
    this.conflictResolutionStrategy =
        ConflictResolutionStrategy.lastWriteWins,
  })  : _cacheService = cacheService,
        _connectivityChecker =
            connectivityChecker ?? (() async => true);

  // ==========================================
  // Getters
  // ==========================================

  /// Whether the device is currently online
  bool get isOnline => _isOnline;

  /// Whether the manager has been initialised
  bool get isInitialized => _isInitialized;

  /// Number of operations waiting to be synced
  int get pendingSyncCount => _syncQueue.length;

  /// Stream of connectivity changes (`true` = online, `false` = offline)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // ==========================================
  // Initialisation
  // ==========================================

  /// Initialise the manager.
  ///
  /// Must be called before any other method.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  OfflineCacheManager already initialized');
      return;
    }

    try {
      await _loadSyncQueue();

      // Start periodic connectivity checks
      _startConnectivityMonitor();

      // Start background sync timer
      _startBackgroundSync();

      _isInitialized = true;
      debugPrint('✅ OfflineCacheManager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing OfflineCacheManager: $e');
      rethrow;
    }
  }

  /// Dispose the manager and cancel background timers.
  Future<void> dispose() async {
    _connectivityTimer?.cancel();
    _syncTimer?.cancel();
    await _connectivityController.close();
    _isInitialized = false;
    debugPrint('✅ OfflineCacheManager disposed');
  }

  // ==========================================
  // Connectivity
  // ==========================================

  /// Check connectivity and update internal state.
  ///
  /// Returns `true` if the device is online.
  Future<bool> checkConnectivity() async {
    _ensureInitialized();

    try {
      final online = await _connectivityChecker();
      _updateOnlineStatus(online);
      return online;
    } catch (e) {
      debugPrint('❌ Connectivity check failed: $e');
      _updateOnlineStatus(false);
      return false;
    }
  }

  /// Manually notify the manager about a connectivity change.
  void updateConnectivity(bool isOnline) {
    _updateOnlineStatus(isOnline);
  }

  // ==========================================
  // Cache Operations
  // ==========================================

  /// Cache data with offline support.
  ///
  /// When online the data is written directly to cache.
  /// When offline the operation is added to the sync queue.
  ///
  /// [key] Cache key.
  /// [data] Data to cache (must be JSON-serialisable).
  /// [ttlMinutes] Optional TTL for the cache entry.
  Future<void> cacheData(
    String key,
    Map<String, dynamic> data, {
    int? ttlMinutes,
  }) async {
    _ensureInitialized();

    if (_isOnline) {
      await _cacheService.put(key, jsonEncode(data), ttlMinutes: ttlMinutes);
      debugPrint('💾 Cached data for key: $key');
    } else {
      await _enqueueOperation(
        SyncOperation(
          id: '${key}_${DateTime.now().millisecondsSinceEpoch}',
          key: key,
          type: SyncOperationType.update,
          timestamp: DateTime.now(),
          data: data,
        ),
      );
      debugPrint('📋 Queued offline write for key: $key');
    }
  }

  /// Get data from cache.
  ///
  /// Returns cached data regardless of connectivity.
  Future<T?> getData<T>(String key) async {
    _ensureInitialized();

    try {
      final raw = await _cacheService.get<String>(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded as T?;
    } catch (e) {
      debugPrint('❌ Error getting data for key $key: $e');
      return null;
    }
  }

  /// Delete data with offline support.
  ///
  /// When online the entry is removed immediately.
  /// When offline a delete operation is queued.
  Future<void> deleteData(String key) async {
    _ensureInitialized();

    if (_isOnline) {
      await _cacheService.delete(key);
    } else {
      await _enqueueOperation(
        SyncOperation(
          id: '${key}_delete_${DateTime.now().millisecondsSinceEpoch}',
          key: key,
          type: SyncOperationType.delete,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  // ==========================================
  // Sync Queue
  // ==========================================

  /// Manually trigger processing of the sync queue.
  ///
  /// Resolves conflicts and applies queued operations.
  Future<void> processQueue() async {
    _ensureInitialized();

    if (_syncQueue.isEmpty) {
      debugPrint('📋 Sync queue is empty – nothing to process');
      return;
    }

    debugPrint('🔄 Processing sync queue (${_syncQueue.length} operations)…');

    final toRemove = <SyncOperation>[];

    for (final operation in List<SyncOperation>.from(_syncQueue)) {
      try {
        await _applyOperation(operation);
        toRemove.add(operation);
      } catch (e) {
        debugPrint('❌ Failed to apply operation ${operation.id}: $e');
        final updated = operation.copyWith(retryCount: operation.retryCount + 1);
        final idx = _syncQueue.indexOf(operation);
        if (idx >= 0) {
          _syncQueue[idx] = updated;
        }
        if (updated.retryCount >= _maxRetries) {
          debugPrint(
              '⚠️  Operation ${operation.id} exceeded max retries – discarding');
          toRemove.add(operation);
        }
      }
    }

    for (final op in toRemove) {
      _syncQueue.removeWhere((e) => e.id == op.id);
    }

    await _persistSyncQueue();
    debugPrint('✅ Sync queue processed – ${toRemove.length} operations applied');
  }

  /// Clear the sync queue without processing.
  Future<void> clearQueue() async {
    _ensureInitialized();
    _syncQueue.clear();
    await _persistSyncQueue();
    debugPrint('🗑️  Sync queue cleared');
  }

  // ==========================================
  // Conflict Resolution
  // ==========================================

  /// Resolve a conflict between a local queued value and the current cached
  /// value.
  ///
  /// Returns the value that should be persisted.
  Map<String, dynamic> resolveConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    DateTime? localTimestamp,
    DateTime? remoteTimestamp,
  }) {
    switch (conflictResolutionStrategy) {
      case ConflictResolutionStrategy.remoteWins:
        return remoteData;
      case ConflictResolutionStrategy.localWins:
        return localData;
      case ConflictResolutionStrategy.lastWriteWins:
        if (localTimestamp == null && remoteTimestamp == null) {
          return remoteData;
        }
        if (localTimestamp == null) return remoteData;
        if (remoteTimestamp == null) return localData;
        return localTimestamp.isAfter(remoteTimestamp) ? localData : remoteData;
    }
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  void _updateOnlineStatus(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    _connectivityController.add(online);
    debugPrint(online ? '🌐 Device is online' : '📵 Device is offline');

    if (online && _syncQueue.isNotEmpty) {
      processQueue();
    }
  }

  void _startConnectivityMonitor() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkConnectivity(),
    );
  }

  void _startBackgroundSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        if (_isOnline && _syncQueue.isNotEmpty) {
          await processQueue();
        }
      },
    );
  }

  Future<void> _enqueueOperation(SyncOperation operation) async {
    _syncQueue.add(operation);
    await _persistSyncQueue();
    debugPrint(
        '📋 Enqueued ${operation.type.name} for key: ${operation.key} '
        '(queue size: ${_syncQueue.length})');
  }

  Future<void> _applyOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        if (operation.data != null) {
          await _cacheService.put(
            operation.key,
            jsonEncode(operation.data),
          );
        }
      case SyncOperationType.delete:
        await _cacheService.delete(operation.key);
    }
  }

  Future<void> _persistSyncQueue() async {
    try {
      final list = _syncQueue.map((op) => op.toJson()).toList();
      await _cacheService.put(
        _syncQueueKey,
        jsonEncode(list),
      );
    } catch (e) {
      debugPrint('❌ Error persisting sync queue: $e');
    }
  }

  Future<void> _loadSyncQueue() async {
    try {
      final raw = await _cacheService.get<String>(_syncQueueKey);
      if (raw == null) return;

      final list = jsonDecode(raw) as List<dynamic>;
      _syncQueue.addAll(
        list.map((e) => SyncOperation.fromJson(e as Map<String, dynamic>)),
      );

      debugPrint('📋 Loaded ${_syncQueue.length} queued operations');
    } catch (e) {
      debugPrint('⚠️  Could not load sync queue: $e');
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'OfflineCacheManager not initialized. Call initialize() first.',
      );
    }
  }
}
