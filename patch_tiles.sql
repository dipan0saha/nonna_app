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
