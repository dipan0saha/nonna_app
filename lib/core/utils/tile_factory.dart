import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/di/providers.dart';

// Tiles and Providers
import 'package:nonna_app/tiles/recent_photos/providers/recent_photos_provider.dart';
import 'package:nonna_app/tiles/recent_photos/widgets/recent_photos_tile.dart';

import 'package:nonna_app/tiles/checklist/widgets/checklist_tile.dart';
import 'package:nonna_app/tiles/countdown/providers/countdown_provider.dart';
import 'package:nonna_app/tiles/countdown/widgets/countdown_tile.dart';
import 'package:nonna_app/tiles/activity_list/providers/activity_list_provider.dart';
import 'package:nonna_app/tiles/activity_list/widgets/activity_list_tile.dart';
import 'package:nonna_app/tiles/gallery_favorites/widgets/gallery_favorites_tile.dart';
import 'package:nonna_app/tiles/invites_status/widgets/invites_status_tile.dart';
import 'package:nonna_app/tiles/new_followers/widgets/new_followers_tile.dart';
import 'package:nonna_app/tiles/notifications/providers/notifications_provider.dart';
import 'package:nonna_app/tiles/notifications/widgets/notifications_tile.dart';
import 'package:nonna_app/tiles/recent_purchases/widgets/recent_purchases_tile.dart';
import 'package:nonna_app/tiles/registry_deals/widgets/registry_deals_tile.dart';
import 'package:nonna_app/tiles/registry_deals/providers/registry_deals_provider.dart';

import 'package:nonna_app/tiles/registry_highlights/widgets/registry_highlights_tile.dart';
import 'package:nonna_app/tiles/registry_highlights/providers/registry_highlights_provider.dart';

import 'package:nonna_app/tiles/rsvp_tasks/widgets/rsvp_tasks_tile.dart';
import 'package:nonna_app/tiles/storage_usage/widgets/storage_usage_tile.dart';
import 'package:nonna_app/tiles/system_announcements/widgets/system_announcements_tile.dart';
import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart';

/// Factory for instantiating dynamic tiles based on their configuration.
class TileFactory {
  /// Builds the appropriate smart tile widget for a given configuration.
  static Widget buildTile(BuildContext context, TileConfig config) {
    if (config.componentName == null) {
      return _buildFallback(config);
    }

    switch (config.componentName) {
      case 'RecentPhotosTile':
        return const _RecentPhotosSmartTile();
      case 'UpcomingEventsTile':
        // TODO: Implement _UpcomingEventsSmartTile wrapper
        return const UpcomingEventsTile(events: [], isLoading: false);
      case 'RegistryHighlightsTile':
        return const _RegistryHighlightsSmartTile();
      case 'CountdownTile':
        return const _CountdownSmartTile();
      case 'ChecklistTile':
        // TODO: Implement _ChecklistSmartTile wrapper
        return const ChecklistTile(items: [], isLoading: false);
      case 'ActivityListTile':
        return const _ActivityListSmartTile();
      case 'GalleryFavoritesTile':
        // TODO: Implement _GalleryFavoritesSmartTile wrapper
        return const GalleryFavoritesTile(favorites: [], isLoading: false);
      case 'InvitesStatusTile':
        // TODO: Implement _InvitesStatusSmartTile wrapper
        return const InvitesStatusTile(invitations: [], isLoading: false);
      case 'NewFollowersTile':
        // TODO: Implement _NewFollowersSmartTile wrapper
        return const NewFollowersTile(followers: [], isLoading: false);
      case 'NotificationsTile':
        return const _NotificationsSmartTile();
      case 'RecentPurchasesTile':
        // TODO: Implement _RecentPurchasesSmartTile wrapper
        return const RecentPurchasesTile(purchases: [], isLoading: false);
      case 'RegistryDealsTile':
        return const _RegistryDealsSmartTile();
      case 'RsvpTasksTile':
        // TODO: Implement _RsvpTasksSmartTile wrapper
        return const RsvpTasksTile(events: [], isLoading: false);
      case 'StorageUsageTile':
        // TODO: Implement _StorageUsageSmartTile wrapper
        return const StorageUsageTile(info: null, isLoading: false);
      case 'SystemAnnouncementsTile':
        // TODO: Implement _SystemAnnouncementsSmartTile wrapper
        return const SystemAnnouncementsTile(
            announcements: [], isLoading: false);
      default:
        return _buildFallback(config);
    }
  }

  static Widget _buildFallback(TileConfig config) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.extension, size: 32, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.componentName ?? config.tileDefinitionId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Coming soon...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Smart Tile Wrappers
// -----------------------------------------------------------------------------

class _RecentPhotosSmartTile extends ConsumerStatefulWidget {
  const _RecentPhotosSmartTile();

  @override
  ConsumerState<_RecentPhotosSmartTile> createState() =>
      _RecentPhotosSmartTileState();
}

class _RecentPhotosSmartTileState
    extends ConsumerState<_RecentPhotosSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(recentPhotosProvider.notifier)
            .fetchPhotos(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentPhotosProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    // Watch for baby profile changes and re-fetch if needed
    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(recentPhotosProvider.notifier)
            .fetchPhotos(babyProfileId: current);
      }
    });

    return RecentPhotosTile(
      photos: state.photos
          .map((p) =>
              PhotoWithSquishCount(photo: p, squishCount: 0, isSquished: false))
          .toList(),
      isLoading: state.isLoading && state.photos.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(recentPhotosProvider.notifier)
              .refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );
  }
}

class _NotificationsSmartTile extends ConsumerStatefulWidget {
  const _NotificationsSmartTile();

  @override
  ConsumerState<_NotificationsSmartTile> createState() =>
      _NotificationsSmartTileState();
}

class _NotificationsSmartTileState
    extends ConsumerState<_NotificationsSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref
            .read(notificationsProvider.notifier)
            .fetchNotifications(userId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider);

    ref.listen(currentUserProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(notificationsProvider.notifier)
            .fetchNotifications(userId: current.id);
      }
    });

    return NotificationsTile(
      notifications: state.notifications,
      unreadCount: state.unreadCount,
      isLoading: state.isLoading && state.notifications.isEmpty,
      error: state.error,
      onRefresh: user != null
          ? () => ref
              .read(notificationsProvider.notifier)
              .fetchNotifications(userId: user.id, forceRefresh: true)
          : null,
    );
  }
}

class _CountdownSmartTile extends ConsumerStatefulWidget {
  const _CountdownSmartTile();

  @override
  ConsumerState<_CountdownSmartTile> createState() =>
      _CountdownSmartTileState();
}

class _CountdownSmartTileState extends ConsumerState<_CountdownSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(countdownProvider.notifier)
            .fetchCountdowns(babyProfileIds: [babyProfileId]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countdownProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(countdownProvider.notifier)
            .fetchCountdowns(babyProfileIds: [current]);
      }
    });

    return CountdownTile(
      countdowns: state.countdowns,
      isLoading: state.isLoading && state.countdowns.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref.read(countdownProvider.notifier).fetchCountdowns(
              babyProfileIds: [babyProfileId], forceRefresh: true)
          : null,
    );
  }
}

class _ActivityListSmartTile extends ConsumerStatefulWidget {
  const _ActivityListSmartTile();

  @override
  ConsumerState<_ActivityListSmartTile> createState() =>
      _ActivityListSmartTileState();
}

class _ActivityListSmartTileState
    extends ConsumerState<_ActivityListSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(activityListProvider.notifier)
            .fetchEngagement(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityListProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(activityListProvider.notifier)
            .fetchEngagement(babyProfileId: current);
      }
    });

    return ActivityListTile(
      metrics: state.metrics,
      isLoading: state.isLoading && state.metrics == null,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(activityListProvider.notifier)
              .fetchEngagement(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}

class _RegistryHighlightsSmartTile extends ConsumerStatefulWidget {
  const _RegistryHighlightsSmartTile();

  @override
  ConsumerState<_RegistryHighlightsSmartTile> createState() =>
      _RegistryHighlightsSmartTileState();
}

class _RegistryHighlightsSmartTileState
    extends ConsumerState<_RegistryHighlightsSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(registryHighlightsProvider.notifier)
            .fetchHighlights(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryHighlightsProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(registryHighlightsProvider.notifier)
            .fetchHighlights(babyProfileId: current);
      }
    });

    return RegistryHighlightsTile(
      items: state.items,
      isLoading: state.isLoading && state.items.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(registryHighlightsProvider.notifier)
              .fetchHighlights(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}

class _RegistryDealsSmartTile extends ConsumerStatefulWidget {
  const _RegistryDealsSmartTile();

  @override
  ConsumerState<_RegistryDealsSmartTile> createState() =>
      _RegistryDealsSmartTileState();
}

class _RegistryDealsSmartTileState extends ConsumerState<_RegistryDealsSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(registryDealsProvider.notifier)
            .fetchDeals(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryDealsProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(registryDealsProvider.notifier)
            .fetchDeals(babyProfileId: current);
      }
    });

    return RegistryDealsTile(
      deals: state.deals,
      isLoading: state.isLoading && state.deals.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(registryDealsProvider.notifier)
              .fetchDeals(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}
