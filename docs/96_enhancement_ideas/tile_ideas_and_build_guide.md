# Tile Enhancement Ideas and Build Guide

This doc captures new tile ideas and a practical checklist for building new tiles in the Nonna dynamic tile system.

## New Tile Ideas

1. Milestone Timeline Tile
   - Purpose: A compact, chronological snapshot of key milestones (first smile, first steps, etc.).
   - Data: New `milestones` table with date + photo + note.
   - Screens: Home, Profile, Gallery.

2. Growth Tracker Tile
   - Purpose: Weight/height/head circumference trend summary with last 2-3 entries.
   - Data: New `growth_entries` table.
   - Screens: Home (owner), Profile (owner), optional follower read-only.

3. Vaccination Schedule Tile
   - Purpose: Upcoming/overdue vaccinations with status chips.
   - Data: New `vaccination_schedule` + `vaccination_records` tables.
   - Screens: Home (owner), Calendar.

4. Feeding Log Highlights Tile
   - Purpose: Last 24h feeding summary (count + total volume).
   - Data: New `feeding_logs` table; aggregate queries.
   - Screens: Home (owner), optional follower hidden.

5. Sleep Summary Tile
   - Purpose: Last 24h sleep total + longest stretch.
   - Data: New `sleep_logs` table.
   - Screens: Home (owner).

6. Photo Highlights Tile
   - Purpose: Weekly top photos (most squishes or comments).
   - Data: Existing photos + squishes + comments.
   - Screens: Home, Gallery.

7. Family Memory Prompt Tile
   - Purpose: Prompt a weekly story or question; show recent responses.
   - Data: New `memory_prompts` + `memory_responses` tables.
   - Screens: Home, Profile.

8. Registry Price Drop Tile
   - Purpose: Track price changes for registry items with external links.
   - Data: New `registry_price_watch` table + scheduled edge function.
   - Screens: Registry.

9. Event Photo Recap Tile
   - Purpose: After events, show linked photos and comments summary.
   - Data: Events + photos tagged with event id.
   - Screens: Calendar, Gallery.

10. New Follower Activity Tile (enhanced)
    - Purpose: Weekly summary of new followers + their recent interactions.
    - Data: Existing followers + activity feed.
    - Screens: Home (owner).

## New Tile Build Checklist

### 1) Define the tile spec
- Tile purpose, primary users (owner/follower), and target screens.
- Data inputs (tables, queries, and expected freshness).
- Params needed for configuration (limit, timeframe, hideWhenEmpty).

### 2) Data layer and Supabase schema
- Add or update tables in `supabase/migrations/` if new data is required.
- Update RLS policies and add indexes for expected queries.
- If realtime is needed, ensure the table is in the publication and filtered correctly.
- Add or update `SupabaseTables` constants for new tables.

### 3) Domain model
- Create model in `lib/core/models/` (or `lib/tiles/<tile>/models/`).
- Add serialization, validation, and unit tests.

### 4) Provider and caching
- Add a Riverpod provider in `lib/tiles/<tile>/providers/`.
- Use `DatabaseService` for queries and `CacheService` for offline caching.
- Add background refresh and error handling.

### 5) Tile UI widget
- Create the widget in `lib/tiles/<tile>/widgets/`.
- Use `TileHeader` and `TileIcons` for consistent header styling.
- Keep spacing compact and match the theme (ColorScheme + AppColors).

### 6) TileFactory wiring
- Add the tile switch case in `lib/core/utils/tile_factory.dart`.
- Build a smart wrapper if the tile needs provider orchestration or routing.

### 7) Tile definition and config
- Insert the tile into `tile_definitions` (tile_type must match TileFactory case).
- Add `tile_configs` for each screen/role with `display_order` and `params`.
- Update `supabase/seed/*.sql` so new environments include the tile.

### 8) Edge function behavior
- If using `tile-configs`, confirm params and `hideWhenEmpty` logic.
- Ensure the edge function handles any new tile-specific params.

### 9) Realtime subscriptions (optional)
- If realtime is required, use `RealtimeService` + `RealtimeSubscriptionManager`.
- Scope filters to avoid noisy channels and respect RLS.

### 10) Analytics and notifications (optional)
- Log tile impressions or actions in `AnalyticsService`.
- Add notification triggers where appropriate.

### 11) Localization and accessibility
- Add any user-facing strings to l10n ARB files.
- Ensure labels, contrast, and tap targets match accessibility guidelines.

### 12) Tests
- Provider tests for fetch/caching behavior.
- Widget tests for empty/error/loading states.
- Optional integration tests if the tile affects user flows.

## Suggested Verification Steps
- Confirm the tile appears for the intended role/screen based on `tile_configs`.
- Check `TileFactory` rendering and params parsing.
- Verify offline cache loads and realtime updates when applicable.
