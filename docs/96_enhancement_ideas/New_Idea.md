# Dynamic, Database-Driven Control of Tiles & Screens

This document outlines the detailed architectural concept, database override
design, and step-by-step implementation guide to migrate hardcoded tile
configurations and parameters to a centralized, database-driven system
controlled from Supabase's `tile_configs` table.

By shifting these parameters to the database via the JSONB `params` column, we
enable instant, over-the-air (OTA) updates, personalized content rendering, and
centralized A/B testing of limits and messaging—all while maintaining robust
compile-time client fallback mechanisms for offline resiliency.

---

## Architectural Paradigm: The Hybrid Override Strategy

To balance **dynamic remote control** with **offline resilience**, we employ a
hybrid strategy:

```
        +-----------------------------------+
        |      Supabase tile_configs        |
        |     (JSONB 'params' payload)      |
        +-----------------------------------+
                          |
                          | [Fetches over API / Hive Cache]
                          v
        +-----------------------------------+
        |       Smart Tile Wrapper          |
        |  (Uses params?['key'] if present) |
        +-----------------------------------+
                     /         \
       [If present] /           \ [If null / Offline]
                   v             v
+----------------------+     +----------------------+
|   Dynamic DB Value   |     | Hardcoded Fallback   |
|  (Over-the-air OTA)  |     |   (Type-safe Dart)   |
+----------------------+     +----------------------+
```

1. **DB Override**: The client fetches the screen configuration and individual
   tile configs. If a key is configured in a tile's `params` dictionary, that
   value is used.
2. **Compile-Time Fallback**: If the key is missing from the database (null), or
   if the user is offline without a cache, the smart tile wrapper falls back to
   hardcoded, type-safe constants.
3. **Safe Serialization**: Non-primitive types (such as Material icons) are
   represented in database JSON as unique string identifiers (e.g.
   `'card_giftcard_outlined'`) and mapped to actual `IconData` elements via a
   type-safe enum mapper on the client.

---

## Overview of Changes

The implementation spans five ordered steps:

1. **`TileParamKeys`** — A new constants class for all standardized param key
   strings, preventing typos and enabling safe refactoring.
2. **`TileIconMapper`** — A new utility mapping DB icon strings to `IconData`,
   with full coverage of icons currently in use across the app.
3. **Tile Widget Updates** — Add an optional `emptyWidget` parameter to each
   tile widget that currently has a hardcoded `CompactEmptyState`.
4. **Smart Tile Factory Updates** — Thread `TileConfig` through all 18 smart
   tile wrappers and read `emptyMessage`/`emptyIcon` params.
5. **`RegistryListSmartTile` & `registry_screen.dart`** — Special-case updates
   for the registry tile (which lives in `lib/tiles/`) and the registry screen
   (which must remain in its current normalized `body: TileListView(...)` form).

---

## Step 0: `TileParamKeys` Constants Class

#### [NEW] `lib/core/constants/tile_param_keys.dart`

All `params` key strings are centralized here. Every smart tile wrapper reads
keys through this class—never raw string literals—preventing typos and making
future renames safe.

```dart
/// Standardized keys for the JSONB `params` column in `tile_configs`.
///
/// Every key that a smart tile wrapper may read from [TileConfig.params]
/// must be declared here. Do not use raw string literals elsewhere.
abstract final class TileParamKeys {
  // ─── Layout / behaviour ────────────────────────────────────────────────────
  /// Boolean. When `true`, renders the tile in an expanded full-view layout.
  /// Used by: RecentPhotosTile, GalleryFavoritesTile.
  static const String fullView = 'full';

  /// Integer. Maximum number of items to display in a condensed list.
  /// Used by: RecentPurchasesTile.
  static const String maxItems = 'maxItems';

  // ─── Empty-state overrides ─────────────────────────────────────────────────
  /// String. Overrides the primary heading of the screen-level empty state.
  /// Used by: RegistryScreen (via RegistryListTile params).
  static const String emptyTitle = 'emptyTitle';

  /// String. Overrides the body message shown in the tile or screen empty state.
  static const String emptyMessage = 'emptyMessage';

  /// String. Overrides the supplementary description text (screen-level only).
  /// Used by: RegistryScreen.
  static const String emptyDescription = 'emptyDescription';

  /// String. Icon identifier resolved by [TileIconMapper].
  /// Must match a key defined in [TileIconMapper.mapStringToIcon].
  static const String emptyIcon = 'emptyIcon';
}
```

> **Note**: The `hideWhenEmpty` key is consumed by the Supabase edge function
> `tile-configs/index.ts` before the config reaches the client. Do not add
> client-side logic that reads it.

---

## Step 1: `TileIconMapper` Utility

#### [NEW] `lib/core/utils/tile_icon_mapper.dart`

Maps database-stored icon name strings to Flutter `IconData`. Covers every
icon currently referenced in the app's empty states, plus a safe fallback.

```dart
import 'package:flutter/material.dart';

/// Maps DB string identifiers to Material [IconData] tokens.
///
/// Usage:
/// ```dart
/// final icon = TileIconMapper.mapStringToIcon(
///   config.params?[TileParamKeys.emptyIcon]?.toString(),
///   Icons.shopping_bag_outlined,   // caller-supplied fallback
/// );
/// ```
class TileIconMapper {
  TileIconMapper._();

  /// Returns the [IconData] for [iconName], or [fallback] when the name is
  /// `null`, blank, or unrecognised. Comparison is case-insensitive and
  /// whitespace-trimmed.
  static IconData mapStringToIcon(
    String? iconName, [
    IconData fallback = Icons.extension,
  ]) {
    if (iconName == null || iconName.trim().isEmpty) return fallback;

    switch (iconName.trim().toLowerCase()) {
      // ── Registry ────────────────────────────────────────────────────────────
      case 'card_giftcard_outlined':
      case 'card_giftcard':
        return Icons.card_giftcard_outlined;

      // ── Photos / Gallery ────────────────────────────────────────────────────
      case 'photo_outlined':
      case 'photo':
        return Icons.photo_outlined;
      case 'photo_library_outlined':
      case 'photo_library':
        return Icons.photo_library_outlined;
      case 'add_photo_alternate_outlined':
      case 'add_photo_alternate':
        return Icons.add_photo_alternate_outlined;
      case 'add_a_photo_outlined':
      case 'add_a_photo':
        return Icons.add_a_photo_outlined;
      case 'favorite_outline':
      case 'favorite_border':
        return Icons.favorite_outline;
      case 'favorite':
        return Icons.favorite;

      // ── Purchases / Shopping ────────────────────────────────────────────────
      case 'shopping_bag_outlined':
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;

      // ── Social / Followers ──────────────────────────────────────────────────
      case 'people_outline':
      case 'people':
        return Icons.people_outline;
      case 'mail_outlined':
      case 'mail':
        return Icons.mail_outlined;

      // ── Notifications ────────────────────────────────────────────────────────
      case 'notifications_none_outlined':
      case 'notifications_none':
        return Icons.notifications_none_outlined;

      // ── Calendar / Events ───────────────────────────────────────────────────
      case 'event_outlined':
      case 'event':
        return Icons.event_outlined;
      case 'calendar_today_outlined':
      case 'calendar_today':
        return Icons.calendar_today;

      // ── Tasks / Checklists ──────────────────────────────────────────────────
      case 'checklist_outlined':
      case 'checklist':
        return Icons.checklist_outlined;
      case 'check_circle_outline':
      case 'check_circle':
        return Icons.check_circle_outline;

      // ── Baby / Milestones ───────────────────────────────────────────────────
      case 'child_care_outlined':
      case 'child_care':
        return Icons.child_care_outlined;
      case 'child_friendly_outlined':
      case 'child_friendly':
        return Icons.child_friendly_outlined;
      case 'cake_outlined':
      case 'cake':
        return Icons.cake_outlined;
      case 'celebration_outlined':
      case 'celebration':
        return Icons.celebration_outlined;
      case 'emoji_emotions_outlined':
      case 'emoji_emotions':
        return Icons.emoji_emotions_outlined;

      // ── Gamification ────────────────────────────────────────────────────────
      case 'sports_esports_outlined':
      case 'sports_esports':
        return Icons.sports_esports_outlined;
      case 'poll_outlined':
      case 'poll':
        return Icons.poll_outlined;
      case 'how_to_vote_outlined':
      case 'how_to_vote':
        return Icons.how_to_vote_outlined;
      case 'text_fields_outlined':
      case 'text_fields':
        return Icons.text_fields;

      // ── Storage / System ────────────────────────────────────────────────────
      case 'storage_outlined':
      case 'storage':
        return Icons.storage_outlined;
      case 'dashboard_outlined':
      case 'dashboard':
        return Icons.dashboard_outlined;
      case 'info_outlined':
      case 'info':
        return Icons.info_outlined;
      case 'error_outline':
      case 'error':
        return Icons.error_outline;
      case 'warning_outlined':
      case 'warning':
        return Icons.warning_outlined;
      case 'inbox_outlined':
      case 'inbox':
        return Icons.inbox_outlined;
      case 'auto_awesome_outlined':
      case 'auto_awesome':
        return Icons.auto_awesome_outlined;
      case 'star_border':
      case 'star_outlined':
        return Icons.star_border;

      // ── Fallback ─────────────────────────────────────────────────────────────
      default:
        return fallback;
    }
  }
}
```

> **Maintenance rule**: Whenever a new icon is used in any tile's empty state,
> add it to this mapper before shipping. The `default:` branch always returns
> the caller-supplied fallback, so missing keys degrade gracefully.

---

## Step 2: Tile Widget Updates

Each tile widget that currently renders a hardcoded `CompactEmptyState` must be
updated to accept an optional `Widget? emptyWidget` parameter. The internal
`CompactEmptyState` is used as the default, preserving all existing behaviour
when nothing is passed.

### Affected tile widgets

| File | Tile Widget Class | Current hardcoded empty state |
|---|---|---|
| `lib/tiles/recent_photos/widgets/recent_photos_tile.dart` | `RecentPhotosTile` | `'No photos yet'` |
| `lib/tiles/gallery_favorites/widgets/gallery_favorites_tile.dart` | `GalleryFavoritesTile` | `'No favorites yet'` |
| `lib/tiles/recent_purchases/widgets/recent_purchases_tile.dart` | `RecentPurchasesTile` | `'No recent purchases'` |
| `lib/tiles/checklist/widgets/checklist_tile.dart` | `ChecklistTile` | `'Nothing left to do'` |
| `lib/tiles/countdown/widgets/countdown_tile.dart` | `CountdownTile` | `'No due dates'` |
| `lib/tiles/invites_status/widgets/invites_status_tile.dart` | `InvitesStatusTile` | `'No invitations sent'` |
| `lib/tiles/new_followers/widgets/new_followers_tile.dart` | `NewFollowersTile` | `'No new followers recently'` |
| `lib/tiles/notifications/widgets/notifications_tile.dart` | `NotificationsTile` | `'No notifications'` |
| `lib/tiles/rsvp_tasks/widgets/rsvp_tasks_tile.dart` | `RsvpTasksTile` | `'No RSVP tasks'` |
| `lib/tiles/upcoming_events/widgets/upcoming_events_tile.dart` | `UpcomingEventsTile` | `'No upcoming events'` |
| `lib/tiles/registry_highlights/widgets/registry_highlights_tile.dart` | `RegistryHighlightsTile` | `'No registry highlights'` |
| `lib/tiles/system_announcements/widgets/system_announcements_tile.dart` | `SystemAnnouncementsTile` | `'No announcements'` |
| `lib/tiles/name_suggestions/widgets/name_suggestions_tile.dart` | `NameSuggestionsTile` | `'No name suggestions yet'` |
| `lib/tiles/prediction_votes/widgets/prediction_votes_tile.dart` | `PredictionVotesTile` | `'No predictions yet'` |

> **Tiles that do NOT need this change**: `ActivityListTile`,
> `StorageUsageTile`, and `NewBabyWelcomeTile` do not render a conventional
> empty state and are excluded.

### Modification pattern (apply identically to every widget above)

**Before**:
```dart
// inside the tile widget's build method, in the empty-data branch:
if (purchases.isEmpty) {
  return const CompactEmptyState(
    message: 'No recent purchases',
    icon: Icons.shopping_bag_outlined,
  );
}
```

**After**:
```dart
// 1. Add the parameter to the widget's constructor field list:
final Widget? emptyWidget;

// 2. Add it to the constructor:
const RecentPurchasesTile({
  super.key,
  // ... existing params ...
  this.emptyWidget,
});

// 3. Replace the hardcoded CompactEmptyState with a guarded fallback:
if (purchases.isEmpty) {
  return emptyWidget ??
      const CompactEmptyState(
        message: 'No recent purchases',
        icon: Icons.shopping_bag_outlined,
      );
}
```

No other logic in the tile widget changes. The default `CompactEmptyState`
values remain as the fallback, so every call site that does not pass
`emptyWidget` continues to work exactly as before.

---

## Step 3: Smart Tile Factory Updates

#### [MODIFY] `lib/core/utils/tile_factory.dart`

Two parallel changes are needed.

### 3a. Thread `TileConfig` through all smart tile wrappers

Tiles that are currently instantiated as `const _XSmartTile()` (no config) must
be changed to receive `config: config`. This is the prerequisite for any wrapper
to read `params`.

**In `TileFactory.buildTile()` switch statement** — change every `const`
instantiation to pass config:

```dart
// Before (example — 15 tiles currently use this pattern):
case 'CountdownTile':
  return const _CountdownSmartTile();

// After:
case 'CountdownTile':
  return _CountdownSmartTile(config: config);
```

Apply this to all 15 tiles that currently lack config:

| Case | Before | After |
|---|---|---|
| `'UpcomingEventsTile'` | `const _UpcomingEventsSmartTile()` | `_UpcomingEventsSmartTile(config: config)` |
| `'RegistryHighlightsTile'` | `const _RegistryHighlightsSmartTile()` | `_RegistryHighlightsSmartTile(config: config)` |
| `'RegistryListTile'` | `const RegistryListSmartTile()` | `RegistryListSmartTile(config: config)` |
| `'CountdownTile'` | `const _CountdownSmartTile()` | `_CountdownSmartTile(config: config)` |
| `'ChecklistTile'` | `const _ChecklistSmartTile()` | `_ChecklistSmartTile(config: config)` |
| `'ActivityListTile'` | `const _ActivityListSmartTile()` | `_ActivityListSmartTile(config: config)` |
| `'InvitesStatusTile'` | `const _InvitesStatusSmartTile()` | `_InvitesStatusSmartTile(config: config)` |
| `'NewFollowersTile'` | `const _NewFollowersSmartTile()` | `_NewFollowersSmartTile(config: config)` |
| `'NotificationsTile'` | `const _NotificationsSmartTile()` | `_NotificationsSmartTile(config: config)` |
| `'RsvpTasksTile'` | `const _RsvpTasksSmartTile()` | `_RsvpTasksSmartTile(config: config)` |
| `'StorageUsageTile'` | `const _StorageUsageSmartTile()` | `_StorageUsageSmartTile(config: config)` |
| `'SystemAnnouncementsTile'` | `const _SystemAnnouncementsSmartTile()` | `_SystemAnnouncementsSmartTile(config: config)` |
| `'NameSuggestionsTile'` | `const NameSuggestionsSmartTile()` | `NameSuggestionsSmartTile(config: config)` |
| `'PredictionVotesTile'` | `const PredictionVotesSmartTile()` | `PredictionVotesSmartTile(config: config)` |
| `'NewBabyWelcomeTile'` | `const _NewBabyWelcomeSmartTile()` | `_NewBabyWelcomeSmartTile(config: config)` |

The three tiles that already receive config (`RecentPhotosTile`,
`GalleryFavoritesTile`, `RecentPurchasesTile`) require no change to the switch.

Each wrapper class must also gain `final TileConfig config;` as a field and
update its constructor accordingly:

```dart
// Before:
class _CountdownSmartTile extends ConsumerStatefulWidget {
  const _CountdownSmartTile();
  // ...
}

// After:
class _CountdownSmartTile extends ConsumerStatefulWidget {
  const _CountdownSmartTile({required this.config});
  final TileConfig config;
  // ...
}
```

> `NameSuggestionsSmartTile` and `PredictionVotesSmartTile` are public classes
> defined in their own tile files — apply the same constructor change there, not
> in `tile_factory.dart`.

### 3b. Read params in `build()` and pass `emptyWidget` down

Apply the following pattern to every smart tile wrapper that maps to a tile with
an empty state (see the table in Step 2). The three wrappers that already read
params (`_RecentPhotosSmartTile`, `_GalleryFavoritesSmartTile`,
`_RecentPurchasesSmartTile`) need only the new `emptyMessage`/`emptyIcon` block
added alongside their existing param reads.

#### Tile-by-tile specifications

| Smart Tile Wrapper | Tile Widget | Default `emptyMessage` | Default `emptyIcon` |
|---|---|---|---|
| `_RecentPhotosSmartTile` | `RecentPhotosTile` | `'No photos yet'` | `Icons.photo_outlined` |
| `_GalleryFavoritesSmartTile` | `GalleryFavoritesTile` | `'No favorites yet'` | `Icons.favorite_outline` |
| `_RecentPurchasesSmartTile` | `RecentPurchasesTile` | `'No recent purchases'` | `Icons.shopping_bag_outlined` |
| `_ChecklistSmartTile` | `ChecklistTile` | `'No checklist items'` | `Icons.checklist_outlined` |
| `_CountdownSmartTile` ⚠️ | `CountdownTile` | `'No due dates to display'` | `Icons.child_care_outlined` |
| `_InvitesStatusSmartTile` | `InvitesStatusTile` | `'No invitations sent'` | `Icons.mail_outlined` |
| `_NewFollowersSmartTile` | `NewFollowersTile` | `'No new followers recently'` | `Icons.people_outline` |
| `_NotificationsSmartTile` | `NotificationsTile` | `'No notifications'` | `Icons.notifications_none_outlined` |
| `_RsvpTasksSmartTile` | `RsvpTasksTile` | `'No RSVP tasks'` | `Icons.check_circle_outline` |
| `_UpcomingEventsSmartTile` | `UpcomingEventsTile` | `'No upcoming events'` | `Icons.event_outlined` |
| `_RegistryHighlightsSmartTile` | `RegistryHighlightsTile` | `'No registry highlights'` | `Icons.card_giftcard_outlined` |
| `_SystemAnnouncementsSmartTile` | `SystemAnnouncementsTile` | `'No announcements'` | `Icons.info_outlined` |
| `NameSuggestionsSmartTile` ★ | `NameSuggestionsTile` | `'No name suggestions yet'` | `Icons.text_fields_outlined` |
| `PredictionVotesSmartTile` ★ | `PredictionVotesTile` | `'No predictions yet'` | `Icons.poll_outlined` |

> ⚠️ `_CountdownSmartTile` currently returns `SizedBox.shrink()` when
> `state.countdowns.isEmpty` (it self-hides once all babies have birthdates).
> The `emptyWidget` override allows that self-hide to be replaced with a visible
> message if desired, but the DB row should leave `emptyMessage` unset by
> default so the existing self-hide behaviour is preserved.

> ★ `NameSuggestionsSmartTile` and `PredictionVotesSmartTile` are public classes
> defined in their own tile files. Apply the same pattern there.

> Tiles without a conventional empty state — `_ActivityListSmartTile`,
> `_StorageUsageSmartTile`, `_NewBabyWelcomeSmartTile` — receive `config` for
> future extensibility but do **not** need `emptyMessage`/`emptyIcon` logic.

#### Code pattern (applied in every relevant wrapper's `build()` method)

```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(recentPurchasesProvider);
  final babyProfileId = ref.watch(selectedBabyProfileProvider);

  // ── Existing layout params ────────────────────────────────────────────────
  final maxItems = widget.config.params?[TileParamKeys.maxItems] as int? ?? 3;

  // ── Empty-state overrides (use .toString() to guard against JSONB type mismatches)
  final emptyMessage =
      widget.config.params?[TileParamKeys.emptyMessage]?.toString()
          ?? 'No recent purchases';

  final emptyIcon = TileIconMapper.mapStringToIcon(
    widget.config.params?[TileParamKeys.emptyIcon]?.toString(),
    Icons.shopping_bag_outlined,   // compile-time fallback
  );

  return RecentPurchasesTile(
    purchases: state.purchases,
    isLoading: state.isLoading && state.purchases.isEmpty,
    error: state.error,
    maxItems: maxItems,
    emptyWidget: CompactEmptyState(message: emptyMessage, icon: emptyIcon),
    onRefresh: babyProfileId != null
        ? () => ref
            .read(recentPurchasesProvider.notifier)
            .fetchPurchases(babyProfileId: babyProfileId, forceRefresh: true)
        : null,
  );
}
```

> **Type safety rule**: Always use `.toString()` when extracting String params.
> A JSONB value accidentally stored as a number would throw with `as String?`
> but degrade gracefully with `.toString()`.

---

## Step 4: `RegistryListSmartTile` Update

`RegistryListSmartTile` is a special case: unlike the private wrappers in
`tile_factory.dart`, it is defined directly inside
`lib/tiles/registry_list/widgets/registry_list_tile.dart` and is both the smart
tile wrapper and the tile itself (a `ConsumerWidget`, not a
`ConsumerStatefulWidget`).

#### [MODIFY] `lib/tiles/registry_list/widgets/registry_list_tile.dart`

Add `TileConfig? config` to the constructor and read params:

```dart
import 'package:nonna_app/core/constants/tile_param_keys.dart';
import 'package:nonna_app/core/utils/tile_icon_mapper.dart';
import 'package:nonna_app/core/models/tile_config.dart';

class RegistryListSmartTile extends ConsumerWidget {
  const RegistryListSmartTile({super.key, this.config});

  final TileConfig? config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...existing state and role resolution unchanged...

    final emptyMessage =
        config?.params?[TileParamKeys.emptyMessage]?.toString()
            ?? 'No registry items found';

    final emptyIcon = TileIconMapper.mapStringToIcon(
      config?.params?[TileParamKeys.emptyIcon]?.toString(),
      Icons.card_giftcard_outlined,
    );

    // ...existing card / column structure unchanged...

    if (items.isEmpty)
      CompactEmptyState(message: emptyMessage, icon: emptyIcon)
    // ...rest of the widget tree unchanged...
  }
}
```

The factory switch (`case 'RegistryListTile': return RegistryListSmartTile(config: config)`)
from Step 3a is the only caller — no other call sites exist.

---

## Step 5: `registry_screen.dart` Update

#### [MODIFY] `lib/features/registry/presentation/screens/registry_screen.dart`

The registry screen was normalized in a previous session to use
`body: TileListView(...)` directly. **This normalized structure must be
preserved** — the older `SliverToBoxAdapter` + `shrinkWrap` chain must not be
reintroduced.

Two distinct empty state levels exist in the registry screen:

- **Tile-level** (most common): `RegistryListSmartTile` shows `CompactEmptyState`
  when the registry items list is empty. This is handled by Step 4.
- **Screen-level** (edge case): `TileListView`'s `emptyWidget` is shown when
  `state.tiles` is entirely empty (e.g., all tiles hidden by the edge function).

For the screen-level empty state, the `RegistryListTile` config params are
reused — they are semantically equivalent and avoid introducing a separate
screen-config concept.

Add the following imports if not already present:

```dart
import 'package:nonna_app/core/constants/tile_param_keys.dart';
import 'package:nonna_app/core/utils/tile_icon_mapper.dart';
```

Replace the hardcoded `emptyWidget` in the `body: TileListView(...)` call:

```dart
// Before:
body: TileListView(
  tiles: state.tiles,
  isLoading: state.isLoading,
  error: state.error,
  onRefresh: _onRefresh,
  onRetry: _loadRegistryIfReady,
  emptyWidget: const EmptyState(
    icon: Icons.card_giftcard_outlined,
    title: 'Your registry is empty',
    message: 'Add your first item!',
    description: 'Tap the + button below to get started.',
  ),
),

// After:
body: Builder(
  builder: (context) {
    // Reuse the RegistryListTile params for the screen-level empty state.
    final registryParams = state.tiles
        .where((t) => t.componentName == 'RegistryListTile')
        .firstOrNull
        ?.params;

    final emptyTitle =
        registryParams?[TileParamKeys.emptyTitle]?.toString()
            ?? 'Your registry is empty';
    final emptyMessage =
        registryParams?[TileParamKeys.emptyMessage]?.toString()
            ?? 'Add your first item!';
    final emptyDesc =
        registryParams?[TileParamKeys.emptyDescription]?.toString()
            ?? 'Tap the + button below to get started.';
    final emptyIcon = TileIconMapper.mapStringToIcon(
      registryParams?[TileParamKeys.emptyIcon]?.toString(),
      Icons.card_giftcard_outlined,
    );

    return TileListView(
      tiles: state.tiles,
      isLoading: state.isLoading,
      error: state.error,
      onRefresh: _onRefresh,
      onRetry: _loadRegistryIfReady,
      emptyWidget: EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
        description: emptyDesc,
      ),
    );
  },
),
```

> **Why `Builder`?** It avoids extracting a helper method while keeping the
> param lookup local to the build tree. A `_buildBody(state)` helper is equally
> valid if preferred — just derive params inside the method, not from a separate
> `screenParams` argument.

---

## Operational Notes

### Cache TTL & OTA propagation delay

`TileLoader` caches tile configs (including `params`) in Hive for **30 minutes**
(`PerformanceLimits.screenCacheDuration`). A param change made in Supabase will
not reach users until their cache expires or they perform a manual
pull-to-refresh. This is acceptable for empty-state copy changes. If an urgent
param update must propagate immediately, increment the Hive cache key prefix
(currently `tile_configs_v3`) to bust all existing caches on the next app
launch.

### Edge function coordination

The edge function `tile-configs/index.ts` reads only `params?.hideWhenEmpty`
from the params payload. All client-side keys (`emptyMessage`, `emptyIcon`,
`emptyTitle`, `emptyDescription`, `full`, `maxItems`) are passed through
untouched. No edge function changes are required for this feature.

### `TileLoader` component name filter

`TileLoader._supportedComponentNames` is the client-side allowlist that filters
which tile types are accepted from the API response. All 18 tile types covered
by this feature are already in the set. No changes needed.

---

## Verification & Testing Plan

### 1. `TileIconMapper` unit tests

#### [NEW] `test/core/utils/tile_icon_mapper_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/tile_icon_mapper.dart';

void main() {
  group('TileIconMapper', () {
    test('returns correct IconData for known keys', () {
      expect(TileIconMapper.mapStringToIcon('card_giftcard_outlined'),
          Icons.card_giftcard_outlined);
      expect(TileIconMapper.mapStringToIcon('shopping_bag_outlined'),
          Icons.shopping_bag_outlined);
      expect(TileIconMapper.mapStringToIcon('sports_esports_outlined'),
          Icons.sports_esports_outlined);
      expect(TileIconMapper.mapStringToIcon('poll_outlined'),
          Icons.poll_outlined);
      expect(TileIconMapper.mapStringToIcon('add_photo_alternate_outlined'),
          Icons.add_photo_alternate_outlined);
    });

    test('is case-insensitive and trims whitespace', () {
      expect(TileIconMapper.mapStringToIcon('  Card_Giftcard_Outlined  '),
          Icons.card_giftcard_outlined);
      expect(TileIconMapper.mapStringToIcon('SHOPPING_BAG_OUTLINED'),
          Icons.shopping_bag_outlined);
    });

    test('returns default fallback (Icons.extension) for unknown strings', () {
      expect(TileIconMapper.mapStringToIcon('non_existent_icon'),
          Icons.extension);
    });

    test('returns caller-supplied fallback for null or empty input', () {
      expect(TileIconMapper.mapStringToIcon(null, Icons.error), Icons.error);
      expect(TileIconMapper.mapStringToIcon('', Icons.warning_outlined),
          Icons.warning_outlined);
      expect(TileIconMapper.mapStringToIcon('   ', Icons.info_outlined),
          Icons.info_outlined);
    });

    test('supports alternate alias keys', () {
      expect(TileIconMapper.mapStringToIcon('card_giftcard'),
          Icons.card_giftcard_outlined);
      expect(TileIconMapper.mapStringToIcon('favorite_border'),
          Icons.favorite_outline);
    });
  });
}
```

```bash
flutter test test/core/utils/tile_icon_mapper_test.dart
```

### 2. Smart tile wrapper param extraction tests

#### [NEW] `test/core/utils/tile_param_extraction_test.dart`

Widget tests verifying that each wrapper correctly reads params and falls back
when params are absent. Use `TileConfig` with a mocked `params` map.

Key scenarios to cover for each wrapper:

1. **Params present** — supply `emptyMessage` and `emptyIcon` in params; assert
   the rendered `CompactEmptyState` displays those values.
2. **Params absent (`null`)** — supply `TileConfig` with `params: null`; assert
   the compile-time default message and icon are rendered.
3. **Params malformed (wrong type)** — supply `params: {'emptyIcon': 42}`
   (integer, not string); assert no exception is thrown and the fallback icon
   is used (validates the `.toString()` coercion rule).

### 3. Manual Supabase configuration test

Verify end-to-end by setting a tile's `params` in Supabase Studio:

```json
{
  "maxItems": 1,
  "emptyMessage": "Nothing here yet — check back soon!",
  "emptyIcon": "notifications_none_outlined"
}
```

Steps:
1. Update the row in `tile_configs` for the target tile.
2. Kill and relaunch the app (to bypass the 30-minute Hive cache).
3. Navigate to the screen containing that tile.
4. Confirm the tile shows exactly 1 item max and the custom empty-state message
   and icon when no data is present.
5. Toggle airplane mode, relaunch — confirm cached params render the same
   overridden values without errors.
