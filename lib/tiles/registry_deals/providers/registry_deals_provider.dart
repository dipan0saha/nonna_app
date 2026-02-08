import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/registry_item.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/realtime_service.dart';

/// Registry Deals provider for the Registry Deals tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches recommended items (high priority unpurchased items)
/// - Deal tracking and promotion
/// - Priority-based sorting
/// - Real-time updates via Supabase subscriptions
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, RegistryItem model

/// State class for registry deals
class RegistryDealsState {
  final List<RegistryItem> deals;
  final bool isLoading;
  final String? error;

  const RegistryDealsState({
    this.deals = const [],
    this.isLoading = false,
    this.error,
  });

  RegistryDealsState copyWith({
    List<RegistryItem>? deals,
    bool? isLoading,
    String? error,
  }) {
    return RegistryDealsState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Registry Deals provider
///
/// Manages registry deals (high priority unpurchased items) with real-time updates.
class RegistryDealsNotifier extends Notifier<RegistryDealsState> {
  @override
  RegistryDealsState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscription();
    });
    return const RegistryDealsState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'registry_deals';
  static const int _maxDeals = 15;
  static const int _minPriority = 3; // Show items with priority >= 3

  String? _subscriptionId;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch registry deals for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchDeals({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedDeals = await _loadFromCache(babyProfileId);
        if (cachedDeals != null && cachedDeals.isNotEmpty) {
          state = state.copyWith(
            deals: cachedDeals,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch from database
      final deals = await _fetchFromDatabase(babyProfileId);

      // Save to cache
      await _saveToCache(babyProfileId, deals);

      state = state.copyWith(
        deals: deals,
        isLoading: false,
      );

      // Setup real-time subscription
      await _setupRealtimeSubscription(babyProfileId);

      debugPrint(
        '✅ Loaded ${deals.length} registry deals for profile: $babyProfileId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch registry deals: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Get high priority items only (priority >= 4)
  List<RegistryItem> getHighPriorityDeals() {
    return state.deals.where((item) => item.priority >= 4).toList();
  }

  /// Refresh deals
  Future<void> refresh({required String babyProfileId}) async {
    await fetchDeals(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }



  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch unpurchased high-priority items from database
  Future<List<RegistryItem>> _fetchFromDatabase(String babyProfileId) async {
    // Get all registry items for this profile
    final itemsResponse = await ref.read(databaseServiceProvider)
        .select(SupabaseTables.registryItems)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isNull(SupabaseTables.deletedAt)
        .gte(SupabaseTables.priority, _minPriority)
        .order(SupabaseTables.priority, ascending: false)
        .order(SupabaseTables.createdAt, ascending: false);

    final items = (itemsResponse as List)
        .map((json) => RegistryItem.fromJson(json as Map<String, dynamic>))
        .toList();

    if (items.isEmpty) return [];

    // Check which items have been purchased
    final itemIds = items.map((item) => item.id).toList();
    final purchasesResponse = await ref.read(databaseServiceProvider)
        .select(SupabaseTables.registryPurchases)
        .inFilter(SupabaseTables.registryItemId, itemIds)
        .isNull(SupabaseTables.deletedAt);

    final purchasedItemIds = (purchasesResponse as List)
        .map((json) => json[SupabaseTables.registryItemId] as String)
        .toSet();

    // Filter out purchased items and limit to max deals
    final unpurchasedItems = items
        .where((item) => !purchasedItemIds.contains(item.id))
        .take(_maxDeals)
        .toList();

    return unpurchasedItems;
  }

  /// Load deals from cache
  Future<List<RegistryItem>?> _loadFromCache(String babyProfileId) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await ref.read(cacheServiceProvider).get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List)
          .map((json) => RegistryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save deals to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<RegistryItem> deals,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = deals.map((item) => item.toJson()).toList();
      await ref.read(cacheServiceProvider).put(cacheKey, jsonData, ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  /// Setup real-time subscription for registry items
  Future<void> _setupRealtimeSubscription(String babyProfileId) async {
    try {
      _cancelRealtimeSubscription();

      _subscriptionId = await ref.read(realtimeServiceProvider).subscribe(
        table: SupabaseTables.registryItems,
        filter: '${SupabaseTables.babyProfileId}=eq.$babyProfileId',
        callback: (payload) {
          _handleRealtimeUpdate(payload, babyProfileId);
        },
      );

      debugPrint('✅ Real-time subscription setup for registry deals');
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
      // Refresh data on any change
      fetchDeals(
        babyProfileId: babyProfileId,
        forceRefresh: true,
      );

      debugPrint('✅ Real-time registry deal update processed');
    } catch (e) {
      debugPrint('❌ Failed to handle real-time update: $e');
    }
  }

  /// Cancel real-time subscription
  void _cancelRealtimeSubscription() {
    if (_subscriptionId != null) {
      ref.read(realtimeServiceProvider).unsubscribe(_subscriptionId!);
      _subscriptionId = null;
      debugPrint('✅ Real-time subscription cancelled');
    }
  }
}

/// Provider for registry deals
///
/// Usage:
/// ```dart
/// final dealsState = ref.watch(registryDealsProvider);
/// final notifier = ref.read(registryDealsProvider.notifier);
/// await notifier.fetchDeals(babyProfileId: 'abc');
/// ```
final registryDealsProvider =
    NotifierProvider.autoDispose<RegistryDealsNotifier, RegistryDealsState>(
  RegistryDealsNotifier.new,
);
