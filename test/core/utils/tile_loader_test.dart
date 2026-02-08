import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/utils/tile_loader.dart';

import '../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'tile_loader_test.mocks.dart';

void main() {
  group('TileLoader', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

    // Sample tile config data
    final sampleTileConfig1 = TileConfig(
      id: 'tile_1',
      screenId: 'home',
      tileDefinitionId: 'def_1',
      role: UserRole.owner,
      displayOrder: 1,
      isVisible: true,
      params: {'key': 'value'},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final sampleTileConfig2 = TileConfig(
      id: 'tile_2',
      screenId: 'home',
      tileDefinitionId: 'def_2',
      role: UserRole.owner,
      displayOrder: 2,
      isVisible: true,
      params: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final sampleTileConfig3 = TileConfig(
      id: 'tile_3',
      screenId: 'home',
      tileDefinitionId: 'def_3',
      role: UserRole.owner,
      displayOrder: 3,
      isVisible: false, // Not visible
      params: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      // Create a ProviderContainer with overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('loadForScreen', () {
      test('loads from cache when available and forceRefresh is false',
          () async {
        // Setup cache to return data
        final cachedData = [
          sampleTileConfig1.toJson(),
          sampleTileConfig2.toJson(),
        ];
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => cachedData);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: false,
        );

        // Verify cache was used
        verify(mockCacheService.get<List<Map<String, dynamic>>>(any)).called(1);
        verifyNever(mockDatabaseService.select(any));

        // Verify results
        expect(result, hasLength(2));
        expect(result.first.id, equals('tile_1'));
        expect(result.last.id, equals('tile_2'));
      });

      test('loads from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            sampleTileConfig1.toJson(),
            sampleTileConfig2.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: false,
        );

        // Verify database was called
        verify(mockDatabaseService.select(any)).called(1);
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);

        // Verify results
        expect(result, hasLength(2));
        expect(result.first.id, equals('tile_1'));
      });

      test('bypasses cache when forceRefresh is true', () async {
        // Setup mocks
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            sampleTileConfig1.toJson(),
            sampleTileConfig2.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify cache was bypassed
        verifyNever(mockCacheService.get<List<Map<String, dynamic>>>(any));
        verify(mockDatabaseService.select(any)).called(1);
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);

        // Verify results
        expect(result, hasLength(2));
      });

      test('filters out invisible tiles', () async {
        // Setup database to return tiles including invisible ones
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            sampleTileConfig1.toJson(),
            sampleTileConfig2.toJson(),
            sampleTileConfig3.toJson(), // This one is invisible
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify invisible tile was filtered out
        expect(result, hasLength(2));
        expect(result.where((t) => t.id == 'tile_3'), isEmpty);
      });

      test('sorts tiles by display order', () async {
        // Create tiles with different display orders
        final unorderedTile1 = TileConfig(
          id: 'tile_high',
          screenId: 'home',
          tileDefinitionId: 'def_1',
          role: UserRole.owner,
          displayOrder: 10,
          isVisible: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final unorderedTile2 = TileConfig(
          id: 'tile_low',
          screenId: 'home',
          tileDefinitionId: 'def_2',
          role: UserRole.owner,
          displayOrder: 1,
          isVisible: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final unorderedTile3 = TileConfig(
          id: 'tile_mid',
          screenId: 'home',
          tileDefinitionId: 'def_3',
          role: UserRole.owner,
          displayOrder: 5,
          isVisible: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Setup database to return tiles in unordered sequence
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            unorderedTile1.toJson(),
            unorderedTile2.toJson(),
            unorderedTile3.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify tiles are sorted by displayOrder
        expect(result, hasLength(3));
        expect(result[0].id, equals('tile_low')); // displayOrder: 1
        expect(result[1].id, equals('tile_mid')); // displayOrder: 5
        expect(result[2].id, equals('tile_high')); // displayOrder: 10
      });

      test('queries database with correct parameters', () async {
        // Setup mocks
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        final mockBuilder = FakePostgrestBuilder([]);
        when(mockDatabaseService.select(any)).thenReturn(mockBuilder);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'calendar',
          role: UserRole.follower,
        );

        // Verify database was called with correct table
        verify(mockDatabaseService.select('tile_configs')).called(1);
      });

      test('handles corrupted cache gracefully', () async {
        // Setup cache to return corrupted data that cannot be parsed
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => [
                  {'invalid': 'data'}
                ]);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            sampleTileConfig1.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify it falls back to database
        verify(mockDatabaseService.select(any)).called(1);
        expect(result, hasLength(1));
      });

      test('caches results after loading from database', () async {
        // Setup mocks
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            sampleTileConfig1.toJson(),
            sampleTileConfig2.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify cache.put was called with correct key
        verify(mockCacheService.put(
          'tile_configs_home_owner',
          any,
          ttlMinutes: anyNamed('ttlMinutes'),
        )).called(1);
      });

      test('works with different screen IDs and roles', () async {
        // Test with calendar screen and follower role
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'calendar',
          role: UserRole.follower,
        );

        // Verify correct cache key was used
        verify(mockCacheService.put(
          'tile_configs_calendar_follower',
          any,
          ttlMinutes: anyNamed('ttlMinutes'),
        )).called(1);
      });
    });

    group('clearCache', () {
      test('clears cache for specific screen and role', () async {
        when(mockCacheService.delete(any)).thenAnswer((_) async => {});

        await TileLoader.clearCache(
          cacheService: mockCacheService,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Verify delete was called with correct key
        verify(mockCacheService.delete('tile_configs_home_owner')).called(1);
      });

      test('uses correct cache key format', () async {
        when(mockCacheService.delete(any)).thenAnswer((_) async => {});

        await TileLoader.clearCache(
          cacheService: mockCacheService,
          screenId: 'calendar',
          role: UserRole.follower,
        );

        // Verify delete was called with correct key
        verify(mockCacheService.delete('tile_configs_calendar_follower'))
            .called(1);
      });
    });

    group('clearAllCaches', () {
      test('clears cache for all known screens and roles', () async {
        when(mockCacheService.delete(any)).thenAnswer((_) async => {});

        await TileLoader.clearAllCaches(cacheService: mockCacheService);

        // Verify delete was called for each screen and role combination
        // 4 screens * 2 roles = 8 calls
        verify(mockCacheService.delete(any)).called(8);

        // Verify specific combinations
        verify(mockCacheService.delete('tile_configs_home_owner')).called(1);
        verify(mockCacheService.delete('tile_configs_home_follower')).called(1);
        verify(mockCacheService.delete('tile_configs_calendar_owner'))
            .called(1);
        verify(mockCacheService.delete('tile_configs_calendar_follower'))
            .called(1);
        verify(mockCacheService.delete('tile_configs_gallery_owner')).called(1);
        verify(mockCacheService.delete('tile_configs_gallery_follower'))
            .called(1);
        verify(mockCacheService.delete('tile_configs_registry_owner'))
            .called(1);
        verify(mockCacheService.delete('tile_configs_registry_follower'))
            .called(1);
      });
    });

    group('edge cases', () {
      test('handles empty database response', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result, isEmpty);
      });

      test('handles tiles with same display order', () async {
        // Create tiles with same display order
        final tile1 = TileConfig(
          id: 'tile_a',
          screenId: 'home',
          tileDefinitionId: 'def_1',
          role: UserRole.owner,
          displayOrder: 5,
          isVisible: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final tile2 = TileConfig(
          id: 'tile_b',
          screenId: 'home',
          tileDefinitionId: 'def_2',
          role: UserRole.owner,
          displayOrder: 5,
          isVisible: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            tile1.toJson(),
            tile2.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Both tiles should be present
        expect(result, hasLength(2));
        expect(result.map((t) => t.displayOrder).toSet(), equals({5}));
      });

      test('handles null params in tile config', () async {
        final tileWithNullParams = TileConfig(
          id: 'tile_null',
          screenId: 'home',
          tileDefinitionId: 'def_1',
          role: UserRole.owner,
          displayOrder: 1,
          isVisible: true,
          params: null,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder([
            tileWithNullParams.toJson(),
          ]),
        );
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result, hasLength(1));
        expect(result.first.params, isNull);
      });
    });
  });
}
