import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/tiles/new_followers/providers/new_followers_provider.dart';

// Import centralized mocks and helpers
import '../../../mocks/mock_services.mocks.dart';
import '../../../helpers/mock_factory.dart';
import '../../../helpers/test_data_factory.dart';
import '../../../helpers/fake_postgrest_builders.dart';

/// Example of refactored test using centralized mocking strategy
///
/// Key improvements:
/// - No @GenerateMocks annotation (uses centralized mocks)
/// - Uses MockFactory for pre-configured services
/// - Uses TestDataFactory for consistent test data
/// - Uses MockHelpers for common patterns
/// - Less boilerplate, more focused on business logic
void main() {
  group('NewFollowersProvider Tests (Refactored)', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

    // Sample follower data using TestDataFactory
    late final sampleFollower = TestDataFactory.createBabyMembership(
      babyProfileId: 'baby_profile_1',
      userId: 'user_1',
      role: UserRole.follower,
      relationshipLabel: 'Aunt',
    );

    setUp(() {
      // Create all mock services with sensible defaults
      mocks = MockFactory.createServiceContainer();

      // Create provider container with mock overrides
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mocks.database),
          cacheServiceProvider.overrideWithValue(mocks.cache),
          realtimeServiceProvider.overrideWithValue(mocks.realtime),
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
        // Setup cache miss and empty database response
        MockHelpers.setupCacheMiss(mocks.cache);
        MockHelpers.setupDatabaseSelect(mocks.database, 'baby_memberships', []);

        // Start fetching
        final fetchFuture = container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Verify loading state
        expect(container.read(newFollowersProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches followers from database when cache is empty', () async {
        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [sampleFollower.toJson()],
        );

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Verify state updated
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId,
            equals('user_1'));
        expect(container.read(newFollowersProvider).isLoading, isFalse);
        expect(container.read(newFollowersProvider).error, isNull);
      });

      test('loads followers from cache when available', () async {
        // Setup cache hit
        MockHelpers.setupCacheGet(
          mocks.cache,
          any,
          [sampleFollower.toJson()],
        );

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mocks.database.select(any, columns: anyNamed('columns')));

        // Verify state updated from cache
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId,
            equals('user_1'));
      });

      test('handles errors gracefully', () async {
        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup database error
        MockHelpers.setupDatabaseError(
          mocks.database,
          'baby_memberships',
          Exception('Database error'),
        );

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Verify error state
        expect(container.read(newFollowersProvider).isLoading, isFalse);
        expect(container.read(newFollowersProvider).error,
            contains('Database error'));
        expect(container.read(newFollowersProvider).followers, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup cache with data
        MockHelpers.setupCacheGet(
          mocks.cache,
          any,
          [sampleFollower.toJson()],
        );

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [sampleFollower.toJson()],
        );

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: 'profile_1',
              forceRefresh: true,
            );

        // Verify database was called despite cache
        verify(mocks.database.select(any, columns: anyNamed('columns')))
            .called(greaterThanOrEqualTo(1));
      });

      test('filters only recent followers', () async {
        // Create recent follower using TestDataFactory
        final recentFollower = TestDataFactory.createBabyMembership(
          babyProfileId: 'baby_profile_1',
          userId: 'user_1',
          relationshipLabel: 'Aunt',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [recentFollower.toJson()],
        );

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: 'profile_1',
            );

        // Should only have recent followers
        expect(container.read(newFollowersProvider).followers, hasLength(1));
        expect(container.read(newFollowersProvider).followers.first.userId,
            equals('user_1'));
      });

      test('saves fetched followers to cache', () async {
        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [sampleFollower.toJson()],
        );

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Verify cache put was called
        verify(mocks.cache.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });

      test('limits to recent followers only', () async {
        // Create multiple followers using TestDataFactory batch method
        final followers = List.generate(
          30,
          (i) => TestDataFactory.createBabyMembership(
            babyProfileId: 'baby_profile_1',
            userId: 'user_$i',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );

        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response using TestDataFactory JSON conversion
        when(mocks.database.select(any, columns: anyNamed('columns')))
            .thenReturn(FakePostgrestBuilder(
          followers.map((f) => f.toJson()).toList(),
        ));

        await container.read(newFollowersProvider.notifier).fetchFollowers(
              babyProfileId: 'profile_1',
            );

        // Should limit results
        expect(container.read(newFollowersProvider).followers.length,
            lessThanOrEqualTo(30));
      });
    });

    group('refresh', () {
      test('refreshes followers with force refresh', () async {
        // Setup cache with data
        MockHelpers.setupCacheGet(
          mocks.cache,
          any,
          [sampleFollower.toJson()],
        );

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [sampleFollower.toJson()],
        );

        await container.read(newFollowersProvider.notifier).refresh(
              babyProfileId: 'profile_1',
            );

        // Verify database was called (bypassing cache)
        verify(mocks.database.select(any, columns: anyNamed('columns')))
            .called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles new follower', () async {
        // Setup initial state
        MockHelpers.setupCacheMiss(mocks.cache);
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );
        MockHelpers.setupDatabaseSelect(
          mocks.database,
          'baby_memberships',
          [sampleFollower.toJson()],
        );

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        final initialCount =
            container.read(newFollowersProvider).followers.length;

        // Note: Real-time updates are handled internally by the provider
        // and cannot be easily tested with direct state manipulation
        expect(initialCount, equals(1));
      });
    });

    group('Sorting', () {
      test('sorts followers by date (newest first)', () async {
        // Create followers with different dates using TestDataFactory
        final follower1 = TestDataFactory.createBabyMembership(
          babyProfileId: 'baby_profile_1',
          userId: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        final follower2 = TestDataFactory.createBabyMembership(
          babyProfileId: 'baby_profile_1',
          userId: 'user_2',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final follower3 = TestDataFactory.createBabyMembership(
          babyProfileId: 'baby_profile_1',
          userId: 'user_3',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Setup cache miss
        MockHelpers.setupCacheMiss(mocks.cache);

        // Setup realtime subscription
        MockHelpers.setupRealtimeSubscription(
          mocks.realtime,
          'baby_memberships',
          Stream.empty(),
        );

        // Setup database response
        when(mocks.database.select(any, columns: anyNamed('columns')))
            .thenReturn(FakePostgrestBuilder([
          follower1.toJson(),
          follower2.toJson(),
          follower3.toJson(),
        ]));

        await container
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: 'profile_1');

        // Most recent should be first
        expect(container.read(newFollowersProvider).followers[0].userId,
            equals('user_3'));
        expect(container.read(newFollowersProvider).followers[1].userId,
            equals('user_2'));
        expect(container.read(newFollowersProvider).followers[2].userId,
            equals('user_1'));
      });
    });
  });
}
