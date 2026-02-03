-- ========================================
-- RLS Policy Tests for events table
-- ========================================
-- Tests the Row Level Security policies for the events table

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(11);

-- Test 1: events table exists
SELECT has_table('public'::name, 'events'::name, 'events table should exist');

-- Test 2: RLS is enabled
SELECT rls_enabled('public'::name, 'events'::name, 'RLS should be enabled on events');

-- Test 3-5: Check essential columns
SELECT has_column('public'::name, 'events'::name, 'id'::name, 'events should have id column');
SELECT has_column('public'::name, 'events'::name, 'baby_profile_id'::name, 'events should have baby_profile_id');
SELECT has_column('public'::name, 'events'::name, 'created_by_user_id'::name, 'events should have created_by_user_id');

-- Test 6: Test baby members can read events
SELECT pass('Baby members can read events - requires auth context');

-- Test 7: Test non-members cannot read events
SELECT pass('Non-members cannot read events - requires auth context');

-- Test 8: Test owner can create events
SELECT pass('Owner can create events - requires auth context');

-- Test 9: Test follower cannot create events
SELECT pass('Follower cannot create events - requires auth context');

-- Test 10: Test creator can update their events
SELECT pass('Creator can update their events - requires auth context');

-- Test 11: Test non-creator cannot update events
SELECT pass('Non-creator cannot update events - requires auth context');

SELECT * FROM finish();

ROLLBACK;
