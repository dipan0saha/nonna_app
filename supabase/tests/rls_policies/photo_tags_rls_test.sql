BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(11);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'photo_tags'::name, 'photo_tags table should exist');
SELECT rls_enabled('public'::name, 'photo_tags'::name, 'RLS should be enabled on photo_tags');

SELECT has_column('public'::name, 'photo_tags'::name, 'id'::name,       'photo_tags has id');
SELECT has_column('public'::name, 'photo_tags'::name, 'photo_id'::name, 'photo_tags has photo_id');
SELECT has_column('public'::name, 'photo_tags'::name, 'tag'::name,      'photo_tags has tag');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'photo_tags', 'Members can view photo tags',   'policy exists: members view photo tags');
SELECT has_policy('public', 'photo_tags', 'Owners can manage photo tags',  'policy exists: owners manage photo tags');

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

INSERT INTO public.photo_tags (id, photo_id, tag) VALUES
  ('11111111-0000-0000-0000-000000000001', 'dddddddd-0000-0000-0000-000000000001', 'cute');

-- ==================== Functional Tests ====================

-- Member can view tags
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.photo_tags
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Member can view photo tags'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view tags
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.photo_tags
     WHERE photo_id = 'dddddddd-0000-0000-0000-000000000001' $$,
  'Non-member cannot view photo tags'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can insert tag
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.photo_tags (id, photo_id, tag)
     VALUES ('11111111-0000-0000-0000-000000000002',
             'dddddddd-0000-0000-0000-000000000001',
             'adorable') $$,
  'Owner can insert photo tag'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot insert tag
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.photo_tags (id, photo_id, tag)
     VALUES ('11111111-0000-0000-0000-000000000099',
             'dddddddd-0000-0000-0000-000000000001',
             'unauthorized') $$,
  '42501', NULL,
  'Follower cannot insert photo tag'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
