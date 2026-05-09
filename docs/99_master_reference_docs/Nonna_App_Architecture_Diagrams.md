# Nonna App - Architecture Diagrams

These Mermaid diagrams give a visual map of how the Nonna app works, from startup to tiles, routing, and data flow.

---

## 1) System Overview

```mermaid
flowchart LR
  subgraph Client[Flutter App]
    UI[Material 3 UI]
    State[Riverpod v3 State]
    Router[GoRouter v17]
    Tiles[Dynamic Tile Engine]
    Cache[Hive + SharedPreferences]
  end

  subgraph Backend[Supabase]
    Auth[Auth]
    DB[(Postgres)]
    Storage[Storage]
    Realtime[Realtime]
    Edge[Edge Functions]
  end

  subgraph Integrations[3rd Party]
    OneSignal[OneSignal Push]
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

## 2) Startup and Initialization Flow

```mermaid
sequenceDiagram
  autonumber
  participant App as main()
  participant Init as AppInitializationService
  participant Supa as Supabase
  participant Fire as Firebase
  participant One as OneSignal
  participant UI as MyApp

  App->>Init: initialize()
  Init->>Supa: init (critical)
  Supa-->>Init: ok
  par Optional integrations
    Init->>Fire: init (optional)
    Fire-->>Init: ok/warn
    Init->>One: init (optional)
    One-->>Init: ok/warn
  end
  Init-->>UI: success + warnings
  UI->>UI: build MaterialApp.router
```

---

## 3) Navigation Shell (Tabs + Fullscreen Routes)

```mermaid
flowchart TD
  Root[/ /] --> Home[/home/]

  subgraph Shell[StatefulShellRoute - 5 Tabs]
    HomeTab[Home]
    GalleryTab[Gallery]
    CalendarTab[Calendar]
    RegistryTab[Registry]
    FunTab[Fun]
  end

  Home --> HomeTab
  Home --> GalleryTab
  Home --> CalendarTab
  Home --> RegistryTab
  Home --> FunTab

  subgraph Fullscreen[Outside Shell]
    Profile[/profile/]
    Settings[/settings/]
    BabyProfile[/baby-profile/]
    Followers[/baby-profile/followers/]
    Invite[/baby-profile/followers/invite/]
  end
```

---

## 4) Tile Engine Pipeline (Edge-First with DB Fallback)

```mermaid
flowchart LR
  Screen[Screen Provider] --> Loader[TileLoader.loadForScreen]
  Loader --> Cache[Cache Lookup]
  Cache -->|Hit| Tiles[TileConfig List]
  Cache -->|Miss| Edge[Edge Function: tile-configs]
  Edge -->|Success| Tiles
  Edge -->|Fail| DBJoin[DB Join: tile_configs + screens + tile_definitions]
  DBJoin --> Tiles
  Tiles --> Filter[Filter + Sort]
  Filter --> UI[TileListView]
```

---

## 5) Tile Rendering and Smart Wrapper Pattern

```mermaid
sequenceDiagram
  autonumber
  participant Home as HomeScreen
  participant Provider as homeScreenProvider
  participant Loader as TileLoader
  participant Factory as TileFactory
  participant Smart as Smart Tile Wrapper
  participant Data as Tile Provider
  participant Widget as Presentational Tile

  Home->>Provider: loadTiles(babyProfileId, role)
  Provider->>Loader: loadForScreen(...)
  Loader-->>Provider: List<TileConfig>
  Provider-->>Home: state.tiles
  Home->>Factory: buildTile(config)
  Factory->>Smart: return wrapper
  Smart->>Data: fetch data (init + profile change)
  Data-->>Smart: tile state
  Smart-->>Widget: render
```

---

## 6) Role Model and Visibility

```mermaid
flowchart TD
  User[User] --> Memberships[Baby Memberships]
  Memberships --> Owner[Owner]
  Memberships --> Follower[Follower]

  Owner -->|CRUD| Features[Full Features]
  Follower -->|Read-only| Features

  Owner --> TilesOwner[Tile configs: role=owner]
  Follower --> TilesFollower[Tile configs: role=follower]
  TilesOwner --> Home
  TilesFollower --> Home
```

---

## 7) Data Access Rule (Service + Constants)

```mermaid
flowchart LR
  UI[Feature/Tile Provider] --> Service[DatabaseService]
  Service --> Tables[SupabaseTables Constants]
  Service --> DB[(Postgres via Supabase)]
```
