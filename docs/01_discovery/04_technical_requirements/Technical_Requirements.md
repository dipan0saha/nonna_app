# Technical Requirements: Dynamic Tile-Based UI (Role-Driven Tiles with Supabase Config)

## 1. Goals
- Deliver a dynamic tile-based UI for Home, Gallery, Calendar, Registry, Photo Gallery, Fun, with tiles configured and ordered via Supabase tables based on user roles.
- Ensure tiles are self-contained, modular widgets with independent Supabase queries, supporting aggregation for followers across all followed babies.
- Meet existing functional/non-functional requirements (auth, RLS, performance <500ms, realtime <2s, 10MB photo uploads, 10K concurrent users).

## 2. Dynamic Tile Model: Role-Driven Tiles with Supabase Config
- **TileFactory and Configs:** Tiles are instantiated via a TileFactory from Supabase `tile_configs` (defines tile type, visibility, order, params) and `screen_configs` (defines tiles per screen by role).
- **Role-Based Behavior:** Owners see editable tiles per baby; followers see aggregated read-only tiles across all followed babies.
- **Aggregation for Followers:** Tiles query data from all accessible babies, sorted globally (e.g., recent photos from all followed babies).
- **Tile Instance Data:** Tiles render dynamically based on fetched data, with visibility and order from configs.

## 3. Data Sources (examples)
- Upcoming events tile: Select next N events from `events` for owners (per baby) or followers (across all followed babies), filtered by role and date.
- Recent photos tile: Select recent photos with thumbnails; owners per baby, followers aggregated across babies.
- Registry highlights tile: Top priority unpurchased items; owners per baby, followers aggregated.
- Notifications tile: Unread notifications for user.
- Invitations status tile: Pending invites for owners (per baby).
- RSVP tasks tile: Events awaiting RSVP; owners per baby, followers aggregated.
- Due date countdown tile: Expected birth dates; owners per baby, followers aggregated.
- Recent purchases tile: Latest purchased registry items; owners per baby, followers aggregated.
- Registry deals/recommendations tile: High-priority items; owners per baby, followers aggregated.
- Engagement recap tile: Recent comments/likes; owners per baby, followers aggregated.
- New followers/pending approvals tile: Follower events; owner-only per baby.
- Gallery favorites tile: Top squished photos; role-filtered.
- Checklist/onboarding tile: Outstanding tasks; owner-focused per baby.
- Storage/usage tile: Counts of content; owner per baby.
- System announcements tile: Feature notices; global.

## 4. API/Edge Function Layer
- **Endpoint:** `/tile-configs` (Edge Function) returns tile configs for a screen.
  - Inputs: `screen`, `role`, `baby_profile_ids` (for owners) or followed babies (for followers).
  - Logic: Query `screen_configs` and `tile_configs` with RLS; return enabled tiles with params.
  - Output: Array of tile objects (e.g., [{name: 'upcoming_events', params: {limit: 5}}]).
- **Caching:** Cache configs locally in Flutter; refresh on role change or screen load.
- **Realtime:** Subscribe to config tables for live updates, scoped by role.

## 5. Security & RLS
- All tile data from RLS-protected tables (`events`, `photos`, `registry_items`, etc.).
- Edge Function uses user JWT; queries scoped by role and baby access.
- For followers, aggregate queries check `user_followers` for access; prevent cross-baby leakage.

## 6. Performance
- Query targets: <300ms per tile; total <500ms for screen load.
- Indexes: As before, plus on `tile_configs(role, visible)`, `screen_configs(role)`.
- Pagination: Tiles cap data (e.g., limit 5 events); paging for drill-ins.
- Caching: Hive/Isar for configs and data; Riverpod keep-alive.
- Aggregation: Efficient `.in()` queries for followers; cache aggregated results.

## 7. Tile Configs & Rollouts
- Configs in `tile_configs` and `screen_configs` control visibility, order, and params per role.
- Supports dynamic updates without app releases; owners can adjust via dashboard.

## 8. Testing Strategy
- **Unit:** TileFactory, data mappers, role-based queries.
- **Widget:** Tile rendering for role-specific states; aggregation for followers.
- **Integration:** `/tile-configs` end-to-end; validate RLS and aggregation.
- **Contract tests:** JSON schema for config responses.
- **Performance tests:** Load test with 10K users; assert P95 <500ms.

## 9. Tile Catalog (initial)
- UPCOMING_EVENTS: Next events; owners per baby, followers aggregated.
- RECENT_PHOTOS: Latest photos; owners per baby, followers aggregated.
- REGISTRY_HIGHLIGHTS: Top unpurchased items; owners per baby, followers aggregated.
- NOTIFICATIONS_BRIEF: Unread notifications.
- INVITES_STATUS (owners): Pending invites per baby.
- CALENDAR_SUMMARY: Events count; owners per baby, followers aggregated.

## 10. Screen Compositions (v1)
- HOME: UPCOMING_EVENTS, RECENT_PHOTOS, REGISTRY_HIGHLIGHTS, NOTIFICATIONS_BRIEF (role-specific order from configs).
- CALENDAR: UPCOMING_EVENTS, CALENDAR_SUMMARY.
- GALLERY: RECENT_PHOTOS.
- REGISTRY: REGISTRY_HIGHLIGHTS.
- Configurable via `screen_configs` for dynamic ordering.

## 11. Mobile Implementation Notes (Flutter)
- State: Riverpod per tile; TileFactory instantiates based on configs.
- Data fetch: Fetch configs via `/tile-configs`, then render tiles. Each tile handles data (Supabase streams).
- Realtime: Tiles subscribe to data tables scoped by role/babies.
- UI: Tiles as cards; role-based visibility. Empty/error states.
- Theming/accessibility: As before.

## 12. Migration Plan (DB)
1) Create `tile_configs`, `screen_configs`, `user_followers` tables with RLS.
2) Seed initial configs for screens and tiles by role.
3) Implement Edge Function `/tile-configs`.
4) Add indexes on configs (role, visible).
5) Test integration for configs and aggregation.

## 13. Analytics (optional)
- Track tile impressions and taps (without sensitive payloads) to tune ordering and usefulness.

## 14. Risks & Mitigations
- **Overfetch/latency:** Cap queries; cache configs/data.
- **RLS gaps:** Test role tokens; deny-by-default on configs.
- **Config misconfigurations:** Default safe visibility; fallback if fails.
- **Realtime noise:** Scope subscriptions by role/babies.
- **Aggregation complexity:** Test multi-baby queries; optimize with caching.
