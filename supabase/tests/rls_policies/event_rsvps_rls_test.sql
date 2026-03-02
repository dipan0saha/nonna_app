BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(18);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'event_rsvps'::name, 'event_rsvps table should exist');
SELECT rls_enabled('public'::name, 'event_rsvps'::name, 'RLS should be enabled on event_rsvps');

SELECT has_column('public'::name, 'event_rsvps'::name, 'id'::name,       'event_rsvps has id');
SELECT has_column('public'::name, 'event_rsvps'::name, 'event_id'::name, 'event_rsvps has event_id');
SELECT has_column('public'::name, 'event_rsvps'::name, 'user_id'::name,  'event_rsvps has user_id');
SELECT has_column('public'::name, 'event_rsvps'::name, 'status'::name,   'event_rsvps has status');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'event_rsvps', 'Members can view event RSVPs',   'policy exists: members view RSVPs');
SELECT has_policy('public', 'event_rsvps', 'Members can create RSVPs',       'policy exists: members create RSVPs');
SELECT has_policy('public', 'event_rsvps', 'Users can update own RSVPs',     'policy exists: users update own RSVPs');
SELECT has_policy('public', 'event_rsvps', 'Users can delete own RSVPs',     'policy exists: users delete own RSVPs');

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

INSERT INTO public.event_rsvps (id, event_id, user_id, status) VALUES
  ('44444444-0000-0000-0000-000000000001',
   '22222222-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'going');

-- ==================== Functional Tests ====================

-- Member can view RSVPs
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.event_rsvps
     WHERE event_id = '22222222-0000-0000-0000-000000000001' $$,
  'Member can view event RSVPs'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view RSVPs
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.event_rsvps
     WHERE event_id = '22222222-0000-0000-0000-000000000001' $$,
  'Non-member cannot view event RSVPs'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member (follower) can create RSVP
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.event_rsvps (id, event_id, user_id, status)
     VALUES ('44444444-0000-0000-0000-000000000002',
             '22222222-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'going') $$,
  'Member can create event RSVP'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot create RSVP
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.event_rsvps (id, event_id, user_id, status)
     VALUES ('44444444-0000-0000-0000-000000000099',
             '22222222-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'going') $$,
  '42501', NULL,
  'Non-member cannot create event RSVP'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User2 can update own RSVP
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.event_rsvps SET status = 'maybe'
     WHERE id = '44444444-0000-0000-0000-000000000002' $$,
  'User can update own RSVP'
);

-- User2 cannot update user1 RSVP (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.event_rsvps SET status = 'not_going'
     WHERE id = '44444444-0000-0000-0000-000000000001' $$,
  'User cannot update another user''s RSVP (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user1 RSVP status unchanged
SELECT is(
  (SELECT status FROM public.event_rsvps WHERE id = '44444444-0000-0000-0000-000000000001'),
  'going',
  'User1 RSVP status was not changed by user2'
);

-- User2 can delete own RSVP
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.event_rsvps WHERE id = '44444444-0000-0000-0000-000000000002' $$,
  'User can delete own RSVP'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
