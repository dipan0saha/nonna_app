import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/models/tile_config.dart';
import '../../../../core/utils/tile_loader.dart';

/// Gallery Screen Provider for managing gallery screen state
class GalleryScreenState {
  final Map<String, List<TileConfig>> tilesByScreen;
  final Map<String, bool> isLoadingByScreen;
  final Map<String, bool> isRefreshingByScreen;
  final Map<String, String?> errorByScreen;
  final String? selectedBabyProfileId;
  final UserRole? selectedRole;
  final DateTime? lastRefreshed;

  const GalleryScreenState({
    this.tilesByScreen = const {},
    this.isLoadingByScreen = const {},
    this.isRefreshingByScreen = const {},
    this.errorByScreen = const {},
    this.selectedBabyProfileId,
    this.selectedRole,
    this.lastRefreshed,
  });

  List<TileConfig> tilesFor(String screenId) =>
      tilesByScreen[screenId] ?? const [];
  bool isLoadingFor(String screenId) => isLoadingByScreen[screenId] ?? false;
  bool isRefreshingFor(String screenId) =>
      isRefreshingByScreen[screenId] ?? false;
  String? errorFor(String screenId) => errorByScreen[screenId];

  GalleryScreenState copyWith({
    Map<String, List<TileConfig>>? tilesByScreen,
    Map<String, bool>? isLoadingByScreen,
    Map<String, bool>? isRefreshingByScreen,
    Map<String, String?>? errorByScreen,
    String? selectedBabyProfileId,
    UserRole? selectedRole,
    DateTime? lastRefreshed,
  }) {
    return GalleryScreenState(
      tilesByScreen: tilesByScreen ?? this.tilesByScreen,
      isLoadingByScreen: isLoadingByScreen ?? this.isLoadingByScreen,
      isRefreshingByScreen: isRefreshingByScreen ?? this.isRefreshingByScreen,
      errorByScreen: errorByScreen ?? this.errorByScreen,
      selectedBabyProfileId:
          selectedBabyProfileId ?? this.selectedBabyProfileId,
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

  static const String _cacheKeyPrefix = 'gallery_screen';

  Future<void> loadTiles({
    required String babyProfileId,
    required String screenId,
    UserRole role = UserRole.follower,
  }) async {
    try {
      state = state.copyWith(
        isLoadingByScreen: {...state.isLoadingByScreen, screenId: true},
        errorByScreen: {...state.errorByScreen, screenId: null},
        selectedBabyProfileId: babyProfileId,
        selectedRole: role,
      );

      final tiles = await TileLoader.loadForScreen(
        ref: ref,
        babyProfileId: babyProfileId,
        screenId: screenId,
        role: role,
        forceRefresh: false,
      );
      if (!ref.mounted) return;

      await _saveToCache(babyProfileId, role, screenId, tiles);
      if (!ref.mounted) return;

      state = state.copyWith(
        tilesByScreen: {...state.tilesByScreen, screenId: tiles},
        isLoadingByScreen: {...state.isLoadingByScreen, screenId: false},
        lastRefreshed: DateTime.now(),
      );

      debugPrint('✅ Loaded ${tiles.length} tiles for screen $screenId');
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to load screen $screenId: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoadingByScreen: {...state.isLoadingByScreen, screenId: false},
        errorByScreen: {...state.errorByScreen, screenId: errorMessage},
      );
    }
  }

  Future<void> refresh(String screenId) async {
    if (state.selectedBabyProfileId == null || state.selectedRole == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile or role');
      return;
    }

    try {
      state = state.copyWith(
        isRefreshingByScreen: {...state.isRefreshingByScreen, screenId: true},
        errorByScreen: {...state.errorByScreen, screenId: null},
      );

      final tiles = await TileLoader.loadForScreen(
        ref: ref,
        babyProfileId: state.selectedBabyProfileId!,
        screenId: screenId,
        role: state.selectedRole!,
        forceRefresh: true,
      );
      if (!ref.mounted) return;

      await _saveToCache(
          state.selectedBabyProfileId!, state.selectedRole!, screenId, tiles);
      if (!ref.mounted) return;

      state = state.copyWith(
        tilesByScreen: {...state.tilesByScreen, screenId: tiles},
        isRefreshingByScreen: {...state.isRefreshingByScreen, screenId: false},
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshingByScreen: {...state.isRefreshingByScreen, screenId: false},
        errorByScreen: {
          ...state.errorByScreen,
          screenId: 'Failed to refresh gallery: $e'
        },
      );
    }
  }

  void retry(String screenId) {
    if (state.selectedBabyProfileId != null && state.selectedRole != null) {
      loadTiles(
        babyProfileId: state.selectedBabyProfileId!,
        role: state.selectedRole!,
        screenId: screenId,
      );
    }
  }

  Future<void> _saveToCache(String babyProfileId, UserRole role,
      String screenId, List<TileConfig> tiles) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey =
          '${_cacheKeyPrefix}_${babyProfileId}_${role.name}_$screenId';
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
final galleryScreenProvider =
    NotifierProvider<GalleryScreenNotifier, GalleryScreenState>(
  () => GalleryScreenNotifier(),
);
