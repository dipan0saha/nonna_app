import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loading state handler for coordinating loading indicators
///
/// **Functional Requirements**: Section 3.5.6 - Error & Loading State Handlers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Loading indicators coordination
/// - Skeleton screens support
/// - Progress tracking (percentage-based)
/// - Cancellation support
/// - Multiple concurrent operations
/// - Operation-specific loading states
///
/// Dependencies: None
///
/// Usage:
/// ```dart
/// final loadingHandler = ref.read(loadingStateHandlerProvider.notifier);
///
/// // Start loading
/// loadingHandler.startLoading('fetch_data');
///
/// // Update progress
/// loadingHandler.updateProgress('fetch_data', 0.5);
///
/// // Stop loading
/// loadingHandler.stopLoading('fetch_data');
///
/// // Execute with loading
/// await loadingHandler.executeWithLoading(
///   key: 'fetch_data',
///   operation: () => fetchData(),
/// );
/// ```
class LoadingStateHandler extends StateNotifier<LoadingState> {
  LoadingStateHandler() : super(LoadingState.initial());

  // Timers for cancellation
  final Map<String, Timer> _timers = {};

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  // ==========================================
  // Loading Management
  // ==========================================

  /// Start loading for a specific operation
  ///
  /// [key] Operation key (default: 'global')
  /// [message] Optional loading message
  /// [showProgress] Whether to show progress (default: false)
  /// [timeout] Optional timeout duration for automatic cancellation
  void startLoading(
    String key, {
    String? message,
    bool showProgress = false,
    Duration? timeout,
  }) {
    final operations = Map<String, LoadingOperation>.from(state.operations);

    operations[key] = LoadingOperation(
      key: key,
      isLoading: true,
      message: message,
      showProgress: showProgress,
      progress: 0.0,
      startTime: DateTime.now(),
    );

    state = state.copyWith(operations: operations);

    debugPrint('⏳ Loading started: $key${message != null ? " - $message" : ""}');

    // Set up timeout if specified
    if (timeout != null) {
      _timers[key]?.cancel();
      _timers[key] = Timer(timeout, () {
        debugPrint('⏱️  Loading timeout: $key');
        stopLoading(key);
      });
    }
  }

  /// Stop loading for a specific operation
  ///
  /// [key] Operation key (default: 'global')
  void stopLoading(String key) {
    final operations = Map<String, LoadingOperation>.from(state.operations);
    operations.remove(key);

    state = state.copyWith(operations: operations);

    // Cancel timeout timer
    _timers[key]?.cancel();
    _timers.remove(key);

    debugPrint('✅ Loading stopped: $key');
  }

  /// Stop all loading operations
  void stopAllLoading() {
    state = state.copyWith(operations: {});

    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    debugPrint('✅ All loading stopped');
  }

  /// Update loading progress
  ///
  /// [key] Operation key
  /// [progress] Progress value (0.0 to 1.0)
  /// [message] Optional progress message
  void updateProgress(
    String key,
    double progress, {
    String? message,
  }) {
    final operations = Map<String, LoadingOperation>.from(state.operations);
    final operation = operations[key];

    if (operation == null) {
      debugPrint('⚠️  Cannot update progress: $key not loading');
      return;
    }

    // Clamp progress between 0 and 1
    final clampedProgress = progress.clamp(0.0, 1.0);

    operations[key] = operation.copyWith(
      progress: clampedProgress,
      message: message ?? operation.message,
    );

    state = state.copyWith(operations: operations);

    debugPrint('📊 Progress updated: $key - ${(clampedProgress * 100).toInt()}%');
  }

  /// Update loading message
  ///
  /// [key] Operation key
  /// [message] New loading message
  void updateMessage(String key, String message) {
    final operations = Map<String, LoadingOperation>.from(state.operations);
    final operation = operations[key];

    if (operation == null) {
      debugPrint('⚠️  Cannot update message: $key not loading');
      return;
    }

    operations[key] = operation.copyWith(message: message);
    state = state.copyWith(operations: operations);

    debugPrint('💬 Message updated: $key - $message');
  }

  // ==========================================
  // Query Methods
  // ==========================================

  /// Check if a specific operation is loading
  ///
  /// [key] Operation key (default: 'global')
  bool isLoading([String key = 'global']) {
    return state.operations.containsKey(key);
  }

  /// Check if any operation is loading
  bool get isAnyLoading => state.operations.isNotEmpty;

  /// Get loading operation
  ///
  /// [key] Operation key
  LoadingOperation? getOperation(String key) {
    return state.operations[key];
  }

  /// Get loading progress
  ///
  /// [key] Operation key
  /// Returns progress value (0.0 to 1.0) or null if not loading
  double? getProgress(String key) {
    return state.operations[key]?.progress;
  }

  /// Get loading message
  ///
  /// [key] Operation key
  String? getMessage(String key) {
    return state.operations[key]?.message;
  }

  /// Get elapsed time for an operation
  ///
  /// [key] Operation key
  /// Returns duration since loading started or null if not loading
  Duration? getElapsedTime(String key) {
    final operation = state.operations[key];
    if (operation == null) return null;

    return DateTime.now().difference(operation.startTime);
  }

  // ==========================================
  // Operation Helpers
  // ==========================================

  /// Execute an operation with loading state
  ///
  /// [operation] The async operation to execute
  /// [key] Operation key (default: 'global')
  /// [message] Optional loading message
  /// [showProgress] Whether to show progress
  /// [timeout] Optional timeout duration
  Future<T?> executeWithLoading<T>({
    required Future<T> Function() operation,
    String key = 'global',
    String? message,
    bool showProgress = false,
    Duration? timeout,
  }) async {
    // Start loading
    startLoading(
      key,
      message: message,
      showProgress: showProgress,
      timeout: timeout,
    );

    try {
      // Execute operation
      final result = await operation();
      return result;
    } finally {
      // Stop loading
      stopLoading(key);
    }
  }

  /// Execute an operation with progress updates
  ///
  /// [operation] The async operation with progress callback
  /// [key] Operation key
  /// [message] Optional loading message
  /// [timeout] Optional timeout duration
  Future<T?> executeWithProgress<T>({
    required Future<T> Function(void Function(double) onProgress) operation,
    String key = 'global',
    String? message,
    Duration? timeout,
  }) async {
    // Start loading with progress
    startLoading(
      key,
      message: message,
      showProgress: true,
      timeout: timeout,
    );

    try {
      // Execute operation with progress callback
      final result = await operation((progress) {
        updateProgress(key, progress);
      });
      return result;
    } finally {
      // Stop loading
      stopLoading(key);
    }
  }

  /// Execute multiple operations concurrently with individual loading states
  ///
  /// [operations] Map of operation key to async operation
  /// Returns map of results
  Future<Map<String, dynamic>> executeMultiple({
    required Map<String, Future<dynamic> Function()> operations,
    Duration? timeout,
  }) async {
    final results = <String, dynamic>{};

    // Start all operations
    final futures = operations.entries.map((entry) async {
      final key = entry.key;
      final operation = entry.value;

      final result = await executeWithLoading(
        operation: operation,
        key: key,
        timeout: timeout,
      );

      results[key] = result;
    }).toList();

    // Wait for all to complete
    await Future.wait(futures);

    return results;
  }

  // ==========================================
  // Cancellation
  // ==========================================

  /// Cancel a loading operation
  ///
  /// [key] Operation key to cancel
  void cancel(String key) {
    stopLoading(key);
    debugPrint('🚫 Loading cancelled: $key');
  }

  /// Cancel all loading operations
  void cancelAll() {
    stopAllLoading();
    debugPrint('🚫 All loading cancelled');
  }

  // ==========================================
  // Skeleton Screen Helpers
  // ==========================================

  /// Enable skeleton screen for an operation
  ///
  /// [key] Operation key
  void enableSkeleton(String key) {
    final operations = Map<String, LoadingOperation>.from(state.operations);
    final operation = operations[key];

    if (operation == null) {
      // Start loading with skeleton enabled
      startLoading(key, showProgress: false);
    }

    debugPrint('🦴 Skeleton enabled: $key');
  }

  /// Disable skeleton screen for an operation
  ///
  /// [key] Operation key
  void disableSkeleton(String key) {
    stopLoading(key);
    debugPrint('🦴 Skeleton disabled: $key');
  }
}

/// Loading state
class LoadingState {
  /// Map of active loading operations by key
  final Map<String, LoadingOperation> operations;

  const LoadingState({
    required this.operations,
  });

  factory LoadingState.initial() {
    return const LoadingState(operations: {});
  }

  /// Check if any operation is loading
  bool get isAnyLoading => operations.isNotEmpty;

  /// Get count of active operations
  int get operationCount => operations.length;

  /// Get all operation keys
  List<String> get operationKeys => operations.keys.toList();

  LoadingState copyWith({
    Map<String, LoadingOperation>? operations,
  }) {
    return LoadingState(
      operations: operations ?? this.operations,
    );
  }
}

/// Loading operation information
class LoadingOperation {
  /// Operation key/identifier
  final String key;

  /// Whether the operation is loading
  final bool isLoading;

  /// Loading message
  final String? message;

  /// Whether to show progress
  final bool showProgress;

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Start time
  final DateTime startTime;

  const LoadingOperation({
    required this.key,
    required this.isLoading,
    this.message,
    this.showProgress = false,
    this.progress = 0.0,
    required this.startTime,
  });

  /// Get elapsed time
  Duration get elapsed => DateTime.now().difference(startTime);

  /// Get progress percentage (0 to 100)
  int get progressPercent => (progress * 100).toInt();

  LoadingOperation copyWith({
    String? key,
    bool? isLoading,
    String? message,
    bool? showProgress,
    double? progress,
    DateTime? startTime,
  }) {
    return LoadingOperation(
      key: key ?? this.key,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      showProgress: showProgress ?? this.showProgress,
      progress: progress ?? this.progress,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// Provider for loading state handler
final loadingStateHandlerProvider =
    StateNotifierProvider<LoadingStateHandler, LoadingState>((ref) {
  return LoadingStateHandler();
});
