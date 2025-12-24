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
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "tile_definitions_manage_service_role"
    ON public.tile_definitions
    FOR ALL
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "tile_configs_manage_service_role"
    ON public.tile_configs
    FOR ALL
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

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
