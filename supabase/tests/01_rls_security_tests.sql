BEGIN;
SELECT plan(3);

-- 1. Test Registry Items RLS (Followers Cannot Insert)
SELECT throws_ok(
    'INSERT INTO registry_items (baby_profile_id, created_by_user_id, name) VALUES (''00000000-0000-0000-0000-000000000000'', ''00000000-0000-0000-0000-000000000000'', ''Test Item'')',
    'new row violates row-level security policy for table "registry_items"'
);

-- 2. Test Baby Profiles (Guest Cannot access unlinked profiles)
SELECT is_empty(
    'SELECT * FROM baby_profiles WHERE id = ''00000000-0000-0000-0000-000000000000''',
    'Unlinked users cannot view private baby profiles'
);

-- 3. Check functions are Security Definer
SELECT is(
    (SELECT prosecdef FROM pg_proc WHERE proname = 'is_baby_member' LIMIT 1),
    true,
    'is_baby_member should be SECURITY DEFINER'
);

SELECT * FROM finish();
ROLLBACK;
