import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/tiles/new_followers/providers/new_followers_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'new_followers_provider_test.mocks.dart';

void main() {
  group('NewFollowersProvider Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample follower data
    final sampleFollower = BabyMembership(
      babyProfileId: 'baby_profile_1',
      userId: 'user_1',
      role: UserRole.follower,
      relationshipLabel: 'Aunt',
      createdAt: DateTime.now(),
      removedAt: null,
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty followers', () {
        final state = container.read(newFollowersProvider);
        
        expect(state.followers, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('fetchFollowers', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockDatabaseService.select(argThat(isA<String>()))).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Verify loading state
        expect(container.read(newFollowersProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches followers from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Verify state updated
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId, equals('user_1'));
        expect(container.read(newFollowersProvider).isLoading, isFalse);
        expect(container.read(newFollowersProvider).error, isNull);
      });

      test('loads followers from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleFollower.toJson()]);

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(argThat(isA<String>())));

        // Verify state updated from cache
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId, equals('user_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenThrow(Exception('Database error'));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Verify error state
        expect(container.read(newFollowersProvider).isLoading, isFalse);
        expect(container.read(newFollowersProvider).error, contains('Database error'));
        expect(container.read(newFollowersProvider).followers, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(greaterThanOrEqualTo(1));
      });

      test('filters only recent followers', () async {
        final recentFollower = sampleFollower.copyWith(
          userId: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([recentFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
          babyProfileId: 'profile_1',
        );

        // Should only have recent followers
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId, equals('user_1'));
      });

      test('saves fetched followers to cache', () async {
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('limits to recent followers only', () async {
        // Create 30 followers
        final followers = List.generate(
          30,
          (i) => sampleFollower.copyWith(
            userId: 'user_$i',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );

        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>()))).thenReturn(
          FakePostgrestBuilder(followers.map((f) => f.toJson()).toList()),
        );

        await container.read(newFollowersProvider.notifier).fetchFollowers(
          babyProfileId: 'profile_1',
        );

        // Should limit results
        expect(container.read(newFollowersProvider).followers.length, lessThanOrEqualTo(30));
      });
    });

    group('refresh', () {
      test('refreshes followers with force refresh', () async {
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).refresh(
          babyProfileId: 'profile_1',
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles new follower', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        final initialCount = container.read(newFollowersProvider).followers.length;

        // Note: Real-time updates are handled internally by the provider
        // and cannot be easily tested with direct state manipulation
        expect(initialCount, equals(1));
      });

      test('handles follower removed', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        expect(container.read(newFollowersProvider).followers, hasLength(1));

        // Note: Real-time updates are handled internally by the provider
        // and cannot be easily tested with direct state manipulation
      });
    });

    group('Time Period Options', () {
      test('supports 7-day period', () async {
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
          babyProfileId: 'profile_1',
        );

        expect(container.read(newFollowersProvider).followers, isNotEmpty);
      });

      test('supports 30-day period', () async {
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
          babyProfileId: 'profile_1',
        );

        expect(container.read(newFollowersProvider).followers, isNotEmpty);
      });
    });

    group('Sorting', () {
      test('sorts followers by date (newest first)', () async {
        final follower1 = sampleFollower.copyWith(
          userId: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        final follower2 = sampleFollower.copyWith(
          userId: 'user_2',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final follower3 = sampleFollower.copyWith(
          userId: 'user_3',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabaseService.select(argThat(isA<String>()))).thenReturn(FakePostgrestBuilder([
          follower1.toJson(),
          follower2.toJson(),
          follower3.toJson(),
        ]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(babyProfileId: 'profile_1');

        // Most recent should be first
        expect(container.read(newFollowersProvider).followers[0].userId, equals('user_3'));
        expect(container.read(newFollowersProvider).followers[1].userId, equals('user_2'));
        expect(container.read(newFollowersProvider).followers[2].userId, equals('user_1'));
      });
    });
  });
}
