-- System Permissions, Grants & Realtime
-- Migration: Grant all RLS-related permissions
-- Consolidates: 20260302000003 + 20260302000004 + 20260302000005 + 20260302000006 + 20260302000012
--
-- Grants all necessary permissions for authenticated and anon roles to interact with
-- protected tables and call RLS helper functions

-- ========================================
-- All SELECT Permissions (Read Access)
-- ========================================

-- Core tables
GRANT SELECT ON public.baby_profiles TO authenticated;
GRANT SELECT ON public.baby_memberships TO authenticated;
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.user_stats TO authenticated;

-- Events and RSVPs
GRANT SELECT ON public.events TO authenticated;
GRANT SELECT ON public.event_comments TO authenticated;
GRANT SELECT ON public.event_rsvps TO authenticated;

-- Photos and related
GRANT SELECT ON public.photos TO authenticated;
GRANT SELECT ON public.photo_comments TO authenticated;
GRANT SELECT ON public.photo_squishes TO authenticated;
GRANT SELECT ON public.photo_tags TO authenticated;

-- Gamification and social
GRANT SELECT ON public.votes TO authenticated;
GRANT SELECT ON public.name_suggestions TO authenticated;
GRANT SELECT ON public.name_suggestion_likes TO authenticated;

-- Notifications and metadata
GRANT SELECT ON public.notifications TO authenticated;
GRANT SELECT ON public.notification_preferences TO authenticated;
GRANT SELECT ON public.activity_events TO authenticated;
GRANT SELECT ON public.invitations TO authenticated;
GRANT SELECT ON public.owner_update_markers TO authenticated;

-- Registry
GRANT SELECT ON public.registry_items TO authenticated;
GRANT SELECT ON public.registry_purchases TO authenticated;

-- Configuration
GRANT SELECT ON public.screens TO authenticated, anon;
GRANT SELECT ON public.tile_definitions TO authenticated, anon;
GRANT SELECT ON public.tile_configs TO authenticated, anon;

-- ========================================
-- INSERT/UPDATE/DELETE Permissions (Write Access)
-- ========================================

-- Events and RSVPs
GRANT INSERT, UPDATE, DELETE ON public.events TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.event_comments TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.event_rsvps TO authenticated;

-- Photos and related
GRANT INSERT, UPDATE, DELETE ON public.photos TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.photo_comments TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.photo_squishes TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.photo_tags TO authenticated;

-- Gamification and social
GRANT INSERT, UPDATE, DELETE ON public.votes TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.name_suggestions TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.name_suggestion_likes TO authenticated;

-- Notifications and metadata
GRANT INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO service_role;
GRANT INSERT, UPDATE, DELETE ON public.notification_preferences TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.activity_events TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.invitations TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.owner_update_markers TO authenticated;

-- Registry
GRANT INSERT, UPDATE, DELETE ON public.registry_items TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.registry_purchases TO authenticated;

-- ========================================
-- Helper Function Permissions
-- ========================================

-- Baby membership helpers
GRANT EXECUTE ON FUNCTION public.is_baby_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_baby_owner(uuid, uuid) TO authenticated;

-- Photo/event/registry helpers
GRANT EXECUTE ON FUNCTION is_photo_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_photo_owner(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_event_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_registry_item_member(uuid, uuid) TO authenticated;

-- ========================================
-- User Profiles Permissions (Limited - read only for auth context)
-- ========================================

GRANT SELECT ON public.profiles TO authenticated;
GRANT INSERT ON public.profiles TO authenticated; -- For initial profile creation
GRANT UPDATE ON public.profiles TO authenticated;  -- For profile updates (restricted via RLS)

-- ========================================
-- Anonymous User Permissions (Public data only)
-- ========================================

GRANT SELECT ON public.screens TO anon;
GRANT SELECT ON public.tile_definitions TO anon;
GRANT SELECT ON public.tile_configs TO anon;

-- ========================================
-- Tile Configs Anonymous User Permission
-- ========================================

GRANT SELECT ON public.tile_configs TO anon;
-- Migration: Grant write permissions on core tables
-- Ensures authenticated users can create and manage baby profiles and memberships

-- Baby Profiles
GRANT INSERT, UPDATE, DELETE ON public.baby_profiles TO authenticated;

-- Baby Memberships
GRANT INSERT, UPDATE, DELETE ON public.baby_memberships TO authenticated;
-- Enable real-time for all required tables to prevent RealtimeCloseEvent (code: 1002) channel drop errors

BEGIN;
  -- Add tables that the app subscribes to for Real-time events
  -- Do not DROP the publication, as the Supabase Realtime server relies on its persistent OID
  ALTER PUBLICATION supabase_realtime ADD TABLE 
    user_stats,
    photos,
    photo_squishes,
    events,
    votes,
    name_suggestions,
    name_suggestion_likes,
    activity_events,
    app_versions,
    event_comments,
    event_rsvps,
    photo_comments,
    photo_tags,
    notification_preferences,
    invitations,
    owner_update_markers,
    registry_items,
    registry_purchases,
    profiles,
    screens,
    tile_definitions,
    notifications,
    tile_configs,
    baby_memberships,
    baby_profiles;
COMMIT;
