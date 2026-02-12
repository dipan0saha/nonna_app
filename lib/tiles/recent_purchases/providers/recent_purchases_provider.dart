import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/registry_purchase.dart';

/// Recent Purchases provider for the Recent Purchases tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches recent registry purchases
/// - Thank you status tracking
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, RegistryPurchase model

/// State class for recent purchases
class RecentPurchasesState {
  final List<RegistryPurchase> purchases;
  final bool isLoading;
  final String? error;
  final int unthankedCount;

  const RecentPurchasesState({
    this.purchases = const [],
    this.isLoading = false,
    this.error,
    this.unthankedCount = 0,
  });

  RecentPurchasesState copyWith({
    List<RegistryPurchase>? purchases,
    bool? isLoading,
    String? error,
    int? unthankedCount,
  }) {
    return RecentPurchasesState(
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unthankedCount: unthankedCount ?? this.unthankedCount,
    );
  }
}

/// Recent Purchases provider
///
/// Manages recent purchases with thank you status tracking and real-time updates.
class RecentPurchasesNotifier extends Notifier<RecentPurchasesState> {
  // Configuration
  static const String _cacheKeyPrefix = 'recent_purchases';
  static const int _maxPurchases = 20;

  late final _realtimeService = ref.read(realtimeServiceProvider);
  String? _subscriptionId;

  @override
  RecentPurchasesState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const RecentPurchasesState();
  }

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch recent purchases for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchPurchases({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedPurchases = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
        if (cachedPurchases != null && cachedPurchases.isNotEmpty) {
          final unthankedCount = 0;
          state = state.copyWith(
            purchases: cachedPurchases,
            isLoading: false,
            unthankedCount: unthankedCount,
          );
          return;
        }
      }

      // Fetch from database
      final purchases = await _fetchFromDatabase(babyProfileId);
      if (!ref.mounted) return;
      final unthankedCount = 0; // Removed thank you tracking from this version

      // Save to cache
      await _saveToCache(babyProfileId, purchases);
      if (!ref.mounted) return;

      state = state.copyWith(
        purchases: purchases,
        isLoading: false,
        unthankedCount: unthankedCount,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);

      debugPrint(
        '✅ Loaded ${purchases.length} recent purchases for profile: $babyProfileId',
      );
    } catch (e) {
      if (!ref.mounted) return;
      final errorMessage = 'Failed to fetch recent purchases: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get recent purchases (all purchases are shown)
  List<RegistryPurchase> getAllPurchases() {
    return state.purchases;
  }

  /// Refresh purchases
  Future<void> refresh({required String babyProfileId}) async {
    await fetchPurchases(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch purchases from database
  Future<List<RegistryPurchase>> _fetchFromDatabase(
    String babyProfileId,
  ) async {
    // First get all registry items for this baby profile
    final itemsResponse = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.registryItems)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null);

    final itemIds =
        (itemsResponse as List).map((json) => json['id'] as String).toList();

    if (itemIds.isEmpty) return [];

    // Then fetch purchases for these items
    final response = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.registryPurchases)
        .inFilter('registry_item_id', itemIds)
        .isFilter(SupabaseTables.deletedAt, null)
        .order(SupabaseTables.createdAt, ascending: false)
        .limit(_maxPurchases);

    return (response as List)
        .map((json) => RegistryPurchase.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Load purchases from cache
  Future<List<RegistryPurchase>?> _loadFromCache(String babyProfileId) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map(
              (json) => RegistryPurchase.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save purchases to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<RegistryPurchase> purchases,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = purchases.map((p) => p.toJson()).toList();
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

  /// Setup real-time subscription for purchases
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      final channelName = 'registry-purchases-channel-$babyProfileId';
      final stream = _realtimeService.subscribe(
        table: SupabaseTables.registryPurchases,
        channelName: channelName,
      );

      _subscriptionId = channelName;

      stream.listen((payload) {
        _handleRealtimeUpdate(payload, babyProfileId);
      });

      debugPrint('✅ Real-time subscription setup for purchases');
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
        final newPurchase = RegistryPurchase.fromJson(newData);
        final updatedPurchases = [newPurchase, ...state.purchases];
        state = state.copyWith(
          purchases: updatedPurchases,
          unthankedCount: 0,
        );
        _saveToCache(babyProfileId, updatedPurchases);
      } else if (eventType == 'UPDATE' && newData != null) {
        final updatedPurchase = RegistryPurchase.fromJson(newData);
        final updatedPurchases = state.purchases
            .map((p) => p.id == updatedPurchase.id ? updatedPurchase : p)
            .toList();
        state = state.copyWith(
          purchases: updatedPurchases,
          unthankedCount: 0,
        );
        _saveToCache(babyProfileId, updatedPurchases);
      } else if (eventType == 'DELETE') {
        final oldData = payload['old'] as Map<String, dynamic>?;
        if (oldData != null) {
          final deletedId = oldData['id'] as String;
          final updatedPurchases =
              state.purchases.where((p) => p.id != deletedId).toList();
          state = state.copyWith(
            purchases: updatedPurchases,
            unthankedCount: 0,
          );
          _saveToCache(babyProfileId, updatedPurchases);
        }
      }

      debugPrint('✅ Real-time purchase update processed: $eventType');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
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

/// Provider for recent purchases
///
/// Usage:
/// ```dart
/// final purchasesState = ref.watch(recentPurchasesProvider);
/// final notifier = ref.read(recentPurchasesProvider.notifier);
/// await notifier.fetchPurchases(babyProfileId: 'abc');
/// ```
final recentPurchasesProvider =
    NotifierProvider.autoDispose<RecentPurchasesNotifier, RecentPurchasesState>(
  RecentPurchasesNotifier.new,
);
