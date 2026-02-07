import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/models/tile_config.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/tile_loader.dart';

/// Home Screen Provider for managing home screen state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// **Issue #3.21 Fix**: Removed direct dependency on tileConfigProvider
/// Now uses TileLoader utility for decoupled tile loading
///
/// Features:
/// - Home screen state management
/// - Tile list management
/// - Refresh logic
/// - Error handling
/// - Pull-to-refresh support
///
/// Dependencies: DatabaseService, CacheService (via TileLoader)

/// Home screen state model
class HomeScreenState {
  final List<TileConfig> tiles;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String? selectedBabyProfileId;
  final UserRole? selectedRole;
  final DateTime? lastRefreshed;

  const HomeScreenState({
    this.tiles = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.selectedBabyProfileId,
    this.selectedRole,
    this.lastRefreshed,
  });

  HomeScreenState copyWith({
    List<TileConfig>? tiles,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? selectedBabyProfileId,
    UserRole? selectedRole,
    DateTime? lastRefreshed,
  }) {
    return HomeScreenState(
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

/// Home Screen Provider Notifier
class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  final DatabaseService _databaseService;
  final CacheService _cacheService;
  final Ref _ref;

  HomeScreenNotifier({
    required DatabaseService databaseService,
    required CacheService cacheService,
    required Ref ref,
  })  : _databaseService = databaseService,
        _cacheService = cacheService,
        _ref = ref,
        super(const HomeScreenState());

  // Configuration
  static const String _screenId = 'home';
  static const String _cacheKeyPrefix = 'home_screen';

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load home screen tiles for a baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [role] The user role (owner or follower)
  Future<void> loadTiles({
    required String babyProfileId,
    required UserRole role,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
        selectedRole: role,
      );

      // Load tiles using TileLoader utility (decoupled from tileConfigProvider)
      // Issue #3.21 Fix: Removed direct provider dependency
      final tiles = await TileLoader.loadForScreen(
        ref: _ref,
        screenId: _screenId,
        role: role,
        forceRefresh: false,
      );

      // Save to cache
      await _saveToCache(babyProfileId, role, tiles);

      state = state.copyWith(
        tiles: tiles,
        isLoading: false,
        lastRefreshed: DateTime.now(),
      );

      debugPrint('✅ Loaded ${tiles.length} tiles for home screen');
    } catch (e) {
      final errorMessage = 'Failed to load home screen: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh home screen tiles
  Future<void> refresh() async {
    if (state.selectedBabyProfileId == null || state.selectedRole == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile or role');
      return;
    }

    try {
      state = state.copyWith(isRefreshing: true, error: null);

      // Force refresh using TileLoader utility (decoupled)
      // Issue #3.21 Fix: Removed direct provider dependency
      final tiles = await TileLoader.loadForScreen(
        ref: _ref,
        screenId: _screenId,
        role: state.selectedRole!,
        forceRefresh: true,
      );

      // Update cache
      await _saveToCache(state.selectedBabyProfileId!, state.selectedRole!, tiles);

      state = state.copyWith(
        tiles: tiles,
        isRefreshing: false,
        lastRefreshed: DateTime.now(),
      );

      debugPrint('✅ Refreshed ${tiles.length} tiles');
    } catch (e) {
      debugPrint('❌ Failed to refresh home screen: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh: $e',
      );
    }
  }

  /// Handle pull-to-refresh
  Future<void> onPullToRefresh() async {
    await refresh();
  }

  /// Switch baby profile
  Future<void> switchBabyProfile({
    required String babyProfileId,
    required UserRole role,
  }) async {
    await loadTiles(babyProfileId: babyProfileId, role: role);
  }

  /// Toggle role (for dual-role users)
  Future<void> toggleRole(UserRole newRole) async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot toggle role: missing baby profile');
      return;
    }

    await loadTiles(
      babyProfileId: state.selectedBabyProfileId!,
      role: newRole,
    );
  }

  /// Retry after error
  Future<void> retry() async {
    if (state.selectedBabyProfileId == null || state.selectedRole == null) {
      debugPrint('⚠️  Cannot retry: missing baby profile or role');
      return;
    }

    await loadTiles(
      babyProfileId: state.selectedBabyProfileId!,
      role: state.selectedRole!,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load tiles from cache
  Future<List<TileConfig>?> _loadFromCache(
    String babyProfileId,
    UserRole role,
  ) async {
    if (!_cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId, role);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => TileConfig.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save tiles to cache
  Future<void> _saveToCache(
    String babyProfileId,
    UserRole role,
    List<TileConfig> tiles,
  ) async {
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId, role);
      final jsonData = tiles.map((tile) => tile.toJson()).toList();
      await _cacheService.put(
        cacheKey,
        jsonData,
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId, UserRole role) {
    return '${_cacheKeyPrefix}_${babyProfileId}_${role.name}';
  }
}

/// Home screen provider
///
/// Usage:
/// ```dart
/// final homeState = ref.watch(homeScreenProvider);
/// final notifier = ref.read(homeScreenProvider.notifier);
/// await notifier.loadTiles(babyProfileId: 'abc', role: UserRole.owner);
/// ```
final homeScreenProvider =
    StateNotifierProvider.autoDispose<HomeScreenNotifier, HomeScreenState>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);

    return HomeScreenNotifier(
      databaseService: databaseService,
      cacheService: cacheService,
      ref: ref,
    );
  },
);
