# Nonna App — Project Understanding

**Document Version**: 1.1
**Created**: April 28, 2026
**Last Updated**: May 4, 2026
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
│   └── ... (18 total)
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

## Tile Widgets (18 total)

| Tile | Screens Used |
|---|---|
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
- Added owner-facing follower management routes and screens:
  - `/baby-profile/followers`
  - `/baby-profile/followers/invite`
- Home app bar actions have been consolidated into a single, cleaner PopupMenuButton containing:
  - `Create Baby Profile`
  - `Baby Profile Info`
  - Owner-only `Manage Followers`
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
- All 18 tile widgets with providers and widget tests
- All feature screens (auth, home, calendar, gallery, registry, profile, baby profile, gamification, settings)
- GoRouter navigation with auth redirect guards
- Supabase RLS policies with pgTAP test suite
- Supabase Edge Functions: `tile-configs`, `notification-trigger`, `image-processing`
- Localization (English + Spanish)
- Theming, error boundaries, offline cache and network failure handling
- **Centralized `TileFactory`** — dynamic tile instantiation from Supabase `tile_configs`/`screen_configs` tables mapped to all 18 tile components.

### Pending (Production Readiness Checklist)
- Implement `ConsumerStatefulWidget` smart wrappers for remaining tiles inside `TileFactory`.
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
| `baby_profiles` | `id`, `name`, `expected_birth_date`, `actual_birth_date`, `gender`, `profile_photo_url`, `created_by`, `deleted_at` | Core baby record; soft-deleted; `created_by` allows creator access before membership is set |
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
supabase login
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
