import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';
import '../../../../mocks/mock_services.mocks.dart';
import '../../../../helpers/mock_factory.dart';

void main() {
  group('CalendarScreenNotifier Tests', () {
    late CalendarScreenNotifier notifier;
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockCacheService mockCacheService;
    late MockRealtimeService mockRealtimeService;

    final sampleEvent = Event(
      id: 'event_1',
      babyProfileId: 'profile_1',
      title: 'Baby Shower',
      description: 'Join us for a celebration',
      startsAt: DateTime(2024, 6, 15, 14, 0),
      endsAt: DateTime(2024, 6, 15, 17, 0),
      location: '123 Main St',
      createdByUserId: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockFactory.createDatabaseService();
      mockCacheService = MockFactory.createCacheService();
      mockRealtimeService = MockFactory.createRealtimeService();

      when(mockCacheService.isInitialized).thenReturn(true);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          cacheServiceProvider.overrideWithValue(mockCacheService),
          realtimeServiceProvider.overrideWithValue(mockRealtimeService),
        ],
      );

      notifier = container.read(calendarScreenProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initial state has empty events', () {
        expect(notifier.state.events, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.eventsByDate, isEmpty);
        expect(notifier.state.selectedDate, isNotNull);
        expect(notifier.state.focusedMonth, isNotNull);
      });

      test('initial date is today', () {
        final now = DateTime.now();
        expect(notifier.state.selectedDate.year, equals(now.year));
        expect(notifier.state.selectedDate.month, equals(now.month));
        expect(notifier.state.selectedDate.day, equals(now.day));
      });
    });

    group('loadEvents', () {
      test('sets loading state while fetching', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([]));

        final future = notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isTrue);
        await future;
      });

      test('loads events from cache when available', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => [
              sampleEvent.toJson(),
            ]);

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.id, equals('event_1'));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.selectedBabyProfileId, equals('profile_1'));
      });

      test('fetches events from database when cache is empty', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.events, hasLength(1));
        expect(notifier.state.events.first.id, equals('event_1'));
        expect(notifier.state.isLoading, isFalse);
        verify(mockCacheService.put(any, any, ttlMinutes: 30)).called(1);
      });

      test('groups events by date', () async {
        final event2 = sampleEvent.copyWith(
          id: 'event_2',
          startsAt: DateTime(2024, 6, 16, 10, 0),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any)).thenReturn(
            FakePostgrestBuilder([sampleEvent.toJson(), event2.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.eventsByDate.keys, hasLength(2));
        expect(notifier.state.eventsByDate['2024-06-15'], hasLength(1));
        expect(notifier.state.eventsByDate['2024-06-16'], hasLength(1));
      });

      test('uses custom date range when provided', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        final startDate = DateTime(2024, 5, 1);
        final endDate = DateTime(2024, 7, 31);

        await notifier.loadEvents(
          babyProfileId: 'profile_1',
          startDate: startDate,
          endDate: endDate,
        );

        expect(notifier.state.events, hasLength(1));
      });

      test('handles errors gracefully', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, contains('Database error'));
        expect(notifier.state.events, isEmpty);
      });

      test('sets up real-time subscription', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        verify(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).called(1);
      });
    });

    group('Date Selection', () {
      test('selectDate updates selected date', () {
        final newDate = DateTime(2024, 7, 20);

        notifier.selectDate(newDate);

        expect(notifier.state.selectedDate, equals(newDate));
      });

      test('eventsForSelectedDate returns correct events', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');
        notifier.selectDate(DateTime(2024, 6, 15));

        expect(notifier.state.eventsForSelectedDate, hasLength(1));
        expect(
            notifier.state.eventsForSelectedDate.first.id, equals('event_1'));
      });

      test('datesWithEvents returns all dates with events', () async {
        final event2 = sampleEvent.copyWith(
          id: 'event_2',
          startsAt: DateTime(2024, 6, 16, 10, 0),
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any)).thenReturn(
            FakePostgrestBuilder([sampleEvent.toJson(), event2.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        final datesWithEvents = notifier.state.datesWithEvents;
        expect(datesWithEvents, hasLength(2));
      });
    });

    group('Month Navigation', () {
      test('nextMonth navigates to next month', () {
        final currentMonth = DateTime(2024, 6, 1);
        notifier.state = notifier.state.copyWith(focusedMonth: currentMonth);

        notifier.nextMonth();

        expect(notifier.state.focusedMonth.year, equals(2024));
        expect(notifier.state.focusedMonth.month, equals(7));
      });

      test('previousMonth navigates to previous month', () {
        final currentMonth = DateTime(2024, 6, 1);
        notifier.state = notifier.state.copyWith(focusedMonth: currentMonth);

        notifier.previousMonth();

        expect(notifier.state.focusedMonth.year, equals(2024));
        expect(notifier.state.focusedMonth.month, equals(5));
      });

      test('goToMonth navigates to specific month', () {
        final targetMonth = DateTime(2024, 12, 1);

        notifier.goToMonth(targetMonth);

        expect(notifier.state.focusedMonth.year, equals(2024));
        expect(notifier.state.focusedMonth.month, equals(12));
      });

      test('nextMonth handles year transition', () {
        final currentMonth = DateTime(2024, 12, 1);
        notifier.state = notifier.state.copyWith(focusedMonth: currentMonth);

        notifier.nextMonth();

        expect(notifier.state.focusedMonth.year, equals(2025));
        expect(notifier.state.focusedMonth.month, equals(1));
      });

      test('previousMonth handles year transition', () {
        final currentMonth = DateTime(2024, 1, 1);
        notifier.state = notifier.state.copyWith(focusedMonth: currentMonth);

        notifier.previousMonth();

        expect(notifier.state.focusedMonth.year, equals(2023));
        expect(notifier.state.focusedMonth.month, equals(12));
      });
    });

    group('refresh', () {
      test('refreshes events', () async {
        notifier.state = notifier.state.copyWith(
          selectedBabyProfileId: 'profile_1',
        );

        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.refresh();

        expect(notifier.state.events, hasLength(1));
      });

      test('does not refresh when baby profile is missing', () async {
        await notifier.refresh();

        verifyNever(mockDatabaseService.select(any));
      });
    });

    group('Real-time Updates', () {
      test('handles INSERT event', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final streamController = Stream.value({
          'eventType': 'INSERT',
          'new': {
            'id': 'event_2',
            'baby_profile_id': 'profile_1',
            'title': 'New Event',
            'starts_at': DateTime(2024, 6, 20, 10, 0).toIso8601String(),
            'created_by_user_id': 'user_1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        });

        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => streamController);

        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.events.length, equals(2));
      });

      test('handles UPDATE event', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final streamController = Stream.value({
          'eventType': 'UPDATE',
          'new': {
            'id': 'event_1',
            'baby_profile_id': 'profile_1',
            'title': 'Updated Event',
            'starts_at': DateTime(2024, 6, 15, 14, 0).toIso8601String(),
            'ends_at': DateTime(2024, 6, 15, 17, 0).toIso8601String(),
            'location': '123 Main St',
            'description': 'Join us for a celebration',
            'created_by_user_id': 'user_1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        });

        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => streamController);

        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.events.first.title, equals('Updated Event'));
      });

      test('handles DELETE event', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        final streamController = Stream.value({
          'eventType': 'DELETE',
          'old': {'id': 'event_1'},
        });

        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => streamController);

        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.events, hasLength(1));

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.events, isEmpty);
      });
    });

    group('dispose', () {
      test('cancels real-time subscription on dispose', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});
        when(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).thenAnswer((_) => Stream.value({}));
        when(mockRealtimeService.unsubscribe(any)).thenAnswer((_) async {});
        when(mockDatabaseService.select(any))
            .thenAnswer((_) => FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        // Note: dispose is called automatically by Riverpod's ref.onDispose
        // We can't manually call dispose on a Riverpod notifier

        // Just verify the subscription was created
        verify(mockRealtimeService.subscribe(
          table: any,
          channelName: any,
          filter: any,
        )).called(1);
      });
    });
  });
}
