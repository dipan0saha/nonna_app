BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(12);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'user_stats'::name, 'user_stats table should exist');
SELECT rls_enabled('public'::name, 'user_stats'::name, 'RLS should be enabled on user_stats');

SELECT has_column('public'::name, 'user_stats'::name, 'user_id'::name,                'user_stats has user_id');
SELECT has_column('public'::name, 'user_stats'::name, 'events_attended_count'::name,  'user_stats has events_attended_count');
SELECT has_column('public'::name, 'user_stats'::name, 'items_purchased_count'::name,  'user_stats has items_purchased_count');
SELECT has_column('public'::name, 'user_stats'::name, 'photos_squished_count'::name,  'user_stats has photos_squished_count');
SELECT has_column('public'::name, 'user_stats'::name, 'comments_added_count'::name,   'user_stats has comments_added_count');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'user_stats', 'Users can view own stats',                       'policy exists: view own stats');
SELECT has_policy('public', 'user_stats', 'Users in same baby profile can view stats',      'policy exists: same baby stats');

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

INSERT INTO public.user_stats (user_id, events_attended_count, items_purchased_count, photos_squished_count, comments_added_count) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 5, 3, 10, 7),
  ('aaaaaaaa-0000-0000-0000-000000000002', 2, 1,  4, 3),
  ('aaaaaaaa-0000-0000-0000-000000000003', 1, 0,  0, 0);

-- ==================== Functional Tests ====================

-- User1 can view own stats
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.user_stats WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User can view own stats'
);

-- User1 cannot view user3 stats (not in same baby)
SELECT is_empty(
  $$ SELECT * FROM public.user_stats WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000003' $$,
  'User cannot view stats of user not in same baby'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User2 (same baby as user1) can view user1 stats
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.user_stats WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User in same baby can view co-member stats'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
