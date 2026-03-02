BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(20);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'baby_profiles'::name, 'baby_profiles table should exist');
SELECT rls_enabled('public'::name, 'baby_profiles'::name, 'RLS should be enabled on baby_profiles');

SELECT has_column('public'::name, 'baby_profiles'::name, 'id'::name,                  'baby_profiles has id');
SELECT has_column('public'::name, 'baby_profiles'::name, 'name'::name,                'baby_profiles has name');
SELECT has_column('public'::name, 'baby_profiles'::name, 'expected_birth_date'::name, 'baby_profiles has expected_birth_date');
SELECT has_column('public'::name, 'baby_profiles'::name, 'actual_birth_date'::name,   'baby_profiles has actual_birth_date');
SELECT has_column('public'::name, 'baby_profiles'::name, 'gender'::name,              'baby_profiles has gender');
SELECT has_column('public'::name, 'baby_profiles'::name, 'deleted_at'::name,          'baby_profiles has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'baby_profiles', 'Members can view baby profiles',                  'policy exists: members view');
SELECT has_policy('public', 'baby_profiles', 'Owners can update baby profiles',                 'policy exists: owners update');
SELECT has_policy('public', 'baby_profiles', 'Authenticated users can create baby profiles',    'policy exists: authenticated insert');
SELECT has_policy('public', 'baby_profiles', 'Owners can delete baby profiles',                 'policy exists: owners delete');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'user4@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby'),
  ('bbbbbbbb-0000-0000-0000-000000000003', 'Baby to Delete');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower'),
  ('cccccccc-0000-0000-0000-000000000005', 'bbbbbbbb-0000-0000-0000-000000000003', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner');

-- ==================== Functional Tests ====================

-- Owner can view baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.baby_profiles WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Owner can view baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower can view baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.baby_profiles WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Follower can view baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.baby_profiles WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can update baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.baby_profiles SET name = 'Updated Baby'
     WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Owner can update baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot update baby (silently 0 rows)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.baby_profiles SET name = 'Hacked Baby'
     WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Follower update attempt does not error'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify follower did not change name
SELECT is(
  (SELECT name FROM public.baby_profiles WHERE id = 'bbbbbbbb-0000-0000-0000-000000000001'),
  'Updated Baby',
  'Follower cannot change baby profile name'
);

-- Authenticated user can insert new baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000004", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.baby_profiles (id, name)
     VALUES ('bbbbbbbb-0000-0000-0000-000000000002', 'New Baby') $$,
  'Authenticated user can create a baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can delete baby (remove FK child first as superuser)
DELETE FROM public.baby_memberships
WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000003';

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.baby_profiles WHERE id = 'bbbbbbbb-0000-0000-0000-000000000003' $$,
  'Owner can delete baby profile'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
