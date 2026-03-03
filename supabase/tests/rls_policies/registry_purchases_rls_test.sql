BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(12);

-- ==================== Structural Tests ====================

SELECT has_table('public'::name, 'registry_purchases'::name, 'registry_purchases table should exist');
SELECT rls_enabled('public'::name, 'registry_purchases'::name, 'RLS should be enabled on registry_purchases');

SELECT has_column('public'::name, 'registry_purchases'::name, 'id'::name,                   'registry_purchases has id');
SELECT has_column('public'::name, 'registry_purchases'::name, 'registry_item_id'::name,     'registry_purchases has registry_item_id');
SELECT has_column('public'::name, 'registry_purchases'::name, 'purchased_by_user_id'::name, 'registry_purchases has purchased_by_user_id');
SELECT has_column('public'::name, 'registry_purchases'::name, 'purchased_at'::name,         'registry_purchases has purchased_at');

-- ==================== Policy Existence Tests ====================

SELECT has_policy('public', 'registry_purchases', 'Members can view registry purchases',      'policy exists: members view purchases');
SELECT has_policy('public', 'registry_purchases', 'Members can mark items as purchased',      'policy exists: members mark purchased');

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
  ('55555555-0000-0000-0000-000000000002', 'bbbbbbbb-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'Car Seat');

INSERT INTO public.registry_purchases (id, registry_item_id, purchased_by_user_id, purchased_at) VALUES
  ('66666666-0000-0000-0000-000000000001',
   '55555555-0000-0000-0000-000000000001',
   'aaaaaaaa-0000-0000-0000-000000000001',
   NOW());

-- ==================== Functional Tests ====================

-- Member can view purchases
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000001", "aud": "authenticated"}';

SELECT isnt_empty(
  $$ SELECT * FROM public.registry_purchases
     WHERE registry_item_id = '55555555-0000-0000-0000-000000000001' $$,
  'Member can view registry purchases'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot view purchases
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.registry_purchases
     WHERE registry_item_id = '55555555-0000-0000-0000-000000000001' $$,
  'Non-member cannot view registry purchases'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Member (follower) can mark item as purchased
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000002", "aud": "authenticated"}';

SELECT lives_ok(
  $$ INSERT INTO public.registry_purchases (id, registry_item_id, purchased_by_user_id, purchased_at)
     VALUES ('66666666-0000-0000-0000-000000000002',
             '55555555-0000-0000-0000-000000000002',
             'aaaaaaaa-0000-0000-0000-000000000002',
             NOW()) $$,
  'Member can mark registry item as purchased'
);

RESET ROLE;
RESET "request.jwt.claims";

-- Nonmember cannot purchase
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "aaaaaaaa-0000-0000-0000-000000000003", "aud": "authenticated"}';

SELECT throws_ok(
  $$ INSERT INTO public.registry_purchases (id, registry_item_id, purchased_by_user_id, purchased_at)
     VALUES ('66666666-0000-0000-0000-000000000099',
             '55555555-0000-0000-0000-000000000001',
             'aaaaaaaa-0000-0000-0000-000000000003',
             NOW()) $$,
  '42501', NULL,
  'Non-member cannot mark registry item as purchased'
);

RESET ROLE;
RESET "request.jwt.claims";

SELECT * FROM finish();

ROLLBACK;
