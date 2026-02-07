import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/tiles/core/providers/tile_config_provider.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'tile_config_provider_test.mocks.dart';

void main() {
  group('TileConfigProvider Tests', () {
    late TileConfigNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

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
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = TileConfigNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
      );
    });

    group('Initial State', () {
      test('initial state has empty configs', () {
        expect(notifier.state.configs, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchConfigs', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Future.value([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches configs from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([sampleTileConfig.toJson()]));

        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify state updated
        expect(notifier.state.configs, hasLength(1));
        expect(notifier.state.configs.first.id, equals('tile_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads configs from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleTileConfig.toJson()]);

        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any, columns: anyNamed('columns')));

        // Verify state updated from cache
        expect(notifier.state.configs, hasLength(1));
        expect(notifier.state.configs.first.id, equals('tile_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenThrow(Exception('Database error'));

        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.configs, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([sampleTileConfig.toJson()]));

        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any, columns: anyNamed('columns'))).called(1);
      });
    });

    group('getConfigsForScreen', () {
      test('filters configs by screen ID', () async {
        final config1 = sampleTileConfig;
        final config2 = sampleTileConfig.copyWith(
          id: 'tile_2',
          screenId: 'calendar',
        );

        // Setup state with multiple configs
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([
          config1.toJson(),
          config2.toJson(),
        ]));

        await notifier.fetchAllConfigs();

        // Test filtering
        final homeConfigs = notifier.getConfigsForScreen('home');
        expect(homeConfigs, hasLength(1));
        expect(homeConfigs.first.screenId, equals('home'));

        final calendarConfigs = notifier.getConfigsForScreen('calendar');
        expect(calendarConfigs, hasLength(1));
        expect(calendarConfigs.first.screenId, equals('calendar'));
      });

      test('sorts configs by display order', () async {
        final config1 = sampleTileConfig.copyWith(displayOrder: 3);
        final config2 = sampleTileConfig.copyWith(
          id: 'tile_2',
          displayOrder: 1,
        );
        final config3 = sampleTileConfig.copyWith(
          id: 'tile_3',
          displayOrder: 2,
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([
          config1.toJson(),
          config2.toJson(),
          config3.toJson(),
        ]));

        await notifier.fetchAllConfigs();

        final configs = notifier.getConfigsForScreen('home');
        expect(configs[0].displayOrder, equals(1));
        expect(configs[1].displayOrder, equals(2));
        expect(configs[2].displayOrder, equals(3));
      });
    });

    group('getVisibleConfigs', () {
      test('filters by screen, role, and visibility', () async {
        final visibleConfig = sampleTileConfig.copyWith(isVisible: true);
        final hiddenConfig = sampleTileConfig.copyWith(
          id: 'tile_2',
          isVisible: false,
        );
        final followerConfig = sampleTileConfig.copyWith(
          id: 'tile_3',
          role: UserRole.follower,
          isVisible: true,
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([
          visibleConfig.toJson(),
          hiddenConfig.toJson(),
          followerConfig.toJson(),
        ]));

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
      test('updates visibility in database and state', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([sampleTileConfig.toJson()]));
        await notifier.fetchAllConfigs();

        // Setup update mock
        when(mockDatabaseService.update(any)).thenReturn(MockPostgrestUpdateBuilder());

        await notifier.updateVisibility(
          configId: 'tile_1',
          isVisible: false,
        );

        // Verify database update
        verify(mockDatabaseService.update(any)).called(1);

        // Verify state updated
        final config = notifier.state.configs.firstWhere((c) => c.id == 'tile_1');
        expect(config.isVisible, isFalse);
      });
    });

    group('Cache Management', () {
      test('saves fetched configs to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any, columns: anyNamed('columns')))
            .thenReturn(MockPostgrestBuilder([sampleTileConfig.toJson()]));

        await notifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify cache put was called
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });
  });
}

// Mock builders for Postgrest operations
class MockPostgrestBuilder {
  final List<Map<String, dynamic>> data;

  MockPostgrestBuilder(this.data);

  MockPostgrestBuilder eq(String column, dynamic value) => this;
  MockPostgrestBuilder order(String column) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}

class MockPostgrestUpdateBuilder {
  MockPostgrestUpdateBuilder eq(String column, dynamic value) => this;
  Future<void> update(Map<String, dynamic> data) async {}
}
