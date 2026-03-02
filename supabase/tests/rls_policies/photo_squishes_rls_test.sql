BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(15);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'photo_squishes'::name, 'photo_squishes table should exist');
SELECT rls_enabled('public'::name, 'photo_squishes'::name, 'RLS should be enabled on photo_squishes');

SELECT has_column('public'::name, 'photo_squishes'::name, 'id'::name,       'photo_squishes has id');
SELECT has_column('public'::name, 'photo_squishes'::name, 'photo_id'::name, 'photo_squishes has photo_id');
SELECT has_column('public'::name, 'photo_squishes'::name, 'user_id'::name,  'photo_squishes has user_id');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'photo_squishes', 'Members can view photo squishes',      'policy exists: members view squishes');
SELECT has_policy('public', 'photo_squishes', 'Members can squish photos',            'policy exists: members squish photos');
SELECT has_policy('public', 'photo_squishes', 'Users can unsquish (delete own squish)', 'policy exists: users unsquish');

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
  ('dddddddd-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'photos/photo1.jpg'),
  ('dddddddd-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'photos/photo2.jpg');

-- Existing squishes for view/delete tests
INSERT INTO public.photo_squishes (id, photo_id, user_id) VALUES
  ('eeeeeeee-0000-0000-0000-000000000001', 'dddddddd-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001'),
  ('eeeeeeee-0000-0000-0000-000000000002', 'dddddddd-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000002');

-- ==================== Functional Tests ====================

-- Member can view squishes
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.photo_squishes
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Member can view photo squishes'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view squishes
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.photo_squishes
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Non-member cannot view photo squishes'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member (follower) can squish photo2
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.photo_squishes (id, photo_id, user_id)
     VALUES ('eeeeeeee-0000-0000-0000-000000000003',
             'dddddddd-0000-0000-0000-000000000002',
             'aaaaaaaa-0000-0000-0000-000000000002') $$,
  'Member can squish a photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot squish
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.photo_squishes (id, photo_id, user_id)
     VALUES ('eeeeeeee-0000-0000-0000-000000000099',
             'dddddddd-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003') $$,
  '42501', NULL,
  'Non-member cannot squish photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- User1 can unsquish own squish
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.photo_squishes WHERE id = 'eeeeeeee-0000-0000-0000-000000000001' $$,
  'User can unsquish own squish'
);

-- User1 cannot delete user2 squish (silently 0 rows)
SELECT lives_ok(
  $$ DELETE FROM public.photo_squishes WHERE id = 'eeeeeeee-0000-0000-0000-000000000002' $$,
  'User cannot delete another user''s squish (silently 0 rows)'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify user2 squish still exists
SELECT isnt_empty(
  $$ SELECT * FROM public.photo_squishes WHERE id = 'eeeeeeee-0000-0000-0000-000000000002' $$,
  'User2 squish still exists after user1 attempted deletion'
);

SELECT * FROM finish();

ROLLBACK;
