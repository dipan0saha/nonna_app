import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/performance_limits.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/registry_item.dart';
import '../../../../core/models/registry_purchase.dart';
import '../../../../core/models/user.dart';
import '../../../../core/enums/user_role.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/tile_config.dart';
import '../../../../core/utils/tile_loader.dart';

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
  dateNewest,
  dateOldest,
}

/// Registry item with purchase status
class RegistryItemWithStatus {
  final RegistryItem item;
  final bool isPurchased;
  final int purchaseCount;
  final List<User> purchasers;
  final bool isPurchasedByCurrentUser;

  const RegistryItemWithStatus({
    required this.item,
    required this.isPurchased,
    this.purchaseCount = 0,
    this.purchasers = const [],
    this.isPurchasedByCurrentUser = false,
  });
}

/// Registry screen state model
class RegistryScreenState {
  final List<TileConfig> tiles;
  final List<RegistryItemWithStatus> items;
  final bool isLoading;
  final String? error;
  final RegistryFilter currentFilter;
  final RegistrySort currentSort;
  final String? selectedBabyProfileId;

  const RegistryScreenState({
    this.tiles = const [],
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.currentFilter = RegistryFilter.all,
    this.currentSort = RegistrySort.priorityHigh,
    this.selectedBabyProfileId,
  });

  RegistryScreenState copyWith({
    List<TileConfig>? tiles,
    List<RegistryItemWithStatus>? items,
    bool? isLoading,
    String? error,
    RegistryFilter? currentFilter,
    RegistrySort? currentSort,
    String? selectedBabyProfileId,
  }) {
    return RegistryScreenState(
      tiles: tiles ?? this.tiles,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      selectedBabyProfileId:
          selectedBabyProfileId ?? this.selectedBabyProfileId,
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
        break;
    }

    return filtered;
  }

  /// Get sorted items
  List<RegistryItemWithStatus> get sortedItems {
    final itemsToSort = List<RegistryItemWithStatus>.from(filteredItems);

    switch (currentSort) {
      case RegistrySort.priorityHigh:
        itemsToSort.sort((a, b) {
          final byPriority = b.item.priority.compareTo(a.item.priority);
          if (byPriority != 0) return byPriority;
          return b.item.createdAt.compareTo(a.item.createdAt);
        });
        break;
      case RegistrySort.priorityLow:
        itemsToSort.sort((a, b) {
          final byPriority = a.item.priority.compareTo(b.item.priority);
          if (byPriority != 0) return byPriority;
          return b.item.createdAt.compareTo(a.item.createdAt);
        });
        break;
      case RegistrySort.dateNewest:
        itemsToSort
            .sort((a, b) => b.item.createdAt.compareTo(a.item.createdAt));
        break;
      case RegistrySort.dateOldest:
        itemsToSort
            .sort((a, b) => a.item.createdAt.compareTo(b.item.createdAt));
        break;
    }

    final unpurchased = itemsToSort.where((item) => !item.isPurchased).toList();
    final purchased = itemsToSort.where((item) => item.isPurchased).toList();
    return [...unpurchased, ...purchased];
  }
}

/// Registry Screen Provider Notifier
class RegistryScreenNotifier extends Notifier<RegistryScreenState> {
  String? _itemsSubscriptionId;
  late final _realtimeService = ref.read(realtimeServiceProvider);
  String? _purchasesSubscriptionId;

  @override
  RegistryScreenState build() {
    ref.onDispose(() {
      _cancelRealtimeSubscriptions();
    });
    return const RegistryScreenState();
  }

  // Configuration
  static const String _cacheKeyPrefix = 'registry_items';

  // ==========================================
  // Public Methods
  // ==========================================

  /// Load registry items for a baby profile
  Future<void> loadItems({
    required String babyProfileId,
    UserRole role = UserRole.follower,
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedBabyProfileId: babyProfileId,
      );

      // We load tile configs first asynchronously so they populate fast
      TileLoader.loadForScreen(
        ref: ref,
        screenId: 'registry',
        role: role,
        forceRefresh: false,
      ).then((tiles) {
        if (!ref.mounted) return;
        state = state.copyWith(
          tiles: _customizeRegistryTiles(tiles),
        );
      });

      // Try to load from cache first
      if (!forceRefresh) {
        final cachedItems = await _loadFromCache(babyProfileId);
        if (!ref.mounted) return;
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
      if (!ref.mounted) return;

      // Save to cache
      await _saveToCache(babyProfileId, itemsWithStatus);
      if (!ref.mounted) return;

      state = state.copyWith(
        items: itemsWithStatus,
        isLoading: false,
      );

      // Setup real-time subscriptions
      await _setupRealtimeSubscriptions(babyProfileId);
      if (!ref.mounted) return;

      debugPrint('✅ Loaded ${itemsWithStatus.length} registry items');
    } catch (e) {
      if (!ref.mounted) return;
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

  /// Toggle purchase status
  Future<void> togglePurchase(RegistryItemWithStatus itemWithStatus) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('⚠️  User not logged in, cannot toggle purchase');
      return;
    }

    final databaseService = ref.read(databaseServiceProvider);

    try {
      if (itemWithStatus.isPurchasedByCurrentUser) {
        // Remove only the current user's purchase record
        await databaseService.delete(SupabaseTables.registryPurchases).match({
          'registry_item_id': itemWithStatus.item.id,
          'purchased_by_user_id': user.id,
        });
      } else {
        // Create a purchase only if one does not already exist for this user
        final existing = await databaseService
            .select(SupabaseTables.registryPurchases, columns: 'id')
            .eq('registry_item_id', itemWithStatus.item.id)
            .eq('purchased_by_user_id', user.id)
            .maybeSingle();

        if (existing != null) {
          await refresh();
          return;
        }

        final purchase = RegistryPurchase(
          id: const Uuid().v4(),
          registryItemId: itemWithStatus.item.id,
          purchasedByUserId: user.id,
          purchasedAt: DateTime.now(),
        );

        await databaseService.insert(
          SupabaseTables.registryPurchases,
          purchase.toJson(),
        );
      }

      await refresh();
    } catch (e) {
      debugPrint('❌ Failed to toggle purchase: $e');
    }
  }

  List<TileConfig> _customizeRegistryTiles(List<TileConfig> tiles) {
    final withoutHighlights = tiles
        .where((tile) => tile.componentName != 'RegistryHighlightsTile')
        .map((tile) {
      if (tile.componentName == 'RecentPurchasesTile') {
        return tile.copyWith(
          params: {
            ...?tile.params,
            'maxItems': 3,
          },
        );
      }
      return tile;
    }).toList();

    int rank(TileConfig tile) {
      switch (tile.componentName) {
        case 'RecentPurchasesTile':
          return 0;
        case 'RegistryListTile':
          return 1;
        default:
          return 2;
      }
    }

    withoutHighlights.sort((a, b) {
      final rankCompare = rank(a).compareTo(rank(b));
      if (rankCompare != 0) return rankCompare;
      return a.displayOrder.compareTo(b.displayOrder);
    });

    return withoutHighlights;
  }

  /// Refresh registry
  Future<void> refresh({UserRole role = UserRole.follower}) async {
    if (state.selectedBabyProfileId == null) {
      debugPrint('⚠️  Cannot refresh: missing baby profile');
      return;
    }

    await loadItems(
      babyProfileId: state.selectedBabyProfileId!,
      role: role,
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
    final databaseService = ref.read(databaseServiceProvider);
    final currentUser = ref.read(currentUserProvider);

    // Fetch registry items
    final itemsResponse = await databaseService
        .select(SupabaseTables.registryItems)
        .eq(SupabaseTables.babyProfileId, babyProfileId)
        .isFilter(SupabaseTables.deletedAt, null)
        .order('priority', ascending: false);

    final items = (itemsResponse as List)
        .map((json) => RegistryItem.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch purchases
    final purchasesResponse = await databaseService
        .select(SupabaseTables.registryPurchases)
        .order('purchased_at', ascending: false);

    final purchases = (purchasesResponse as List)
        .map((json) => RegistryPurchase.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch profiles for users who purchased items
    final purchasedUserIds =
        purchases.map((p) => p.purchasedByUserId).toSet().toList();
    final List<User> purchaserProfiles = [];

    if (purchasedUserIds.isNotEmpty) {
      try {
        final profilesResponse = await databaseService
            .select(SupabaseTables.userProfiles)
            .inFilter('user_id', purchasedUserIds);

        purchaserProfiles.addAll((profilesResponse as List)
            .map((json) => User.fromJson(json as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('⚠️ Failed to fetch purchaser profiles: $e');
      }
    }

    // Create items with purchase status
    final itemsWithStatus = items.map((item) {
      final itemPurchases =
          purchases.where((p) => p.registryItemId == item.id).toList();

      final purchasers = itemPurchases
          .map((purchase) {
            return purchaserProfiles.cast<User?>().firstWhere(
                  (profile) => profile?.userId == purchase.purchasedByUserId,
                  orElse: () => null,
                );
          })
          .whereType<User>()
          .toList();

      final isPurchasedByCurrentUser = currentUser != null &&
          itemPurchases.any((p) => p.purchasedByUserId == currentUser.id);

      return RegistryItemWithStatus(
        item: item,
        isPurchased: itemPurchases.isNotEmpty,
        purchaseCount: itemPurchases.length,
        purchasers: purchasers,
        isPurchasedByCurrentUser: isPurchasedByCurrentUser,
      );
    }).toList();

    return itemsWithStatus;
  }

  /// Load items from cache
  Future<List<RegistryItemWithStatus>?> _loadFromCache(
    String babyProfileId,
  ) async {
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return null;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final cachedData = await cacheService.get(cacheKey);

      if (cachedData == null) return null;

      return (cachedData as List).map((dynamic json) {
        final map = Map<String, dynamic>.from(json as Map);
        final itemJson = Map<String, dynamic>.from(map['item'] as Map);
        final purchasersJson = map['purchasers'] as List?;

        return RegistryItemWithStatus(
          item: RegistryItem.fromJson(itemJson),
          isPurchased: map['isPurchased'] as bool,
          purchaseCount: map['purchaseCount'] as int,
          purchasers: purchasersJson != null
              ? purchasersJson
                  .map(
                      (u) => User.fromJson(Map<String, dynamic>.from(u as Map)))
                  .toList()
              : const [],
          isPurchasedByCurrentUser:
              map['isPurchasedByCurrentUser'] as bool? ?? false,
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
    final cacheService = ref.read(cacheServiceProvider);
    if (!cacheService.isInitialized) return;

    try {
      final cacheKey = _getCacheKey(babyProfileId);
      final jsonData = items
          .map((itemWithStatus) => {
                'item': itemWithStatus.item.toJson(),
                'isPurchased': itemWithStatus.isPurchased,
                'purchaseCount': itemWithStatus.purchaseCount,
                'purchasers':
                    itemWithStatus.purchasers.map((u) => u.toJson()).toList(),
                'isPurchasedByCurrentUser':
                    itemWithStatus.isPurchasedByCurrentUser,
              })
          .toList();
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

  /// Setup real-time subscriptions
  Future<void> _setupRealtimeSubscriptions(String babyProfileId) async {
    try {
      _cancelRealtimeSubscriptions();

      final realtimeService = _realtimeService;

      // Subscribe to registry items changes
      final itemsChannelName = 'registry-items-channel-$babyProfileId';
      final itemsStream = realtimeService.subscribe(
        table: SupabaseTables.registryItems,
        channelName: itemsChannelName,
        filter: {
          'column': SupabaseTables.babyProfileId,
          'value': babyProfileId,
        },
      );

      _itemsSubscriptionId = itemsChannelName;

      itemsStream.listen((payload) {
        _handleItemsUpdate(payload, babyProfileId);
      });

      // Subscribe to purchases changes
      final purchasesChannelName = 'registry-purchases-channel-$babyProfileId';
      final purchasesStream = realtimeService.subscribe(
        table: SupabaseTables.registryPurchases,
        channelName: purchasesChannelName,
      );

      _purchasesSubscriptionId = purchasesChannelName;

      purchasesStream.listen((payload) {
        _handlePurchasesUpdate(payload, babyProfileId);
      });

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
    debugPrint('✅ Real-time subscriptions marked for cancellation');
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
final registryScreenProvider =
    NotifierProvider.autoDispose<RegistryScreenNotifier, RegistryScreenState>(
  RegistryScreenNotifier.new,
);
