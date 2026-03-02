BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(17);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'invitations'::name, 'invitations table should exist');
SELECT rls_enabled('public'::name, 'invitations'::name, 'RLS should be enabled on invitations');

SELECT has_column('public'::name, 'invitations'::name, 'id'::name,                  'invitations has id');
SELECT has_column('public'::name, 'invitations'::name, 'baby_profile_id'::name,     'invitations has baby_profile_id');
SELECT has_column('public'::name, 'invitations'::name, 'invited_by_user_id'::name,  'invitations has invited_by_user_id');
SELECT has_column('public'::name, 'invitations'::name, 'invitee_email'::name,       'invitations has invitee_email');
SELECT has_column('public'::name, 'invitations'::name, 'token_hash'::name,          'invitations has token_hash');
SELECT has_column('public'::name, 'invitations'::name, 'expires_at'::name,          'invitations has expires_at');
SELECT has_column('public'::name, 'invitations'::name, 'status'::name,              'invitations has status');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'invitations', 'Owners can view invitations for their babies', 'policy exists: owners view invitations');
SELECT has_policy('public', 'invitations', 'Owners can create invitations',                'policy exists: owners create invitations');
SELECT has_policy('public', 'invitations', 'Owners can update invitations (revoke)',        'policy exists: owners update invitations');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower');

INSERT INTO public.invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status) VALUES
  ('aaaaaaaa-0000-0000-0002-000000000001',
   'bbbbbbbb-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   'invite@test.com',
   'testhash001',
   NOW() + INTERVAL '7 days',
   'pending');

-- ==================== Functional Tests ====================

-- Owner can view invitations
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.invitations
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Owner can view invitations for their baby'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot view invitations
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.invitations
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Follower cannot view invitations'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can create invitation
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status)
     VALUES ('aaaaaaaa-0000-0000-0002-000000000002',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000001',
             'new@test.com', 'testhash002',
             NOW() + INTERVAL '7 days', 'pending') $$,
  'Owner can create invitation'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot create invitation
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status)
     VALUES ('aaaaaaaa-0000-0000-0002-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'hack@test.com', 'testhash099',
             NOW() + INTERVAL '7 days', 'pending') $$,
  '42501', NULL,
  'Follower cannot create invitation'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can update (revoke) invitation
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.invitations SET status = 'revoked'
     WHERE id = 'aaaaaaaa-0000-0000-0002-000000000001' $$,
  'Owner can revoke invitation'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
