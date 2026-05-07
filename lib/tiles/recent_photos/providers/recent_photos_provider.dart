import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/photo.dart';
import '../../../core/services/storage_service.dart';

/// Recent Photos provider for the Recent Photos tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches recent photos from Supabase
/// - Thumbnail loading optimization
/// - Infinite scroll support
/// - Aggregation logic for photo display
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Photo model

/// State class for recent photos
class RecentPhotosState {
  final List<Photo> photos;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const RecentPhotosState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  RecentPhotosState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return RecentPhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Recent Photos provider
///
/// Manages recent photos with infinite scroll, thumbnail loading, and real-time updates.
class RecentPhotosNotifier extends Notifier<RecentPhotosState> {
  // Configuration
  static const String _cacheKeyPrefix = 'recent_photos';
  static const int _pageSize = 30;

  late final _realtimeService = ref.read(realtimeServiceProvider);
  String? _subscriptionId;
  late final _subscriptionManager =
      ref.read(realtimeSubscriptionManagerProvider);

  @override
  RecentPhotosState build() {
    // Eager initialization prevents ref.read during dispose.
    _realtimeService;
    _subscriptionManager;

    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const RecentPhotosState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch recent photos for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchPhotos({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedPhotos = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
        if (cachedPhotos != null && cachedPhotos.isNotEmpty) {
          final displayPhotos = await _toDisplayPhotos(cachedPhotos);
          if (!ref.mounted) return;

          state = state.copyWith(
            photos: displayPhotos,
            isLoading: false,
            currentPage: 1,
          );

          // Keep live updates active even when cache is used.
          await _setupRealtimeSubscription(babyProfileId);
          if (!ref.mounted) return;

          // Refresh in background to surface newly uploaded photos quickly.
          unawaited(_refreshFromDatabase(babyProfileId));
          return;
        }
      }

      // Fetch from database
      final photos = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: 0,
      );
      if (!ref.mounted) return;

      // Save to cache
      await _saveToCache(babyProfileId, photos);
      if (!ref.mounted) return;

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        hasMore: photos.isNotEmpty,
        currentPage: 1,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);
      if (!ref.mounted) return;

      debugPrint(
        '✅ Loaded ${photos.length} recent photos for profile: $babyProfileId',
      );
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to fetch recent photos: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Load more photos (infinite scroll)
  Future<void> loadMore({required String babyProfileId}) async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final offset = state.currentPage * _pageSize;
      final newPhotos = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: offset,
      );
      if (!ref.mounted) return;

      final updatedPhotos = [...state.photos, ...newPhotos];

      state = state.copyWith(
        photos: updatedPhotos,
        isLoading: false,
        hasMore: newPhotos.isNotEmpty,
        currentPage: state.currentPage + 1,
      );

      // Update cache
      await _saveToCache(babyProfileId, updatedPhotos);
      if (!ref.mounted) return;

      debugPrint('✅ Loaded ${newPhotos.length} more photos');
    } catch (e) {
      debugPrint('❌ Failed to load more photos: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Refresh photos
  Future<void> refresh({required String babyProfileId}) async {
    await fetchPhotos(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch photos from database
  Future<List<Photo>> _fetchFromDatabase({
    required String babyProfileId,
    required int limit,
    required int offset,
  }) async {
    final response = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.photos)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null)
        .order(SupabaseTables.createdAt, ascending: false)
        .range(offset, offset + limit - 1);

    final rawPhotos = (response as List)
        .map((json) => Photo.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();

    return await _toDisplayPhotos(rawPhotos);
  }

  /// Load photos from cache
  Future<List<Photo>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      final photos = (cachedData as List)
          .map((json) => Photo.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      return await _toDisplayPhotos(photos);
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save photos to cache
  Future<void> _saveToCache(String babyProfileId, List<Photo> photos) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = photos.map((photo) => photo.toJson()).toList();
      await cacheService.put(cacheKey, jsonData,
          ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  /// Setup real-time subscription for photos
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      final channelName = 'photos-channel-$babyProfileId';
      final stream = _realtimeService.subscribe(
        table: SupabaseTables.photos,
        channelName: channelName,
        filter: {
          'column': SupabaseTables.babyProfileId,
          'value': babyProfileId,
        },
      );

      _subscriptionId = channelName;

      stream.listen((payload) {
        if (payload is! Map<String, dynamic>) return;
        _handleRealtimeUpdate(payload, babyProfileId);
      });

      debugPrint('✅ Real-time subscription setup for photos');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
      Map<String, dynamic> payload, String babyProfileId) {
    if (!ref.mounted) return;
    try {
      final eventType = payload['eventType'] as String?;
      if (eventType == 'INSERT' ||
          eventType == 'UPDATE' ||
          eventType == 'DELETE') {
        unawaited(_refreshFromDatabase(babyProfileId));
      }

      debugPrint('✅ Real-time photo update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  Future<void> _refreshFromDatabase(String babyProfileId) async {
    try {
      final photos = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: 0,
      );
      if (!ref.mounted) return;

      await _saveToCache(babyProfileId, photos);
      if (!ref.mounted) return;

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        hasMore: photos.isNotEmpty,
        currentPage: 1,
      );
    } catch (e) {
      debugPrint('⚠️  Background recent photos refresh failed: $e');
    }
  }

  Future<List<Photo>> _toDisplayPhotos(List<Photo> photos) async {
    final converted = <Photo>[];
    for (final photo in photos) {
      converted.add(await _toDisplayPhoto(photo));
    }
    return converted;
  }

  Future<Photo> _toDisplayPhoto(Photo photo) async {
    final storageService = ref.read(storageServiceProvider);
    final resolvedStorage =
        await _resolveGalleryPath(storageService, photo.storagePath);
    final resolvedThumbnail = photo.thumbnailPath != null
        ? await _resolveGalleryPath(storageService, photo.thumbnailPath!)
        : null;

    return photo.copyWith(
      storagePath: resolvedStorage,
      thumbnailPath: resolvedThumbnail,
    );
  }

  Future<String> _resolveGalleryPath(
      StorageService storageService, String pathOrUrl) async {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }

    if (!_isGalleryStoragePath(pathOrUrl)) {
      return pathOrUrl;
    }

    try {
      return await storageService.getSignedUrl('gallery-photos', pathOrUrl);
    } catch (_) {
      return pathOrUrl;
    }
  }

  bool _isGalleryStoragePath(String pathOrUrl) {
    return pathOrUrl.startsWith('baby_') || pathOrUrl.contains('/baby_');
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      _realtimeService.unsubscribe(_subscriptionId!);
      _subscriptionManager.unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Provider for recent photos
///
/// Usage:
/// ```dart
/// final photosState = ref.watch(recentPhotosProvider);
/// final notifier = ref.read(recentPhotosProvider.notifier);
/// await notifier.fetchPhotos(babyProfileId: 'abc');
/// ```
final recentPhotosProvider =
    NotifierProvider.autoDispose<RecentPhotosNotifier, RecentPhotosState>(
  RecentPhotosNotifier.new,
);
