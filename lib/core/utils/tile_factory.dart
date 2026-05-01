import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/di/providers.dart';

// Tiles and Providers
import 'package:nonna_app/tiles/recent_photos/providers/recent_photos_provider.dart';
import 'package:nonna_app/tiles/recent_photos/widgets/recent_photos_tile.dart';

import 'package:nonna_app/tiles/checklist/widgets/checklist_tile.dart';
import 'package:nonna_app/tiles/checklist/providers/checklist_provider.dart';
import 'package:nonna_app/tiles/invites_status/providers/invites_status_provider.dart';
import 'package:nonna_app/tiles/new_followers/providers/new_followers_provider.dart';
import 'package:nonna_app/tiles/recent_purchases/providers/recent_purchases_provider.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';
import 'package:nonna_app/tiles/system_announcements/providers/system_announcements_provider.dart';

import 'package:nonna_app/tiles/countdown/providers/countdown_provider.dart';
import 'package:nonna_app/tiles/countdown/widgets/countdown_tile.dart';
import 'package:nonna_app/tiles/activity_list/providers/activity_list_provider.dart';
import 'package:nonna_app/tiles/activity_list/widgets/activity_list_tile.dart';
import 'package:nonna_app/tiles/gallery_favorites/widgets/gallery_favorites_tile.dart';
import 'package:nonna_app/tiles/gallery_favorites/providers/gallery_favorites_provider.dart';
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
import 'package:nonna_app/tiles/registry_list/widgets/registry_list_tile.dart';
import 'package:nonna_app/tiles/system_announcements/widgets/system_announcements_tile.dart';
import 'package:nonna_app/tiles/upcoming_events/widgets/upcoming_events_tile.dart';
import 'package:nonna_app/tiles/upcoming_events/providers/upcoming_events_provider.dart';
import 'package:nonna_app/tiles/rsvp_tasks/providers/rsvp_tasks_provider.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:nonna_app/tiles/name_suggestions/widgets/name_suggestions_tile.dart';
import 'package:nonna_app/tiles/prediction_votes/widgets/prediction_votes_tile.dart';

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
        return const _UpcomingEventsSmartTile();
      case 'RegistryHighlightsTile':
        return const _RegistryHighlightsSmartTile();
      case 'RegistryListTile':
        return const RegistryListSmartTile();
      case 'CountdownTile':
        return const _CountdownSmartTile();
      case 'ChecklistTile':
        return const _ChecklistSmartTile();
      case 'ActivityListTile':
        return const _ActivityListSmartTile();
      case 'GalleryFavoritesTile':
        return const _GalleryFavoritesSmartTile();
      case 'InvitesStatusTile':
        return const _InvitesStatusSmartTile();
      case 'NewFollowersTile':
        return const _NewFollowersSmartTile();
      case 'NotificationsTile':
        return const _NotificationsSmartTile();
      case 'RecentPurchasesTile':
        return const _RecentPurchasesSmartTile();
      case 'RegistryDealsTile':
        return const _RegistryDealsSmartTile();
      case 'RsvpTasksTile':
        return const _RsvpTasksSmartTile();
      case 'StorageUsageTile':
        return const _StorageUsageSmartTile();
      case 'SystemAnnouncementsTile':
        return const _SystemAnnouncementsSmartTile();
      case 'NameSuggestionsTile':
        return const NameSuggestionsSmartTile();
      case 'PredictionVotesTile':
        return const PredictionVotesSmartTile();
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
      onPhotoTap: (photo) =>
          context.push('/gallery/photo/detail', extra: photo),
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

class _RegistryDealsSmartTileState
    extends ConsumerState<_RegistryDealsSmartTile> {
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

class _GalleryFavoritesSmartTile extends ConsumerStatefulWidget {
  const _GalleryFavoritesSmartTile();

  @override
  ConsumerState<_GalleryFavoritesSmartTile> createState() =>
      _GalleryFavoritesSmartTileState();
}

class _GalleryFavoritesSmartTileState
    extends ConsumerState<_GalleryFavoritesSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(galleryFavoritesProvider.notifier)
            .fetchFavorites(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryFavoritesProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    // Watch for baby profile changes and re-fetch if needed
    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(galleryFavoritesProvider.notifier)
            .fetchFavorites(babyProfileId: current);
      }
    });

    return GalleryFavoritesTile(
      favorites: state.favorites,
      isLoading: state.isLoading && state.favorites.isEmpty,
      error: state.error,
      onPhotoTap: (photo) =>
          context.push('/gallery/photo/detail', extra: photo),
      onRefresh: babyProfileId != null
          ? () => ref
              .read(galleryFavoritesProvider.notifier)
              .refresh(babyProfileId: babyProfileId)
          : null,
      onViewAll: () {},
    );
  }
}

class _UpcomingEventsSmartTile extends ConsumerStatefulWidget {
  const _UpcomingEventsSmartTile();

  @override
  ConsumerState<_UpcomingEventsSmartTile> createState() =>
      _UpcomingEventsSmartTileState();
}

class _UpcomingEventsSmartTileState
    extends ConsumerState<_UpcomingEventsSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      final role =
          ref.read(homeScreenProvider).selectedRole ?? UserRole.follower;
      if (babyProfileId != null) {
        ref
            .read(upcomingEventsProvider.notifier)
            .fetchEvents(babyProfileId: babyProfileId, role: role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingEventsProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);
    final role =
        ref.watch(homeScreenProvider).selectedRole ?? UserRole.follower;

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(upcomingEventsProvider.notifier)
            .fetchEvents(babyProfileId: current, role: role);
      }
    });

    return UpcomingEventsTile(
      events: state.events.map((e) => EventWithRsvp(event: e)).toList(),
      isLoading: state.isLoading && state.events.isEmpty,
      error: state.error,
      onEventTap: (event) {
        context.push('/calendar/event/detail', extra: event);
      },
      onRefresh: () {
        if (babyProfileId != null) {
          ref
              .read(upcomingEventsProvider.notifier)
              .refresh(babyProfileId: babyProfileId, role: role);
        }
      },
      onViewAll: () {
        // Navigate to full calendar if needed or let the main tab handle it
      },
    );
  }
}

class _RsvpTasksSmartTile extends ConsumerStatefulWidget {
  const _RsvpTasksSmartTile();

  @override
  ConsumerState<_RsvpTasksSmartTile> createState() =>
      _RsvpTasksSmartTileState();
}

class _RsvpTasksSmartTileState extends ConsumerState<_RsvpTasksSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      final userId = ref.read(authProvider).user?.id ?? '';
      if (babyProfileId != null && userId.isNotEmpty) {
        ref
            .read(rsvpTasksProvider.notifier)
            .fetchRSVPTasks(babyProfileId: babyProfileId, userId: userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rsvpTasksProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);
    final userId = ref.watch(authProvider).user?.id ?? '';

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous && userId.isNotEmpty) {
        ref
            .read(rsvpTasksProvider.notifier)
            .fetchRSVPTasks(babyProfileId: current, userId: userId);
      }
    });

    return RsvpTasksTile(
      events: state.events,
      isLoading: state.isLoading && state.events.isEmpty,
      error: state.error,
      onEventTap: (eventWithRsvp) {
        // TODO: Navigate to event details
      },
      onRefresh: () {
        if (babyProfileId != null && userId.isNotEmpty) {
          ref
              .read(rsvpTasksProvider.notifier)
              .refresh(babyProfileId: babyProfileId, userId: userId);
        }
      },
    );
  }
}

class _ChecklistSmartTile extends ConsumerStatefulWidget {
  const _ChecklistSmartTile();

  @override
  ConsumerState<_ChecklistSmartTile> createState() =>
      _ChecklistSmartTileState();
}

class _ChecklistSmartTileState extends ConsumerState<_ChecklistSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(checklistProvider.notifier)
            .loadChecklist(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checklistProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(checklistProvider.notifier)
            .loadChecklist(babyProfileId: current);
      }
    });

    return ChecklistTile(
      items: state.items,
      isLoading: state.isLoading && state.items.isEmpty,
      error: state.error,
      onItemToggle: (item) {
        if (babyProfileId != null) {
          ref.read(checklistProvider.notifier).toggleItem(
                itemId: item.id,
                babyProfileId: babyProfileId,
              );
        }
      },
      onRefresh: babyProfileId != null
          ? () => ref
              .read(checklistProvider.notifier)
              .loadChecklist(babyProfileId: babyProfileId)
          : null,
    );
  }
}

class _InvitesStatusSmartTile extends ConsumerStatefulWidget {
  const _InvitesStatusSmartTile();

  @override
  ConsumerState<_InvitesStatusSmartTile> createState() =>
      _InvitesStatusSmartTileState();
}

class _InvitesStatusSmartTileState
    extends ConsumerState<_InvitesStatusSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(invitesStatusProvider.notifier)
            .fetchInvitations(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invitesStatusProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(invitesStatusProvider.notifier)
            .fetchInvitations(babyProfileId: current);
      }
    });

    return InvitesStatusTile(
      invitations: state.invitations,
      isLoading: state.isLoading && state.invitations.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref.read(invitesStatusProvider.notifier).fetchInvitations(
              babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}

class _NewFollowersSmartTile extends ConsumerStatefulWidget {
  const _NewFollowersSmartTile();

  @override
  ConsumerState<_NewFollowersSmartTile> createState() =>
      _NewFollowersSmartTileState();
}

class _NewFollowersSmartTileState
    extends ConsumerState<_NewFollowersSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newFollowersProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(newFollowersProvider.notifier)
            .fetchFollowers(babyProfileId: current);
      }
    });

    return NewFollowersTile(
      followers: state.followers,
      isLoading: state.isLoading && state.followers.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(newFollowersProvider.notifier)
              .fetchFollowers(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
      onViewAll: () {},
    );
  }
}

class _RecentPurchasesSmartTile extends ConsumerStatefulWidget {
  const _RecentPurchasesSmartTile();

  @override
  ConsumerState<_RecentPurchasesSmartTile> createState() =>
      _RecentPurchasesSmartTileState();
}

class _RecentPurchasesSmartTileState
    extends ConsumerState<_RecentPurchasesSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(recentPurchasesProvider.notifier)
            .fetchPurchases(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentPurchasesProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(recentPurchasesProvider.notifier)
            .fetchPurchases(babyProfileId: current);
      }
    });

    return RecentPurchasesTile(
      purchases: state.purchases,
      isLoading: state.isLoading && state.purchases.isEmpty,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(recentPurchasesProvider.notifier)
              .fetchPurchases(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}

class _StorageUsageSmartTile extends ConsumerStatefulWidget {
  const _StorageUsageSmartTile();

  @override
  ConsumerState<_StorageUsageSmartTile> createState() =>
      _StorageUsageSmartTileState();
}

class _StorageUsageSmartTileState
    extends ConsumerState<_StorageUsageSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProfileId = ref.read(selectedBabyProfileProvider);
      if (babyProfileId != null) {
        ref
            .read(storageUsageProvider.notifier)
            .fetchUsage(babyProfileId: babyProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storageUsageProvider);
    final babyProfileId = ref.watch(selectedBabyProfileProvider);

    ref.listen(selectedBabyProfileProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(storageUsageProvider.notifier)
            .fetchUsage(babyProfileId: current);
      }
    });

    return StorageUsageTile(
      info: state.info,
      isLoading: state.isLoading && state.info == null,
      error: state.error,
      onRefresh: babyProfileId != null
          ? () => ref
              .read(storageUsageProvider.notifier)
              .fetchUsage(babyProfileId: babyProfileId, forceRefresh: true)
          : null,
    );
  }
}

class _SystemAnnouncementsSmartTile extends ConsumerStatefulWidget {
  const _SystemAnnouncementsSmartTile();

  @override
  ConsumerState<_SystemAnnouncementsSmartTile> createState() =>
      _SystemAnnouncementsSmartTileState();
}

class _SystemAnnouncementsSmartTileState
    extends ConsumerState<_SystemAnnouncementsSmartTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(systemAnnouncementsProvider);
    final user = ref.watch(currentUserProvider);

    ref.listen(currentUserProvider, (previous, current) {
      if (current != null && current != previous) {
        ref
            .read(systemAnnouncementsProvider.notifier)
            .loadAnnouncements(userId: current.id);
      }
    });

    return SystemAnnouncementsTile(
      announcements: state.announcements,
      dismissedIds: state.dismissedIds,
      isLoading: state.isLoading && state.announcements.isEmpty,
      error: state.error,
      onDismiss: (id) {
        if (user != null) {
          ref.read(systemAnnouncementsProvider.notifier).dismissAnnouncement(
                announcementId: id,
                userId: user.id,
              );
        }
      },
      onRefresh: user != null
          ? () => ref
              .read(systemAnnouncementsProvider.notifier)
              .loadAnnouncements(userId: user.id)
          : null,
    );
  }
}
