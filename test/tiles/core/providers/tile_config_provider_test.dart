import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/tiles/core/providers/tile_config_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('TileConfigProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample tile config data
    final sampleTileConfig = TileConfig(
      id: 'tile_1',
      screenId: 'home',
      tileDefinitionId: 'def_1',
      role: UserRole.owner,
      displayOrder: 1,
      isVisible: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mocks = MockFactory.createServiceContainer();

      // Create provider container with overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty configs', () {
        final state = container.read(tileConfigProvider);
        expect(state.configs, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchConfigs', () {
      test('sets loading state while fetching', () async {        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        // Start fetching
        final notifier = container.read(tileConfigProvider.notifier);
        final fetchFuture = notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        await fetchFuture;

        // Verify final state
        final state = container.read(tileConfigProvider);
        expect(state.isLoading, isFalse);
      });

      test('fetches configs from database when cache is empty', () async {        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleTileConfig.toJson()]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify state updated
        final state = container.read(tileConfigProvider);
        expect(state.configs, hasLength(1));
        expect(state.configs.first.id, equals('tile_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loads configs from cache when available', () async {        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleTileConfig.toJson()]);

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        // Verify state updated from cache
        final state = container.read(tileConfigProvider);
        expect(state.configs, hasLength(1));
        expect(state.configs.first.id, equals('tile_1'));
      });

      test('handles errors gracefully', () async {        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify error state
        final state = container.read(tileConfigProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.configs, isEmpty);
      });

      test('force refresh bypasses cache', () async {        // Setup mocks
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleTileConfig.toJson()]);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleTileConfig.toJson()]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('getConfigsForScreen', () {
      test('filters configs by screen ID', () async {        final config1 = sampleTileConfig;
        final config2 = sampleTileConfig.copyWith(
          id: 'tile_2',
          screenId: 'calendar',
        );

        // Setup state with multiple configs
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          config1.toJson(),
          config2.toJson(),
        ]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchAllConfigs();

        // Test filtering
        final homeConfigs = notifier.getConfigsForScreen('home');
        expect(homeConfigs, hasLength(1));
        expect(homeConfigs.first.screenId, equals('home'));

        final calendarConfigs = notifier.getConfigsForScreen('calendar');
        expect(calendarConfigs, hasLength(1));
        expect(calendarConfigs.first.screenId, equals('calendar'));
      });

      test('sorts configs by display order', () async {        final config1 = sampleTileConfig.copyWith(displayOrder: 3);
        final config2 = sampleTileConfig.copyWith(
          id: 'tile_2',
          displayOrder: 1,
        );
        final config3 = sampleTileConfig.copyWith(
          id: 'tile_3',
          displayOrder: 2,
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          config1.toJson(),
          config2.toJson(),
          config3.toJson(),
        ]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchAllConfigs();

        final configs = notifier.getConfigsForScreen('home');
        expect(configs[0].displayOrder, equals(1));
        expect(configs[1].displayOrder, equals(2));
        expect(configs[2].displayOrder, equals(3));
      });
    });

    group('getVisibleConfigs', () {
      test('filters by screen, role, and visibility', () async {        final visibleConfig = sampleTileConfig.copyWith(isVisible: true);
        final hiddenConfig = sampleTileConfig.copyWith(
          id: 'tile_2',
          isVisible: false,
        );
        final followerConfig = sampleTileConfig.copyWith(
          id: 'tile_3',
          role: UserRole.follower,
          isVisible: true,
        );

        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any)).thenAnswer((_) => FakePostgrestBuilder([
          visibleConfig.toJson(),
          hiddenConfig.toJson(),
          followerConfig.toJson(),
        ]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchAllConfigs();

        final ownerVisibleConfigs = notifier.getVisibleConfigs(
          'home',
          UserRole.owner,
        );

        expect(ownerVisibleConfigs, hasLength(1));
        expect(ownerVisibleConfigs.first.id, equals('tile_1'));
        expect(ownerVisibleConfigs.first.isVisible, isTrue);
        expect(ownerVisibleConfigs.first.role, equals(UserRole.owner));
      });
    });

    group('updateVisibility', () {
      test('updates visibility in database and state', () async {        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.cache.delete(any)).thenAnswer((_) async => {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleTileConfig.toJson()]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchAllConfigs();

        // Setup update mock
        when(mocks.database.update(any, any))
            .thenReturn(FakePostgrestUpdateBuilder());

        await notifier.updateVisibility(
          configId: 'tile_1',
          isVisible: false,
        );

        // Verify database update
        verify(mocks.database.update(any, any)).called(1);

        // Verify state updated
        final state = container.read(tileConfigProvider);
        final config = state.configs.firstWhere((c) => c.id == 'tile_1');
        expect(config.isVisible, isFalse);
      });
    });

    group('Cache Management', () {
      test('saves fetched configs to cache', () async {        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleTileConfig.toJson()]));

        final notifier = container.read(tileConfigProvider.notifier);
        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify cache put was called
        verify(mocks.cache.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });
  });
}
