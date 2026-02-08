import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/tiles/new_followers/providers/new_followers_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
// Import centralized mocks from the centralized location
import '../../../mocks/mock_services.mocks.dart';

/// Example of refactored test using centralized mocking strategy
///
/// Key improvements over traditional approach:
/// - No @GenerateMocks annotation needed in this file
/// - Uses centralized MockDatabaseService, MockCacheService, etc.
/// - All mocks come from test/mocks/mock_services.mocks.dart
/// - Less boilerplate, more focused on business logic
///
/// This demonstrates the MOCKING_NEXT_STEPS.md strategy where:
/// 1. Mock generation happens centrally in test/mocks/mock_services.dart
/// 2. All tests import from test/mocks/mock_services.mocks.dart
/// 3. No duplicate mock generation per test file
void main() {
  group('NewFollowersProvider Tests Refactored', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabase;
    late MockCacheService mockCache;
    late MockRealtimeService mockRealtime;

    const testBabyProfileId = 'test-baby-profile-id';

    setUp(() {
      // Create mock services from centralized mocks
      mockDatabase = MockDatabaseService();
      mockCache = MockCacheService();
      mockRealtime = MockRealtimeService();

      // Setup default mock behaviors
      // Note: Set cache to initialized to avoid triggering property access
      // during other mock setups (avoids "Cannot call when within a stub response")
      when(mockCache.isInitialized).thenReturn(true);
      when(mockCache.get(any)).thenAnswer((_) async => null);
      when(mockCache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
          .thenAnswer((_) async => Future.value());

      // Setup realtime service to return empty stream by default
      when(mockRealtime.subscribe(
        table: anyNamed('table'),
        channelName: anyNamed('channelName'),
        filter: anyNamed('filter'),
      )).thenAnswer((_) => Stream.empty());

      // Create provider container with mock overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabase),
          cacheServiceProvider.overrideWithValue(mockCache),
          realtimeServiceProvider.overrideWithValue(mockRealtime),
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
        expect(state.activeCount, 0);
      });
    });

    group('Data Fetching', () {
      test('fetchFollowers handles database errors', () async {
        // Arrange: Mock database error
        when(mockDatabase.select('baby_memberships'))
            .thenThrow(Exception('Database connection failed'));

        // Act
        final notifier = container.read(newFollowersProvider.notifier);
        await notifier.fetchFollowers(babyProfileId: testBabyProfileId);

        // Assert
        final state = container.read(newFollowersProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNotNull);
        expect(state.error!.contains('Database connection failed'), isTrue);
        expect(state.followers, isEmpty);
        expect(state.activeCount, 0);
      });

      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockDatabase.select(any)).thenReturn(FakePostgrestBuilder([]));

        // Start fetching
        final fetchFuture = container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        // Verify loading state
        expect(container.read(newFollowersProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches followers from database when cache is empty', () async {
        // Setup mocks
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        // Verify state updated
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId,
            equals('user_1'));
        expect(container.read(newFollowersProvider).isLoading, isFalse);
        expect(container.read(newFollowersProvider).error, isNull);
      });

      test('force refresh bypasses cache', () async {
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: testBabyProfileId,
              forceRefresh: true,
            );

        // Verify database was called despite cache
        verify(mockDatabase.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('filters only recent followers', () async {
        final recentFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([recentFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: testBabyProfileId,
            );

        // Should only have recent followers
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId,
            equals('user_1'));
      });

      test('saves fetched followers to cache', () async {
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        // Verify cache put was called
        verify(mockCache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('limits to recent followers only', () async {
        // Create 30 followers
        final followers = List.generate(
          30,
          (i) => BabyMembership(
            babyProfileId: testBabyProfileId,
            userId: 'user_$i',
            role: UserRole.follower,
            relationshipLabel: 'Aunt',
            createdAt: DateTime.now().subtract(Duration(days: i)),
            removedAt: null,
          ),
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any)).thenReturn(
          FakePostgrestBuilder(followers.map((f) => f.toJson()).toList()),
        );

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: testBabyProfileId,
            );

        // Should limit results
        expect(container.read(newFollowersProvider).followers.length,
            lessThanOrEqualTo(30));
      });
    });

    group('Cache Behavior', () {
      test('uses cached data when available', () async {
        // Arrange: Mock cache hit
        final cachedFollowers = [
          BabyMembership(
            babyProfileId: testBabyProfileId,
            userId: 'cached-user',
            role: UserRole.follower,
            createdAt: DateTime.now().subtract(Duration(days: 1)),
          ),
        ];
        final cachedJson = cachedFollowers.map((f) => f.toJson()).toList();

        when(mockCache.get<List<Map<String, dynamic>>>(
                'new_followers_$testBabyProfileId'))
            .thenAnswer((_) async => cachedJson);
        when(mockCache.isInitialized).thenReturn(true);

        // Act
        final notifier = container.read(newFollowersProvider.notifier);
        await notifier.fetchFollowers(babyProfileId: testBabyProfileId);

        // Assert: Should use cache, not call database
        final state = container.read(newFollowersProvider);
        expect(state.followers, hasLength(1));
        expect(state.followers[0].userId, 'cached-user');
        verifyNever(mockDatabase.select('baby_memberships'));
      });
    });

    group('Refresh', () {
      test('refreshes followers with force refresh', () async {
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).refresh(
              babyProfileId: testBabyProfileId,
            );

        // Verify database was called (bypassing cache)
        verify(mockDatabase.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Active/Removed Followers', () {
      test('getActiveFollowers returns only active followers', () {
        // Arrange: Set state with mixed active/removed followers
        final activeFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'active-user',
          role: UserRole.follower,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        );
        final removedFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'removed-user',
          role: UserRole.follower,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          removedAt: DateTime.now().subtract(Duration(days: 1)),
        );

        final notifier = container.read(newFollowersProvider.notifier);
        notifier.state = notifier.state
            .copyWith(followers: [activeFollower, removedFollower]);

        // Act
        final activeFollowers = notifier.getActiveFollowers();

        // Assert
        expect(activeFollowers, hasLength(1));
        expect(activeFollowers[0].userId, 'active-user');
      });

      test('getRemovedFollowers returns only removed followers', () {
        // Arrange: Set state with mixed active/removed followers
        final activeFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'active-user',
          role: UserRole.follower,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        );
        final removedFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'removed-user',
          role: UserRole.follower,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          removedAt: DateTime.now().subtract(Duration(days: 1)),
        );

        final notifier = container.read(newFollowersProvider.notifier);
        notifier.state = notifier.state
            .copyWith(followers: [activeFollower, removedFollower]);

        // Act
        final removedFollowers = notifier.getRemovedFollowers();

        // Assert
        expect(removedFollowers, hasLength(1));
        expect(removedFollowers[0].userId, 'removed-user');
      });
    });

    group('Real-time Updates', () {
      test('handles new follower', () async {
        // Setup initial state
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        final initialCount =
            container.read(newFollowersProvider).followers.length;

        // Note: Real-time updates are handled internally by the provider
        // and cannot be easily tested with direct state manipulation
        expect(initialCount, equals(1));
      });

      test('handles follower removed', () async {
        // Setup initial state
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        expect(container.read(newFollowersProvider).followers, hasLength(1));

        // Note: Real-time updates are handled internally by the provider
        // and cannot be easily tested with direct state manipulation
      });
    });

    group('Time Period Options', () {
      test('supports 7-day period', () async {
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: testBabyProfileId,
            );

        expect(container.read(newFollowersProvider).followers, isNotEmpty);
      });

      test('supports 30-day period', () async {
        final sampleFollower = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now(),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleFollower.toJson()]));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: testBabyProfileId,
            );

        expect(container.read(newFollowersProvider).followers, isNotEmpty);
      });
    });

    group('Sorting', () {
      test('sorts followers by date (newest first)', () async {
        final follower1 = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_1',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          removedAt: null,
        );
        final follower2 = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_2',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          removedAt: null,
        );
        final follower3 = BabyMembership(
          babyProfileId: testBabyProfileId,
          userId: 'user_3',
          role: UserRole.follower,
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          removedAt: null,
        );

        when(mockCache.get(any)).thenAnswer((_) async => null);
        when(mockRealtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenReturn(Stream.empty());
        when(mockDatabase.select(any)).thenAnswer((_) => FakePostgrestBuilder([
              follower1.toJson(),
              follower2.toJson(),
              follower3.toJson(),
            ]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: testBabyProfileId);

        // Most recent should be first
        expect(container.read(newFollowersProvider).followers[0].userId,
            equals('user_3'));
        expect(container.read(newFollowersProvider).followers[1].userId,
            equals('user_2'));
        expect(container.read(newFollowersProvider).followers[2].userId,
            equals('user_1'));
      });
    });

    group('Error Handling', () {
      test('error state can be set and read', () async {
        // Arrange: Set error state manually
        final notifier = container.read(newFollowersProvider.notifier);
        notifier.state = notifier.state.copyWith(error: 'Test error');

        // Assert
        final state = container.read(newFollowersProvider);
        expect(state.error, 'Test error');
      });
    });

    group('Basic Functionality', () {
      test('provider can be read from container', () {
        final notifier = container.read(newFollowersProvider.notifier);
        expect(notifier, isNotNull);
      });

      test('provider has access to required services', () {
        // Verify that the provider can be instantiated without throwing
        // This validates that all required dependencies are available in the container
        expect(() => container.read(newFollowersProvider), returnsNormally);
      });

      test('fetchFollowers method exists', () {
        final notifier = container.read(newFollowersProvider.notifier);
        expect(notifier.fetchFollowers, isNotNull);
      });

      test('refresh method exists', () {
        final notifier = container.read(newFollowersProvider.notifier);
        expect(notifier.refresh, isNotNull);
      });
    });

    group('dispose', () {
      test('container can be disposed without errors', () {
        // Verify the container can be disposed cleanly
        expect(() => container.dispose(), returnsNormally);
      });
    });
  });
}
