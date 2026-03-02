BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(19);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'event_comments'::name, 'event_comments table should exist');
SELECT rls_enabled('public'::name, 'event_comments'::name, 'RLS should be enabled on event_comments');

SELECT has_column('public'::name, 'event_comments'::name, 'id'::name,         'event_comments has id');
SELECT has_column('public'::name, 'event_comments'::name, 'event_id'::name,   'event_comments has event_id');
SELECT has_column('public'::name, 'event_comments'::name, 'user_id'::name,    'event_comments has user_id');
SELECT has_column('public'::name, 'event_comments'::name, 'body'::name,       'event_comments has body');
SELECT has_column('public'::name, 'event_comments'::name, 'deleted_at'::name, 'event_comments has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'event_comments', 'Members can view event comments',         'policy exists: members view event comments');
SELECT has_policy('public', 'event_comments', 'Members can add event comments',          'policy exists: members add event comments');
SELECT has_policy('public', 'event_comments', 'Users can update own event comments',     'policy exists: users update own event comments');
SELECT has_policy('public', 'event_comments', 'Users and owners can delete event comments', 'policy exists: users and owners delete event comments');

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

INSERT INTO public.event_comments (id, event_id, user_id, body) VALUES
  ('33333333-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'User1 event comment'),
  ('33333333-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'User2 event comment');

-- ==================== Functional Tests ====================

-- Follower can view event comments
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.event_comments
     WHERE event_id = '22222222-0000-0000-0000-000000000001' $$,
  'Member can view event comments'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view event comments
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.event_comments
     WHERE event_id = '22222222-0000-0000-0000-000000000001' $$,
  'Non-member cannot view event comments'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower can add event comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.event_comments (id, event_id, user_id, body)
     VALUES ('33333333-0000-0000-0000-000000000003',
             '22222222-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'Another event comment') $$,
  'Member (follower) can add event comment'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot add event comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.event_comments (id, event_id, user_id, body)
     VALUES ('33333333-0000-0000-0000-000000000099',
             '22222222-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'Unauthorized event comment') $$,
  '42501', NULL,
  'Non-member cannot add event comment'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 can update own comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.event_comments SET body = 'Updated event comment'
     WHERE id = '33333333-0000-0000-0000-000000000001' $$,
  'User can update own event comment'
);

-- User1 cannot update user2 comment (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.event_comments SET body = 'Hacked event comment'
     WHERE id = '33333333-0000-0000-0000-000000000002' $$,
  'User cannot update another user''s event comment (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 comment unchanged
SELECT is(
  (SELECT body FROM public.event_comments WHERE id = '33333333-0000-0000-0000-000000000002'),
  'User2 event comment',
  'User2 event comment was not changed by user1'
);

-- Owner (user1) can delete user2 comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.event_comments WHERE id = '33333333-0000-0000-0000-000000000002' $$,
  'Owner can delete another user''s event comment'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
