import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/event.dart';

/// Calendar Screen Provider for managing calendar view state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Calendar view state management
/// - Event list management
/// - Date selection handling
/// - Tile visibility control
/// - Month navigation
/// - Real-time event updates
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Event model

/// Calendar screen state model
class CalendarScreenState {
  final List<Event> events;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool isLoading;
  final String? error;
  final Map<String, List<Event>> eventsByDate;
  final String? selectedBabyProfileId;

  CalendarScreenState({
    this.events = const [],
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.isLoading = false,
    this.error,
    this.eventsByDate = const {},
    this.selectedBabyProfileId,
  })  : selectedDate = selectedDate ?? _getDefaultDate(),
        focusedMonth = focusedMonth ?? _getDefaultDate();

  static DateTime _getDefaultDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  CalendarScreenState copyWith({
    List<Event>? events,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    bool? isLoading,
    String? error,
    Map<String, List<Event>>? eventsByDate,
    String? selectedBabyProfileId,
  }) {
    return CalendarScreenState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      eventsByDate: eventsByDate ?? this.eventsByDate,
      selectedBabyProfileId:
          selectedBabyProfileId ?? this.selectedBabyProfileId,
    );
  }

  /// Get events for selected date
  List<Event> get eventsForSelectedDate {
    final dateKey = _getDateKey(selectedDate);
    return eventsByDate[dateKey] ?? [];
  }

  /// Get all dates with events
  Set<DateTime> get datesWithEvents {
    return eventsByDate.keys.map((key) {
      final parts = key.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toSet();
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Calendar Screen Provider Notifier
class CalendarScreenNotifier extends Notifier<CalendarScreenState> {
  String? _subscriptionId;

  @override
  CalendarScreenState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });

    return CalendarScreenState(
      selectedDate: DateTime.now(),
      focusedMonth: DateTime.now(),
    );
  }

  // Configuration
  static const String _cacheKeyPrefix = 'calendar_events';

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load events for a baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [startDate] Start date for event range (default: 3 months ago)
  /// [endDate] End date for event range (default: 6 months from now)
  Future<void> loadEvents({
    required String babyProfileId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
      );

      // Default date range: 3 months ago to 6 months from now
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 90));
      final end = endDate ?? DateTime.now().add(const Duration(days: 180));

      // Try to load from cache first
      final cachedEvents = await _loadFromCache(babyProfileId);
      if (!ref.mounted) return;
      if (cachedEvents != null && cachedEvents.isNotEmpty) {
        final eventsByDate = _groupEventsByDate(cachedEvents);
        state = state.copyWith(
          events: cachedEvents,
          eventsByDate: eventsByDate,
          isLoading: false,
        );
        // Still fetch from database in background to ensure fresh data
        _fetchAndUpdateEvents(babyProfileId, start, end);
        return;
      }

      // Fetch from database
      await _fetchAndUpdateEvents(babyProfileId, start, end);
      if (!ref.mounted) return;

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);
      if (!ref.mounted) return;

      debugPrint('✅ Loaded ${state.events.length} events for calendar');
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to load calendar events: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Fetch and update events from database
  Future<void> _fetchAndUpdateEvents(
    String babyProfileId,
    DateTime start,
    DateTime end,
  ) async {
    final databaseService = ref.read(databaseServiceProvider);

    final response = await databaseService
        .select(SupabaseTables.events)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null)
        .gte('starts_at', start.toIso8601String())
        .lte('starts_at', end.toIso8601String())
        .order('starts_at', ascending: true);

    final events = (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();

    // Group events by date
    final eventsByDate = _groupEventsByDate(events);

    // Save to cache
    await _saveToCache(babyProfileId, events);
    if (!ref.mounted) return;

    state = state.copyWith(
      events: events,
      eventsByDate: eventsByDate,
      isLoading: false,
    );
  }

  /// Select a date
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    debugPrint('✅ Selected date: $date');
  }

  /// Navigate to next month
  void nextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    state = state.copyWith(focusedMonth: newMonth);
    debugPrint('✅ Navigated to: ${newMonth.year}-${newMonth.month}');
  }

  /// Navigate to previous month
  void previousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    state = state.copyWith(focusedMonth: newMonth);
    debugPrint('✅ Navigated to: ${newMonth.year}-${newMonth.month}');
  }

  /// Navigate to specific month
  void goToMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
    debugPrint('✅ Navigated to: ${month.year}-${month.month}');
  }

  /// Refresh events
  Future<void> refresh() async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile');
      return;
    }

    await loadEvents(
      babyProfileId: state.selectedBabyProfileId!,
    );
  }

  /// Retry after error
  Future<void> retry() async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot retry: missing baby profile');
      return;
    }

    await loadEvents(
      babyProfileId: state.selectedBabyProfileId!,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Group events by date
  Map<String, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<String, List<Event>> grouped = {};

    for (final event in events) {
      final dateKey = CalendarScreenState._getDateKey(event.startsAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    return grouped;
  }

  /// Load events from cache
  Future<List<Event>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save events to cache
  Future<void> _saveToCache(String babyProfileId, List<Event> events) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = events.map((event) => event.toJson()).toList();
      await cacheService.put(
        cacheKey,
        jsonData,
        ttlMinutes: PerformanceLimits.screenCacheDuration.inMinutes,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  /// Setup real-time subscription for events
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      final realtimeService = ref.read(realtimeServiceProvider);
      final channelName = 'events-channel-$babyProfileId';

      final stream = realtimeService.subscribe(
        table: SupabaseTables.events,
        channelName: channelName,
        filter: {
          'column': SupabaseTables.babyProfileId,
          'value': babyProfileId,
        },
      );

      _subscriptionId = channelName;

      stream.listen((payload) {
        _handleRealtimeUpdate(payload, babyProfileId);
      });

      debugPrint('✅ Real-time subscription setup for calendar events');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    if (!ref.mounted) return;
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newEvent = Event.fromJson(newData);
        final updatedEvents = [...state.events, newEvent]
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        final eventsByDate = _groupEventsByDate(updatedEvents);
        state = state.copyWith(
          events: updatedEvents,
          eventsByDate: eventsByDate,
        );
        _saveToCache(babyProfileId, updatedEvents);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedEvent = Event.fromJson(newData);
        final updatedEvents = state.events
            .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        final eventsByDate = _groupEventsByDate(updatedEvents);
        state = state.copyWith(
          events: updatedEvents,
          eventsByDate: eventsByDate,
        );
        _saveToCache(babyProfileId, updatedEvents);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedId = oldData['id'] as String;
          final updatedEvents =
              state.events.where((e) => e.id != deletedId).toList();
          final eventsByDate = _groupEventsByDate(updatedEvents);
          state = state.copyWith(
            events: updatedEvents,
            eventsByDate: eventsByDate,
          );
          _saveToCache(babyProfileId, updatedEvents);
        }
      }

      debugPrint('✅ Real-time calendar event update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      final realtimeService = ref.read(realtimeServiceProvider);
      realtimeService.unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Calendar screen provider
///
/// Usage:
/// ```dart
/// final calendarState = ref.watch(calendarScreenProvider);
/// final notifier = ref.read(calendarScreenProvider.notifier);
/// await notifier.loadEvents(babyProfileId: 'abc');
/// ```
final calendarScreenProvider =
    NotifierProvider.autoDispose<CalendarScreenNotifier, CalendarScreenState>(
        CalendarScreenNotifier.new);
