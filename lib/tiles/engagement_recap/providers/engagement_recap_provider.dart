import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/event_rsvp.dart';
import '../../../core/models/photo_comment.dart';
import '../../../core/models/photo_squish.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';

/// Engagement metrics
class EngagementMetrics {
  final int photoSquishes;
  final int photoComments;
  final int eventRSVPs;
  final int totalEngagement;
  final DateTime calculatedAt;

  const EngagementMetrics({
    required this.photoSquishes,
    required this.photoComments,
    required this.eventRSVPs,
    required this.totalEngagement,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'photoSquishes': photoSquishes,
      'photoComments': photoComments,
      'eventRSVPs': eventRSVPs,
      'totalEngagement': totalEngagement,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    return EngagementMetrics(
      photoSquishes: json['photoSquishes'] as int,
      photoComments: json['photoComments'] as int,
      eventRSVPs: json['eventRSVPs'] as int,
      totalEngagement: json['totalEngagement'] as int,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}

/// Engagement Recap provider for the Engagement Recap tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Aggregates social engagement metrics (photo squishes, comments, event RSVPs)
/// - Activity summary over time period
/// - Trend calculation
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, PhotoSquish model, PhotoComment model, EventRSVP model

/// State class for engagement recap
class EngagementRecapState {
  final EngagementMetrics? metrics;
  final bool isLoading;
  final String? error;

  const EngagementRecapState({
    this.metrics,
    this.isLoading = false,
    this.error,
  });

  EngagementRecapState copyWith({
    EngagementMetrics? metrics,
    bool? isLoading,
    String? error,
  }) {
    return EngagementRecapState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Engagement Recap provider
///
/// Manages engagement metrics aggregation and activity summary.
class EngagementRecapNotifier extends Notifier<EngagementRecapState> {
  // Configuration
  static const String _cacheKeyPrefix = 'engagement_recap';
  static const int _defaultDaysBack = 30; // Default to last 30 days

  @override
  EngagementRecapState build() {
    return const EngagementRecapState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch engagement metrics for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [daysBack] Number of days to look back (default: 30)
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchEngagement({
    required String babyProfileId,
    int daysBack = _defaultDaysBack,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedMetrics = await _loadFromCache(babyProfileId, daysBack);
        if (cachedMetrics != null) {
          state = state.copyWith(
            metrics: cachedMetrics,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch and calculate metrics from database
      final metrics = await _calculateMetrics(babyProfileId, daysBack);

      // Save to cache
      await _saveToCache(babyProfileId, daysBack, metrics);

      state = state.copyWith(
        metrics: metrics,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded engagement metrics for profile: $babyProfileId (${metrics.totalEngagement} total)',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch engagement metrics: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh engagement metrics
  Future<void> refresh({
    required String babyProfileId,
    int daysBack = _defaultDaysBack,
  }) async {
    await fetchEngagement(
      babyProfileId: babyProfileId,
      daysBack: daysBack,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Calculate engagement metrics from database
  Future<EngagementMetrics> _calculateMetrics(
    String babyProfileId,
    int daysBack,
  ) async {
    final databaseService = ref.read(databaseServiceProvider);
    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));

    // Get all photos for this baby profile
    final photosResponse = await databaseService
        .select(SupabaseTables.photos)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .is_(SupabaseTables.deletedAt, null);

    final photoIds = (photosResponse as List)
        .map((json) => json['id'] as String)
        .toList();

    // Count photo squishes
    int photoSquishesCount = 0;
    if (photoIds.isNotEmpty) {
      final squishesResponse = await databaseService
          .select(SupabaseTables.photoSquishes)
          .inFilter('photo_id', photoIds)
          .gte(SupabaseTables.createdAt, cutoffDate.toIso8601String());

      photoSquishesCount = (squishesResponse as List).length;
    }

    // Count photo comments
    int photoCommentsCount = 0;
    if (photoIds.isNotEmpty) {
      final commentsResponse = await databaseService
          .select(SupabaseTables.photoComments)
          .inFilter('photo_id', photoIds)
          .gte(SupabaseTables.createdAt, cutoffDate.toIso8601String());

      photoCommentsCount = (commentsResponse as List).length;
    }

    // Get all events for this baby profile
    final eventsResponse = await databaseService
        .select(SupabaseTables.events)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .is_(SupabaseTables.deletedAt, null);

    final eventIds = (eventsResponse as List)
        .map((json) => json['id'] as String)
        .toList();

    // Count event RSVPs
    int eventRSVPsCount = 0;
    if (eventIds.isNotEmpty) {
      final rsvpsResponse = await databaseService
          .select('event_rsvps')
          .inFilter('event_id', eventIds)
          .gte(SupabaseTables.createdAt, cutoffDate.toIso8601String());

      eventRSVPsCount = (rsvpsResponse as List).length;
    }

    final totalEngagement =
        photoSquishesCount + photoCommentsCount + eventRSVPsCount;

    return EngagementMetrics(
      photoSquishes: photoSquishesCount,
      photoComments: photoCommentsCount,
      eventRSVPs: eventRSVPsCount,
      totalEngagement: totalEngagement,
      calculatedAt: DateTime.now(),
    );
  }

  /// Load metrics from cache
  Future<EngagementMetrics?> _loadFromCache(
    String babyProfileId,
    int daysBack,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId, daysBack);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return EngagementMetrics.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save metrics to cache
  Future<void> _saveToCache(
    String babyProfileId,
    int daysBack,
    EngagementMetrics metrics,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId, daysBack);
      final jsonData = metrics.toJson();
      await cacheService.put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId, int daysBack) {
    return '${_cacheKeyPrefix}_${babyProfileId}_${daysBack}d';
  }
}

/// Provider for engagement recap
///
/// Usage:
/// ```dart
/// final engagementState = ref.watch(engagementRecapProvider);
/// final notifier = ref.read(engagementRecapProvider.notifier);
/// await notifier.fetchEngagement(babyProfileId: 'abc', daysBack: 30);
/// ```
final engagementRecapProvider = NotifierProvider.autoDispose<
    EngagementRecapNotifier, EngagementRecapState>(
  EngagementRecapNotifier.new,
);
