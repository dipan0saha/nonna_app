BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(9);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'activity_events'::name, 'activity_events table should exist');
SELECT rls_enabled('public'::name, 'activity_events'::name, 'RLS should be enabled on activity_events');

SELECT has_column('public'::name, 'activity_events'::name, 'id'::name,              'activity_events has id');
SELECT has_column('public'::name, 'activity_events'::name, 'baby_profile_id'::name, 'activity_events has baby_profile_id');
SELECT has_column('public'::name, 'activity_events'::name, 'actor_user_id'::name,   'activity_events has actor_user_id');
SELECT has_column('public'::name, 'activity_events'::name, 'type'::name,            'activity_events has type');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'activity_events', 'Members can view activity events', 'policy exists: members view activity events');

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

INSERT INTO public.activity_events (id, baby_profile_id, actor_user_id, type) VALUES
  ('bbbbbbbb-0000-0001-0000-000000000001',
   'bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'photo_uploaded');

-- ==================== Functional Tests ====================

-- Member can view activity events
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.activity_events
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Member can view activity events'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view activity events
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.activity_events
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view activity events'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
