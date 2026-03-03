BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(18);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'baby_memberships'::name, 'baby_memberships table should exist');
SELECT rls_enabled('public'::name, 'baby_memberships'::name, 'RLS should be enabled on baby_memberships');

SELECT has_column('public'::name, 'baby_memberships'::name, 'id'::name,              'baby_memberships has id');
SELECT has_column('public'::name, 'baby_memberships'::name, 'baby_profile_id'::name, 'baby_memberships has baby_profile_id');
SELECT has_column('public'::name, 'baby_memberships'::name, 'user_id'::name,         'baby_memberships has user_id');
SELECT has_column('public'::name, 'baby_memberships'::name, 'role'::name,            'baby_memberships has role');
SELECT has_column('public'::name, 'baby_memberships'::name, 'removed_at'::name,      'baby_memberships has removed_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'baby_memberships', 'Members can view memberships for their babies', 'policy exists: members view memberships');
SELECT has_policy('public', 'baby_memberships', 'Owners can manage memberships',                 'policy exists: owners manage memberships');
SELECT has_policy('public', 'baby_memberships', 'Users can create their own membership',         'policy exists: users create own membership');
SELECT has_policy('public', 'baby_memberships', 'Users can leave (soft delete own membership)',  'policy exists: users soft delete own membership');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'user4@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower');

-- ==================== Functional Tests ====================

-- Member can view memberships for their baby
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.baby_memberships
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Member can view memberships for their baby'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view memberships
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.baby_memberships
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view memberships'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can add a new member (user4)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role)
     VALUES ('cccccccc-0000-0000-0000-000000000003',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000004',
             'follower') $$,
  'Owner can add new member'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot insert membership for user3
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role)
     VALUES ('cccccccc-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'follower') $$,
  '42501', NULL,
  'Follower cannot add members for others'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User3 can create own membership (self-join)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role)
     VALUES ('cccccccc-0000-0000-0000-000000000004',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'follower') $$,
  'User can create own membership (self-join)'
);

-- User3 cannot create membership for user4
SELECT throws_ok(
  $$ INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role)
     VALUES ('cccccccc-0000-0000-0000-000000000098',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000004',
             'follower') $$,
  '42501', NULL,
  'User cannot create membership for another user'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User2 can soft-delete own membership (leave)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.baby_memberships
     SET removed_at = NOW()
     WHERE id = 'cccccccc-0000-0000-0000-000000000002' $$,
  'User can soft-delete (leave) own membership'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
