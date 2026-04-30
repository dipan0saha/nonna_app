import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/models/tile_config.dart';
import '../../../../core/utils/tile_loader.dart';

/// Gallery Screen Provider for managing gallery screen state
class GalleryScreenState {
  final List<TileConfig> tiles;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String? selectedBabyProfileId;
  final UserRole? selectedRole;
  final DateTime? lastRefreshed;

  const GalleryScreenState({
    this.tiles = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.selectedBabyProfileId,
    this.selectedRole,
    this.lastRefreshed,
  });

  GalleryScreenState copyWith({
    List<TileConfig>? tiles,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? selectedBabyProfileId,
    UserRole? selectedRole,
    DateTime? lastRefreshed,
  }) {
    return GalleryScreenState(
      tiles: tiles ?? this.tiles,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      selectedBabyProfileId: selectedBabyProfileId ?? this.selectedBabyProfileId,
      selectedRole: selectedRole ?? this.selectedRole,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

/// Gallery Screen Provider Notifier
class GalleryScreenNotifier extends Notifier<GalleryScreenState> {
  @override
  GalleryScreenState build() {
    return const GalleryScreenState();
  }

  static const String _screenId = 'gallery';
  static const String _cacheKeyPrefix = 'gallery_screen';

  Future<void> loadTiles({
    required String babyProfileId,
    UserRole role = UserRole.follower,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
        selectedRole: role,
      );

      final tiles = await TileLoader.loadForScreen(
        ref: ref,
        screenId: _screenId,
        role: role,
        forceRefresh: false,
      );
      if (!ref.mounted) return;

      await _saveToCache(babyProfileId, role, tiles);
      if (!ref.mounted) return;

      state = state.copyWith(
        tiles: tiles,
        isLoading: false,
        lastRefreshed: DateTime.now(),
      );

      debugPrint('✅ Loaded ${tiles.length} tiles for gallery screen');
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to load gallery screen: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> refresh() async {
    if (state.selectedBabyProfileId == null || state.selectedRole == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile or role');
      return;
    }

    try {
      state = state.copyWith(isRefreshing: true, error: null);

      final tiles = await TileLoader.loadForScreen(
        ref: ref,
        screenId: _screenId,
        role: state.selectedRole!,
        forceRefresh: true,
      );
      if (!ref.mounted) return;

      await _saveToCache(state.selectedBabyProfileId!, state.selectedRole!, tiles);
      if (!ref.mounted) return;

      state = state.copyWith(
        tiles: tiles,
        isRefreshing: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh gallery: $e',
      );
    }
  }

  void retry() {
    if (state.selectedBabyProfileId != null && state.selectedRole != null) {
      loadTiles(
        babyProfileId: state.selectedBabyProfileId!,
        role: state.selectedRole!,
      );
    }
  }

  Future<void> _saveToCache(String babyProfileId, UserRole role, List<TileConfig> tiles) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = '${_cacheKeyPrefix}_${babyProfileId}_${role.name}';
      final dataList = tiles.map((t) => t.toJson()).toList();
      
      await cacheService.put(
        cacheKey,
        dataList,
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save gallery cache: $e');
    }
  }
}

// Ensure it is properly exported
final galleryScreenProvider = NotifierProvider<GalleryScreenNotifier, GalleryScreenState>(
  () => GalleryScreenNotifier(),
);
