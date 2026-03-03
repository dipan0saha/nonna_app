-- Simple RLS Policy Test (no pgTAP complexity)
-- Tests if the helper functions and policies work correctly

BEGIN;

-- Create test data
INSERT INTO auth.users (id, email) VALUES
  ('11111111-1111-1111-1111-111111111111', 'owner@test.com'),
  ('22222222-2222-2222-2222-222222222222', 'follower@test.com'),
  ('33333333-3333-3333-3333-333333333333', 'nonmember@test.com')
ON CONFLICT DO NOTHING;

INSERT INTO public.baby_profiles (id, name) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test Baby')
ON CONFLICT DO NOTHING;

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role) VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'owner'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'follower')
ON CONFLICT DO NOTHING;

-- Test 1: Check if helper functions work as postgres (should succeed)
SELECT '===== Test 1: Helper Functions (as postgres) =====' as test;

SELECT is_baby_member('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') as owner_is_member;
SELECT is_baby_member('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') as follower_is_member;
SELECT is_baby_member('33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') as nonmember_is_member;

SELECT is_baby_owner('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') as owner_is_owner;
SELECT is_baby_owner('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') as follower_is_owner;

-- Test 2: Check RLS policies with direct SQL (as owner)
SELECT '===== Test 2: Owner Access (with SET ROLE) =====' as test;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "11111111-1111-1111-1111-111111111111"}';
SELECT COUNT(*) as owner_can_see FROM public.baby_profiles WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
RESET ROLE;
RESET "request.jwt.claims";

-- Test 3: Check RLS policies (as follower)
SELECT '===== Test 3: Follower Access (with SET ROLE) =====' as test;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "22222222-2222-2222-2222-222222222222"}';
SELECT COUNT(*) as follower_can_see FROM public.baby_profiles WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
RESET ROLE;
RESET "request.jwt.claims";

-- Test 4: Check RLS policies (as non-member)
SELECT '===== Test 4: Non-Member Access (with SET ROLE) =====' as test;
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "33333333-3333-3333-3333-333333333333"}';
SELECT COUNT(*) as nonmember_can_see FROM public.baby_profiles WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
RESET ROLE;
RESET "request.jwt.claims";

-- Cleanup
DELETE FROM public.baby_memberships WHERE id LIKE 'bbbbbbbb%' OR id LIKE 'cccccccc%';
DELETE FROM public.baby_profiles WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
DELETE FROM auth.users WHERE id IN ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');

ROLLBACK;
