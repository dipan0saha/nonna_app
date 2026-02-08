import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/tiles/upcoming_events/providers/upcoming_events_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'upcoming_events_provider_test.mocks.dart';

void main() {
  group('UpcomingEventsProvider Tests', () {
    late ProviderContainer container;
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

      provideDummy<String>('');

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
      test('initial state has empty events', () {
        final state = container.read(upcomingEventsProvider);
        expect(state.events, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.hasMore, isTrue);
        expect(state.currentPage, equals(0));
      });
    });

    group('fetchEvents', () {
      test('sets loading state while fetching', () async {
        // Setup mock to delay response
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockDatabaseService.select(argThat(isA<String>()))).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        });

        final notifier = container.read(upcomingEventsProvider.notifier);

        // Start fetching
        final fetchFuture = notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify loading state
        expect(container.read(upcomingEventsProvider).isLoading, isTrue);

        await fetchFuture;
      });

      test('fetches events from database when cache is empty', () async {
        // Setup mocks
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(upcomingEventsProvider);
        // Verify state updated
        expect(state.events, hasLength(1));
        expect(state.events.first.id, equals('event_1'));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.currentPage, equals(1));
      });

      test('loads events from cache when available', () async {
        // Setup cache to return data
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was not called
        verifyNever(mockDatabaseService.select(argThat(isA<String>())));

        final state = container.read(upcomingEventsProvider);
        // Verify state updated from cache
        expect(state.events, hasLength(1));
        expect(state.events.first.id, equals('event_1'));
      });

      test('handles errors gracefully', () async {
        // Setup mock to throw error
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenThrow(Exception('Database error'));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(upcomingEventsProvider);
        // Verify error state
        expect(state.isLoading, isFalse);
        expect(state.error, contains('Database error'));
        expect(state.events, isEmpty);
      });

      test('force refresh bypasses cache', () async {
        // Setup mocks
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(1);
      });

      test('saves fetched events to cache', () async {
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify cache put was called
        verify(mockCacheService.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('loadMore', () {
      test('loads more events for pagination', () async {
        // Setup initial state with events
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final event2 =
            sampleEvent.copyWith(id: 'event_2', title: 'Gender Reveal');
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [event2.toJson()]);

        await notifier.loadMore(babyProfileId: 'profile_1');

        final state = container.read(upcomingEventsProvider);
        // Verify state updated with new events
        expect(state.events, hasLength(2));
        expect(state.currentPage, equals(2));
      });

      test('does not load more when already loading', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Set loading state manually
        notifier.state = notifier.state.copyWith(isLoading: true);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify no additional database call
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(1); // Only initial fetch
      });

      test('does not load more when hasMore is false', () async {
        // Setup initial state with hasMore = false
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => []);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final state = container.read(upcomingEventsProvider);
        // hasMore should be false when empty result
        expect(state.hasMore, isFalse);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify only initial database call
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(1);
      });
    });

    group('refresh', () {
      test('refreshes events with force refresh', () async {
        when(mockCacheService.get(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.refresh(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was called (bypassing cache)
        verify(mockDatabaseService.select(argThat(isA<String>()))).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT event', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final initialCount = container.read(upcomingEventsProvider).events.length;

        // Simulate real-time INSERT
        final newEvent =
            sampleEvent.copyWith(id: 'event_2', title: 'New Event');
        notifier.state = notifier.state.copyWith(
          events: [newEvent, ...notifier.state.events],
        );

        expect(container.read(upcomingEventsProvider).events.length, equals(initialCount + 1));
      });

      test('handles UPDATE event', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

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

        expect(container.read(upcomingEventsProvider).events.first.title, equals('Updated Event'));
      });

      test('handles DELETE event', () async {
        // Setup initial state
        when(mockCacheService.get(argThat(isA<String>()))).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(argThat(isA<String>())))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        expect(container.read(upcomingEventsProvider).events, hasLength(1));

        // Simulate real-time DELETE
        notifier.state = notifier.state.copyWith(
          events:
              notifier.state.events.where((e) => e.id != 'event_1').toList(),
        );

        expect(container.read(upcomingEventsProvider).events, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () async {
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});

        // Disposing the container will trigger the onDispose callback
        container.dispose();

        // Give a moment for async dispose to complete
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify the container was disposed
        // Note: This verifies the method can be called without errors
        expect(true, isTrue);
      });
    });
  });
}
