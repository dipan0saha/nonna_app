BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(15);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'name_suggestion_likes'::name, 'name_suggestion_likes table should exist');
SELECT rls_enabled('public'::name, 'name_suggestion_likes'::name, 'RLS should be enabled on name_suggestion_likes');

SELECT has_column('public'::name, 'name_suggestion_likes'::name, 'id'::name,                  'name_suggestion_likes has id');
SELECT has_column('public'::name, 'name_suggestion_likes'::name, 'name_suggestion_id'::name,  'name_suggestion_likes has name_suggestion_id');
SELECT has_column('public'::name, 'name_suggestion_likes'::name, 'user_id'::name,             'name_suggestion_likes has user_id');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'name_suggestion_likes', 'Members can view name suggestion likes', 'policy exists: members view likes');
SELECT has_policy('public', 'name_suggestion_likes', 'Members can like name suggestions',      'policy exists: members like suggestions');
SELECT has_policy('public', 'name_suggestion_likes', 'Users can unlike (delete own like)',     'policy exists: users unlike');

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

-- User1 likes Oliver, user2 likes Oliver
INSERT INTO public.name_suggestion_likes (id, name_suggestion_id, user_id) VALUES
  ('99999999-0000-0000-0000-000000000001', '88888888-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001'),
  ('99999999-0000-0000-0000-000000000002', '88888888-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002');

-- ==================== Functional Tests ====================

-- Member can view likes
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.name_suggestion_likes
     WHERE name_suggestion_id = '88888888-0000-0000-0000-000000000001' $$,
  'Member can view name suggestion likes'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view likes
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.name_suggestion_likes
     WHERE name_suggestion_id = '88888888-0000-0000-0000-000000000001' $$,
  'Non-member cannot view name suggestion likes'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member can like a suggestion (user2 likes Emma)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.name_suggestion_likes (id, name_suggestion_id, user_id)
     VALUES ('99999999-0000-0000-0000-000000000003',
             '88888888-0000-0000-0000-000000000002',
             'aaaaaaaa-0000-0000-0000-000000000002') $$,
  'Member can like a name suggestion'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot like
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.name_suggestion_likes (id, name_suggestion_id, user_id)
     VALUES ('99999999-0000-0000-0000-000000000099',
             '88888888-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003') $$,
  '42501', NULL,
  'Non-member cannot like name suggestion'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 can unlike own like
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.name_suggestion_likes
     WHERE id = '99999999-0000-0000-0000-000000000001' $$,
  'User can unlike own name suggestion like'
);

-- User1 cannot delete user2 like (silently 0 rows)
SELECT lives_ok(
  $$ DELETE FROM public.name_suggestion_likes
     WHERE id = '99999999-0000-0000-0000-000000000002' $$,
  'User cannot unlike another user''s like (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 like still exists
SELECT isnt_empty(
  $$ SELECT * FROM public.name_suggestion_likes WHERE id = '99999999-0000-0000-0000-000000000002' $$,
  'User2 like still exists after user1 attempted deletion'
);

SELECT * FROM finish();

ROLLBACK;
