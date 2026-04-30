# Nonna App Context

You are assisting with the Nonna App, a private family milestone tracking mobile application.

## Key Technologies
- **Frontend**: Flutter + Material 3
- **State Management**: Riverpod v3
- **Navigation**: GoRouter v17
- **Backend**: Supabase (Auth, PostgreSQL, Realtime, Storage, Edge Functions)
- **Local Storage/Caching**: Hive

## Core Architecture
- **Dynamic Tile-Based System**: The UI relies on reusable, self-contained widgets located in `lib/tiles/` governed by `TileFactory`. These are dynamically rendered based on Supabase configurations.
- **Role System**: 
  - **Owner**: Parents. They have full CRUD access scoped to their baby profile(s).
  - **Follower**: Friends & Family. They have a read-only, aggregated view across followed babies.

## Strict AI Guidelines
1. **Master Documentation**: ALWAYS consult `docs/99_master_reference_docs/Nonna_Project_Understanding.md` when asked about architectural decisions, roles, pending tasks, or database schemas before writing code. It is the absolute source of truth.
2. **State & Architecture**: Ensure all state is managed via Riverpod providers. UI components should reside in `lib/features/` or `lib/tiles/`.
3. **Data Layer**: All database interactions must go through the `DatabaseService` using `SupabaseTables` constants.
4. **Imports**: Use absolute/relative imports safely as per the current codebase structure.