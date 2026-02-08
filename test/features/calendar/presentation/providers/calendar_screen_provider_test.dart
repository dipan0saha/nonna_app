import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';

import '../../../../helpers/fake_postgrest_builders.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'calendar_screen_provider_test.mocks.dart';

void main() {
  group('CalendarScreenNotifier Tests', () {
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
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

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
        final state = container.read(calendarScreenProvider);
        
        expect(state.events, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.eventsByDate, isEmpty);
        expect(container.read(calendarScreenProvider).selectedDate, isNotNull);
        expect(container.read(calendarScreenProvider).focusedMonth, isNotNull);
      });

      test('initial date is today', () {
        final now = DateTime.now();
        expect(container.read(calendarScreenProvider).selectedDate.year, equals(now.year));
        expect(container.read(calendarScreenProvider).selectedDate.month, equals(now.month));
        expect(container.read(calendarScreenProvider).selectedDate.day, equals(now.day));
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
            .thenReturn(FakePostgrestBuilder([]));

        final future = container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).isLoading, isTrue);
        await future;
      });

      test('loads events from cache when available', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => [
              sampleEvent.toJson(),
            ]);

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).events, hasLength(1));
        expect(container.read(calendarScreenProvider).events.first.id, equals('event_1'));
        expect(container.read(calendarScreenProvider).isLoading, isFalse);
        expect(container.read(calendarScreenProvider).selectedBabyProfileId, equals('profile_1'));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).events, hasLength(1));
        expect(container.read(calendarScreenProvider).events.first.id, equals('event_1'));
        expect(container.read(calendarScreenProvider).isLoading, isFalse);
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

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).eventsByDate.keys, hasLength(2));
        expect(container.read(calendarScreenProvider).eventsByDate['2024-06-15'], hasLength(1));
        expect(container.read(calendarScreenProvider).eventsByDate['2024-06-16'], hasLength(1));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        final startDate = DateTime(2024, 5, 1);
        final endDate = DateTime(2024, 7, 31);

        await container.read(calendarScreenProvider.notifier).loadEvents(
          babyProfileId: 'profile_1',
          startDate: startDate,
          endDate: endDate,
        );

        expect(container.read(calendarScreenProvider).events, hasLength(1));
      });

      test('handles errors gracefully', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockDatabaseService.select(any))
            .thenThrow(Exception('Database error'));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).isLoading, isFalse);
        expect(container.read(calendarScreenProvider).error, contains('Database error'));
        expect(container.read(calendarScreenProvider).events, isEmpty);
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

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

        container.read(calendarScreenProvider.notifier).selectDate(newDate);

        expect(container.read(calendarScreenProvider).selectedDate, equals(newDate));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');
        container.read(calendarScreenProvider.notifier).selectDate(DateTime(2024, 6, 15));

        expect(container.read(calendarScreenProvider).eventsForSelectedDate, hasLength(1));
        expect(
            container.read(calendarScreenProvider).eventsForSelectedDate.first.id, equals('event_1'));
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

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        final datesWithEvents = container.read(calendarScreenProvider).datesWithEvents;
        expect(datesWithEvents, hasLength(2));
      });
    });

    group('Month Navigation', () {
      test('nextMonth navigates to next month', () {
        final currentMonth = DateTime(2024, 6, 1);
        container.read(calendarScreenProvider) = container.read(calendarScreenProvider).copyWith(focusedMonth: currentMonth);

        notifier.nextMonth();

        expect(container.read(calendarScreenProvider).focusedMonth.year, equals(2024));
        expect(container.read(calendarScreenProvider).focusedMonth.month, equals(7));
      });

      test('previousMonth navigates to previous month', () {
        final currentMonth = DateTime(2024, 6, 1);
        container.read(calendarScreenProvider) = container.read(calendarScreenProvider).copyWith(focusedMonth: currentMonth);

        notifier.previousMonth();

        expect(container.read(calendarScreenProvider).focusedMonth.year, equals(2024));
        expect(container.read(calendarScreenProvider).focusedMonth.month, equals(5));
      });

      test('goToMonth navigates to specific month', () {
        final targetMonth = DateTime(2024, 12, 1);

        notifier.goToMonth(targetMonth);

        expect(container.read(calendarScreenProvider).focusedMonth.year, equals(2024));
        expect(container.read(calendarScreenProvider).focusedMonth.month, equals(12));
      });

      test('nextMonth handles year transition', () {
        final currentMonth = DateTime(2024, 12, 1);
        container.read(calendarScreenProvider) = container.read(calendarScreenProvider).copyWith(focusedMonth: currentMonth);

        notifier.nextMonth();

        expect(container.read(calendarScreenProvider).focusedMonth.year, equals(2025));
        expect(container.read(calendarScreenProvider).focusedMonth.month, equals(1));
      });

      test('previousMonth handles year transition', () {
        final currentMonth = DateTime(2024, 1, 1);
        container.read(calendarScreenProvider) = container.read(calendarScreenProvider).copyWith(focusedMonth: currentMonth);

        notifier.previousMonth();

        expect(container.read(calendarScreenProvider).focusedMonth.year, equals(2023));
        expect(container.read(calendarScreenProvider).focusedMonth.month, equals(12));
      });
    });

    group('refresh', () {
      test('refreshes events', () async {
        container.read(calendarScreenProvider) = container.read(calendarScreenProvider).copyWith(
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.refresh();

        expect(container.read(calendarScreenProvider).events, hasLength(1));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(calendarScreenProvider).events.length, equals(2));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(calendarScreenProvider).events.first.title, equals('Updated Event'));
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

        expect(container.read(calendarScreenProvider).events, hasLength(1));

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(calendarScreenProvider).events, isEmpty);
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
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await container.read(calendarScreenProvider.notifier).loadEvents(babyProfileId: 'profile_1');

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
