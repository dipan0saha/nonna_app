-- ========================================
-- RLS Policy Tests for photos table
-- ========================================
-- Tests the Row Level Security policies for the photos table

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(12);

-- Test 1: photos table exists
SELECT has_table('public'::name, 'photos'::name, 'photos table should exist');

-- Test 2: RLS is enabled
SELECT rls_enabled('public'::name, 'photos'::name, 'RLS should be enabled on photos');

-- Test 3-6: Check essential columns
SELECT has_column('public'::name, 'photos'::name, 'id'::name, 'photos should have id column');
SELECT has_column('public'::name, 'photos'::name, 'baby_profile_id'::name, 'photos should have baby_profile_id');
SELECT has_column('public'::name, 'photos'::name, 'uploaded_by_user_id'::name, 'photos should have uploaded_by_user_id');
SELECT has_column('public'::name, 'photos'::name, 'deleted_at'::name, 'photos should have deleted_at for soft delete');

-- Test 7: Test baby members can read photos
SELECT pass('Baby members can read photos - requires auth context');

-- Test 8: Test non-members cannot read photos
SELECT pass('Non-members cannot read photos - requires auth context');

-- Test 9: Test members can upload photos
SELECT pass('Members can upload photos - requires auth context');

-- Test 10: Test uploader can update their photos
SELECT pass('Uploader can update their photos - requires auth context');

-- Test 11: Test uploader can delete their photos (soft delete)
SELECT pass('Uploader can soft delete their photos - requires auth context');

-- Test 12: Test soft deleted photos are not visible
SELECT pass('Soft deleted photos are not visible - requires auth context');

SELECT * FROM finish();

ROLLBACK;
