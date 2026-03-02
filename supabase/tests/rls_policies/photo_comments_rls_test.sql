BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(19);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'photo_comments'::name, 'photo_comments table should exist');
SELECT rls_enabled('public'::name, 'photo_comments'::name, 'RLS should be enabled on photo_comments');

SELECT has_column('public'::name, 'photo_comments'::name, 'id'::name,         'photo_comments has id');
SELECT has_column('public'::name, 'photo_comments'::name, 'photo_id'::name,   'photo_comments has photo_id');
SELECT has_column('public'::name, 'photo_comments'::name, 'user_id'::name,    'photo_comments has user_id');
SELECT has_column('public'::name, 'photo_comments'::name, 'body'::name,       'photo_comments has body');
SELECT has_column('public'::name, 'photo_comments'::name, 'deleted_at'::name, 'photo_comments has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'photo_comments', 'Members can view photo comments',         'policy exists: members view photo comments');
SELECT has_policy('public', 'photo_comments', 'Members can add photo comments',          'policy exists: members add photo comments');
SELECT has_policy('public', 'photo_comments', 'Users can update own photo comments',     'policy exists: users update own photo comments');
SELECT has_policy('public', 'photo_comments', 'Users and owners can delete photo comments', 'policy exists: users and owners delete photo comments');

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

INSERT INTO public.photos (id, baby_profile_id, uploaded_by_user_id, storage_path) VALUES
  ('dddddddd-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001', 'photos/photo1.jpg');

INSERT INTO public.photo_comments (id, photo_id, user_id, body) VALUES
  ('ffffffff-0000-0000-0000-000000000001', 'dddddddd-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'User1 comment'),
  ('ffffffff-0000-0000-0000-000000000002', 'dddddddd-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'User2 comment');

-- ==================== Functional Tests ====================

-- Follower can view comments
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.photo_comments
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Member can view photo comments'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view comments
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.photo_comments
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Non-member cannot view photo comments'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower can add comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.photo_comments (id, photo_id, user_id, body)
     VALUES ('ffffffff-0000-0000-0000-000000000003',
             'dddddddd-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'Another comment') $$,
  'Member (follower) can add photo comment'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot add comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.photo_comments (id, photo_id, user_id, body)
     VALUES ('ffffffff-0000-0000-0000-000000000099',
             'dddddddd-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'Unauthorized comment') $$,
  '42501', NULL,
  'Non-member cannot add photo comment'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 can update own comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.photo_comments SET body = 'Updated comment'
     WHERE id = 'ffffffff-0000-0000-0000-000000000001' $$,
  'User can update own photo comment'
);

-- User1 cannot update user2 comment (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.photo_comments SET body = 'Hacked comment'
     WHERE id = 'ffffffff-0000-0000-0000-000000000002' $$,
  'User cannot update another user''s photo comment (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 comment unchanged
SELECT is(
  (SELECT body FROM public.photo_comments WHERE id = 'ffffffff-0000-0000-0000-000000000002'),
  'User2 comment',
  'User2 photo comment body was not changed by user1'
);

-- Owner (user1) can delete user2 comment
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.photo_comments WHERE id = 'ffffffff-0000-0000-0000-000000000002' $$,
  'Owner can delete another user''s photo comment'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
