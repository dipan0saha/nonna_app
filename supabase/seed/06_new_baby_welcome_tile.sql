-- Seed: NewBabyWelcomeTile definition and home-screen config (owner only)
-- Date: 2026-05-10
--
-- The tile is shown only on the owner home screen.
-- The Edge Function / TileLoader already filters tiles whose
-- baby profile has no actual_birth_date, or whose birth was >7 days ago,
-- via the smart wrapper in TileFactory — no extra DB-level filter needed.
-- The tile is placed at display_order = 5 so it sits at the very top
-- of the home feed (above CountdownTile at 20, etc.).

-- 1. Register the tile definition
INSERT INTO tile_definitions (id, tile_type, description, schema_params, is_active)
VALUES (
  gen_random_uuid(),
  'NewBabyWelcomeTile',
  'Welcome card shown to the owner for 7 days after the baby''s actual birth date. Displays baby photo, name, gender, birth date, weight and height.',
  '{
    "hideWhenEmpty": true
  }'::jsonb,
  true
)
ON CONFLICT (tile_type) DO NOTHING;

-- 2. Add the tile_config entry for the owner home screen
WITH screen AS (
  SELECT id FROM screens WHERE screen_name = 'home' LIMIT 1
)
INSERT INTO tile_configs (screen_id, tile_definition_id, role, display_order, is_visible, params)
SELECT
  screen.id,
  td.id,
  'owner',
  5,
  true,
  '{"hideWhenEmpty": true}'::jsonb
FROM screen
JOIN tile_definitions td ON td.tile_type = 'NewBabyWelcomeTile'
ON CONFLICT DO NOTHING;
