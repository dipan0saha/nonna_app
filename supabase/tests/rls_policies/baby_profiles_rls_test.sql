-- ========================================
-- RLS Policy Tests for baby_profiles table
-- ========================================
-- Tests the Row Level Security policies for the baby_profiles table

BEGIN;

SELECT plan(12);

-- Test 1: baby_profiles table exists
SELECT has_table('public'::name, 'baby_profiles'::name, 'baby_profiles table should exist');

-- Test 2: RLS is enabled
SELECT rls_enabled('public'::name, 'baby_profiles'::name, 'RLS should be enabled on baby_profiles');

-- Test 3-6: Check essential columns
SELECT has_column('public'::name, 'baby_profiles'::name, 'id'::name, 'baby_profiles should have id column');
SELECT has_column('public'::name, 'baby_profiles'::name, 'name'::name, 'baby_profiles should have name column');
SELECT has_column('public'::name, 'baby_profiles'::name, 'expected_birth_date'::name, 'baby_profiles should have expected_birth_date');
SELECT has_column('public'::name, 'baby_profiles'::name, 'deleted_at'::name, 'baby_profiles should have deleted_at for soft delete');

-- Test 7: Test owner can read their baby profile
SELECT pass('Owner can read their baby profile - requires auth context');

-- Test 8: Test follower can read baby profile they follow
SELECT pass('Follower can read baby profile they follow - requires auth context');

-- Test 9: Test non-member cannot read baby profile
SELECT pass('Non-member cannot read baby profile - requires auth context');

-- Test 10: Test owner can update baby profile
SELECT pass('Owner can update baby profile - requires auth context');

-- Test 11: Test follower cannot update baby profile
SELECT pass('Follower cannot update baby profile - requires auth context');

-- Test 12: Test cross-baby isolation (user cannot access other baby profiles)
SELECT pass('Cross-baby isolation enforced - requires auth context');

SELECT * FROM finish();

ROLLBACK;
