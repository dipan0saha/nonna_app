import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/services/cache_service.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/realtime_service.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';

@GenerateMocks([DatabaseService, CacheService, RealtimeService])
import 'calendar_screen_provider_test.mocks.dart';

void main() {
  group('CalendarScreenNotifier Tests', () {
    late CalendarScreenNotifier notifier;
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
      createdBy: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockCacheService = MockCacheService();
      mockRealtimeService = MockRealtimeService();

      when(mockCacheService.isInitialized).thenReturn(true);

      notifier = CalendarScreenNotifier(
        databaseService: mockDatabaseService,
        cacheService: mockCacheService,
        realtimeService: mockRealtimeService,
      );
    });

    tearDown(() {
      notifier.dispose();
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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([]));

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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        verify(mockRealtimeService.subscribe(
          table: any,
          filter: any,
          callback: any,
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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

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

        Function? realtimeCallback;
        when(mockRealtimeService.subscribe(
          table: any,
          filter: any,
          callback: any,
        )).thenAnswer((invocation) async {
          realtimeCallback = invocation.namedArguments[#callback] as Function;
          return 'sub_1';
        });

        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        final initialCount = notifier.state.events.length;

        // Simulate INSERT
        final newEvent = sampleEvent.copyWith(
          id: 'event_2',
          title: 'New Event',
          startsAt: DateTime(2024, 6, 20, 10, 0),
        );
        realtimeCallback!({
          'eventType': 'INSERT',
          'new': newEvent.toJson(),
        });

        expect(notifier.state.events.length, equals(initialCount + 1));
      });

      test('handles UPDATE event', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        Function? realtimeCallback;
        when(mockRealtimeService.subscribe(
          table: any,
          filter: any,
          callback: any,
        )).thenAnswer((invocation) async {
          realtimeCallback = invocation.namedArguments[#callback] as Function;
          return 'sub_1';
        });

        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        // Simulate UPDATE
        final updatedEvent = sampleEvent.copyWith(title: 'Updated Event');
        realtimeCallback!({
          'eventType': 'UPDATE',
          'new': updatedEvent.toJson(),
        });

        expect(notifier.state.events.first.title, equals('Updated Event'));
      });

      test('handles DELETE event', () async {
        when(mockCacheService.get(any)).thenAnswer((_) async => null);
        when(mockCacheService.put(any, any, ttlMinutes: any))
            .thenAnswer((_) async => {});

        Function? realtimeCallback;
        when(mockRealtimeService.subscribe(
          table: any,
          filter: any,
          callback: any,
        )).thenAnswer((invocation) async {
          realtimeCallback = invocation.namedArguments[#callback] as Function;
          return 'sub_1';
        });

        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        expect(notifier.state.events, hasLength(1));

        // Simulate DELETE
        realtimeCallback!({
          'eventType': 'DELETE',
          'old': {'id': 'event_1'},
        });

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
          filter: any,
          callback: any,
        )).thenAnswer((_) async => 'sub_1');
        when(mockRealtimeService.unsubscribe(any)).thenReturn(null);
        when(mockDatabaseService.select(any))
            .thenReturn(FakePostgrestBuilder([sampleEvent.toJson()]));

        await notifier.loadEvents(babyProfileId: 'profile_1');

        notifier.dispose();

        verify(mockRealtimeService.unsubscribe('sub_1')).called(1);
      });
    });
  });
}

// Fake builders for Postgrest operations
class FakePostgrestBuilder {
  final List<Map<String, dynamic>> data;

  FakePostgrestBuilder(this.data);

  FakePostgrestBuilder eq(String column, dynamic value) => this;
  FakePostgrestBuilder isNull(String column) => this;
  FakePostgrestBuilder gte(String column, dynamic value) => this;
  FakePostgrestBuilder lte(String column, dynamic value) => this;
  FakePostgrestBuilder order(String column, {bool ascending = true}) => this;
  FakePostgrestBuilder range(int from, int to) => this;

  Future<List<Map<String, dynamic>>> call() async => data;
}
