# Nonna App - Architecture and Workflow Reference

**Document Version**: 3.0
**Last Updated**: May 25, 2026
**Location**: `docs/99_master_reference_docs/Nonna_Architecture_and_Workflow_Reference.md`
**Status**: Living Document - Fully updated with Version 3.0 standards and unified codebase specifications

## Purpose
This document is the fast, implementation-aligned reference for agents and developers who need to understand how the Nonna app works end-to-end before making changes.

Use this document to answer:
- How the app boots and routes users.
- How tile-driven screens are configured and rendered.
- How Riverpod state, Supabase data, and role-based access interact.
- Which files to read first for each kind of change.

## Source-of-Truth Priority
When details conflict, use this order:
1. **[Highest]** Live code in `lib/` and `supabase/`
2. `docs/99_master_reference_docs/Database_Schema_and_Functions.md`
3. `docs/99_master_reference_docs/App_Structure_Nonna.md`
4. This file
5. Other docs

---

## App At A Glance
- **Product**: Private baby milestone tracking and family sharing app.
- **Roles**: `owner` and `follower` (users can be dual-role, resolved per baby profile).
- **Frontend**: Flutter + Material 3.
- **State**: Riverpod v3 (Notifier pattern).
- **Routing**: GoRouter v17 with auth redirects and tabbed shell navigation (StatefulShellRoute indexed stacks).
- **Backend**: Supabase Auth + Postgres + Realtime + Storage + Edge Functions.
- **Cache**: Hive + SharedPreferences via service layer.
- **Command Runner**: Unified targets mapped in root `Makefile`.

---

## Recent Implementation Updates (May 2026)
- **Consolidated Home App Bar**: Consolidated create-profile, baby info, and owner-only manage-followers actions into a single PopupMenuButton to reduce visual clutter.
- **Fullscreen Follower Routes**: Added `FollowersManagementScreen` (`/baby-profile/followers`) and `InviteFollowersScreen` (`/baby-profile/followers/invite`) outside the shell navigator.
- **Dynamic Typography**: Integrated 11 premium Google Fonts (e.g., Plus Jakarta Sans, Inter, Montserrat) selectable globally from the Settings screen.
- **Owner Gift Override**: Updated registry business logic and RLS policies to allow baby profile owners to unmark/delete ANY registry purchase on their baby's profile, regardless of who bought it.
- **Auto-Selection**: Baby profile creation now auto-selects the new profile and switches Home to owner role context.
- **Hardened Sign-Out**: Wipes OneSignal and Firebase identities clean before executing Supabase sign-out to prevent credential crossover.

---

## Core Architectural Pattern: Dynamic Tile Engine

The app composes major screens (Home, Gallery, Calendar, Registry, Fun) using tile configurations loaded dynamically.

### Runtime Loader Pipeline:
1. Screen/provider requests tile configs for `{screenName, role, babyProfileId}`.
2. `TileLoader.loadForScreen()` triggers an **Edge-First caching query**:
   * Checks Hive local cache prefix `tile_configs_v3`. If valid and not `forceRefresh`, returns cached JSON.
   * If cache misses, invokes Supabase Edge Function `tile-configs`.
   * If Edge function fails or times out, falls back to direct database inner joins on `tile_configs` + `screens` + `tile_definitions`.
3. Screen state stores `List<TileConfig>`.
4. `TileListView` iterates through loaded tile configs.
5. `TileFactory.buildTile()` maps the configuration's `componentName` to the appropriate smart tile wrapper.
6. The Smart Tile Wrapper watches its active Riverpod provider, fetches data (reacting dynamically to `selectedBabyProfileProvider`), and renders the static, presentational tile widget.

*Note on Visibility*: Content-aware hiding is enforced server-side via `tile-configs` Edge Function based on per-tile empty probes and the `tile_configs.params.hideWhenEmpty` rule.

---

## Startup Workflow

### Primary Files:
- `lib/main.dart` - Entrypoint initializing bindings and loading initial views.
- `lib/core/services/app_initialization_service.dart` - Sequences Supabase connectivity, Hive initialization, OneSignal push setup, and Firebase trackers.
- `lib/core/di/providers.dart` - Dependency injection gateway for core services.
- `lib/core/router/app_router.dart` - Standardized paths, branch Navigator keys, and GoRouter settings.

### Sequence:
1. `main()` initializes Flutter bindings and hooks up Sentry/observability error boundaries.
2. `AppInitializationService.initialize()` connects to Supabase, local storage, and initializes 3rd party SDKs in parallel (fail-open policy).
3. If initialization succeeds, the app runs inside `ProviderScope` and mounts `MyApp`.
4. `MyApp` watches `appInitializationProvider`.
5. `MaterialApp.router` is created via `routerProvider`.
6. GoRouter refresh listenable watches `isAuthenticatedProvider` to trigger `RouteGuards.authRedirect` redirect evaluations.

---

## Navigation & GoRouter Shell Model

### Routing Structure:
* **Outside the Shell**:
  * Auth screens: `/login`, `/signup`, `/role-selection`
  * Fullscreen screens (parentNavigatorKey = root): `/profile`, `/profile/edit`, `/settings`, `/baby-profile`, `/baby-profile/create`, `/baby-profile/:id/edit`, `/baby-profile/followers`, `/baby-profile/followers/invite`
  * Complex actions escaping parent nav bar: `/gallery/photo/detail`, `/calendar/event/create`, `/calendar/event/edit`, `/registry/item/create`, `/registry/item/edit`
* **Inside the Stateful Shell (5 branches)**:
  * **Branch 0 (Home)**: `/home` rendering dynamic home tiles.
  * **Branch 1 (Gallery)**: `/gallery` rendering photo grids (with sub-routes `/favorites` and `/recent`).
  * **Branch 2 (Calendar)**: `/calendar` rendering calendar views (with sub-route `/upcoming` and nested `/event/detail`).
  * **Branch 3 (Registry)**: `/registry` rendering registry filters (with nested `/item/detail`).
  * **Branch 4 (Fun)**: `/gamification` rendering follower voting predictions and name suggestions.

---

## Roles and Access Model

### User Association Roles:
- **`owner`**: Full create/edit privileges (CRUD) for their baby profile. Can invite/revoke followers, delete registry purchases, edit baby info, and see owner-only tiles (`Checklist`, `StorageUsage`, `InvitesStatus`, `NewFollowers`).
- **`follower`**: Read-only access with interactive integrations. Can squish photos, post comments, RSVP to scheduled events, submit predictions/names, mark registry items as purchased, and see follower-only tiles (`RsvpTasks`, `RegistryList`).

*Note on Dual-Role*: Users can be dual-role (an owner of Baby A and a follower of Baby B). Home screen dynamically switches tile configurations and FAB visibility based on the selected baby profile's membership (`currentUserRoleForBabyProfileProvider`).

---

## State Management Model (Riverpod)

### Dependency Injection Layers:
* **Core Providers**: Database clients, Auth handles, persistence storage, cache manager.
* **Context Provider**: `selectedBabyProfileProvider` tracks the active baby profile ID (reloading all subscribed tiles).
* **Screen Providers**: `homeScreenProvider`, `galleryScreenProvider`, `calendarScreenProvider`, `registryScreenProvider` orchestrate screen-specific configurations.
* **Tile Providers**: Specialized providers (e.g., `recentPhotosProvider`, `upcomingEventsProvider`) manage data queries, Hive local caches, and Supabase Realtime subscriptions.

---

## Data Access Rules and Abstractions

### Architecture Guidelines:
* **Omission of Redundant Repositories**: The `lib/core/repositories/interfaces` directory remains empty. Instead, providers query database and client endpoints directly via **DatabaseService** and core models, avoiding boilerplate code.
* **Standardized Table References**: Table and column names must utilize the string constraints inside **SupabaseTables** constants (`lib/core/constants/supabase_tables.dart`).
* **Direct Service Invocations**: Data fetching must map through the specialized core services.

---

## Inventory Baseline

* **Domain Models**: **23** active domain models under `lib/core/models/`.
* **Shared Services**: **22** active shared services under `lib/core/services/` (managing backup, sync, error boundaries, push channels, and storage).
* **Tile Component Folders**: **20** subdirectories inside `lib/tiles/` (including `core` infrastructure, **18 functional smart tiles**, and the deprecated `registry_deals` folder).

---

## Local Development and CI/CD Guidelines

Standard workflows are consolidated into the project **[Makefile](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/Makefile)**. Do not execute custom scripts:

### Standard Command References:
* Initialize dependencies: `make deps`
* compiler analysis: `make analyze`
* Apply lint fixes: `make lint-fix`
* Format code: `make format`
* Run test suites: `make test`
* Update test reporting: `make test-all`
* Automated Emulator integration tests: `make test-integration`
* Build Android APK release: `make build-android`
* Build iOS Simulator release: `make build-ios`

---

## Key Risks and Gotchas
- **Deleted Records**: Most entities are soft-deleted via `deleted_at`; queries must filter out non-null deleted markers.
- **Realtime Leak Prevention**: Always hook up realtime streams utilizing the `RealtimeSubscriptionManager` inside providers to automatically cancel active subscriptions when the provider is disposed.
- **Empty Placeholders**: Do not add data/domain layers inside feature folders (`lib/features/`). Keep features presentation-focused; delegate database operations to core services or smart tile layers.

---

## Quick File Map For Developers
* Boot sequence & App launch: `lib/main.dart` -> `lib/core/services/app_initialization_service.dart`
* Router and navigation stacks: `lib/core/router/app_router.dart`
* Global dependency injections: `lib/core/di/providers.dart`
* Decoupled configuration load: `lib/core/utils/tile_loader.dart`
* Screen dynamic composition: `lib/core/utils/tile_factory.dart`
* Database connector and tables: `lib/core/services/database_service.dart` -> `lib/core/constants/supabase_tables.dart`

---

## Related Master Docs
- `docs/99_master_reference_docs/Database_Schema_and_Functions.md`
- `docs/99_master_reference_docs/App_Structure_Nonna.md`
- `docs/99_master_reference_docs/Nonna_App_Architecture_Diagrams.md`

---

## Test Login Credentials (Automated Integration Checks)
* **Email**: `testuser_nonna@example.com`
* **Password**: `Password123!`