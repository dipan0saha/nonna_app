# Nonna App — Architecture & Codebase Deep Dive

## What Is Nonna?
A **Flutter mobile app** (v1.0.0) for **baby milestone tracking and family sharing**. Private, invite-only platform where parents (owners) share pregnancy/baby updates with family and friends (followers).

## Tech Stack
- **UI**: Flutter + Material 3
- **State Management**: Riverpod v3 (Notifier pattern)
- **Navigation**: GoRouter v17 with auth-guard redirects
- **Backend**: Supabase (Auth, PostgreSQL, Storage, Realtime)
- **Push**: OneSignal
- **Analytics/Crash**: Firebase Analytics, Crashlytics, Performance
- **Caching**: Hive + SharedPreferences
- **Auth**: Supabase Auth, Google Sign-In, Facebook Auth, LocalAuth (biometrics)
- **Localization**: Flutter i18n (ARB) — English + Spanish

## Core Architecture: Dynamic Tile Engine

The defining architectural pattern is the **Tile Engine** — self-contained, reusable tile widgets rendered dynamically from Supabase-driven configuration.

### Data Flow
```
Supabase DB (screens + tile_definitions + tile_configs)
  → TileLoader.loadForScreen() (queries DB, caches in Hive)
    → HomeScreenNotifier.loadTiles() (stores List<TileConfig> in state)
      → TileListView (renders list)
        → TileFactory.buildTile() (switch on componentName → SmartTile widget)
          → _XxxSmartTile (ConsumerStatefulWidget: reads providers, passes data to presentational tile)
```

### Key Components

1. **`screens` table** — Registers screens that host tiles (home, calendar, registry, etc.)
2. **`tile_definitions` table** — Catalog of tile types with `tile_type` string identifiers
3. **`tile_configs` table** — Maps definitions to screens per role, with `display_order`, `is_visible`, `params`
4. **`TileLoader`** (`lib/core/utils/tile_loader.dart`) — Static utility that queries `tile_configs` with inner joins on `screens` and `tile_definitions`, caches results in Hive
5. **`TileFactory`** (`lib/core/utils/tile_factory.dart`) — Static `buildTile()` method with switch statement mapping `componentName` → SmartTile widget wrapper
6. **SmartTile wrappers** — `ConsumerStatefulWidget` classes inside `tile_factory.dart` that wire Riverpod providers to presentational tile widgets

### Directory Structure
```
lib/
├── main.dart                  # Entry point: Supabase/Firebase/OneSignal init → ProviderScope
├── core/
│   ├── config/
│   ├── constants/             # spacing, performance_limits, supabase_tables
│   ├── contracts/
│   ├── di/                    # providers.dart (global Riverpod), service_locator.dart
│   ├── enums/                 # user_role.dart, etc.
│   ├── exceptions/
│   ├── extensions/
│   ├── middleware/
│   ├── mixins/
│   ├── models/                # 23 domain models (tile_config, baby_profile, photo, event, etc.)
│   ├── navigation/
│   ├── network/               # supabase_client.dart
│   ├── providers/
│   ├── repositories/
│   ├── router/                # app_router.dart (GoRouter), route_guards.dart
│   ├── services/              # 22 services (auth, cache, database, realtime, sync, etc.)
│   ├── themes/                # app_theme.dart, colors.dart
│   ├── typedefs/
│   ├── utils/                 # tile_factory.dart, tile_loader.dart
│   └── widgets/               # shared widgets (empty_state, etc.)
├── tiles/                     # 18+1 tile widget directories (first-class citizens, reusable across screens)
│   ├── core/                  # BaseTile, TileContainer shared components
│   ├── activity_list/
│   ├── checklist/
│   ├── countdown/
│   ├── gallery_favorites/
│   ├── invites_status/
│   ├── name_suggestions/
│   ├── new_followers/
│   ├── notifications/
│   ├── prediction_votes/
│   ├── recent_photos/
│   ├── recent_purchases/
│   ├── registry_deals/
│   ├── registry_highlights/
│   ├── registry_list/
│   ├── rsvp_tasks/
│   ├── storage_usage/
│   ├── system_announcements/
│   └── upcoming_events/
├── features/                  # Screen composition
│   ├── auth/
│   ├── baby_profile/
│   ├── calendar/
│   ├── fun/
│   ├── gallery/
│   ├── gamification/
│   ├── home/                  # HomeScreen, HomeAppBar, TileListView, HomeScreenProvider
│   ├── photo_gallery/
│   ├── profile/
│   ├── registry/
│   └── settings/
├── flutter_gen/               # Generated code
└── l10n/                      # Localization
```

## Role System
| Role       | Access |
|------------|--------|
| **Owner**  | Full access, editable tiles, scoped to own baby profile(s) |
| **Follower** | Read-only, aggregated view across all followed babies |

Users can hold both roles (dual-role). The HomeScreen renders a role toggle chip bar. The `tile-configs` Edge Function filters tiles by role (followers restricted from `registry_highlights`, `registry_deals`, `storage_usage`).

## 23 Domain Models (lib/core/models/)
activity_event, baby_membership, baby_profile, event, event_comment, event_rsvp, invitation, name_suggestion, name_suggestion_like, notification, owner_update_marker, photo, photo_comment, photo_squish, photo_tag, registry_item, registry_purchase, screen_config, system_announcement, tile_config, user, user_stats, vote

## 22 Services (lib/core/services/)
analytics, app_initialization, auth, backup, cache, crash_recovery_handler, data_deletion_handler, data_export_handler, database, force_update, local_storage, network_error_handler, notification, observability, offline_cache_manager, persistence_strategies, realtime, realtime_subscription_manager, state_persistence_manager, storage, supabase, sync_manager

## 18 Tile Widgets (lib/tiles/)
Each tile directory contains: `widgets/`, `providers/`, and sometimes `models/`

| Tile | SmartTile in TileFactory |
|------|--------------------------|
| ActivityListTile | ✅ `_ActivityListSmartTile` |
| ChecklistTile | ✅ `_ChecklistSmartTile` |
| CountdownTile | ✅ `_CountdownSmartTile` |
| GalleryFavoritesTile | ✅ `_GalleryFavoritesSmartTile` |
| InvitesStatusTile | ✅ `_InvitesStatusSmartTile` |
| NameSuggestionsTile | ✅ `NameSuggestionsSmartTile` (public) |
| NewFollowersTile | ✅ `_NewFollowersSmartTile` |
| NotificationsTile | ✅ `_NotificationsSmartTile` |
| PredictionVotesTile | ✅ `PredictionVotesSmartTile` (public) |
| RecentPhotosTile | ✅ `_RecentPhotosSmartTile` |
| RecentPurchasesTile | ✅ `_RecentPurchasesSmartTile` |
| RegistryDealsTile | ✅ `_RegistryDealsSmartTile` |
| RegistryHighlightsTile | ✅ `_RegistryHighlightsSmartTile` |
| RegistryListTile | ✅ `RegistryListSmartTile` (public) |
| RsvpTasksTile | ✅ `_RsvpTasksSmartTile` |
| StorageUsageTile | ✅ `_StorageUsageSmartTile` |
| SystemAnnouncementsTile | ✅ `_SystemAnnouncementsSmartTile` |
| UpcomingEventsTile | ✅ `_UpcomingEventsSmartTile` |

### SmartTile Pattern
Each SmartTile is a `ConsumerStatefulWidget` that:
1. In `initState()` → fetches data via its provider using `selectedBabyProfileProvider`
2. Listens to `selectedBabyProfileProvider` changes to re-fetch on profile switch
3. Passes presentational props to the actual tile widget

## Supabase Backend

### Database Tables (20+)
- **User**: profiles, user_stats
- **Baby**: baby_profiles, baby_memberships, invitations, owner_update_markers
- **Photos**: photos, photo_squishes, photo_comments, photo_tags
- **Calendar**: events, event_rsvps, event_comments
- **Registry**: registry_items, registry_purchases
- **Gamification**: votes, name_suggestions, name_suggestion_likes
- **Notifications**: notifications, notification_preferences
- **Tile System**: screens, tile_definitions, tile_configs
- **Activity/Meta**: activity_events, app_versions

### Edge Functions (6, 3 implemented + 3 stubs)
| Function | Status |
|----------|--------|
| `tile-configs` | ✅ Implemented — role-filtered tile config aggregator |
| `notification-trigger` | ✅ Implemented — OneSignal push multiplexer |
| `image-processing` | ✅ Implemented — thumbnail gen, optimization, EXIF |
| `send-invitation-email` | ⏳ Stub |
| `send-push-notification` | ⏳ Stub |
| `generate-thumbnail` | ⏳ Stub |

### Key DB Triggers
- `update_updated_at` — auto-maintain `updated_at` on all tables
- `handle_new_user` — auto-create profile + user_stats on signup
- Content marker triggers (photo/event/registry → `owner_update_markers`)
- Business rules: max 2 owners per baby, max 2 events per day per baby
- User stat counters: auto-increment on RSVP yes, purchase, squish, comment

### RLS Helper Functions (SECURITY DEFINER)
`is_baby_member`, `is_baby_owner`, `is_photo_member`, `is_photo_owner`, `is_event_member`, `is_registry_item_member`

## Navigation (GoRouter)
17 named routes defined in `app_router.dart` with auth redirect guards. Key routes: home, login, signup, role-selection, profile, calendar, gallery, gamification, settings, baby-profile CRUD, registry CRUD.

## Initialization Flow
1. `main()` → `AppInitializationService.initialize()` (Supabase, Firebase, OneSignal)
2. On success → `ProviderScope` → `MyApp`
3. `MyApp` watches `appInitializationProvider` → `MaterialApp.router` with GoRouter
4. Auth guard redirects unauthenticated users to login
5. Home screen auto-selects first baby profile if none set

## Key Patterns & Gotchas
- **TileLoader vs TileFactory**: TileLoader fetches configs from DB. TileFactory maps configs to widgets. They are separate concerns.
- **Issue #3.21**: HomeScreenNotifier was decoupled from direct `tileConfigProvider` dependency; now uses `TileLoader` utility.
- **Cache invalidation**: `owner_update_markers` table tracks content changes per baby; drives Hive cache invalidation.
- **Soft deletes**: Most tables use `deleted_at` column for soft deletion.
- **`selectedBabyProfileProvider`**: Global provider tracking the currently active baby profile ID. All smart tiles listen to it for re-fetching.
- **`homeScreenProvider`**: `autoDispose` NotifierProvider managing tile list, loading/error state, selected baby profile + role.
