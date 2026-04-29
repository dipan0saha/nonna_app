# Nonna App — Project Understanding

**Document Version**: 1.0
**Created**: April 28, 2026
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

The core architectural idea is **self-contained, reusable tile widgets** rendered dynamically based on Supabase-driven configuration tables (`tile_configs`, `screen_configs`).

```
lib/
├── core/          # Cross-cutting: models, services, DI, router, themes, utils
├── tiles/         # 15 reusable tile widgets (first-class citizens)
│   ├── core/      # TileFactory [IN PROGRESS], BaseTile, TileContainer
│   ├── upcoming_events/
│   ├── recent_photos/
│   ├── registry_highlights/
│   └── ... (15 total)
└── features/      # Screen composition (Home, Calendar, Gallery, etc.)
    ├── auth/
    ├── home/       # Composes tiles into a scrollable list view
    ├── calendar/
    ├── gallery/
    ├── registry/
    ├── baby_profile/
    ├── gamification/  # Name suggestions + voting (the "Fun" tab)
    ├── profile/
    └── settings/
```

**Key design decision**: Tiles live at `lib/tiles/` (not inside features) so they can be reused across any screen. Each tile is self-contained with its own model, provider, datasource, and widget.

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

## Tile Widgets (15 total)

| Tile | Screens Used |
|---|---|
| `UpcomingEventsTile` | Home, Calendar |
| `RecentPhotosTile` | Home, Gallery |
| `RegistryHighlightsTile` | Home, Registry |
| `DueDateCountdownTile` | Home |
| `ChecklistTile` | Home |
| `EngagementRecapTile` | Home |
| `GalleryFavoritesTile` | Home, Gallery |
| `InvitesStatusTile` | Home |
| `NewFollowersTile` | Home |
| `NotificationsTile` | Home |
| `RecentPurchasesTile` | Home, Registry |
| `RegistryDealsTile` | Home, Registry |
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
| `registry` | `/registry` | RegistryScreen |
| `registryItem` | `/registry/item/detail` | RegistryItemDetailScreen |
| `registryItemCreate` | `/registry/item/create` | RegistryItemCreationScreen |

---

## Current State (as of April 28, 2026)

### Completed
- All 23 domain models with serialization, validation, and unit tests
- All 22 services with middleware integration
- All 15 tile widgets with providers and widget tests
- All feature screens (auth, home, calendar, gallery, registry, profile, baby profile, gamification, settings)
- GoRouter navigation with auth redirect guards
- Supabase RLS policies with pgTAP test suite
- Supabase Edge Functions: `tile-configs`, `notification-trigger`, `image-processing`
- Localization (English + Spanish)
- Theming, error boundaries, offline cache and network failure handling

### In Progress
- **Centralized `TileFactory`** — dynamic tile instantiation from Supabase `tile_configs`/`screen_configs` tables. HomeScreen currently uses a simplified `TileListView` as an interim solution.

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
| `lib/tiles/core/widgets/tile_factory.dart` | [IN PROGRESS] Dynamic tile instantiation from Supabase configs |
| `lib/features/home/presentation/screens/home_screen.dart` | Main screen composing tiles via `TileListView` |
| `lib/core/services/app_initialization_service.dart` | Bootstraps all third-party SDKs with graceful degradation |
| `lib/core/di/providers.dart` | Global Riverpod providers (auth, Supabase) |
| `lib/core/themes/colors.dart` | App color palette |
| `pubspec.yaml` | Dependency manifest |
| `supabase/migrations/` | Database migration scripts |
| `supabase/functions/` | Edge Functions (TypeScript/Deno) |
