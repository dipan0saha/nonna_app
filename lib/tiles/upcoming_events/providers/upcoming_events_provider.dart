import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/models/event.dart';

/// Upcoming Events provider for the Upcoming Events tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches upcoming events from Supabase
/// - Role-based filtering (owner vs. follower)
/// - Pagination support for large event lists
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Event model

/// State class for upcoming events
class UpcomingEventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const UpcomingEventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  UpcomingEventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return UpcomingEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Upcoming Events provider
///
/// Manages upcoming events with pagination, caching, and real-time updates.
class UpcomingEventsNotifier extends Notifier<UpcomingEventsState> {
  @override
  UpcomingEventsState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const UpcomingEventsState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'upcoming_events';
  static const int _pageSize = 20;

  String? _subscriptionId;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch upcoming events for a specific baby profile and role
  ///
  /// [babyProfileId] The baby profile identifier
  /// [role] The user role (owner or follower)
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchEvents({
    required String babyProfileId,
    required UserRole role,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedEvents = await _loadFromCache(babyProfileId);
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          state = state.copyWith(
            events: cachedEvents,
            isLoading: false,
            currentPage: 1,
          );
          return;
        }
      }

      // Fetch from database
      final events = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: 0,
      );

      // Save to cache
      await _saveToCache(babyProfileId, events);

      state = state.copyWith(
        events: events,
        isLoading: false,
        hasMore: events.length >= _pageSize,
        currentPage: 1,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);

      debugPrint(
        '✅ Loaded ${events.length} upcoming events for profile: $babyProfileId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch upcoming events: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Load more events (pagination)
  Future<void> loadMore({required String babyProfileId}) async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final offset = state.currentPage * _pageSize;
      final newEvents = await _fetchFromDatabase(
        babyProfileId: babyProfileId,
        limit: _pageSize,
        offset: offset,
      );

      final updatedEvents = [...state.events, ...newEvents];

      state = state.copyWith(
        events: updatedEvents,
        isLoading: false,
        hasMore: newEvents.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );

      // Update cache
      await _saveToCache(babyProfileId, updatedEvents);

      debugPrint('✅ Loaded ${newEvents.length} more events');
    } catch (e) {
      debugPrint('❌ Failed to load more events: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Refresh events
  Future<void> refresh({
    required String babyProfileId,
    required UserRole role,
  }) async {
    await fetchEvents(
      babyProfileId: babyProfileId,
      role: role,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch events from database
  Future<List<Event>> _fetchFromDatabase({
    required String babyProfileId,
    required int limit,
    required int offset,
  }) async {
    final databaseService = ref.read(databaseServiceProvider);
    final now = DateTime.now();

    final response = await databaseService
        .select(SupabaseTables.events)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null)
        .gte('starts_at', now.toIso8601String())
        .order('starts_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
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
      await cacheService.put(cacheKey, jsonData,
          ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
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

      final channelName = 'events-channel-$babyProfileId';
      final stream = ref.read(realtimeServiceProvider).subscribe(
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

      debugPrint('✅ Real-time subscription setup for events');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
      Map<String, dynamic> payload, String babyProfileId) {
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newEvent = Event.fromJson(newData);
        final updatedEvents = [newEvent, ...state.events]
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        state = state.copyWith(events: updatedEvents);
        _saveToCache(babyProfileId, updatedEvents);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedEvent = Event.fromJson(newData);
        final updatedEvents = state.events
            .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        state = state.copyWith(events: updatedEvents);
        _saveToCache(babyProfileId, updatedEvents);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedId = oldData['id'] as String;
          final updatedEvents =
              state.events.where((e) => e.id != deletedId).toList();
          state = state.copyWith(events: updatedEvents);
          _saveToCache(babyProfileId, updatedEvents);
        }
      }

      debugPrint('✅ Real-time event update processed: $eventType');
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

/// Provider for upcoming events
///
/// Usage:
/// ```dart
/// final eventsState = ref.watch(upcomingEventsProvider);
/// final notifier = ref.read(upcomingEventsProvider.notifier);
/// await notifier.fetchEvents(babyProfileId: 'abc', role: UserRole.owner);
/// ```
final upcomingEventsProvider =
    NotifierProvider.autoDispose<UpcomingEventsNotifier, UpcomingEventsState>(
  UpcomingEventsNotifier.new,
);
