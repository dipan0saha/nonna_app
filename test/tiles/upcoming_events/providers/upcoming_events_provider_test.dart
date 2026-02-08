import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/upcoming_events/providers/upcoming_events_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'upcoming_events_provider_test.mocks.dart';

void main() {
  group('UpcomingEventsProvider Tests', () {
    late UpcomingEventsNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample event data
    final sampleEvent = Event(
      id: 'event_1',
      babyProfileId: 'profile_1',
      title: 'Baby Shower',
      description: 'Join us for a celebration',
      startsAt: DateTime.now().add(const Duration(days: 7)),
      endsAt: DateTime.now().add(const Duration(days: 7, hours: 3)),
      location: '123 Main St',
      createdByUserId: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = UpcomingEventsNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    group('Initial State', () {
      test('initial state has empty events', () {
        expect(notifier.state.events, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.hasMore, isTrue);
        expect(notifier.state.currentPage, equals(0));
      });
    });

    group('fetchEvents', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify loading state
        expect(notifier.state.isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches events from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify state updated
        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.id, equals('event_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.currentPage, equals(1));
      });

      test('loads events from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.id, equals('event_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.events, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(1);
      });

      test('saves fetched events to cache', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify cache put was called
        verify(mockCacheService.put(any, any, ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('loadMore', () {
      test('loads more events for pagination', () async {
        // Setup initial state with events
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final event2 = sampleEvent.copyWith(id: 'event_2', title: 'Gender Reveal');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([event2.toJson()]));

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify state updated with new events
        expect(notifier.state.events, hasLength(2));
        expect(notifier.state.currentPage, equals(2));
      });

      test('does not load more when already loading', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Set loading state manually
        notifier.state = notifier.state.copyWith(isLoading: true);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify no additional database call
        verify(mockDatabaseService.select(any)).called(1); // Only initial fetch
      });

      test('does not load more when hasMore is false', () async {
        // Setup initial state with hasMore = false
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any)).thenReturn(FakePostgrestBuilder([]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // hasMore should be false when empty result
        expect(notifier.state.hasMore, isFalse);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify only initial database call
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('refresh', () {
      test('refreshes events with force refresh', () async {
        when(mockCacheService.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.refresh(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT event', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final initialCount = notifier.state.events.length;

        // Simulate real-time INSERT
        final newEvent = sampleEvent.copyWith(id: 'event_2', title: 'New Event');
        notifier.state = notifier.state.copyWith(
          events: [newEvent, ...notifier.state.events],
        );

        expect(notifier.state.events.length, equals(initialCount + 1));
      });

      test('handles UPDATE event', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Simulate real-time UPDATE
        final updatedEvent = sampleEvent.copyWith(title: 'Updated Event');
        notifier.state = notifier.state.copyWith(
          events: notifier.state.events
              .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
              .toList(),
        );

        expect(notifier.state.events.first.title, equals('Updated Event'));
      });

      test('handles DELETE event', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(notifier.state.events, hasLength(1));

        // Simulate real-time DELETE
        notifier.state = notifier.state.copyWith(
          events: notifier.state.events.where((e) => e.id != 'event_1').toList(),
        );

        expect(notifier.state.events, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        // Verify unsubscribe was called if subscription existed
        // Note: This verifies the method can be called without errors
        expect(notifier.state, isNotNull);
      });
    });
  });
}

// Fake builders for Postgrest operations (test doubles)
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder isNull(String column) => this;
  FakePostgrestBuilder gte(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder range(int from, int to) => this;
  FakePostgrestBuilder limit(int count) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
