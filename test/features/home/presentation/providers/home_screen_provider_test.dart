import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/tiles/core/providers/tile_config_provider.dart';

@GenerateMocks([DatabaseService, CacheService, Ref])
import 'home_screen_provider_test.mocks.dart';

void main() {
  group('HomeScreenNotifier Tests', () {
    late HomeScreenNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRef mockRef;

    final sampleTileConfig = TileConfig(
      id: 'tile_1',
      screenId: 'home',
      tileType: 'upcoming_events',
      displayName: 'Upcoming Events',
      order: 0,
      isEnabled: true,
      ownerVisible: true,
      followerVisible: true,
      settings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRef = MockRef();

      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = HomeScreenNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        ref: mockRef,
      );
    });

    group('Initial State', () {
      test('initial state has empty tiles', () {
        expect(notifier.state.tiles, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.selectedBabyProfileId, isNull);
        expect(notifier.state.selectedRole, isNull);
        expect(notifier.state.lastRefreshed, isNull);
      });
    });

    group('loadTiles', () {
      test('sets loading state while fetching', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        final future = notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.isLoading, isTrue);
        await future;
      });

      test('loads tiles from cache when available', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => [
              sampleTileConfig.toJson(),
            ]);

        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.tiles, hasLength(1));
        expect(notifier.state.tiles.first.id, equals('tile_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.selectedBabyProfileId, equals('profile_1'));
        expect(notifier.state.selectedRole, equals(UserRole.owner));
        expect(notifier.state.lastRefreshed, isNotNull);
      });

      test('fetches tiles from provider when cache is empty', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.tiles, hasLength(1));
        expect(notifier.state.tiles.first.id, equals('tile_1'));
        expect(notifier.state.isLoading, isFalse);
        verify(mockCacheService.put(any, any, ttlMinutes: 30)).called(1);
      });

      test('filters out disabled tiles', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final disabledTile = sampleTileConfig.copyWith(
          id: 'tile_2',
          isEnabled: false,
        );

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig, disabledTile],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.tiles, hasLength(1));
        expect(notifier.state.tiles.first.isEnabled, isTrue);
      });

      test('sorts tiles by order', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final tile2 = sampleTileConfig.copyWith(id: 'tile_2', order: 2);
        final tile1 = sampleTileConfig.copyWith(id: 'tile_3', order: 1);

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [tile2, sampleTileConfig, tile1],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.tiles, hasLength(3));
        expect(notifier.state.tiles[0].order, equals(0));
        expect(notifier.state.tiles[1].order, equals(1));
        expect(notifier.state.tiles[2].order, equals(2));
      });

      test('handles errors gracefully', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);

        final mockTileConfigNotifier = MockTileConfigNotifier();
        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenThrow(Exception('Network error'));

        await notifier.loadTiles(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Network error'));
        expect(notifier.state.tiles, isEmpty);
      });
    });

    group('refresh', () {
      test('refreshes tiles with force refresh', () async {
        // Setup initial state
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          selectedRole: UserRole.owner,
        );

        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: true,
        )).thenAnswer((_) async => {});

        await notifier.refresh();

        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.tiles, hasLength(1));
        verify(mockTileConfigNotifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        )).called(1);
      });

      test('does not refresh when baby profile is missing', () async {
        await notifier.refresh();

        verifyNever(mockRef.read(any));
      });

      test('handles refresh error', () async {
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          selectedRole: UserRole.owner,
        );

        final mockTileConfigNotifier = MockTileConfigNotifier();
        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenThrow(Exception('Refresh failed'));

        await notifier.refresh();

        expect(notifier.state.isRefreshing, isFalse);
        expect(notifier.state.error, contains('Refresh failed'));
      });
    });

    group('onPullToRefresh', () {
      test('calls refresh method', () async {
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          selectedRole: UserRole.owner,
        );

        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.onPullToRefresh();

        verify(mockTileConfigNotifier.fetchConfigs(
          screenId: 'home',
          role: UserRole.owner,
          forceRefresh: true,
        )).called(1);
      });
    });

    group('switchBabyProfile', () {
      test('loads tiles for new baby profile', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.switchBabyProfile(
          babyProfileId: 'profile_2',
          role: UserRole.follower,
        );

        expect(notifier.state.selectedBabyProfileId, equals('profile_2'));
        expect(notifier.state.selectedRole, equals(UserRole.follower));
      });
    });

    group('toggleRole', () {
      test('toggles user role', () async {
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          selectedRole: UserRole.owner,
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.toggleRole(UserRole.follower);

        expect(notifier.state.selectedRole, equals(UserRole.follower));
      });

      test('does not toggle when baby profile is missing', () async {
        await notifier.toggleRole(UserRole.follower);

        verifyNever(mockRef.read(any));
      });
    });

    group('retry', () {
      test('retries loading tiles after error', () async {
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
          selectedRole: UserRole.owner,
          error: 'Previous error',
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final mockTileConfigNotifier = MockTileConfigNotifier();
        final mockTileConfigState = TileConfigState(
          configs: [sampleTileConfig],
          isLoading: false,
        );

        when(mockRef.read(tileConfigProvider.notifier))
            .thenReturn(mockTileConfigNotifier);
        when(mockRef.read(tileConfigProvider)).thenReturn(mockTileConfigState);
        when(mockTileConfigNotifier.fetchConfigs(
          screenId: any,
          role: any,
          forceRefresh: any,
        )).thenAnswer((_) async => {});

        await notifier.retry();

        expect(notifier.state.error, isNull);
        expect(notifier.state.tiles, hasLength(1));
      });
    });
  });
}

// Mock TileConfigNotifier
class MockTileConfigNotifier extends Mock implements TileConfigNotifier {
  @override
  Future<void> fetchConfigs({
    required String screenId,
    required UserRole role,
    bool forceRefresh = false,
  }) =>
      super.noSuchMethod(
        Invocation.method(#fetchConfigs, [], {
          #screenId: screenId,
          #role: role,
          #forceRefresh: forceRefresh,
        }),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}
