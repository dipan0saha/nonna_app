# Nonna App - Architecture Diagrams

**Document Version**: 3.0
**Last Updated**: May 25, 2026
**Location**: `docs/99_master_reference_docs/Nonna_App_Architecture_Diagrams.md`
**Status**: Living Document - Fully updated with GoRouter v17 and decoupled TileLoader pipeline

These Mermaid diagrams provide a comprehensive visual map of the Nonna app's systems, from startup sequences to tab routing, dynamic tile rendering, role authorization, and data flow.

---

## 1) High-Level System Overview

The Nonna application combines a modern Flutter mobile front-end (Material 3, Riverpod v3 state management, Hive caching) with a Supabase PostgreSQL backend, leveraging serverless Edge Functions for background tasks and push notification multi-plexing.

```mermaid
flowchart LR
  subgraph Client[Flutter Mobile App]
    UI[Material 3 UI]
    State[Riverpod v3 State]
    Router[GoRouter v17]
    Tiles[Dynamic Tile Engine]
    Cache[Hive + SharedPreferences]
  end

  subgraph Backend[Supabase Cloud]
    Auth[Supabase Auth]
    DB[(PostgreSQL Database)]
    Storage[Supabase Storage]
    Realtime[Supabase Realtime]
    Edge[Serverless Edge Functions]
  end

  subgraph Integrations[3rd Party Integrations]
    OneSignal[OneSignal Push REST]
    Firebase[Firebase Analytics/Crash]
  end

  UI --> State
  UI --> Router
  State --> Tiles
  State --> Cache
  State --> DB
  State --> Realtime
  Tiles --> Edge
  Edge --> DB
  Storage --> UI

  Auth <--> State
  OneSignal <--> State
  Firebase <--> State
```

---

## 2) Startup and Initialization Sequence

Upon app launch, `main.dart` coordinates with the `AppInitializationService` to initialize remote resources and load cached sessions before transitioning the splash screen.

```mermaid
sequenceDiagram
  autonumber
  participant App as main()
  participant Init as AppInitializationService
  participant Supa as Supabase Client
  participant Fire as Firebase Core
  participant One as OneSignal SDK
  participant UI as MyApp MaterialApp.router

  App->>Init: initialize()
  Init->>Supa: init (critical database connection)
  Supa-->>Init: OK
  par Optional 3rd Party SDKs (Fail-Open Policy)
    Init->>Fire: init (Analytics / Crashlytics)
    Fire-->>Init: OK / Warning
    Init->>One: init (Push Notifications)
    One-->>Init: OK / Warning
  end
  Init-->>App: initialization complete
  App->>UI: build MaterialApp.router
  UI->>UI: evaluate initial auth redirect
```

---

## 3) Navigation Shell & GoRouter Tab Stack

The app uses `StatefulShellRoute.indexedStack` to maintain **5 independent navigation stacks** (retaining scroll position and tab states). Fullscreen routes, modals, and creation screens escape the shell to render cleanly over the bottom navigation bar.

```mermaid
flowchart TD
  Root[/ /] -->|Initial Redirect| Home[/home/]

  subgraph AuthRoutes[Auth Routes - Outside Shell]
    Login[/login/]
    Signup[/signup/]
    RoleSelect[/role-selection/]
  end

  subgraph Shell[StatefulShellRoute Shell Navigator]
    direction TB
    
    subgraph BranchHome[Branch 0: Home]
      HomeTab[HomeScreen]
    end
    
    subgraph BranchGallery[Branch 1: Gallery]
      GalleryTab[GalleryScreen]
      GalleryFavs[gallery/favorites]
      GalleryRecent[gallery/recent]
    end
    
    subgraph BranchCalendar[Branch 2: Calendar]
      CalendarTab[CalendarScreen]
      CalendarUpcoming[calendar/upcoming]
      CalendarDetail[calendar/event/detail]
    end
    
    subgraph BranchRegistry[Branch 3: Registry]
      RegistryTab[RegistryScreen]
      RegistryDetail[registry/item/detail]
    end
    
    subgraph BranchFun[Branch 4: Fun]
      FunTab[GamificationScreen]
    end
  end

  subgraph Fullscreen[Fullscreen Routes - Outside Shell]
    Profile[/profile/]
    ProfileEdit[/profile/edit/]
    Settings[/settings/]
    BabyProfile[/baby-profile/]
    BabyProfileCreate[/baby-profile/create/]
    BabyProfileEdit[/baby-profile/:id/edit/]
    Followers[/baby-profile/followers/]
    Invite[/baby-profile/followers/invite/]
    
    DetailEscapes[gallery/photo/detail]
    CreateEvent[calendar/event/create]
    EditEvent[calendar/event/edit]
    CreateRegistry[registry/item/create]
    EditRegistry[registry/item/edit]
  end

  Root --> AuthRoutes
  Root --> Shell
  Shell --> Fullscreen
```

---

## 4) Tile Engine Pipeline (Edge-First with DB Fallback)

To decouple dependencies, screens load dynamic configurations utilizing the utility class `TileLoader.loadForScreen`. It follows a robust **Edge-First caching strategy**, failing open to a local PostgreSQL join if the network or Serverless function fails.

```mermaid
flowchart TD
  Screen[Screen Provider] -->|Invokes| Loader[TileLoader.loadForScreen]
  Loader -->|Check Key| Cache{Cache Lookup}
  
  Cache -->|Hit: Return cached JSON| Filter[Filter Enabled & Sorted TileConfigs]
  Cache -->|Miss: Query Remote| Edge[Edge Function: tile-configs]
  
  Edge -->|Success: 200 OK| CacheSave[Save JSON to Cache via TTL]
  CacheSave --> Filter
  
  Edge -->|Fail: Network/Server Error| DBJoin[Postgres Join: tile_configs + screens + tile_definitions]
  DBJoin --> CacheSave2[Save DB JSON to Cache via TTL]
  CacheSave2 --> Filter
  
  Filter -->|Validate Active Components| UI[TileListView.builder]
```

---

## 5) Tile Rendering and Smart Wrapper Pattern

Screens compose widgets utilizing the **Smart Wrapper Pattern**. Inactive/Presentational tiles remain decoupled from the active Riverpod providers that hydrate them, passing events via clean callback triggers.

```mermaid
sequenceDiagram
  autonumber
  participant Screen as HomeScreen / RegistryScreen
  participant Provider as ScreenProvider (homeScreenProvider)
  participant Loader as TileLoader Utility
  participant Factory as TileFactory
  participant Smart as Smart Tile Wrapper (_RecentPhotosSmartTile)
  participant Data as Tile State Provider (recentPhotosProvider)
  participant UI as Presentational Tile Widget (RecentPhotosTile)

  Screen->>Provider: initialize / refresh
  Provider->>Loader: loadForScreen(babyProfileId, role)
  Loader-->>Provider: List<TileConfig>
  Provider-->>Screen: rebuild with configs
  Screen->>Factory: buildTile(config)
  Factory->>Smart: instantiate wrapper instance
  Smart->>Data: subscribe and read (watches babyProfileId)
  Data-->>Smart: AsyncValue<TileState>
  Smart-->>UI: map data and render static presentation
  UI->>Smart: user tap event callback
  Smart->>Screen: navigation route push
```

---

## 6) Role Model & Content Visibility

The application dynamically adjusts data scopes and visibility depending on the User's RBAC association with the active baby profile.

```mermaid
flowchart TD
  User[User Profile] --> Memberships[Baby Memberships Table]
  Memberships -->|Role: owner| Owner[Owner Scope]
  Memberships -->|Role: follower| Follower[Follower Scope]

  subgraph OwnerAccess[Owner Operations]
    Owner -->|Full CRUD| EventCRUD[Create/Edit Calendar Events]
    Owner -->|Invite/Revoke| FollowerInvites[Invite Followers via Email]
    Owner -->|Manage Gifts| DeletePurchases[Delete Registry Purchases]
    Owner -->|Active Controls| OwnerTiles[Show Owner-Only Tiles: Checklist, StorageUsage, InvitesStatus]
  end

  subgraph FollowerAccess[Follower Operations]
    Follower -->|Read-Only Feed| AggregatedPhotos[Aggregated Baby Photos]
    Follower -->|Submit Predicts| PredictionGuesses[Vote predictions / suggest baby names]
    Follower -->|Gift Commit| PurchaseItem[Mark Registry Items Bought]
    Follower -->|Read Tiles| FollowerTiles[Show Follower-Only Tiles: RSVPTasks, RegistryList]
  end
```

---

## 7) Decoupled Data Access Rule

To maintain clear separation of concerns, presentation controllers and tiles do not query remote endpoints directly. Database interactions are routed through standardized core services.

```mermaid
flowchart LR
  UI[Feature / Tile Provider] -->|Subscribes| Service[DatabaseService]
  Service -->|Table Identifiers| Constants[SupabaseTables Constants]
  Service -->|Postgrest Filters| Supa[Supabase DB / RLS Rules]
```
