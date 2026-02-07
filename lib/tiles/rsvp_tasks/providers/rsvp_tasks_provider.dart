import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums/rsvp_status.dart';
import '../../../core/models/event.dart';
import '../../../core/models/event_rsvp.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/realtime_service.dart';

/// Event with RSVP status
class EventWithRSVP {
  final Event event;
  final EventRSVP? rsvp;
  final bool needsResponse;

  const EventWithRSVP({
    required this.event,
    this.rsvp,
    required this.needsResponse,
  });
}

/// RSVP Tasks provider for the RSVP Tasks tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches events needing RSVP
/// - Status tracking (pending/accepted/declined)
/// - Reminders support for pending RSVPs
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, Event model, EventRSVP model

/// State class for RSVP tasks
class RSVPTasksState {
  final List<EventWithRSVP> events;
  final bool isLoading;
  final String? error;
  final int pendingCount;

  const RSVPTasksState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.pendingCount = 0,
  });

  RSVPTasksState copyWith({
    List<EventWithRSVP>? events,
    bool? isLoading,
    String? error,
    int? pendingCount,
  }) {
    return RSVPTasksState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

/// RSVP Tasks provider
///
/// Manages events needing RSVP with status tracking and real-time updates.
class RSVPTasksNotifier extends StateNotifier<RSVPTasksState> {
  final DatabaseService _databaseService;
  final CacheService _cacheService;
  final RealtimeService _realtimeService;

  RSVPTasksNotifier({
    required DatabaseService databaseService,
    required CacheService cacheService,
    required RealtimeService realtimeService,
  })  : _databaseService = databaseService,
        _cacheService = cacheService,
        _realtimeService = realtimeService,
        super(const RSVPTasksState());

  // Configuration
  static const String _cacheKeyPrefix = 'rsvp_tasks';

  String? _eventsSubscriptionId;
  String? _rsvpsSubscriptionId;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch events needing RSVP for a specific user and baby profile
  ///
  /// [userId] The user identifier
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchRSVPTasks({
    required String userId,
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedEvents = await _loadFromCache(userId, babyProfileId);
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          final pendingCount = cachedEvents.where((e) => e.needsResponse).length;
          state = state.copyWith(
            events: cachedEvents,
            isLoading: false,
            pendingCount: pendingCount,
          );
          return;
        }
      }

      // Fetch from database
      final events = await _fetchFromDatabase(userId, babyProfileId);
      final pendingCount = events.where((e) => e.needsResponse).length;

      // Save to cache
      await _saveToCache(userId, babyProfileId, events);

      state = state.copyWith(
        events: events,
        isLoading: false,
        pendingCount: pendingCount,
      );

      // Setup real-time subscriptions
      await _setupRealtimeSubscriptions(userId, babyProfileId);

      debugPrint(
        '✅ Loaded ${events.length} RSVP tasks (${pendingCount} pending) for user: $userId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch RSVP tasks: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get pending RSVPs only
  List<EventWithRSVP> getPendingRSVPs() {
    return state.events.where((e) => e.needsResponse).toList();
  }

  /// Get responded RSVPs
  List<EventWithRSVP> getRespondedRSVPs() {
    return state.events.where((e) => !e.needsResponse).toList();
  }

  /// Refresh RSVP tasks
  Future<void> refresh({
    required String userId,
    required String babyProfileId,
  }) async {
    await fetchRSVPTasks(
      userId: userId,
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  /// Dispose and cleanup subscriptions
  void dispose() {
    _cancelRealtimeSubscriptions();
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch events and RSVPs from database
  Future<List<EventWithRSVP>> _fetchFromDatabase(
    String userId,
    String babyProfileId,
  ) async {
    final now = DateTime.now();

    // Fetch upcoming events for this baby profile
    final eventsResponse = await _databaseService
        .select(SupabaseTables.events)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isNull(SupabaseTables.deletedAt)
        .gte(SupabaseTables.startsAt, now.toIso8601String())
        .order(SupabaseTables.startsAt, ascending: true);

    final events = (eventsResponse as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch RSVPs for these events by this user
    final eventIds = events.map((e) => e.id).toList();
    if (eventIds.isEmpty) return [];

    final rsvpsResponse = await _databaseService
        .select(SupabaseTables.eventRSVPs)
        .eq(SupabaseTables.userId, userId)
        .inFilter(SupabaseTables.eventId, eventIds);

    final rsvps = (rsvpsResponse as List)
        .map((json) => EventRSVP.fromJson(json as Map<String, dynamic>))
        .toList();

    // Create RSVP map for quick lookup
    final rsvpMap = {for (var rsvp in rsvps) rsvp.eventId: rsvp};

    // Combine events with RSVPs
    return events.map((event) {
      final rsvp = rsvpMap[event.id];
      final needsResponse = rsvp == null || rsvp.status == RSVPStatus.pending;
      return EventWithRSVP(
        event: event,
        rsvp: rsvp,
        needsResponse: needsResponse,
      );
    }).toList();
  }

  /// Load events from cache
  Future<List<EventWithRSVP>?> _loadFromCache(
    String userId,
    String babyProfileId,
  ) async {
    if (!_cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(userId, babyProfileId);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List).map((json) {
        final eventData = json['event'] as Map<String, dynamic>;
        final rsvpData = json['rsvp'] as Map<String, dynamic>?;
        final needsResponse = json['needsResponse'] as bool;

        return EventWithRSVP(
          event: Event.fromJson(eventData),
          rsvp: rsvpData != null ? EventRSVP.fromJson(rsvpData) : null,
          needsResponse: needsResponse,
        );
      }).toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save events to cache
  Future<void> _saveToCache(
    String userId,
    String babyProfileId,
    List<EventWithRSVP> events,
  ) async {
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(userId, babyProfileId);
      final jsonData = events.map((eventWithRSVP) {
        return {
          'event': eventWithRSVP.event.toJson(),
          'rsvp': eventWithRSVP.rsvp?.toJson(),
          'needsResponse': eventWithRSVP.needsResponse,
        };
      }).toList();
      await _cacheService.put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String userId, String babyProfileId) {
    return '${_cacheKeyPrefix}_${userId}_$babyProfileId';
  }

  /// Setup real-time subscriptions for events and RSVPs
  Future<void> _setupRealtimeSubscriptions(
    String userId,
    String babyProfileId,
  ) async {
    try {
      _cancelRealtimeSubscriptions();

      // Subscribe to events
      _eventsSubscriptionId = await _realtimeService.subscribe(
        table: SupabaseTables.events,
        filter: '${SupabaseTables.babyProfileId}=eq.$babyProfileId',
        callback: (payload) {
          _handleRealtimeUpdate(payload, userId, babyProfileId);
        },
      );

      // Subscribe to RSVPs
      _rsvpsSubscriptionId = await _realtimeService.subscribe(
        table: SupabaseTables.eventRSVPs,
        filter: '${SupabaseTables.userId}=eq.$userId',
        callback: (payload) {
          _handleRealtimeUpdate(payload, userId, babyProfileId);
        },
      );

      debugPrint('✅ Real-time subscriptions setup for RSVP tasks');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscriptions: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    String userId,
    String babyProfileId,
  ) {
    try {
      // Refresh data on any change
      fetchRSVPTasks(
        userId: userId,
        babyProfileId: babyProfileId,
        forceRefresh: true,
      );

      debugPrint('✅ Real-time RSVP update processed');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscriptions
  void _cancelRealtimeSubscriptions() {
    if (_eventsSubscriptionId != null) {
      _realtimeService.unsubscribe(_eventsSubscriptionId!);
      _eventsSubscriptionId = null;
    }
    if (_rsvpsSubscriptionId != null) {
      _realtimeService.unsubscribe(_rsvpsSubscriptionId!);
      _rsvpsSubscriptionId = null;
    }
    debugPrint('✅ Real-time subscriptions cancelled');
  }
}

/// Provider for RSVP tasks
///
/// Usage:
/// ```dart
/// final rsvpState = ref.watch(rsvpTasksProvider);
/// final notifier = ref.read(rsvpTasksProvider.notifier);
/// await notifier.fetchRSVPTasks(userId: 'user123', babyProfileId: 'abc');
/// ```
final rsvpTasksProvider =
    StateNotifierProvider.autoDispose<RSVPTasksNotifier, RSVPTasksState>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final realtimeService = ref.watch(realtimeServiceProvider);

    final notifier = RSVPTasksNotifier(
      databaseService: databaseService,
      cacheService: cacheService,
      realtimeService: realtimeService,
    );

    ref.onDispose(() {
      notifier.dispose();
    });

    return notifier;
  },
);
