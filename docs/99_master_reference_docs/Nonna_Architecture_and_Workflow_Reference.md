# Nonna App - Architecture and Workflow Reference

## Purpose
This document is the fast, implementation-aligned reference for agents and developers who need to understand how the Nonna app works end-to-end before making changes.

Use this document to answer:
- How the app boots and routes users
- How tile-driven screens are configured and rendered
- How Riverpod state, Supabase data, and role-based access interact
- Which files to read first for each kind of change

## Source-of-Truth Priority
When details conflict, use this order:
1. [Highest] Live code in `lib/` and `supabase/`
2. `docs/99_master_reference_docs/Nonna_Project_Understanding.md`
3. This file
4. Other docs

## App At A Glance
- Product: Private baby milestone tracking and family sharing app
- Roles: `owner` and `follower` (users can be dual-role)
- Frontend: Flutter + Material 3
- State: Riverpod v3 (Notifier pattern)
- Routing: GoRouter v17 with auth redirects and tabbed shell navigation
- Backend: Supabase Auth + Postgres + Realtime + Storage + Edge Functions
- Cache: Hive + SharedPreferences via service layer

## Recent Implementation Updates (May 2026)
- Added full-screen follower-management routes:
  - `/baby-profile/followers`
  - `/baby-profile/followers/invite`
- Home app bar actions (create-profile, baby info, and owner-only manage-followers) have been consolidated into a single PopupMenuButton to reduce visual clutter.
- Dynamic typography was added, allowing users to switch between 11 premium Google Fonts (e.g., Plus Jakarta Sans, Inter, Montserrat) globally from the settings screen.
- Registry business logic and RLS policies were updated to allow baby profile owners to unmark/delete ANY registry purchase, not just their own.
- Baby profile creation now auto-selects the new profile and switches Home to owner role context.
- Registry role/fab visibility now resolves from live membership (`currentUserRoleForBabyProfileProvider`) for the selected profile.
- Invitation flow is currently email-only in-app (`invitee_email`), with owner-only revoke support.
- Sign-out/session handling was hardened to clear OneSignal/Firebase identities before Supabase sign-out.

## Core Architectural Pattern: Dynamic Tile Engine
The app composes major screens using tile configurations loaded from Supabase tables.

Runtime flow:
1. Screen/provider requests tile configs for screen + role.
2. `TileLoader.loadForScreen()` calls Supabase Edge Function `tile-configs` with `{babyProfileId, userRole, screenName}`.
3. Edge response is cached per `{babyProfileId, screenId, role}` and locally filtered/sorted.
4. If edge invocation fails, `TileLoader` falls back to direct `tile_configs` join query (`screens` + `tile_definitions`).
5. Screen state stores `List<TileConfig>`.
6. `TileListView` iterates through tile configs.
7. `TileFactory.buildTile()` maps `componentName` to smart tile wrapper.
8. Smart tile wrapper reads the relevant Riverpod provider and renders a presentational tile widget.

Important implementation note:
- `tile-configs` is now part of the primary runtime path for tile loading (edge-first with DB fallback).
- Content-aware hiding is enforced server-side per tile type and tile params (`hideWhenEmpty`).

## Startup Workflow
Primary files:
- `lib/main.dart`
- `lib/core/services/app_initialization_service.dart`
- `lib/core/di/providers.dart`
- `lib/core/router/app_router.dart`

Boot sequence:
1. `main()` initializes Flutter bindings.
2. `AppInitializationService.initialize()` initializes Supabase/Firebase/OneSignal and related integrations.
3. App starts inside `ProviderScope` when critical initialization succeeds.
4. `MyApp` waits on `appInitializationProvider`.
5. `MaterialApp.router` is created with `routerProvider`.
6. `GoRouter` applies auth redirects via `RouteGuards.authRedirect`.

## Navigation and Screen Shell Model
Primary file:
- `lib/core/router/app_router.dart`

Structure:
- Auth and full-screen routes live outside shell.
- Main app uses `StatefulShellRoute.indexedStack` with 5 persistent branches:
  - Home
  - Gallery
  - Calendar
  - Registry
  - Fun (Gamification)
- Each branch has its own navigator key and stack state.
- Additional full-screen owner flows are routed outside shell for profile collaboration:
  - Follower management (`/baby-profile/followers`)
  - Invitation composer (`/baby-profile/followers/invite`)

Auth behavior:
- Unauthenticated access to protected routes redirects to `/login`.
- Authenticated users on auth screens redirect to `/home`.

## Roles and Access Model
Role meaning:
- `owner`: full create/edit privileges for their baby profile scope
- `follower`: read-only/limited interaction for followed profiles

Key behavior:
- Home can show role toggle for dual-role users.
- Feature screens often infer role from provider state when not passed explicitly.
- Route guards support role-based restrictions where configured.

## State Management Model (Riverpod)
Global providers (core DI):
- Supabase client, auth, database, cache, realtime, storage, analytics, observability
- Selected baby profile state via `selectedBabyProfileProvider`

Feature providers:
- `homeScreenProvider`
- `galleryScreenProvider`
- `calendarScreenProvider`
- `registryScreenProvider`

Pattern used broadly:
1. Provider receives baby profile + role context.
2. Provider loads cached data first when available.
3. Provider refreshes from database.
4. Provider updates state and optional cache.
5. Provider may subscribe to realtime updates and reconcile state.

## Data Access Rules and Abstractions
Primary files:
- `lib/core/services/database_service.dart`
- `lib/core/constants/supabase_tables.dart`

Implementation rules:
- Database operations should go through `DatabaseService`.
- Table/column names should come from `SupabaseTables` constants.
- Auth/session handling is managed via auth service/providers.

## Home Screen Workflow (Reference Path)
Primary files:
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/providers/home_screen_provider.dart`
- `lib/features/home/presentation/widgets/tile_list_view.dart`
- `lib/core/utils/tile_loader.dart`
- `lib/core/utils/tile_factory.dart`

Detailed flow:
1. Home screen attempts to resolve selected baby profile and role.
2. If no selected profile exists, provider auto-selects first membership profile.
3. Provider loads tile configs for screen `home` using `TileLoader`.
4. Tile list renders loading/error/empty/content states.
5. Each tile is instantiated through `TileFactory`.
6. Smart wrappers fetch tile-specific data and react to baby profile changes.

## Smart Tile Wrapper Pattern
Smart wrappers are `ConsumerStatefulWidget` classes inside `tile_factory.dart`.

Expected behavior:
1. In `initState`, fetch initial tile data once context is ready.
2. Listen for `selectedBabyProfileProvider` changes.
3. Re-fetch on profile change.
4. Pass final state to presentational tile widget.

Current tile mapping is implemented for all primary tile types listed in project docs.

## Feature Workflow Snapshots
Calendar:
- Loads tile configs for `calendar` screen.
- Loads and groups events by date.
- Uses realtime subscription to keep events synchronized.

Registry:
- Loads tile configs for `registry` screen.
- Loads registry items and purchase status.
- Applies filter/sort in state.
- Uses realtime subscriptions for items and purchases.

Gallery:
- Loads tile configs by gallery variant screen id (`gallery`, `gallery_favorites`, `gallery_recent`).
- Refreshes per screen scope and role.

## Backend Architecture Snapshot
Database groups:
- User: `profiles`, `user_stats`
- Baby and access: `baby_profiles`, `baby_memberships`, `invitations`, `owner_update_markers`
- Photos: `photos`, `photo_squishes`, `photo_comments`, `photo_tags`
- Calendar: `events`, `event_rsvps`, `event_comments`
- Registry: `registry_items`, `registry_purchases`
- Gamification: `votes`, `name_suggestions`, `name_suggestion_likes`
- Notifications: `notifications`, `notification_preferences`
- Tile system: `screens`, `tile_definitions`, `tile_configs`
- Activity/meta: `activity_events`, `app_versions`

Invitation model note:
- The active invitation schema in app code uses email-based invitations (`invitee_email`) with token/status lifecycle (`pending`, `accepted`, `revoked`, `expired`).

Edge Functions (documented):
- Implemented: `tile-configs`, `notification-trigger`, `image-processing`
- Stubs/placeholders: `send-invitation-email`, `send-push-notification`, `generate-thumbnail`

## Inventory Baseline (Current)
- Domain models: 23 (`lib/core/models/`)
- Services: 22 (`lib/core/services/`)
- Tile directories: 19 total in `lib/tiles/` including shared `core`; 18 functional tile feature directories

## Key Risks and Gotchas
- Doc/code drift may exist around table names, role labels, and edge-function usage paths.
- `TileLoader` and `TileFactory` are intentionally separate responsibilities; do not merge concerns.
- Many entities are soft-deleted via `deleted_at`; queries must filter appropriately.
- Screen-level providers can hold both domain and tile state; verify both paths when debugging.
- Profile context (`selectedBabyProfileProvider`) drives many reloads across tiles and screens.

## Change Impact Checklist (Before Any Code Edit)
1. Identify affected feature provider(s), tile provider(s), and smart wrapper(s).
2. Trace route entry points and role-based behavior for the impacted feature.
3. Verify database table/column constants and model serialization expectations.
4. Review cache keys/TTL effects and realtime subscription behavior.
5. Check cross-screen reuse of the same tile/widget/provider.
6. Run relevant tests and a build before finalizing.

## Validation Commands
Use these as baseline checks after meaningful changes:
- `flutter test`
- `flutter analyze`
- `flutter build apk --release`

## Quick File Map For Agents
Start here for app-wide understanding:
- `lib/main.dart`
- `lib/core/router/app_router.dart`
- `lib/core/di/providers.dart`
- `lib/core/services/database_service.dart`
- `lib/core/constants/supabase_tables.dart`
- `lib/core/utils/tile_loader.dart`
- `lib/core/utils/tile_factory.dart`
- `lib/features/home/presentation/providers/home_screen_provider.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/calendar/presentation/providers/calendar_screen_provider.dart`
- `lib/features/gallery/presentation/providers/gallery_screen_provider.dart`
- `lib/features/registry/presentation/providers/registry_screen_provider.dart`

## Related Master Docs
- `docs/99_master_reference_docs/Nonna_Project_Understanding.md`
- `docs/99_master_reference_docs/Database_Schema_and_Functions.md`

---
# Test Login Credentials for automated testing

Email: testuser_nonna@example.com
Password: Password123!