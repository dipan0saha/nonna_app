BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(21);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'events'::name, 'events table should exist');
SELECT rls_enabled('public'::name, 'events'::name, 'RLS should be enabled on events');

SELECT has_column('public'::name, 'events'::name, 'id'::name,                 'events has id');
SELECT has_column('public'::name, 'events'::name, 'baby_profile_id'::name,    'events has baby_profile_id');
SELECT has_column('public'::name, 'events'::name, 'created_by_user_id'::name, 'events has created_by_user_id');
SELECT has_column('public'::name, 'events'::name, 'title'::name,              'events has title');
SELECT has_column('public'::name, 'events'::name, 'starts_at'::name,          'events has starts_at');
SELECT has_column('public'::name, 'events'::name, 'deleted_at'::name,         'events has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'events', 'Members can view events',   'policy exists: members view events');
SELECT has_policy('public', 'events', 'Owners can create events',  'policy exists: owners create events');
SELECT has_policy('public', 'events', 'Owners can update events',  'policy exists: owners update events');
SELECT has_policy('public', 'events', 'Owners can delete events',  'policy exists: owners delete events');

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

INSERT INTO public.events (id, baby_profile_id, created_by_user_id, title, starts_at) VALUES
  ('22222222-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001', 'Test Event', NOW() + INTERVAL '1 day');

-- ==================== Functional Tests ====================

-- Owner can view event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.events WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Owner can view event'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower can view event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.events WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Follower can view event'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.events WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Non-member cannot view event'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can create event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.events (id, baby_profile_id, created_by_user_id, title, starts_at)
     VALUES ('22222222-0000-0000-0000-000000000002',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000001',
             'New Event', NOW() + INTERVAL '2 days') $$,
  'Owner can create event'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot create event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.events (id, baby_profile_id, created_by_user_id, title, starts_at)
     VALUES ('22222222-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'Unauthorized Event', NOW() + INTERVAL '3 days') $$,
  '42501', NULL,
  'Follower cannot create event'
);

-- Owner can update event
RESET ROLE;
RESET "request.jwt.claims";

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.events SET title = 'Updated Event'
     WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Owner can update event'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot update event (silently 0 rows)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.events SET title = 'Hacked Event'
     WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Follower update attempt does not error'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify title unchanged by follower
SELECT is(
  (SELECT title FROM public.events WHERE id = '22222222-0000-0000-0000-000000000001'),
  'Updated Event',
  'Follower cannot change event title'
);

-- Owner can delete event
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.events WHERE id = '22222222-0000-0000-0000-000000000001' $$,
  'Owner can delete event'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
