DROP SCHEMA public CASCADE;
CREATE SCHEMA public AUTHORIZATION CURRENT_USER;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
GRANT ALL ON SCHEMA public TO public;

-- ============================================================================
-- Nonna App - Physical Data Model DDL Migration Script
-- Version: 1.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Complete schema creation with Supabase optimizations
-- ============================================================================

-- Enable required PostgreSQL extensions
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";       -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- Performance monitoring
CREATE EXTENSION IF NOT EXISTS "pg_trgm";         -- Text search optimization
CREATE EXTENSION IF NOT EXISTS "btree_gin";       -- Multi-column indexing

-- ============================================================================
-- SECTION 1: Core User Tables
-- ============================================================================

-- User Profiles (1:1 with auth.users)
-- Links application profile data to Supabase Auth
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name text,
    avatar_url text,
    biometric_enabled boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.profiles IS 'User profile information linked to Supabase Auth';
COMMENT ON COLUMN public.profiles.user_id IS 'Foreign key to auth.users with CASCADE delete';

-- User Statistics (Gamification counters)
CREATE TABLE IF NOT EXISTS public.user_stats (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    events_attended_count int NOT NULL DEFAULT 0,
    items_purchased_count int NOT NULL DEFAULT 0,
    photos_squished_count int NOT NULL DEFAULT 0,
    comments_added_count int NOT NULL DEFAULT 0,
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.user_stats IS 'Pre-computed user engagement statistics for gamification';

-- ============================================================================
-- SECTION 2: Baby Profile & Access Control
-- ============================================================================

-- Baby Profiles (Core entity)
CREATE TABLE IF NOT EXISTS public.baby_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    default_last_name_source text,
    profile_photo_url text,
    expected_birth_date date,
    gender text CHECK (gender IN ('male', 'female', 'unknown')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.baby_profiles IS 'Central baby profile hub - tenant boundary for all content';
COMMENT ON COLUMN public.baby_profiles.gender IS 'Enum: male, female, unknown';

-- Baby Memberships (Access Control & Roles)
CREATE TABLE IF NOT EXISTS public.baby_memberships (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('owner', 'follower')),
    relationship_label text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    removed_at timestamptz
);

COMMENT ON TABLE public.baby_memberships IS 'Maps users to baby profiles with roles (owner/follower) for RLS';
COMMENT ON COLUMN public.baby_memberships.role IS 'Enum: owner (full control), follower (read + interact)';
COMMENT ON COLUMN public.baby_memberships.removed_at IS 'Soft delete timestamp for audit trail';

-- Invitations
CREATE TABLE IF NOT EXISTS public.invitations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    invited_by_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    invitee_email text NOT NULL,
    token_hash text NOT NULL UNIQUE,
    expires_at timestamptz NOT NULL,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
    accepted_at timestamptz,
    accepted_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.invitations IS 'Email invitation lifecycle with 7-day expiration';
COMMENT ON COLUMN public.invitations.token_hash IS 'Secure hashed token for invitation verification';
COMMENT ON COLUMN public.invitations.status IS 'Enum: pending, accepted, revoked, expired';

-- ============================================================================
-- SECTION 3: Dynamic Tile System Configuration
-- ============================================================================

-- Screens (Navigation destinations)
CREATE TABLE IF NOT EXISTS public.screens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    screen_name text NOT NULL UNIQUE,
    description text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.screens IS 'App screens for tile configuration (Home, Calendar, etc.)';

-- Tile Definitions (Tile type catalog)
CREATE TABLE IF NOT EXISTS public.tile_definitions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tile_type text NOT NULL UNIQUE,
    description text,
    schema_params jsonb,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.tile_definitions IS 'Catalog of tile types for TileFactory';
COMMENT ON COLUMN public.tile_definitions.schema_params IS 'JSON schema for tile parameters validation';

-- Tile Configurations (Role-driven layout)
CREATE TABLE IF NOT EXISTS public.tile_configs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    screen_id uuid NOT NULL REFERENCES public.screens(id) ON DELETE CASCADE,
    tile_definition_id uuid NOT NULL REFERENCES public.tile_definitions(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('owner', 'follower')),
    display_order int NOT NULL,
    is_visible boolean NOT NULL DEFAULT true,
    params jsonb DEFAULT '{}'::jsonb,
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.tile_configs IS 'Role-driven tile placement and configuration per screen';
COMMENT ON COLUMN public.tile_configs.params IS 'Tile-specific parameters (limit, days, etc.)';

-- ============================================================================
-- SECTION 4: Cache Invalidation
-- ============================================================================

-- Owner Update Markers (Follower cache invalidation)
CREATE TABLE IF NOT EXISTS public.owner_update_markers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL UNIQUE REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    tiles_last_updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    reason text
);

COMMENT ON TABLE public.owner_update_markers IS 'Cache invalidation marker - one per baby profile';
COMMENT ON COLUMN public.owner_update_markers.tiles_last_updated_at IS 'Timestamp for follower cache checks';

-- ============================================================================
-- SECTION 5: Calendar Features
-- ============================================================================

-- Events
CREATE TABLE IF NOT EXISTS public.events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    created_by_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title text NOT NULL,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz,
    description text,
    location text,
    video_link text,
    cover_photo_url text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.events IS 'Calendar events for baby profiles';

-- Event RSVPs
CREATE TABLE IF NOT EXISTS public.event_rsvps (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status text NOT NULL CHECK (status IN ('yes', 'no', 'maybe')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(event_id, user_id)
);

COMMENT ON TABLE public.event_rsvps IS 'RSVP responses - one per user per event';

-- Event Comments
CREATE TABLE IF NOT EXISTS public.event_comments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,
    deleted_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

COMMENT ON TABLE public.event_comments IS 'Comments on events with owner moderation';

-- ============================================================================
-- SECTION 6: Registry Features
-- ============================================================================

-- Registry Items
CREATE TABLE IF NOT EXISTS public.registry_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    created_by_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    description text,
    link_url text,
    priority int DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.registry_items IS 'Baby registry items created by owners';

-- Registry Purchases
CREATE TABLE IF NOT EXISTS public.registry_purchases (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    registry_item_id uuid NOT NULL REFERENCES public.registry_items(id) ON DELETE CASCADE,
    purchased_by_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    purchased_at timestamptz NOT NULL DEFAULT now(),
    note text
);

COMMENT ON TABLE public.registry_purchases IS 'Purchase records - keeps registry_items immutable';

-- ============================================================================
-- SECTION 7: Photo Gallery Features
-- ============================================================================

-- Photos
CREATE TABLE IF NOT EXISTS public.photos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    uploaded_by_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    storage_path text NOT NULL,
    caption text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.photos IS 'Photo metadata - storage_path links to Supabase Storage';
COMMENT ON COLUMN public.photos.storage_path IS 'Supabase Storage bucket path';

-- Photo Squishes (Likes)
CREATE TABLE IF NOT EXISTS public.photo_squishes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id uuid NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(photo_id, user_id)
);

COMMENT ON TABLE public.photo_squishes IS 'Photo likes - one squish per user per photo';

-- Photo Comments
CREATE TABLE IF NOT EXISTS public.photo_comments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id uuid NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,
    deleted_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

COMMENT ON TABLE public.photo_comments IS 'Comments on photos with owner moderation';

-- Photo Tags (Search)
CREATE TABLE IF NOT EXISTS public.photo_tags (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id uuid NOT NULL REFERENCES public.photos(id) ON DELETE CASCADE,
    tag text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.photo_tags IS 'Searchable tags for photos';

-- ============================================================================
-- SECTION 8: Gamification Features
-- ============================================================================

-- Votes (Gender/Birthdate predictions)
CREATE TABLE IF NOT EXISTS public.votes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vote_type text NOT NULL CHECK (vote_type IN ('gender', 'birthdate')),
    value_text text,
    value_date date,
    is_anonymous boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.votes IS 'Anonymous voting for gender/birthdate predictions';

-- Name Suggestions
CREATE TABLE IF NOT EXISTS public.name_suggestions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    gender text NOT NULL CHECK (gender IN ('male', 'female', 'unknown')),
    suggested_name text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.name_suggestions IS 'Name suggestions - one per user per gender per baby';

-- Name Suggestion Likes
CREATE TABLE IF NOT EXISTS public.name_suggestion_likes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name_suggestion_id uuid NOT NULL REFERENCES public.name_suggestions(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(name_suggestion_id, user_id)
);

COMMENT ON TABLE public.name_suggestion_likes IS 'Likes on name suggestions';

-- ============================================================================
-- SECTION 9: Notifications & Activity
-- ============================================================================

-- Notifications (In-app inbox)
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    baby_profile_id uuid REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    read_at timestamptz
);

COMMENT ON TABLE public.notifications IS 'In-app notification inbox for users';
COMMENT ON COLUMN public.notifications.payload IS 'Structured notification data for deep-linking';

-- Activity Events (Recent activity stream)
CREATE TABLE IF NOT EXISTS public.activity_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baby_profile_id uuid NOT NULL REFERENCES public.baby_profiles(id) ON DELETE CASCADE,
    actor_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.activity_events IS 'Append-only activity stream for Recent Activity tiles';

-- ============================================================================
-- SECTION 10: Performance Indexes (PostgREST & Frontend Optimization)
-- ============================================================================

-- Membership checks (critical for RLS performance)
CREATE INDEX IF NOT EXISTS idx_baby_memberships_user_active
    ON public.baby_memberships (user_id)
    WHERE removed_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_baby_memberships_baby_active
    ON public.baby_memberships (baby_profile_id)
    WHERE removed_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_baby_memberships_baby_user_role
    ON public.baby_memberships (baby_profile_id, user_id, role)
    WHERE removed_at IS NULL;

-- Screen tiles: fetch by screen + role in stable order
CREATE INDEX IF NOT EXISTS idx_tile_configs_screen_role_order
    ON public.tile_configs (screen_id, role, display_order)
    WHERE is_visible = true;

-- Baby-scoped feeds (critical for tile queries)
CREATE INDEX IF NOT EXISTS idx_events_baby_starts
    ON public.events (baby_profile_id, starts_at DESC);

CREATE INDEX IF NOT EXISTS idx_photos_baby_created
    ON public.photos (baby_profile_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_registry_items_baby_created
    ON public.registry_items (baby_profile_id, created_at DESC);

-- Conversations (comments sorted by time)
CREATE INDEX IF NOT EXISTS idx_event_comments_event_created
    ON public.event_comments (event_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_photo_comments_photo_created
    ON public.photo_comments (photo_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Inbox queries (notifications)
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_created
    ON public.notifications (recipient_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_unread
    ON public.notifications (recipient_user_id, created_at DESC)
    WHERE read_at IS NULL;

-- Activity streams
CREATE INDEX IF NOT EXISTS idx_activity_events_baby_created
    ON public.activity_events (baby_profile_id, created_at DESC);

-- Photo tags (text search with trigram)
CREATE INDEX IF NOT EXISTS idx_photo_tags_tag_trgm
    ON public.photo_tags USING gin (tag gin_trgm_ops);

-- Invitation lookups
CREATE INDEX IF NOT EXISTS idx_invitations_token_hash
    ON public.invitations (token_hash);

CREATE INDEX IF NOT EXISTS idx_invitations_baby_status
    ON public.invitations (baby_profile_id, status);

-- ============================================================================
-- SECTION 11: Unique Constraints (Data Integrity)
-- ============================================================================

-- One active membership per user per baby
CREATE UNIQUE INDEX IF NOT EXISTS uq_baby_memberships_baby_user_active
    ON public.baby_memberships (baby_profile_id, user_id)
    WHERE removed_at IS NULL;

-- One name suggestion per user per gender per baby
CREATE UNIQUE INDEX IF NOT EXISTS uq_name_suggestions_baby_user_gender
    ON public.name_suggestions (baby_profile_id, user_id, gender);

-- Stable identifiers
CREATE UNIQUE INDEX IF NOT EXISTS uq_screens_screen_name
    ON public.screens (screen_name);

CREATE UNIQUE INDEX IF NOT EXISTS uq_tile_definitions_tile_type
    ON public.tile_definitions (tile_type);

-- ============================================================================
-- END OF DDL MIGRATION SCRIPT
-- ============================================================================


-- ============================================================================
-- Nonna App - Comprehensive Seed Data Script
-- Version: 2.1.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Extended test data - 10 babies, 20 owners, 130 followers
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Create authentication users (profiles) for testing
-- ---------------------------------------------------------------------------
-- Generated auth.users and auth.identities INSERTs
SET session_replication_role = 'origin';

-- Truncate all tables before seeding to ensure clean state
TRUNCATE TABLE auth.identities CASCADE;
TRUNCATE TABLE auth.users CASCADE;
TRUNCATE TABLE public.activity_events CASCADE;
TRUNCATE TABLE public.baby_memberships CASCADE;
TRUNCATE TABLE public.baby_profiles CASCADE;
TRUNCATE TABLE public.event_comments CASCADE;
TRUNCATE TABLE public.event_rsvps CASCADE;
TRUNCATE TABLE public.events CASCADE;
TRUNCATE TABLE public.invitations CASCADE;
TRUNCATE TABLE public.name_suggestion_likes CASCADE;
TRUNCATE TABLE public.name_suggestions CASCADE;
TRUNCATE TABLE public.notifications CASCADE;
TRUNCATE TABLE public.owner_update_markers CASCADE;
TRUNCATE TABLE public.photo_comments CASCADE;
TRUNCATE TABLE public.photo_squishes CASCADE;
TRUNCATE TABLE public.photo_tags CASCADE;
TRUNCATE TABLE public.photos CASCADE;
TRUNCATE TABLE public.profiles CASCADE;
TRUNCATE TABLE public.registry_items CASCADE;
TRUNCATE TABLE public.registry_purchases CASCADE;
TRUNCATE TABLE public.screens CASCADE;
TRUNCATE TABLE public.tile_configs CASCADE;
TRUNCATE TABLE public.tile_definitions CASCADE;
TRUNCATE TABLE public.user_stats CASCADE;
TRUNCATE TABLE public.votes CASCADE;

BEGIN;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000000-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000000@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000000-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000000-1001-1001-1001-000000001001','seed+10000000@example.local')::jsonb, 'email', '10000000-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000001-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000001-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000001-1001-1001-1001-000000001001','seed+10000001@example.local')::jsonb, 'email', '10000001-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000002-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000002-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000002-1001-1001-1001-000000001001','seed+10000002@example.local')::jsonb, 'email', '10000002-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000003-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000003-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000003-1001-1001-1001-000000001001','seed+10000003@example.local')::jsonb, 'email', '10000003-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000004-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000004-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000004-1001-1001-1001-000000001001','seed+10000004@example.local')::jsonb, 'email', '10000004-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000005-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000005-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000005-1001-1001-1001-000000001001','seed+10000005@example.local')::jsonb, 'email', '10000005-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000006-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000006-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000006-1001-1001-1001-000000001001','seed+10000006@example.local')::jsonb, 'email', '10000006-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000007-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000007-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000007-1001-1001-1001-000000001001','seed+10000007@example.local')::jsonb, 'email', '10000007-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000008-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000008-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000008-1001-1001-1001-000000001001','seed+10000008@example.local')::jsonb, 'email', '10000008-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000009-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000009-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000009-1001-1001-1001-000000001001','seed+10000009@example.local')::jsonb, 'email', '10000009-1001-1001-1001-000000001001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000000-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000000@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000000-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000000-2001-2001-2001-000000002001','seed+20000000@example.local')::jsonb, 'email', '20000000-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000001-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000001-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000001-2001-2001-2001-000000002001','seed+20000001@example.local')::jsonb, 'email', '20000001-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000002-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000002-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000002-2001-2001-2001-000000002001','seed+20000002@example.local')::jsonb, 'email', '20000002-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000003-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000003-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000003-2001-2001-2001-000000002001','seed+20000003@example.local')::jsonb, 'email', '20000003-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000004-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000004-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000004-2001-2001-2001-000000002001','seed+20000004@example.local')::jsonb, 'email', '20000004-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000005-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000005-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000005-2001-2001-2001-000000002001','seed+20000005@example.local')::jsonb, 'email', '20000005-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000006-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000006-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000006-2001-2001-2001-000000002001','seed+20000006@example.local')::jsonb, 'email', '20000006-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000007-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000007-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000007-2001-2001-2001-000000002001','seed+20000007@example.local')::jsonb, 'email', '20000007-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000008-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000008-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000008-2001-2001-2001-000000002001','seed+20000008@example.local')::jsonb, 'email', '20000008-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000009-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000009-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000009-2001-2001-2001-000000002001','seed+20000009@example.local')::jsonb, 'email', '20000009-2001-2001-2001-000000002001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000000-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000000@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000000-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000000-4001-4001-4001-000000004001','seed+40000000@example.local')::jsonb, 'email', '40000000-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000001-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000001-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000001-4001-4001-4001-000000004001','seed+40000001@example.local')::jsonb, 'email', '40000001-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000002-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000002-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000002-4001-4001-4001-000000004001','seed+40000002@example.local')::jsonb, 'email', '40000002-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000003-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000003-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000003-4001-4001-4001-000000004001','seed+40000003@example.local')::jsonb, 'email', '40000003-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000004-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000004-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000004-4001-4001-4001-000000004001','seed+40000004@example.local')::jsonb, 'email', '40000004-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000005-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000005-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000005-4001-4001-4001-000000004001','seed+40000005@example.local')::jsonb, 'email', '40000005-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000006-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000006-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000006-4001-4001-4001-000000004001','seed+40000006@example.local')::jsonb, 'email', '40000006-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000007-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000007-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000007-4001-4001-4001-000000004001','seed+40000007@example.local')::jsonb, 'email', '40000007-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000008-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000008-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000008-4001-4001-4001-000000004001','seed+40000008@example.local')::jsonb, 'email', '40000008-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000009-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000009-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000009-4001-4001-4001-000000004001','seed+40000009@example.local')::jsonb, 'email', '40000009-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000a-4001-4001-4001-000000004001','seed+4000000a@example.local')::jsonb, 'email', '4000000a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000b-4001-4001-4001-000000004001','seed+4000000b@example.local')::jsonb, 'email', '4000000b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000c-4001-4001-4001-000000004001','seed+4000000c@example.local')::jsonb, 'email', '4000000c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000d-4001-4001-4001-000000004001','seed+4000000d@example.local')::jsonb, 'email', '4000000d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000e-4001-4001-4001-000000004001','seed+4000000e@example.local')::jsonb, 'email', '4000000e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000f-4001-4001-4001-000000004001','seed+4000000f@example.local')::jsonb, 'email', '4000000f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000010-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000010@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000010-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000010-4001-4001-4001-000000004001','seed+40000010@example.local')::jsonb, 'email', '40000010-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000011-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000011@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000011-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000011-4001-4001-4001-000000004001','seed+40000011@example.local')::jsonb, 'email', '40000011-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000012-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000012@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000012-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000012-4001-4001-4001-000000004001','seed+40000012@example.local')::jsonb, 'email', '40000012-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000013-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000013@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000013-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000013-4001-4001-4001-000000004001','seed+40000013@example.local')::jsonb, 'email', '40000013-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000014-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000014@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000014-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000014-4001-4001-4001-000000004001','seed+40000014@example.local')::jsonb, 'email', '40000014-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000015-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000015@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000015-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000015-4001-4001-4001-000000004001','seed+40000015@example.local')::jsonb, 'email', '40000015-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000016-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000016@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000016-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000016-4001-4001-4001-000000004001','seed+40000016@example.local')::jsonb, 'email', '40000016-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000017-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000017@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000017-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000017-4001-4001-4001-000000004001','seed+40000017@example.local')::jsonb, 'email', '40000017-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000018-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000018@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000018-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000018-4001-4001-4001-000000004001','seed+40000018@example.local')::jsonb, 'email', '40000018-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000019-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000019@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000019-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000019-4001-4001-4001-000000004001','seed+40000019@example.local')::jsonb, 'email', '40000019-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001a-4001-4001-4001-000000004001','seed+4000001a@example.local')::jsonb, 'email', '4000001a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001b-4001-4001-4001-000000004001','seed+4000001b@example.local')::jsonb, 'email', '4000001b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001c-4001-4001-4001-000000004001','seed+4000001c@example.local')::jsonb, 'email', '4000001c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001d-4001-4001-4001-000000004001','seed+4000001d@example.local')::jsonb, 'email', '4000001d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001e-4001-4001-4001-000000004001','seed+4000001e@example.local')::jsonb, 'email', '4000001e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001f-4001-4001-4001-000000004001','seed+4000001f@example.local')::jsonb, 'email', '4000001f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000020-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000020@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000020-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000020-4001-4001-4001-000000004001','seed+40000020@example.local')::jsonb, 'email', '40000020-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000021-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000021@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000021-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000021-4001-4001-4001-000000004001','seed+40000021@example.local')::jsonb, 'email', '40000021-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000022-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000022@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000022-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000022-4001-4001-4001-000000004001','seed+40000022@example.local')::jsonb, 'email', '40000022-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000023-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000023@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000023-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000023-4001-4001-4001-000000004001','seed+40000023@example.local')::jsonb, 'email', '40000023-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000024-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000024@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000024-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000024-4001-4001-4001-000000004001','seed+40000024@example.local')::jsonb, 'email', '40000024-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000025-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000025@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000025-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000025-4001-4001-4001-000000004001','seed+40000025@example.local')::jsonb, 'email', '40000025-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000026-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000026@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000026-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000026-4001-4001-4001-000000004001','seed+40000026@example.local')::jsonb, 'email', '40000026-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000027-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000027@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000027-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000027-4001-4001-4001-000000004001','seed+40000027@example.local')::jsonb, 'email', '40000027-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000028-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000028@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000028-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000028-4001-4001-4001-000000004001','seed+40000028@example.local')::jsonb, 'email', '40000028-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000029-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000029@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000029-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000029-4001-4001-4001-000000004001','seed+40000029@example.local')::jsonb, 'email', '40000029-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002a-4001-4001-4001-000000004001','seed+4000002a@example.local')::jsonb, 'email', '4000002a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002b-4001-4001-4001-000000004001','seed+4000002b@example.local')::jsonb, 'email', '4000002b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002c-4001-4001-4001-000000004001','seed+4000002c@example.local')::jsonb, 'email', '4000002c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002d-4001-4001-4001-000000004001','seed+4000002d@example.local')::jsonb, 'email', '4000002d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002e-4001-4001-4001-000000004001','seed+4000002e@example.local')::jsonb, 'email', '4000002e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002f-4001-4001-4001-000000004001','seed+4000002f@example.local')::jsonb, 'email', '4000002f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000030-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000030@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000030-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000030-4001-4001-4001-000000004001','seed+40000030@example.local')::jsonb, 'email', '40000030-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000031-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000031@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000031-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000031-4001-4001-4001-000000004001','seed+40000031@example.local')::jsonb, 'email', '40000031-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000032-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000032@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000032-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000032-4001-4001-4001-000000004001','seed+40000032@example.local')::jsonb, 'email', '40000032-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000033-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000033@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000033-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000033-4001-4001-4001-000000004001','seed+40000033@example.local')::jsonb, 'email', '40000033-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000034-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000034@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000034-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000034-4001-4001-4001-000000004001','seed+40000034@example.local')::jsonb, 'email', '40000034-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000035-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000035@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000035-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000035-4001-4001-4001-000000004001','seed+40000035@example.local')::jsonb, 'email', '40000035-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000036-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000036@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000036-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000036-4001-4001-4001-000000004001','seed+40000036@example.local')::jsonb, 'email', '40000036-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000037-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000037@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000037-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000037-4001-4001-4001-000000004001','seed+40000037@example.local')::jsonb, 'email', '40000037-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000038-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000038@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000038-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000038-4001-4001-4001-000000004001','seed+40000038@example.local')::jsonb, 'email', '40000038-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000039-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000039@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000039-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000039-4001-4001-4001-000000004001','seed+40000039@example.local')::jsonb, 'email', '40000039-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003a-4001-4001-4001-000000004001','seed+4000003a@example.local')::jsonb, 'email', '4000003a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003b-4001-4001-4001-000000004001','seed+4000003b@example.local')::jsonb, 'email', '4000003b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003c-4001-4001-4001-000000004001','seed+4000003c@example.local')::jsonb, 'email', '4000003c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003d-4001-4001-4001-000000004001','seed+4000003d@example.local')::jsonb, 'email', '4000003d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003e-4001-4001-4001-000000004001','seed+4000003e@example.local')::jsonb, 'email', '4000003e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003f-4001-4001-4001-000000004001','seed+4000003f@example.local')::jsonb, 'email', '4000003f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000040-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000040@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000040-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000040-4001-4001-4001-000000004001','seed+40000040@example.local')::jsonb, 'email', '40000040-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000041-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000041@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000041-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000041-4001-4001-4001-000000004001','seed+40000041@example.local')::jsonb, 'email', '40000041-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000042-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000042@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000042-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000042-4001-4001-4001-000000004001','seed+40000042@example.local')::jsonb, 'email', '40000042-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000043-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000043@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000043-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000043-4001-4001-4001-000000004001','seed+40000043@example.local')::jsonb, 'email', '40000043-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000044-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000044@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000044-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000044-4001-4001-4001-000000004001','seed+40000044@example.local')::jsonb, 'email', '40000044-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000045-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000045@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000045-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000045-4001-4001-4001-000000004001','seed+40000045@example.local')::jsonb, 'email', '40000045-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000046-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000046@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000046-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000046-4001-4001-4001-000000004001','seed+40000046@example.local')::jsonb, 'email', '40000046-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000047-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000047@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000047-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000047-4001-4001-4001-000000004001','seed+40000047@example.local')::jsonb, 'email', '40000047-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000048-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000048@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000048-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000048-4001-4001-4001-000000004001','seed+40000048@example.local')::jsonb, 'email', '40000048-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000049-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000049@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000049-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000049-4001-4001-4001-000000004001','seed+40000049@example.local')::jsonb, 'email', '40000049-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004a-4001-4001-4001-000000004001','seed+4000004a@example.local')::jsonb, 'email', '4000004a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004b-4001-4001-4001-000000004001','seed+4000004b@example.local')::jsonb, 'email', '4000004b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004c-4001-4001-4001-000000004001','seed+4000004c@example.local')::jsonb, 'email', '4000004c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004d-4001-4001-4001-000000004001','seed+4000004d@example.local')::jsonb, 'email', '4000004d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004e-4001-4001-4001-000000004001','seed+4000004e@example.local')::jsonb, 'email', '4000004e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004f-4001-4001-4001-000000004001','seed+4000004f@example.local')::jsonb, 'email', '4000004f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000050-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000050@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000050-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000050-4001-4001-4001-000000004001','seed+40000050@example.local')::jsonb, 'email', '40000050-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000051-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000051@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000051-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000051-4001-4001-4001-000000004001','seed+40000051@example.local')::jsonb, 'email', '40000051-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000052-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000052@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000052-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000052-4001-4001-4001-000000004001','seed+40000052@example.local')::jsonb, 'email', '40000052-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000053-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000053@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000053-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000053-4001-4001-4001-000000004001','seed+40000053@example.local')::jsonb, 'email', '40000053-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000054-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000054@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000054-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000054-4001-4001-4001-000000004001','seed+40000054@example.local')::jsonb, 'email', '40000054-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000055-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000055@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000055-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000055-4001-4001-4001-000000004001','seed+40000055@example.local')::jsonb, 'email', '40000055-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000056-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000056@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000056-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000056-4001-4001-4001-000000004001','seed+40000056@example.local')::jsonb, 'email', '40000056-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000057-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000057@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000057-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000057-4001-4001-4001-000000004001','seed+40000057@example.local')::jsonb, 'email', '40000057-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000058-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000058@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000058-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000058-4001-4001-4001-000000004001','seed+40000058@example.local')::jsonb, 'email', '40000058-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000059-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000059@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000059-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000059-4001-4001-4001-000000004001','seed+40000059@example.local')::jsonb, 'email', '40000059-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005a-4001-4001-4001-000000004001','seed+4000005a@example.local')::jsonb, 'email', '4000005a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005b-4001-4001-4001-000000004001','seed+4000005b@example.local')::jsonb, 'email', '4000005b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005c-4001-4001-4001-000000004001','seed+4000005c@example.local')::jsonb, 'email', '4000005c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005d-4001-4001-4001-000000004001','seed+4000005d@example.local')::jsonb, 'email', '4000005d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005e-4001-4001-4001-000000004001','seed+4000005e@example.local')::jsonb, 'email', '4000005e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005f-4001-4001-4001-000000004001','seed+4000005f@example.local')::jsonb, 'email', '4000005f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000060-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000060@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000060-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000060-4001-4001-4001-000000004001','seed+40000060@example.local')::jsonb, 'email', '40000060-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000061-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000061@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000061-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000061-4001-4001-4001-000000004001','seed+40000061@example.local')::jsonb, 'email', '40000061-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000062-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000062@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000062-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000062-4001-4001-4001-000000004001','seed+40000062@example.local')::jsonb, 'email', '40000062-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000063-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000063@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000063-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000063-4001-4001-4001-000000004001','seed+40000063@example.local')::jsonb, 'email', '40000063-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000064-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000064@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000064-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000064-4001-4001-4001-000000004001','seed+40000064@example.local')::jsonb, 'email', '40000064-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000065-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000065@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000065-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000065-4001-4001-4001-000000004001','seed+40000065@example.local')::jsonb, 'email', '40000065-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000066-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000066@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000066-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000066-4001-4001-4001-000000004001','seed+40000066@example.local')::jsonb, 'email', '40000066-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000067-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000067@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000067-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000067-4001-4001-4001-000000004001','seed+40000067@example.local')::jsonb, 'email', '40000067-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000068-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000068@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000068-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000068-4001-4001-4001-000000004001','seed+40000068@example.local')::jsonb, 'email', '40000068-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000069-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000069@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000069-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000069-4001-4001-4001-000000004001','seed+40000069@example.local')::jsonb, 'email', '40000069-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006a-4001-4001-4001-000000004001','seed+4000006a@example.local')::jsonb, 'email', '4000006a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006b-4001-4001-4001-000000004001','seed+4000006b@example.local')::jsonb, 'email', '4000006b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006c-4001-4001-4001-000000004001','seed+4000006c@example.local')::jsonb, 'email', '4000006c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006d-4001-4001-4001-000000004001','seed+4000006d@example.local')::jsonb, 'email', '4000006d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006e-4001-4001-4001-000000004001','seed+4000006e@example.local')::jsonb, 'email', '4000006e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006f-4001-4001-4001-000000004001','seed+4000006f@example.local')::jsonb, 'email', '4000006f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000070-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000070@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000070-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000070-4001-4001-4001-000000004001','seed+40000070@example.local')::jsonb, 'email', '40000070-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000071-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000071@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000071-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000071-4001-4001-4001-000000004001','seed+40000071@example.local')::jsonb, 'email', '40000071-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000072-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000072@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000072-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000072-4001-4001-4001-000000004001','seed+40000072@example.local')::jsonb, 'email', '40000072-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000073-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000073@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000073-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000073-4001-4001-4001-000000004001','seed+40000073@example.local')::jsonb, 'email', '40000073-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000074-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000074@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000074-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000074-4001-4001-4001-000000004001','seed+40000074@example.local')::jsonb, 'email', '40000074-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000075-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000075@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000075-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000075-4001-4001-4001-000000004001','seed+40000075@example.local')::jsonb, 'email', '40000075-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000076-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000076@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000076-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000076-4001-4001-4001-000000004001','seed+40000076@example.local')::jsonb, 'email', '40000076-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000077-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000077@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000077-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000077-4001-4001-4001-000000004001','seed+40000077@example.local')::jsonb, 'email', '40000077-4001-4001-4001-000000004001', NOW(), NOW(), NOW());
COMMIT;


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
    (gen_random_uuid(), 'b0000001-b001-b001-b001-00000000b001', '10000001-1001-1001-1001-000000001001', 'Gender Reveal Party', NOW() + INTERVAL '25 days', NOW() + INTERVAL '25 days' + INTERVAL '4 hours', 'Find out if it''s a boy or girl!', 'Community Center', NULL, 'https://api.dicebear.com/7.x/shapes/svg?seed=event1', NOW() - INTERVAL '18 days', NOW() - INTERVAL '9 days'),
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
    (gen_random_uuid(), (SELECT id FROM public.events WHERE title = 'Gender Reveal Party' LIMIT 1), '4000000d-4001-4001-4001-000000004001', 'I think it''s a girl! 💕', NOW() - INTERVAL '4 days', NULL, NULL)
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

-- ============================================================================
-- END OF ADDITIONAL SEED DATA
-- ============================================================================

SET session_replication_role = 'origin';

-- ============================================================================
-- Nonna App - Row Level Security (RLS) Policies
-- Version: 1.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Comprehensive RLS policies for security and access control
-- ============================================================================

-- ============================================================================
-- SECTION 1: Enable RLS on All Tables
-- ============================================================================

-- Core user tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Baby profile and access control
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

-- Tile system configuration
ALTER TABLE public.screens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_configs ENABLE ROW LEVEL SECURITY;

-- Cache invalidation
ALTER TABLE public.owner_update_markers ENABLE ROW LEVEL SECURITY;

-- Calendar features
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;

-- Registry features
ALTER TABLE public.registry_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registry_purchases ENABLE ROW LEVEL SECURITY;

-- Photo gallery features
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_squishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_tags ENABLE ROW LEVEL SECURITY;

-- Gamification features
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.name_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.name_suggestion_likes ENABLE ROW LEVEL SECURITY;

-- Notifications and activity
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_events ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SECTION 2: Helper Functions for RLS
-- ============================================================================

-- Check if user is an active member of a baby profile
CREATE OR REPLACE FUNCTION public.is_baby_member(p_baby_profile_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.baby_memberships
        WHERE baby_profile_id = p_baby_profile_id
          AND user_id = p_user_id
          AND removed_at IS NULL
    );
$$;

-- Check if user is an owner of a baby profile
CREATE OR REPLACE FUNCTION public.is_baby_owner(p_baby_profile_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.baby_memberships
        WHERE baby_profile_id = p_baby_profile_id
          AND user_id = p_user_id
          AND role = 'owner'
          AND removed_at IS NULL
    );
$$;

-- Check if current user is service role
CREATE OR REPLACE FUNCTION public.is_service_role()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT COALESCE(auth.jwt()->>'role' = 'service_role', false);
$$;

-- ============================================================================
-- SECTION 3: Profiles RLS Policies
-- ============================================================================

-- Users can view all profiles (for displaying names/avatars)
CREATE POLICY "profiles_select_all"
    ON public.profiles
    FOR SELECT
    USING (true);

-- Users can insert their own profile
CREATE POLICY "profiles_insert_self"
    ON public.profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "profiles_update_self"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own profile
CREATE POLICY "profiles_delete_self"
    ON public.profiles
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- SECTION 4: User Stats RLS Policies
-- ============================================================================

-- Users can view all stats (for gamification display)
CREATE POLICY "user_stats_select_all"
    ON public.user_stats
    FOR SELECT
    USING (true);

-- System can insert/update stats (typically via triggers)
CREATE POLICY "user_stats_insert_system"
    ON public.user_stats
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "user_stats_update_system"
    ON public.user_stats
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- SECTION 5: Baby Profiles RLS Policies
-- ============================================================================

-- Members can view baby profiles they have access to
CREATE POLICY "baby_profiles_select_for_members"
    ON public.baby_profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.baby_memberships bm
            WHERE bm.baby_profile_id = baby_profiles.id
              AND bm.user_id = auth.uid()
              AND bm.removed_at IS NULL
        )
    );

-- Owners can insert baby profiles (membership created separately)
CREATE POLICY "baby_profiles_insert_authenticated"
    ON public.baby_profiles
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Owners can update their baby profiles
CREATE POLICY "baby_profiles_update_for_owners"
    ON public.baby_profiles
    FOR UPDATE
    USING (public.is_baby_owner(id, auth.uid()))
    WITH CHECK (public.is_baby_owner(id, auth.uid()));

-- Owners can delete their baby profiles
CREATE POLICY "baby_profiles_delete_for_owners"
    ON public.baby_profiles
    FOR DELETE
    USING (public.is_baby_owner(id, auth.uid()));

-- ============================================================================
-- SECTION 6: Baby Memberships RLS Policies
-- ============================================================================

-- Members can view memberships for babies they have access to
CREATE POLICY "baby_memberships_select_for_members"
    ON public.baby_memberships
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.baby_memberships bm
            WHERE bm.baby_profile_id = baby_memberships.baby_profile_id
              AND bm.user_id = auth.uid()
              AND bm.removed_at IS NULL
        )
    );

-- Owners can insert new memberships (for invitations)
CREATE POLICY "baby_memberships_insert_for_owners"
    ON public.baby_memberships
    FOR INSERT
    WITH CHECK (
        public.is_baby_owner(baby_profile_id, auth.uid())
        OR user_id = auth.uid() -- Allow self-join after invitation acceptance
    );

-- Owners can update memberships (e.g., revoke access)
CREATE POLICY "baby_memberships_update_for_owners"
    ON public.baby_memberships
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- Members can soft-delete their own membership (leave)
CREATE POLICY "baby_memberships_update_self_leave"
    ON public.baby_memberships
    FOR UPDATE
    USING (user_id = auth.uid() AND removed_at IS NULL)
    WITH CHECK (user_id = auth.uid() AND removed_at IS NOT NULL);

-- ============================================================================
-- SECTION 7: Invitations RLS Policies
-- ============================================================================

-- Owners can view invitations for their baby profiles
CREATE POLICY "invitations_select_for_owners"
    ON public.invitations
    FOR SELECT
    USING (public.is_baby_owner(baby_profile_id, auth.uid()));

-- Owners can create invitations
CREATE POLICY "invitations_insert_for_owners"
    ON public.invitations
    FOR INSERT
    WITH CHECK (
        public.is_baby_owner(baby_profile_id, auth.uid())
        AND invited_by_user_id = auth.uid()
    );

-- Owners can update invitations (revoke)
CREATE POLICY "invitations_update_for_owners"
    ON public.invitations
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- System can update invitations (for acceptance flow via Edge Function)
CREATE POLICY "invitations_update_system"
    ON public.invitations
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- SECTION 8: Tile System RLS Policies (Read-Only for Users)
-- ============================================================================

-- All authenticated users can view screens
CREATE POLICY "screens_select_authenticated"
    ON public.screens
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- All authenticated users can view tile definitions
CREATE POLICY "tile_definitions_select_authenticated"
    ON public.tile_definitions
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Users can view tile configs for their role
CREATE POLICY "tile_configs_select_authenticated"
    ON public.tile_configs
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Service role can manage tile system (admin operations)
CREATE POLICY "tile_system_manage_service_role"
    ON public.screens
    FOR ALL
    USING (public.is_service_role())
    WITH CHECK (public.is_service_role());

CREATE POLICY "tile_definitions_manage_service_role"
    ON public.tile_definitions
    FOR ALL
    USING (public.is_service_role())
    WITH CHECK (public.is_service_role());

CREATE POLICY "tile_configs_manage_service_role"
    ON public.tile_configs
    FOR ALL
    USING (public.is_service_role())
    WITH CHECK (public.is_service_role());

-- ============================================================================
-- SECTION 9: Owner Update Markers RLS Policies
-- ============================================================================

-- Members can view markers for babies they have access to
CREATE POLICY "markers_select_for_members"
    ON public.owner_update_markers
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Owners can update markers
CREATE POLICY "markers_update_for_owners"
    ON public.owner_update_markers
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- System can insert markers (typically on baby profile creation)
CREATE POLICY "markers_insert_system"
    ON public.owner_update_markers
    FOR INSERT
    WITH CHECK (true);

-- ============================================================================
-- SECTION 10: Events RLS Policies
-- ============================================================================

-- Members can view events for babies they have access to
CREATE POLICY "events_select_for_members"
    ON public.events
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Owners can create events
CREATE POLICY "events_insert_for_owners"
    ON public.events
    FOR INSERT
    WITH CHECK (
        public.is_baby_owner(baby_profile_id, auth.uid())
        AND created_by_user_id = auth.uid()
    );

-- Owners can update events
CREATE POLICY "events_update_for_owners"
    ON public.events
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- Owners can delete events
CREATE POLICY "events_delete_for_owners"
    ON public.events
    FOR DELETE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()));

-- ============================================================================
-- SECTION 11: Event RSVPs RLS Policies
-- ============================================================================

-- Members can view RSVPs for events they have access to
CREATE POLICY "event_rsvps_select_for_members"
    ON public.event_rsvps
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_rsvps.event_id
              AND public.is_baby_member(e.baby_profile_id, auth.uid())
        )
    );

-- Members can insert their own RSVPs
CREATE POLICY "event_rsvps_insert_self"
    ON public.event_rsvps
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_rsvps.event_id
              AND public.is_baby_member(e.baby_profile_id, auth.uid())
        )
    );

-- Members can update their own RSVPs
CREATE POLICY "event_rsvps_update_self"
    ON public.event_rsvps
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Members can delete their own RSVPs
CREATE POLICY "event_rsvps_delete_self"
    ON public.event_rsvps
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- SECTION 12: Event Comments RLS Policies
-- ============================================================================

-- Members can view non-deleted comments
CREATE POLICY "event_comments_select_for_members"
    ON public.event_comments
    FOR SELECT
    USING (
        deleted_at IS NULL
        AND EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_comments.event_id
              AND public.is_baby_member(e.baby_profile_id, auth.uid())
        )
    );

-- Members can insert comments
CREATE POLICY "event_comments_insert_for_members"
    ON public.event_comments
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_comments.event_id
              AND public.is_baby_member(e.baby_profile_id, auth.uid())
        )
    );

-- Users can update their own comments
CREATE POLICY "event_comments_update_self"
    ON public.event_comments
    FOR UPDATE
    USING (user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (user_id = auth.uid());

-- Owners can soft-delete any comment (moderation)
CREATE POLICY "event_comments_update_moderate_owners"
    ON public.event_comments
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_comments.event_id
              AND public.is_baby_owner(e.baby_profile_id, auth.uid())
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.events e
            WHERE e.id = event_comments.event_id
              AND public.is_baby_owner(e.baby_profile_id, auth.uid())
        )
    );

-- ============================================================================
-- SECTION 13: Registry Items RLS Policies
-- ============================================================================

-- Members can view registry items
CREATE POLICY "registry_items_select_for_members"
    ON public.registry_items
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Owners can create registry items
CREATE POLICY "registry_items_insert_for_owners"
    ON public.registry_items
    FOR INSERT
    WITH CHECK (
        public.is_baby_owner(baby_profile_id, auth.uid())
        AND created_by_user_id = auth.uid()
    );

-- Owners can update registry items
CREATE POLICY "registry_items_update_for_owners"
    ON public.registry_items
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- Owners can delete registry items
CREATE POLICY "registry_items_delete_for_owners"
    ON public.registry_items
    FOR DELETE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()));

-- ============================================================================
-- SECTION 14: Registry Purchases RLS Policies
-- ============================================================================

-- Members can view purchases
CREATE POLICY "registry_purchases_select_for_members"
    ON public.registry_purchases
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.registry_items ri
            WHERE ri.id = registry_purchases.registry_item_id
              AND public.is_baby_member(ri.baby_profile_id, auth.uid())
        )
    );

-- Members can create purchases
CREATE POLICY "registry_purchases_insert_for_members"
    ON public.registry_purchases
    FOR INSERT
    WITH CHECK (
        purchased_by_user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.registry_items ri
            WHERE ri.id = registry_purchases.registry_item_id
              AND public.is_baby_member(ri.baby_profile_id, auth.uid())
        )
    );

-- Users can delete their own purchases
CREATE POLICY "registry_purchases_delete_self"
    ON public.registry_purchases
    FOR DELETE
    USING (purchased_by_user_id = auth.uid());

-- ============================================================================
-- SECTION 15: Photos RLS Policies
-- ============================================================================

-- Members can view photos
CREATE POLICY "photos_select_for_members"
    ON public.photos
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Owners can upload photos
CREATE POLICY "photos_insert_for_owners"
    ON public.photos
    FOR INSERT
    WITH CHECK (
        public.is_baby_owner(baby_profile_id, auth.uid())
        AND uploaded_by_user_id = auth.uid()
    );

-- Owners can update photos
CREATE POLICY "photos_update_for_owners"
    ON public.photos
    FOR UPDATE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()))
    WITH CHECK (public.is_baby_owner(baby_profile_id, auth.uid()));

-- Owners can delete photos
CREATE POLICY "photos_delete_for_owners"
    ON public.photos
    FOR DELETE
    USING (public.is_baby_owner(baby_profile_id, auth.uid()));

-- ============================================================================
-- SECTION 16: Photo Squishes RLS Policies
-- ============================================================================

-- Members can view squishes
CREATE POLICY "photo_squishes_select_for_members"
    ON public.photo_squishes
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_squishes.photo_id
              AND public.is_baby_member(p.baby_profile_id, auth.uid())
        )
    );

-- Members can insert their own squishes
CREATE POLICY "photo_squishes_insert_self"
    ON public.photo_squishes
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_squishes.photo_id
              AND public.is_baby_member(p.baby_profile_id, auth.uid())
        )
    );

-- Members can delete their own squishes
CREATE POLICY "photo_squishes_delete_self"
    ON public.photo_squishes
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- SECTION 17: Photo Comments RLS Policies
-- ============================================================================

-- Members can view non-deleted comments
CREATE POLICY "photo_comments_select_for_members"
    ON public.photo_comments
    FOR SELECT
    USING (
        deleted_at IS NULL
        AND EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_comments.photo_id
              AND public.is_baby_member(p.baby_profile_id, auth.uid())
        )
    );

-- Members can insert comments
CREATE POLICY "photo_comments_insert_for_members"
    ON public.photo_comments
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_comments.photo_id
              AND public.is_baby_member(p.baby_profile_id, auth.uid())
        )
    );

-- Users can update their own comments
CREATE POLICY "photo_comments_update_self"
    ON public.photo_comments
    FOR UPDATE
    USING (user_id = auth.uid() AND deleted_at IS NULL)
    WITH CHECK (user_id = auth.uid());

-- Owners can soft-delete any comment (moderation)
CREATE POLICY "photo_comments_update_moderate_owners"
    ON public.photo_comments
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_comments.photo_id
              AND public.is_baby_owner(p.baby_profile_id, auth.uid())
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_comments.photo_id
              AND public.is_baby_owner(p.baby_profile_id, auth.uid())
        )
    );

-- ============================================================================
-- SECTION 18: Photo Tags RLS Policies
-- ============================================================================

-- Members can view tags
CREATE POLICY "photo_tags_select_for_members"
    ON public.photo_tags
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_tags.photo_id
              AND public.is_baby_member(p.baby_profile_id, auth.uid())
        )
    );

-- Owners can create tags
CREATE POLICY "photo_tags_insert_for_owners"
    ON public.photo_tags
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_tags.photo_id
              AND public.is_baby_owner(p.baby_profile_id, auth.uid())
        )
    );

-- Owners can delete tags
CREATE POLICY "photo_tags_delete_for_owners"
    ON public.photo_tags
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1
            FROM public.photos p
            WHERE p.id = photo_tags.photo_id
              AND public.is_baby_owner(p.baby_profile_id, auth.uid())
        )
    );

-- ============================================================================
-- SECTION 19: Votes RLS Policies
-- ============================================================================

-- Members can view votes (anonymity handled in application logic)
CREATE POLICY "votes_select_for_members"
    ON public.votes
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Members can insert their own votes
CREATE POLICY "votes_insert_self"
    ON public.votes
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND public.is_baby_member(baby_profile_id, auth.uid())
    );

-- Members can update their own votes
CREATE POLICY "votes_update_self"
    ON public.votes
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Members can delete their own votes
CREATE POLICY "votes_delete_self"
    ON public.votes
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- SECTION 20: Name Suggestions RLS Policies
-- ============================================================================

-- Members can view name suggestions
CREATE POLICY "name_suggestions_select_for_members"
    ON public.name_suggestions
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- Members can insert their own suggestions
CREATE POLICY "name_suggestions_insert_self"
    ON public.name_suggestions
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND public.is_baby_member(baby_profile_id, auth.uid())
    );

-- Members can update their own suggestions
CREATE POLICY "name_suggestions_update_self"
    ON public.name_suggestions
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Members can delete their own suggestions
CREATE POLICY "name_suggestions_delete_self"
    ON public.name_suggestions
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- SECTION 21: Name Suggestion Likes RLS Policies
-- ============================================================================

-- Members can view likes
CREATE POLICY "name_suggestion_likes_select_for_members"
    ON public.name_suggestion_likes
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.name_suggestions ns
            WHERE ns.id = name_suggestion_likes.name_suggestion_id
              AND public.is_baby_member(ns.baby_profile_id, auth.uid())
        )
    );

-- Members can insert their own likes
CREATE POLICY "name_suggestion_likes_insert_self"
    ON public.name_suggestion_likes
    FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1
            FROM public.name_suggestions ns
            WHERE ns.id = name_suggestion_likes.name_suggestion_id
              AND public.is_baby_member(ns.baby_profile_id, auth.uid())
        )
    );

-- Members can delete their own likes
CREATE POLICY "name_suggestion_likes_delete_self"
    ON public.name_suggestion_likes
    FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================================
-- SECTION 22: Notifications RLS Policies
-- ============================================================================

-- Users can view their own notifications
CREATE POLICY "notifications_select_self"
    ON public.notifications
    FOR SELECT
    USING (recipient_user_id = auth.uid());

-- System can insert notifications (typically via triggers/Edge Functions)
CREATE POLICY "notifications_insert_system"
    ON public.notifications
    FOR INSERT
    WITH CHECK (true);

-- Users can update their own notifications (mark as read)
CREATE POLICY "notifications_update_self"
    ON public.notifications
    FOR UPDATE
    USING (recipient_user_id = auth.uid())
    WITH CHECK (recipient_user_id = auth.uid());

-- Users can delete their own notifications
CREATE POLICY "notifications_delete_self"
    ON public.notifications
    FOR DELETE
    USING (recipient_user_id = auth.uid());

-- ============================================================================
-- SECTION 23: Activity Events RLS Policies
-- ============================================================================

-- Members can view activity events for babies they have access to
CREATE POLICY "activity_events_select_for_members"
    ON public.activity_events
    FOR SELECT
    USING (public.is_baby_member(baby_profile_id, auth.uid()));

-- System can insert activity events (typically via triggers)
CREATE POLICY "activity_events_insert_system"
    ON public.activity_events
    FOR INSERT
    WITH CHECK (true);

-- ============================================================================
-- SECTION 24: Grant Permissions
-- ============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated, anon, service_role;

-- Grant select on all tables to authenticated users (RLS handles row-level access)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant appropriate permissions to anon role (for invitation acceptance flow)
GRANT SELECT, INSERT, UPDATE ON public.invitations TO anon;
GRANT SELECT ON public.baby_profiles TO anon;

-- Grant all permissions to service_role for admin operations
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated, service_role;

-- ============================================================================
-- END OF RLS POLICIES SCRIPT
-- ============================================================================


-- ============================================================================
-- Nonna App - Database Triggers and Functions
-- Version: 1.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Automated triggers for profile creation, timestamps, and cache invalidation
-- ============================================================================

-- ============================================================================
-- SECTION 1: Auto-Create Profile on User Signup
-- ============================================================================

-- Function: Create profile when new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert profile for new auth user
    INSERT INTO public.profiles (user_id, display_name, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NOW(),
        NOW()
    );
    
    -- Insert initial user stats
    INSERT INTO public.user_stats (user_id, updated_at)
    VALUES (NEW.id, NOW());
    
    RETURN NEW;
END;
$$;

-- Trigger: Execute handle_new_user after auth.users insert
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates profile and stats when new user signs up via Supabase Auth';

-- ============================================================================
-- SECTION 2: Auto-Update Timestamps
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Apply update_updated_at trigger to all relevant tables
CREATE TRIGGER set_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_user_stats
    BEFORE UPDATE ON public.user_stats
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_baby_profiles
    BEFORE UPDATE ON public.baby_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_baby_memberships
    BEFORE UPDATE ON public.baby_memberships
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_invitations
    BEFORE UPDATE ON public.invitations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_tile_configs
    BEFORE UPDATE ON public.tile_configs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_events
    BEFORE UPDATE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_event_rsvps
    BEFORE UPDATE ON public.event_rsvps
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_registry_items
    BEFORE UPDATE ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_photos
    BEFORE UPDATE ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_votes
    BEFORE UPDATE ON public.votes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_name_suggestions
    BEFORE UPDATE ON public.name_suggestions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

COMMENT ON FUNCTION public.update_updated_at_column() IS 'Auto-updates updated_at timestamp on row modification';

-- ============================================================================
-- SECTION 3: Owner Update Marker Management
-- ============================================================================

-- Function: Create owner update marker on baby profile creation
CREATE OR REPLACE FUNCTION public.create_owner_update_marker()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Create initial marker for new baby profile
    INSERT INTO public.owner_update_markers (baby_profile_id, tiles_last_updated_at, reason)
    VALUES (NEW.id, NOW(), 'baby_profile_created');
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_baby_profile_created
    AFTER INSERT ON public.baby_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.create_owner_update_marker();

COMMENT ON FUNCTION public.create_owner_update_marker() IS 'Creates cache invalidation marker when baby profile is created';

-- Function: Update owner marker on content changes
CREATE OR REPLACE FUNCTION public.update_owner_marker()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_reason text;
BEGIN
    -- Determine baby_profile_id and reason based on table
    IF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'event_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'photo_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'registry_items' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'registry_item_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_reason := 'registry_purchase_' || TG_OP;
    ELSE
        RETURN NEW;
    END IF;
    
    -- Update marker timestamp
    UPDATE public.owner_update_markers
    SET tiles_last_updated_at = NOW(),
        updated_by_user_id = auth.uid(),
        reason = v_reason
    WHERE baby_profile_id = v_baby_profile_id;
    
    RETURN NEW;
END;
$$;

-- Apply marker update triggers to content tables
CREATE TRIGGER update_marker_on_event_change
    AFTER INSERT OR UPDATE OR DELETE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_photo_change
    AFTER INSERT OR UPDATE OR DELETE ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_registry_item_change
    AFTER INSERT OR UPDATE OR DELETE ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

COMMENT ON FUNCTION public.update_owner_marker() IS 'Updates cache invalidation marker when owners modify content';

-- ============================================================================
-- SECTION 4: User Stats Update Triggers
-- ============================================================================

-- Function: Increment events attended count
CREATE OR REPLACE FUNCTION public.increment_events_attended()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only count 'yes' RSVPs
    IF NEW.status = 'yes' THEN
        UPDATE public.user_stats
        SET events_attended_count = events_attended_count + 1,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_event_rsvp_yes
    AFTER INSERT OR UPDATE ON public.event_rsvps
    FOR EACH ROW
    WHEN (NEW.status = 'yes')
    EXECUTE FUNCTION public.increment_events_attended();

-- Function: Increment items purchased count
CREATE OR REPLACE FUNCTION public.increment_items_purchased()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET items_purchased_count = items_purchased_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.purchased_by_user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_items_purchased();

-- Function: Increment photos squished count
CREATE OR REPLACE FUNCTION public.increment_photos_squished()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET photos_squished_count = photos_squished_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_photo_squish
    AFTER INSERT ON public.photo_squishes
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_photos_squished();

-- Function: Increment comments added count
CREATE OR REPLACE FUNCTION public.increment_comments_added()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET comments_added_count = comments_added_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_event_comment
    AFTER INSERT ON public.event_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_comments_added();

CREATE TRIGGER on_photo_comment
    AFTER INSERT ON public.photo_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_comments_added();

COMMENT ON FUNCTION public.increment_events_attended() IS 'Updates user stats when RSVP changes to yes';
COMMENT ON FUNCTION public.increment_items_purchased() IS 'Updates user stats when registry item purchased';
COMMENT ON FUNCTION public.increment_photos_squished() IS 'Updates user stats when photo squished';
COMMENT ON FUNCTION public.increment_comments_added() IS 'Updates user stats when comment added';

-- ============================================================================
-- SECTION 5: Activity Event Logging
-- ============================================================================

-- Function: Log activity events
CREATE OR REPLACE FUNCTION public.log_activity_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_type text;
    v_payload jsonb;
BEGIN
    -- Determine activity type and payload based on table
    IF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'photo_uploaded';
        v_payload := jsonb_build_object('photo_id', NEW.id, 'caption', NEW.caption);
        
    ELSIF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'event_created';
        v_payload := jsonb_build_object('event_id', NEW.id, 'title', NEW.title);
        
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_type := 'item_purchased';
        v_payload := jsonb_build_object('registry_item_id', NEW.registry_item_id);
        
    ELSIF TG_TABLE_NAME = 'event_comments' THEN
        -- Get baby_profile_id from events
        SELECT e.baby_profile_id INTO v_baby_profile_id
        FROM public.events e
        WHERE e.id = NEW.event_id;
        v_type := 'comment_added';
        v_payload := jsonb_build_object('event_id', NEW.event_id, 'comment_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'photo_comments' THEN
        -- Get baby_profile_id from photos
        SELECT p.baby_profile_id INTO v_baby_profile_id
        FROM public.photos p
        WHERE p.id = NEW.photo_id;
        v_type := 'comment_added';
        v_payload := jsonb_build_object('photo_id', NEW.photo_id, 'comment_id', NEW.id);
        
    ELSE
        RETURN NEW;
    END IF;
    
    -- Insert activity event
    INSERT INTO public.activity_events (baby_profile_id, actor_user_id, type, payload)
    VALUES (v_baby_profile_id, auth.uid(), v_type, v_payload);
    
    RETURN NEW;
END;
$$;

-- Apply activity logging triggers
CREATE TRIGGER log_photo_activity
    AFTER INSERT ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_event_activity
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_purchase_activity
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_event_comment_activity
    AFTER INSERT ON public.event_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_photo_comment_activity
    AFTER INSERT ON public.photo_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

COMMENT ON FUNCTION public.log_activity_event() IS 'Logs significant actions to activity_events for Recent Activity tiles';

-- ============================================================================
-- SECTION 6: Notification Triggers
-- ============================================================================

-- Constant for null UUID (used when actor is unknown)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'null_uuid') THEN
        CREATE FUNCTION public.null_uuid() RETURNS uuid AS
        'SELECT ''00000000-0000-0000-0000-000000000000''::uuid;'
        LANGUAGE SQL IMMUTABLE;
    END IF;
END
$$;

-- Function: Create notifications for new content
CREATE OR REPLACE FUNCTION public.create_content_notifications()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_type text;
    v_payload jsonb;
    v_recipient record;
BEGIN
    -- Determine notification type and payload
    IF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'photo_added';
        v_payload := jsonb_build_object('photo_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'event_created';
        v_payload := jsonb_build_object('event_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'registry_items' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'registry_item_added';
        v_payload := jsonb_build_object('registry_item_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_type := 'registry_item_purchased';
        v_payload := jsonb_build_object('registry_item_id', NEW.registry_item_id, 'purchased_by', NEW.purchased_by_user_id);
        
    ELSIF TG_TABLE_NAME = 'event_rsvps' THEN
        -- Get baby_profile_id from events
        SELECT e.baby_profile_id INTO v_baby_profile_id
        FROM public.events e
        WHERE e.id = NEW.event_id;
        v_type := 'event_rsvp';
        v_payload := jsonb_build_object('event_id', NEW.event_id, 'user_id', NEW.user_id, 'status', NEW.status);
        
    ELSIF TG_TABLE_NAME = 'baby_memberships' AND NEW.removed_at IS NULL THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'new_follower';
        v_payload := jsonb_build_object('user_id', NEW.user_id, 'relationship', NEW.relationship_label);
        
    ELSE
        RETURN NEW;
    END IF;
    
    -- Create notifications for all members (excluding actor)
    FOR v_recipient IN
        SELECT DISTINCT user_id
        FROM public.baby_memberships
        WHERE baby_profile_id = v_baby_profile_id
          AND removed_at IS NULL
          AND user_id != COALESCE(auth.uid(), public.null_uuid())
    LOOP
        INSERT INTO public.notifications (recipient_user_id, baby_profile_id, type, payload)
        VALUES (v_recipient.user_id, v_baby_profile_id, v_type, v_payload);
    END LOOP;
    
    RETURN NEW;
END;
$$;

-- Apply notification triggers
CREATE TRIGGER notify_on_photo_upload
    AFTER INSERT ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_event_creation
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_registry_item_added
    AFTER INSERT ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_event_rsvp
    AFTER INSERT OR UPDATE ON public.event_rsvps
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_new_follower
    AFTER INSERT ON public.baby_memberships
    FOR EACH ROW
    WHEN (NEW.removed_at IS NULL AND NEW.role = 'follower')
    EXECUTE FUNCTION public.create_content_notifications();

COMMENT ON FUNCTION public.create_content_notifications() IS 'Creates in-app notifications for significant events';

-- ============================================================================
-- SECTION 7: Constraint Enforcement via Triggers
-- ============================================================================

-- Function: Enforce max 2 owners per baby profile
CREATE OR REPLACE FUNCTION public.check_max_owners()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_owner_count int;
BEGIN
    -- Only check for owner role insertions
    IF NEW.role = 'owner' AND NEW.removed_at IS NULL THEN
        SELECT COUNT(*)
        INTO v_owner_count
        FROM public.baby_memberships
        WHERE baby_profile_id = NEW.baby_profile_id
          AND role = 'owner'
          AND removed_at IS NULL
          AND id != NEW.id; -- Exclude current row for updates
        
        IF v_owner_count >= 2 THEN
            RAISE EXCEPTION 'Maximum 2 owners allowed per baby profile';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_max_owners
    BEFORE INSERT OR UPDATE ON public.baby_memberships
    FOR EACH ROW
    EXECUTE FUNCTION public.check_max_owners();

COMMENT ON FUNCTION public.check_max_owners() IS 'Enforces maximum 2 owners per baby profile requirement';

-- Function: Validate invitation expiry
CREATE OR REPLACE FUNCTION public.validate_invitation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Auto-expire invitations past expiration date
    IF NEW.expires_at < NOW() AND NEW.status = 'pending' THEN
        NEW.status := 'expired';
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER check_invitation_expiry
    BEFORE INSERT OR UPDATE ON public.invitations
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_invitation();

COMMENT ON FUNCTION public.validate_invitation() IS 'Auto-expires invitations past 7-day expiration';

-- ============================================================================
-- END OF TRIGGERS AND FUNCTIONS SCRIPT
-- ============================================================================
