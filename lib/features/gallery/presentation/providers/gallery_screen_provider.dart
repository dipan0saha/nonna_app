import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/photo.dart';

/// Gallery Screen Provider for managing photo gallery state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Photo gallery state management
/// - Photo grid display
/// - Filters (by baby, date, tags)
/// - Infinite scroll / pagination
/// - Upload state management
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Photo model

/// Gallery filter options
enum GalleryFilter {
  all,
  byDate,
  byTag,
}

/// Gallery screen state model
class GalleryScreenState {
  final List<Photo> photos;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final GalleryFilter currentFilter;
  final String? selectedTag;
  final DateTime? selectedDate;
  final bool hasMore;
  final int currentPage;
  final String? selectedBabyProfileId;

  const GalleryScreenState({
    this.photos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentFilter = GalleryFilter.all,
    this.selectedTag,
    this.selectedDate,
    this.hasMore = true,
    this.currentPage = 0,
    this.selectedBabyProfileId,
  });

  GalleryScreenState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    GalleryFilter? currentFilter,
    String? selectedTag,
    DateTime? selectedDate,
    bool? hasMore,
    int? currentPage,
    String? selectedBabyProfileId,
  }) {
    return GalleryScreenState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedTag: selectedTag ?? this.selectedTag,
      selectedDate: selectedDate ?? this.selectedDate,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedBabyProfileId:
          selectedBabyProfileId ?? this.selectedBabyProfileId,
    );
  }
}

/// Gallery Screen Provider Notifier
class GalleryScreenNotifier extends Notifier<GalleryScreenState> {
  String? _subscriptionId;

  @override
  GalleryScreenState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const GalleryScreenState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'gallery_photos';
  static const int _pageSize = 30;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load photos for a baby profile
  Future<void> loadPhotos({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
      );

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedPhotos = await _loadFromCache(babyProfileId);
        if (cachedPhotos != null && cachedPhotos.isNotEmpty) {
          state = state.copyWith(
            photos: cachedPhotos,
            isLoading: false,
            currentPage: 1,
          );
          return;
        }
      }

      // Fetch from database
      final photos = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: 0,
      );

      // Save to cache
      await _saveToCache(babyProfileId, photos);

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        hasMore: photos.length >= _pageSize,
        currentPage: 1,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);

      debugPrint('✅ Loaded ${photos.length} photos for gallery');
    } catch (e) {
      final errorMessage = 'Failed to load photos: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Load more photos (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.selectedBabyProfileId == null) {
      return;
    }

    try {
      state = state.copyWith(isLoadingMore: true);

      final offset = state.currentPage * _pageSize;
      final newPhotos = await _fetchFromDatabase(
        babyProfileId: state.selectedBabyProfileId!,
        limit: _pageSize,
        offset: offset,
      );

      final updatedPhotos = [...state.photos, ...newPhotos];

      state = state.copyWith(
        photos: updatedPhotos,
        isLoadingMore: false,
        hasMore: newPhotos.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );

      // Update cache
      await _saveToCache(state.selectedBabyProfileId!, updatedPhotos);

      debugPrint('✅ Loaded ${newPhotos.length} more photos');
    } catch (e) {
      debugPrint('❌ Failed to load more photos: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Filter photos by tag
  Future<void> filterByTag(String tag) async {
    if (state.selectedBabyProfileId == null) return;

    try {
      state = state.copyWith(
        isLoading: true,
        currentFilter: GalleryFilter.byTag,
        selectedTag: tag,
      );

      final photos = await _fetchPhotosByTag(
        babyProfileId: state.selectedBabyProfileId!,
        tag: tag,
      );

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        hasMore: false, // No pagination for filtered results
      );

      debugPrint('✅ Filtered ${photos.length} photos by tag: $tag');
    } catch (e) {
      debugPrint('❌ Failed to filter photos: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to filter photos: $e',
      );
    }
  }

  /// Clear filters and show all photos
  Future<void> clearFilters() async {
    if (state.selectedBabyProfileId == null) return;

    state = state.copyWith(
      currentFilter: GalleryFilter.all,
      selectedTag: null,
      selectedDate: null,
    );

    await loadPhotos(
      babyProfileId: state.selectedBabyProfileId!,
      forceRefresh: true,
    );
  }

  /// Refresh photos
  Future<void> refresh() async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile');
      return;
    }

    await loadPhotos(
      babyProfileId: state.selectedBabyProfileId!,
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
        .is_(SupabaseTables.deletedAt, null)
        .order(SupabaseTables.createdAt, ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch photos by tag
  Future<List<Photo>> _fetchPhotosByTag({
    required String babyProfileId,
    required String tag,
  }) async {
    final response = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.photos)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .is_(SupabaseTables.deletedAt, null)
        .contains('tags', [tag]).order(SupabaseTables.createdAt,
            ascending: false);

    return (response as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load photos from cache
  Future<List<Photo>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => Photo.fromJson(json as Map<String, dynamic>))
          .toList();
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
      await cacheService.put(
        cacheKey,
        jsonData,
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
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
      final stream = ref.read(realtimeServiceProvider).subscribe(
        table: SupabaseTables.photos,
        channelName: channelName,
        filter: {
          'column': SupabaseTables.babyProfileId,
          'value': babyProfileId,
        },
      );

      _subscriptionId = channelName;

      stream.listen((payload) {
        _handleRealtimeUpdate(payload, babyProfileId);
      });

      debugPrint('✅ Real-time subscription setup for photos');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newPhoto = Photo.fromJson(newData);
        final updatedPhotos = [newPhoto, ...state.photos];
        state = state.copyWith(photos: updatedPhotos);
        _saveToCache(babyProfileId, updatedPhotos);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedPhoto = Photo.fromJson(newData);
        final updatedPhotos = state.photos
            .map((p) => p.id == updatedPhoto.id ? updatedPhoto : p)
            .toList();
        state = state.copyWith(photos: updatedPhotos);
        _saveToCache(babyProfileId, updatedPhotos);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedId = oldData['id'] as String;
          final updatedPhotos =
              state.photos.where((p) => p.id != deletedId).toList();
          state = state.copyWith(photos: updatedPhotos);
          _saveToCache(babyProfileId, updatedPhotos);
        }
      }

      debugPrint('✅ Real-time photo update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      ref.read(realtimeServiceProvider).unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Gallery screen provider
///
/// Usage:
/// ```dart
/// final galleryState = ref.watch(galleryScreenProvider);
/// final notifier = ref.read(galleryScreenProvider.notifier);
/// await notifier.loadPhotos(babyProfileId: 'abc');
/// ```
final galleryScreenProvider =
    NotifierProvider.autoDispose<GalleryScreenNotifier, GalleryScreenState>(
  GalleryScreenNotifier.new,
);
