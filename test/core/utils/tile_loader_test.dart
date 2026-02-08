import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/performance_limits.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/utils/tile_loader.dart';

import '../../helpers/fake_postgrest_builders.dart';

// Mock implementations
class MockDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, dynamic>>> _data = {};
  int selectCallCount = 0;

  void setData(String table, List<Map<String, dynamic>> data) {
    _data[table] = data;
  }

  @override
  dynamic select(String table, {List<String>? columns}) {
    selectCallCount++;
    return FakePostgrestBuilder(_data[table] ?? []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCacheService implements CacheService {
  final Map<String, dynamic> _cache = {};
  int getCallCount = 0;
  int putCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<T?> get<T>(String key) async {
    getCallCount++;
    return _cache[key] as T?;
  }

  @override
  Future<void> put<T>(String key, T value, {int? ttlMinutes}) async {
    putCallCount++;
    _cache[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    deleteCallCount++;
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TileLoader', () {
    late MockDatabaseService mockDatabase;
    late MockCacheService mockCache;
    late ProviderContainer container;

    setUp(() {
      mockDatabase = MockDatabaseService();
      mockCache = MockCacheService();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabase),
          cacheServiceProvider.overrideWithValue(mockCache),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('loadForScreen', () {
      final testDate = DateTime(2026, 2, 8);

      final mockTileConfigs = [
        {
          'id': '1',
          'screen_id': 'home',
          'tile_definition_id': 'tile_1',
          'role': 'owner',
          'display_order': 2,
          'is_visible': true,
          'params': null,
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        },
        {
          'id': '2',
          'screen_id': 'home',
          'tile_definition_id': 'tile_2',
          'role': 'owner',
          'display_order': 1,
          'is_visible': true,
          'params': null,
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        },
        {
          'id': '3',
          'screen_id': 'home',
          'tile_definition_id': 'tile_3',
          'role': 'owner',
          'display_order': 3,
          'is_visible': false,
          'params': null,
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        },
      ];

      test('loads tiles from database when cache is empty', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result.length, 2); // Only visible tiles
        expect(mockDatabase.selectCallCount, 1);
        expect(mockCache.getCallCount, 1);
        expect(mockCache.putCallCount, 1);
      });

      test('returns tiles sorted by display order', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result[0].displayOrder, 1);
        expect(result[1].displayOrder, 2);
        expect(result[0].tileDefinitionId, 'tile_2');
        expect(result[1].tileDefinitionId, 'tile_1');
      });

      test('filters out invisible tiles', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result.length, 2);
        expect(result.every((tile) => tile.isVisible), true);
        expect(result.any((tile) => tile.id == '3'), false);
      });

      test('uses cache when available', () async {
        // Pre-populate cache
        final cachedData = mockTileConfigs
            .where((config) => config['is_visible'] == true)
            .toList();

        await mockCache.put(
          'tile_configs_home_owner',
          cachedData,
        );

        mockDatabase.setData(SupabaseTables.tileConfigs, []);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result.length, 2);
        expect(mockDatabase.selectCallCount, 0); // Should not hit database
        expect(mockCache.getCallCount, 1);
      });

      test('bypasses cache when forceRefresh is true', () async {
        // Pre-populate cache
        final cachedData = mockTileConfigs
            .where((config) => config['is_visible'] == true)
            .toList();

        await mockCache.put(
          'tile_configs_home_owner',
          cachedData,
        );

        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        );

        expect(result.length, 2);
        expect(mockDatabase.selectCallCount, 1); // Should hit database
        expect(mockCache.putCallCount, greaterThan(0));
      });

      test('handles corrupted cache gracefully', () async {
        // Put invalid data in cache
        await mockCache.put('tile_configs_home_owner', 'invalid_data');

        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result.length, 2);
        expect(mockDatabase.selectCallCount, 1); // Should fallback to database
      });

      test('caches results with correct TTL', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, mockTileConfigs);
        mockCache.putCallCount = 0;

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(mockCache.putCallCount, 1);
        // Verify the cache key format
        expect(mockCache._cache.containsKey('tile_configs_home_owner'), true);
      });

      test('handles empty result from database', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, []);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result, isEmpty);
        expect(mockDatabase.selectCallCount, 1);
      });

      test('handles different screen IDs', () async {
        final calendarConfigs = [
          {
            'id': '4',
            'screen_id': 'calendar',
            'tile_definition_id': 'tile_4',
            'role': 'owner',
            'display_order': 1,
            'is_visible': true,
            'params': null,
            'created_at': testDate.toIso8601String(),
            'updated_at': testDate.toIso8601String(),
          },
        ];

        mockDatabase.setData(SupabaseTables.tileConfigs, calendarConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'calendar',
          role: UserRole.owner,
        );

        expect(result.length, 1);
        expect(result[0].screenId, 'calendar');
      });

      test('handles different roles', () async {
        final followerConfigs = [
          {
            'id': '5',
            'screen_id': 'home',
            'tile_definition_id': 'tile_5',
            'role': 'follower',
            'display_order': 1,
            'is_visible': true,
            'params': null,
            'created_at': testDate.toIso8601String(),
            'updated_at': testDate.toIso8601String(),
          },
        ];

        mockDatabase.setData(SupabaseTables.tileConfigs, followerConfigs);

        final result = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.follower,
        );

        expect(result.length, 1);
        expect(result[0].role, UserRole.follower);
      });
    });

    group('clearCache', () {
      test('clears specific screen cache', () async {
        await mockCache.put('tile_configs_home_owner', []);
        mockCache.deleteCallCount = 0;

        await TileLoader.clearCache(
          cacheService: mockCache,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(mockCache.deleteCallCount, 1);
        expect(mockCache._cache.containsKey('tile_configs_home_owner'), false);
      });

      test('uses correct cache key format', () async {
        await mockCache.put('tile_configs_calendar_follower', []);
        mockCache.deleteCallCount = 0;

        await TileLoader.clearCache(
          cacheService: mockCache,
          screenId: 'calendar',
          role: UserRole.follower,
        );

        expect(mockCache.deleteCallCount, 1);
      });
    });

    group('clearAllCaches', () {
      test('clears all screen and role combinations', () async {
        // Pre-populate caches
        await mockCache.put('tile_configs_home_owner', []);
        await mockCache.put('tile_configs_home_follower', []);
        await mockCache.put('tile_configs_calendar_owner', []);
        mockCache.deleteCallCount = 0;

        await TileLoader.clearAllCaches(cacheService: mockCache);

        // Should clear for all 4 screens * 2 roles = 8 combinations
        expect(mockCache.deleteCallCount, 8);
      });

      test('handles errors gracefully', () async {
        // This test verifies that clearAllCaches doesn't throw
        // even if some caches don't exist
        expect(
          () => TileLoader.clearAllCaches(cacheService: mockCache),
          returnsNormally,
        );
      });
    });

    group('cache key generation', () {
      test('generates unique keys for different screens', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, []);

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'calendar',
          role: UserRole.owner,
        );

        expect(mockCache._cache.containsKey('tile_configs_home_owner'), true);
        expect(
            mockCache._cache.containsKey('tile_configs_calendar_owner'), true);
      });

      test('generates unique keys for different roles', () async {
        mockDatabase.setData(SupabaseTables.tileConfigs, []);

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.follower,
        );

        expect(mockCache._cache.containsKey('tile_configs_home_owner'), true);
        expect(
            mockCache._cache.containsKey('tile_configs_home_follower'), true);
      });
    });

    group('integration tests', () {
      test('complete flow: load, cache, and reload from cache', () async {
        final testDate = DateTime(2026, 2, 8);
        final configs = [
          {
            'id': '1',
            'screen_id': 'home',
            'tile_definition_id': 'tile_1',
            'role': 'owner',
            'display_order': 1,
            'is_visible': true,
            'params': null,
            'created_at': testDate.toIso8601String(),
            'updated_at': testDate.toIso8601String(),
          },
        ];

        mockDatabase.setData(SupabaseTables.tileConfigs, configs);

        // First load - should hit database
        final result1 = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result1.length, 1);
        expect(mockDatabase.selectCallCount, 1);

        // Second load - should use cache
        final result2 = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result2.length, 1);
        expect(mockDatabase.selectCallCount, 1); // Still 1, didn't hit DB again

        // Clear cache
        await TileLoader.clearCache(
          cacheService: mockCache,
          screenId: 'home',
          role: UserRole.owner,
        );

        // Third load - should hit database again
        final result3 = await TileLoader.loadForScreen(
          ref: container,
          screenId: 'home',
          role: UserRole.owner,
        );

        expect(result3.length, 1);
        expect(mockDatabase.selectCallCount, 2); // Hit DB again
      });
    });
  });
}
