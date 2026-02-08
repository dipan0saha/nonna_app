import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/performance_limits.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/registry_item.dart';
import '../../../core/models/registry_purchase.dart';

/// Registry item with purchase status
class RegistryItemWithStatus {
  final RegistryItem item;
  final bool isPurchased;
  final List<RegistryPurchase> purchases;

  const RegistryItemWithStatus({
    required this.item,
    required this.isPurchased,
    this.purchases = const [],
  });
}

/// Registry Highlights provider for the Registry Highlights tile
///
/// **Functional Requirements**: Section 3.5.4 - Tile-Specific Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Fetches top registry items based on priority
/// - Priority sorting (highest first)
/// - Purchase status tracking
/// - Local caching with TTL
///
/// Dependencies: DatabaseService, CacheService, RegistryItem model, RegistryPurchase model

/// State class for registry highlights
class RegistryHighlightsState {
  final List<RegistryItemWithStatus> items;
  final bool isLoading;
  final String? error;

  const RegistryHighlightsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  RegistryHighlightsState copyWith({
    List<RegistryItemWithStatus>? items,
    bool? isLoading,
    String? error,
  }) {
    return RegistryHighlightsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Registry Highlights provider
///
/// Manages registry highlights with priority sorting and purchase status.
class RegistryHighlightsNotifier extends Notifier<RegistryHighlightsState> {
  @override
  RegistryHighlightsState build() {
    return const RegistryHighlightsState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'registry_highlights';
  static const int _maxItems = 10; // Show top 10 items

  // ==========================================
  // Public Methods
  // ==========================================

  /// Fetch registry highlights for a specific baby profile
  ///
  /// [babyProfileId] The baby profile identifier
  /// [forceRefresh] Whether to bypass cache and fetch from server
  Future<void> fetchHighlights({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedItems = await _loadFromCache(babyProfileId);
        if (cachedItems != null && cachedItems.isNotEmpty) {
          state = state.copyWith(
            items: cachedItems,
            isLoading: false,
          );
          return;
        }
      }

      // Fetch registry items sorted by priority
      final items = await _fetchFromDatabase(babyProfileId);

      // Fetch purchase status for each item
      final itemsWithStatus = await _fetchPurchaseStatus(items);

      // Save to cache
      await _saveToCache(babyProfileId, itemsWithStatus);

      state = state.copyWith(
        items: itemsWithStatus,
        isLoading: false,
      );

      debugPrint(
        '✅ Loaded ${itemsWithStatus.length} registry highlights for profile: $babyProfileId',
      );
    } catch (e) {
      final errorMessage = 'Failed to fetch registry highlights: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Refresh registry highlights
  Future<void> refresh({required String babyProfileId}) async {
    await fetchHighlights(
      babyProfileId: babyProfileId,
      forceRefresh: true,
    );
  }

  /// Get unpurchased items only
  List<RegistryItemWithStatus> getUnpurchasedItems() {
    return state.items.where((item) => !item.isPurchased).toList();
  }

  /// Get high priority items only
  List<RegistryItemWithStatus> getHighPriorityItems() {
    return state.items.where((item) => item.item.priority >= 4).toList();
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch registry items from database
  Future<List<RegistryItem>> _fetchFromDatabase(String babyProfileId) async {
    final response = await ref
        .read(databaseServiceProvider)
        .select(SupabaseTables.registryItems)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .is_(SupabaseTables.deletedAt, null)
        .order('priority', ascending: false)
        .order(SupabaseTables.createdAt, ascending: false)
        .limit(_maxItems);

    return (response as List)
        .map((json) => RegistryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch purchase status for items
  Future<List<RegistryItemWithStatus>> _fetchPurchaseStatus(
    List<RegistryItem> items,
  ) async {
    if (items.isEmpty) return [];

    final itemsWithStatus = <RegistryItemWithStatus>[];

    for (final item in items) {
      try {
        // Fetch purchases for this item
        final response = await ref
            .read(databaseServiceProvider)
            .select(SupabaseTables.registryPurchases)
            .eq('registry_item_id', item.id)
            .is_(SupabaseTables.deletedAt, null);

        final purchases = (response as List)
            .map((json) =>
                RegistryPurchase.fromJson(json as Map<String, dynamic>))
            .toList();

        itemsWithStatus.add(
          RegistryItemWithStatus(
            item: item,
            isPurchased: purchases.isNotEmpty,
            purchases: purchases,
          ),
        );
      } catch (e) {
        debugPrint(
            '⚠️  Failed to fetch purchase status for item ${item.id}: $e');
        // Add item without purchase status
        itemsWithStatus.add(
          RegistryItemWithStatus(
            item: item,
            isPurchased: false,
            purchases: [],
          ),
        );
      }
    }

    return itemsWithStatus;
  }

  /// Load items from cache
  Future<List<RegistryItemWithStatus>?> _loadFromCache(
    String babyProfileId,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await ref.read(cacheServiceProvider).get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List).map((json) {
        final itemData = json['item'] as Map<String, dynamic>;
        final isPurchased = json['isPurchased'] as bool;
        final purchasesData = json['purchases'] as List;

        return RegistryItemWithStatus(
          item: RegistryItem.fromJson(itemData),
          isPurchased: isPurchased,
          purchases: purchasesData
              .map((p) => RegistryPurchase.fromJson(p as Map<String, dynamic>))
              .toList(),
        );
      }).toList();
    } catch (e) {
      debugPrint('⚠️  Failed to load from cache: $e');
      return null;
    }
  }

  /// Save items to cache
  Future<void> _saveToCache(
    String babyProfileId,
    List<RegistryItemWithStatus> items,
  ) async {
    if (!ref.read(cacheServiceProvider).isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = items.map((itemWithStatus) {
        return {
          'item': itemWithStatus.item.toJson(),
          'isPurchased': itemWithStatus.isPurchased,
          'purchases': itemWithStatus.purchases.map((p) => p.toJson()).toList(),
        };
      }).toList();
      await ref.read(cacheServiceProvider).put(cacheKey, jsonData,
          ttlMinutes: PerformanceLimits.tileCacheDuration.inMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }
}

/// Provider for registry highlights
///
/// Usage:
/// ```dart
/// final highlightsState = ref.watch(registryHighlightsProvider);
/// final notifier = ref.read(registryHighlightsProvider.notifier);
/// await notifier.fetchHighlights(babyProfileId: 'abc');
/// ```
final registryHighlightsProvider = NotifierProvider.autoDispose<
    RegistryHighlightsNotifier, RegistryHighlightsState>(
  RegistryHighlightsNotifier.new,
);
