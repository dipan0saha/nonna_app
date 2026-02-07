import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cache_service.dart';
import '../../../core/services/local_storage_service.dart';

/// Tile visibility provider for managing user-specific tile visibility preferences
///
/// **Functional Requirements**: Section 3.5.2 - Tile Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Manages tile visibility flags per user
/// - Stores user preferences locally
/// - Supports feature flags for conditional rendering
/// - Provides conditional rendering logic for tiles
///
/// Dependencies: CacheService, LocalStorageService

/// State class for tile visibility
class TileVisibilityState {
  /// Map of tile IDs to visibility status
  final Map<String, bool> visibilityMap;

  /// Map of feature flags
  final Map<String, bool> featureFlags;

  final bool isLoading;
  final String? error;

  const TileVisibilityState({
    this.visibilityMap = const {},
    this.featureFlags = const {},
    this.isLoading = false,
    this.error,
  });

  TileVisibilityState copyWith({
    Map<String, bool>? visibilityMap,
    Map<String, bool>? featureFlags,
    bool? isLoading,
    String? error,
  }) {
    return TileVisibilityState(
      visibilityMap: visibilityMap ?? this.visibilityMap,
      featureFlags: featureFlags ?? this.featureFlags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Tile visibility notifier
///
/// Manages tile visibility preferences and feature flags.
class TileVisibilityNotifier extends StateNotifier<TileVisibilityState> {
  final CacheService _cacheService;
  final LocalStorageService _localStorageService;

  TileVisibilityNotifier({
    required CacheService cacheService,
    required LocalStorageService localStorageService,
  })  : _cacheService = cacheService,
        _localStorageService = localStorageService,
        super(const TileVisibilityState());

  // Storage keys
  static const String _visibilityStorageKey = 'tile_visibility_preferences';
  static const String _featureFlagsStorageKey = 'feature_flags';

  // ==========================================
  // Initialization
  // ==========================================

  /// Load visibility preferences from local storage
  ///
  /// Should be called when the user logs in or app starts.
  Future<void> loadPreferences({String? userId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load visibility preferences
      final visibilityKey = userId != null
          ? '${_visibilityStorageKey}_$userId'
          : _visibilityStorageKey;

      final Map<String, bool> visibilityMap =
          await _loadVisibilityFromStorage(visibilityKey);

      // Load feature flags
      final Map<String, bool> featureFlags =
          await _loadFeatureFlagsFromStorage();

      state = state.copyWith(
        visibilityMap: visibilityMap,
        featureFlags: featureFlags,
        isLoading: false,
      );

      debugPrint('✅ Loaded tile visibility preferences');
    } catch (e) {
      final errorMessage = 'Failed to load visibility preferences: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  // ==========================================
  // Visibility Management
  // ==========================================

  /// Check if a tile is visible
  ///
  /// [tileId] The tile identifier
  /// Returns true if the tile should be shown, false otherwise.
  bool isTileVisible(String tileId) {
    return state.visibilityMap[tileId] ?? true; // Default to visible
  }

  /// Set tile visibility
  ///
  /// [tileId] The tile identifier
  /// [isVisible] New visibility state
  /// [userId] Optional user ID for user-specific preferences
  Future<void> setTileVisibility({
    required String tileId,
    required bool isVisible,
    String? userId,
  }) async {
    try {
      // Update state
      final updatedMap = Map<String, bool>.from(state.visibilityMap);
      updatedMap[tileId] = isVisible;

      state = state.copyWith(visibilityMap: updatedMap);

      // Persist to storage
      final visibilityKey = userId != null
          ? '${_visibilityStorageKey}_$userId'
          : _visibilityStorageKey;

      await _saveVisibilityToStorage(visibilityKey, updatedMap);

      debugPrint('✅ Updated visibility for tile: $tileId to $isVisible');
    } catch (e) {
      debugPrint('❌ Failed to update tile visibility: $e');
      rethrow;
    }
  }

  /// Hide a tile
  ///
  /// Convenience method to hide a tile.
  Future<void> hideTile(String tileId, {String? userId}) async {
    await setTileVisibility(
      tileId: tileId,
      isVisible: false,
      userId: userId,
    );
  }

  /// Show a tile
  ///
  /// Convenience method to show a tile.
  Future<void> showTile(String tileId, {String? userId}) async {
    await setTileVisibility(
      tileId: tileId,
      isVisible: true,
      userId: userId,
    );
  }

  /// Toggle tile visibility
  ///
  /// Flips the current visibility state.
  Future<void> toggleTileVisibility(String tileId, {String? userId}) async {
    final currentVisibility = isTileVisible(tileId);
    await setTileVisibility(
      tileId: tileId,
      isVisible: !currentVisibility,
      userId: userId,
    );
  }

  /// Reset tile visibility preferences
  ///
  /// Clears all user-specific visibility preferences.
  Future<void> resetPreferences({String? userId}) async {
    try {
      state = state.copyWith(visibilityMap: {});

      final visibilityKey = userId != null
          ? '${_visibilityStorageKey}_$userId'
          : _visibilityStorageKey;

      await _localStorageService.remove(visibilityKey);

      debugPrint('✅ Reset tile visibility preferences');
    } catch (e) {
      debugPrint('❌ Failed to reset preferences: $e');
      rethrow;
    }
  }

  // ==========================================
  // Feature Flags
  // ==========================================

  /// Check if a feature is enabled
  ///
  /// [featureName] The feature flag name
  /// Returns true if the feature is enabled, false otherwise.
  bool isFeatureEnabled(String featureName) {
    return state.featureFlags[featureName] ?? false;
  }

  /// Set feature flag
  ///
  /// [featureName] The feature flag name
  /// [isEnabled] New enabled state
  Future<void> setFeatureFlag({
    required String featureName,
    required bool isEnabled,
  }) async {
    try {
      // Update state
      final updatedFlags = Map<String, bool>.from(state.featureFlags);
      updatedFlags[featureName] = isEnabled;

      state = state.copyWith(featureFlags: updatedFlags);

      // Persist to storage
      await _saveFeatureFlagsToStorage(updatedFlags);

      debugPrint('✅ Updated feature flag: $featureName to $isEnabled');
    } catch (e) {
      debugPrint('❌ Failed to update feature flag: $e');
      rethrow;
    }
  }

  /// Load feature flags from remote config
  ///
  /// In a production app, this would fetch from a remote config service
  /// like Firebase Remote Config or LaunchDarkly.
  Future<void> loadRemoteFeatureFlags() async {
    try {
      // TODO: Implement remote config fetching
      // For now, we'll use local storage
      final flags = await _loadFeatureFlagsFromStorage();
      state = state.copyWith(featureFlags: flags);

      debugPrint('✅ Loaded remote feature flags');
    } catch (e) {
      debugPrint('❌ Failed to load remote feature flags: $e');
    }
  }

  // ==========================================
  // Conditional Rendering Logic
  // ==========================================

  /// Check if a tile should be rendered
  ///
  /// Combines visibility preferences and feature flags.
  ///
  /// [tileId] The tile identifier
  /// [requiredFeature] Optional feature flag that must be enabled
  /// Returns true if the tile should be rendered, false otherwise.
  bool shouldRenderTile(String tileId, {String? requiredFeature}) {
    // Check visibility preference
    if (!isTileVisible(tileId)) {
      return false;
    }

    // Check feature flag if provided
    if (requiredFeature != null && !isFeatureEnabled(requiredFeature)) {
      return false;
    }

    return true;
  }

  /// Get all visible tiles
  ///
  /// Returns a list of tile IDs that are currently visible.
  List<String> getVisibleTiles() {
    return state.visibilityMap.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all hidden tiles
  ///
  /// Returns a list of tile IDs that are currently hidden.
  List<String> getHiddenTiles() {
    return state.visibilityMap.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Load visibility preferences from storage
  Future<Map<String, bool>> _loadVisibilityFromStorage(String key) async {
    if (!_localStorageService.isInitialized) {
      return {};
    }

    try {
      final data = await _localStorageService.getString(key);
      if (data == null) return {};

      // Parse JSON string to Map
      final Map<String, dynamic> jsonMap =
          Map<String, dynamic>.from(await _localStorageService.getObject(key));
      return jsonMap.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      debugPrint('⚠️  Failed to load visibility from storage: $e');
      return {};
    }
  }

  /// Save visibility preferences to storage
  Future<void> _saveVisibilityToStorage(
    String key,
    Map<String, bool> visibilityMap,
  ) async {
    if (!_localStorageService.isInitialized) return;

    try {
      await _localStorageService.setObject(key, visibilityMap);
    } catch (e) {
      debugPrint('⚠️  Failed to save visibility to storage: $e');
    }
  }

  /// Load feature flags from storage
  Future<Map<String, bool>> _loadFeatureFlagsFromStorage() async {
    if (!_localStorageService.isInitialized) {
      return {};
    }

    try {
      final data = await _localStorageService.getObject(_featureFlagsStorageKey);
      if (data == null) return {};

      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data);
      return jsonMap.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      debugPrint('⚠️  Failed to load feature flags from storage: $e');
      return {};
    }
  }

  /// Save feature flags to storage
  Future<void> _saveFeatureFlagsToStorage(Map<String, bool> featureFlags) async {
    if (!_localStorageService.isInitialized) return;

    try {
      await _localStorageService.setObject(_featureFlagsStorageKey, featureFlags);
    } catch (e) {
      debugPrint('⚠️  Failed to save feature flags to storage: $e');
    }
  }
}

/// Provider for tile visibility
///
/// Usage:
/// ```dart
/// final tileVisibilityProvider = StateNotifierProvider<TileVisibilityNotifier, TileVisibilityState>((ref) {
///   final cacheService = ref.watch(cacheServiceProvider);
///   final localStorageService = ref.watch(localStorageServiceProvider);
///   return TileVisibilityNotifier(
///     cacheService: cacheService,
///     localStorageService: localStorageService,
///   );
/// });
/// ```
final tileVisibilityProvider =
    StateNotifierProvider<TileVisibilityNotifier, TileVisibilityState>((ref) {
  // Import providers from core DI
  // Note: This will be imported from lib/core/di/providers.dart
  throw UnimplementedError(
    'tileVisibilityProvider must be initialized with actual service dependencies',
  );
});
