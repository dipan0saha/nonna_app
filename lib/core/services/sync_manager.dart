import 'dart:async';

import 'package:flutter/foundation.dart';

import 'realtime_service.dart';

/// Sync status enumeration
enum SyncStatus {
  /// No sync in progress
  idle,

  /// Actively syncing data
  syncing,

  /// Sync completed successfully
  synced,

  /// Sync encountered an error
  error,
}

/// Holds information about a sync error
class SyncError {
  const SyncError({
    required this.message,
    required this.timestamp,
    this.operationKey,
  });

  /// Human-readable error message
  final String message;

  /// When the error occurred
  final DateTime timestamp;

  /// The operation key that failed, if applicable
  final String? operationKey;

  @override
  String toString() => 'SyncError($message at $timestamp)';
}

/// Sync Manager
///
/// **Functional Requirements**: Section 3.6.8 – Offline-First Implementation
///
/// Features:
/// - Background data synchronisation on a configurable interval
/// - Delta sync (only re-syncs data changed since the last successful sync)
/// - Conflict resolution delegated to the registered sync handlers
/// - Retry logic with exponential back-off on failure
/// - Exposes a [syncStatusStream] for UI to react to sync state changes
///
/// Dependencies: [RealtimeService]
///
/// Usage:
/// ```dart
/// final syncManager = SyncManager(realtimeService: realtimeService);
/// syncManager.registerSyncHandler(
///   'baby_profiles',
///   (since) async { /* fetch changes since [since] */ },
/// );
/// await syncManager.initialize();
///
/// // Listen for status changes
/// syncManager.syncStatusStream.listen((status) {
///   if (status == SyncStatus.syncing) showLoadingBanner();
/// });
/// ```
class SyncManager {
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);

  final RealtimeService _realtimeService;
  final Duration syncInterval;

  bool _isInitialized = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  SyncError? _lastError;
  int _retryCount = 0;

  Timer? _syncTimer;
  Timer? _retryTimer;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Tracks subscriptions created by [subscribeToRealtime] so they can be
  /// cancelled when [dispose] is called.
  final Map<String, StreamSubscription<dynamic>> _realtimeSubscriptions = {};

  /// Key → async handler that accepts the `since` timestamp and returns
  /// `true` when the sync succeeded.
  final Map<String, Future<bool> Function(DateTime? since)> _syncHandlers = {};

  /// Creates a [SyncManager].
  ///
  /// [realtimeService] is the underlying realtime service.
  /// [syncInterval] controls how often background sync runs (default: 5 min).
  SyncManager({
    required RealtimeService realtimeService,
    this.syncInterval = const Duration(minutes: 5),
  }) : _realtimeService = realtimeService;

  // ==========================================
  // Getters
  // ==========================================

  /// Current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Whether the manager has been initialised
  bool get isInitialized => _isInitialized;

  /// Time of the last successful sync (null if never synced)
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Last sync error, if any
  SyncError? get lastError => _lastError;

  /// Number of consecutive retry attempts
  int get retryCount => _retryCount;

  /// Stream of [SyncStatus] updates for the UI layer
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  // ==========================================
  // Initialisation
  // ==========================================

  /// Initialise the manager and start background sync.
  ///
  /// Must be called before any other method.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️  SyncManager already initialized');
      return;
    }

    try {
      _startBackgroundSync();
      _isInitialized = true;
      debugPrint('✅ SyncManager initialized');
    } catch (e) {
      debugPrint('❌ Error initializing SyncManager: $e');
      rethrow;
    }
  }

  /// Dispose the manager and cancel all timers.
  Future<void> dispose() async {
    _syncTimer?.cancel();
    _retryTimer?.cancel();
    for (final sub in _realtimeSubscriptions.values) {
      await sub.cancel();
    }
    _realtimeSubscriptions.clear();
    await _statusController.close();
    _isInitialized = false;
    debugPrint('✅ SyncManager disposed');
  }

  // ==========================================
  // Handler Registration
  // ==========================================

  /// Register a sync handler for a given [key].
  ///
  /// [key] A unique identifier for this data source (e.g. `'baby_profiles'`).
  /// [handler] An async function that syncs data changed since [since].
  ///   It should return `true` on success, `false` (or throw) on failure.
  void registerSyncHandler(
    String key,
    Future<bool> Function(DateTime? since) handler,
  ) {
    _syncHandlers[key] = handler;
    debugPrint('📌 Registered sync handler for: $key');
  }

  /// Remove a previously registered sync handler.
  void unregisterSyncHandler(String key) {
    _syncHandlers.remove(key);
    debugPrint('🗑️  Unregistered sync handler for: $key');
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Manually trigger a sync cycle.
  ///
  /// Uses delta sync (changes since [lastSyncTime]) when possible.
  Future<void> sync() async {
    _ensureInitialized();

    if (_syncStatus == SyncStatus.syncing) {
      debugPrint('⚠️  Sync already in progress – skipping');
      return;
    }

    _setSyncStatus(SyncStatus.syncing);
    debugPrint('🔄 Starting sync (since: $_lastSyncTime)…');

    final since = _lastSyncTime;

    try {
      var allSucceeded = true;
      String? failureReason;

      for (final entry in _syncHandlers.entries) {
        final key = entry.key;
        final handler = entry.value;
        try {
          final success = await handler(since);
          if (!success) {
            allSucceeded = false;
            failureReason ??= 'Sync handler "$key" reported failure';
            debugPrint('⚠️  Sync handler "$key" reported failure');
          }
        } catch (e) {
          allSucceeded = false;
          failureReason ??= e.toString();
          debugPrint('❌ Sync handler "$key" threw: $e');
        }
      }

      if (allSucceeded) {
        _lastSyncTime = DateTime.now();
        _retryCount = 0;
        _lastError = null;
        _setSyncStatus(SyncStatus.synced);
        debugPrint('✅ Sync completed at $_lastSyncTime');
      } else {
        _handleSyncFailure(failureReason ?? 'One or more sync handlers failed');
      }
    } catch (e) {
      _handleSyncFailure(e.toString());
    }
  }

  /// Force a full sync, ignoring the [lastSyncTime] delta.
  Future<void> forceFullSync() async {
    _ensureInitialized();
    _lastSyncTime = null;
    await sync();
  }

  // ==========================================
  // Retry Logic
  // ==========================================

  /// Retry a failed sync with exponential back-off.
  void retrySync() {
    _ensureInitialized();

    if (_retryCount >= _maxRetries) {
      debugPrint('⚠️  Max retries reached – not retrying');
      return;
    }

    // Note: delay is calculated from the current _retryCount *before*
    // incrementing, yielding delays of 2s, 4s, 8s, ... for attempts 1, 2, 3.
    // The count is incremented inside the timer callback when the retry
    // actually runs.  If sync() later succeeds, _retryCount is reset to 0,
    // so a new failure sequence starts from the base delay again.
    final delay = _baseRetryDelay * (1 << _retryCount); // 2s, 4s, 8s …
    debugPrint(
        '🔁 Scheduling retry ${_retryCount + 1}/$_maxRetries in ${delay.inSeconds}s');

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () async {
      _retryCount++;
      await sync();
    });
  }

  // ==========================================
  // Realtime Integration
  // ==========================================

  /// Subscribe to real-time updates for a given table and trigger a sync on
  /// any change.
  ///
  /// Returns the subscription stream that the caller can use directly.
  Stream<dynamic> subscribeToRealtime({
    required String table,
    required String channelName,
    Map<String, String>? filter,
  }) {
    _ensureInitialized();

    final stream = _realtimeService.subscribe(
      table: table,
      channelName: channelName,
      filter: filter,
    );

    // Trigger a sync whenever a realtime event arrives
    final subscription = stream.listen(
      (_) {
        if (_syncStatus != SyncStatus.syncing) {
          sync();
        }
      },
      onError: (Object e) {
        debugPrint('❌ Realtime error for $channelName: $e');
      },
    );
    _realtimeSubscriptions[channelName] = subscription;

    return stream;
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  void _startBackgroundSync() {
    _syncTimer = Timer.periodic(syncInterval, (_) async {
      if (_syncStatus != SyncStatus.syncing && _syncHandlers.isNotEmpty) {
        await sync();
      }
    });

    debugPrint(
        '🔄 Background sync started (interval: ${syncInterval.inMinutes}min)');
  }

  void _handleSyncFailure(String message) {
    _lastError = SyncError(
      message: message,
      timestamp: DateTime.now(),
    );
    _setSyncStatus(SyncStatus.error);
    debugPrint('❌ Sync failed: $message');
    retrySync();
  }

  void _setSyncStatus(SyncStatus status) {
    _syncStatus = status;
    _statusController.add(status);
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('SyncManager not initialized. Call initialize() first.');
    }
  }
}
