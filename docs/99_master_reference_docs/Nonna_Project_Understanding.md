# Nonna App — Project Understanding

**Document Version**: 3.3 **Last Updated**: May 2026 **Status**: Living
Document - Fully aligned with Version 3.1 codebase specifications

---

## What Is Nonna?

Nonna is a **Flutter mobile app** (v1.0.0) for **baby milestone tracking and
family sharing**. It is a private, invite-only platform where expectant/new
parents (**owners**) share pregnancy and baby updates with family and friends
(**followers**).

---

## Tech Stack

| Layer              | Technology                                                           |
| ------------------ | -------------------------------------------------------------------- |
| UI / Framework     | Flutter + Material 3                                                 |
| State Management   | Riverpod v3                                                          |
| Navigation         | GoRouter v17                                                         |
| Backend            | Supabase (Auth, PostgreSQL, Storage, Realtime)                       |
| Push Notifications | OneSignal                                                            |
| Analytics / Crash  | Firebase Analytics, Crashlytics, Performance                         |
| Caching            | Hive + SharedPreferences                                             |
| Authentication     | Supabase Auth, Google Sign-In, Facebook Auth, LocalAuth (biometrics) |
| Localization       | Flutter i18n (ARB) — English + Spanish                               |

---

## Architecture: Dynamic Tile-Based System

The core architectural idea is **self-contained, reusable tile widgets**
rendered dynamically based on Supabase-driven configuration tables. This "Tile
Engine" decouples the frontend layout from hardcoded screens, allowing the
product team to reorder, enable, or disable features purely via database
updates.

### How the Tile Engine Works

1. **`screens` Table**: Registers the logical app screens capable of hosting
   tiles (e.g., `home`, `registry`, `calendar`).
2. **`tile_definitions` Table**: A catalog of every available tile component
   (e.g., `RegistryHighlightsTile`, `RecentPhotosTile`). It dictates the unique
   string identifier (`tile_type`) that the Flutter app uses to map a database
   row to a Dart class.
3. **`tile_configs` Table**: The master control table. It maps a
   `tile_definition` to a `screen` with specific deployment logic:
   - `role`: (`owner` or `follower`) Defines which user role will see this tile.
   - `display_order`: An integer defining the vertical sort order of the tile on
     the screen.
   - `is_visible`: A boolean kill-switch to quickly disable a tile without
     deleting the row.
   - `params`: An optional JSONB payload for passing dynamic settings (e.g., max
     items to fetch) directly to the tile widget.
4. **Supabase Edge Function (`tile-configs`)**: `TileLoader` now uses an
   edge-first strategy and invokes `tile-configs` with
   `{babyProfileId, userRole, screenName}`. The function resolves role/screen
   config and performs content-aware filtering (hiding tiles with no data) using
   `tile_configs.params` policy (`hideWhenEmpty`, default true for most tiles).
   If the function is unavailable, Flutter safely falls back to direct table
   query loading.
5. **`TileFactory` (Flutter)**: The frontend reads the JSON array returned by
   the Edge Function. The `TileFactory.buildTile()` method contains a giant
   `switch` statement matching the `tile_type` string to the corresponding
   `ConsumerStatefulWidget` wrapper (e.g., `_RegistryHighlightsSmartTile`).

```text
lib/
├── core/          # Cross-cutting: models, services, DI, router, themes, utils
├── tiles/         # 18 reusable parameterized smart tile widgets (first-class citizens)
│   ├── core/      # TileFactory, BaseTile, TileContainer
│   ├── upcoming_events/
│   ├── recent_photos/
│   ├── registry_highlights/
│   └── ... (18 total including core)
└── features/      # Screen composition & presentation (Home, Calendar, Gallery, etc.)
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

**Key design decision**: Tiles live at `lib/tiles/` (not inside features) so
they can be reused across any screen. Each tile is completely self-contained
with its own model, Riverpod provider, offline cache, and widget.

---

## Role System

Two roles drive what content is shown:

| Role         | Access                                                                                                                              |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Owner**    | Full access, editable tiles, scoped to their own baby profile(s). Can manage followers, invitations, and registry purchase deletes. |
| **Follower** | Read-only, aggregated view across all followed babies. Can squish photos, post comments, and commit registry gifts.                 |

The `HomeScreen` accepts `babyProfileId`, `userRole`, and `isDualRole` props and
renders different tile sets accordingly. A user can hold both roles
simultaneously (dual-role).

---

## Domain Models (23 total)

| Category                 | Models                                                                    |
| ------------------------ | ------------------------------------------------------------------------- |
| User Identity            | `User`, `UserStats`                                                       |
| Baby Profile             | `BabyProfile`, `BabyMembership`, `Invitation`                             |
| Tile System              | `TileConfig`, `ScreenConfig`, `TileDefinition`, `TileParams`, `TileState` |
| Calendar & Events        | `Event`, `EventRsvp`, `EventComment`                                      |
| Registry                 | `RegistryItem`, `RegistryPurchase`                                        |
| Photo Gallery            | `Photo`, `PhotoSquish`, `PhotoComment`, `PhotoTag`                        |
| Gamification             | `Vote`, `NameSuggestion`, `NameSuggestionLike`                            |
| Notifications & Activity | `Notification`, `ActivityEvent`                                           |
| Supporting               | `OwnerUpdateMarker`, `SystemAnnouncement`                                 |

---

## Service Layer (22 services)

| Category                 | Services                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| Supabase Core            | `SupabaseService`, `AuthService`, `DatabaseService`, `StorageService`                    |
| Data Persistence         | `CacheService`, `LocalStorageService`                                                    |
| Realtime & Notifications | `RealtimeService`, `RealtimeSubscriptionManager`, `NotificationService`                  |
| Monitoring & Analytics   | `AnalyticsService`, `ObservabilityService`                                               |
| Offline & Sync           | `OfflineCacheManager`, `SyncManager`, `StatePersistenceManager`, `PersistenceStrategies`, `NetworkStatusNotifier`, `ConnectivityWrapper` |
| Recovery & Compliance    | `CrashRecoveryHandler`, `BackupService`, `DataExportHandler`, `DataDeletionHandler`      |
| App Lifecycle            | `AppInitializationService`, `ForceUpdateService`, `NetworkErrorHandler`                  |

---

## Active Tile Widgets (18 total)

| Tile                      | Screens Used   | Description                                                                          |
| ------------------------- | -------------- | ------------------------------------------------------------------------------------ |
| `NewBabyWelcomeTile`      | Home           | Congratulations birth announcement card (owner-only, visible for 7 days post-birth). |
| `UpcomingEventsTile`      | Home, Calendar | Displays upcoming calendar milestones and events.                                    |
| `RecentPhotosTile`        | Home, Gallery  | Showcases recent baby photos.                                                        |
| `RegistryHighlightsTile`  | Home, Registry | Highlights featured registry items for followers to buy.                             |
| `CountdownTile`           | Home           | Active due date countdown until birth.                                               |
| `ChecklistTile`           | Home           | Onboarding checklist guiding owners on setup tasks.                                  |
| `ActivityListTile`        | Home           | Social activity summaries and metrics recap.                                         |
| `GalleryFavoritesTile`    | Home, Gallery  | Displays top-squished (liked) family photos.                                         |
| `InvitesStatusTile`       | Home           | Sentence tracker for sent follower email invites (owner-only).                       |
| `NewFollowersTile`        | Home           | Lists recently added followers (last 30 days).                                       |
| `NotificationsTile`       | Home           | Recipient alert and deep-linking routing notifications.                              |
| `RecentPurchasesTile`     | Home, Registry | Highlights bought registry items from the last 15 days.                              |
| `RegistryListTile`        | Registry       | Complete dynamic list of registry needs.                                             |
| `NameSuggestionsTile`     | Gamification   | Proposed name suggestions list.                                                      |
| `PredictionVotesTile`     | Gamification   | Community prediction votes card.                                                     |
| `RsvpTasksTile`           | Home, Calendar | Shows upcoming events requiring RSVPs.                                               |
| `StorageUsageTile`        | Home           | Cloud file allocation storage usage metrics (owner-only).                            |
| `SystemAnnouncementsTile` | Home           | Global push announcements or release banners.                                        |

---

## Navigation Structure

Routes are defined in `lib/core/router/app_router.dart` using GoRouter with
auth-guard redirects.

Detail/edit routes embed `:id` path slugs so they survive deep links, push
notification launches, and OS background restores. Use the static URL builder
helpers on `AppRoutes` (e.g. `AppRoutes.galleryPhotoRoute(id)`) as navigation
targets — never the raw constants directly.

| Route Constant         | Path                             | Screen                     |
| ---------------------- | -------------------------------- | -------------------------- |
| `home`                 | `/home`                          | HomeScreen                 |
| `login`                | `/login`                         | LoginScreen                |
| `signup`               | `/signup`                        | SignupScreen               |
| `roleSelection`        | `/role-selection`                | RoleSelectionScreen        |
| `profile`              | `/profile`                       | ProfileScreen              |
| `profileEdit`          | `/profile/edit`                  | EditProfileScreen          |
| `calendar`             | `/calendar`                      | CalendarScreen             |
| `calendarUpcoming`     | `/calendar/upcoming`             | UpcomingEventsScreen       |
| `calendarEvent`        | `/calendar/event/:id`            | EventDetailScreen          |
| `calendarEventCreate`  | `/calendar/event/create`         | EventCreationScreen        |
| `calendarEventEdit`    | `/calendar/event/:id/edit`       | EventEditScreen            |
| `gallery`              | `/gallery`                       | GalleryScreen              |
| `galleryFavorites`     | `/gallery/favorites`             | GalleryScreen (Favorites)  |
| `galleryRecent`        | `/gallery/recent`                | GalleryScreen (Recent)     |
| `galleryPhoto`         | `/gallery/photo/:id`             | PhotoDetailScreen          |
| `gamification`         | `/gamification`                  | GamificationScreen         |
| `settings`             | `/settings`                      | SettingsScreen             |
| `babyProfile`          | `/baby-profile`                  | BabyProfileScreen          |
| `babyProfileCreate`    | `/baby-profile/create`           | CreateBabyProfileScreen    |
| `babyProfileEdit`      | `/baby-profile/:id/edit`         | EditBabyProfileScreen      |
| `babyProfileFollowers` | `/baby-profile/followers`        | FollowersManagementScreen  |
| `babyProfileInvite`    | `/baby-profile/followers/invite` | InviteFollowersScreen      |
| `registry`             | `/registry`                      | RegistryScreen             |
| `registryItem`         | `/registry/item/:id`             | RegistryItemDetailScreen   |
| `registryItemCreate`   | `/registry/item/create`          | RegistryItemCreationScreen |
| `registryItemEdit`     | `/registry/item/:id/edit`        | RegistryItemEditScreen     |

---

## Key Files Reference

| File                                                                             | Purpose                                                                                   |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `lib/main.dart`                                                                  | Entry point — initializes Supabase/Firebase/OneSignal, launches with `ProviderScope`      |
| `lib/core/router/app_router.dart`                                                | GoRouter config with all named routes and auth redirect guards                            |
| `lib/core/utils/tile_factory.dart`                                               | Core utility for dynamic tile instantiation from Supabase configs                         |
| `lib/core/utils/tile_loader.dart`                                                | Decoupled utility for fetching tile layout configurations (edge-first strategy)           |
| `lib/features/home/presentation/screens/home_screen.dart`                        | Main screen composing tiles via `TileListView`                                            |
| `lib/core/services/app_initialization_service.dart`                              | Bootstraps all third-party SDKs with graceful degradation                                 |
| `lib/core/di/providers.dart`                                                     | Global Riverpod providers (auth, Supabase)                                                |
| `lib/core/themes/colors.dart`                                                    | App color palette                                                                         |
| `pubspec.yaml`                                                                   | Dependency manifest                                                                       |
| `Makefile`                                                                       | Standard project command runner (CI/CD pipeline, formatting, testing)                     |
| `supabase/migrations/`                                                           | Database migration scripts                                                                |
| `supabase/migrations/20260510000000_add_birth_measurements_to_baby_profiles.sql` | Adds `birth_weight_kg` and `birth_height_cm` columns to `baby_profiles`                   |
| `supabase/seed/06_new_baby_welcome_tile.sql`                                     | Seeds `tile_definitions` + `tile_configs` for `NewBabyWelcomeTile`                        |
| `lib/tiles/new_baby_welcome/providers/new_baby_welcome_provider.dart`            | Riverpod provider for `NewBabyWelcomeTile` — fetches profile, checks 7-day welcome window |
| `lib/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart`                  | Dumb tile widget — birth announcement card                                                |
| `lib/core/models/baby_profile.dart`                                              | Core baby profile model (extended with `birthWeightKg`, `birthHeightCm`)                  |
| `lib/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart`   | Edit profile screen (extended with weight/height input fields)                            |
| `supabase/functions/`                                                            | Serverless Edge Functions (TypeScript/Deno)                                               |

---

## Supabase Database Schema

### Tables

#### User Identity

| Table        | Key Columns                                                                                                            | Purpose                                           |
| ------------ | ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `profiles`   | `user_id` (PK→auth), `display_name`, `avatar_url`, `biometric_enabled`                                                 | Public user profile; auto-created on signup       |
| `user_stats` | `user_id` (PK→auth), `events_attended_count`, `items_purchased_count`, `photos_squished_count`, `comments_added_count` | Engagement counters; auto-incremented by triggers |

#### Baby Profile

| Table                  | Key Columns                                                                                                                                                             | Purpose                                                                         |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `baby_profiles`        | `id`, `name`, `default_last_name_source`, `expected_birth_date`, `actual_birth_date`, `gender`, `profile_photo_url`, `birth_weight_kg`, `birth_height_cm`, `deleted_at` | Core baby record; soft-deleted; birth weight/height added May 2026              |
| `baby_memberships`     | `id`, `baby_profile_id`, `user_id`, `role` (`owner`/`follower`), `relationship_label`, `removed_at`                                                                     | Links users to babies with role; max 2 owners enforced by trigger; soft-removed |
| `invitations`          | `id`, `baby_profile_id`, `invited_by_user_id`, `invitee_email`, `token_hash`, `expires_at`, `status` (`pending`/`accepted`/`revoked`/`expired`)                         | Token-based email invitations to join a baby profile                            |
| `owner_update_markers` | `id`, `baby_profile_id` (UNIQUE), `tiles_last_updated_at`, `reason`                                                                                                     | Timestamp of last content change per baby; drives tile cache invalidation       |

#### Photo Gallery

| Table            | Key Columns                                                                                                         | Purpose                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `photos`         | `id`, `baby_profile_id`, `uploaded_by_user_id`, `storage_path`, `thumbnail_path`, `caption`, `tags[]`, `deleted_at` | Photo uploads; soft-deleted                                          |
| `photo_squishes` | `id`, `photo_id`, `user_id`                                                                                         | "Squish" reactions (like/heart) on photos; unique per user per photo |
| `photo_comments` | `id`, `photo_id`, `user_id`, `body`, `deleted_at`                                                                   | Comments on photos; soft-deleted                                     |
| `photo_tags`     | `id`, `photo_id`, `tag`                                                                                             | Free-form string tags applied to photos                              |

#### Calendar & Events

| Table            | Key Columns                                                                                                                                              | Purpose                                                                   |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `events`         | `id`, `baby_profile_id`, `created_by_user_id`, `title`, `starts_at`, `ends_at`, `description`, `location`, `video_link`, `cover_photo_url`, `deleted_at` | Calendar events; soft-deleted; max 2 per day per baby enforced by trigger |
| `event_comments` | `id`, `event_id`, `user_id`, `body`, `deleted_at`                                                                                                        | Comments on events; soft-deleted                                          |
| `event_rsvps`    | `id`, `event_id`, `user_id`, `status` (`yes`/`no`/`maybe`)                                                                                               | RSVP per user per event; unique constraint                                |

#### Registry

| Table                | Key Columns                                                                                                      | Purpose                                                                               |
| -------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `registry_items`     | `id`, `baby_profile_id`, `created_by_user_id`, `name`, `description`, `link_url`, `priority` (1–5), `deleted_at` | Baby registry wishlist items; soft-deleted                                            |
| `registry_purchases` | `id`, `registry_item_id` (UNIQUE), `purchased_by_user_id`, `purchased_at`, `note`                                | Immutable gift claim purchase record; single-purchase unique key constraint enforced. |

#### Gamification

| Table                   | Key Columns                                                                                                        | Purpose                                                   |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------- |
| `votes`                 | `id`, `baby_profile_id`, `user_id`, `vote_type` (`gender`/`birthdate`), `value_text`, `value_date`, `is_anonymous` | Community predictions on gender or birth date             |
| `name_suggestions`      | `id`, `baby_profile_id`, `user_id`, `suggested_name`, `gender`, `deleted_at`                                       | User-submitted baby name suggestions; soft-deleted        |
| `name_suggestion_likes` | `id`, `name_suggestion_id`, `user_id`                                                                              | Likes on name suggestions; unique per user per suggestion |

#### Notifications

| Table                      | Key Columns                                                                        | Purpose                                          |
| -------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------ |
| `notifications`            | `id`, `recipient_user_id`, `baby_profile_id`, `type`, `payload` (JSONB), `read_at` | In-app notifications; `read_at` null = unread    |
| `notification_preferences` | `user_id` (PK), `push_*` flags, `email_*` flags                                    | Per-user toggle for push and email notifications |

#### Tile System

| Table              | Key Columns                                                                                                           | Purpose                                                     |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `screens`          | `id`, `screen_name` (UNIQUE), `is_active`                                                                             | Registry of app screens that can host tiles                 |
| `tile_definitions` | `id`, `tile_type` (UNIQUE), `description`, `schema_params` (JSONB), `is_active`                                       | Catalog of available tile types with their parameter schema |
| `tile_configs`     | `id`, `screen_id`, `tile_definition_id`, `role` (`owner`/`follower`), `display_order`, `is_visible`, `params` (JSONB) | Per-screen, per-role layout config for each tile            |

#### Activity & App Meta

| Table             | Key Columns                                                         | Purpose                                                           |
| ----------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `activity_events` | `id`, `baby_profile_id`, `actor_user_id`, `type`, `payload` (JSONB) | Audit log of user actions (feed/activity stream)                  |
| `app_versions`    | `id`, `platform`, `minimum_version`, `store_url`, `is_active`       | Minimum required app version per platform for force-update checks |

---

### Storage Buckets

| Bucket                | Visibility    | Max Size | Formats         | Purpose                       |
| --------------------- | ------------- | -------- | --------------- | ----------------------------- |
| `user-avatars`        | Public        | 5 MB     | JPEG, PNG, WebP | User profile photos           |
| `baby-profile-photos` | Public        | 5 MB     | JPEG, PNG, WebP | Baby profile cover photos     |
| `gallery-photos`      | Private (RLS) | 10 MB    | JPEG, PNG       | Family photo gallery uploads  |
| `event-photos`        | Private (RLS) | 10 MB    | JPEG, PNG       | Event cover/attachment photos |

---

### Database Triggers & Functions

#### Auto-maintenance

| Function / Trigger                         | Fires On                                      | Purpose                                                 |
| ------------------------------------------ | --------------------------------------------- | ------------------------------------------------------- |
| `update_updated_at`                        | BEFORE UPDATE on all tables with `updated_at` | Keeps `updated_at` current automatically                |
| `handle_new_user` / `on_auth_user_created` | AFTER INSERT on `auth.users`                  | Auto-creates `profiles` and `user_stats` rows on signup |

#### Content Change Markers

| Function / Trigger                                   | Fires On                                       | Purpose                                                                            |
| ---------------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------- |
| `update_photo_marker` / `photo_marker_trigger`       | AFTER INSERT/UPDATE/DELETE on `photos`         | Updates `owner_update_markers.tiles_last_updated_at` with `reason='photo_updated'` |
| `update_event_marker` / `event_marker_trigger`       | AFTER INSERT/UPDATE/DELETE on `events`         | Same for `reason='event_updated'`                                                  |
| `update_registry_marker` / `registry_marker_trigger` | AFTER INSERT/UPDATE/DELETE on `registry_items` | Same for `reason='registry_updated'`                                               |

#### Business Rule Enforcement

| Function / Trigger                                            | Fires On                                   | Purpose                                                               |
| ------------------------------------------------------------- | ------------------------------------------ | --------------------------------------------------------------------- |
| `enforce_max_two_owners` / `check_max_owners`                 | BEFORE INSERT/UPDATE on `baby_memberships` | Raises exception if a 3rd owner is added to a baby profile            |
| `enforce_max_two_events_per_day` / `check_max_events_per_day` | BEFORE INSERT/UPDATE on `events`           | Raises exception if >2 events exist for the same baby on the same day |

#### User Stat Counters

| Function / Trigger                                      | Fires On                             | Purpose                                                      |
| ------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------ |
| `increment_events_attended` / `count_event_rsvp`        | AFTER INSERT/UPDATE on `event_rsvps` | +1 to `events_attended_count` when RSVP status becomes `yes` |
| `increment_items_purchased` / `count_registry_purchase` | AFTER INSERT on `registry_purchases` | +1 to `items_purchased_count`                                |
| `increment_photos_squished` / `count_photo_squish`      | AFTER INSERT on `photo_squishes`     | +1 to `photos_squished_count`                                |
| `increment_comments_added` / `count_photo_comment`      | AFTER INSERT on `photo_comments`     | +1 to `comments_added_count`                                 |

#### RLS Helper Functions (SECURITY DEFINER)

These break circular RLS dependencies and are used inside row-level security
policies:

| Function                                             | Purpose                                                                           |
| ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| `is_baby_member(user_id, baby_profile_id)`           | Returns true if user has an active (non-removed) membership                       |
| `is_baby_owner(user_id, baby_profile_id)`            | Returns true if user is an active owner                                           |
| `is_photo_member(user_id, photo_id)`                 | Returns true if user is a member of the baby profile the photo belongs to         |
| `is_photo_owner(user_id, photo_id)`                  | Returns true if user is an owner for the baby profile the photo belongs to        |
| `is_event_member(user_id, event_id)`                 | Returns true if user is a member of the baby profile the event belongs to         |
| `is_registry_item_member(user_id, registry_item_id)` | Returns true if user is a member of the baby profile the registry item belongs to |

---

### Edge Functions (Supabase/Deno)

All **6 Edge Functions** are actively implemented in the Deno backend
environment:

| Function                 | Status      | Purpose                                                                                                                                                                                                                                              |
| ------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tile-configs`           | Implemented | Accepts `{babyProfileId, userRole, screenName}`. Returns screen-scoped, role-scoped rows from `tile_configs` joined with `screens` and `tile_definitions`. Applies Visibilities filters (`hideWhenEmpty`). Consumed directly by client `TileLoader`. |
| `notification-trigger`   | Implemented | Accepts `{recipientUserId, notificationType, title, message, data, babyProfileId}`. Inserts into `notifications` table then delivers push via OneSignal API.                                                                                         |
| `image-processing`       | Implemented | Accepts `{imageUrl, bucketName, filePath, operations}`. Handles metadata dimension extractions and EXIF evaluations.                                                                                                                                 |
| `send-invitation-email`  | Implemented | Dispatches follower invitations externally. Integrates dynamically with **Resend API** and **SendGrid API** using authorization secrets.                                                                                                             |
| `send-push-notification` | Implemented | Direct push dispatcher. Connects directly to **OneSignal REST API** via `ONESIGNAL_APP_ID` + `ONESIGNAL_REST_API_KEY` (features mock fallback on missing credentials).                                                                               |
| `generate-thumbnail`     | Implemented | Real server-side thumbnail generation using `imagescript` WASM. Downloads original image from Storage, cover-resizes to 300×300 JPEG (quality 80), uploads `_thumb.jpg` sibling, and writes `thumbnail_path` to the `photos` DB row under `SUPABASE_SERVICE_ROLE_KEY`. Idempotent via `upsert: true`.                                                                                               |

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
