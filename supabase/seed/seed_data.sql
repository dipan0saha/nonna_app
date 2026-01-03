-- ============================================================================
-- Nonna App - Comprehensive Seed Data Script
-- Version: 2.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Extended test data - 10 babies, 20 owners, 120 followers
-- ============================================================================

-- NOTE: In production, auth.users would be created via Supabase Auth API.
-- For testing, we create profiles directly.

-- ============================================================================
-- SECTION 1: PROFILES - Owners (20 users, 2 per baby)
-- ============================================================================
SET session_replication_role = 'replica';
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
-- SECTION 2: PROFILES - Followers (120 users, 12 per baby)
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
    ('30000000-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000001-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000001-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000001-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000002-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000002-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000002-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000003-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000003-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000003-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000004-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000004-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000004-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000005-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000005-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000005-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000006-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000006-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000006-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000007-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000007-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000007-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000008-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000008-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000008-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
    ('10000009-1001-1001-1001-000000001001', 0, 0, 0, 0, NOW()),
    ('20000009-2001-2001-2001-000000002001', 0, 0, 0, 0, NOW()),
    ('30000009-3001-3001-3001-000000003001', 0, 0, 0, 0, NOW()),
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
-- SECTION 5: BABY MEMBERSHIPS (30 owners + 120 followers = 150 memberships)
-- ============================================================================

INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role, relationship_label, created_at, updated_at, removed_at) VALUES
    ('bm-000001', 'b0000000-b001-b001-b001-00000000b001', '10000000-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000002', 'b0000000-b001-b001-b001-00000000b001', '20000000-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000003', 'b0000000-b001-b001-b001-00000000b001', '30000000-3001-3001-3001-000000003001', 'owner', 'Grandmother', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000004', 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000005', 'b0000001-b001-b001-b001-00000000b001', '20000001-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000006', 'b0000001-b001-b001-b001-00000000b001', '30000001-3001-3001-3001-000000003001', 'owner', 'Grandfather', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000007', 'b0000002-b001-b001-b001-00000000b001', '10000002-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000008', 'b0000002-b001-b001-b001-00000000b001', '20000002-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000009', 'b0000002-b001-b001-b001-00000000b001', '30000002-3001-3001-3001-000000003001', 'owner', 'Grandmother', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000010', 'b0000003-b001-b001-b001-00000000b001', '10000003-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000011', 'b0000003-b001-b001-b001-00000000b001', '20000003-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000012', 'b0000003-b001-b001-b001-00000000b001', '30000003-3001-3001-3001-000000003001', 'owner', 'Grandfather', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000013', 'b0000004-b001-b001-b001-00000000b001', '10000004-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000014', 'b0000004-b001-b001-b001-00000000b001', '20000004-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000015', 'b0000004-b001-b001-b001-00000000b001', '30000004-3001-3001-3001-000000003001', 'owner', 'Grandmother', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000016', 'b0000005-b001-b001-b001-00000000b001', '10000005-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000017', 'b0000005-b001-b001-b001-00000000b001', '20000005-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000018', 'b0000005-b001-b001-b001-00000000b001', '30000005-3001-3001-3001-000000003001', 'owner', 'Grandfather', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000019', 'b0000006-b001-b001-b001-00000000b001', '10000006-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000020', 'b0000006-b001-b001-b001-00000000b001', '20000006-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000021', 'b0000006-b001-b001-b001-00000000b001', '30000006-3001-3001-3001-000000003001', 'owner', 'Grandmother', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000022', 'b0000007-b001-b001-b001-00000000b001', '10000007-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000023', 'b0000007-b001-b001-b001-00000000b001', '20000007-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000024', 'b0000007-b001-b001-b001-00000000b001', '30000007-3001-3001-3001-000000003001', 'owner', 'Grandfather', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000025', 'b0000008-b001-b001-b001-00000000b001', '10000008-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000026', 'b0000008-b001-b001-b001-00000000b001', '20000008-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000027', 'b0000008-b001-b001-b001-00000000b001', '30000008-3001-3001-3001-000000003001', 'owner', 'Grandmother', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000028', 'b0000009-b001-b001-b001-00000000b001', '10000009-1001-1001-1001-000000001001', 'owner', 'Mother', NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days', NULL),
    ('bm-000029', 'b0000009-b001-b001-b001-00000000b001', '20000009-2001-2001-2001-000000002001', 'owner', 'Father', NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days', NULL),
    ('bm-000030', 'b0000009-b001-b001-b001-00000000b001', '30000009-3001-3001-3001-000000003001', 'owner', 'Grandfather', NOW() - INTERVAL '57 days', NOW() - INTERVAL '57 days', NULL),
    ('bm-000031', 'b0000000-b001-b001-b001-00000000b001', '40000000-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('bm-000032', 'b0000000-b001-b001-b001-00000000b001', '40000001-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('bm-000033', 'b0000000-b001-b001-b001-00000000b001', '40000002-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('bm-000034', 'b0000000-b001-b001-b001-00000000b001', '40000003-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('bm-000035', 'b0000000-b001-b001-b001-00000000b001', '40000004-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('bm-000036', 'b0000000-b001-b001-b001-00000000b001', '40000005-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000037', 'b0000000-b001-b001-b001-00000000b001', '40000006-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('bm-000038', 'b0000000-b001-b001-b001-00000000b001', '40000007-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('bm-000039', 'b0000000-b001-b001-b001-00000000b001', '40000008-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000040', 'b0000000-b001-b001-b001-00000000b001', '40000009-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('bm-000041', 'b0000000-b001-b001-b001-00000000b001', '4000000a-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('bm-000042', 'b0000000-b001-b001-b001-00000000b001', '4000000b-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000043', 'b0000001-b001-b001-b001-00000000b001', '4000000c-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('bm-000044', 'b0000001-b001-b001-b001-00000000b001', '4000000d-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('bm-000045', 'b0000001-b001-b001-b001-00000000b001', '4000000e-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000046', 'b0000001-b001-b001-b001-00000000b001', '4000000f-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('bm-000047', 'b0000001-b001-b001-b001-00000000b001', '40000010-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('bm-000048', 'b0000001-b001-b001-b001-00000000b001', '40000011-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000049', 'b0000001-b001-b001-b001-00000000b001', '40000012-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('bm-000050', 'b0000001-b001-b001-b001-00000000b001', '40000013-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('bm-000051', 'b0000001-b001-b001-b001-00000000b001', '40000014-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000052', 'b0000001-b001-b001-b001-00000000b001', '40000015-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('bm-000053', 'b0000001-b001-b001-b001-00000000b001', '40000016-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('bm-000054', 'b0000001-b001-b001-b001-00000000b001', '40000017-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000055', 'b0000002-b001-b001-b001-00000000b001', '40000018-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('bm-000056', 'b0000002-b001-b001-b001-00000000b001', '40000019-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('bm-000057', 'b0000002-b001-b001-b001-00000000b001', '4000001a-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000058', 'b0000002-b001-b001-b001-00000000b001', '4000001b-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('bm-000059', 'b0000002-b001-b001-b001-00000000b001', '4000001c-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('bm-000060', 'b0000002-b001-b001-b001-00000000b001', '4000001d-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000061', 'b0000002-b001-b001-b001-00000000b001', '4000001e-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('bm-000062', 'b0000002-b001-b001-b001-00000000b001', '4000001f-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('bm-000063', 'b0000002-b001-b001-b001-00000000b001', '40000020-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('bm-000064', 'b0000002-b001-b001-b001-00000000b001', '40000021-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('bm-000065', 'b0000002-b001-b001-b001-00000000b001', '40000022-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('bm-000066', 'b0000002-b001-b001-b001-00000000b001', '40000023-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000067', 'b0000003-b001-b001-b001-00000000b001', '40000024-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('bm-000068', 'b0000003-b001-b001-b001-00000000b001', '40000025-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('bm-000069', 'b0000003-b001-b001-b001-00000000b001', '40000026-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000070', 'b0000003-b001-b001-b001-00000000b001', '40000027-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('bm-000071', 'b0000003-b001-b001-b001-00000000b001', '40000028-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('bm-000072', 'b0000003-b001-b001-b001-00000000b001', '40000029-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000073', 'b0000003-b001-b001-b001-00000000b001', '4000002a-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('bm-000074', 'b0000003-b001-b001-b001-00000000b001', '4000002b-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('bm-000075', 'b0000003-b001-b001-b001-00000000b001', '4000002c-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000076', 'b0000003-b001-b001-b001-00000000b001', '4000002d-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('bm-000077', 'b0000003-b001-b001-b001-00000000b001', '4000002e-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('bm-000078', 'b0000003-b001-b001-b001-00000000b001', '4000002f-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000079', 'b0000004-b001-b001-b001-00000000b001', '40000030-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('bm-000080', 'b0000004-b001-b001-b001-00000000b001', '40000031-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('bm-000081', 'b0000004-b001-b001-b001-00000000b001', '40000032-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000082', 'b0000004-b001-b001-b001-00000000b001', '40000033-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('bm-000083', 'b0000004-b001-b001-b001-00000000b001', '40000034-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('bm-000084', 'b0000004-b001-b001-b001-00000000b001', '40000035-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000085', 'b0000004-b001-b001-b001-00000000b001', '40000036-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('bm-000086', 'b0000004-b001-b001-b001-00000000b001', '40000037-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('bm-000087', 'b0000004-b001-b001-b001-00000000b001', '40000038-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000088', 'b0000004-b001-b001-b001-00000000b001', '40000039-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('bm-000089', 'b0000004-b001-b001-b001-00000000b001', '4000003a-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('bm-000090', 'b0000004-b001-b001-b001-00000000b001', '4000003b-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000091', 'b0000005-b001-b001-b001-00000000b001', '4000003c-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('bm-000092', 'b0000005-b001-b001-b001-00000000b001', '4000003d-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('bm-000093', 'b0000005-b001-b001-b001-00000000b001', '4000003e-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('bm-000094', 'b0000005-b001-b001-b001-00000000b001', '4000003f-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('bm-000095', 'b0000005-b001-b001-b001-00000000b001', '40000040-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('bm-000096', 'b0000005-b001-b001-b001-00000000b001', '40000041-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000097', 'b0000005-b001-b001-b001-00000000b001', '40000042-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('bm-000098', 'b0000005-b001-b001-b001-00000000b001', '40000043-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('bm-000099', 'b0000005-b001-b001-b001-00000000b001', '40000044-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000100', 'b0000005-b001-b001-b001-00000000b001', '40000045-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('bm-000101', 'b0000005-b001-b001-b001-00000000b001', '40000046-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('bm-000102', 'b0000005-b001-b001-b001-00000000b001', '40000047-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000103', 'b0000006-b001-b001-b001-00000000b001', '40000048-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('bm-000104', 'b0000006-b001-b001-b001-00000000b001', '40000049-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('bm-000105', 'b0000006-b001-b001-b001-00000000b001', '4000004a-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000106', 'b0000006-b001-b001-b001-00000000b001', '4000004b-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('bm-000107', 'b0000006-b001-b001-b001-00000000b001', '4000004c-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('bm-000108', 'b0000006-b001-b001-b001-00000000b001', '4000004d-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000109', 'b0000006-b001-b001-b001-00000000b001', '4000004e-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('bm-000110', 'b0000006-b001-b001-b001-00000000b001', '4000004f-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('bm-000111', 'b0000006-b001-b001-b001-00000000b001', '40000050-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000112', 'b0000006-b001-b001-b001-00000000b001', '40000051-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('bm-000113', 'b0000006-b001-b001-b001-00000000b001', '40000052-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('bm-000114', 'b0000006-b001-b001-b001-00000000b001', '40000053-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000115', 'b0000007-b001-b001-b001-00000000b001', '40000054-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('bm-000116', 'b0000007-b001-b001-b001-00000000b001', '40000055-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('bm-000117', 'b0000007-b001-b001-b001-00000000b001', '40000056-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000118', 'b0000007-b001-b001-b001-00000000b001', '40000057-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('bm-000119', 'b0000007-b001-b001-b001-00000000b001', '40000058-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('bm-000120', 'b0000007-b001-b001-b001-00000000b001', '40000059-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL),
    ('bm-000121', 'b0000007-b001-b001-b001-00000000b001', '4000005a-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('bm-000122', 'b0000007-b001-b001-b001-00000000b001', '4000005b-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '26 days', NOW() - INTERVAL '26 days', NULL),
    ('bm-000123', 'b0000007-b001-b001-b001-00000000b001', '4000005c-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '27 days', NOW() - INTERVAL '27 days', NULL),
    ('bm-000124', 'b0000007-b001-b001-b001-00000000b001', '4000005d-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days', NULL),
    ('bm-000125', 'b0000007-b001-b001-b001-00000000b001', '4000005e-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '29 days', NOW() - INTERVAL '29 days', NULL),
    ('bm-000126', 'b0000007-b001-b001-b001-00000000b001', '4000005f-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000127', 'b0000008-b001-b001-b001-00000000b001', '40000060-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '31 days', NOW() - INTERVAL '31 days', NULL),
    ('bm-000128', 'b0000008-b001-b001-b001-00000000b001', '40000061-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days', NULL),
    ('bm-000129', 'b0000008-b001-b001-b001-00000000b001', '40000062-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '33 days', NOW() - INTERVAL '33 days', NULL),
    ('bm-000130', 'b0000008-b001-b001-b001-00000000b001', '40000063-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '34 days', NOW() - INTERVAL '34 days', NULL),
    ('bm-000131', 'b0000008-b001-b001-b001-00000000b001', '40000064-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '35 days', NOW() - INTERVAL '35 days', NULL),
    ('bm-000132', 'b0000008-b001-b001-b001-00000000b001', '40000065-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '36 days', NOW() - INTERVAL '36 days', NULL),
    ('bm-000133', 'b0000008-b001-b001-b001-00000000b001', '40000066-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days', NULL),
    ('bm-000134', 'b0000008-b001-b001-b001-00000000b001', '40000067-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '38 days', NOW() - INTERVAL '38 days', NULL),
    ('bm-000135', 'b0000008-b001-b001-b001-00000000b001', '40000068-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days', NULL),
    ('bm-000136', 'b0000008-b001-b001-b001-00000000b001', '40000069-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days', NULL),
    ('bm-000137', 'b0000008-b001-b001-b001-00000000b001', '4000006a-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '41 days', NOW() - INTERVAL '41 days', NULL),
    ('bm-000138', 'b0000008-b001-b001-b001-00000000b001', '4000006b-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days', NULL),
    ('bm-000139', 'b0000009-b001-b001-b001-00000000b001', '4000006c-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '43 days', NOW() - INTERVAL '43 days', NULL),
    ('bm-000140', 'b0000009-b001-b001-b001-00000000b001', '4000006d-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '44 days', NOW() - INTERVAL '44 days', NULL),
    ('bm-000141', 'b0000009-b001-b001-b001-00000000b001', '4000006e-4001-4001-4001-000000004001', 'follower', 'Grandma', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days', NULL),
    ('bm-000142', 'b0000009-b001-b001-b001-00000000b001', '4000006f-4001-4001-4001-000000004001', 'follower', 'Grandpa', NOW() - INTERVAL '46 days', NOW() - INTERVAL '46 days', NULL),
    ('bm-000143', 'b0000009-b001-b001-b001-00000000b001', '40000070-4001-4001-4001-000000004001', 'follower', 'Aunt', NOW() - INTERVAL '47 days', NOW() - INTERVAL '47 days', NULL),
    ('bm-000144', 'b0000009-b001-b001-b001-00000000b001', '40000071-4001-4001-4001-000000004001', 'follower', 'Uncle', NOW() - INTERVAL '48 days', NOW() - INTERVAL '48 days', NULL),
    ('bm-000145', 'b0000009-b001-b001-b001-00000000b001', '40000072-4001-4001-4001-000000004001', 'follower', 'Cousin', NOW() - INTERVAL '49 days', NOW() - INTERVAL '49 days', NULL),
    ('bm-000146', 'b0000009-b001-b001-b001-00000000b001', '40000073-4001-4001-4001-000000004001', 'follower', 'Friend', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL),
    ('bm-000147', 'b0000009-b001-b001-b001-00000000b001', '40000074-4001-4001-4001-000000004001', 'follower', 'Neighbor', NOW() - INTERVAL '51 days', NOW() - INTERVAL '51 days', NULL),
    ('bm-000148', 'b0000009-b001-b001-b001-00000000b001', '40000075-4001-4001-4001-000000004001', 'follower', 'Colleague', NOW() - INTERVAL '52 days', NOW() - INTERVAL '52 days', NULL),
    ('bm-000149', 'b0000009-b001-b001-b001-00000000b001', '40000076-4001-4001-4001-000000004001', 'follower', 'Family Friend', NOW() - INTERVAL '53 days', NOW() - INTERVAL '53 days', NULL),
    ('bm-000150', 'b0000009-b001-b001-b001-00000000b001', '40000077-4001-4001-4001-000000004001', 'follower', 'Godparent', NOW() - INTERVAL '54 days', NOW() - INTERVAL '54 days', NULL)

ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 6: TILE SYSTEM CONFIGURATION
-- ============================================================================

INSERT INTO public.screens (id, screen_name, description, is_active, created_at) VALUES
    ('screen-home', 'home', 'Home screen with aggregated updates', true, NOW()),
    ('screen-gallery', 'gallery', 'Photo gallery screen', true, NOW()),
    ('screen-calendar', 'calendar', 'Calendar events screen', true, NOW()),
    ('screen-registry', 'registry', 'Baby registry screen', true, NOW()),
    ('screen-fun', 'fun', 'Gamification and voting screen', true, NOW())

ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tile_definitions (id, tile_type, description, schema_params, is_active, created_at) VALUES
    ('tile-upcoming-events', 'UpcomingEventsTile', 'Shows upcoming calendar events', '{"limit": 5, "daysAhead": 30}'::jsonb, true, NOW()),
    ('tile-recent-photos', 'RecentPhotosTile', 'Grid of recent photos', '{"limit": 6}'::jsonb, true, NOW()),
    ('tile-registry-highlights', 'RegistryHighlightsTile', 'Top priority unpurchased items', '{"limit": 3}'::jsonb, true, NOW()),
    ('tile-activity-list', 'ActivityListTile', 'Recent activity feed', '{"limit": 10}'::jsonb, true, NOW()),
    ('tile-countdown', 'CountdownTile', 'Baby arrival countdown', '{}'::jsonb, true, NOW()),
    ('tile-notifications', 'NotificationsTile', 'Unread notifications', '{"limit": 5}'::jsonb, true, NOW())

ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tile_configs (id, screen_id, tile_definition_id, role, display_order, is_visible, params, updated_at) VALUES
    ('cfg-home-owner-1', 'screen-home', 'tile-countdown', 'owner', 10, true, '{}'::jsonb, NOW()),
    ('cfg-home-owner-2', 'screen-home', 'tile-notifications', 'owner', 20, true, '{"limit": 5}'::jsonb, NOW()),
    ('cfg-home-owner-3', 'screen-home', 'tile-activity-list', 'owner', 30, true, '{"limit": 10}'::jsonb, NOW()),
    ('cfg-home-owner-4', 'screen-home', 'tile-recent-photos', 'owner', 40, true, '{"limit": 6}'::jsonb, NOW()),
    ('cfg-home-follower-1', 'screen-home', 'tile-countdown', 'follower', 10, true, '{}'::jsonb, NOW()),
    ('cfg-home-follower-2', 'screen-home', 'tile-activity-list', 'follower', 20, true, '{"limit": 15}'::jsonb, NOW()),
    ('cfg-home-follower-3', 'screen-home', 'tile-recent-photos', 'follower', 30, true, '{"limit": 9}'::jsonb, NOW()),
    ('cfg-home-follower-4', 'screen-home', 'tile-upcoming-events', 'follower', 40, true, '{"limit": 3}'::jsonb, NOW())

ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA
-- Summary: 10 babies, 30 owners, 120 followers, 150 total users
-- ============================================================================

-- Display summary statistics
DO $$
BEGIN
    RAISE NOTICE 'Seed data loaded successfully!';
    RAISE NOTICE 'Profiles: %', (SELECT COUNT(*) FROM public.profiles);
    RAISE NOTICE 'Baby Profiles: %', (SELECT COUNT(*) FROM public.baby_profiles);
    RAISE NOTICE 'Total Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE removed_at IS NULL);
    RAISE NOTICE 'Owner Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE role = ''owner'' AND removed_at IS NULL);
    RAISE NOTICE 'Follower Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE role = ''follower'' AND removed_at IS NULL);
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
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Baby Shower' AND baby_profile_id = 'b0000000-b001-b001-b001-00000000b001'), '40000000-4001-4001-4001-000000004001', 'So excited for this! Can''t wait to celebrate with you!', NOW() - INTERVAL '7 days', NULL, NULL),
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
    (gen_random_uuid(), (SELECT id FROM public.photos ORDER BY created_at LIMIT 1), '40000001-4001-4001-4001-000000004001', 'Can''t wait to meet the little one!', NOW() - INTERVAL '13 days', NULL, NULL),
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
    (gen_random_uuid(), (SELECT id FROM public.registry_items WHERE name = 'Stroller' LIMIT 1), '40000001-4001-4001-4001-000000004001', NOW() - INTERVAL '16 days', 'Can''t wait for walks with baby!'),
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
SET session_replication_role = 'origin';
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
