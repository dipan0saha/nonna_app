# Tile System Design for Nonna App

## Overview

The Nonna App implements a dynamic, modular tile-based architecture to display content across various screens (Home, Gallery, Calendar, Registry, Photo Gallery, Fun). This system uses a TileFactory to create self-contained tiles, each with its own targeted Supabase queries. Tiles are configured and ordered via Supabase tables based on user roles, with dynamic visibility controlled by flags. The design prioritizes performance, modularity, and security, ensuring smooth scrolling and real-time updates only when necessary.

## User Perspective

### How Users Interact with Tiles

1. **Seamless Experience Across Roles**:
   - **Parents (Owners)**: Can view and manage all tiles on their baby profiles. They see editing controls for tiles they own and receive real-time notifications for interactions (e.g., comments, purchases).
   - **Friends & Family (Followers)**: View tiles based on visibility flags. They interact with content (e.g., RSVP, comment, like) but cannot modify tile configurations. Tiles aggregate content from all followed babies in a unified view.

2. **Dynamic Screen Layout**:
   - Each screen (e.g., Home, Calendar) displays a curated list of tiles in a predefined order based on user role.
   - Tiles appear or disappear based on dynamic flags (e.g., a "Baby Countdown" tile only shows for profiles within 10 days of expected birth).
   - The same tile (e.g., PhotoGridTile) can appear on multiple screens, ensuring consistency.
   - For followers, tiles aggregate content from all followed babies in a unified view (e.g., PhotoGridTile shows photos from all followed babies in one grid, sorted by date).

3. **Performance and Responsiveness**:
   - Screens load instantly from cached data on first open.
   - Updates occur only when owners post new content, minimizing data usage and battery drain.
   - Smooth scrolling through tile lists, even with large galleries or activity feeds.

4. **Customization for Owners**:
   - Owners can adjust tile visibility and order via an in-app dashboard (future feature), stored in Supabase.
   - Changes propagate in real-time to followers.

5. **Notifications and Updates**:
   - Followers receive push notifications only for relevant updates (e.g., new photo in gallery).
   - Owners get notifications for all interactions on their tiles.

### Example User Flow

- **Follower Opens Home Screen**:
  - Cached tiles load instantly: Baby Countdown, Recent Activities, Photo Grid.
  - If owner updated content since last visit, tiles refresh automatically.
  - User scrolls smoothly through activities, RSVPs to events, or likes photos.

- **Owner Edits Registry**:
  - Adds a new item; tile updates in real-time for followers.
  - Followers see the change without manual refresh.

## Technical Perspective

### Core Components

1. **TileFactory**:
   - A factory class that instantiates specific tile widgets based on type (e.g., `ActivityListTile`, `PhotoGridTile`).
   - Each tile is self-contained: handles its own Supabase queries, state management, and UI rendering.
   - Supports modularity: tiles can be developed, tested, and deployed independently.

2. **Supabase Tables**:
   - **tile_configs**: Stores tile definitions (type, visibility flags, order, parameters like limit).
     - Columns: `id`, `role` ('owner' or 'follower'), `tile_type`, `visible`, `order`, `params` (JSON), `last_updated`.
   - **tile_data**: Stores content for each tile (e.g., activities, photos).
     - Row-Level Security (RLS): Only owners can insert/update/delete.
   - **screen_configs**: Defines which tiles appear on which screens, with order.
     - Columns: `screen_name`, `tile_ids` (array), `role` ('owner' or 'follower').
   - **user_followers**: Tracks which babies a user follows.
     - Columns: `user_id`, `baby_profile_id`, `relationship`.

3. **Caching Strategy**:
   - Local cache using Hive or Isar for tile data and configs.
   - Cache invalidation: Based on `last_updated` timestamp from Supabase.
   - Riverpod providers with `keepAlive: true` to persist state across navigation.

4. **State Management**:
   - Riverpod for dependency injection and state sharing.
   - Each tile has its own provider for data fetching and updates.
   - Shared provider for visibility flags to avoid duplicate queries.

5. **Real-Time Updates**:
   - Owners subscribe to full tile tables for real-time broadcasts across their babies.
   - Followers subscribe to a per-user channel for updates across all followed babies (broadcasting the max timestamp).
   - Updates trigger cache refresh and UI rebuilds.

### Data Flow

1. **App Launch**:
   - Load cached tile configs and data.
   - Check `last_updated` timestamp via Supabase.
   - If outdated, fetch fresh data and update cache.

2. **Screen Rendering**:
   - Fetch screen config from Supabase/cache based on user role.
   - Use TileFactory to build visible tiles in order.
   - Each tile executes its query (cached if possible; followers query across all followed babies).

3. **Tile Updates**:
   - Owner actions (e.g., add photo) update Supabase.
   - Real-time subscription notifies followers.
   - Followers refresh tile data across all followed babies.

4. **Performance Optimizations**:
   - Lazy loading with `ListView.builder` and pagination.
   - Precache images and assets.
   - Minimize rebuilds with `const` constructors and `ValueKey`.

### Security

- **Row-Level Security (RLS)**: Policies ensure only owners can modify tile configs and data.
- **Authentication**: JWT tokens for all Supabase interactions.
- **Data Encryption**: AES-256 at rest, TLS 1.3 in transit.

### Implementation Steps

1. **Define Tile Types**:
   - `ActivityListTile`: Shows recent activities (comments, purchases).
   - `PhotoGridTile`: Grid of photos with squish functionality.
   - `CalendarTile`: Upcoming events with RSVP.
   - `RegistryTile`: Baby items with purchase status.
   - `CountdownTile`: Baby arrival countdown.

2. **Set Up Supabase**:
   - Create tables with RLS policies.
   - Enable real-time for key tables.

3. **Build TileFactory**:
   - Switch statement to instantiate tiles by type.
   - Pass parameters from `tile_configs`, with role determining query scope (owners edit, followers view aggregated).

4. **Integrate Caching**:
   - Use Hive for local storage.
   - Riverpod providers for data management.

5. **Test Modularity**:
   - Develop each tile in isolation.
   - Unit tests for queries and UI.

6. **Performance Testing**:
   - Measure load times, scrolling smoothness.
   - Simulate high concurrency.

### Potential Challenges and Solutions

- **Conflicting Ideas**: Prioritize low-latency (cache-first) over complex real-time for followers.
- **Scalability**: Use Supabase edge functions for heavy queries; handle multi-baby data with efficient indexing.
- **Battery Usage**: Limit subscriptions; use efficient polling for non-critical updates.
- **Role-Based Access**: Ensure queries respect user roles and baby access; test with mixed owner/follower scenarios.

## Conclusion

This tile system provides a flexible, performant foundation for the Nonna App, balancing user experience with technical efficiency. By leveraging Supabase's features and Flutter's state management, we ensure modularity, security, and smooth performance for up to 10,000 concurrent users.