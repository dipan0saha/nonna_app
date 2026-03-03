BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(20);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'photos'::name, 'photos table should exist');
SELECT rls_enabled('public'::name, 'photos'::name, 'RLS should be enabled on photos');

SELECT has_column('public'::name, 'photos'::name, 'id'::name,                  'photos has id');
SELECT has_column('public'::name, 'photos'::name, 'baby_profile_id'::name,     'photos has baby_profile_id');
SELECT has_column('public'::name, 'photos'::name, 'uploaded_by_user_id'::name, 'photos has uploaded_by_user_id');
SELECT has_column('public'::name, 'photos'::name, 'storage_path'::name,        'photos has storage_path');
SELECT has_column('public'::name, 'photos'::name, 'deleted_at'::name,          'photos has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'photos', 'Members can view photos',   'policy exists: members view photos');
SELECT has_policy('public', 'photos', 'Owners can upload photos',  'policy exists: owners upload photos');
SELECT has_policy('public', 'photos', 'Owners can update photos',  'policy exists: owners update photos');
SELECT has_policy('public', 'photos', 'Owners can delete photos',  'policy exists: owners delete photos');

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

-- ==================== Functional Tests ====================

-- Owner can view photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.photos WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Owner can view photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower can view photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.photos WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Follower can view photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.photos WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Non-member cannot view photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can upload photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.photos (id, baby_profile_id, uploaded_by_user_id, storage_path)
     VALUES ('dddddddd-0000-0000-0000-000000000002',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000001',
             'photos/photo2.jpg') $$,
  'Owner can upload photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot upload photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.photos (id, baby_profile_id, uploaded_by_user_id, storage_path)
     VALUES ('dddddddd-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'photos/follower.jpg') $$,
  '42501', NULL,
  'Follower cannot upload photo'
);

-- Owner can update photo metadata
RESET ROLE;
RESET "request.jwt.claims";

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.photos SET storage_path = 'photos/updated.jpg'
     WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Owner can update photo'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot update photo (silently 0 rows)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.photos SET storage_path = 'photos/hacked.jpg'
     WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Follower update attempt does not error'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify storage_path unchanged by follower
SELECT is(
  (SELECT storage_path FROM public.photos WHERE id = 'dddddddd-0000-0000-0000-000000000001'),
  'photos/updated.jpg',
  'Follower cannot change photo storage path'
);

-- Owner can delete photo
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.photos WHERE id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Owner can delete photo'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
