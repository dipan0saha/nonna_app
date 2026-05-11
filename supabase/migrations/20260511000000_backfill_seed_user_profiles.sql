-- ============================================================================
-- BACKFILL: Seed user profiles
-- ============================================================================
-- The original seed.sql relied on the handle_new_user DB trigger to auto-create
-- profiles rows for seed users, then UPDATEd them with display_name/avatar_url.
-- Since seed scripts bypass Supabase Auth (direct INSERT into auth.users), the
-- trigger never fired, leaving all seed users with no profiles row.
-- This migration backfills those rows with their intended identities.
-- ============================================================================

INSERT INTO public.profiles (user_id, display_name, avatar_url, biometric_enabled, created_at, updated_at)
VALUES
    -- Owners (seed+1000000x)
    ('10000000-1001-1001-1001-000000001001', 'Sarah Johnson',         'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah0',        false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('10000001-1001-1001-1001-000000001001', 'Emily Davis',           'https://api.dicebear.com/7.x/avataaars/png?seed=Emily1',        false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('10000002-1001-1001-1001-000000001001', 'Jennifer Smith',        'https://api.dicebear.com/7.x/avataaars/png?seed=Jennifer2',     false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('10000003-1001-1001-1001-000000001001', 'Jessica Brown',         'https://api.dicebear.com/7.x/avataaars/png?seed=Jessica3',      false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('10000004-1001-1001-1001-000000001001', 'Amanda Wilson',         'https://api.dicebear.com/7.x/avataaars/png?seed=Amanda4',       false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('10000005-1001-1001-1001-000000001001', 'Maria Martinez',        'https://api.dicebear.com/7.x/avataaars/png?seed=Maria5',        false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('10000006-1001-1001-1001-000000001001', 'Sofia Garcia',          'https://api.dicebear.com/7.x/avataaars/png?seed=Sofia6',        false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('10000007-1001-1001-1001-000000001001', 'Michelle Lee',          'https://api.dicebear.com/7.x/avataaars/png?seed=Michelle7',     false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('10000008-1001-1001-1001-000000001001', 'Rachel Anderson',       'https://api.dicebear.com/7.x/avataaars/png?seed=Rachel8',       false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('10000009-1001-1001-1001-000000001001', 'Lauren Taylor',         'https://api.dicebear.com/7.x/avataaars/png?seed=Lauren9',       false, NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days'),
    -- Followers (seed+2000000x)
    ('20000000-2001-2001-2001-000000002001', 'Michael Johnson',       'https://api.dicebear.com/7.x/avataaars/png?seed=Michael0',      false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('20000001-2001-2001-2001-000000002001', 'John Davis',            'https://api.dicebear.com/7.x/avataaars/png?seed=John1',         false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('20000002-2001-2001-2001-000000002001', 'David Smith',           'https://api.dicebear.com/7.x/avataaars/png?seed=David2',        false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('20000003-2001-2001-2001-000000002001', 'Robert Brown',          'https://api.dicebear.com/7.x/avataaars/png?seed=Robert3',       false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('20000004-2001-2001-2001-000000002001', 'James Wilson',          'https://api.dicebear.com/7.x/avataaars/png?seed=James4',        false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('20000005-2001-2001-2001-000000002001', 'Carlos Martinez',       'https://api.dicebear.com/7.x/avataaars/png?seed=Carlos5',       false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('20000006-2001-2001-2001-000000002001', 'Miguel Garcia',         'https://api.dicebear.com/7.x/avataaars/png?seed=Miguel6',       false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('20000007-2001-2001-2001-000000002001', 'Kevin Lee',             'https://api.dicebear.com/7.x/avataaars/png?seed=Kevin7',        false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('20000008-2001-2001-2001-000000002001', 'Christopher Anderson',  'https://api.dicebear.com/7.x/avataaars/png?seed=Christopher8',  false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('20000009-2001-2001-2001-000000002001', 'Daniel Taylor',         'https://api.dicebear.com/7.x/avataaars/png?seed=Daniel9',       false, NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days')
ON CONFLICT (user_id) DO NOTHING;
