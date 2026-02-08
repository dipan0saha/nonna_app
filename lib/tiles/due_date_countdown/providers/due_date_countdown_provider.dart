import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/baby_profile.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/realtime_service.dart';

/// Baby profile with countdown info
class BabyCountdown {
  final BabyProfile profile;
  final int daysUntilDueDate;
  final bool isPastDue;
  final String formattedCountdown;

  const BabyCountdown({
    required this.profile,
    required this.daysUntilDueDate,
    required this.isPastDue,
    required this.formattedCountdown,
  });
}

/// Due Date Countdown provider for the Due Date Countdown tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Calculates days until due date from BabyProfile
/// - Countdown formatting (days/weeks/months)
/// - Multiple babies support
/// - Past due date handling
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, BabyProfile model

/// State class for due date countdown
class DueDateCountdownState {
  final List<BabyCountdown> countdowns;
  final bool isLoading;
  final String? error;

  const DueDateCountdownState({
    this.countdowns = const [],
    this.isLoading = false,
    this.error,
  });

  DueDateCountdownState copyWith({
    List<BabyCountdown>? countdowns,
    bool? isLoading,
    String? error,
  }) {
    return DueDateCountdownState(
      countdowns: countdowns ?? this.countdowns,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Due Date Countdown provider
///
/// Manages due date countdowns with automatic calculations and formatting.
class DueDateCountdownNotifier extends Notifier<DueDateCountdownState> {
  // Configuration
  static const String _cacheKeyPrefix = 'due_date_countdown';

  String? _subscriptionId;

  @override
  DueDateCountdownState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const DueDateCountdownState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch due date countdown for baby profiles
  ///
  /// [babyProfileIds] List of baby profile identifiers
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchCountdowns({
    required List<String> babyProfileIds,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      if (babyProfileIds.isEmpty) {
        state = state.copyWith(
          countdowns: [],
          isLoading: false,
        );
        return;
      }

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedCountdowns = await _loadFromCache(babyProfileIds);
        if (cachedCountdowns != null && cachedCountdowns.isNotEmpty) {
          state = state.copyWith(
            countdowns: cachedCountdowns,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch from database
      final countdowns = await _fetchFromDatabase(babyProfileIds);

      // Save to cache
      await _saveToCache(babyProfileIds, countdowns);

      state = state.copyWith(
        countdowns: countdowns,
        isLoading: false,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileIds);

      debugPrint(
        '✅ Loaded ${countdowns.length} due date countdowns',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch due date countdowns: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh countdowns
  Future<void> refresh({required List<String> babyProfileIds}) async {
    await fetchCountdowns(
      babyProfileIds: babyProfileIds,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch baby profiles and calculate countdowns
  Future<List<BabyCountdown>> _fetchFromDatabase(
    List<String> babyProfileIds,
  ) async {
    final databaseService = ref.read(databaseServiceProvider);
    final response = await databaseService
        .select(SupabaseTables.babyProfiles)
        .inFilter(SupabaseTables.id, babyProfileIds)
        .is_(SupabaseTables.deletedAt, null);

    final profiles = (response as List)
        .map((json) => BabyProfile.fromJson(json as Map<String, dynamic>))
        .toList();

    return profiles.map((profile) => _calculateCountdown(profile)).toList();
  }

  /// Calculate countdown for a baby profile
  BabyCountdown _calculateCountdown(BabyProfile profile) {
    if (profile.expectedBirthDate == null) {
      return BabyCountdown(
        profile: profile,
        daysUntilDueDate: 0,
        isPastDue: false,
        formattedCountdown: 'Due date not set',
      );
    }

    final now = DateTime.now();
    final dueDate = profile.expectedBirthDate!;
    final difference = dueDate.difference(now);
    final daysUntil = difference.inDays;

    String formatted;
    bool isPastDue = false;

    if (daysUntil < 0) {
      isPastDue = true;
      final daysPast = daysUntil.abs();
      if (daysPast == 1) {
        formatted = '1 day overdue';
      } else {
        formatted = '$daysPast days overdue';
      }
    } else if (daysUntil == 0) {
      formatted = 'Due today!';
    } else if (daysUntil == 1) {
      formatted = '1 day until due date';
    } else if (daysUntil < 7) {
      formatted = '$daysUntil days until due date';
    } else if (daysUntil < 30) {
      final weeks = (daysUntil / 7).floor();
      final remainingDays = daysUntil % 7;
      if (remainingDays == 0) {
        formatted = '$weeks ${weeks == 1 ? "week" : "weeks"}';
      } else {
        formatted = '$weeks ${weeks == 1 ? "week" : "weeks"}, $remainingDays ${remainingDays == 1 ? "day" : "days"}';
      }
    } else {
      final months = (daysUntil / 30).floor();
      final remainingDays = daysUntil % 30;
      if (remainingDays == 0) {
        formatted = '$months ${months == 1 ? "month" : "months"}';
      } else {
        formatted = '$months ${months == 1 ? "month" : "months"}, $remainingDays ${remainingDays == 1 ? "day" : "days"}';
      }
    }

    return BabyCountdown(
      profile: profile,
      daysUntilDueDate: daysUntil,
      isPastDue: isPastDue,
      formattedCountdown: formatted,
    );
  }

  /// Load countdowns from cache
  Future<List<BabyCountdown>?> _loadFromCache(
    List<String> babyProfileIds,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileIds);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List).map((json) {
        final profileData = json['profile'] as Map<String, dynamic>;
        final profile = BabyProfile.fromJson(profileData);
        // Recalculate countdown with current date
        return _calculateCountdown(profile);
      }).toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save countdowns to cache
  Future<void> _saveToCache(
    List<String> babyProfileIds,
    List<BabyCountdown> countdowns,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileIds);
      final jsonData = countdowns.map((countdown) {
        return {
          'profile': countdown.profile.toJson(),
        };
      }).toList();
      await cacheService.put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(List<String> babyProfileIds) {
    final idsString = babyProfileIds.join('_');
    return '${_cacheKeyPrefix}_$idsString';
  }

  /// Setup real-time subscription for baby profiles
  Future<void> _setupRealtimeSubscription(List<String> babyProfileIds) async {
    try {
      _cancelRealtimeSubscription();

      if (babyProfileIds.isEmpty) return;

      final realtimeService = ref.read(realtimeServiceProvider);
      // Subscribe to any baby profile changes
      final channelName = 'baby-profiles-channel-${babyProfileIds.join("-")}';
      final stream = realtimeService.subscribe(
        table: SupabaseTables.babyProfiles,
        channelName: channelName,
      );
      
      _subscriptionId = channelName;
      
      stream.listen((payload) {
        _handleRealtimeUpdate(payload, babyProfileIds);
      });

      debugPrint('✅ Real-time subscription setup for due date countdowns');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    List<String> babyProfileIds,
  ) {
    try {
      // Refresh data on any change to baby profile
      fetchCountdowns(
        babyProfileIds: babyProfileIds,
        forceRefresh: true,
      );

      debugPrint('✅ Real-time due date update processed');
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

/// Provider for due date countdown
///
/// Usage:
/// ```dart
/// final countdownState = ref.watch(dueDateCountdownProvider);
/// final notifier = ref.read(dueDateCountdownProvider.notifier);
/// await notifier.fetchCountdowns(babyProfileIds: ['abc', 'def']);
/// ```
final dueDateCountdownProvider = NotifierProvider.autoDispose<
    DueDateCountdownNotifier, DueDateCountdownState>(
  DueDateCountdownNotifier.new,
);
