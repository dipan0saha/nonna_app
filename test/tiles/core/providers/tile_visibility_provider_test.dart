import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/tiles/core/providers/tile_visibility_provider.dart';

@GenerateMocks([CacheService, LocalStorageService])
import 'tile_visibility_provider_test.mocks.dart';

void main() {
  group('TileVisibilityProvider Tests', () {
    late TileVisibilityNotifier notifier;
    late MockCacheService mockCacheService;
    late MockLocalStorageService mockLocalStorageService;
    late ProviderContainer container;

    setUp(() {
      mockCacheService = MockCacheService();
      mockLocalStorageService = MockLocalStorageService();

      // Setup mock local storage
      when(mockLocalStorageService.isInitialized).thenReturn(true);

      // Create provider container with overrides
      container = ProviderContainer(
        overrides: [
          cacheServiceProvider.overrideWithValue(mockCacheService),
          localStorageServiceProvider.overrideWithValue(mockLocalStorageService),
        ],
      );

      notifier = container.read(tileVisibilityProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty visibility map', () {
        expect(notifier.state.visibilityMap, isEmpty);
        expect(notifier.state.featureFlags, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('loadPreferences', () {
      test('loads visibility preferences from storage', () async {
        final testVisibilityMap = {'tile_1': true, 'tile_2': false};

        when(mockLocalStorageService.getString(any))
            .thenAnswer((_) async => null);
        when(mockLocalStorageService.getObject(any))
            .thenAnswer((_) async => testVisibilityMap);

        await notifier.loadPreferences();

        expect(notifier.state.visibilityMap, equals(testVisibilityMap));
        expect(notifier.state.isLoading, isFalse);
      });

      test('handles errors gracefully', () async {
        when(mockLocalStorageService.getString(any))
            .thenThrow(Exception('Storage error'));

        await notifier.loadPreferences();

        expect(notifier.state.error, contains('Storage error'));
        expect(notifier.state.isLoading, isFalse);
      });

      test('loads user-specific preferences when userId provided', () async {
        when(mockLocalStorageService.getString(any))
            .thenAnswer((_) async => null);
        when(mockLocalStorageService.getObject(any))
            .thenAnswer((_) async => {'tile_1': true});

        await notifier.loadPreferences(userId: 'user_123');

        // Verify correct key was used
        verify(mockLocalStorageService.getObject(
          argThat(contains('user_123')),
        )).called(1);
      });
    });

    group('isTileVisible', () {
      test('returns true for tiles not in visibility map', () {
        expect(notifier.isTileVisible('tile_1'), isTrue);
      });

      test('returns correct visibility state for tiles in map', () async {
        when(mockLocalStorageService.getString(any))
            .thenAnswer((_) async => null);
        when(mockLocalStorageService.getObject(any))
            .thenAnswer((_) async => {'tile_1': false, 'tile_2': true});

        await notifier.loadPreferences();

        expect(notifier.isTileVisible('tile_1'), isFalse);
        expect(notifier.isTileVisible('tile_2'), isTrue);
        expect(notifier.isTileVisible('tile_3'), isTrue);
      });
    });

    group('setTileVisibility', () {
      test('updates tile visibility in state', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(
          tileId: 'tile_1',
          isVisible: false,
        );

        expect(notifier.isTileVisible('tile_1'), isFalse);
      });

      test('persists visibility to storage', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(
          tileId: 'tile_1',
          isVisible: false,
        );

        verify(mockLocalStorageService.setObject(any, any)).called(1);
      });

      test('handles user-specific preferences', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(
          tileId: 'tile_1',
          isVisible: false,
          userId: 'user_123',
        );

        verify(mockLocalStorageService.setObject(
          argThat(contains('user_123')),
          any,
        )).called(1);
      });
    });

    group('Convenience Methods', () {
      test('hideTile sets visibility to false', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.hideTile('tile_1');

        expect(notifier.isTileVisible('tile_1'), isFalse);
      });

      test('showTile sets visibility to true', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        // First hide the tile
        await notifier.hideTile('tile_1');
        expect(notifier.isTileVisible('tile_1'), isFalse);

        // Then show it
        await notifier.showTile('tile_1');
        expect(notifier.isTileVisible('tile_1'), isTrue);
      });

      test('toggleTileVisibility flips current state', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        // Initially true (default)
        expect(notifier.isTileVisible('tile_1'), isTrue);

        // Toggle to false
        await notifier.toggleTileVisibility('tile_1');
        expect(notifier.isTileVisible('tile_1'), isFalse);

        // Toggle back to true
        await notifier.toggleTileVisibility('tile_1');
        expect(notifier.isTileVisible('tile_1'), isTrue);
      });
    });

    group('resetPreferences', () {
      test('clears visibility map', () async {
        // Setup initial state
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);
        when(mockLocalStorageService.remove(any)).thenAnswer((_) async => null);

        await notifier.setTileVisibility(
          tileId: 'tile_1',
          isVisible: false,
        );
        expect(notifier.state.visibilityMap, isNotEmpty);

        // Reset
        await notifier.resetPreferences();

        expect(notifier.state.visibilityMap, isEmpty);
        verify(mockLocalStorageService.remove(any)).called(1);
      });
    });

    group('Feature Flags', () {
      test('isFeatureEnabled returns false for unknown features', () {
        expect(notifier.isFeatureEnabled('unknown_feature'), isFalse);
      });

      test('setFeatureFlag updates state', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setFeatureFlag(
          featureName: 'new_feature',
          isEnabled: true,
        );

        expect(notifier.isFeatureEnabled('new_feature'), isTrue);
      });

      test('setFeatureFlag persists to storage', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setFeatureFlag(
          featureName: 'new_feature',
          isEnabled: true,
        );

        verify(mockLocalStorageService.setObject(any, any)).called(1);
      });

      test('loadRemoteFeatureFlags loads from storage', () async {
        final testFlags = {'feature_1': true, 'feature_2': false};

        when(mockLocalStorageService.getObject(any))
            .thenAnswer((_) async => testFlags);

        await notifier.loadRemoteFeatureFlags();

        expect(notifier.state.featureFlags, equals(testFlags));
      });
    });

    group('shouldRenderTile', () {
      test('returns false when tile is not visible', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(
          tileId: 'tile_1',
          isVisible: false,
        );

        expect(notifier.shouldRenderTile('tile_1'), isFalse);
      });

      test('returns false when required feature is disabled', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setFeatureFlag(
          featureName: 'premium',
          isEnabled: false,
        );

        expect(
          notifier.shouldRenderTile('tile_1', requiredFeature: 'premium'),
          isFalse,
        );
      });

      test('returns true when tile visible and no feature required', () {
        expect(notifier.shouldRenderTile('tile_1'), isTrue);
      });

      test('returns true when tile visible and feature enabled', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setFeatureFlag(
          featureName: 'premium',
          isEnabled: true,
        );

        expect(
          notifier.shouldRenderTile('tile_1', requiredFeature: 'premium'),
          isTrue,
        );
      });
    });

    group('getVisibleTiles', () {
      test('returns list of visible tile IDs', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(tileId: 'tile_1', isVisible: true);
        await notifier.setTileVisibility(tileId: 'tile_2', isVisible: false);
        await notifier.setTileVisibility(tileId: 'tile_3', isVisible: true);

        final visibleTiles = notifier.getVisibleTiles();

        expect(visibleTiles, hasLength(2));
        expect(visibleTiles, contains('tile_1'));
        expect(visibleTiles, contains('tile_3'));
        expect(visibleTiles, isNot(contains('tile_2')));
      });
    });

    group('getHiddenTiles', () {
      test('returns list of hidden tile IDs', () async {
        when(mockLocalStorageService.setObject(any, any))
            .thenAnswer((_) async => null);

        await notifier.setTileVisibility(tileId: 'tile_1', isVisible: true);
        await notifier.setTileVisibility(tileId: 'tile_2', isVisible: false);
        await notifier.setTileVisibility(tileId: 'tile_3', isVisible: false);

        final hiddenTiles = notifier.getHiddenTiles();

        expect(hiddenTiles, hasLength(2));
        expect(hiddenTiles, contains('tile_2'));
        expect(hiddenTiles, contains('tile_3'));
        expect(hiddenTiles, isNot(contains('tile_1')));
      });
    });
  });
}
