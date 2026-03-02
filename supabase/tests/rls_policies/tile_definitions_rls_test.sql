BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(8);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'tile_definitions'::name, 'tile_definitions table should exist');
SELECT rls_enabled('public'::name, 'tile_definitions'::name, 'RLS should be enabled on tile_definitions');

SELECT has_column('public'::name, 'tile_definitions'::name, 'id'::name,         'tile_definitions has id');
SELECT has_column('public'::name, 'tile_definitions'::name, 'tile_type'::name,  'tile_definitions has tile_type');
SELECT has_column('public'::name, 'tile_definitions'::name, 'is_active'::name,  'tile_definitions has is_active');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'tile_definitions', 'Anyone can view tile definitions', 'policy exists: anyone view tile definitions');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com');

INSERT INTO public.tile_definitions (id, tile_type, is_active) VALUES
  ('22222222-0000-0001-0000-000000000001', 'photo_gallery', TRUE),
  ('22222222-0000-0001-0000-000000000002', 'countdown',     FALSE);

-- ==================== Functional Tests ====================

-- Authenticated user can view active tile definition
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.tile_definitions WHERE tile_type = 'photo_gallery' $$,
  'Authenticated user can view active tile definition'
);

-- Inactive tile definition is not visible
SELECT is_empty(
  $$ SELECT * FROM public.tile_definitions WHERE tile_type = 'countdown' $$,
  'Inactive tile definition is not visible to authenticated user'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
