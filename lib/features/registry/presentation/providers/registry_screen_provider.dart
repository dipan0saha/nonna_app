import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/registry_item.dart';
import '../../../../core/models/registry_purchase.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/realtime_service.dart';

/// Registry Screen Provider for managing registry state
///
/// **Functional Requirements**: Section 3.5.3 - Feature Providers
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Registry state management
/// - Item list display
/// - Filters (priority, purchased status)
/// - Purchase state tracking
/// - Sorting options
///
/// Dependencies: DatabaseService, CacheService, RealtimeService, RegistryItem model

/// Registry filter options
enum RegistryFilter {
  all,
  highPriority,
  purchased,
  unpurchased,
}

/// Registry sort options
enum RegistrySort {
  priorityHigh,
  priorityLow,
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
}

/// Registry item with purchase status
class RegistryItemWithStatus {
  final RegistryItem item;
  final bool isPurchased;
  final int purchaseCount;

  const RegistryItemWithStatus({
    required this.item,
    required this.isPurchased,
    this.purchaseCount = 0,
  });
}

/// Registry screen state model
class RegistryScreenState {
  final List<RegistryItemWithStatus> items;
  final bool isLoading;
  final String? error;
  final RegistryFilter currentFilter;
  final RegistrySort currentSort;
  final String? selectedBabyProfileId;

  const RegistryScreenState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.currentFilter = RegistryFilter.all,
    this.currentSort = RegistrySort.priorityHigh,
    this.selectedBabyProfileId,
  });

  RegistryScreenState copyWith({
    List<RegistryItemWithStatus>? items,
    bool? isLoading,
    String? error,
    RegistryFilter? currentFilter,
    RegistrySort? currentSort,
    String? selectedBabyProfileId,
  }) {
    return RegistryScreenState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      selectedBabyProfileId: selectedBabyProfileId ?? this.selectedBabyProfileId,
    );
  }

  /// Get filtered items
  List<RegistryItemWithStatus> get filteredItems {
    var filtered = items;

    switch (currentFilter) {
      case RegistryFilter.highPriority:
        filtered = items.where((i) => i.item.priority >= 4).toList();
        break;
      case RegistryFilter.purchased:
        filtered = items.where((i) => i.isPurchased).toList();
        break;
      case RegistryFilter.unpurchased:
        filtered = items.where((i) => !i.isPurchased).toList();
        break;
      case RegistryFilter.all:
      default:
        break;
    }

    return filtered;
  }

  /// Get sorted items
  List<RegistryItemWithStatus> get sortedItems {
    final itemsToSort = List<RegistryItemWithStatus>.from(filteredItems);

    switch (currentSort) {
      case RegistrySort.priorityHigh:
        itemsToSort.sort((a, b) => b.item.priority.compareTo(a.item.priority));
        break;
      case RegistrySort.priorityLow:
        itemsToSort.sort((a, b) => a.item.priority.compareTo(b.item.priority));
        break;
      case RegistrySort.nameAsc:
        itemsToSort.sort((a, b) => a.item.name.compareTo(b.item.name));
        break;
      case RegistrySort.nameDesc:
        itemsToSort.sort((a, b) => b.item.name.compareTo(a.item.name));
        break;
      case RegistrySort.dateNewest:
        itemsToSort.sort((a, b) => b.item.createdAt.compareTo(a.item.createdAt));
        break;
      case RegistrySort.dateOldest:
        itemsToSort.sort((a, b) => a.item.createdAt.compareTo(b.item.createdAt));
        break;
    }

    return itemsToSort;
  }
}

/// Registry Screen Provider Notifier
class RegistryScreenNotifier extends StateNotifier<RegistryScreenState> {
  final DatabaseService _databaseService;
  final CacheService _cacheService;
  final RealtimeService _realtimeService;

  String? _itemsSubscriptionId;
  String? _purchasesSubscriptionId;

  RegistryScreenNotifier({
    required DatabaseService databaseService,
    required CacheService cacheService,
    required RealtimeService realtimeService,
  })  : _databaseService = databaseService,
        _cacheService = cacheService,
        _realtimeService = realtimeService,
        super(const RegistryScreenState());

  // Configuration
  static const String _cacheKeyPrefix = 'registry_items';
  static const int _cacheTtlMinutes = 30;

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load registry items for a baby profile
  Future<void> loadItems({
    required String babyProfileId,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
      );

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

      // Fetch items and purchases from database
      final itemsWithStatus = await _fetchItemsWithStatus(babyProfileId);

      // Save to cache
      await _saveToCache(babyProfileId, itemsWithStatus);

      state = state.copyWith(
        items: itemsWithStatus,
        isLoading: false,
      );

      // Setup real-time subscriptions
      await _setupRealtimeSubscriptions(babyProfileId);

      debugPrint('✅ Loaded ${itemsWithStatus.length} registry items');
    } catch (e) {
      final errorMessage = 'Failed to load registry items: $e';
      debugPrint('❌ $errorMessage');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Apply filter
  void applyFilter(RegistryFilter filter) {
    state = state.copyWith(currentFilter: filter);
    debugPrint('✅ Applied filter: $filter');
  }

  /// Apply sort
  void applySort(RegistrySort sort) {
    state = state.copyWith(currentSort: sort);
    debugPrint('✅ Applied sort: $sort');
  }

  /// Refresh registry
  Future<void> refresh() async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile');
      return;
    }

    await loadItems(
      babyProfileId: state.selectedBabyProfileId!,
      forceRefresh: true,
    );
  }

  // ==========================================
  // Private Methods
  // ==========================================

  /// Fetch registry items with purchase status
  Future<List<RegistryItemWithStatus>> _fetchItemsWithStatus(
    String babyProfileId,
  ) async {
    // Fetch registry items
    final itemsResponse = await _databaseService
        .select(SupabaseTables.registryItems)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isNull(SupabaseTables.deletedAt)
        .order(SupabaseTables.priority, ascending: false);

    final items = (itemsResponse as List)
        .map((json) => RegistryItem.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch purchases
    final purchasesResponse = await _databaseService
        .select(SupabaseTables.registryPurchases)
        .order(SupabaseTables.createdAt, ascending: false);

    final purchases = (purchasesResponse as List)
        .map((json) => RegistryPurchase.fromJson(json as Map<String, dynamic>))
        .toList();

    // Create items with purchase status
    final itemsWithStatus = items.map((item) {
      final itemPurchases = purchases.where((p) => p.registryItemId == item.id).toList();
      return RegistryItemWithStatus(
        item: item,
        isPurchased: itemPurchases.isNotEmpty,
        purchaseCount: itemPurchases.length,
      );
    }).toList();

    return itemsWithStatus;
  }

  /// Load items from cache
  Future<List<RegistryItemWithStatus>?> _loadFromCache(
    String babyProfileId,
  ) async {
    if (!_cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await _cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List).map((json) {
        final itemJson = json['item'] as Map<String, dynamic>;
        return RegistryItemWithStatus(
          item: RegistryItem.fromJson(itemJson),
          isPurchased: json['isPurchased'] as bool,
          purchaseCount: json['purchaseCount'] as int,
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
    if (!_cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = items.map((itemWithStatus) => {
        'item': itemWithStatus.item.toJson(),
        'isPurchased': itemWithStatus.isPurchased,
        'purchaseCount': itemWithStatus.purchaseCount,
      }).toList();
      await _cacheService.put(cacheKey, jsonData, ttlMinutes: _cacheTtlMinutes);
    } catch (e) {
      debugPrint('⚠️  Failed to save to cache: $e');
    }
  }

  /// Get cache key
  String _getCacheKey(String babyProfileId) {
    return '${_cacheKeyPrefix}_$babyProfileId';
  }

  /// Setup real-time subscriptions
  Future<void> _setupRealtimeSubscriptions(String babyProfileId) async {
    try {
      _cancelRealtimeSubscriptions();

      // Subscribe to registry items changes
      _itemsSubscriptionId = await _realtimeService.subscribe(
        table: SupabaseTables.registryItems,
        filter: '${SupabaseTables.babyProfileId}=eq.$babyProfileId',
        callback: (payload) {
          _handleItemsUpdate(payload, babyProfileId);
        },
      );

      // Subscribe to purchases changes
      _purchasesSubscriptionId = await _realtimeService.subscribe(
        table: SupabaseTables.registryPurchases,
        callback: (payload) {
          _handlePurchasesUpdate(payload, babyProfileId);
        },
      );

      debugPrint('✅ Real-time subscriptions setup for registry');
    } catch (e) {
      debugPrint('⚠️  Failed to setup real-time subscriptions: $e');
    }
  }

  /// Handle items update
  void _handleItemsUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    try {
      // Refresh items when registry items change
      refresh();
      debugPrint('✅ Real-time registry items update processed');
    } catch (e) {
      debugPrint('❌ Failed to handle items update: $e');
    }
  }

  /// Handle purchases update
  void _handlePurchasesUpdate(
    Map<String, dynamic> payload,
    String babyProfileId,
  ) {
    try {
      // Refresh items when purchases change
      refresh();
      debugPrint('✅ Real-time purchases update processed');
    } catch (e) {
      debugPrint('❌ Failed to handle purchases update: $e');
    }
  }

  /// Cancel real-time subscriptions
  void _cancelRealtimeSubscriptions() {
    if (_itemsSubscriptionId != null) {
      _realtimeService.unsubscribe(_itemsSubscriptionId!);
      _itemsSubscriptionId = null;
    }
    if (_purchasesSubscriptionId != null) {
      _realtimeService.unsubscribe(_purchasesSubscriptionId!);
      _purchasesSubscriptionId = null;
    }
    debugPrint('✅ Real-time subscriptions cancelled');
  }

  // ==========================================
  // Cleanup
  // ==========================================

  @override
  void dispose() {
    _cancelRealtimeSubscriptions();
    super.dispose();
  }
}

/// Registry screen provider
///
/// Usage:
/// ```dart
/// final registryState = ref.watch(registryScreenProvider);
/// final notifier = ref.read(registryScreenProvider.notifier);
/// await notifier.loadItems(babyProfileId: 'abc');
/// ```
final registryScreenProvider = StateNotifierProvider.autoDispose<
    RegistryScreenNotifier, RegistryScreenState>(
  (ref) {
    final databaseService = ref.watch(databaseServiceProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final realtimeService = ref.watch(realtimeServiceProvider);

    final notifier = RegistryScreenNotifier(
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
