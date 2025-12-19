# Technical Requirements: Hybrid Tile-Based UI (Static Tiles + Feature Flags)

## 1. Goals
- Deliver a tile-based UI for Home, Plans, Calendar, etc., with static tile definitions in Flutter and dynamic visibility via Supabase feature flags.
- Ensure tiles are independently testable, with dynamic data fetching.
- Meet existing functional/non-functional requirements (auth, RLS, performance <500ms, realtime <2s, 10MB photo uploads, 10K concurrent users).

## 2. Hybrid Tile Model: Static Tiles + Feature Flags
- **Static Tile Definitions:** Tiles are predefined Flutter widgets (e.g., `UpcomingEventsTile`) with hardcoded data queries and rendering logic. Each tile fetches dynamic data from Supabase based on user context.
- **Feature Flags (DB):** Control tile visibility per screen, role, and baby profile.
  - Table: `feature_flags`
    - `id`, `screen_name` (e.g., 'home', 'plans'), `tile_name` (e.g., 'upcoming_events'), `user_role` (optional), `baby_profile_id` (optional), `is_enabled` (boolean), `created_at`
- **Tile Instance Data:** Tiles render dynamically based on fetched data, but visibility is toggled via flags.
  - Response contract (example): Same as before, but tiles are assembled client-side after flag fetch.

## 3. Data Sources (examples)
- Upcoming events tile: select next N events from `events` for baby profile, filtered by role visibility and date.
- Recent photos tile: select recent photos (respect visibility, RLS) with thumbnails.
- Registry highlights tile: top priority unpurchased items, include purchaser metadata if purchased.
- Notifications tile: unread notifications for user.
- Invitations status tile: pending invites for owners.
- RSVP tasks tile: events awaiting the current user’s RSVP, scoped to baby profile and future dates.
- Due date countdown tile: shows expected birth date, days remaining, and CTA to add an event or note.
- Recent purchases tile: latest purchased registry items with purchaser and timestamp for owner visibility.
- Registry deals/recommendations tile: surface high-priority items without purchaser plus optional affiliate link metadata.
- Engagement recap tile: recent comments/likes on photos or events targeted to the user.
- New followers/pending approvals tile: follower join events or invites nearing expiration (owner-only).
- Gallery favorites tile: top squished photos in the last 7/30 days (role-filtered view only; no PII leakage).
- Checklist/onboarding tile: outstanding setup tasks (e.g., add baby profile photo, send first invite, create first event).
- Storage/usage tile: counts of photos, events, registry items; show soft caps and CTA to clean up (owner focus).
- System announcements tile: feature rollouts or maintenance notices (static content from config table or CMS).

## 4. API/Edge Function Layer
- **Endpoint:** `/feature-flags` (Edge Function) returns enabled tiles for a screen.
  - Inputs: `screen`, `baby_profile_id`, `role`.
  - Logic: Query `feature_flags` table with RLS; return list of enabled `tile_name`s.
  - Output: Array of tile names (e.g., ['upcoming_events', 'photo_gallery']).
- **Caching:** Cache flags locally in Flutter for session; refresh on login or screen change.
- **Realtime:** Optional subscription to `feature_flags` for live updates, but minimal since flags change infrequently.

## 5. Security & RLS
- All tile data sourced from tables already RLS-protected (`events`, `photos`, `registry_items`, `notifications`, `invitations`).
- Edge Function uses service role only to read layout metadata; data queries executed with user JWT where possible; otherwise re-check role and baby_profile membership before returning rows.
- Prevent leakage by scoping every query with `baby_profile_id` and role filters.

## 6. Performance
- Query targets: <300ms per tile query; total <500ms for typical screen load.
- Indexes: `events(baby_profile_id, event_date)`, `photos(baby_profile_id, created_at)`, `registry_items(baby_profile_id, priority, purchased_at)`, `notifications(recipient_id, created_at, read_at)`.
- Pagination: tiles return capped counts (e.g., events limit 5, photos limit 6) with paging tokens for drill-in screens.
- Thumbnails and on-device caching for media tiles.

## 7. Feature Flags & Rollouts
- Flags in `feature_flags` table enable/disable tiles per screen, role, and baby profile.
- Supports A/B testing (e.g., enable for 10% of users) and gradual rollouts without app updates.

## 8. Testing Strategy
- **Unit:** Tile data mappers and flag evaluators.
- **Widget:** Tile rendering for empty, loading, populated, and error states; flag-based visibility.
- **Integration:** Edge Function `/feature-flags` end-to-end with Supabase; validate RLS and role-based filtering.
- **Contract tests:** JSON schema for flag responses.
- **Performance tests:** Load test flag fetches with 10K concurrent users; assert P95 <500ms.

## 9. Tile Catalog (initial)
- UPCOMING_EVENTS: next events (respect role visibility, RSVP status).
- RECENT_PHOTOS: latest photos with thumbnails and squish state.
- REGISTRY_HIGHLIGHTS: top priority unpurchased items; show purchaser+timestamp if bought.
- NOTIFICATIONS_BRIEF: last 5 unread notifications.
- INVITES_STATUS (owners): pending invitations and expirations.
- CALENDAR_SUMMARY: events count this week + quick CTA.

## 10. Screen Compositions (v1)
- HOME: UPCOMING_EVENTS, RECENT_PHOTOS, REGISTRY_HIGHLIGHTS, NOTIFICATIONS_BRIEF.
- CALENDAR: UPCOMING_EVENTS, CALENDAR_SUMMARY.
- PLANS (roadmap/registry focus): REGISTRY_HIGHLIGHTS, UPCOMING_EVENTS.
- GALLERY: RECENT_PHOTOS.
- REGISTRY: REGISTRY_HIGHLIGHTS.

## 11. Mobile Implementation Notes (Flutter)
- State: BLoC per screen; tiles are static widgets with dynamic data fetching.
- Data fetch: Fetch flags via `/feature-flags`, then conditionally render tiles. Each tile handles its own data (e.g., via Supabase streams).
- Realtime: Tiles subscribe to relevant data tables (e.g., events, photos) scoped by baby_profile_id.
- UI: Tiles as cards; visibility controlled by flags. Empty/error states per tile.
- Theming/accessibility: Use Semantics, text scaling, and WCAG AA colors; support light/dark.

## 12. Migration Plan (DB)
1) Create `feature_flags` table with RLS policies.
2) Seed initial flags for screens and tiles (e.g., enable 'upcoming_events' on 'home' for 'parent' role).
3) Implement Edge Function `/feature-flags` using Supabase client.
4) Add indexes on `feature_flags` (screen_name, user_role, baby_profile_id).
5) Add integration tests for flag fetching and RLS.

## 13. Analytics (optional)
- Track tile impressions and taps (without sensitive payloads) to tune ordering and usefulness.

## 14. Risks & Mitigations
- **Overfetch/latency:** Cap data queries in tiles; cache flags locally.
- **RLS gaps:** Test with follower vs owner tokens; deny-by-default policies on flags.
- **Flag misconfigurations:** Default to safe visibility; if flag fails, show tiles with fallback logic.
- **Realtime noise:** Scope subscriptions to baby profile and tables; limit per screen.
