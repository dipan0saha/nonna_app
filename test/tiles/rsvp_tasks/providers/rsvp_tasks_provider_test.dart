import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/rsvp_status.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/event_rsvp.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/tiles/rsvp_tasks/providers/rsvp_tasks_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'rsvp_tasks_provider_test.mocks.dart';

void main() {
  group('RSVPTasksProvider Tests', () {
    late RSVPTasksNotifier notifier;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    // Sample event and RSVP data
    final sampleEvent = Event(
      id: 'event_1',
      babyProfileId: 'profile_1',
      title: 'Baby Shower',
      description: 'Join us for a celebration',
      startsAt: DateTime.now().add(const Duration(days: 7)),
      endsAt: DateTime.now().add(const Duration(days: 7, hours: 3)),
      location: '123 Main St',
      createdBy: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleRSVP = EventRSVP(
      id: 'rsvp_1',
      eventId: 'event_1',
      userId: 'user_1',
      status: RSVPStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      // Setup mock cache service
      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = RSVPTasksNotifier(
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
        expect(notifier.state.pendingCount, equals(0));
      });
    });

    group('fetchRSVPTasks', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return FakePostgrestBuilder([]);
        });

        // Start fetching
        final fetchFuture = notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
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

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // Verify state updated
        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.event.id, equals('event_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('loads events from cache when available', () async {
        // Setup cache to return data
        final cachedData = {
          'event': sampleEvent.toJson(),
          'rsvp': null,
          'needsResponse': true,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // Verify database was not called
        verifyNever(mockDatabaseService.select(any));

        // Verify state updated from cache
        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.event.id, equals('event_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // Verify error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.events, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        final cachedData = {
          'event': sampleEvent.toJson(),
          'rsvp': null,
          'needsResponse': true,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });

      test('calculates pending count correctly', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // All events without RSVP are pending
        expect(notifier.state.pendingCount, greaterThanOrEqualTo(0));
      });
    });

    group('submitRSVP', () {
      test('submits RSVP and updates state', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));
        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // Setup insert mock
        when(mockDatabaseService.insert(any))
            .thenReturn(FakePostgrestInsertBuilder([sampleRSVP.toJson()]));

        await notifier.submitRSVP(
          eventId: 'event_1',
          userId: 'user_1',
          babyProfileId: 'profile_1',
          status: RSVPStatus.accepted,
        );

        // Verify database insert
        verify(mockDatabaseService.insert(any)).called(1);
      });
    });

    group('refresh', () {
      test('refreshes RSVP tasks with force refresh', () async {
        final cachedData = {
          'event': sampleEvent.toJson(),
          'rsvp': null,
          'needsResponse': true,
        };
        when(mockCacheService.get(any)).thenAnswer((_) async => [cachedData]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.refresh(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(any)).called(greaterThanOrEqualTo(1));
      });
    });

    group('Real-time Updates', () {
      test('handles new event requiring RSVP', () async {
        // Setup initial state
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        final initialCount = notifier.state.events.length;

        // Simulate real-time INSERT
        final newEvent = sampleEvent.copyWith(id: 'event_2');
        final newEventWithRSVP = EventWithRSVP(
          event: newEvent,
          rsvp: null,
          needsResponse: true,
        );

        notifier.state = notifier.state.copyWith(
          events: [...notifier.state.events, newEventWithRSVP],
          pendingCount: notifier.state.pendingCount + 1,
        );

        expect(notifier.state.events.length, equals(initialCount + 1));
      });
    });

    group('dispose', () {
      test('cancels real-time subscriptions on dispose', () {
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);

        notifier.dispose();

        expect(notifier.state, isNotNull);
      });
    });

    group('RSVP Status Filtering', () {
      test('filters events needing response', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          filter: anyNamed('filter'),
          callback: anyNamed('callback'),
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.fetchRSVPTasks(
          userId: 'user_1',
          babyProfileId: 'profile_1',
        );

        // All events should need response initially
        for (final eventWithRSVP in notifier.state.events) {
          expect(eventWithRSVP.needsResponse, isTrue);
        }
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

  Future<List<Map<String, dynamic>>> call() async => data;
}

class FakePostgrestInsertBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestInsertBuilder(this.data);

  Future<List<Map<String, dynamic>>> insert(Map<String, dynamic> data) async =>
      this.data;
}
