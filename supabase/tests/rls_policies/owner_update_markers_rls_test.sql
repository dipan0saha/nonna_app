BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(13);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'owner_update_markers'::name, 'owner_update_markers table should exist');
SELECT rls_enabled('public'::name, 'owner_update_markers'::name, 'RLS should be enabled on owner_update_markers');

SELECT has_column('public'::name, 'owner_update_markers'::name, 'id'::name,                    'owner_update_markers has id');
SELECT has_column('public'::name, 'owner_update_markers'::name, 'baby_profile_id'::name,       'owner_update_markers has baby_profile_id');
SELECT has_column('public'::name, 'owner_update_markers'::name, 'tiles_last_updated_at'::name, 'owner_update_markers has tiles_last_updated_at');
SELECT has_column('public'::name, 'owner_update_markers'::name, 'updated_by_user_id'::name,    'owner_update_markers has updated_by_user_id');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'owner_update_markers', 'Members can view owner update markers',  'policy exists: members view markers');
SELECT has_policy('public', 'owner_update_markers', 'Owners can manage owner update markers', 'policy exists: owners manage markers');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby 1'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'Test Baby 2');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower'),
  ('cccccccc-0000-0000-0000-000000000003', 'bbbbbbbb-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner');

INSERT INTO public.owner_update_markers (id, baby_profile_id, updated_by_user_id) VALUES
  ('00000000-0000-0000-0000-aaaaaaaaaaaa',
   'bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001');

-- ==================== Functional Tests ====================

-- Member can view marker
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.owner_update_markers
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Member can view owner update marker'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view marker
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.owner_update_markers
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view owner update marker'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can update marker
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.owner_update_markers
     SET tiles_last_updated_at = NOW()
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Owner can update owner update marker'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot insert marker for baby1 (not an owner)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.owner_update_markers (id, baby_profile_id, updated_by_user_id)
     VALUES ('00000000-0000-0000-0000-bbbbbbbbbbbb',
             'bbbbbbbb-0000-0000-0000-000000000002',
             'aaaaaaaa-0000-0000-0000-000000000002') $$,
  '42501', NULL,
  'Follower/non-owner cannot insert owner update marker'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can insert marker for baby2
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.owner_update_markers (id, baby_profile_id, updated_by_user_id)
     VALUES ('00000000-0000-0000-0000-cccccccccccc',
             'bbbbbbbb-0000-0000-0000-000000000002',
             'aaaaaaaa-0000-0000-0000-000000000001') $$,
  'Owner can insert owner update marker for their baby'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
