import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/photo.dart';

/// Photo with squish count
class PhotoWithSquishes {
  final Photo photo;
  final int squishCount;

  const PhotoWithSquishes({
    required this.photo,
    required this.squishCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'photo': photo.toJson(),
      'squishCount': squishCount,
    };
  }

  factory PhotoWithSquishes.fromJson(Map<String, dynamic> json) {
    return PhotoWithSquishes(
      photo: Photo.fromJson(json['photo'] as Map<String, dynamic>),
      squishCount: json['squishCount'] as int,
    );
  }
}

/// Gallery Favorites provider for the Gallery Favorites tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches most squished photos
/// - Popularity ranking based on squish counts
/// - Aggregation of squish data
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, Photo model, PhotoSquish model

/// State class for gallery favorites
class GalleryFavoritesState {
  final List<PhotoWithSquishes> favorites;
  final bool isLoading;
  final String? error;

  const GalleryFavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  GalleryFavoritesState copyWith({
    List<PhotoWithSquishes>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return GalleryFavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Gallery Favorites provider
///
/// Manages most squished photos with popularity ranking.
class GalleryFavoritesNotifier extends Notifier<GalleryFavoritesState> {
  // Configuration
  static const String _cacheKeyPrefix = 'gallery_favorites';
  static const int _maxFavorites = 10;
  static const int _minSquishes = 2; // Minimum squishes to be considered

  @override
  GalleryFavoritesState build() {
    return const GalleryFavoritesState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch gallery favorites for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchFavorites({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedFavorites = await _loadFromCache(babyProfileId);
        if (cachedFavorites != null && cachedFavorites.isNotEmpty) {
          state = state.copyWith(
            favorites: cachedFavorites,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch and aggregate from database
      final favorites = await _fetchFromDatabase(babyProfileId);

      // Save to cache
      await _saveToCache(babyProfileId, favorites);

      state = state.copyWith(
        favorites: favorites,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded ${favorites.length} gallery favorites for profile: $babyProfileId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch gallery favorites: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh favorites
  Future<void> refresh({required String babyProfileId}) async {
    await fetchFavorites(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch photos with squish counts from database
  Future<List<PhotoWithSquishes>> _fetchFromDatabase(
    String babyProfileId,
  ) async {
    final databaseService = ref.read(databaseServiceProvider);
    // Get all photos for this baby profile
    final photosResponse = await databaseService
        .select(SupabaseTables.photos)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .is(SupabaseTables.deletedAt, null)
        .order(SupabaseTables.createdAt, ascending: false);

    final photos = (photosResponse as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();

    if (photos.isEmpty) return [];

    // Get squish counts for each photo
    final photoIds = photos.map((p) => p.id).toList();
    final squishesResponse = await databaseService
        .select(SupabaseTables.photoSquishes)
        .inFilter('photo_id', photoIds);

    // Count squishes per photo
    final squishCounts = <String, int>{};
    for (final squishJson in (squishesResponse as List)) {
      final photoId = squishJson['photo_id'] as String;
      squishCounts[photoId] = (squishCounts[photoId] ?? 0) + 1;
    }

    // Create PhotoWithSquishes objects
    final photosWithSquishes = photos
        .map((photo) {
          final count = squishCounts[photo.id] ?? 0;
          return PhotoWithSquishes(
            photo: photo,
            squishCount: count,
          );
        })
        .where((pws) => pws.squishCount >= _minSquishes)
        .toList();

    // Sort by squish count (highest first)
    photosWithSquishes.sort((a, b) => b.squishCount.compareTo(a.squishCount));

    // Return top favorites
    return photosWithSquishes.take(_maxFavorites).toList();
  }

  /// Load favorites from cache
  Future<List<PhotoWithSquishes>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) =>
              PhotoWithSquishes.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save favorites to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<PhotoWithSquishes> favorites,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = favorites.map((fav) => fav.toJson()).toList();
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
}

/// Provider for gallery favorites
///
/// Usage:
/// ```dart
/// final favoritesState = ref.watch(galleryFavoritesProvider);
/// final notifier = ref.read(galleryFavoritesProvider.notifier);
/// await notifier.fetchFavorites(babyProfileId: 'abc');
/// ```
final galleryFavoritesProvider = NotifierProvider.autoDispose<
    GalleryFavoritesNotifier, GalleryFavoritesState>(
  GalleryFavoritesNotifier.new,
);
