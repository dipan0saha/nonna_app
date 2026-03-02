BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(19);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'registry_items'::name, 'registry_items table should exist');
SELECT rls_enabled('public'::name, 'registry_items'::name, 'RLS should be enabled on registry_items');

SELECT has_column('public'::name, 'registry_items'::name, 'id'::name,                  'registry_items has id');
SELECT has_column('public'::name, 'registry_items'::name, 'baby_profile_id'::name,     'registry_items has baby_profile_id');
SELECT has_column('public'::name, 'registry_items'::name, 'created_by_user_id'::name,  'registry_items has created_by_user_id');
SELECT has_column('public'::name, 'registry_items'::name, 'name'::name,                'registry_items has name');
SELECT has_column('public'::name, 'registry_items'::name, 'deleted_at'::name,          'registry_items has deleted_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'registry_items', 'Members can view registry items',   'policy exists: members view registry items');
SELECT has_policy('public', 'registry_items', 'Owners can create registry items',  'policy exists: owners create registry items');
SELECT has_policy('public', 'registry_items', 'Owners can update registry items',  'policy exists: owners update registry items');
SELECT has_policy('public', 'registry_items', 'Owners can delete registry items',  'policy exists: owners delete registry items');

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

INSERT INTO public.registry_items (id, baby_profile_id, created_by_user_id, name) VALUES
  ('55555555-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'Stroller'),
  ('55555555-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'Item to Delete');

-- ==================== Functional Tests ====================

-- Member can view registry items
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.registry_items
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Member can view registry items'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view registry items
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.registry_items
     WHERE baby_profile_id = 'bbbbbbbb-0000-0000-0000-000000000001' $$,
  'Non-member cannot view registry items'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Owner can create registry item
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.registry_items (id, baby_profile_id, created_by_user_id, name)
     VALUES ('55555555-0000-0000-0000-000000000003',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000001',
             'Car Seat') $$,
  'Owner can create registry item'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot create registry item
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.registry_items (id, baby_profile_id, created_by_user_id, name)
     VALUES ('55555555-0000-0000-0000-000000000099',
             'bbbbbbbb-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000002',
             'Unauthorized Item') $$,
  '42501', NULL,
  'Follower cannot create registry item'
);

-- Owner can update item
RESET ROLE;
RESET "request.jwt.claims";

SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.registry_items SET name = 'Premium Stroller'
     WHERE id = '55555555-0000-0000-0000-000000000001' $$,
  'Owner can update registry item'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Follower cannot update item (silently 0 rows)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ UPDATE public.registry_items SET name = 'Hacked Item'
     WHERE id = '55555555-0000-0000-0000-000000000001' $$,
  'Follower update attempt does not error'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Verify item name unchanged by follower
SELECT is(
  (SELECT name FROM public.registry_items WHERE id = '55555555-0000-0000-0000-000000000001'),
  'Premium Stroller',
  'Follower cannot change registry item name'
);

-- Owner can delete registry item
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT lives_ok(
  $$ DELETE FROM public.registry_items WHERE id = '55555555-0000-0000-0000-000000000002' $$,
  'Owner can delete registry item'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
