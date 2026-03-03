BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(14);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'notifications'::name, 'notifications table should exist');
SELECT rls_enabled('public'::name, 'notifications'::name, 'RLS should be enabled on notifications');

SELECT has_column('public'::name, 'notifications'::name, 'id'::name,                 'notifications has id');
SELECT has_column('public'::name, 'notifications'::name, 'recipient_user_id'::name,  'notifications has recipient_user_id');
SELECT has_column('public'::name, 'notifications'::name, 'baby_profile_id'::name,    'notifications has baby_profile_id');
SELECT has_column('public'::name, 'notifications'::name, 'type'::name,               'notifications has type');
SELECT has_column('public'::name, 'notifications'::name, 'read_at'::name,            'notifications has read_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'notifications', 'Users can view own notifications',                   'policy exists: users view own notifications');
SELECT has_policy('public', 'notifications', 'Users can update own notifications (mark as read)',   'policy exists: users update own notifications');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com');

INSERT INTO public.notifications (id, recipient_user_id, type) VALUES
  ('aaaaaaaa-0000-0001-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'new_photo');

-- ==================== Functional Tests ====================

-- User1 can view own notification
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.notifications
     WHERE recipient_user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User can view own notifications'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User2 cannot view user1 notifications
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.notifications
     WHERE recipient_user_id = 'aaaaaaaa-0000-0000-0000-000000000001' $$,
  'User cannot view another user''s notifications'
);

-- User2 cannot update user1 notification (silently 0 rows)
SELECT lives_ok(
  $$ UPDATE public.notifications SET read_at = NOW()
     WHERE id = 'aaaaaaaa-0000-0001-0000-000000000001' $$,
  'User cannot update another user''s notification (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user1 notification read_at is still NULL (user2 failed to update it)
SELECT is(
  (SELECT read_at FROM public.notifications WHERE id = 'aaaaaaaa-0000-0001-0000-000000000001'),
  NULL::timestamptz,
  'Notification read_at not changed by non-owner'
);

-- User1 can mark own notification as read
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.notifications SET read_at = NOW()
     WHERE id = 'aaaaaaaa-0000-0001-0000-000000000001' $$,
  'User can mark own notification as read'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
