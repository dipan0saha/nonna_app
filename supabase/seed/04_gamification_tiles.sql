-- Upsert new Gamification Tile Definitions
INSERT INTO tile_definitions (id, tile_type, description, schema_params, is_active)
VALUES 
  (gen_random_uuid(), 'NameSuggestionsTile', 'Shows incoming baby name suggestions', '{}'::jsonb, true),
  (gen_random_uuid(), 'PredictionVotesTile', 'Shows community predictions and votes', '{}'::jsonb, true)
ON CONFLICT (tile_type) DO NOTHING;

-- Configure Fun/Gamification Screen with these tiles
WITH screen AS (SELECT id FROM screens WHERE screen_name = 'fun' LIMIT 1)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT screen.id, td.id, role_param, order_param, true, '{}'::jsonb
FROM screen
CROSS JOIN (
  VALUES 
    ('NameSuggestionsTile', 'owner', 20), ('NameSuggestionsTile', 'follower', 20),
    ('PredictionVotesTile', 'owner', 30), ('PredictionVotesTile', 'follower', 30)
) AS mappings(tile_type, role_param, order_param)
JOIN tile_definitions td ON td.tile_type = mappings.tile_type
ON CONFLICT DO NOTHING;
