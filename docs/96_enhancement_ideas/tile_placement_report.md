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
- SystemAnnouncementsTile
- CountdownTile
- NotificationsTile
- RegistryHighlightsTile
- RecentPurchasesTile
- RecentPhotosTile
- UpcomingEventsTile
- ActivityListTile

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
- ChecklistTile
- InvitesStatusTile
- NewFollowersTile
- StorageUsageTile

## Tiles Mentioned but Not Wired
- RegistryDealsTile is referenced in project documentation but is not present in TileFactory, and lib/tiles/registry_deals/widgets is empty, so it is not currently a functional tile.
