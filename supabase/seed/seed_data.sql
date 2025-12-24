-- ============================================================================
-- Nonna App - Seed Data Script
-- Version: 1.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Test data for development and testing - respects FK dependencies
-- ============================================================================

-- NOTE: This seed data uses mock UUIDs. In a real Supabase environment,
-- auth.users entries would be created via Supabase Auth API.
-- For testing purposes, we'll create mock profiles directly.

-- ============================================================================
-- SECTION 1: Mock User Profiles (Simulating auth.users)
-- ============================================================================

-- Create mock profiles (in production, these would be created via trigger on auth.users insert)
INSERT INTO public.profiles (user_id, display_name, avatar_url, created_at, updated_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Sarah Johnson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('22222222-2222-2222-2222-222222222222', 'Michael Johnson', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Michael', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
    ('33333333-3333-3333-3333-333333333333', 'Grandma Betty', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Betty', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('44444444-4444-4444-4444-444444444444', 'Aunt Lisa', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lisa', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
    ('55555555-5555-5555-5555-555555555555', 'Uncle Tom', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Tom', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('66666666-6666-6666-6666-666666666666', 'Emily Davis', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emily', NOW() - INTERVAL '60 days', NOW() - INTERVAL '60 days'),
    ('77777777-7777-7777-7777-777777777777', 'John Davis', 'https://api.dicebear.com/7.x/avataaars/svg?seed=John', NOW() - INTERVAL '60 days', NOW() - INTERVAL '60 days'),
    ('88888888-8888-8888-8888-888888888888', 'Grandpa Joe', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Joe', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days')
ON CONFLICT (user_id) DO NOTHING;

-- Create user stats for mock users
INSERT INTO public.user_stats (user_id, events_attended_count, items_purchased_count, photos_squished_count, comments_added_count, updated_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 0, 0, 0, 0, NOW()),
    ('22222222-2222-2222-2222-222222222222', 0, 0, 0, 0, NOW()),
    ('33333333-3333-3333-3333-333333333333', 2, 1, 5, 3, NOW()),
    ('44444444-4444-4444-4444-444444444444', 1, 2, 8, 5, NOW()),
    ('55555555-5555-5555-5555-555555555555', 1, 0, 3, 2, NOW()),
    ('66666666-6666-6666-6666-666666666666', 0, 0, 0, 0, NOW()),
    ('77777777-7777-7777-7777-777777777777', 0, 0, 0, 0, NOW()),
    ('88888888-8888-8888-8888-888888888888', 0, 1, 2, 1, NOW())
ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- SECTION 2: Baby Profiles
-- ============================================================================

INSERT INTO public.baby_profiles (id, name, default_last_name_source, profile_photo_url, expected_birth_date, gender, created_at, updated_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Baby Johnson', 'Sarah', 'https://api.dicebear.com/7.x/bottts/svg?seed=baby1', '2026-03-15', 'unknown', NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Emma Davis', NULL, 'https://api.dicebear.com/7.x/bottts/svg?seed=baby2', '2025-08-22', 'female', NOW() - INTERVAL '60 days', NOW() - INTERVAL '10 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 3: Baby Memberships (Access Control)
-- ============================================================================

-- Baby Johnson memberships
INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role, relationship_label, created_at, updated_at, removed_at) VALUES
    ('bm-000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'owner', 'Mother', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'owner', 'Father', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NULL),
    ('bm-000003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'follower', 'Grandma', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NULL),
    ('bm-000004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'follower', 'Aunt', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days', NULL),
    ('bm-000005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 'follower', 'Uncle', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days', NULL)
ON CONFLICT (id) DO NOTHING;

-- Emma Davis memberships
INSERT INTO public.baby_memberships (id, baby_profile_id, user_id, role, relationship_label, created_at, updated_at, removed_at) VALUES
    ('bm-000006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'owner', 'Mother', NOW() - INTERVAL '60 days', NOW() - INTERVAL '60 days', NULL),
    ('bm-000007', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '77777777-7777-7777-7777-777777777777', 'owner', 'Father', NOW() - INTERVAL '60 days', NOW() - INTERVAL '60 days', NULL),
    ('bm-000008', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '88888888-8888-8888-8888-888888888888', 'follower', 'Grandpa', NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days', NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 4: Invitations
-- ============================================================================

INSERT INTO public.invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status, accepted_at, accepted_by_user_id, created_at, updated_at) VALUES
    ('inv-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'grandma@example.com', 'hash_grandma_token', NOW() - INTERVAL '24 days', 'accepted', NOW() - INTERVAL '25 days', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '26 days', NOW() - INTERVAL '25 days'),
    ('inv-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'aunt@example.com', 'hash_aunt_token', NOW() - INTERVAL '19 days', 'accepted', NOW() - INTERVAL '20 days', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '21 days', NOW() - INTERVAL '20 days'),
    ('inv-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'uncle@example.com', 'hash_uncle_token', NOW() - INTERVAL '14 days', 'accepted', NOW() - INTERVAL '15 days', '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '16 days', NOW() - INTERVAL '15 days'),
    ('inv-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'friend@example.com', 'hash_friend_token', NOW() + INTERVAL '5 days', 'pending', NULL, NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
    ('inv-005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'grandpa@example.com', 'hash_grandpa_token', NOW() - INTERVAL '49 days', 'accepted', NOW() - INTERVAL '50 days', '88888888-8888-8888-8888-888888888888', NOW() - INTERVAL '51 days', NOW() - INTERVAL '50 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 5: Tile System Configuration
-- ============================================================================

-- Screens
INSERT INTO public.screens (id, screen_name, description, is_active, created_at) VALUES
    ('screen-home', 'home', 'Home screen with aggregated updates', true, NOW()),
    ('screen-gallery', 'gallery', 'Photo gallery screen', true, NOW()),
    ('screen-calendar', 'calendar', 'Calendar events screen', true, NOW()),
    ('screen-registry', 'registry', 'Baby registry screen', true, NOW()),
    ('screen-fun', 'fun', 'Gamification and voting screen', true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Tile Definitions
INSERT INTO public.tile_definitions (id, tile_type, description, schema_params, is_active, created_at) VALUES
    ('tile-upcoming-events', 'UpcomingEventsTile', 'Shows upcoming calendar events', '{"limit": 5, "daysAhead": 30}'::jsonb, true, NOW()),
    ('tile-recent-photos', 'RecentPhotosTile', 'Grid of recent photos', '{"limit": 6}'::jsonb, true, NOW()),
    ('tile-registry-highlights', 'RegistryHighlightsTile', 'Top priority unpurchased items', '{"limit": 3}'::jsonb, true, NOW()),
    ('tile-activity-list', 'ActivityListTile', 'Recent activity feed', '{"limit": 10}'::jsonb, true, NOW()),
    ('tile-countdown', 'CountdownTile', 'Baby arrival countdown', '{}'::jsonb, true, NOW()),
    ('tile-notifications', 'NotificationsTile', 'Unread notifications', '{"limit": 5}'::jsonb, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Tile Configs (Owner role - Home screen)
INSERT INTO public.tile_configs (id, screen_id, tile_definition_id, role, display_order, is_visible, params, updated_at) VALUES
    ('cfg-home-owner-1', 'screen-home', 'tile-countdown', 'owner', 10, true, '{}'::jsonb, NOW()),
    ('cfg-home-owner-2', 'screen-home', 'tile-notifications', 'owner', 20, true, '{"limit": 5}'::jsonb, NOW()),
    ('cfg-home-owner-3', 'screen-home', 'tile-activity-list', 'owner', 30, true, '{"limit": 10}'::jsonb, NOW()),
    ('cfg-home-owner-4', 'screen-home', 'tile-recent-photos', 'owner', 40, true, '{"limit": 6}'::jsonb, NOW())
ON CONFLICT (id) DO NOTHING;

-- Tile Configs (Follower role - Home screen)
INSERT INTO public.tile_configs (id, screen_id, tile_definition_id, role, display_order, is_visible, params, updated_at) VALUES
    ('cfg-home-follower-1', 'screen-home', 'tile-countdown', 'follower', 10, true, '{}'::jsonb, NOW()),
    ('cfg-home-follower-2', 'screen-home', 'tile-activity-list', 'follower', 20, true, '{"limit": 15}'::jsonb, NOW()),
    ('cfg-home-follower-3', 'screen-home', 'tile-recent-photos', 'follower', 30, true, '{"limit": 9}'::jsonb, NOW()),
    ('cfg-home-follower-4', 'screen-home', 'tile-upcoming-events', 'follower', 40, true, '{"limit": 3}'::jsonb, NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 6: Calendar Events
-- ============================================================================

INSERT INTO public.events (id, baby_profile_id, created_by_user_id, title, starts_at, ends_at, description, location, video_link, cover_photo_url, created_at, updated_at) VALUES
    ('event-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Gender Reveal Party', NOW() + INTERVAL '14 days', NOW() + INTERVAL '14 days' + INTERVAL '3 hours', 'Join us to find out if it''s a boy or girl!', '123 Main St, Springfield', NULL, 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
    ('event-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Baby Shower', NOW() + INTERVAL '45 days', NOW() + INTERVAL '45 days' + INTERVAL '4 hours', 'Celebrating Baby Johnson with family and friends', 'Community Center', 'https://zoom.us/j/123456789', NULL, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
    ('event-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '20-Week Ultrasound', NOW() + INTERVAL '7 days', NOW() + INTERVAL '7 days' + INTERVAL '1 hour', 'Anatomy scan appointment', 'Memorial Hospital', NULL, NULL, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
    ('event-004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'Emma''s Baby Shower', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days' + INTERVAL '3 hours', 'Shower for Emma Davis', '456 Oak Ave', NULL, NULL, NOW() - INTERVAL '45 days', NOW() - INTERVAL '20 days')
ON CONFLICT (id) DO NOTHING;

-- Event RSVPs
INSERT INTO public.event_rsvps (id, event_id, user_id, status, created_at, updated_at) VALUES
    ('rsvp-001', 'event-001', '33333333-3333-3333-3333-333333333333', 'yes', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'),
    ('rsvp-002', 'event-001', '44444444-4444-4444-4444-444444444444', 'yes', NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
    ('rsvp-003', 'event-001', '55555555-5555-5555-5555-555555555555', 'maybe', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
    ('rsvp-004', 'event-002', '33333333-3333-3333-3333-333333333333', 'yes', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
    ('rsvp-005', 'event-004', '88888888-8888-8888-8888-888888888888', 'yes', NOW() - INTERVAL '40 days', NOW() - INTERVAL '40 days')
ON CONFLICT (id) DO NOTHING;

-- Event Comments
INSERT INTO public.event_comments (id, event_id, user_id, body, created_at, deleted_at, deleted_by_user_id) VALUES
    ('ec-001', 'event-001', '33333333-3333-3333-3333-333333333333', 'So excited! Can''t wait to find out!', NOW() - INTERVAL '9 days', NULL, NULL),
    ('ec-002', 'event-001', '44444444-4444-4444-4444-444444444444', 'I''ll bring the cupcakes!', NOW() - INTERVAL '8 days', NULL, NULL),
    ('ec-003', 'event-002', '55555555-5555-5555-5555-555555555555', 'What should I bring?', NOW() - INTERVAL '4 days', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 7: Registry Items
-- ============================================================================

INSERT INTO public.registry_items (id, baby_profile_id, created_by_user_id, name, description, link_url, priority, created_at, updated_at) VALUES
    ('item-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Stroller', 'Lightweight travel stroller', 'https://example.com/stroller', 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('item-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Crib', 'Convertible 3-in-1 crib', 'https://example.com/crib', 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
    ('item-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Diapers Size 1', 'Newborn diapers', 'https://example.com/diapers', 2, NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
    ('item-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Baby Monitor', 'Video baby monitor with night vision', 'https://example.com/monitor', 1, NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
    ('item-005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Nursing Pillow', 'Ergonomic nursing support', NULL, 3, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('item-006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'Car Seat', 'Infant car seat with base', 'https://example.com/carseat', 1, NOW() - INTERVAL '50 days', NOW() - INTERVAL '50 days')
ON CONFLICT (id) DO NOTHING;

-- Registry Purchases
INSERT INTO public.registry_purchases (id, registry_item_id, purchased_by_user_id, purchased_at, note) VALUES
    ('purchase-001', 'item-003', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '10 days', 'Congrats! We''re so happy for you!'),
    ('purchase-002', 'item-005', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '8 days', NULL),
    ('purchase-003', 'item-006', '88888888-8888-8888-8888-888888888888', NOW() - INTERVAL '35 days', 'Welcome Emma!')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 8: Photos
-- ============================================================================

INSERT INTO public.photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption, created_at, updated_at) VALUES
    ('photo-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'babies/baby-johnson/photo1.jpg', '12 weeks ultrasound!', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
    ('photo-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'babies/baby-johnson/photo2.jpg', 'Baby bump at 16 weeks', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('photo-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'babies/baby-johnson/photo3.jpg', 'Setting up the nursery!', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
    ('photo-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'babies/baby-johnson/photo4.jpg', '20 weeks and feeling great', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
    ('photo-005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'babies/emma-davis/photo1.jpg', 'Emma''s first photo', NOW() - INTERVAL '45 days', NOW() - INTERVAL '45 days'),
    ('photo-006', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'babies/emma-davis/photo2.jpg', 'Emma at 2 weeks', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- Photo Squishes
INSERT INTO public.photo_squishes (id, photo_id, user_id, created_at) VALUES
    ('squish-001', 'photo-001', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '19 days'),
    ('squish-002', 'photo-001', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '19 days'),
    ('squish-003', 'photo-001', '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '18 days'),
    ('squish-004', 'photo-002', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '14 days'),
    ('squish-005', 'photo-002', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '14 days'),
    ('squish-006', 'photo-003', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '9 days'),
    ('squish-007', 'photo-003', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '9 days'),
    ('squish-008', 'photo-003', '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '9 days'),
    ('squish-009', 'photo-004', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '4 days'),
    ('squish-010', 'photo-005', '88888888-8888-8888-8888-888888888888', NOW() - INTERVAL '44 days'),
    ('squish-011', 'photo-006', '88888888-8888-8888-8888-888888888888', NOW() - INTERVAL '29 days')
ON CONFLICT (id) DO NOTHING;

-- Photo Comments
INSERT INTO public.photo_comments (id, photo_id, user_id, body, created_at, deleted_at, deleted_by_user_id) VALUES
    ('pc-001', 'photo-001', '33333333-3333-3333-3333-333333333333', 'So beautiful!', NOW() - INTERVAL '19 days', NULL, NULL),
    ('pc-002', 'photo-002', '44444444-4444-4444-4444-444444444444', 'You look amazing!', NOW() - INTERVAL '14 days', NULL, NULL),
    ('pc-003', 'photo-003', '55555555-5555-5555-5555-555555555555', 'Love the nursery colors!', NOW() - INTERVAL '9 days', NULL, NULL),
    ('pc-004', 'photo-004', '33333333-3333-3333-3333-333333333333', 'Glowing mama!', NOW() - INTERVAL '4 days', NULL, NULL),
    ('pc-005', 'photo-005', '88888888-8888-8888-8888-888888888888', 'Welcome to the world Emma!', NOW() - INTERVAL '44 days', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- Photo Tags
INSERT INTO public.photo_tags (id, photo_id, tag, created_at) VALUES
    ('tag-001', 'photo-001', 'ultrasound', NOW() - INTERVAL '20 days'),
    ('tag-002', 'photo-001', 'milestone', NOW() - INTERVAL '20 days'),
    ('tag-003', 'photo-002', 'bump', NOW() - INTERVAL '15 days'),
    ('tag-004', 'photo-003', 'nursery', NOW() - INTERVAL '10 days'),
    ('tag-005', 'photo-003', 'preparation', NOW() - INTERVAL '10 days'),
    ('tag-006', 'photo-005', 'newborn', NOW() - INTERVAL '45 days'),
    ('tag-007', 'photo-005', 'firstphoto', NOW() - INTERVAL '45 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 9: Gamification - Votes
-- ============================================================================

INSERT INTO public.votes (id, baby_profile_id, user_id, vote_type, value_text, value_date, is_anonymous, created_at, updated_at) VALUES
    ('vote-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'gender', 'girl', NULL, true, NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
    ('vote-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'gender', 'boy', NULL, true, NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days'),
    ('vote-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 'gender', 'girl', NULL, true, NOW() - INTERVAL '13 days', NOW() - INTERVAL '13 days'),
    ('vote-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'birthdate', NULL, '2026-03-10', true, NOW() - INTERVAL '12 days', NOW() - INTERVAL '12 days'),
    ('vote-005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'birthdate', NULL, '2026-03-18', true, NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SECTION 10: Gamification - Name Suggestions
-- ============================================================================

INSERT INTO public.name_suggestions (id, baby_profile_id, user_id, gender, suggested_name, created_at, updated_at) VALUES
    ('ns-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'female', 'Sophia', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
    ('ns-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'male', 'Liam', NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
    ('ns-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'female', 'Olivia', NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days'),
    ('ns-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'male', 'Noah', NOW() - INTERVAL '16 days', NOW() - INTERVAL '16 days'),
    ('ns-005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 'female', 'Emma', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days')
ON CONFLICT (id) DO NOTHING;

-- Name Suggestion Likes
INSERT INTO public.name_suggestion_likes (id, name_suggestion_id, user_id, created_at) VALUES
    ('nsl-001', 'ns-001', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '17 days'),
    ('nsl-002', 'ns-001', '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '16 days'),
    ('nsl-003', 'ns-002', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '17 days'),
    ('nsl-004', 'ns-003', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '15 days'),
    ('nsl-005', 'ns-005', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '13 days'),
    ('nsl-006', 'ns-005', '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '13 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA SCRIPT
-- ============================================================================

-- Summary statistics
DO $$
BEGIN
    RAISE NOTICE 'Seed data loaded successfully!';
    RAISE NOTICE 'Profiles: %', (SELECT COUNT(*) FROM public.profiles);
    RAISE NOTICE 'Baby Profiles: %', (SELECT COUNT(*) FROM public.baby_profiles);
    RAISE NOTICE 'Memberships: %', (SELECT COUNT(*) FROM public.baby_memberships WHERE removed_at IS NULL);
    RAISE NOTICE 'Events: %', (SELECT COUNT(*) FROM public.events);
    RAISE NOTICE 'Photos: %', (SELECT COUNT(*) FROM public.photos);
    RAISE NOTICE 'Registry Items: %', (SELECT COUNT(*) FROM public.registry_items);
END $$;
