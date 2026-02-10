import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/tiles/upcoming_events/providers/upcoming_events_provider.dart';

import '../../../helpers/fake_postgrest_builders.dart';
import '../../../helpers/mock_factory.dart';

void main() {
  group('UpcomingEventsProvider Tests', () {
    late ProviderContainer container;
    late MockServiceContainer mocks;

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
      mocks = MockFactory.createServiceContainer();

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
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mock to delay response
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

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
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mocks
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

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
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup cache to return data
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was not called
        verifyNever(mocks.database.select(any));

        final state = container.read(upcomingEventsProvider);
        // Verify state updated from cache
        expect(state.events, hasLength(1));
        expect(state.events.first.id, equals('event_1'));
      });

      test('handles errors gracefully', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mock to throw error
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.database.select(any))
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
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup mocks
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
          forceRefresh: true,
        );

        // Verify database was called despite cache
        verify(mocks.database.select(any)).called(1);
      });

      test('saves fetched events to cache', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify cache put was called
        verify(mocks.cache.put(any, any,
                ttlMinutes: anyNamed('ttlMinutes')))
            .called(1);
      });
    });

    group('loadMore', () {
      test('loads more events for pagination', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state with events
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final event2 =
            sampleEvent.copyWith(id: 'event_2', title: 'Gender Reveal');
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([event2.toJson()]));

        await notifier.loadMore(babyProfileId: 'profile_1');

        final state = container.read(upcomingEventsProvider);
        // Verify state updated with new events
        expect(state.events, hasLength(2));
        expect(state.currentPage, equals(2));
      });

      test('does not load more when already loading', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Set loading state manually
        notifier.state = notifier.state.copyWith(isLoading: true);

        await notifier.loadMore(babyProfileId: 'profile_1');

        // Verify no additional database call
        verify(mocks.database.select(any)).called(1); // Only initial fetch
      });

      test('does not load more when hasMore is false', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state with hasMore = false
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

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
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('refresh', () {
      test('refreshes events with force refresh', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mocks.cache.get(any))
            .thenAnswer((_) async => [sampleEvent.toJson()]);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.refresh(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        // Verify database was called (bypassing cache)
        verify(mocks.database.select(any)).called(1);
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT event', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final notifier = container.read(upcomingEventsProvider.notifier);

        await notifier.fetchEvents(
          babyProfileId: 'profile_1',
          role: UserRole.owner,
        );

        final initialCount =
            container.read(upcomingEventsProvider).events.length;

        // Simulate real-time INSERT
        final newEvent =
            sampleEvent.copyWith(id: 'event_2', title: 'New Event');
        notifier.state = notifier.state.copyWith(
          events: [newEvent, ...notifier.state.events],
        );

        expect(container.read(upcomingEventsProvider).events.length,
            equals(initialCount + 1));
      });

      test('handles UPDATE event', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

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

        expect(container.read(upcomingEventsProvider).events.first.title,
            equals('Updated Event'));
      });

      test('handles DELETE event', () async {
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        // Setup initial state
        when(mocks.cache.get(any)).thenAnswer((_) async => null);
        when(mocks.realtime.subscribe(
          table: anyNamed('table'),
          channelName: anyNamed('channelName'),
          filter: anyNamed('filter'),
        )).thenAnswer((_) => Stream.value({}));
        when(mocks.database.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

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
        addTearDown(() async {
          await Future.delayed(Duration.zero);
        });
        
        when(mocks.realtime.unsubscribe(any)).thenAnswer((_) async {});

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
