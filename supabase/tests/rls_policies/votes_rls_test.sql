BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(17);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'votes'::name, 'votes table should exist');
SELECT rls_enabled('public'::name, 'votes'::name, 'RLS should be enabled on votes');

SELECT has_column('public'::name, 'votes'::name, 'id'::name,              'votes has id');
SELECT has_column('public'::name, 'votes'::name, 'baby_profile_id'::name, 'votes has baby_profile_id');
SELECT has_column('public'::name, 'votes'::name, 'user_id'::name,         'votes has user_id');
SELECT has_column('public'::name, 'votes'::name, 'vote_type'::name,       'votes has vote_type');
SELECT has_column('public'::name, 'votes'::name, 'is_anonymous'::name,    'votes has is_anonymous');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'votes', 'Members can view non-anonymous votes', 'policy exists: members view non-anonymous votes');
SELECT has_policy('public', 'votes', 'Members can create votes',             'policy exists: members create votes');
SELECT has_policy('public', 'votes', 'Users can update own votes',           'policy exists: users update own votes');

-- ==================== Test Data ====================

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', 'user1@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'user2@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'user3@test.com'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'user4@test.com');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 'Test Baby');

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('cccccccc-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'owner'),
  ('cccccccc-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'follower'),
  ('cccccccc-0000-0000-0000-000000000003', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000004', 'follower');

-- vote1: user1 non-anonymous, vote2: user2 anonymous, vote3: user4 anonymous
INSERT INTO public.votes (id, baby_profile_id, user_id, vote_type, is_anonymous) VALUES
  ('77777777-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'boy',  FALSE),
  ('77777777-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002', 'girl', TRUE),
  ('77777777-0000-0000-0000-000000000003', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000004', 'boy',  TRUE);

-- ==================== Functional Tests ====================

-- User2 (follower) can see user1 non-anonymous vote
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.votes
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000001' AND is_anonymous = FALSE $$,
  'Member can view another member''s non-anonymous vote'
);

-- User2 can see own anonymous vote
SELECT isnt_empty(
  $$ SELECT * FROM public.votes
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000002' $$,
  'Member can view own anonymous vote'
);

-- User2 cannot see user4 anonymous vote
SELECT is_empty(
  $$ SELECT * FROM public.votes
     WHERE user_id = 'aaaaaaaa-0000-0000-0000-000000000004' $$,
  'Member cannot see another member''s anonymous vote'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot see any votes
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.votes
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot see votes'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member can create vote
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.votes (id, baby_profile_id, user_id, vote_type, is_anonymous)
     VALUES ('77777777-0000-0000-0000-000000000004',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'girl', FALSE) $$,
  'Member can create a vote'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot create vote
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.votes (id, baby_profile_id, user_id, vote_type, is_anonymous)
     VALUES ('77777777-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             'boy', FALSE) $$,
  '42501', NULL,
  'Non-member cannot create a vote'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 (owner) can update own vote
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.votes SET vote_type = 'girl'
     WHERE id = '77777777-0000-0000-0000-000000000001' $$,
  'User can update own vote'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
