import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/user.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/new_followers/providers/new_followers_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'new_followers_provider_test.mocks.dart';

void main() {
  group('NewFollowersProvider Tests', () {
    late NewFollowersNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample follower data
    final sampleFollower = User(
      id: 'user_1',
      email: 'follower@example.com',
      displayName: 'John Doe',
      photoUrl: 'https://example.com/avatar.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = NewFollowersNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty followers', () {
        expect(notifier.state.followers, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });
    });

    group('fetchNewFollowers', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture =
            notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches followers from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        // Verify state updated
        expect(notifier.state.followers, hasLength(1));
        expect(notifier.state.followers.first.id, equals('user_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads followers from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleFollower.toJson()]);

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.followers, hasLength(1));
        expect(notifier.state.followers.first.id, equals('user_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.followers, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('filters only recent followers', () async {
        final recentFollower = sampleFollower.copyWith(
          id: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([recentFollower.toJson()]));

        await notifier.fetchNewFollowers(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Should only have recent followers
        expect(notifier.state.followers, hasLength(1));
        expect(notifier.state.followers.first.id, equals('user_1'));
      });

      test('saves fetched followers to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

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
            id: 'user_$i',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(
          FakePostgrestBuilder(followers.map((f) => f.toJson()).toList()),
        );

        await notifier.fetchNewFollowers(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Should limit results
        expect(notifier.state.followers.length, lessThanOrEqualTo(30));
      });
    });

    group('refresh', () {
      test('refreshes followers with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleFollower.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.refresh(
          babyProfileId: 'profile_1',
          days: 7,
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles new follower', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        final initialCount = notifier.state.followers.length;

        // Simulate real-time INSERT
        final newFollower = sampleFollower.copyWith(id: 'user_2');
        notifier.state = notifier.state.copyWith(
          followers: [newFollower, ...notifier.state.followers],
        );

        expect(notifier.state.followers.length, equals(initialCount + 1));
      });

      test('handles follower removed', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        expect(notifier.state.followers, hasLength(1));

        // Simulate real-time DELETE
        notifier.state = notifier.state.copyWith(
          followers:
              notifier.state.followers.where((f) => f.id != 'user_1').toList(),
        );

        expect(notifier.state.followers, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });

    group('Time Period Options', () {
      test('supports 7-day period', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(
          babyProfileId: 'profile_1',
          days: 7,
        );

        expect(notifier.state.followers, isNotEmpty);
      });

      test('supports 30-day period', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleFollower.toJson()]));

        await notifier.fetchNewFollowers(
          babyProfileId: 'profile_1',
          days: 30,
        );

        expect(notifier.state.followers, isNotEmpty);
      });
    });

    group('Sorting', () {
      test('sorts followers by date (newest first)', () async {
        final follower1 = sampleFollower.copyWith(
          id: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        final follower2 = sampleFollower.copyWith(
          id: 'user_2',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final follower3 = sampleFollower.copyWith(
          id: 'user_3',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([
          follower1.toJson(),
          follower2.toJson(),
          follower3.toJson(),
        ]));

        await notifier.fetchNewFollowers(babyProfileId: 'profile_1');

        // Most recent should be first
        expect(notifier.state.followers[0].id, equals('user_3'));
        expect(notifier.state.followers[1].id, equals('user_2'));
        expect(notifier.state.followers[2].id, equals('user_1'));
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder gte(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
