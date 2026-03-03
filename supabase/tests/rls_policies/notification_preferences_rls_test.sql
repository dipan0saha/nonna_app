BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(16);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'notification_preferences'::name, 'notification_preferences table should exist');
SELECT rls_enabled('public'::name, 'notification_preferences'::name, 'RLS should be enabled on notification_preferences');

SELECT has_column('public'::name, 'notification_preferences'::name, 'user_id'::name,              'notification_preferences has user_id');
SELECT has_column('public'::name, 'notification_preferences'::name, 'push_new_photos'::name,      'notification_preferences has push_new_photos');
SELECT has_column('public'::name, 'notification_preferences'::name, 'push_new_comments'::name,    'notification_preferences has push_new_comments');
SELECT has_column('public'::name, 'notification_preferences'::name, 'email_weekly_digest'::name,  'notification_preferences has email_weekly_digest');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'notification_preferences', 'Users can view own notification preferences',   'policy exists: view own prefs');
SELECT has_policy('public', 'notification_preferences', 'Users can update own notification preferences', 'policy exists: update own prefs');
SELECT has_policy('public', 'notification_preferences', 'Users can insert own notification preferences', 'policy exists: insert own prefs');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'user4@test.com');

INSERT INTO public.notification_preferences (user_id, push_new_photos, push_new_comments, email_weekly_digest) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', TRUE, TRUE, TRUE),
  ('aaaaaaaa-0000-0000-0000-000000000002', TRUE, TRUE, TRUE);

-- ==================== Functional Tests ====================

-- User1 can view own preferences
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.notification_preferences
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User can view own notification preferences'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User2 cannot view user1 preferences
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.notification_preferences
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User cannot view another user''s notification preferences'
);

-- User2 cannot update user1 preferences (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.notification_preferences SET push_new_photos = FALSE
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User cannot update another user''s notification preferences (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user1 preferences unchanged
SELECT is(
  (SELECT push_new_photos FROM public.notification_preferences
   WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  TRUE,
  'User1 push_new_photos was not changed by user2'
);

-- User1 can update own preferences
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.notification_preferences SET push_new_photos = FALSE
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User can update own notification preferences'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User3 can insert own preferences
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.notification_preferences (user_id)
     VALUES ('aaaaaaaa-0000-0000-0000-000000000003') $$,
  'User can insert own notification preferences'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 cannot insert preferences for user4
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.notification_preferences (user_id)
     VALUES ('aaaaaaaa-0000-0000-0000-000000000004') $$,
  '42501', NULL,
  'User cannot insert notification preferences for another user'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
