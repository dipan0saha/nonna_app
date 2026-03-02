BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(12);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'tile_configs'::name, 'tile_configs table should exist');
SELECT rls_enabled('public'::name, 'tile_configs'::name, 'RLS should be enabled on tile_configs');

SELECT has_column('public'::name, 'tile_configs'::name, 'id'::name,                  'tile_configs has id');
SELECT has_column('public'::name, 'tile_configs'::name, 'screen_id'::name,           'tile_configs has screen_id');
SELECT has_column('public'::name, 'tile_configs'::name, 'tile_definition_id'::name,  'tile_configs has tile_definition_id');
SELECT has_column('public'::name, 'tile_configs'::name, 'role'::name,                'tile_configs has role');
SELECT has_column('public'::name, 'tile_configs'::name, 'display_order'::name,       'tile_configs has display_order');
SELECT has_column('public'::name, 'tile_configs'::name, 'is_visible'::name,          'tile_configs has is_visible');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'tile_configs', 'Authenticated users can view tile configs for their role', 'policy exists: authenticated view tile configs');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com');

INSERT INTO public.screens (id, screen_name, is_active) VALUES
  ('11111111-0000-0001-0000-000000000001', 'home_screen', TRUE);

INSERT INTO public.tile_definitions (id, tile_type, is_active) VALUES
  ('22222222-0000-0001-0000-000000000001', 'photo_gallery', TRUE);

INSERT INTO public.tile_configs (id, screen_id, tile_definition_id, role, display_order, is_visible) VALUES
  ('33333333-0000-0001-0000-000000000001',
   '11111111-0000-0001-0000-000000000001',
   '22222222-0000-0001-0000-000000000001',
   'owner', 1, TRUE),
  ('33333333-0000-0001-0000-000000000002',
   '11111111-0000-0001-0000-000000000001',
   '22222222-0000-0001-0000-000000000001',
   'follower', 2, FALSE);

-- ==================== Functional Tests ====================

-- Authenticated user can view visible tile config
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.tile_configs WHERE is_visible = TRUE $$,
  'Authenticated user can view visible tile configs'
);

-- Invisible tile config is not visible
SELECT is_empty(
  $$ SELECT * FROM public.tile_configs WHERE is_visible = FALSE $$,
  'Invisible tile config is not visible to authenticated user'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Anonymous user cannot see tile configs (policy is TO authenticated only)
SET LOCAL ROLE anon;

SELECT is_empty(
  $$ SELECT * FROM public.tile_configs WHERE is_visible = TRUE $$,
  'Anonymous user cannot see tile configs'
);

RESET ROLE;

SELECT * FROM finish();

ROLLBACK;
