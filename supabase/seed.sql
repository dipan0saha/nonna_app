-- ============================================================================
-- Nonna App - Comprehensive Seed Data Script
-- Version: 2.1.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Extended test data - 10 babies, 20 owners, 130 followers
-- ============================================================================

-- ---------------------------------------------------------------------------
-- TRUNCATE existing tables to ensure idempotent seed runs
-- This resets sequences and cascades to dependent rows.
-- Adjust or remove if you prefer manual cleanup.
BEGIN;
TRUNCATE TABLE public.tile_configs, public.tile_definitions, public.screens,
    public.baby_memberships, public.baby_profiles, public.user_stats, public.profiles, public.notifications
    RESTART IDENTITY CASCADE;
COMMIT;
-- ---------------------------------------------------------------------------


-- NOTE: In production, auth.users would be created via Supabase Auth API.
-- For testing, we create profiles directly.

-- ============================================================================
-- SECTION 1: PROFILES - Owners (20 users, 2 per baby)
-- ============================================================================

INSERT INTO public.profiles (user_id, display_name, avatar_url, biometric_enabled, created_at, updated_at) VALUES
    ('10000000-1001-1001-1001-000000001001', 'Sarah Johnson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah0', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('20000000-2001-2001-2001-000000002001', 'Michael Johnson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Michael0', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('10000001-1001-1001-1001-000000001001', 'Emily Davis', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emily1', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('20000001-2001-2001-2001-000000002001', 'John Davis', 'https://api.dicebear.com/7.x/avataaars/svg?seed=John1', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('10000002-1001-1001-1001-000000001001', 'Jennifer Smith', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jennifer2', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('20000002-2001-2001-2001-000000002001', 'David Smith', 'https://api.dicebear.com/7.x/avataaars/svg?seed=David2', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('10000003-1001-1001-1001-000000001001', 'Jessica Brown', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jessica3', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('20000003-2001-2001-2001-000000002001', 'Robert Brown', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Robert3', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('10000004-1001-1001-1001-000000001001', 'Amanda Wilson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amanda4', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('20000004-2001-2001-2001-000000002001', 'James Wilson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=James4', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('10000005-1001-1001-1001-000000001001', 'Maria Martinez', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maria5', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('20000005-2001-2001-2001-000000002001', 'Carlos Martinez', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Carlos5', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('10000006-1001-1001-1001-000000001001', 'Sofia Garcia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sofia6', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('20000006-2001-2001-2001-000000002001', 'Miguel Garcia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Miguel6', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('10000007-1001-1001-1001-000000001001', 'Michelle Lee', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Michelle7', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('20000007-2001-2001-2001-000000002001', 'Kevin Lee', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kevin7', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('10000008-1001-1001-1001-000000001001', 'Rachel Anderson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rachel8', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('20000008-2001-2001-2001-000000002001', 'Christopher Anderson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Christopher8', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('10000009-1001-1001-1001-000000001001', 'Lauren Taylor', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lauren9', false, NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days'),
    ('20000009-2001-2001-2001-000000002001', 'Daniel Taylor', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Daniel9', false, NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days')

ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- SECTION 2: PROFILES - Followers (120 users)
-- Note: 10 of these users are also owners of other babies (cross-profile)
-- ============================================================================

INSERT INTO public.profiles (user_id, display_name, avatar_url, biometric_enabled, created_at, updated_at) VALUES
    ('40000000-4001-4001-4001-000000004001', 'Grandma Emma', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F0', false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('40000001-4001-4001-4001-000000004001', 'Grandpa Olivia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F1', false, NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days'),
    ('40000002-4001-4001-4001-000000004001', 'Aunt Ava', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F2', false, NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days'),
    ('40000003-4001-4001-4001-000000004001', 'Uncle Isabella', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F3', false, NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
    ('40000004-4001-4001-4001-000000004001', 'Cousin Sophia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F4', false, NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),
    ('40000005-4001-4001-4001-000000004001', 'Friend Mia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F5', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('40000006-4001-4001-4001-000000004001', 'Neighbor Charlotte', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F6', false, NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days'),
    ('40000007-4001-4001-4001-000000004001', 'Colleague Amelia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F7', false, NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days'),
    ('40000008-4001-4001-4001-000000004001', 'Family Friend Harper', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F8', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('40000009-4001-4001-4001-000000004001', 'Godparent Evelyn', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F9', false, NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days'),
    ('4000000a-4001-4001-4001-000000004001', 'Grandma Liam', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F10', false, NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days'),
    ('4000000b-4001-4001-4001-000000004001', 'Grandpa Noah', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F11', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('4000000c-4001-4001-4001-000000004001', 'Aunt Oliver', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F12', false, NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days'),
    ('4000000d-4001-4001-4001-000000004001', 'Uncle Elijah', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F13', false, NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days'),
    ('4000000e-4001-4001-4001-000000004001', 'Cousin William', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F14', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('4000000f-4001-4001-4001-000000004001', 'Friend James', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F15', false, NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days'),
    ('40000010-4001-4001-4001-000000004001', 'Neighbor Benjamin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F16', false, NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days'),
    ('40000011-4001-4001-4001-000000004001', 'Colleague Lucas', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F17', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('40000012-4001-4001-4001-000000004001', 'Family Friend Henry', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F18', false, NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days'),
    ('40000013-4001-4001-4001-000000004001', 'Godparent Alexander', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F19', false, NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days'),
    ('40000014-4001-4001-4001-000000004001', 'Grandma Anna', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F20', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('40000015-4001-4001-4001-000000004001', 'Grandpa Grace', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F21', false, NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days'),
    ('40000016-4001-4001-4001-000000004001', 'Aunt Lily', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F22', false, NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days'),
    ('40000017-4001-4001-4001-000000004001', 'Uncle Zoe', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F23', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('40000018-4001-4001-4001-000000004001', 'Cousin Hannah', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F24', false, NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days'),
    ('40000019-4001-4001-4001-000000004001', 'Friend Chloe', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F25', false, NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days'),
    ('4000001a-4001-4001-4001-000000004001', 'Neighbor Ella', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F26', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('4000001b-4001-4001-4001-000000004001', 'Colleague Aria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F27', false, NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days'),
    ('4000001c-4001-4001-4001-000000004001', 'Family Friend Scarlett', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F28', false, NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days'),
    ('4000001d-4001-4001-4001-000000004001', 'Godparent Victoria', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F29', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('4000001e-4001-4001-4001-000000004001', 'Grandma Mason', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F30', false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('4000001f-4001-4001-4001-000000004001', 'Grandpa Ethan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F31', false, NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days'),
    ('40000020-4001-4001-4001-000000004001', 'Aunt Logan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F32', false, NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days'),
    ('40000021-4001-4001-4001-000000004001', 'Uncle Jacob', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F33', false, NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
    ('40000022-4001-4001-4001-000000004001', 'Cousin Jackson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F34', false, NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),
    ('40000023-4001-4001-4001-000000004001', 'Friend Aiden', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F35', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('40000024-4001-4001-4001-000000004001', 'Neighbor Samuel', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F36', false, NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days'),
    ('40000025-4001-4001-4001-000000004001', 'Colleague Sebastian', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F37', false, NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days'),
    ('40000026-4001-4001-4001-000000004001', 'Family Friend Matthew', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F38', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('40000027-4001-4001-4001-000000004001', 'Godparent Jack', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F39', false, NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days'),
    ('40000028-4001-4001-4001-000000004001', 'Grandma Ruby', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F40', false, NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days'),
    ('40000029-4001-4001-4001-000000004001', 'Grandpa Alice', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F41', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('4000002a-4001-4001-4001-000000004001', 'Aunt Eva', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F42', false, NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days'),
    ('4000002b-4001-4001-4001-000000004001', 'Uncle Lucy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F43', false, NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days'),
    ('4000002c-4001-4001-4001-000000004001', 'Cousin Freya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F44', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('4000002d-4001-4001-4001-000000004001', 'Friend Sophie', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F45', false, NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days'),
    ('4000002e-4001-4001-4001-000000004001', 'Neighbor Daisy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F46', false, NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days'),
    ('4000002f-4001-4001-4001-000000004001', 'Colleague Phoebe', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F47', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('40000030-4001-4001-4001-000000004001', 'Family Friend Florence', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F48', false, NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days'),
    ('40000031-4001-4001-4001-000000004001', 'Godparent Isabelle', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F49', false, NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days'),
    ('40000032-4001-4001-4001-000000004001', 'Grandma Leo', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F50', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('40000033-4001-4001-4001-000000004001', 'Grandpa Oscar', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F51', false, NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days'),
    ('40000034-4001-4001-4001-000000004001', 'Aunt Charlie', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F52', false, NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days'),
    ('40000035-4001-4001-4001-000000004001', 'Uncle Max', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F53', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('40000036-4001-4001-4001-000000004001', 'Cousin Isaac', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F54', false, NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days'),
    ('40000037-4001-4001-4001-000000004001', 'Friend Dylan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F55', false, NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days'),
    ('40000038-4001-4001-4001-000000004001', 'Neighbor Thomas', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F56', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('40000039-4001-4001-4001-000000004001', 'Colleague Nathan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F57', false, NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days'),
    ('4000003a-4001-4001-4001-000000004001', 'Family Friend Ryan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F58', false, NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days'),
    ('4000003b-4001-4001-4001-000000004001', 'Godparent Luke', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F59', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('4000003c-4001-4001-4001-000000004001', 'Grandma Rose', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F60', false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('4000003d-4001-4001-4001-000000004001', 'Grandpa Violet', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F61', false, NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days'),
    ('4000003e-4001-4001-4001-000000004001', 'Aunt Ivy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F62', false, NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days'),
    ('4000003f-4001-4001-4001-000000004001', 'Uncle Penelope', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F63', false, NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
    ('40000040-4001-4001-4001-000000004001', 'Cousin Aurora', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F64', false, NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),
    ('40000041-4001-4001-4001-000000004001', 'Friend Hazel', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F65', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('40000042-4001-4001-4001-000000004001', 'Neighbor Stella', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F66', false, NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days'),
    ('40000043-4001-4001-4001-000000004001', 'Colleague Willow', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F67', false, NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days'),
    ('40000044-4001-4001-4001-000000004001', 'Family Friend Luna', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F68', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('40000045-4001-4001-4001-000000004001', 'Godparent Savannah', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F69', false, NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days'),
    ('40000046-4001-4001-4001-000000004001', 'Grandma Aaron', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F70', false, NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days'),
    ('40000047-4001-4001-4001-000000004001', 'Grandpa Caleb', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F71', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('40000048-4001-4001-4001-000000004001', 'Aunt Wyatt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F72', false, NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days'),
    ('40000049-4001-4001-4001-000000004001', 'Uncle Julian', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F73', false, NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days'),
    ('4000004a-4001-4001-4001-000000004001', 'Cousin Carter', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F74', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('4000004b-4001-4001-4001-000000004001', 'Friend Jaxon', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F75', false, NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days'),
    ('4000004c-4001-4001-4001-000000004001', 'Neighbor Connor', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F76', false, NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days'),
    ('4000004d-4001-4001-4001-000000004001', 'Colleague Adam', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F77', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('4000004e-4001-4001-4001-000000004001', 'Family Friend Austin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F78', false, NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days'),
    ('4000004f-4001-4001-4001-000000004001', 'Godparent Gabriel', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F79', false, NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days'),
    ('40000050-4001-4001-4001-000000004001', 'Grandma Maya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F80', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('40000051-4001-4001-4001-000000004001', 'Grandpa Elena', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F81', false, NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days'),
    ('40000052-4001-4001-4001-000000004001', 'Aunt Natalie', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F82', false, NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days'),
    ('40000053-4001-4001-4001-000000004001', 'Uncle Julia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F83', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('40000054-4001-4001-4001-000000004001', 'Cousin Audrey', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F84', false, NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days'),
    ('40000055-4001-4001-4001-000000004001', 'Friend Layla', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F85', false, NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days'),
    ('40000056-4001-4001-4001-000000004001', 'Neighbor Leah', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F86', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('40000057-4001-4001-4001-000000004001', 'Colleague Reagan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F87', false, NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days'),
    ('40000058-4001-4001-4001-000000004001', 'Family Friend Bella', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F88', false, NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days'),
    ('40000059-4001-4001-4001-000000004001', 'Godparent Nora', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F89', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days'),
    ('4000005a-4001-4001-4001-000000004001', 'Grandma Ian', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F90', false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('4000005b-4001-4001-4001-000000004001', 'Grandpa Evan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F91', false, NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days'),
    ('4000005c-4001-4001-4001-000000004001', 'Aunt Dominic', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F92', false, NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days'),
    ('4000005d-4001-4001-4001-000000004001', 'Uncle Adrian', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F93', false, NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
    ('4000005e-4001-4001-4001-000000004001', 'Cousin Gavin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F94', false, NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days'),
    ('4000005f-4001-4001-4001-000000004001', 'Friend Xavier', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F95', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('40000060-4001-4001-4001-000000004001', 'Neighbor Tristan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F96', false, NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days'),
    ('40000061-4001-4001-4001-000000004001', 'Colleague Miles', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F97', false, NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days'),
    ('40000062-4001-4001-4001-000000004001', 'Family Friend Cole', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F98', false, NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days'),
    ('40000063-4001-4001-4001-000000004001', 'Godparent Bryson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F99', false, NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days'),
    ('40000064-4001-4001-4001-000000004001', 'Grandma Claire', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F100', false, NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days'),
    ('40000065-4001-4001-4001-000000004001', 'Grandpa Madeline', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F101', false, NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days'),
    ('40000066-4001-4001-4001-000000004001', 'Aunt Sadie', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F102', false, NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days'),
    ('40000067-4001-4001-4001-000000004001', 'Uncle Peyton', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F103', false, NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days'),
    ('40000068-4001-4001-4001-000000004001', 'Cousin Autumn', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F104', false, NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days'),
    ('40000069-4001-4001-4001-000000004001', 'Friend Paisley', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F105', false, NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days'),
    ('4000006a-4001-4001-4001-000000004001', 'Neighbor Naomi', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F106', false, NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days'),
    ('4000006b-4001-4001-4001-000000004001', 'Colleague Emilia', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F107', false, NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
    ('4000006c-4001-4001-4001-000000004001', 'Family Friend Caroline', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F108', false, NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days'),
    ('4000006d-4001-4001-4001-000000004001', 'Godparent Kennedy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F109', false, NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days'),
    ('4000006e-4001-4001-4001-000000004001', 'Grandma Jordan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F110', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('4000006f-4001-4001-4001-000000004001', 'Grandpa Justin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F111', false, NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days'),
    ('40000070-4001-4001-4001-000000004001', 'Aunt Blake', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F112', false, NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days'),
    ('40000071-4001-4001-4001-000000004001', 'Uncle Cooper', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F113', false, NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days'),
    ('40000072-4001-4001-4001-000000004001', 'Cousin Chase', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F114', false, NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days'),
    ('40000073-4001-4001-4001-000000004001', 'Friend Colin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F115', false, NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days'),
    ('40000074-4001-4001-4001-000000004001', 'Neighbor Wesley', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F116', false, NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days'),
    ('40000075-4001-4001-4001-000000004001', 'Colleague Preston', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F117', false, NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days'),
    ('40000076-4001-4001-4001-000000004001', 'Family Friend Sawyer', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F118', false, NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days'),
    ('40000077-4001-4001-4001-000000004001', 'Godparent Jude', 'https://api.dicebear.com/7.x/avataaars/svg?seed=F119', false, NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days')

ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- SECTION 3: USER STATS (for all 150 users)
-- ============================================================================

INSERT INTO public.user_stats (user_id, events_attended_count, items_purchased_count, photos_squished_count, comments_added_count, updated_at) VALUES
    ('10000000-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000000-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000001-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000001-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000002-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000002-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000003-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000003-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000004-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000004-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000005-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000005-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000006-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000006-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000007-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000007-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000008-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000008-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('10000009-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000009-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('40000000-4001-4001-4001-000000004001', 0, 0, 0, 0, NOW()),
    ('40000001-4001-4001-4001-000000004001', 1, 1, 2, 3, NOW()),
    ('40000002-4001-4001-4001-000000004001', 2, 2, 4, 6, NOW()),
    ('40000003-4001-4001-4001-000000004001', 3, 0, 6, 1, NOW()),
    ('40000004-4001-4001-4001-000000004001', 4, 1, 8, 4, NOW()),
    ('40000005-4001-4001-4001-000000004001', 0, 2, 0, 7, NOW()),
    ('40000006-4001-4001-4001-000000004001', 1, 0, 2, 2, NOW()),
    ('40000007-4001-4001-4001-000000004001', 2, 1, 4, 5, NOW()),
    ('40000008-4001-4001-4001-000000004001', 3, 2, 6, 0, NOW()),
    ('40000009-4001-4001-4001-000000004001', 4, 0, 8, 3, NOW()),
    ('4000000a-4001-4001-4001-000000004001', 0, 1, 0, 6, NOW()),
    ('4000000b-4001-4001-4001-000000004001', 1, 2, 2, 1, NOW()),
    ('4000000c-4001-4001-4001-000000004001', 2, 0, 4, 4, NOW()),
    ('4000000d-4001-4001-4001-000000004001', 3, 1, 6, 7, NOW()),
    ('4000000e-4001-4001-4001-000000004001', 4, 2, 8, 2, NOW()),
    ('4000000f-4001-4001-4001-000000004001', 0, 0, 0, 5, NOW()),
    ('40000010-4001-4001-4001-000000004001', 1, 1, 2, 0, NOW()),
    ('40000011-4001-4001-4001-000000004001', 2, 2, 4, 3, NOW()),
    ('40000012-4001-4001-4001-000000004001', 3, 0, 6, 6, NOW()),
    ('40000013-4001-4001-4001-000000004001', 4, 1, 8, 1, NOW()),
    ('40000014-4001-4001-4001-000000004001', 0, 2, 0, 4, NOW()),
    ('40000015-4001-4001-4001-000000004001', 1, 0, 2, 7, NOW()),
    ('40000016-4001-4001-4001-000000004001', 2, 1, 4, 2, NOW()),
    ('40000017-4001-4001-4001-000000004001', 3, 2, 6, 5, NOW()),
    ('40000018-4001-4001-4001-000000004001', 4, 0, 8, 0, NOW()),
    ('40000019-4001-4001-4001-000000004001', 0, 1, 0, 3, NOW()),
    ('4000001a-4001-4001-4001-000000004001', 1, 2, 2, 6, NOW()),
    ('4000001b-4001-4001-4001-000000004001', 2, 0, 4, 1, NOW()),
    ('4000001c-4001-4001-4001-000000004001', 3, 1, 6, 4, NOW()),
    ('4000001d-4001-4001-4001-000000004001', 4, 2, 8, 7, NOW()),
    ('4000001e-4001-4001-4001-000000004001', 0, 0, 0, 2, NOW()),
    ('4000001f-4001-4001-4001-000000004001', 1, 1, 2, 5, NOW()),
    ('40000020-4001-4001-4001-000000004001', 2, 2, 4, 0, NOW()),
    ('40000021-4001-4001-4001-000000004001', 3, 0, 6, 3, NOW()),
    ('40000022-4001-4001-4001-000000004001', 4, 1, 8, 6, NOW()),
    ('40000023-4001-4001-4001-000000004001', 0, 2, 0, 1, NOW()),
    ('40000024-4001-4001-4001-000000004001', 1, 0, 2, 4, NOW()),
    ('40000025-4001-4001-4001-000000004001', 2, 1, 4, 7, NOW()),
    ('40000026-4001-4001-4001-000000004001', 3, 2, 6, 2, NOW()),
    ('40000027-4001-4001-4001-000000004001', 4, 0, 8, 5, NOW()),
    ('40000028-4001-4001-4001-000000004001', 0, 1, 0, 0, NOW()),
    ('40000029-4001-4001-4001-000000004001', 1, 2, 2, 3, NOW()),
    ('4000002a-4001-4001-4001-000000004001', 2, 0, 4, 6, NOW()),
    ('4000002b-4001-4001-4001-000000004001', 3, 1, 6, 1, NOW()),
    ('4000002c-4001-4001-4001-000000004001', 4, 2, 8, 4, NOW()),
    ('4000002d-4001-4001-4001-000000004001', 0, 0, 0, 7, NOW()),
    ('4000002e-4001-4001-4001-000000004001', 1, 1, 2, 2, NOW()),
    ('4000002f-4001-4001-4001-000000004001', 2, 2, 4, 5, NOW()),
    ('40000030-4001-4001-4001-000000004001', 3, 0, 6, 0, NOW()),
    ('40000031-4001-4001-4001-000000004001', 4, 1, 8, 3, NOW()),
    ('40000032-4001-4001-4001-000000004001', 0, 2, 0, 6, NOW()),
    ('40000033-4001-4001-4001-000000004001', 1, 0, 2, 1, NOW()),
    ('40000034-4001-4001-4001-000000004001', 2, 1, 4, 4, NOW()),
    ('40000035-4001-4001-4001-000000004001', 3, 2, 6, 7, NOW()),
    ('40000036-4001-4001-4001-000000004001', 4, 0, 8, 2, NOW()),
    ('40000037-4001-4001-4001-000000004001', 0, 1, 0, 5, NOW()),
    ('40000038-4001-4001-4001-000000004001', 1, 2, 2, 0, NOW()),
    ('40000039-4001-4001-4001-000000004001', 2, 0, 4, 3, NOW()),
    ('4000003a-4001-4001-4001-000000004001', 3, 1, 6, 6, NOW()),
    ('4000003b-4001-4001-4001-000000004001', 4, 2, 8, 1, NOW()),
    ('4000003c-4001-4001-4001-000000004001', 0, 0, 0, 4, NOW()),
    ('4000003d-4001-4001-4001-000000004001', 1, 1, 2, 7, NOW()),
    ('4000003e-4001-4001-4001-000000004001', 2, 2, 4, 2, NOW()),
    ('4000003f-4001-4001-4001-000000004001', 3, 0, 6, 5, NOW()),
    ('40000040-4001-4001-4001-000000004001', 4, 1, 8, 0, NOW()),
    ('40000041-4001-4001-4001-000000004001', 0, 2, 0, 3, NOW()),
    ('40000042-4001-4001-4001-000000004001', 1, 0, 2, 6, NOW()),
    ('40000043-4001-4001-4001-000000004001', 2, 1, 4, 1, NOW()),
    ('40000044-4001-4001-4001-000000004001', 3, 2, 6, 4, NOW()),
    ('40000045-4001-4001-4001-000000004001', 4, 0, 8, 7, NOW()),
    ('40000046-4001-4001-4001-000000004001', 0, 1, 0, 2, NOW()),
    ('40000047-4001-4001-4001-000000004001', 1, 2, 2, 5, NOW()),
    ('40000048-4001-4001-4001-000000004001', 2, 0, 4, 0, NOW()),
    ('40000049-4001-4001-4001-000000004001', 3, 1, 6, 3, NOW()),
    ('4000004a-4001-4001-4001-000000004001', 4, 2, 8, 6, NOW()),
    ('4000004b-4001-4001-4001-000000004001', 0, 0, 0, 1, NOW()),
    ('4000004c-4001-4001-4001-000000004001', 1, 1, 2, 4, NOW()),
    ('4000004d-4001-4001-4001-000000004001', 2, 2, 4, 7, NOW()),
    ('4000004e-4001-4001-4001-000000004001', 3, 0, 6, 2, NOW()),
    ('4000004f-4001-4001-4001-000000004001', 4, 1, 8, 5, NOW()),
    ('40000050-4001-4001-4001-000000004001', 0, 2, 0, 0, NOW()),
    ('40000051-4001-4001-4001-000000004001', 1, 0, 2, 3, NOW()),
    ('40000052-4001-4001-4001-000000004001', 2, 1, 4, 6, NOW()),
    ('40000053-4001-4001-4001-000000004001', 3, 2, 6, 1, NOW()),
    ('40000054-4001-4001-4001-000000004001', 4, 0, 8, 4, NOW()),
    ('40000055-4001-4001-4001-000000004001', 0, 1, 0, 7, NOW()),
    ('40000056-4001-4001-4001-000000004001', 1, 2, 2, 2, NOW()),
    ('40000057-4001-4001-4001-000000004001', 2, 0, 4, 5, NOW()),
    ('40000058-4001-4001-4001-000000004001', 3, 1, 6, 0, NOW()),
    ('40000059-4001-4001-4001-000000004001', 4, 2, 8, 3, NOW()),
    ('4000005a-4001-4001-4001-000000004001', 0, 0, 0, 6, NOW()),
    ('4000005b-4001-4001-4001-000000004001', 1, 1, 2, 1, NOW()),
    ('4000005c-4001-4001-4001-000000004001', 2, 2, 4, 4, NOW()),
    ('4000005d-4001-4001-4001-000000004001', 3, 0, 6, 7, NOW()),
    ('4000005e-4001-4001-4001-000000004001', 4, 1, 8, 2, NOW()),
    ('4000005f-4001-4001-4001-000000004001', 0, 2, 0, 5, NOW()),
    ('40000060-4001-4001-4001-000000004001', 1, 0, 2, 0, NOW()),
    ('40000061-4001-4001-4001-000000004001', 2, 1, 4, 3, NOW()),
    ('40000062-4001-4001-4001-000000004001', 3, 2, 6, 6, NOW()),
    ('40000063-4001-4001-4001-000000004001', 4, 0, 8, 1, NOW()),
    ('40000064-4001-4001-4001-000000004001', 0, 1, 0, 4, NOW()),
    ('40000065-4001-4001-4001-000000004001', 1, 2, 2, 7, NOW()),
    ('40000066-4001-4001-4001-000000004001', 2, 0, 4, 2, NOW()),
    ('40000067-4001-4001-4001-000000004001', 3, 1, 6, 5, NOW()),
    ('40000068-4001-4001-4001-000000004001', 4, 2, 8, 0, NOW()),
    ('40000069-4001-4001-4001-000000004001', 0, 0, 0, 3, NOW()),
    ('4000006a-4001-4001-4001-000000004001', 1, 1, 2, 6, NOW()),
    ('4000006b-4001-4001-4001-000000004001', 2, 2, 4, 1, NOW()),
    ('4000006c-4001-4001-4001-000000004001', 3, 0, 6, 4, NOW()),
    ('4000006d-4001-4001-4001-000000004001', 4, 1, 8, 7, NOW()),
    ('4000006e-4001-4001-4001-000000004001', 0, 2, 0, 2, NOW()),
    ('4000006f-4001-4001-4001-000000004001', 1, 0, 2, 5, NOW()),
    ('40000070-4001-4001-4001-000000004001', 2, 1, 4, 0, NOW()),
    ('40000071-4001-4001-4001-000000004001', 3, 2, 6, 3, NOW()),
    ('40000072-4001-4001-4001-000000004001', 4, 0, 8, 6, NOW()),
    ('40000073-4001-4001-4001-000000004001', 0, 1, 0, 1, NOW()),
    ('40000074-4001-4001-4001-000000004001', 1, 2, 2, 4, NOW()),
    ('40000075-4001-4001-4001-000000004001', 2, 0, 4, 7, NOW()),
    ('40000076-4001-4001-4001-000000004001', 3, 1, 6, 2, NOW()),
    ('40000077-4001-4001-4001-000000004001', 4, 2, 8, 5, NOW())

ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- SECTION 4: BABY PROFILES (10 babies)
-- ============================================================================

INSERT INTO public.baby_profiles (id, name, default_last_name_source, profile_photo_url, expected_birth_date, gender, created_at, updated_at) VALUES
    ('b0000000-b001-b001-b001-00000000b001', 'Baby Johnson', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby0', NOW() + INTERVAL '30 days', 'unknown', NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),
    ('b0000001-b001-b001-b001-00000000b001', 'Liam Davis', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby1', NOW() + INTERVAL '45 days', 'male', NOW() - INTERVAL '33 days', NOW() - INTERVAL '6 days'),
    ('b0000002-b001-b001-b001-00000000b001', 'Emma Smith', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby2', NOW() + INTERVAL '60 days', 'female', NOW() - INTERVAL '36 days', NOW() - INTERVAL '7 days'),
    ('b0000003-b001-b001-b001-00000000b001', 'Noah Brown', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby3', NOW() + INTERVAL '75 days', 'male', NOW() - INTERVAL '39 days', NOW() - INTERVAL '8 days'),
    ('b0000004-b001-b001-b001-00000000b001', 'Olivia Wilson', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby4', NOW() + INTERVAL '90 days', 'female', NOW() - INTERVAL '42 days', NOW() - INTERVAL '9 days'),
    ('b0000005-b001-b001-b001-00000000b001', 'Ava Martinez', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby5', NOW() + INTERVAL '105 days', 'female', NOW() - INTERVAL '45 days', NOW() - INTERVAL '10 days'),
    ('b0000006-b001-b001-b001-00000000b001', 'Sophia Garcia', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby6', NOW() + INTERVAL '120 days', 'female', NOW() - INTERVAL '48 days', NOW() - INTERVAL '11 days'),
    ('b0000007-b001-b001-b001-00000000b001', 'Mason Lee', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby7', NOW() + INTERVAL '135 days', 'male', NOW() - INTERVAL '51 days', NOW() - INTERVAL '12 days'),
    ('b0000008-b001-b001-b001-00000000b001', 'Isabella Anderson', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby8', NOW() + INTERVAL '150 days', 'female', NOW() - INTERVAL '54 days', NOW() - INTERVAL '13 days'),
    ('b0000009-b001-b001-b001-00000000b001', 'Lucas Taylor', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby9', NOW() + INTERVAL '165 days', 'male', NOW() - INTERVAL '57 days', NOW() - INTERVAL '14 days')

ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 5: BABY MEMBERSHIPS (20 owners + 120 followers + 10 cross-profile = 150 memberships)
-- Note: 2 owners per baby, with some owners also being followers of other babies
-- ============================================================================

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role, relationship_label, created_at, updated_at, removed_at) VALUES
    -- Baby 0 owners (2)
    ('b1a81fd9-4595-49e8-9476-37acc900f55a', 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('7aae85fe-78a7-42d7-96ee-4c6874ea9136', 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    -- Baby 1 owners (2)
    ('9dd5a931-4fef-40c9-b1f2-6c849b871835', 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('37c0c051-6776-4fbc-a5db-e37485957542', 'b0000001-b001-b001-b001-00000000b001', '20000001-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    -- Baby 2 owners (2)
    ('5b24fb53-94f0-491f-a704-cb98cdf15217', 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('99c7aba8-9223-479f-947f-5bbc7b9ce800', 'b0000002-b001-b001-b001-00000000b001', '20000002-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    -- Baby 3 owners (2)
    ('82405c74-ec4e-4aec-a2c8-372075cc0fe9', 'b0000003-b001-b001-b001-00000000b001', '10000003-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('8b7491e9-8707-49de-9302-e50b07a0b9af', 'b0000003-b001-b001-b001-00000000b001', '20000003-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    -- Baby 4 owners (2)
    ('14a35789-8417-465a-a091-ce0a290b360f', 'b0000004-b001-b001-b001-00000000b001', '10000004-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('9233d56e-9e65-475f-8461-48213a472cb1', 'b0000004-b001-b001-b001-00000000b001', '20000004-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    -- Baby 5 owners (2)
    ('b4782789-9366-465f-bfb9-002b5be03c82', 'b0000005-b001-b001-b001-00000000b001', '10000005-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('06379c90-3557-43d4-815f-beaffc39b631', 'b0000005-b001-b001-b001-00000000b001', '20000005-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    -- Baby 6 owners (2)
    ('5ce3f608-d973-49c5-b0cd-e6b1b4fbaf4e', 'b0000006-b001-b001-b001-00000000b001', '10000006-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('eaa6301a-6226-4c52-a366-8650ab1c9e53', 'b0000006-b001-b001-b001-00000000b001', '20000006-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    -- Baby 7 owners (2)
    ('3c2c888a-0191-4bde-87e1-c25ce35f38be', 'b0000007-b001-b001-b001-00000000b001', '10000007-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('43e3d8a8-2e18-42f0-b07e-08e13daa05b7', 'b0000007-b001-b001-b001-00000000b001', '20000007-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    -- Baby 8 owners (2)
    ('35727ced-d6c1-4da9-a9fb-15bd70674e3a', 'b0000008-b001-b001-b001-00000000b001', '10000008-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('4b0e0adc-74e6-4962-95c9-eddeb5d60d0e', 'b0000008-b001-b001-b001-00000000b001', '20000008-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    -- Baby 9 owners (2)
    ('b7523e88-1adb-4cff-8d0d-89ead091fa18', 'b0000009-b001-b001-b001-00000000b001', '10000009-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days', NULL),
    ('2e8aa096-be19-4cb9-8513-d9f0af6e4814', 'b0000009-b001-b001-b001-00000000b001', '20000009-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days', NULL),
    -- Cross-profile followers: Some owners following other babies (10 total)
    ('a1000000-a001-a001-a001-00000000a001', 'b0000001-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'follower', 'Friend', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('a2000000-a001-a001-a001-00000000a002', 'b0000002-b001-b001-b001-00000000b001', '20000001-2001-2001-2001-000000002001', 'follower', 'Family Friend', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('a3000000-a001-a001-a001-00000000a003', 'b0000003-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'follower', 'Friend', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('a4000000-a001-a001-a001-00000000a004', 'b0000004-b001-b001-b001-00000000b001', '20000003-2001-2001-2001-000000002001', 'follower', 'Family Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('a5000000-a001-a001-a001-00000000a005', 'b0000005-b001-b001-b001-00000000b001', '10000004-1001-1001-1001-000000001001', 'follower', 'Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('a6000000-a001-a001-a001-00000000a006', 'b0000006-b001-b001-b001-00000000b001', '20000005-2001-2001-2001-000000002001', 'follower', 'Family Friend', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('a7000000-a001-a001-a001-00000000a007', 'b0000007-b001-b001-b001-00000000b001', '10000006-1001-1001-1001-000000001001', 'follower', 'Friend', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('a8000000-a001-a001-a001-00000000a008', 'b0000008-b001-b001-b001-00000000b001', '20000007-2001-2001-2001-000000002001', 'follower', 'Family Friend', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('a9000000-a001-a001-a001-00000000a009', 'b0000009-b001-b001-b001-00000000b001', '10000008-1001-1001-1001-000000001001', 'follower', 'Friend', NOW() - INTERVAL '55 days', NOW() - INTERVAL '55 days', NULL),
    ('aa000000-a001-a001-a001-00000000a00a', 'b0000000-b001-b001-b001-00000000b001', '20000009-2001-2001-2001-000000002001', 'follower', 'Family Friend', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('1464609a-0800-42e1-804c-36ee56d958f2', 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('df07cc3f-c667-4488-8469-ca96f6d4a798', 'b0000000-b001-b001-b001-00000000b001', '40000001-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('f3d7711f-b7c4-44ce-b997-e97591333315', 'b0000000-b001-b001-b001-00000000b001', '40000002-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('f11f82a6-8a8d-4800-9477-3f81d8e3227e', 'b0000000-b001-b001-b001-00000000b001', '40000003-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('96f639ba-d83d-40ce-a368-7609295e70ee', 'b0000000-b001-b001-b001-00000000b001', '40000004-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('b8fd7965-1453-4ba5-99a6-e329ddd76f61', 'b0000000-b001-b001-b001-00000000b001', '40000005-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('7381c53a-3588-470a-abd8-e082fb063095', 'b0000000-b001-b001-b001-00000000b001', '40000006-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('e59223ef-3043-43a5-8e6c-5d08886ab78f', 'b0000000-b001-b001-b001-00000000b001', '40000007-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('c24257e9-6805-4a22-b2bc-422f88f8ba17', 'b0000000-b001-b001-b001-00000000b001', '40000008-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('117e2545-7816-4b2d-a3bb-cdfecb50054e', 'b0000000-b001-b001-b001-00000000b001', '40000009-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('f1c9e18c-ee7c-45a9-935b-aaa3d21c08fc', 'b0000000-b001-b001-b001-00000000b001', '4000000a-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('f9ae94c7-e16a-48ca-b7f8-47aee6364b6a', 'b0000000-b001-b001-b001-00000000b001', '4000000b-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('ee0a67c9-ac6e-4316-807b-35769f3c5736', 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('42c88a7a-9932-4b5b-9a04-1401d1f976c6', 'b0000001-b001-b001-b001-00000000b001', '4000000d-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('46f5d022-772e-4726-be0d-a038adbc70ba', 'b0000001-b001-b001-b001-00000000b001', '4000000e-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('88f4dd70-d6bc-4d0e-8f5d-1dd849456e30', 'b0000001-b001-b001-b001-00000000b001', '4000000f-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('5b6942ff-2d0a-4a5b-8863-bc00f9422d82', 'b0000001-b001-b001-b001-00000000b001', '40000010-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('8c57f6fd-dea1-4c1d-8a82-64cf7101664b', 'b0000001-b001-b001-b001-00000000b001', '40000011-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('dabbd442-a47c-4b93-ba78-3d1c65816ac6', 'b0000001-b001-b001-b001-00000000b001', '40000012-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('e3105058-26cd-41a6-acb5-bf9661897901', 'b0000001-b001-b001-b001-00000000b001', '40000013-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('d053778d-31b7-4670-8cd0-cc44ecd54c75', 'b0000001-b001-b001-b001-00000000b001', '40000014-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('797c49ac-f160-407f-82f4-6ba437eaf3b7', 'b0000001-b001-b001-b001-00000000b001', '40000015-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('f3dab764-4e99-4a57-901e-bc2733553ebf', 'b0000001-b001-b001-b001-00000000b001', '40000016-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('2d205e85-9836-44eb-b241-17763d535796', 'b0000001-b001-b001-b001-00000000b001', '40000017-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('0b049f83-c556-40cf-a6bf-c86a18817362', 'b0000002-b001-b001-b001-00000000b001', '40000018-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('95cc8835-f20c-4e2f-8c0d-d4d1e7b8484d', 'b0000002-b001-b001-b001-00000000b001', '40000019-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('e61d6c82-5a51-44b9-9285-f462a790e883', 'b0000002-b001-b001-b001-00000000b001', '4000001a-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('07a57a01-70bd-4331-b0c5-91995abb771f', 'b0000002-b001-b001-b001-00000000b001', '4000001b-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('8c64558b-7443-449d-be2a-f4d96a9172f1', 'b0000002-b001-b001-b001-00000000b001', '4000001c-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('3f7f430b-b927-47ff-80a1-d6e51549c8d7', 'b0000002-b001-b001-b001-00000000b001', '4000001d-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('66fc3337-c220-4164-8c4e-752b38c0cb56', 'b0000002-b001-b001-b001-00000000b001', '4000001e-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('b2993d19-26e3-484a-9264-4afddf937599', 'b0000002-b001-b001-b001-00000000b001', '4000001f-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('c523406f-f9f0-4aea-8d7c-f430a9294ca1', 'b0000002-b001-b001-b001-00000000b001', '40000020-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('6f21986a-fe46-4a4e-88b5-bb94fe7adcbb', 'b0000002-b001-b001-b001-00000000b001', '40000021-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('7172435b-c337-4a59-8175-ba952a7ac59f', 'b0000002-b001-b001-b001-00000000b001', '40000022-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('dd68d1f5-4ee4-4927-a79e-31fb4ba71912', 'b0000002-b001-b001-b001-00000000b001', '40000023-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('1131e3e4-9021-4b12-8fef-92281ea19524', 'b0000003-b001-b001-b001-00000000b001', '40000024-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('c1ab18d7-2350-4b03-8212-8de6fc659f26', 'b0000003-b001-b001-b001-00000000b001', '40000025-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('23f93971-fee6-4046-863c-95f7332ea391', 'b0000003-b001-b001-b001-00000000b001', '40000026-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('b915b0bf-f5cf-4bf3-b8b7-9f6082a7a389', 'b0000003-b001-b001-b001-00000000b001', '40000027-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('6ea1b90c-cf4d-43d9-bc2c-0b0e57af7630', 'b0000003-b001-b001-b001-00000000b001', '40000028-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('37387363-0d08-4245-be24-6629387bc859', 'b0000003-b001-b001-b001-00000000b001', '40000029-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('73bf8b1a-1f3f-4a93-a8b7-5ad023e4515f', 'b0000003-b001-b001-b001-00000000b001', '4000002a-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('aa8430d9-4fa2-4933-928e-5413a403f324', 'b0000003-b001-b001-b001-00000000b001', '4000002b-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('db63ef03-13a2-4ef4-8912-ec4fcffdabc5', 'b0000003-b001-b001-b001-00000000b001', '4000002c-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('32888e8c-fd2c-4868-ad12-0903c8f9ad3f', 'b0000003-b001-b001-b001-00000000b001', '4000002d-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('0892d9ec-966f-432d-b56f-27319acd12a4', 'b0000003-b001-b001-b001-00000000b001', '4000002e-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('773db926-a8a1-4546-908b-401c1e363c9a', 'b0000003-b001-b001-b001-00000000b001', '4000002f-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('1f4bfd84-05dd-466a-b19b-49dcf1451125', 'b0000004-b001-b001-b001-00000000b001', '40000030-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('97d059a4-b1dc-482d-b606-4faf4cf5f523', 'b0000004-b001-b001-b001-00000000b001', '40000031-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('056b2306-a1a1-4da4-93f5-46db335888d3', 'b0000004-b001-b001-b001-00000000b001', '40000032-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('92f52844-fb91-4849-9d9c-be65a9e2c34f', 'b0000004-b001-b001-b001-00000000b001', '40000033-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('37538d58-2892-4d30-9973-4b4a5f3236bf', 'b0000004-b001-b001-b001-00000000b001', '40000034-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('09af6032-008d-4e88-a063-686ebc997f36', 'b0000004-b001-b001-b001-00000000b001', '40000035-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('f84711a7-34a1-458e-a0f7-674eba49b1f1', 'b0000004-b001-b001-b001-00000000b001', '40000036-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('ed09208b-d2dd-4f8a-8762-5948624e83f1', 'b0000004-b001-b001-b001-00000000b001', '40000037-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('245e1a67-e92a-42c2-a324-20275df68b43', 'b0000004-b001-b001-b001-00000000b001', '40000038-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('3dd3cbc0-7c9c-4731-b122-73ee85790e60', 'b0000004-b001-b001-b001-00000000b001', '40000039-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('b58211d6-9674-4f38-a042-70ef3d316407', 'b0000004-b001-b001-b001-00000000b001', '4000003a-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('8adf6864-9e7a-4ff3-847c-f4f3942faba3', 'b0000004-b001-b001-b001-00000000b001', '4000003b-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('8693b95a-74e9-43b1-978f-a8e477d4d776', 'b0000005-b001-b001-b001-00000000b001', '4000003c-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('68f6143b-3692-414a-a233-3cd43e1f7b7f', 'b0000005-b001-b001-b001-00000000b001', '4000003d-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('190b8475-7175-405d-9dfc-24f56c6cae3f', 'b0000005-b001-b001-b001-00000000b001', '4000003e-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('4a3b51b2-1023-432c-846b-308359e12dc1', 'b0000005-b001-b001-b001-00000000b001', '4000003f-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('86a97d5e-8276-41b5-996a-826003048485', 'b0000005-b001-b001-b001-00000000b001', '40000040-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('10c1167c-928c-46ea-894b-f264221dc1e9', 'b0000005-b001-b001-b001-00000000b001', '40000041-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('99258d20-80e0-458b-a525-2961127d4674', 'b0000005-b001-b001-b001-00000000b001', '40000042-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('caf0a31e-3845-4ff7-9b15-c453df0daa5b', 'b0000005-b001-b001-b001-00000000b001', '40000043-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('2e9b67ce-fa32-43cf-8c92-bea01d78e6b3', 'b0000005-b001-b001-b001-00000000b001', '40000044-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('a8402e9e-8336-4a63-9afa-c6f64c1280a0', 'b0000005-b001-b001-b001-00000000b001', '40000045-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('1e8d07b1-5055-425b-a553-650955107039', 'b0000005-b001-b001-b001-00000000b001', '40000046-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('2842ec9d-cfaa-45b4-a267-53f0b5882130', 'b0000005-b001-b001-b001-00000000b001', '40000047-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('d73765f3-aa0b-4b96-8314-9a11b4597f03', 'b0000006-b001-b001-b001-00000000b001', '40000048-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('a0f33a42-39c3-4cb3-bfd3-406f365e6fcf', 'b0000006-b001-b001-b001-00000000b001', '40000049-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('35538bd4-5383-46f2-a8ea-6589ce5cd9f6', 'b0000006-b001-b001-b001-00000000b001', '4000004a-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bb66c5bb-fc43-4139-9877-115e21694039', 'b0000006-b001-b001-b001-00000000b001', '4000004b-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('85a147cf-751a-43a9-b65d-8817534fba0d', 'b0000006-b001-b001-b001-00000000b001', '4000004c-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('ec116486-eedb-42f2-80dc-91893ed0b9bc', 'b0000006-b001-b001-b001-00000000b001', '4000004d-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('3d46285d-0aa9-4023-b288-050a331a163c', 'b0000006-b001-b001-b001-00000000b001', '4000004e-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('49e8b9cb-a7bc-4e6f-80e8-d2c43886960b', 'b0000006-b001-b001-b001-00000000b001', '4000004f-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('85fec2ca-f1a0-4edb-a994-50666403106c', 'b0000006-b001-b001-b001-00000000b001', '40000050-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('8362e300-1698-4654-b109-4b5e7f0ddec4', 'b0000006-b001-b001-b001-00000000b001', '40000051-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('37b15ee9-8356-49f8-8fc9-38382c928a86', 'b0000006-b001-b001-b001-00000000b001', '40000052-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('e9b87930-2643-4106-9cc6-ea42f4db13b3', 'b0000006-b001-b001-b001-00000000b001', '40000053-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('89ce4de3-a590-47c0-b89b-6cf229dfc042', 'b0000007-b001-b001-b001-00000000b001', '40000054-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('7eab1d01-e048-4b0c-84de-ae759e143e3c', 'b0000007-b001-b001-b001-00000000b001', '40000055-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('430d45e7-d2d6-44f9-86ad-738e1105577f', 'b0000007-b001-b001-b001-00000000b001', '40000056-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('4a9d2b4c-81dc-4dd9-8978-56b32c465196', 'b0000007-b001-b001-b001-00000000b001', '40000057-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('e387693e-4e50-47af-844a-1024b0ef92ad', 'b0000007-b001-b001-b001-00000000b001', '40000058-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('493e903c-1f7d-4715-a8f1-67d64f9899dc', 'b0000007-b001-b001-b001-00000000b001', '40000059-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('0a117306-6bf9-42bd-9ce2-0d613036d148', 'b0000007-b001-b001-b001-00000000b001', '4000005a-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('b3e2cecd-3976-4c62-bbfd-93bde15e9841', 'b0000007-b001-b001-b001-00000000b001', '4000005b-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('4e3d7b82-f6d5-4a73-bc12-1c55836da526', 'b0000007-b001-b001-b001-00000000b001', '4000005c-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('d203087b-5385-4b4c-b550-8fe69e3697e3', 'b0000007-b001-b001-b001-00000000b001', '4000005d-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('878cbfa7-614e-44dc-b9ea-ac7787ab8d8c', 'b0000007-b001-b001-b001-00000000b001', '4000005e-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('b6030426-4a50-48fb-ad2c-1331a5ee6139', 'b0000007-b001-b001-b001-00000000b001', '4000005f-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('2ffd9f5c-58cb-4763-9f7a-9342aed7a158', 'b0000008-b001-b001-b001-00000000b001', '40000060-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('a6a7c8ba-95db-4479-89c3-cc6ee595f679', 'b0000008-b001-b001-b001-00000000b001', '40000061-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('9b3c17b3-8df4-4fe0-9b63-151db9c66d89', 'b0000008-b001-b001-b001-00000000b001', '40000062-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('3bca188e-5383-4ca0-90e0-e01fd2990aef', 'b0000008-b001-b001-b001-00000000b001', '40000063-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('8c450d6b-a51f-4437-8749-0f059759d3f0', 'b0000008-b001-b001-b001-00000000b001', '40000064-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('ff14078c-4277-43a9-8bc9-a871d62c630f', 'b0000008-b001-b001-b001-00000000b001', '40000065-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('64544564-f0f6-469d-b0d2-925f42442854', 'b0000008-b001-b001-b001-00000000b001', '40000066-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('b784a180-0040-4c43-be48-cf9f7e1510ad', 'b0000008-b001-b001-b001-00000000b001', '40000067-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('fbf266bd-c1b1-4d18-bd39-a924817ed11b', 'b0000008-b001-b001-b001-00000000b001', '40000068-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('0b8ec05a-9810-4370-b960-0bee5d06dd4d', 'b0000008-b001-b001-b001-00000000b001', '40000069-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('897e87dc-4d9e-408d-b327-746864d59c5e', 'b0000008-b001-b001-b001-00000000b001', '4000006a-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('3424c48a-11c7-4d7e-9892-76ad51e3d7c9', 'b0000008-b001-b001-b001-00000000b001', '4000006b-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('3a3dd48c-00c2-46e5-886f-c983f3c06fcf', 'b0000009-b001-b001-b001-00000000b001', '4000006c-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('3cf15d9a-9beb-43ed-94f2-2d96ca56d529', 'b0000009-b001-b001-b001-00000000b001', '4000006d-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('46e6b554-4d31-42a5-9f29-030bbc7578c4', 'b0000009-b001-b001-b001-00000000b001', '4000006e-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('7ce04864-ea75-4df9-b296-63c54f8c0913', 'b0000009-b001-b001-b001-00000000b001', '4000006f-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('bd8c865b-0dde-4173-a00a-d5dbb9fecd69', 'b0000009-b001-b001-b001-00000000b001', '40000070-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('8c3b632b-7677-4d58-bade-2a6c64c3a838', 'b0000009-b001-b001-b001-00000000b001', '40000071-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('211f4c81-604c-408d-a64b-5e08ff95bacb', 'b0000009-b001-b001-b001-00000000b001', '40000072-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('d943edeb-24e9-4ac8-8e23-7a338bf8819e', 'b0000009-b001-b001-b001-00000000b001', '40000073-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('29fed358-f99a-45cd-ac85-62f9725dcf28', 'b0000009-b001-b001-b001-00000000b001', '40000074-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('41a9c412-060b-414e-8217-0decbc172c15', 'b0000009-b001-b001-b001-00000000b001', '40000075-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('5d4fcc61-6a1b-45fa-9509-857df5c82627', 'b0000009-b001-b001-b001-00000000b001', '40000076-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('650d5f5c-4301-47e8-8c96-f678b9d5f98f', 'b0000009-b001-b001-b001-00000000b001', '40000077-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL)

ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 6: TILE SYSTEM CONFIGURATION
-- ============================================================================

INSERT INTO public.screens (id, screen_name, description, is_active, created_at) VALUES
    ('25ac412d-453a-454c-a56c-4fca18e9882f', 'home', 'Home screen with aggregated updates', true, NOW()),
    ('7144c16c-a40e-43fc-8e5e-b2c2d7c6634d', 'gallery', 'Photo gallery screen', true, NOW()),
    ('dfb67aeb-d734-4158-b36c-461a3cd1e120', 'calendar', 'Calendar events screen', true, NOW()),
    ('b21d306b-3b86-4537-b599-2503d6d69547', 'registry', 'Baby registry screen', true, NOW()),
    ('97c0fbcb-c82e-477b-ab05-28f791a75b53', 'fun', 'Gamification and voting screen', true, NOW())

ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tile_definitions (id, tile_type, description, schema_params, is_active, created_at) VALUES
    ('7d8c4d92-01e1-45a4-8788-a9e0e5d96ac9', 'UpcomingEventsTile', 'Shows upcoming calendar events', '{"limit": 5, "daysAhead": 30}'::jsonb, true, NOW()),
    ('33e220f1-dd1d-493f-9e9a-85ba2c770fa4', 'RecentPhotosTile', 'Grid of recent photos', '{"limit": 6}'::jsonb, true, NOW()),
    ('5c59c85f-b0b7-4e69-b924-6f732e247928', 'RegistryHighlightsTile', 'Top priority unpurchased items', '{"limit": 3}'::jsonb, true, NOW()),
    ('ce88bb4c-f80a-4c90-8b18-35e33ff9c73c', 'ActivityListTile', 'Recent activity feed', '{"limit": 10}'::jsonb, true, NOW()),
    ('9f02e401-a017-457e-b6bb-cfc440e55fde', 'CountdownTile', 'Baby arrival countdown', '{}'::jsonb, true, NOW()),
    ('065a4643-0fe9-44fb-8126-122cb3501a67', 'NotificationsTile', 'Unread notifications', '{"limit": 5}'::jsonb, true, NOW())

ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tile_configs (id, screen_id, tile_definition_id, role, display_order, is_visible, params, updated_at) VALUES
    ('987d60d7-1b3a-42d8-8337-d6ce223bee3c', '25ac412d-453a-454c-a56c-4fca18e9882f', '9f02e401-a017-457e-b6bb-cfc440e55fde', 'owner', 10, true, '{}'::jsonb, NOW()),
    ('d61a3383-8710-4e20-b892-5b19deb888a1', '25ac412d-453a-454c-a56c-4fca18e9882f', '065a4643-0fe9-44fb-8126-122cb3501a67', 'owner', 20, true, '{"limit": 5}'::jsonb, NOW()),
    ('36f0c42b-60d9-4de8-a5c4-1f4a9f9a742f', '25ac412d-453a-454c-a56c-4fca18e9882f', 'ce88bb4c-f80a-4c90-8b18-35e33ff9c73c', 'owner', 30, true, '{"limit": 10}'::jsonb, NOW()),
    ('d6390ab9-e43e-41e0-a1ca-c374d4c7919f', '25ac412d-453a-454c-a56c-4fca18e9882f', '33e220f1-dd1d-493f-9e9a-85ba2c770fa4', 'owner', 40, true, '{"limit": 6}'::jsonb, NOW()),
    ('2fd20cad-53ec-4cba-be8d-85948a0a0d26', '25ac412d-453a-454c-a56c-4fca18e9882f', '9f02e401-a017-457e-b6bb-cfc440e55fde', 'follower', 10, true, '{}'::jsonb, NOW()),
    ('27788d11-6ebb-44be-b40e-c6991e5b3c32', '25ac412d-453a-454c-a56c-4fca18e9882f', 'ce88bb4c-f80a-4c90-8b18-35e33ff9c73c', 'follower', 20, true, '{"limit": 15}'::jsonb, NOW()),
    ('6d6ea654-6f23-4763-90db-444407954ccd', '25ac412d-453a-454c-a56c-4fca18e9882f', '33e220f1-dd1d-493f-9e9a-85ba2c770fa4', 'follower', 30, true, '{"limit": 9}'::jsonb, NOW()),
    ('d785f237-fdbc-44a9-a956-1ca99724608c', '25ac412d-453a-454c-a56c-4fca18e9882f', '7d8c4d92-01e1-45a4-8788-a9e0e5d96ac9', 'follower', 40, true, '{"limit": 3}'::jsonb, NOW())

ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA
-- Summary: 10 babies, 20 owners, 120 unique followers, 140 total users
-- Memberships: 20 owner + 130 follower (including 10 cross-profile) = 150 total
-- ============================================================================

-- Display summary statistics
DO $$
BEGIN
    RAISE NOTICE 'Seed data loaded successfully!';
    RAISE NOTICE 'Profiles: %', (SELECT COUNT(*) FROM public.profiles);
    RAISE NOTICE 'Baby Profiles: %', (SELECT COUNT(*) FROM public.baby_profiles);
    RAISE NOTICE 'Total Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE removed_at IS NULL);
    RAISE NOTICE 'Owner Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'owner' AND removed_at IS NULL);
    RAISE NOTICE 'Follower Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE role = 'follower' AND removed_at IS NULL);
END $$;
-- ============================================================================
-- Additional Seed Data for Missing Tables
-- To be appended to existing seed files
-- ============================================================================

-- ============================================================================
-- SECTION 7: OWNER UPDATE MARKERS (Cache invalidation)
-- ============================================================================

INSERT INTO public.owner_update_markers (id, baby_profile_id, tiles_last_updated_at, updated_by_user_id, reason) VALUES
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', NOW() - INTERVAL '1 day', '10000000-1001-1001-1001-000000001001', 'Initial profile setup'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', NOW() - INTERVAL '2 days', '10000001-1001-1001-1001-000000001001', 'Updated tiles configuration'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', NOW() - INTERVAL '3 days', '10000002-1001-1001-1001-000000001001', 'Added new content'),
    (gen_random_uuid(), 'b0000003-b001-b001-b001-00000000b001', NOW() - INTERVAL '4 days', '10000003-1001-1001-1001-000000001001', 'Modified settings'),
    (gen_random_uuid(), 'b0000004-b001-b001-b001-00000000b001', NOW() - INTERVAL '5 days', '10000004-1001-1001-1001-000000001001', 'Content update'),
    (gen_random_uuid(), 'b0000005-b001-b001-b001-00000000b001', NOW() - INTERVAL '6 days', '10000005-1001-1001-1001-000000001001', 'Profile changes'),
    (gen_random_uuid(), 'b0000006-b001-b001-b001-00000000b001', NOW() - INTERVAL '7 days', '10000006-1001-1001-1001-000000001001', 'New photos added'),
    (gen_random_uuid(), 'b0000007-b001-b001-b001-00000000b001', NOW() - INTERVAL '8 days', '10000007-1001-1001-1001-000000001001', 'Event created'),
    (gen_random_uuid(), 'b0000008-b001-b001-b001-00000000b001', NOW() - INTERVAL '9 days', '10000008-1001-1001-1001-000000001001', 'Registry updated'),
    (gen_random_uuid(), 'b0000009-b001-b001-b001-00000000b001', NOW() - INTERVAL '10 days', '10000009-1001-1001-1001-000000001001', 'General update')
ON CONFLICT (baby_profile_id) DO NOTHING;

-- ============================================================================
-- SECTION 8: EVENTS (Calendar events for baby profiles)
-- ============================================================================

INSERT INTO public.events (id, baby_profile_id, created_by_user_id, title, starts_at, ends_at, description, location, video_link, cover_photo_url, created_at, updated_at) VALUES
    -- Baby 0 events
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'Baby Shower', NOW() + INTERVAL '15 days', NOW() + INTERVAL '15 days' + INTERVAL '3 hours', 'Celebrating the upcoming arrival!', '123 Main St, Hometown', NULL, 'https://api.dicebear.com/7.x/shapes/svg?seed=event0', NOW() - INTERVAL '20 days', NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'Hospital Tour', NOW() + INTERVAL '10 days', NOW() + INTERVAL '10 days' + INTERVAL '1 hour', 'Tour of the maternity ward', 'City Hospital, 456 Oak Ave', NULL, NULL, NOW() - INTERVAL '15 days', NOW() - INTERVAL '8 days'),
    -- Baby 1 events
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'Gender Reveal Party', NOW() + INTERVAL '25 days', NOW() + INTERVAL '25 days' + INTERVAL '4 hours', 'Find out if it\'s a boy or girl!', 'Community Center', NULL, 'https://api.dicebear.com/7.x/shapes/svg?seed=event1', NOW() - INTERVAL '18 days', NOW() - INTERVAL '9 days'),
    -- Baby 2 events
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'Nursery Setup Day', NOW() + INTERVAL '20 days', NOW() + INTERVAL '20 days' + INTERVAL '6 hours', 'Help us set up the nursery', '789 Elm St', NULL, NULL, NOW() - INTERVAL '12 days', NOW() - INTERVAL '7 days'),
    -- Baby 3 events
    (gen_random_uuid(), 'b0000003-b001-b001-b001-00000000b001', '10000003-1001-1001-1001-000000001001', 'Virtual Baby Shower', NOW() + INTERVAL '30 days', NOW() + INTERVAL '30 days' + INTERVAL '2 hours', 'Join us online!', NULL, 'https://zoom.us/j/example', 'https://api.dicebear.com/7.x/shapes/svg?seed=event3', NOW() - INTERVAL '14 days', NOW() - INTERVAL '6 days'),
    -- Baby 4 events
    (gen_random_uuid(), 'b0000004-b001-b001-b001-00000000b001', '10000004-1001-1001-1001-000000001001', 'Meet and Greet', NOW() + INTERVAL '40 days', NOW() + INTERVAL '40 days' + INTERVAL '3 hours', 'Meet the parents-to-be', 'Local Park', NULL, NULL, NOW() - INTERVAL '16 days', NOW() - INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 9: EVENT RSVPS
-- ============================================================================

INSERT INTO public.event_rsvps (id, event_id, user_id, status, created_at, updated_at) VALUES
    -- RSVPs for first event (Baby 0 shower) - mix of responses
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000000-4001-4001-4001-000000004001', 'yes', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000001-4001-4001-4001-000000004001', 'yes', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000002-4001-4001-4001-000000004001', 'maybe', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000003-4001-4001-4001-000000004001', 'no', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
    -- RSVPs for Hospital Tour
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Hospital Tour' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000004-4001-4001-4001-000000004001', 'yes', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Hospital Tour' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000005-4001-4001-4001-000000004001', 'maybe', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
    -- RSVPs for Gender Reveal
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Gender Reveal Party' LIMIT 1), '4000000c-4001-4001-4001-000000004001', 'yes', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Gender Reveal Party' LIMIT 1), '4000000d-4001-4001-4001-000000004001', 'yes', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 10: EVENT COMMENTS
-- ============================================================================

INSERT INTO public.event_comments (id, event_id, user_id, body, created_at, deleted_at, deleted_by_user_id) VALUES
    -- Comments on Baby Shower
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000000-4001-4001-4001-000000004001', 'So excited for this! Can\'t wait to celebrate with you!', NOW() - INTERVAL '7 days', NULL, NULL),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000001-4001-4001-4001-000000004001', 'What should I bring?', NOW() - INTERVAL '6 days', NULL, NULL),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '10000000-1001-1001-1001-000000001001', 'Just bring yourself! We have everything covered.', NOW() - INTERVAL '5 days', NULL, NULL),
    -- Comments on Gender Reveal
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Gender Reveal Party' LIMIT 1), '4000000c-4001-4001-4001-000000004001', 'This is going to be so much fun!', NOW() - INTERVAL '5 days', NULL, NULL),
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Gender Reveal Party' LIMIT 1), '4000000d-4001-4001-4001-000000004001', 'I think it\'s a girl! 💕', NOW() - INTERVAL '4 days', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 11: PHOTOS
-- ============================================================================

INSERT INTO public.photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption, created_at, updated_at) VALUES
    -- Baby 0 photos
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'baby0/ultrasound_20weeks.jpg', '20 week ultrasound - looking healthy!', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'baby0/nursery_progress.jpg', 'Nursery is coming together nicely', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'baby0/baby_bump_25weeks.jpg', '25 weeks and growing!', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
    -- Baby 1 photos
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'baby1/first_ultrasound.jpg', 'Our first glimpse!', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '20000001-2001-2001-2001-000000002001', 'baby1/gender_reveal_cake.jpg', 'Gender reveal party preparations', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
    -- Baby 2 photos
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'baby2/baby_shower_decorations.jpg', 'Baby shower decorations', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '20000002-2001-2001-2001-000000002001', 'baby2/crib_assembly.jpg', 'Dad building the crib!', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
    -- Baby 3 photos
    (gen_random_uuid(), 'b0000003-b001-b001-b001-00000000b001', '10000003-1001-1001-1001-000000001001', 'baby3/baby_clothes.jpg', 'First baby clothes shopping spree', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 12: PHOTO SQUISHES (Likes)
-- ============================================================================

INSERT INTO public.photo_squishes (id, photo_id, user_id, created_at) VALUES
    -- Likes on various photos
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000000-4001-4001-4001-000000004001', NOW() - INTERVAL '14 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000001-4001-4001-4001-000000004001', NOW() - INTERVAL '13 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000002-4001-4001-4001-000000004001', NOW() - INTERVAL '12 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 1), '40000003-4001-4001-4001-000000004001', NOW() - INTERVAL '9 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 1), '40000004-4001-4001-4001-000000004001', NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 2), '40000005-4001-4001-4001-000000004001', NOW() - INTERVAL '4 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 2), '40000006-4001-4001-4001-000000004001', NOW() - INTERVAL '3 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 2), '40000007-4001-4001-4001-000000004001', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 13: PHOTO COMMENTS
-- ============================================================================

INSERT INTO public.photo_comments (id, photo_id, user_id, body, created_at, deleted_at, deleted_by_user_id) VALUES
    -- Comments on first photo
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000000-4001-4001-4001-000000004001', 'Such a beautiful ultrasound picture! 💕', NOW() - INTERVAL '14 days', NULL, NULL),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000001-4001-4001-4001-000000004001', 'Can\'t wait to meet the little one!', NOW() - INTERVAL '13 days', NULL, NULL),
    -- Comments on nursery photo
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 1), '40000003-4001-4001-4001-000000004001', 'The nursery looks amazing!', NOW() - INTERVAL '9 days', NULL, NULL),
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 1), '40000004-4001-4001-4001-000000004001', 'Love the color scheme!', NOW() - INTERVAL '8 days', NULL, NULL),
    -- Comments on baby bump photo
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1 OFFSET 2), '40000005-4001-4001-4001-000000004001', 'You look radiant! ✨', NOW() - INTERVAL '4 days', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 14: PHOTO TAGS
-- ============================================================================

INSERT INTO public.photo_tags (id, photo_id, tag, created_at) VALUES
    -- Tags for ultrasound photos
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%ultrasound%' LIMIT 1), 'ultrasound', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%ultrasound%' LIMIT 1), '20weeks', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%ultrasound%' LIMIT 1), 'healthy', NOW() - INTERVAL '15 days'),
    -- Tags for nursery photos
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%nursery%' LIMIT 1), 'nursery', NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%nursery%' LIMIT 1), 'preparation', NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%nursery%' LIMIT 1), 'babyroom', NOW() - INTERVAL '10 days'),
    -- Tags for baby bump photos
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%baby_bump%' LIMIT 1), 'babybump', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%baby_bump%' LIMIT 1), '25weeks', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), (SELECT id FROM public.photos WHERE storage_path LIKE '%baby_bump%' LIMIT 1), 'pregnancy', NOW() - INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 15: REGISTRY ITEMS
-- ============================================================================

INSERT INTO public.registry_items (id, baby_profile_id, created_by_user_id, name, description, link_url, priority, created_at, updated_at) VALUES
    -- Baby 0 registry
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'Crib', 'Convertible crib with organic mattress', 'https://example.com/crib', 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'Stroller', 'All-terrain jogging stroller', 'https://example.com/stroller', 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'Car Seat', 'Infant car seat with base', 'https://example.com/carseat', 1, NOW() - INTERVAL '24 days', NOW() - INTERVAL '19 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'Baby Monitor', 'Video baby monitor with night vision', 'https://example.com/monitor', 2, NOW() - INTERVAL '23 days', NOW() - INTERVAL '18 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'Diaper Bag', 'Stylish diaper backpack', 'https://example.com/diaperbag', 2, NOW() - INTERVAL '22 days', NOW() - INTERVAL '17 days'),
    -- Baby 1 registry
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'Baby Clothes Set', 'Newborn onesies and sleepers (0-3 months)', 'https://example.com/clothes', 1, NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'Nursing Pillow', 'Ergonomic nursing and feeding pillow', 'https://example.com/nursing-pillow', 2, NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days'),
    -- Baby 2 registry
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'Baby Swing', 'Portable baby swing with music', 'https://example.com/swing', 2, NOW() - INTERVAL '18 days', NOW() - INTERVAL '13 days'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'Bottles and Sterilizer', 'Complete bottle feeding set', 'https://example.com/bottles', 1, NOW() - INTERVAL '18 days', NOW() - INTERVAL '13 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 16: REGISTRY PURCHASES
-- ============================================================================

INSERT INTO public.registry_purchases (id, registry_item_id, purchased_by_user_id, purchased_at, note) VALUES
    -- Crib purchased
    (gen_random_uuid(), (SELECT id FROM public.registry_items WHERE name = 'Crib' LIMIT 1), '40000000-4001-4001-4001-000000004001', NOW() - INTERVAL '18 days', 'So happy to get this for you!'),
    -- Stroller purchased
    (gen_random_uuid(), (SELECT id FROM public.registry_items WHERE name = 'Stroller' LIMIT 1), '40000001-4001-4001-4001-000000004001', NOW() - INTERVAL '16 days', 'Can\'t wait for walks with baby!'),
    -- Baby Monitor purchased
    (gen_random_uuid(), (SELECT id FROM public.registry_items WHERE name = 'Baby Monitor' LIMIT 1), '40000002-4001-4001-4001-000000004001', NOW() - INTERVAL '15 days', 'For peace of mind'),
    -- Baby Clothes purchased
    (gen_random_uuid(), (SELECT id FROM public.registry_items WHERE name = 'Baby Clothes Set' LIMIT 1), '4000000c-4001-4001-4001-000000004001', NOW() - INTERVAL '12 days', 'These are adorable!')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 17: VOTES (Gender/Birthdate predictions)
-- ============================================================================

INSERT INTO public.votes (id, baby_profile_id, user_id, vote_type, value_text, value_date, is_anonymous, created_at, updated_at) VALUES
    -- Baby 0 gender votes
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'gender', 'girl', NULL, true, NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000001-4001-4001-4001-000000004001', 'gender', 'boy', NULL, true, NOW() - INTERVAL '19 days', NOW() - INTERVAL '19 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000002-4001-4001-4001-000000004001', 'gender', 'girl', NULL, false, NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
    -- Baby 0 birthdate votes
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000003-4001-4001-4001-000000004001', 'birthdate', NULL, NOW() + INTERVAL '28 days', true, NOW() - INTERVAL '17 days', NOW() - INTERVAL '17 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000004-4001-4001-4001-000000004001', 'birthdate', NULL, NOW() + INTERVAL '32 days', true, NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days'),
    -- Baby 1 gender votes
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'gender', 'boy', NULL, true, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000d-4001-4001-4001-000000004001', 'gender', 'boy', NULL, true, NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days'),
    -- Baby 2 gender votes
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '40000018-4001-4001-4001-000000004001', 'gender', 'girl', NULL, false, NOW() - INTERVAL '13 days', NOW() - INTERVAL '13 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 18: NAME SUGGESTIONS
-- ============================================================================

INSERT INTO public.name_suggestions (id, baby_profile_id, user_id, gender, suggested_name, created_at, updated_at) VALUES
    -- Baby 0 name suggestions (gender unknown, so suggestions for both)
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'female', 'Olivia', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000001-4001-4001-4001-000000004001', 'female', 'Emma', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000002-4001-4001-4001-000000004001', 'male', 'Noah', NOW() - INTERVAL '13 days', NOW() - INTERVAL '13 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000003-4001-4001-4001-000000004001', 'male', 'Liam', NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
    -- Baby 1 name suggestions (male)
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'male', 'Oliver', NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000d-4001-4001-4001-000000004001', 'male', 'Ethan', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
    -- Baby 2 name suggestions (female)
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '40000018-4001-4001-4001-000000004001', 'female', 'Sophia', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '40000019-4001-4001-4001-000000004001', 'female', 'Isabella', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 19: NAME SUGGESTION LIKES
-- ============================================================================

INSERT INTO public.name_suggestion_likes (id, name_suggestion_id, user_id, created_at) VALUES
    -- Likes on Olivia
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Olivia' LIMIT 1), '40000004-4001-4001-4001-000000004001', NOW() - INTERVAL '14 days'),
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Olivia' LIMIT 1), '40000005-4001-4001-4001-000000004001', NOW() - INTERVAL '13 days'),
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Olivia' LIMIT 1), '40000006-4001-4001-4001-000000004001', NOW() - INTERVAL '12 days'),
    -- Likes on Noah
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Noah' LIMIT 1), '40000007-4001-4001-4001-000000004001', NOW() - INTERVAL '11 days'),
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Noah' LIMIT 1), '40000008-4001-4001-4001-000000004001', NOW() - INTERVAL '10 days'),
    -- Likes on Oliver
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Oliver' LIMIT 1), '4000000e-4001-4001-4001-000000004001', NOW() - INTERVAL '9 days'),
    (gen_random_uuid(), (SELECT id FROM public.name_suggestions WHERE suggested_name = 'Oliver' LIMIT 1), '4000000f-4001-4001-4001-000000004001', NOW() - INTERVAL '8 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 20: INVITATIONS
-- ============================================================================

INSERT INTO public.invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status, accepted_at, accepted_by_user_id, created_at, updated_at) VALUES
    -- Pending invitations
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'friend1@example.com', encode(sha256('token_baby0_pending1'::bytea), 'hex'), NOW() + INTERVAL '5 days', 'pending', NULL, NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'friend2@example.com', encode(sha256('token_baby0_pending2'::bytea), 'hex'), NOW() + INTERVAL '6 days', 'pending', NULL, NULL, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    -- Accepted invitation
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'accepted@example.com', encode(sha256('token_baby1_accepted'::bytea), 'hex'), NOW() + INTERVAL '7 days', 'accepted', NOW() - INTERVAL '3 days', '40000010-4001-4001-4001-000000004001', NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days'),
    -- Expired invitation
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'expired@example.com', encode(sha256('token_baby2_expired'::bytea), 'hex'), NOW() - INTERVAL '1 day', 'expired', NULL, NULL, NOW() - INTERVAL '8 days', NOW() - INTERVAL '1 day'),
    -- Revoked invitation
    (gen_random_uuid(), 'b0000003-b001-b001-b001-00000000b001', '10000003-1001-1001-1001-000000001001', 'revoked@example.com', encode(sha256('token_baby3_revoked'::bytea), 'hex'), NOW() + INTERVAL '7 days', 'revoked', NULL, NULL, NOW() - INTERVAL '4 days', NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 21: NOTIFICATIONS
-- ============================================================================

INSERT INTO public.notifications (id, recipient_user_id, baby_profile_id, type, payload, created_at, read_at) VALUES
    -- Notifications for follower users
    (gen_random_uuid(), '40000000-4001-4001-4001-000000004001', 'b0000000-b001-b001-b001-00000000b001', 'new_photo', '{"photo_id": "photo-123", "caption": "New ultrasound!"}'::jsonb, NOW() - INTERVAL '5 days', NULL),
    (gen_random_uuid(), '40000000-4001-4001-4001-000000004001', 'b0000000-b001-b001-b001-00000000b001', 'event_created', '{"event_id": "event-456", "title": "Baby Shower"}'::jsonb, NOW() - INTERVAL '10 days', NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), '40000001-4001-4001-4001-000000004001', 'b0000000-b001-b001-b001-00000000b001', 'comment_on_photo', '{"photo_id": "photo-123", "commenter": "Grandma Emma"}'::jsonb, NOW() - INTERVAL '4 days', NULL),
    (gen_random_uuid(), '40000001-4001-4001-4001-000000004001', 'b0000000-b001-b001-b001-00000000b001', 'registry_item_purchased', '{"item_name": "Crib", "purchaser": "Aunt Ava"}'::jsonb, NOW() - INTERVAL '18 days', NOW() - INTERVAL '17 days'),
    -- Owner notifications
    (gen_random_uuid(), '10000000-1001-1001-1001-000000001001', 'b0000000-b001-b001-b001-00000000b001', 'new_rsvp', '{"event_title": "Baby Shower", "user": "Grandma Emma", "status": "yes"}'::jsonb, NOW() - INTERVAL '8 days', NOW() - INTERVAL '7 days'),
    (gen_random_uuid(), '10000000-1001-1001-1001-000000001001', 'b0000000-b001-b001-b001-00000000b001', 'photo_like', '{"photo_caption": "20 week ultrasound", "liker": "Godparent Evelyn"}'::jsonb, NOW() - INTERVAL '14 days', NOW() - INTERVAL '12 days'),
    (gen_random_uuid(), '10000001-1001-1001-1001-000000001001', 'b0000001-b001-b001-b001-00000000b001', 'name_suggestion', '{"suggested_name": "Oliver", "suggester": "Aunt Oliver"}'::jsonb, NOW() - INTERVAL '11 days', NULL),
    (gen_random_uuid(), '10000001-1001-1001-1001-000000001001', 'b0000001-b001-b001-b001-00000000b001', 'new_vote', '{"vote_type": "gender", "value": "boy"}'::jsonb, NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 22: ACTIVITY EVENTS (Recent activity stream)
-- ============================================================================

INSERT INTO public.activity_events (id, baby_profile_id, actor_user_id, type, payload, created_at) VALUES
    -- Baby 0 activities
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'photo_uploaded', '{"photo_id": "photo-1", "caption": "20 week ultrasound"}'::jsonb, NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'event_created', '{"event_id": "event-1", "title": "Baby Shower"}'::jsonb, NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'registry_item_purchased', '{"item_name": "Crib"}'::jsonb, NOW() - INTERVAL '18 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'rsvp_submitted', '{"event_title": "Baby Shower", "status": "yes"}'::jsonb, NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000002-4001-4001-4001-000000004001', 'vote_submitted', '{"vote_type": "gender", "value": "girl"}'::jsonb, NOW() - INTERVAL '18 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'name_suggested', '{"name": "Olivia", "gender": "female"}'::jsonb, NOW() - INTERVAL '15 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'photo_uploaded', '{"photo_id": "photo-2", "caption": "Nursery progress"}'::jsonb, NOW() - INTERVAL '10 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000001-4001-4001-4001-000000004001', 'comment_added', '{"resource_type": "photo", "comment": "So excited!"}'::jsonb, NOW() - INTERVAL '7 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'photo_uploaded', '{"photo_id": "photo-3", "caption": "25 weeks"}'::jsonb, NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'b0000000-b001-b001-b001-00000000b001', '40000005-4001-4001-4001-000000004001', 'comment_added', '{"resource_type": "photo", "comment": "You look radiant!"}'::jsonb, NOW() - INTERVAL '4 days'),
    -- Baby 1 activities
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'event_created', '{"event_id": "event-2", "title": "Gender Reveal Party"}'::jsonb, NOW() - INTERVAL '18 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'photo_uploaded', '{"photo_id": "photo-4", "caption": "First ultrasound"}'::jsonb, NOW() - INTERVAL '20 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'name_suggested', '{"name": "Oliver", "gender": "male"}'::jsonb, NOW() - INTERVAL '11 days'),
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'vote_submitted', '{"vote_type": "gender", "value": "boy"}'::jsonb, NOW() - INTERVAL '15 days'),
    -- Baby 2 activities  
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'photo_uploaded', '{"photo_id": "photo-6", "caption": "Baby shower decorations"}'::jsonb, NOW() - INTERVAL '8 days'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '20000002-2001-2001-2001-000000002001', 'photo_uploaded', '{"photo_id": "photo-7", "caption": "Crib assembly"}'::jsonb, NOW() - INTERVAL '6 days'),
    (gen_random_uuid(), 'b0000002-b001-b001-b001-00000000b001', '40000018-4001-4001-4001-000000004001', 'name_suggested', '{"name": "Sophia", "gender": "female"}'::jsonb, NOW() - INTERVAL '9 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- END OF ADDITIONAL SEED DATA
-- ============================================================================

-- Display summary of additional data
DO $$
BEGIN
    RAISE NOTICE '=== Additional Seed Data Summary ===';
    RAISE NOTICE 'Owner Update Markers: %', (SELECT COUNT(*) FROM public.owner_update_markers);
    RAISE NOTICE 'Events: %', (SELECT COUNT(*) FROM public.events);
    RAISE NOTICE 'Event RSVPs: %', (SELECT COUNT(*) FROM public.event_rsvps);
    RAISE NOTICE 'Event Comments: %', (SELECT COUNT(*) FROM public.event_comments);
    RAISE NOTICE 'Photos: %', (SELECT COUNT(*) FROM public.photos);
    RAISE NOTICE 'Photo Squishes: %', (SELECT COUNT(*) FROM public.photo_squishes);
    RAISE NOTICE 'Photo Comments: %', (SELECT COUNT(*) FROM public.photo_comments);
    RAISE NOTICE 'Photo Tags: %', (SELECT COUNT(*) FROM public.photo_tags);
    RAISE NOTICE 'Registry Items: %', (SELECT COUNT(*) FROM public.registry_items);
    RAISE NOTICE 'Registry Purchases: %', (SELECT COUNT(*) FROM public.registry_purchases);
    RAISE NOTICE 'Votes: %', (SELECT COUNT(*) FROM public.votes);
    RAISE NOTICE 'Name Suggestions: %', (SELECT COUNT(*) FROM public.name_suggestions);
    RAISE NOTICE 'Name Suggestion Likes: %', (SELECT COUNT(*) FROM public.name_suggestion_likes);
    RAISE NOTICE 'Invitations: %', (SELECT COUNT(*) FROM public.invitations);
    RAISE NOTICE 'Notifications: %', (SELECT COUNT(*) FROM public.notifications);
    RAISE NOTICE 'Activity Events: %', (SELECT COUNT(*) FROM public.activity_events);
    RAISE NOTICE '====================================';
END $$;
