-- Registry List Tile Configs
-- Adds the RegistryListTile to the registry screen

-- 1. Ensure all known tile definitions exist
INSERT INTO tile_definitions (id, tile_type, description, schema_params, is_active)
VALUES 
  (gen_random_uuid(), 'RegistryListTile', 'Shows the main registry items list', '{}'::jsonb, true)
ON CONFLICT (tile_type) DO NOTHING;

-- 2. Configure Registry Screen
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'registry' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT 
  screen.id,
  td.id,
  mappings.role_param,
  mappings.order_param,
  true,
  '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('RegistryListTile', 'owner', 100),
    ('RegistryListTile', 'follower', 100)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;
