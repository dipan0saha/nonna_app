import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService])
import 'home_screen_provider_test.mocks.dart';

void main() {
  group('HomeScreenNotifier Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;

    final sampleTileConfig = TileConfig(
      id: 'tile_1',
      screenId: 'home',
      tileDefinitionId: 'upcoming_events',
      role: UserRole.owner,
      displayOrder: 0,
      isVisible: true,
      params: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      // Provide dummy values for mockito null-safety
      provideDummy<String>('');
      
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();

      when(mockCacheService.isInitialized).thenReturn(true);

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

    group('Initial State', () {
      test('initial state has empty tiles', () {
        final state = container.read(homeScreenProvider);
        expect(state.tiles, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.isRefreshing, isFalse);
        expect(state.error, isNull);
        expect(state.selectedBabyProfileId, isNull);
        expect(state.selectedRole, isNull);
        expect(state.lastRefreshed, isNull);
      });
    });

    group('loadTiles', () {
      test('loads tiles from database when cache is empty', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final builder = FakePostgrestBuilder([sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any)).thenReturn(builder);

        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(homeScreenProvider);
        expect(state.tiles, hasLength(1));
        expect(state.tiles.first.id, equals('tile_1'));
        expect(state.isLoading, isFalse);
        expect(state.selectedBabyProfileId, equals('profile_1'));
        expect(state.selectedRole, equals(UserRole.owner));
        expect(state.lastRefreshed, isNotNull);
      });

      test('loads tiles from cache when available', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => [sampleTileConfig.toJson()]);

        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(homeScreenProvider);
        expect(state.tiles, hasLength(1));
        expect(state.tiles.first.id, equals('tile_1'));
        expect(state.isLoading, isFalse);
        expect(state.selectedBabyProfileId, equals('profile_1'));
        expect(state.selectedRole, equals(UserRole.owner));
      });

      test('handles errors gracefully', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Network error'));

        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(homeScreenProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Network error'));
        expect(state.tiles, isEmpty);
      });
    });

    group('refresh', () {
      test('refreshes tiles with force refresh', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final builder = FakePostgrestBuilder([sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any)).thenReturn(builder);

        final notifier = container.read(homeScreenProvider.notifier);
        
        // First load tiles
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Then refresh
        await notifier.refresh();

        final state = container.read(homeScreenProvider);
        expect(state.isRefreshing, isFalse);
        expect(state.tiles, hasLength(1));
      });

      test('does not refresh when baby profile is missing', () async {
        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.refresh();

        // Should not throw or call database
        verifyNever(mockDatabaseService.select(any));
      });
    });

    group('switchBabyProfile', () {
      test('loads tiles for new baby profile', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final builder = FakePostgrestBuilder([sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any)).thenReturn(builder);

        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.switchBabyProfile(
          babyProfileId: 'profile_2',
          role: UserRole.follower,
        );

        final state = container.read(homeScreenProvider);
        expect(state.selectedBabyProfileId, equals('profile_2'));
        expect(state.selectedRole, equals(UserRole.follower));
      });
    });

    group('toggleRole', () {
      test('toggles user role', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final builder = FakePostgrestBuilder([sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any)).thenReturn(builder);

        final notifier = container.read(homeScreenProvider.notifier);
        
        // First load with owner role
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Then toggle to follower
        await notifier.toggleRole(UserRole.follower);

        final state = container.read(homeScreenProvider);
        expect(state.selectedRole, equals(UserRole.follower));
      });

      test('does not toggle when baby profile is missing', () async {
        final notifier = container.read(homeScreenProvider.notifier);
        await notifier.toggleRole(UserRole.follower);

        verifyNever(mockDatabaseService.select(any));
      });
    });

    group('retry', () {
      test('retries loading tiles after error', () async {
        when(mockCacheService.get<List<Map<String, dynamic>>>(any))
            .thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .thenAnswer((_) async => {});

        final builder = FakePostgrestBuilder([sampleTileConfig.toJson()]);
        when(mockDatabaseService.select(any)).thenReturn(builder);

        final notifier = container.read(homeScreenProvider.notifier);
        
        // First load tiles
        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Retry
        await notifier.retry();

        final state = container.read(homeScreenProvider);
        expect(state.tiles, hasLength(1));
      });
    });
  });
}
