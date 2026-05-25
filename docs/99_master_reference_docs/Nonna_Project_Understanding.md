# Nonna App — Project Understanding

**Document Version**: 1.3
**Created**: April 28, 2026
**Last Updated**: May 11, 2026
**Status**: Living Document

---

## What Is Nonna?

Nonna is a **Flutter mobile app** (v1.0.0) for **baby milestone tracking and family sharing**. It is a private, invite-only platform where expectant/new parents (**owners**) share pregnancy and baby updates with family and friends (**followers**).

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI / Framework | Flutter + Material 3 |
| State Management | Riverpod v3 |
| Navigation | GoRouter v17 |
| Backend | Supabase (Auth, PostgreSQL, Storage, Realtime) |
| Push Notifications | OneSignal |
| Analytics / Crash | Firebase Analytics, Crashlytics, Performance |
| Caching | Hive + SharedPreferences |
| Authentication | Supabase Auth, Google Sign-In, Facebook Auth, LocalAuth (biometrics) |
| Localization | Flutter i18n (ARB) — English + Spanish |

---

## Architecture: Dynamic Tile-Based System

The core architectural idea is **self-contained, reusable tile widgets** rendered dynamically based on Supabase-driven configuration tables. This "Tile Engine" decouples the frontend layout from hardcoded screens, allowing the product team to reorder, enable, or disable features purely via database updates.

### How the Tile Engine Works

1. **`screens` Table**: Registers the logical app screens capable of hosting tiles (e.g., `home`, `registry`, `calendar`).
2. **`tile_definitions` Table**: A catalog of every available tile component (e.g., `RegistryHighlightsTile`, `RecentPhotosTile`). It dictates the unique string identifier (`tile_type`) that the Flutter app uses to map a database row to a Dart class.
3. **`tile_configs` Table**: The master control table. It maps a `tile_definition` to a `screen` with specific deployment logic:
   - `role`: (`owner` or `follower`) Defines which user role will see this tile.
   - `display_order`: An integer defining the vertical sort order of the tile on the screen.
   - `is_visible`: A boolean kill-switch to quickly disable a tile without deleting the row.
   - `params`: An optional JSONB payload for passing dynamic settings (e.g., max items to fetch) directly to the tile widget.
4. **Supabase Edge Function (`tile-configs`)**: `TileLoader` now uses an edge-first strategy and invokes `tile-configs` with `{babyProfileId, userRole, screenName}`. The function resolves role/screen config and performs content-aware filtering (hiding tiles with no data) using `tile_configs.params` policy (`hideWhenEmpty`, default true for most tiles). If the function is unavailable, Flutter safely falls back to direct table query loading.
5. **`TileFactory` (Flutter)**: The frontend reads the JSON array returned by the Edge Function. The `TileFactory.buildTile()` method contains a giant `switch` statement matching the `tile_type` string to the corresponding `ConsumerStatefulWidget` wrapper (e.g., `_RegistryHighlightsSmartTile`).

```text
lib/
├── core/          # Cross-cutting: models, services, DI, router, themes, utils
├── tiles/         # 18 reusable tile widgets (first-class citizens)
│   ├── core/      # TileFactory, BaseTile, TileContainer
│   ├── upcoming_events/
│   ├── recent_photos/
│   ├── registry_highlights/
│   └── ... (19 total)
└── features/      # Screen composition (Home, Calendar, Gallery, etc.)
    ├── auth/
    ├── home/       # Composes tiles into a scrollable list view via TileFactory
    ├── calendar/
    ├── gallery/
    ├── registry/
    ├── baby_profile/
    ├── gamification/
    ├── profile/
    └── settings/
```

**Key design decision**: Tiles live at `lib/tiles/` (not inside features) so they can be reused across any screen. Each tile is completely self-contained with its own model, Riverpod provider, offline cache, and widget.

---

## Role System

Two roles drive what content is shown:

| Role | Access |
|---|---|
| **Owner** | Full access, editable tiles, scoped to their own baby profile(s) |
| **Follower** | Read-only, aggregated view across all followed babies |

The `HomeScreen` accepts `babyProfileId`, `userRole`, and `isDualRole` props and renders different tile sets accordingly. A user can hold both roles simultaneously (dual-role).

---

## Domain Models (23 total)

| Category | Models |
|---|---|
| User Identity | `User`, `UserStats` |
| Baby Profile | `BabyProfile`, `BabyMembership`, `Invitation` |
| Tile System | `TileConfig`, `ScreenConfig`, `TileDefinition`, `TileParams`, `TileState` |
| Calendar & Events | `Event`, `EventRsvp`, `EventComment` |
| Registry | `RegistryItem`, `RegistryPurchase` |
| Photo Gallery | `Photo`, `PhotoSquish`, `PhotoComment`, `PhotoTag` |
| Gamification | `Vote`, `NameSuggestion`, `NameSuggestionLike` |
| Notifications & Activity | `Notification`, `ActivityEvent` |
| Supporting | `OwnerUpdateMarker`, `SystemAnnouncement` |

---

## Service Layer (22 services)

| Category | Services |
|---|---|
| Supabase Core | `SupabaseService`, `AuthService`, `DatabaseService`, `StorageService` |
| Data Persistence | `CacheService`, `LocalStorageService` |
| Realtime & Notifications | `RealtimeService`, `RealtimeSubscriptionManager`, `NotificationService` |
| Monitoring & Analytics | `AnalyticsService`, `ObservabilityService` |
| Offline & Sync | `OfflineCacheManager`, `SyncManager`, `StatePersistenceManager`, `PersistenceStrategies` |
| Recovery & Compliance | `CrashRecoveryHandler`, `BackupService`, `DataExportHandler`, `DataDeletionHandler` |
| App Lifecycle | `AppInitializationService`, `ForceUpdateService`, `NetworkErrorHandler` |

---

## Tile Widgets (19 total)

| Tile | Screens Used |
|---|---|
| `NewBabyWelcomeTile` | Home (owner-only, visible for 7 days from `actual_birth_date`) |
| `UpcomingEventsTile` | Home, Calendar |
| `RecentPhotosTile` | Home, Gallery |
| `RegistryHighlightsTile` | Home, Registry |
| `CountdownTile` | Home |
| `ChecklistTile` | Home |
| `ActivityListTile` | Home, Gamification / Fun & Games |
| `GalleryFavoritesTile` | Home, Gallery |
| `InvitesStatusTile` | Home |
| `NewFollowersTile` | Home |
| `NotificationsTile` | Home |
| `RecentPurchasesTile` | Home, Registry |
| `RegistryDealsTile` | Home, Registry |
| `RegistryListTile` | Registry |
| `NameSuggestionsTile` | Gamification / Fun & Games |
| `PredictionVotesTile` | Gamification / Fun & Games |
| `RsvpTasksTile` | Home, Calendar |
| `StorageUsageTile` | Home, Settings |
| `SystemAnnouncementsTile` | Home |

---

## Navigation Structure

Routes are defined in `lib/core/router/app_router.dart` using GoRouter with auth-guard redirects.

| Route Constant | Path | Screen |
|---|---|---|
| `home` | `/home` | HomeScreen |
| `login` | `/login` | LoginScreen |
| `signup` | `/signup` | SignupScreen |
| `roleSelection` | `/role-selection` | RoleSelectionScreen |
| `profile` | `/profile` | ProfileScreen |
| `profileEdit` | `/profile/edit` | EditProfileScreen |
| `calendar` | `/calendar` | CalendarScreen |
| `calendarEvent` | `/calendar/event/detail` | EventDetailScreen |
| `calendarEventCreate` | `/calendar/event/create` | EventCreationScreen |
| `gallery` | `/gallery` | GalleryScreen |
| `galleryPhoto` | `/gallery/photo/detail` | PhotoDetailScreen |
| `gamification` | `/gamification` | GamificationScreen |
| `settings` | `/settings` | SettingsScreen |
| `babyProfile` | `/baby-profile` | BabyProfileScreen |
| `babyProfileCreate` | `/baby-profile/create` | CreateBabyProfileScreen |
| `babyProfileEdit` | `/baby-profile/:id/edit` | EditBabyProfileScreen |
| `babyProfileFollowers` | `/baby-profile/followers` | FollowersManagementScreen |
| `babyProfileInvite` | `/baby-profile/followers/invite` | InviteFollowersScreen |
| `registry` | `/registry` | RegistryScreen |
| `registryItem` | `/registry/item/detail` | RegistryItemDetailScreen |
| `registryItemCreate` | `/registry/item/create` | RegistryItemCreationScreen |

---

## Current State (as of April 29, 2026)

### Recent Implementation Updates (May 2026)
- **Registry screen — always show for empty profiles (May 24, 2026)**:
  - **Root cause**: The `tile-configs` edge function's `shouldHideWhenEmpty()` defaults to `true` for any tile NOT in `ALWAYS_VISIBLE_TILE_TYPES`. `RegistryListTile` was missing from that set. For new baby profiles with 0 registry items, the edge function probed `registry_items`, found 0 rows, and excluded `RegistryListTile` from the response. Flutter received an empty tiles array and `TileListView` showed the generic "No tiles to display" fallback.
  - **Fix 1 — Edge function** (`supabase/functions/tile-configs/index.ts`): Added `"RegistryListTile"` to `ALWAYS_VISIBLE_TILE_TYPES` so it is never hidden for empty registries. Redeployed to production (`supabase functions deploy tile-configs`).
  - **Fix 2 — TileLoader `forceRefresh`** (`registry_screen_provider.dart` `loadItems()`): `TileLoader.loadForScreen()` was hardcoded to `forceRefresh: false`, meaning the Hive tile cache could serve stale empty-tiles even when the screen forced a refresh. Changed to `forceRefresh: forceRefresh` so the tile cache is bypassed on full reloads.
  - **Fix 3 — Fallback empty state** (`registry_screen.dart` `_buildBody()`): Added registry-specific `emptyWidget: EmptyState(icon: Icons.card_giftcard_outlined, title: 'Your registry is empty', ...)` to the `TileListView` call, replacing the generic "No tiles to display" message even if tiles are empty for any other reason.
- **3 UI bug fixes — Gender %, Follower Unmark, Empty State (May 24, 2026)**:
  - **Issue #1 — Gender vote percentages now always sum to 100%** (`prediction_votes_tile.dart`): `_GenderVoteSection` used `totalGenderVotes = genderVotes.length` as the denominator, which counted all gender-typed votes including any non-Boy/Girl legacy values, inflating the total. Fixed to `totalGenderVotes = boyCount + girlCount` so Boy% + Girl% = 100% exactly. Removed pre-existing unused `empty_state.dart` import from the same file.
  - **Issue #2 — Followers can now unmark registry items they purchased** (`registry_screen_provider.dart`): Root cause was `togglePurchase()` reading the role from `homeScreenProvider.selectedRole` (global home-screen UI state) rather than the effective role for the specific baby profile whose registry was open. For dual-role users in owner mode viewing a follower-only profile, this set `isOwner = true` erroneously; the owner delete path (`DELETE WHERE registry_item_id = X`) was blocked by the Supabase RLS "Owners can delete any registry purchase" policy (which validates `bm.role = 'owner'`), so 0 rows were deleted silently. **Fix**: Added `currentRole` field (`UserRole?`) to `RegistryScreenState` (+ constructor/`copyWith`), set it in `loadItems()` when the role is resolved, and changed `togglePurchase()` to use `state.currentRole` instead of the homeScreen provider. Secondary defensive fix: `_loadFromCache()` previously restored the cached `isPurchasedByCurrentUser` boolean (a stale user-specific value). Changed to recompute it live from the `purchasers` list: `purchasers.any((u) => u.userId == currentUser.id)`. Removed now-unused `home_screen_provider.dart` import.
  - **Issue #3 — Encouraging empty state on new baby profiles** (`tile_list_view.dart`, `home_screen.dart`, `gallery_screen.dart`): When all tiles are hidden by the edge function's `hideWhenEmpty` policy (new profile with no photos/events/purchases), `TileListView` was showing the hardcoded developer message "No tiles to display". Added optional `emptyWidget` parameter to `TileListView` (falls back to existing default when not provided). `HomeScreen._buildBody()` now passes `EmptyState(icon: Icons.add_a_photo_outlined, title: 'Every big moment starts somewhere.', message: 'Add your first photo!', description: 'Tap the + button below to get started.')`. `GalleryScreen` also passes its own gallery-specific `EmptyState(icon: Icons.add_photo_alternate_outlined, title: 'No photos yet', message: 'Add your first photo!', description: 'Tap the + button below to get started.')`.
  - **Profile screen — show email instead of UUID fragment** (`profile_screen.dart`): The handle below the display name was showing `@${profile.userId.substring(0, 8)}` (first 8 chars of the Supabase UUID). Changed to display `ref.watch(authProvider).user?.email` (the auth user's email address), falling back to the UUID fragment only if email is null.
- **5 UI fixes — Tile polish pass (May 11, 2026)**:
  - **CountdownTile — no more "Born!" badge**: Provider `_fetchFromDatabase()` now filters out baby profiles where `actual_birth_date IS NOT NULL`. Smart tile (`_CountdownSmartTile`) returns `SizedBox.shrink()` (tile disappears) when `countdowns` is empty and not loading — i.e. once all babies have an actual birth date recorded. Badge text changed from `'Born!'` → `'Overdue'` for pre-birth overdue scenarios.
  - **RegistryHighlightsTile — removed from home screen**: `tile_configs` row for `screen=home / role=owner / tile_type=RegistryHighlightsTile` set to `is_visible = false` (pure DB update). Tile remains visible on the Registry screen.
  - **GalleryFavoritesTile — top 3 only, no "View all"**: Display limit changed from 5 → 3 in non-full-view mode (`gallery_favorites_tile.dart`). `onViewAll` callback removed from `_GalleryFavoritesSmartTile` so the "View all" link no longer appears.
  - **RecentPhotosTile — "View all" navigates to Gallery tab**: `onViewAll` callback simplified to `context.go(AppRoutes.gallery)` — always navigates to the Gallery tab root, replacing the previous conditional logic that pushed `galleryRecent`.
  - **RecentPurchasesTile — last 15 days, max 3 items**: Provider `_fetchFromDatabase()` adds `.gte('purchased_at', cutoffDate)` (15-day rolling window) and `_maxPurchases` reduced from 20 → 3. Smart tile default `maxItems` changed from 5 → 3.
- **Bug fixes — NewFollowersTile & ChecklistTile (May 11, 2026)**:
  - **NewFollowersTile — "View all" now functional**: `_NewFollowersSmartTile` in `TileFactory` previously set `onViewAll: () {}` (no-op). Fixed to `context.push(AppRoutes.babyProfileFollowers, extra: {babyProfileId, currentUserId})` — opens the owner `FollowersManagementScreen`. Only active when both `babyProfileId` and `currentUserId` are non-null.
  - **NewFollowersTile — display names**: Provider `_fetchFromDatabase()` now batch-fetches `profiles` and merges `display_name`/`avatar_url` into each `BabyMembership`. Model extended with optional `displayName`/`avatarUrl` fields. `_FollowerRow` renders `displayName ?? relationshipLabel ?? userId`.
  - **ChecklistTile — completed count always showed 0**: `_ChecklistSmartTile` was not passing `completedCount`/`progressPercentage` to `ChecklistTile`. Added both props wired to `state.completedCount` and `state.progressPercentage`.
  - **ChecklistTile — only 5 of 6 tasks visible**: `_buildBody` did `items.take(5)`. Removed the cap — the checklist renders all items (designed for a fixed onboarding set). Test updated from "shows at most 5 items" to "shows all items without truncation".
- **4 previously unseeded tiles activated on Home screen (May 11, 2026)**:
  - `ChecklistTile` ("Getting Started" onboarding checklist) — `display_order=70`, `role=owner`
  - `InvitesStatusTile` (sent invitation statuses with resend/revoke) — `display_order=80`, `role=owner`
  - `NewFollowersTile` (recently added followers in last 30 days) — `display_order=90`, `role=owner`
  - `StorageUsageTile` (cloud storage quota usage) — `display_order=100`, `role=owner`
  - Change was a **pure `tile_configs` DB update** — no code changes required; all smart wrappers in `TileFactory` were already fully implemented.
- **`NewBabyWelcomeTile`** added (May 11, 2026):
  - Birth announcement card tile displayed on the owner home screen for exactly **7 days** from `actual_birth_date`.
  - Shows: baby photo/avatar, name, gender chip, birth date, weight (kg), height (cm), and a day-counter badge ("🎉 Born today!" / "🎉 N days old").
  - Auto-hides via `SizedBox.shrink()` once outside the 7-day window — no server-side config change needed.
  - `tile_config`: screen=`home`, role=`owner`, `display_order=5` (appears at the top).
  - Files: `lib/tiles/new_baby_welcome/providers/new_baby_welcome_provider.dart`, `lib/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart`.
- **Bug fix — red screen on baby profile switch (May 12, 2026)**:
  - **Root cause**: When switching from a profile where `actualBirthDate == null` (baby not yet born) to one within the 7-day welcome window, `_NewBabyWelcomeSmartTileState` called `fetchProfile(newId, forceRefresh: true)`. The provider's `copyWith(isLoading: true)` preserved the old stale `BabyProfile` (with `actualBirthDate == null`). The `!state.isLoading` short-circuit in the smart tile meant it would render `NewBabyWelcomeTile` with the stale profile, and `_WelcomeContent.build()` crashed on `profile.actualBirthDate!` (null check operator on null).
  - **Fix 1** (`new_baby_welcome_tile.dart`): `_WelcomeContent.build()` — replaced `profile.actualBirthDate!` with a null guard: `final birthDate = profile.actualBirthDate; if (birthDate == null) return const SizedBox.shrink();`.
  - **Fix 2** (`tile_factory.dart` — `_NewBabyWelcomeSmartTileState`): Changed `babyProfile: state.babyProfile` → `babyProfile: state.isLoading ? null : state.babyProfile` and `isLoading: state.isLoading && state.babyProfile == null` → `isLoading: state.isLoading` — ensures stale data from a previous profile is never passed to the tile during a loading cycle, showing a shimmer instead.
- **4 UI/UX fixes (May 12, 2026)**:
  - **EditBabyProfile — label text**: `Actual Birth Date` fallback label corrected from `'Not yet born'` → `'Not born yet'` (`edit_baby_profile_screen.dart`).
  - **Home screen scrolling**: Removed unnecessary `SingleChildScrollView(physics: NeverScrollableScrollPhysics())` wrapper from `RecentPhotosTile` (`recent_photos_tile.dart`) — this redundant scrollable competed in Flutter's gesture arena and intercepted vertical drag events from the parent `ListView`, causing erratic scroll behaviour. Card content now uses a plain `Column`. Also updated `TileListView` (`tile_list_view.dart`) to apply `AlwaysScrollableScrollPhysics` on the root `ListView` when a `RefreshIndicator` is present, ensuring pull-to-refresh is reachable even when tile content does not overflow the screen.
  - **Engagement Recap tile — removal pending**: Requires a Supabase `tile_configs` DB update (`is_visible = false` for `tile_type = ActivityListTile`, `screen = fun`). Skipped this session because Supabase was unavailable — must be actioned when DB access is restored.
  - **Default app theme — Light**: `LocalStorageService.themeMode` default changed from `'system'` → `'light'` (`local_storage_service.dart`). `SettingsNotifier.build()` dark-mode detection simplified to `theme == 'dark'` only — the previous `theme == 'system' && platformBrightness == dark` branch is removed, so the OS-level dark-mode setting no longer silently overrides the in-app preference (`settings_provider.dart`).
- **5 UI/UX fixes (May 12, 2026 — second pass)**:
  - **EditBabyProfile — Cancel navigates back**: `Cancel` button now falls back to `context.pop()` when no explicit `onCancelled` callback is provided by the router (previously the button was a no-op because the GoRouter registration omits those callbacks). Same fallback added for `onDeleted`. (`edit_baby_profile_screen.dart`, added `go_router` import).
  - **EditBabyProfile — success SnackBar**: After a successful profile save, a `SnackBar('Baby profile updated successfully!')` is shown before navigation. Previously the save silently returned to the previous screen with no user feedback.
  - **Engagement Recap — app-resume re-fetch**: `_ActivityListSmartTileState` now mixes in `WidgetsBindingObserver` and overrides `didChangeAppLifecycleState`. On `AppLifecycleState.resumed`, `fetchEngagement(forceRefresh: true)` is triggered, clearing the stale `ClientException: Software caused connection abort` error that appeared when the user returned from another app (the HTTP connection pool goes stale while backgrounded).
  - **Registry list — always fetches fresh on open**: `RegistryScreen._loadRegistryIfReady` now passes `forceRefresh: true`. Previously the provider served stale Hive-cached data on initial mount; if the background sync failed (e.g. due to the Supabase connection issue above) the list permanently showed fewer items than the DB until the user added a new item (which called `loadItems(forceRefresh: true)` explicitly).
  - **Gender label — Neutral instead of Unknown**: `Gender.unknown.displayName` changed from `'Unknown'` → `'Neutral'`. Affects the SegmentedButton in `EditBabyProfileScreen` and the name-suggestion gender picker. Unit test in `gender_test.dart` updated accordingly.
- **`NewFollowersNotifier` — Riverpod lifecycle assertion fix (May 13, 2026)**:
  - **Root cause**: `_subscriptionManager` and `_realtimeService` were declared as `late final` fields with inline `ref.read()` initializers. Because `late` fields are lazily evaluated, they were first accessed inside the `onDispose` callback, triggering `ref.read()` during a Riverpod lifecycle — an assertion violation (`_debugCallbackStack == 0`).
  - **Fix** (`new_followers_provider.dart`): Changed to typed `late final` declarations. Both are now eagerly initialised at the top of `build()`, before `ref.onDispose()` is registered. The dispose closure safely references the stored instances with no `ref.read()` calls at teardown.
- **2 UI/UX fixes (May 17, 2026)**:
  - **Edit Baby Profile — direct navigation** (`home_app_bar.dart`): Owners now land directly in `EditBabyProfileScreen` in one tap. The popup menu item routes owners to `/baby-profile/:id/edit` (skipping the intermediate `BabyProfileScreen`). Menu label changes to **"Edit Baby Profile"** (icon: `Icons.edit_outlined`) for owners; followers still see "Baby Profile Info" → `BabyProfileScreen` (read-only).
  - **Settings Screen cleanup** (`settings_screen.dart`):
    - Removed "Nonna App User" profile header tile.
    - Removed "Sign Out" card (and `onSignOut` constructor parameter — `SettingsScreen` is now `const SettingsScreen()`).
    - Removed "Language" option from Customization section.
    - **Help & Support** now functional: opens `mailto:support@nonna.app?subject=Nonna%20App%20Support` via `url_launcher`; falls back to a SnackBar if no email client is available.
- **EditBabyProfile screen** now includes Birth Weight (kg) and Birth Height (cm) input fields (`TextFormField` with decimal keyboard).
- **`baby_profiles` DB schema** extended with `birth_weight_kg NUMERIC(5,3)` and `birth_height_cm NUMERIC(5,1)` (migration `20260510000000_add_birth_measurements_to_baby_profiles.sql`).
- **`BabyProfile` model** updated: `birthWeightKg` and `birthHeightCm` nullable fields added to constructor, `fromJson`, `toJson`, `copyWith`, `==`, `hashCode`.
- Added owner-facing follower management routes and screens:
  - `/baby-profile/followers`
  - `/baby-profile/followers/invite`
- Home app bar actions have been consolidated into a single, cleaner PopupMenuButton containing:
  - `Edit Baby Profile` (owners) / `Baby Profile Info` (followers)
  - Owner-only `Manage Followers`
  - `Add New Baby`
- Dynamic typography added: users can change the global app font from Settings (supported via Riverpod state driving `GoogleFonts` in `MaterialApp` theme).
- Baby profile creation flow now immediately:
  - Selects the newly created profile
  - Invalidates profile switcher data
  - Switches Home into owner context for the new profile
- Invitation flow is currently **email-only** in UI and provider logic:
  - Validation requires email format
  - Invitations are stored using `invitee_email` (lowercased)
  - Owner can revoke pending invitations from follower management
- Registry role resolution now prioritizes live per-profile membership resolution to avoid stale role/fab mismatches.
- Registry unmark purchases: Supabase RLS policies and provider logic were updated to explicitly allow baby profile owners to delete ANY registry purchase.
- Logout/auth-session behavior was hardened:
  - External service identity (Analytics/Crashlytics/OneSignal) is cleared before sign-out
  - Auth guard checks prioritize explicit auth provider state to reduce stale-session UI artifacts

### Completed
- Seed data migration injected globally across tabs via atomic PG transactions.
- Fixed Hive Cache dynamic type mappings for maps and `RegistryPurchase` timestamps (`purchased_at`).
- Configured Realtime replication for all dynamic tables without socket disconnects.
- Synced Hive SettingsNotifier completely with ThemeMode to persist dark mode.
- Fixed Riverpod `selectedBabyProfileProvider` listeners across Registry and main tabs.
- All 23 domain models with serialization, validation, and unit tests
- All 22 services with middleware integration
- All 19 tile widgets with providers and widget tests (includes `NewBabyWelcomeTile` added May 2026)
- All feature screens (auth, home, calendar, gallery, registry, profile, baby profile, gamification, settings)
- GoRouter navigation with auth redirect guards
- Supabase RLS policies with pgTAP test suite
- Supabase Edge Functions: `tile-configs`, `notification-trigger`, `image-processing`
- Localization (English + Spanish)
- Theming, error boundaries, offline cache and network failure handling
- **Centralized `TileFactory`** — dynamic tile instantiation from Supabase `tile_configs`/`screen_configs` tables mapped to all 19 tile components.

### Pending (Production Readiness Checklist)
- Unit test coverage to 80% minimum (sections 4.1–4.4)
- Widget, integration, performance, and golden tests (sections 4.2–4.5)
- App store deployment pipeline

---

## Key Files Reference

| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point — initializes Supabase/Firebase/OneSignal, launches with `ProviderScope` |
| `lib/core/router/app_router.dart` | GoRouter config with all named routes and auth redirect guards |
| `lib/core/utils/tile_factory.dart` | Core utility for dynamic tile instantiation from Supabase configs |
| `lib/features/home/presentation/screens/home_screen.dart` | Main screen composing tiles via `TileListView` |
| `lib/core/services/app_initialization_service.dart` | Bootstraps all third-party SDKs with graceful degradation |
| `lib/core/di/providers.dart` | Global Riverpod providers (auth, Supabase) |
| `lib/core/themes/colors.dart` | App color palette |
| `pubspec.yaml` | Dependency manifest |
| `supabase/migrations/` | Database migration scripts |
| `supabase/migrations/20260510000000_add_birth_measurements_to_baby_profiles.sql` | Adds `birth_weight_kg` and `birth_height_cm` columns to `baby_profiles` |
| `supabase/seed/06_new_baby_welcome_tile.sql` | Seeds `tile_definitions` + `tile_configs` for `NewBabyWelcomeTile` |
| `lib/tiles/new_baby_welcome/providers/new_baby_welcome_provider.dart` | Riverpod provider for `NewBabyWelcomeTile` — fetches profile, checks 7-day welcome window |
| `lib/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart` | Dumb tile widget — birth announcement card |
| `lib/core/models/baby_profile.dart` | Core baby profile model (extended with `birthWeightKg`, `birthHeightCm`) |
| `lib/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart` | Edit profile screen (extended with weight/height input fields) |
| `supabase/functions/` | Edge Functions (TypeScript/Deno) |

---

## Supabase Database Schema

### Tables

#### User Identity
| Table | Key Columns | Purpose |
|---|---|---|
| `profiles` | `user_id` (PK→auth), `display_name`, `avatar_url`, `biometric_enabled` | Public user profile; auto-created on signup |
| `user_stats` | `user_id` (PK→auth), `events_attended_count`, `items_purchased_count`, `photos_squished_count`, `comments_added_count` | Engagement counters; auto-incremented by triggers |

#### Baby Profile
| Table | Key Columns | Purpose |
|---|---|---|
| `baby_profiles` | `id`, `name`, `expected_birth_date`, `actual_birth_date`, `gender`, `profile_photo_url`, `birth_weight_kg`, `birth_height_cm`, `created_by`, `deleted_at` | Core baby record; soft-deleted; `created_by` allows creator access before membership is set; `birth_weight_kg` (NUMERIC 5,3) and `birth_height_cm` (NUMERIC 5,1) added May 2026 |
| `baby_memberships` | `id`, `baby_profile_id`, `user_id`, `role` (`owner`/`follower`), `relationship_label`, `removed_at` | Links users to babies with role; max 2 owners enforced by trigger; soft-removed |
| `invitations` | `id`, `baby_profile_id`, `invited_by_user_id`, `invitee_email`, `token_hash`, `expires_at`, `status` (`pending`/`accepted`/`revoked`/`expired`) | Token-based email invitations to join a baby profile |
| `owner_update_markers` | `id`, `baby_profile_id` (UNIQUE), `tiles_last_updated_at`, `reason` | Timestamp of last content change per baby; drives tile cache invalidation |

#### Photo Gallery
| Table | Key Columns | Purpose |
|---|---|---|
| `photos` | `id`, `baby_profile_id`, `uploaded_by_user_id`, `storage_path`, `thumbnail_path`, `caption`, `tags[]`, `deleted_at` | Photo uploads; soft-deleted |
| `photo_squishes` | `id`, `photo_id`, `user_id` | "Squish" reactions (like/heart) on photos; unique per user per photo |
| `photo_comments` | `id`, `photo_id`, `user_id`, `body`, `deleted_at` | Comments on photos; soft-deleted |
| `photo_tags` | `id`, `photo_id`, `tag` | Free-form string tags applied to photos |

#### Calendar & Events
| Table | Key Columns | Purpose |
|---|---|---|
| `events` | `id`, `baby_profile_id`, `created_by_user_id`, `title`, `starts_at`, `ends_at`, `description`, `location`, `video_link`, `cover_photo_url`, `deleted_at` | Calendar events; soft-deleted; max 2 per day per baby enforced by trigger |
| `event_comments` | `id`, `event_id`, `user_id`, `body`, `deleted_at` | Comments on events; soft-deleted |
| `event_rsvps` | `id`, `event_id`, `user_id`, `status` (`yes`/`no`/`maybe`) | RSVP per user per event; unique constraint |

#### Registry
| Table | Key Columns | Purpose |
|---|---|---|
| `registry_items` | `id`, `baby_profile_id`, `created_by_user_id`, `name`, `description`, `link_url`, `priority` (1–5), `deleted_at` | Baby registry wishlist items; soft-deleted |
| `registry_purchases` | `id`, `registry_item_id`, `purchased_by_user_id`, `purchased_at`, `note` | Records of purchased registry items |

#### Gamification
| Table | Key Columns | Purpose |
|---|---|---|
| `votes` | `id`, `baby_profile_id`, `user_id`, `vote_type` (`gender`/`birthdate`), `value_text`, `value_date`, `is_anonymous` | Community predictions on gender or birth date |
| `name_suggestions` | `id`, `baby_profile_id`, `user_id`, `suggested_name`, `gender`, `deleted_at` | User-submitted baby name suggestions; soft-deleted |
| `name_suggestion_likes` | `id`, `name_suggestion_id`, `user_id` | Likes on name suggestions; unique per user per suggestion |

#### Notifications
| Table | Key Columns | Purpose |
|---|---|---|
| `notifications` | `id`, `recipient_user_id`, `baby_profile_id`, `type`, `payload` (JSONB), `read_at` | In-app notifications; `read_at` null = unread |
| `notification_preferences` | `user_id` (PK), `push_*` flags, `email_*` flags | Per-user toggle for push and email notifications |

#### Tile System
| Table | Key Columns | Purpose |
|---|---|---|
| `screens` | `id`, `screen_name` (UNIQUE), `is_active` | Registry of app screens that can host tiles |
| `tile_definitions` | `id`, `tile_type` (UNIQUE), `description`, `schema_params` (JSONB), `is_active` | Catalog of available tile types with their parameter schema |
| `tile_configs` | `id`, `screen_id`, `tile_definition_id`, `role` (`owner`/`follower`), `display_order`, `is_visible`, `params` (JSONB) | Per-screen, per-role layout config for each tile |

#### Activity & App Meta
| Table | Key Columns | Purpose |
|---|---|---|
| `activity_events` | `id`, `baby_profile_id`, `actor_user_id`, `type`, `payload` (JSONB) | Audit log of user actions (feed/activity stream) |
| `app_versions` | `id`, `platform`, `minimum_version`, `store_url`, `is_active` | Minimum required app version per platform for force-update checks |

---

### Storage Buckets

| Bucket | Visibility | Max Size | Formats | Purpose |
|---|---|---|---|---|
| `user-avatars` | Public | 5 MB | JPEG, PNG, WebP | User profile photos |
| `baby-profile-photos` | Public | 5 MB | JPEG, PNG, WebP | Baby profile cover photos |
| `gallery-photos` | Private (RLS) | 10 MB | JPEG, PNG | Family photo gallery uploads |
| `event-photos` | Private (RLS) | 10 MB | JPEG, PNG | Event cover/attachment photos |

---

### Database Triggers & Functions

#### Auto-maintenance
| Function / Trigger | Fires On | Purpose |
|---|---|---|
| `update_updated_at` | BEFORE UPDATE on all tables with `updated_at` | Keeps `updated_at` current automatically |
| `handle_new_user` / `on_auth_user_created` | AFTER INSERT on `auth.users` | Auto-creates `profiles` and `user_stats` rows on signup |

#### Content Change Markers
| Function / Trigger | Fires On | Purpose |
|---|---|---|
| `update_photo_marker` / `photo_marker_trigger` | AFTER INSERT/UPDATE/DELETE on `photos` | Updates `owner_update_markers.tiles_last_updated_at` with `reason='photo_updated'` |
| `update_event_marker` / `event_marker_trigger` | AFTER INSERT/UPDATE/DELETE on `events` | Same for `reason='event_updated'` |
| `update_registry_marker` / `registry_marker_trigger` | AFTER INSERT/UPDATE/DELETE on `registry_items` | Same for `reason='registry_updated'` |

#### Business Rule Enforcement
| Function / Trigger | Fires On | Purpose |
|---|---|---|
| `enforce_max_two_owners` / `check_max_owners` | BEFORE INSERT/UPDATE on `baby_memberships` | Raises exception if a 3rd owner is added to a baby profile |
| `enforce_max_two_events_per_day` / `check_max_events_per_day` | BEFORE INSERT/UPDATE on `events` | Raises exception if >2 events exist for the same baby on the same day |

#### User Stat Counters
| Function / Trigger | Fires On | Purpose |
|---|---|---|
| `increment_events_attended` / `count_event_rsvp` | AFTER INSERT/UPDATE on `event_rsvps` | +1 to `events_attended_count` when RSVP status becomes `yes` |
| `increment_items_purchased` / `count_registry_purchase` | AFTER INSERT on `registry_purchases` | +1 to `items_purchased_count` |
| `increment_photos_squished` / `count_photo_squish` | AFTER INSERT on `photo_squishes` | +1 to `photos_squished_count` |
| `increment_comments_added` / `count_photo_comment` | AFTER INSERT on `photo_comments` | +1 to `comments_added_count` |

#### RLS Helper Functions (SECURITY DEFINER)
These break circular RLS dependencies and are used inside row-level security policies:

| Function | Purpose |
|---|---|
| `is_baby_member(user_id, baby_profile_id)` | Returns true if user has an active (non-removed) membership |
| `is_baby_owner(user_id, baby_profile_id)` | Returns true if user is an active owner |
| `is_photo_member(user_id, photo_id)` | Returns true if user is a member of the baby profile the photo belongs to |
| `is_photo_owner(user_id, photo_id)` | Returns true if user is an owner for the baby profile the photo belongs to |
| `is_event_member(user_id, event_id)` | Returns true if user is a member of the baby profile the event belongs to |
| `is_registry_item_member(user_id, registry_item_id)` | Returns true if user is a member of the baby profile the registry item belongs to |

---

### Edge Functions (Supabase/Deno)

| Function | Status | Purpose |
|---|---|---|
| `tile-configs` | Implemented | Accepts `{babyProfileId, userRole, screenName}` (also compatible with snake_case payload keys). Returns screen-scoped, role-scoped rows from `tile_configs` + `screens` + `tile_definitions` with backend content probes per tile type. Tiles with no content are filtered when `params.hideWhenEmpty` is enabled (or omitted for default-on behavior). Response includes metadata (`hiddenByEmptyCount`, `probeCount`) and cache headers (`max-age=300`). |
| `notification-trigger` | Implemented | Accepts `{recipientUserId, notificationType, title, message, data, babyProfileId}`. Inserts into `notifications` table then delivers via OneSignal push (uses `ONESIGNAL_APP_ID` + `ONESIGNAL_API_KEY` env vars). |
| `image-processing` | Implemented | Accepts `{imageUrl, bucketName, filePath, operations}`. Handles thumbnail generation, image optimization, and metadata extraction for Storage uploads. Uses `SUPABASE_SERVICE_ROLE_KEY`. |
| `send-invitation-email` | Stub | Placeholder — not yet implemented. Intended to send invitation emails when an owner invites a follower. |
| `send-push-notification` | Stub | Placeholder — not yet implemented. Intended as a direct push delivery endpoint separate from `notification-trigger`. |
| `generate-thumbnail` | Stub | Placeholder — not yet implemented. Intended as a dedicated thumbnail generation pipeline. |

---

## Connecting to Supabase from Command Line

**Setup:**
```bash
supabase login --token $SUPABASE_ACCESS_TOKEN
supabase link --project-ref $SUPABASE_PROJECT_ID
```

**Query database:**
```bash
psql "postgresql://postgres.ubptybhhrgdiyfkcqgwu:LaNonnaApp24%21%21@aws-1-us-east-2.pooler.supabase.com:5432/postgres" \
  -c "SELECT * FROM baby_profiles LIMIT 10;"
```

**Notes:**
- Special chars in password: URL-encode (e.g., `!` → `%21`)
- Use `-c` for single command, omit for interactive mode
- Common commands: `\dt` (list tables), `\d table_name` (describe), `\q` (quit)
