-- 1. Ensure all known tile definitions exist
INSERT INTO tile_definitions (id, tile_type, description, schema_params, is_active)
VALUES 
  (gen_random_uuid(), 'RecentPhotosTile', 'Shows recently uploaded photos', '{}'::jsonb, true),
  (gen_random_uuid(), 'UpcomingEventsTile', 'Shows upcoming events in calendar', '{}'::jsonb, true),
  (gen_random_uuid(), 'CountdownTile', 'Countdown to baby arrival', '{}'::jsonb, true),
  (gen_random_uuid(), 'ChecklistTile', 'Tasks and checklist items', '{}'::jsonb, true),
  (gen_random_uuid(), 'ActivityListTile', 'Recent activity feed across the app', '{}'::jsonb, true),
  (gen_random_uuid(), 'GalleryFavoritesTile', 'Favorite photos highlighted', '{}'::jsonb, true),
  (gen_random_uuid(), 'InvitesStatusTile', 'Status of sent invitations', '{}'::jsonb, true),
  (gen_random_uuid(), 'NewFollowersTile', 'Recently added followers', '{}'::jsonb, true),
  (gen_random_uuid(), 'NotificationsTile', 'Important system or app notifications', '{}'::jsonb, true),
  (gen_random_uuid(), 'RsvpTasksTile', 'Pending RSVPs for events', '{}'::jsonb, true),
  (gen_random_uuid(), 'StorageUsageTile', 'Current cloud storage usage stats', '{}'::jsonb, true),
  (gen_random_uuid(), 'SystemAnnouncementsTile', 'Platform wide announcements', '{}'::jsonb, true)
ON CONFLICT (tile_type) DO NOTHING;

-- 2. Configure Home Screen
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'home' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT screen.id, td.id, role_param, order_param, true, '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('SystemAnnouncementsTile', 'owner', 10), ('SystemAnnouncementsTile', 'follower', 10),
    ('CountdownTile', 'owner', 20), ('CountdownTile', 'follower', 20),
    ('NotificationsTile', 'owner', 30),
    ('RecentPhotosTile', 'owner', 50), ('RecentPhotosTile', 'follower', 50),
    ('UpcomingEventsTile', 'owner', 60), ('UpcomingEventsTile', 'follower', 60),
    ('ActivityListTile', 'owner', 70), ('ActivityListTile', 'follower', 70)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;

-- 3. Configure Gallery Screen
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'gallery' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT screen.id, td.id, role_param, order_param, true, '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('RecentPhotosTile', 'owner', 10), ('RecentPhotosTile', 'follower', 10),
    ('GalleryFavoritesTile', 'owner', 20), ('GalleryFavoritesTile', 'follower', 20)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;

-- 4. Configure Calendar Screen
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'calendar' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT screen.id, td.id, role_param, order_param, true, '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('UpcomingEventsTile', 'owner', 10), ('UpcomingEventsTile', 'follower', 10),
    ('RsvpTasksTile', 'owner', 20), ('RsvpTasksTile', 'follower', 20)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;

-- 5. Configure Fun/Gamification Screen
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'fun' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT screen.id, td.id, role_param, order_param, true, '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('ActivityListTile', 'owner', 10), ('ActivityListTile', 'follower', 10)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;
-- Upsert missing Tile Definitions
INSERT INTO tile_definitions (id, tile_type, description, schema_params, is_active)
VALUES 
  (gen_random_uuid(), 'RecentPurchasesTile', 'Shows recent purchases in registry', '{}'::jsonb, true),
  (gen_random_uuid(), 'RegistryDealsTile', 'Shows AI suggested deals for registry items', '{}'::jsonb, true)
ON CONFLICT (tile_type) DO NOTHING;

-- Insert configs for the Registry screen
WITH registry_screen AS (
  SELECT id FROM screens WHERE screen_name = 'registry' LIMIT 1
)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT 
  rs.id,
  td.id,
  role_param,
  order_param,
  true,
  '{}'::jsonb
FROM registry_screen rs
CROSS JOIN (
  VALUES 
    ('RegistryHighlightsTile', 'owner', 10),
    ('RegistryDealsTile', 'owner', 20),
    ('RecentPurchasesTile', 'owner', 30),
    ('RecentPurchasesTile', 'follower', 10)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;

-- Also add Registry tiles to the Home screen (as per documentation)
WITH home_screen AS (
  SELECT id FROM screens WHERE screen_name = 'home' LIMIT 1
)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT 
  hs.id,
  td.id,
  role_param,
  order_param,
  true,
  '{}'::jsonb
FROM home_screen hs
CROSS JOIN (
  VALUES 
    ('RegistryHighlightsTile', 'owner', 40),
    ('RegistryDealsTile', 'owner', 41),
    ('RecentPurchasesTile', 'owner', 42),
    ('RecentPurchasesTile', 'follower', 40)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;
