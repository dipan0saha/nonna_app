import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/baby_membership.dart';

/// New Followers provider for the New Followers tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Recent follower additions (owner only)
/// - Active/removed status from BabyMembership
/// - Tracks recent memberships added in last 30 days
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, BabyMembership model

/// State class for new followers
class NewFollowersState {
  final List<BabyMembership> followers;
  final bool isLoading;
  final String? error;
  final int activeCount;

  const NewFollowersState({
    this.followers = const [],
    this.isLoading = false,
    this.error,
    this.activeCount = 0,
  });

  NewFollowersState copyWith({
    List<BabyMembership>? followers,
    bool? isLoading,
    String? error,
    int? activeCount,
  }) {
    return NewFollowersState(
      followers: followers ?? this.followers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeCount: activeCount ?? this.activeCount,
    );
  }
}

/// New Followers provider
///
/// Manages recent followers with active/removed status tracking and real-time updates.
class NewFollowersNotifier extends Notifier<NewFollowersState> {
  // Configuration
  static const String _cacheKeyPrefix = 'new_followers';
  static const int _maxFollowers = 20;
  static const int _recentDaysThreshold =
      30; // Show followers from last 30 days

  String? _subscriptionId;
  // Store realtime service reference to avoid ref.read() in onDispose
  late final _realtimeService = ref.read(realtimeServiceProvider);

  @override
  NewFollowersState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const NewFollowersState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch new followers for a specific baby profile (owner only)
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchFollowers({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedFollowers = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
        if (cachedFollowers != null && cachedFollowers.isNotEmpty) {
          final activeCount =
              cachedFollowers.where((follower) => follower.isActive).length;
          state = state.copyWith(
            followers: cachedFollowers,
            isLoading: false,
            activeCount: activeCount,
          );
          return;
        }
      }

      // Fetch from database
      final followers = await _fetchFromDatabase(babyProfileId);
      if (!ref.mounted) return;
      final activeCount =
          followers.where((follower) => follower.isActive).length;

      // Save to cache
      await _saveToCache(babyProfileId, followers);
      if (!ref.mounted) return;

      state = state.copyWith(
        followers: followers,
        isLoading: false,
        activeCount: activeCount,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);
      if (!ref.mounted) return;

      debugPrint(
        '✅ Loaded ${followers.length} new followers ($activeCount active) for profile: $babyProfileId',
      );
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to fetch new followers: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get active followers only
  List<BabyMembership> getActiveFollowers() {
    return state.followers.where((follower) => follower.isActive).toList();
  }

  /// Get removed followers
  List<BabyMembership> getRemovedFollowers() {
    return state.followers.where((follower) => follower.isRemoved).toList();
  }

  /// Refresh followers
  Future<void> refresh({required String babyProfileId}) async {
    await fetchFollowers(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch followers from database
  Future<List<BabyMembership>> _fetchFromDatabase(String babyProfileId) async {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: _recentDaysThreshold),
    );

    final response = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.babyMemberships)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .gte(SupabaseTables.createdAt, cutoffDate.toIso8601String())
        .isFilter('removed_at', null) // Only get active members
        .order(SupabaseTables.createdAt, ascending: false)
        .limit(_maxFollowers);

    return (response as List)
        .map((json) => BabyMembership.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load followers from cache
  Future<List<BabyMembership>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => BabyMembership.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save followers to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<BabyMembership> followers,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = followers.map((f) => f.toJson()).toList();
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

  /// Setup real-time subscription for baby memberships
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      final channelName = 'baby-memberships-channel-$babyProfileId';
      final stream = _realtimeService.subscribe(
        table: SupabaseTables.babyMemberships,
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

      debugPrint('✅ Real-time subscription setup for new followers');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscription: $e');
    }
  }

  /// Handle real-time update
  void _handleRealtimeUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    try {
      final eventType = payload['eventType'] as String?;
      final newData = payload['new'] as Map<String, dynamic>?;

      if (eventType == 'INSERT' && newData != null) {
        final newFollower = BabyMembership.fromJson(newData);
        final updatedFollowers = [newFollower, ...state.followers];
        final activeCount =
            updatedFollowers.where((follower) => follower.isActive).length;
        state = state.copyWith(
          followers: updatedFollowers,
          activeCount: activeCount,
        );
        _saveToCache(babyProfileId, updatedFollowers);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedFollower = BabyMembership.fromJson(newData);
        final updatedFollowers = state.followers
            .map((follower) => _isMatchingFollower(follower, updatedFollower)
                ? updatedFollower
                : follower)
            .toList();
        final activeCount =
            updatedFollowers.where((follower) => follower.isActive).length;
        state = state.copyWith(
          followers: updatedFollowers,
          activeCount: activeCount,
        );
        _saveToCache(babyProfileId, updatedFollowers);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedBabyProfileId = oldData['baby_profile_id'] as String;
          final deletedUserId = oldData['user_id'] as String;
          final updatedFollowers = state.followers
              .where((follower) => _isNotDeletedFollower(
                  follower, deletedBabyProfileId, deletedUserId))
              .toList();
          final activeCount =
              updatedFollowers.where((follower) => follower.isActive).length;
          state = state.copyWith(
            followers: updatedFollowers,
            activeCount: activeCount,
          );
          _saveToCache(babyProfileId, updatedFollowers);
        }
      }

      debugPrint('✅ Real-time follower update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Check if follower matches the updated follower
  bool _isMatchingFollower(
      BabyMembership follower, BabyMembership updatedFollower) {
    return follower.babyProfileId == updatedFollower.babyProfileId &&
        follower.userId == updatedFollower.userId;
  }

  /// Check if follower is not the deleted follower
  bool _isNotDeletedFollower(
    BabyMembership follower,
    String deletedBabyProfileId,
    String deletedUserId,
  ) {
    return follower.babyProfileId != deletedBabyProfileId ||
        follower.userId != deletedUserId;
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      _realtimeService.unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Provider for new followers
///
/// Usage:
/// ```dart
/// final followersState = ref.watch(newFollowersProvider);
/// final notifier = ref.read(newFollowersProvider.notifier);
/// await notifier.fetchFollowers(babyProfileId: 'abc');
/// ```
final newFollowersProvider =
    NotifierProvider.autoDispose<NewFollowersNotifier, NewFollowersState>(
  NewFollowersNotifier.new,
);
