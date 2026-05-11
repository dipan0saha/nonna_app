# Tile Placement Report (Seed Config + TileFactory)

This report is based on the current codebase and seed SQL files:
- supabase/seed/01_base_tile_configs.sql
- supabase/seed/04_gamification_tiles.sql
- supabase/seed/05_registry_list_tile.sql
- lib/core/utils/tile_factory.dart

Note: The live Supabase `tile_configs` table can differ from these seed defaults.

## Implemented Tiles (TileFactory Cases)
- RecentPhotosTile
- UpcomingEventsTile
- RegistryHighlightsTile
- RegistryListTile
- CountdownTile
- ChecklistTile
- ActivityListTile
- GalleryFavoritesTile
- InvitesStatusTile
- NewFollowersTile
- NotificationsTile
- RecentPurchasesTile
- RsvpTasksTile
- StorageUsageTile
- SystemAnnouncementsTile
- NameSuggestionsTile
- PredictionVotesTile

## Seed Placement by Screen and Role

Home (owner)
- NewBabyWelcomeTile (display_order=5)
- SystemAnnouncementsTile (display_order=10)
- CountdownTile (display_order=10)
- NotificationsTile (display_order=20)
- ActivityListTile (display_order=30)
- RecentPhotosTile (display_order=40)
- RegistryHighlightsTile (display_order=40)
- RegistryDealsTile (display_order=41)
- RecentPurchasesTile (display_order=42)
- UpcomingEventsTile (display_order=60)
- ChecklistTile (display_order=70)
- InvitesStatusTile (display_order=80)
- NewFollowersTile (display_order=90)
- StorageUsageTile (display_order=100)

Home (follower)
- SystemAnnouncementsTile
- CountdownTile
- RecentPurchasesTile
- RecentPhotosTile
- UpcomingEventsTile
- ActivityListTile

Gallery (owner and follower)
- RecentPhotosTile
- GalleryFavoritesTile

Calendar (owner and follower)
- UpcomingEventsTile
- RsvpTasksTile

Registry (owner)
- RegistryHighlightsTile
- RecentPurchasesTile
- RegistryListTile

Registry (follower)
- RecentPurchasesTile
- RegistryListTile

Fun / Gamification (owner and follower)
- ActivityListTile
- NameSuggestionsTile
- PredictionVotesTile

## Tiles Implemented but Not Seeded on Any Screen
_(None — all implemented tiles are now seeded on at least one screen as of May 11, 2026)_

## Tiles Mentioned but Not Wired
- RegistryDealsTile is referenced in project documentation but is not present in TileFactory, and lib/tiles/registry_deals/widgets is empty, so it is not currently a functional tile.
