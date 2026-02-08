import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';

/// Storage usage information
class StorageUsageInfo {
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;
  final double usagePercentage;
  final int photoCount;
  final DateTime calculatedAt;

  const StorageUsageInfo({
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
    required this.usagePercentage,
    required this.photoCount,
    required this.calculatedAt,
  });

  /// Format bytes to human-readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get totalFormatted => formatBytes(totalBytes);
  String get usedFormatted => formatBytes(usedBytes);
  String get availableFormatted => formatBytes(availableBytes);

  Map<String, dynamic> toJson() {
    return {
      'totalBytes': totalBytes,
      'usedBytes': usedBytes,
      'availableBytes': availableBytes,
      'usagePercentage': usagePercentage,
      'photoCount': photoCount,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory StorageUsageInfo.fromJson(Map<String, dynamic> json) {
    return StorageUsageInfo(
      totalBytes: json['totalBytes'] as int,
      usedBytes: json['usedBytes'] as int,
      availableBytes: json['availableBytes'] as int,
      usagePercentage: json['usagePercentage'] as double,
      photoCount: json['photoCount'] as int,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}

/// Storage Usage provider for the Storage Usage tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Storage quota tracking (owner only)
/// - Usage visualization data
/// - Calculate from photo storage
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService

/// State class for storage usage
class StorageUsageState {
  final StorageUsageInfo? info;
  final bool isLoading;
  final String? error;

  const StorageUsageState({
    this.info,
    this.isLoading = false,
    this.error,
  });

  StorageUsageState copyWith({
    StorageUsageInfo? info,
    bool? isLoading,
    String? error,
  }) {
    return StorageUsageState(
      info: info ?? this.info,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Storage Usage provider
///
/// Manages storage quota tracking and usage visualization.
class StorageUsageNotifier extends Notifier<StorageUsageState> {
  @override
  StorageUsageState build() {
    return const StorageUsageState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'storage_usage';
  
  // Storage limits (example values - should be configured per plan)
  static const int _defaultTotalStorageBytes = 5 * 1024 * 1024 * 1024; // 5 GB
  static const int _estimatedPhotoSizeBytes = 2 * 1024 * 1024; // 2 MB average per photo

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch storage usage for a specific baby profile (owner only)
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchUsage({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedInfo = await _loadFromCache(babyProfileId);
        if (cachedInfo != null) {
          state = state.copyWith(
            info: cachedInfo,
            isLoading: false,
          );
          return;
        }
      }

      // Calculate usage from database
      final info = await _calculateUsage(babyProfileId);

      // Save to cache
      await _saveToCache(babyProfileId, info);

      state = state.copyWith(
        info: info,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded storage usage for profile: $babyProfileId (${info.usagePercentage.toStringAsFixed(1)}% used)',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch storage usage: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh storage usage
  Future<void> refresh({required String babyProfileId}) async {
    await fetchUsage(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  /// Check if storage is near limit
  bool isNearLimit() {
    return state.info != null && state.info!.usagePercentage >= 80.0;
  }

  /// Check if storage is full
  bool isFull() {
    return state.info != null && state.info!.usagePercentage >= 100.0;
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Calculate storage usage from database
  Future<StorageUsageInfo> _calculateUsage(String babyProfileId) async {
    // Count photos for this baby profile
    final photosResponse = await ref.read(databaseServiceProvider)
        .select(SupabaseTables.photos)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isNull(SupabaseTables.deletedAt);

    final photoCount = (photosResponse as List).length;

    // Estimate storage used (in real app, would query actual file sizes from storage)
    final estimatedUsedBytes = photoCount * _estimatedPhotoSizeBytes;
    final totalBytes = _defaultTotalStorageBytes;
    final availableBytes = totalBytes - estimatedUsedBytes;
    final usagePercentage = (estimatedUsedBytes / totalBytes) * 100;

    return StorageUsageInfo(
      totalBytes: totalBytes,
      usedBytes: estimatedUsedBytes,
      availableBytes: availableBytes > 0 ? availableBytes : 0,
      usagePercentage: usagePercentage > 100 ? 100 : usagePercentage,
      photoCount: photoCount,
      calculatedAt: DateTime.now(),
    );
  }

  /// Load usage info from cache
  Future<StorageUsageInfo?> _loadFromCache(String babyProfileId) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await ref.read(cacheServiceProvider).get(cacheKey);

      if (cachedData == null) return null;

      return StorageUsageInfo.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save usage info to cache
  Future<void> _saveToCache(
    String babyProfileId,
    StorageUsageInfo info,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = info.toJson();
      await ref.read(cacheServiceProvider).put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }
}

/// Provider for storage usage
///
/// Usage:
/// ```dart
/// final storageState = ref.watch(storageUsageProvider);
/// final notifier = ref.read(storageUsageProvider.notifier);
/// await notifier.fetchUsage(babyProfileId: 'abc');
/// ```
final storageUsageProvider =
    NotifierProvider.autoDispose<StorageUsageNotifier, StorageUsageState>(
  StorageUsageNotifier.new,
);
