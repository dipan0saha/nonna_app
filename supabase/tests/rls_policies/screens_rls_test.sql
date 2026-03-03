BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(8);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'screens'::name, 'screens table should exist');
SELECT rls_enabled('public'::name, 'screens'::name, 'RLS should be enabled on screens');

SELECT has_column('public'::name, 'screens'::name, 'id'::name,          'screens has id');
SELECT has_column('public'::name, 'screens'::name, 'screen_name'::name, 'screens has screen_name');
SELECT has_column('public'::name, 'screens'::name, 'is_active'::name,   'screens has is_active');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'screens', 'Anyone can view screens', 'policy exists: anyone view screens');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com');

INSERT INTO public.screens (id, screen_name, is_active) VALUES
  ('11111111-0000-0001-0000-000000000001', 'home_screen',     TRUE),
  ('11111111-0000-0001-0000-000000000002', 'inactive_screen', FALSE);

-- ==================== Functional Tests ====================

-- Authenticated user can view active screen
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.screens WHERE screen_name = 'home_screen' $$,
  'Authenticated user can view active screen'
);

-- Inactive screen is not visible
SELECT is_empty(
  $$ SELECT * FROM public.screens WHERE screen_name = 'inactive_screen' $$,
  'Inactive screen is not visible to authenticated user'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
