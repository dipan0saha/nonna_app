BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(17);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'profiles'::name, 'profiles table should exist');
SELECT rls_enabled('public'::name, 'profiles'::name, 'RLS should be enabled on profiles');
SELECT has_fk('public'::name, 'profiles'::name, 'profiles should have foreign key constraint');

SELECT has_column('public'::name, 'profiles'::name, 'user_id'::name,      'profiles has user_id');
SELECT has_column('public'::name, 'profiles'::name, 'display_name'::name, 'profiles has display_name');
SELECT has_column('public'::name, 'profiles'::name, 'avatar_url'::name,   'profiles has avatar_url');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'profiles', 'Users can view all profiles',   'policy exists: view all profiles');
SELECT has_policy('public', 'profiles', 'Users can update own profile',   'policy exists: update own profile');
SELECT has_policy('public', 'profiles', 'Users can insert own profile',   'policy exists: insert own profile');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com');

INSERT INTO public.profiles (user_id, display_name) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'User One'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'User Two');

-- ==================== Functional Tests ====================

-- User1 can view own profile
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.profiles WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'Authenticated user can view own profile'
);

-- User1 can view user2 profile (view all policy)
SELECT isnt_empty(
  $$ SELECT * FROM public.profiles WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000002' $$,
  'Authenticated user can view other profiles (view all policy)'
);

-- User1 can update own profile
SELECT lives_ok(
  $$ UPDATE public.profiles SET display_name = 'User One Updated'
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User can update own profile'
);

-- User1 cannot update user2 profile (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.profiles SET display_name = 'Hacked'
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000002' $$,
  'Attempted update of other profile does not error'
);

-- User1 cannot delete user2 profile (no delete policy; silently 0 rows)
SELECT lives_ok(
  $$ DELETE FROM public.profiles WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000002' $$,
  'Attempted delete of other profile does not error'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 was NOT changed
SELECT is(
  (SELECT display_name FROM public.profiles
   WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000002'),
  'User Two',
  'User cannot update another user''s profile'
);

-- User1 cannot insert a profile for user2
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.profiles (user_id, display_name)
     VALUES ('aaaaaaaa-0000-0000-0000-000000000002', 'Fake') $$,
  '42501', NULL,
  'User cannot insert profile for another user'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User3 can insert own profile
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.profiles (user_id, display_name)
     VALUES ('aaaaaaaa-0000-0000-0000-000000000003', 'User Three') $$,
  'User can insert their own profile'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
