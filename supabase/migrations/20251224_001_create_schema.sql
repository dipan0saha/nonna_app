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
