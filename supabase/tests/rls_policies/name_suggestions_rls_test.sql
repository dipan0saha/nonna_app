BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(19);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'name_suggestions'::name, 'name_suggestions table should exist');
SELECT rls_enabled('public'::name, 'name_suggestions'::name, 'RLS should be enabled on name_suggestions');

SELECT has_column('public'::name, 'name_suggestions'::name, 'id'::name,              'name_suggestions has id');
SELECT has_column('public'::name, 'name_suggestions'::name, 'baby_profile_id'::name, 'name_suggestions has baby_profile_id');
SELECT has_column('public'::name, 'name_suggestions'::name, 'user_id'::name,         'name_suggestions has user_id');
SELECT has_column('public'::name, 'name_suggestions'::name, 'suggested_name'::name,  'name_suggestions has suggested_name');
SELECT has_column('public'::name, 'name_suggestions'::name, 'deleted_at'::name,      'name_suggestions has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'name_suggestions', 'Members can view name suggestions',      'policy exists: members view name suggestions');
SELECT has_policy('public', 'name_suggestions', 'Members can create name suggestions',    'policy exists: members create name suggestions');
SELECT has_policy('public', 'name_suggestions', 'Users can update own suggestions',       'policy exists: users update own suggestions');
SELECT has_policy('public', 'name_suggestions', 'Users and owners can delete name suggestions', 'policy exists: users and owners delete suggestions');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower');

INSERT INTO public.name_suggestions (id, baby_profile_id, user_id, suggested_name) VALUES
  ('88888888-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'Oliver'),
  ('88888888-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'Emma');

-- ==================== Functional Tests ====================

-- Follower can view suggestions
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.name_suggestions
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Member can view name suggestions'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view suggestions
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.name_suggestions
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view name suggestions'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member (follower) can create suggestion
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.name_suggestions (id, baby_profile_id, user_id, suggested_name)
     VALUES ('88888888-0000-0000-0000-000000000003',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'Sophia') $$,
  'Member can create name suggestion'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot create suggestion
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.name_suggestions (id, baby_profile_id, user_id, suggested_name)
     VALUES ('88888888-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'Unauthorized') $$,
  '42501', NULL,
  'Non-member cannot create name suggestion'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 can update own suggestion
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.name_suggestions SET suggested_name = 'Liam'
     WHERE id = '88888888-0000-0000-0000-000000000001' $$,
  'User can update own name suggestion'
);

-- User1 cannot update user2 suggestion (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.name_suggestions SET suggested_name = 'Hacked'
     WHERE id = '88888888-0000-0000-0000-000000000002' $$,
  'User cannot update another user''s suggestion (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 suggestion unchanged
SELECT is(
  (SELECT suggested_name FROM public.name_suggestions WHERE id = '88888888-0000-0000-0000-000000000002'),
  'Emma',
  'User2 suggestion was not changed by user1'
);

-- Owner (user1) can delete user2 suggestion
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.name_suggestions WHERE id = '88888888-0000-0000-0000-000000000002' $$,
  'Owner can delete another user''s name suggestion'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
