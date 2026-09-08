# Nonna App Project Structure (Dynamic Tile-Based Architecture)

**Document Version**: 3.1
**Last Updated**: September 8, 2026
**Location**: `docs/99_master_reference_docs/App_Structure_Nonna.md`
**Status**: Living Document - Updated to reflect the current unified codebase implementation

This structure is optimized for the Nonna app's dynamic, tile-based UI with role-driven content, Supabase backend, and support for owner/follower aggregation. Tiles are parameterized, reusable widgets placed at the top level (`lib/tiles/`) for maximum reusability across screens, while screen features (`lib/features/`) are streamlined to handle presentation-layer orchestration, screens, and state providers, leveraging global services and dynamic tiles to fetch and persist data.

## Current Implementation Status

**IMPORTANT**: All core infrastructure, tiles layer, and features layer are fully implemented.

### Current State (As of September 8, 2026)
- **18 Active Smart Tiles**: Fully implemented, tested, and integrated via a centralized `TileFactory` which resolves runtime configs.
- **Prototype onboarding feature**: `lib/features/onboarding/presentation/` — owner/follower/co-owner first-run flows with coordinator persistence and isolated `OnboardingTheme`.
- **Centralized Service Architecture**: The app leverages a robust, unified service layer under `lib/core/services/` (22 services) and domain models (23 models).
- **Streamlined Feature Layer**: Features under `lib/features/` are ultra-lean and presentation-focused, composing tiles and rendering screen widgets. Redundant repository and use case files have been omitted in favor of direct service and Riverpod state provider interactions.
- **Command Runner Interface**: Standard commands are managed via a centralized `Makefile` at the root of the project, including mock generation, test execution, linting, formatting, and build processes.

### Recent Implementation Notes (September 2026)
- Added `lib/features/onboarding/presentation/` — screens, providers, widgets, utils for prototype onboarding (no separate data/domain layer).
- Added `lib/core/themes/onboarding_theme.dart` and `lib/core/constants/first_moment_presets.dart`.
- `route_guards.dart` + `onboardingCoordinatorProvider` gate access to `/home` until onboarding complete.
- `/role-selection` deprecated; redirects to `/onboarding/owner/carousel`.

### Recent Implementation Notes (May 2026)
- Added owner collaboration flows in baby profile feature:
  - `FollowersManagementScreen` at `/baby-profile/followers`
  - `InviteFollowersScreen` at `/baby-profile/followers/invite`
- Home app bar actions (`add`, `info`, `followers`) have been consolidated into a cleaner PopupMenuButton.
- Added dynamic typography, allowing users to choose from 11 top mobile fonts via the Settings screen.
- Registry business logic and RLS policies updated to allow baby profile owners to delete any registry purchase.
- Invitation workflow is email-only in current app implementation.
- New profile creation now auto-selects the new profile and refreshes home/profile context.
- Auth sign-out flow now clears external service user identities before Supabase sign-out.

---

## Directory Tree

```
nonna_app/
├── lib/
│   ├── core/                     # Shared across the entire app
│   │   ├── config/               # Environment configurations
│   │   ├── constants/            # App-wide constants (strings, table names, limits, first_moment_presets)
│   │   ├── contracts/            # Shared interfaces and behaviors (realtime, caching)
│   │   ├── di/                   # Dependency injection (Riverpod providers)
│   │   ├── enums/                # Global enums (UserRole, TileType, ScreenName, etc.)
│   │   ├── examples/             # Example implementations
│   │   ├── exceptions/           # Custom exception classes (network, permission, app)
│   │   ├── extensions/           # Dart/Flutter extensions
│   │   ├── middleware/           # App-level middleware (caching, error, RLS validators)
│   │   ├── mixins/               # Reusable widget behaviors
│   │   ├── models/               # 23 shared domain models
│   │   ├── navigation/           # Context-free navigation service
│   │   ├── network/              # Supabase client, interceptors, and endpoints
│   │   ├── providers/            # Global providers
│   │   ├── repositories/         # [Omitted] Handled directly via Core Services & Providers
│   │   ├── router/               # App navigation (GoRouter & Route guards)
│   │   ├── services/             # 22 shared services (auth, database, caching, realtime, etc.)
│   │   ├── themes/               # App-wide theming + onboarding_theme.dart (isolated prototype palette)
│   │   ├── typedefs/             # Type aliases
│   │   ├── utils/                # Helper functions (dates, formats, role checks)
│   │   └── widgets/              # Shared UI widgets (shimmers, error views, custom buttons)
│   ├── features/                 # Streamlined, presentation-focused feature modules
│   │   ├── auth/                 # Authentication presentation (login, signup, role screens)
│   │   ├── baby_profile/         # Baby profile management (create, edit, follower list, invite)
│   │   ├── calendar/             # Calendar screen & calendar view widget
│   │   ├── fun/                  # Legacy/Placeholder feature
│   │   ├── gallery/              # Photo gallery presentation (grid, photo detail screen)
│   │   ├── gamification/         # Name suggestions & predictions screen
│   │   ├── home/                 # Home screen layout (composes tiles via TileFactory)
│   │   ├── onboarding/           # Prototype first-run flows (presentation-only)
│   │   │   └── presentation/
│   │   │       ├── providers/    # coordinator, routes, types, first_run_home
│   │   │       ├── screens/      # owner / follower / coowner / shared
│   │   │       ├── widgets/      # scaffold, carousel, fields, invite rows
│   │   │       ├── utils/        # auth, invite, baby, analytics helpers
│   │   │       └── l10n/         # onboarding string helpers
│   │   ├── photo_gallery/        # Placeholder/Refactoring feature
│   │   ├── profile/              # User profile screens (view, edit)
│   │   ├── registry/             # Registry presentation (filters, list view, item details)
│   │   └── settings/             # App settings (typography selectors, configuration)
│   ├── flutter_gen/              # Generated assets & localization code
│   ├── l10n/                     # Localization
│   │   ├── app_en.arb
│   │   ├── app_es.arb
│   │   └── l10n.dart
│   ├── main.dart                 # App entry point & initialization
│   └── tiles/                    # 18 reusable, parameterized smart tiles
│       ├── activity_list/        # Engagement recap/recap card tile
│       ├── checklist/            # Onboarding checklist tile
│       ├── core/                 # Shared tile infrastructure (base tile, containers)
│       ├── countdown/            # Baby due date countdown tile
│       ├── gallery_favorites/    # Gallery favorites tile
│       ├── invites_status/       # Followers invitation status tile
│       ├── name_suggestions/     # Baby name suggestion tile
│       ├── new_baby_welcome/     # New baby welcome banner tile
│       ├── new_followers/        # New followers list tile
│       ├── notifications/        # Social & system notification tile
│       ├── prediction_votes/     # Baby prediction voting tile
│       ├── recent_photos/        # Recent photos grid tile
│       ├── recent_purchases/     # Recent purchases list tile
│       ├── registry_highlights/  # Featured registry items tile
│       ├── registry_list/        # Full registry list tile
│       ├── rsvp_tasks/           # Events requiring RSVP tile
│       ├── storage_usage/        # Photo storage allocation tile
│       ├── system_announcements/ # Global system announcements tile
│       └── upcoming_events/      # Upcoming calendar events tile
├── test/                         # Comprehensive unit, widget, and mock tests
│   ├── core/                     # Core layer tests (models, services, utils)
│   ├── features/                 # Screen-composition & screen provider tests
│   │   └── onboarding/           # Coordinator, helpers, deep-link unit tests
│   ├── tiles/                    # Isolated smart tile data & UI tests
│   └── mocks/                    # Centralized mock definitions (SupaClient, services)
├── automated_tests/              # Test reporting scripts and summary configurations
├── supabase/                     # Supabase schema definitions, edge functions, migrations
├── scripts/                      # DB utilities, l10n setup, test user generation scripts
├── Makefile                      # Principal local command runner (deps, tests, linting, builds)
├── run_tests.sh                  # Shell script for running tests
├── run_all_tests.sh              # Shell script for comprehensive test suites
├── run_integration_tests.sh      # Shell script for managing simulators & integration tests
└── pubspec.yaml                  # Flutter package dependencies
```

---

## Core Architecture Walkthrough

### 1. Reusable Smart Tiles (`lib/tiles/`)
Tiles are first-class citizens in the Nonna app. Each tile is self-contained and encapsulates its own layout, presentation widgets, and Riverpod state controllers.
* **Smart Wrappers**: Kept inside `lib/core/utils/tile_factory.dart`. They capture global providers (like `selectedBabyProfileProvider` or `currentUserProvider`), watch for changes, fetch fresh data via their respective providers, and delegate presentation rendering to the static tile widget.
* **Role-Based Flexibility**: Tiles parameterize queries according to the user's role:
  * **Owners**: Queries target data specific to their baby (e.g., `baby_id = ?`). Editable controls and interactive options are shown.
  * **Followers**: Queries aggregate data across multiple babies (e.g., `baby_id IN (...)` mapped from followed babies). They see structured read-only representations.
* **Dynamic Configuration**: Screens fetch tile configurations (`tile_configs` table) and placement orders from Supabase. The `TileFactory` parses the results and constructs the UI at runtime, allowing updates without redeploying the app.

### 2. Core Shared Infrastructure (`lib/core/`)

#### Shared Domain Models (`lib/core/models/`)
The app utilizes **23 core domain models** to maintain strict type safety across database operations and UI layouts:
1. `user.dart` - App user representation
2. `baby_profile.dart` - Baby milestone details
3. `baby_membership.dart` - User associations with baby profiles
4. `invitation.dart` - Follower invite structure
5. `event.dart` - Calendar events
6. `event_rsvp.dart` - Event RSVPs
7. `event_comment.dart` - Comments on events
8. `photo.dart` - Uploaded photo metadata
9. `photo_tag.dart` - Baby tags in photos
10. `photo_comment.dart` - Comments on photos
11. `photo_squish.dart` - Like/Squish engagements
12. `registry_item.dart` - Baby registry products
13. `registry_purchase.dart` - Purchase tracking data
14. `notification.dart` - App social notifications
15. `system_announcement.dart` - Global push banners
16. `activity_event.dart` - Logged baby activity metrics
17. `name_suggestion.dart` - Baby name ideation entries
18. `name_suggestion_like.dart` - Voting likes on name suggestions
19. `vote.dart` - Predictions votes
20. `user_stats.dart` - Social engagements statistics
21. `owner_update_marker.dart` - Realtime sync markers
22. `tile_config.dart` - Dynamic tile layout configuration
23. `screen_config.dart` - Screen mapping coordinates

#### Shared Services (`lib/core/services/`)
Data persistence, remote endpoints connectivity, and operational logic are managed via **22 modular core services**:
1. `supabase_service.dart` - Low-level wrapper for Supabase client operations
2. `database_service.dart` - Safe database execution, table queries, and error parsing
3. `auth_service.dart` - Supabase email/password and social login gateway
4. `local_storage_service.dart` - Key-value offline secure preferences (SharedPreferences)
5. `cache_service.dart` - Hive caching layer for domain entities
6. `offline_cache_manager.dart` - Lifecycle and synchronization operations for offline caching
7. `persistence_strategies.dart` - Cache eviction, TTL, and cache-first lookup rules
8. `sync_manager.dart` - Bidirectional synchronization queue for offline edits
9. `realtime_service.dart` - Realtime stream management for table events
10. `realtime_subscription_manager.dart` - Prevents connection leaks by safely binding streams to provider states
11. `storage_service.dart` - Uploads/downloads with Supabase Storage buckets
12. `notification_service.dart` - OneSignal and local device notification integrations
13. `analytics_service.dart` - Performance measurement and user interaction hooks
14. `observability_service.dart` - Sentry-like monitoring and app telemetry logs
15. `force_update_service.dart` - Semantic version checks for mandatory client updates
16. `app_initialization_service.dart` - Sequence loader for storage, configs, and authentication on launch
17. `network_error_handler.dart` - Standardized retry limits and socket exception translation
18. `crash_recovery_handler.dart` - Safe fallback UI restoration when the widget tree breaks
19. `data_deletion_handler.dart` - Completely clears database tables and local storage nodes
20. `data_export_handler.dart` - Packages personal data into secure zip/json downloads for user export requests
21. `state_persistence_manager.dart` - Handles automatic Riverpod state saving during background suspension
22. `backup_service.dart` - Manages automated triggers to back up local database state offline

#### Omission of Redundant Repositories
The codebase bypasses the traditional repository abstraction layer (`lib/core/repositories/interfaces` remains empty in practice). Instead, the app uses a clean, modern Riverpod state-management pattern. Screen controllers and smart tiles fetch data directly through their data sources and providers, querying the core database services directly. This eliminates boilerplate, improves readability, and makes testing state controllers straightforward.

---

## Dynamic Tile Processing and Data Flow

The diagram below illustrates how screens render their contents dynamically:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Home Screen calls Home Screen Provider                   │
│    Path: lib/features/home/presentation/screens/home_screen.dart│
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. HomeScreenProvider queries Supabase / Cache              │
│    Fetches Active Tile list for context (e.g., ['RecentPhotosTile', ...])│
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Home Screen loops list and calls TileFactory.buildTile() │
│    Path: lib/core/utils/tile_factory.dart                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. TileFactory builds Smart Wrapper (e.g., _RecentPhotosSmartTile)│
│    Passes dynamic layout parameters (e.g., limit, fullView) │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Smart Wrapper watches selected baby and loads state       │
│    Queries via Riverpod (e.g., recentPhotosProvider)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Tile state provider handles fetch                         │
│    Looks up Hive Cache. If stale/empty, queries Supabase via│
│    DatabaseService, maps results, updates cache, and yields │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Smart Wrapper builds static Tile (e.g., RecentPhotosTile) │
│    Renders styled cards inside TileContainer with shimmers  │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed Active Tiles Summary

Below is the list of the 18 active tiles currently integrated in the Nonna app, including their directory locations:

| # | Tile Name | Component Name | Directory Location (`lib/tiles/`) | Description |
|---|---|---|---|---|
| 1 | **Recent Photos** | `RecentPhotosTile` | `recent_photos/` | Displays a grid/slider of the latest baby photos with access to gallery comments. |
| 2 | **Upcoming Events** | `UpcomingEventsTile` | `upcoming_events/` | Lists the baby's upcoming calendar events. |
| 3 | **Registry Highlights** | `RegistryHighlightsTile` | `registry_highlights/` | Shows featured baby registry items for followers to browse. |
| 4 | **Registry List** | `RegistryListTile` | `registry_list/` | Renders a full, searchable list of all baby registry additions. |
| 5 | **Due Date Countdown** | `CountdownTile` | `countdown/` | Tracks the remaining weeks, days, or hours until the baby's expected arrival. |
| 6 | **Checklist** | `ChecklistTile` | `checklist/` | An onboarding guide detailing setup tasks for baby owners. |
| 7 | **Engagement Recap** | `ActivityListTile` | `activity_list/` | Displays real-time social metrics showing follower activity, likes, and comment volume. |
| 8 | **Gallery Favorites** | `GalleryFavoritesTile` | `gallery_favorites/` | Highlights the most squished (liked) photos in the gallery. |
| 9 | **Invites Status** | `InvitesStatusTile` | `invites_status/` | Tracks the status of pending/accepted invitations (owner only). |
| 10 | **New Followers** | `NewFollowersTile` | `new_followers/` | Highlights recent family followers who have joined the baby's profile. |
| 11 | **Notifications** | `NotificationsTile` | `notifications/` | Houses social, RSVP, and system notifications for the current user. |
| 12 | **Recent Purchases** | `RecentPurchasesTile` | `recent_purchases/` | Lists registry items that have been recently bought by followers. |
| 13 | **RSVP Tasks** | `RsvpTasksTile` | `rsvp_tasks/` | Flags upcoming baby events that require an RSVP from the follower. |
| 14 | **Storage Usage** | `StorageUsageTile` | `storage_usage/` | Displays cloud storage metrics for photo and video uploads (owner only). |
| 15 | **System Announcements**| `SystemAnnouncementsTile` | `system_announcements/` | Renders global banners with important messages or app updates. |
| 16 | **Name Suggestions** | `NameSuggestionsTile` | `name_suggestions/` | Collects baby name ideas submitted by family members. |
| 17 | **Prediction Votes** | `PredictionVotesTile` | `prediction_votes/` | Interactive voting card where followers guess details like birth date or gender. |
| 18 | **New Baby Welcome** | `NewBabyWelcomeTile` | `new_baby_welcome/` | A congratulatory banner displayed to owners for 7 days post-birth. |

---

## Local Development and CI/CD Command Guide

Nonna app tasks are standardized using a root-level `Makefile`. You should run commands through `make` rather than executing custom scripts:

### 1. Basic Setup & Outlining
```bash
# Verify your Flutter setup is healthy
make doctor

# Fetch project dependencies
make deps

# Clean all build artifacts
make clean
```

### 2. Format & Analysis
```bash
# Format the entire Dart codebase
make format

# Run Flutter compiler analysis (enforces zero-warnings policy)
make analyze

# Run dart fix to auto-apply lint resolutions
make lint-fix
```

### 3. Running Unit and Widget Tests
```bash
# Run unit and widget tests with coverage metrics
make test

# Generate HTML coverage report
make coverage-report
```

### 4. Continuous Integration
```bash
# Run the automated test runner (categorized runner that outputs updates to automated_tests/TEST_COMMANDS.md)
make test-all

# Run the complete CI pipeline (doctor -> deps -> format -> analyze -> test -> pre-commit check)
make ci
```

### 5. Running Integration Tests (Automated Emulator Orchestration)
```bash
# Run full integration suites with automatic simulator setup (recommended)
make test-integration

# Run integration tests on an already active Android device or emulator
make test-integration-android

# Run integration tests on an already active iOS Simulator
make test-integration-ios
```

### 6. Executing App Builds
```bash
# Release APK for Android
make build-android

# Simulator app bundle for iOS
make build-ios

# Production deployment files for Web
make build-web
```
