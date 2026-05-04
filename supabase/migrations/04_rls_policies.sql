-- Row Level Security (RLS) & Policies
-- Enable RLS on all public tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.owner_update_markers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_squishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registry_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registry_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.name_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.name_suggestion_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tile_configs ENABLE ROW LEVEL SECURITY;
-- ========================================
-- Profiles RLS Policies
-- ========================================

CREATE POLICY "Users can view all profiles"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ========================================
-- User Stats RLS Policies
-- ========================================

CREATE POLICY "Users can view own stats"
  ON public.user_stats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users in same baby profile can view stats"
  ON public.user_stats FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships bm1
      INNER JOIN public.baby_memberships bm2
        ON bm1.baby_profile_id = bm2.baby_profile_id
      WHERE bm1.user_id = auth.uid()
        AND bm2.user_id = user_stats.user_id
        AND bm1.removed_at IS NULL
        AND bm2.removed_at IS NULL
    )
  );

-- ========================================
-- Baby Profiles RLS Policies
-- ========================================

CREATE POLICY "Members can view baby profiles"
  ON public.baby_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = baby_profiles.id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND baby_profiles.deleted_at IS NULL
  );

CREATE POLICY "Owners can update baby profiles"
  ON public.baby_profiles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = baby_profiles.id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Authenticated users can create baby profiles"
  ON public.baby_profiles FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Owners can delete baby profiles"
  ON public.baby_profiles FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = baby_profiles.id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Baby Memberships RLS Policies
-- ========================================

CREATE POLICY "Members can view memberships for their babies"
  ON public.baby_memberships FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships bm
      WHERE bm.baby_profile_id = baby_memberships.baby_profile_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can manage memberships"
  ON public.baby_memberships FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships bm
      WHERE bm.baby_profile_id = baby_memberships.baby_profile_id
        AND bm.user_id = auth.uid()
        AND bm.role = 'owner'
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can create their own membership"
  ON public.baby_memberships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave (soft delete own membership)"
  ON public.baby_memberships FOR UPDATE
  USING (auth.uid() = user_id);

-- ========================================
-- Invitations RLS Policies
-- ========================================

CREATE POLICY "Owners can view invitations for their babies"
  ON public.invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = invitations.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can create invitations"
  ON public.invitations FOR INSERT
  WITH CHECK (
    auth.uid() = invited_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = invitations.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can update invitations (revoke)"
  ON public.invitations FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = invitations.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Owner Update Markers RLS Policies
-- ========================================

CREATE POLICY "Members can view owner update markers"
  ON public.owner_update_markers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = owner_update_markers.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
  );

-- System/owners can insert and update markers
CREATE POLICY "Owners can manage owner update markers"
  ON public.owner_update_markers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = owner_update_markers.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Photos RLS Policies
-- ========================================

CREATE POLICY "Members can view photos"
  ON public.photos FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND photos.deleted_at IS NULL
  );

CREATE POLICY "Owners can upload photos"
  ON public.photos FOR INSERT
  WITH CHECK (
    auth.uid() = uploaded_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can update photos"
  ON public.photos FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can delete photos"
  ON public.photos FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Photo Squishes RLS Policies
-- ========================================

CREATE POLICY "Members can view photo squishes"
  ON public.photo_squishes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_squishes.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Members can squish photos"
  ON public.photo_squishes FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_squishes.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can unsquish (delete own squish)"
  ON public.photo_squishes FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Photo Comments RLS Policies
-- ========================================

CREATE POLICY "Members can view photo comments"
  ON public.photo_comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
    AND photo_comments.deleted_at IS NULL
  );

CREATE POLICY "Members can add photo comments"
  ON public.photo_comments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users and owners can update photo comments"
  ON public.photo_comments FOR UPDATE
  USING (
    auth.uid() = user_id
    OR is_photo_owner(auth.uid(), photo_id)
  );

CREATE POLICY "Users and owners can delete photo comments"
  ON public.photo_comments FOR DELETE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.role = 'owner'
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Photo Tags RLS Policies
-- ========================================

CREATE POLICY "Members can view photo tags"
  ON public.photo_tags FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_tags.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can manage photo tags"
  ON public.photo_tags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_tags.photo_id
        AND bm.user_id = auth.uid()
        AND bm.role = 'owner'
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Events RLS Policies
-- ========================================

CREATE POLICY "Members can view events"
  ON public.events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND events.deleted_at IS NULL
  );

CREATE POLICY "Owners can create events"
  ON public.events FOR INSERT
  WITH CHECK (
    auth.uid() = created_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can update events"
  ON public.events FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can delete events"
  ON public.events FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Event Comments RLS Policies
-- ========================================

CREATE POLICY "Members can view event comments"
  ON public.event_comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.events e
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
      WHERE e.id = event_comments.event_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
    AND event_comments.deleted_at IS NULL
  );

CREATE POLICY "Members can add event comments"
  ON public.event_comments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.events e
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
      WHERE e.id = event_comments.event_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can update own event comments"
  ON public.event_comments FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users and owners can delete event comments"
  ON public.event_comments FOR DELETE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.events e
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
      WHERE e.id = event_comments.event_id
        AND bm.user_id = auth.uid()
        AND bm.role = 'owner'
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Event RSVPs RLS Policies
-- ========================================

CREATE POLICY "Members can view event RSVPs"
  ON public.event_rsvps FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.events e
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
      WHERE e.id = event_rsvps.event_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Members can create RSVPs"
  ON public.event_rsvps FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.events e
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
      WHERE e.id = event_rsvps.event_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can update own RSVPs"
  ON public.event_rsvps FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own RSVPs"
  ON public.event_rsvps FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Registry Items RLS Policies
-- ========================================

CREATE POLICY "Members can view registry items"
  ON public.registry_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND registry_items.deleted_at IS NULL
  );

CREATE POLICY "Owners can create registry items"
  ON public.registry_items FOR INSERT
  WITH CHECK (
    auth.uid() = created_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can update registry items"
  ON public.registry_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Owners can delete registry items"
  ON public.registry_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Registry Purchases RLS Policies
-- ========================================

CREATE POLICY "Members can view registry purchases"
  ON public.registry_purchases FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.registry_items ri
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ri.baby_profile_id
      WHERE ri.id = registry_purchases.registry_item_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Members can mark items as purchased"
  ON public.registry_purchases FOR INSERT
  WITH CHECK (
    auth.uid() = purchased_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.registry_items ri
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ri.baby_profile_id
      WHERE ri.id = registry_purchases.registry_item_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Votes RLS Policies
-- ========================================

CREATE POLICY "Members can view non-anonymous votes"
  ON public.votes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = votes.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND (
      votes.is_anonymous = FALSE
      OR votes.user_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM public.baby_memberships
        WHERE baby_memberships.baby_profile_id = votes.baby_profile_id
          AND baby_memberships.user_id = auth.uid()
          AND baby_memberships.role = 'owner'
          AND baby_memberships.removed_at IS NULL
      )
    )
  );

CREATE POLICY "Members can create votes"
  ON public.votes FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = votes.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Users can update own votes"
  ON public.votes FOR UPDATE
  USING (auth.uid() = user_id);

-- ========================================
-- Name Suggestions RLS Policies
-- ========================================

CREATE POLICY "Members can view name suggestions"
  ON public.name_suggestions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = name_suggestions.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
    AND name_suggestions.deleted_at IS NULL
  );

CREATE POLICY "Members can create name suggestions"
  ON public.name_suggestions FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = name_suggestions.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Users can update own suggestions"
  ON public.name_suggestions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users and owners can delete name suggestions"
  ON public.name_suggestions FOR DELETE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = name_suggestions.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Name Suggestion Likes RLS Policies
-- ========================================

CREATE POLICY "Members can view name suggestion likes"
  ON public.name_suggestion_likes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.name_suggestions ns
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ns.baby_profile_id
      WHERE ns.id = name_suggestion_likes.name_suggestion_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Members can like name suggestions"
  ON public.name_suggestion_likes FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.name_suggestions ns
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ns.baby_profile_id
      WHERE ns.id = name_suggestion_likes.name_suggestion_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can unlike (delete own like)"
  ON public.name_suggestion_likes FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Notifications RLS Policies
-- ========================================

CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = recipient_user_id);

CREATE POLICY "Users can update own notifications (mark as read)"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = recipient_user_id);

-- ========================================
-- Notification Preferences RLS Policies
-- ========================================

CREATE POLICY "Users can view own notification preferences"
  ON public.notification_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notification preferences"
  ON public.notification_preferences FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification preferences"
  ON public.notification_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ========================================
-- Activity Events RLS Policies
-- ========================================

CREATE POLICY "Members can view activity events"
  ON public.activity_events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = activity_events.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.removed_at IS NULL
    )
  );

-- ========================================
-- Screens RLS Policies (Global read, admin write)
-- ========================================

CREATE POLICY "Anyone can view screens"
  ON public.screens FOR SELECT
  USING (is_active = TRUE);

-- ========================================
-- Tile Definitions RLS Policies
-- ========================================

CREATE POLICY "Anyone can view tile definitions"
  ON public.tile_definitions FOR SELECT
  USING (is_active = TRUE);

-- ========================================
-- Tile Configs RLS Policies
-- ========================================

CREATE POLICY "Authenticated users can view tile configs for their role"
  ON public.tile_configs FOR SELECT
  TO authenticated
  USING (is_visible = TRUE);

-- ========================================
-- Grant Permissions
-- ========================================

GRANT SELECT ON public.screens TO anon, authenticated;
GRANT SELECT ON public.tile_definitions TO anon, authenticated;
GRANT SELECT ON public.tile_configs TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.activity_events TO authenticated;
GRANT INSERT ON public.activity_events TO postgres;
GRANT INSERT ON public.notifications TO postgres, authenticated;

-- Migration: Fix all RLS policy recursion issues
-- Combines: 20260302000002_fix_rls_recursion.sql + 20260302000007_fix_remaining_rls_recursion.sql
--
-- This migration resolves infinite recursion in RLS policies by creating SECURITY DEFINER
-- helper functions that break circular dependencies across all affected tables

-- ========================================
-- Baby Membership Helper Functions
-- ========================================

CREATE OR REPLACE FUNCTION public.is_baby_member(
  p_user_id uuid,
  p_baby_profile_id uuid
)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.baby_memberships
    WHERE baby_memberships.baby_profile_id = p_baby_profile_id
      AND baby_memberships.user_id = p_user_id
      AND baby_memberships.removed_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_baby_owner(
  p_user_id uuid,
  p_baby_profile_id uuid
)
RETURNS boolean AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.baby_memberships
    WHERE baby_memberships.baby_profile_id = p_baby_profile_id
      AND baby_memberships.user_id = p_user_id
      AND baby_memberships.role = 'owner'
      AND baby_memberships.removed_at IS NULL
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.is_baby_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_baby_owner(uuid, uuid) TO authenticated;

-- ========================================
-- Photo/Event/Registry Helper Functions
-- ========================================

DROP FUNCTION IF EXISTS is_photo_member(uuid, uuid) CASCADE;
CREATE OR REPLACE FUNCTION is_photo_member(user_id uuid, photo_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.photos p
    INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
    WHERE p.id = $2
      AND bm.user_id = $1
      AND bm.removed_at IS NULL
  );
$$;

DROP FUNCTION IF EXISTS is_photo_owner(uuid, uuid) CASCADE;
CREATE OR REPLACE FUNCTION is_photo_owner(user_id uuid, photo_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.photos p
    INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = p.baby_profile_id
    WHERE p.id = $2
      AND bm.user_id = $1
      AND bm.role = 'owner'
      AND bm.removed_at IS NULL
  );
$$;

DROP FUNCTION IF EXISTS is_event_member(uuid, uuid) CASCADE;
CREATE OR REPLACE FUNCTION is_event_member(user_id uuid, event_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.events e
    INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = e.baby_profile_id
    WHERE e.id = $2
      AND bm.user_id = $1
      AND bm.removed_at IS NULL
  );
$$;

DROP FUNCTION IF EXISTS is_registry_item_member(uuid, uuid) CASCADE;
CREATE OR REPLACE FUNCTION is_registry_item_member(user_id uuid, registry_item_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.registry_items ri
    INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ri.baby_profile_id
    WHERE ri.id = $2
      AND bm.user_id = $1
      AND bm.removed_at IS NULL
  );
$$;

GRANT EXECUTE ON FUNCTION is_photo_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_photo_owner(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_event_member(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_registry_item_member(uuid, uuid) TO authenticated;

-- ========================================
-- Update Baby Memberships Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view memberships for their babies" ON public.baby_memberships;
DROP POLICY IF EXISTS "Owners can manage memberships" ON public.baby_memberships;

CREATE POLICY "Members can view memberships for their babies"
  ON public.baby_memberships FOR SELECT
  USING (public.is_baby_member(auth.uid(), baby_profile_id));

CREATE POLICY "Owners can manage memberships"
  ON public.baby_memberships FOR ALL
  USING (public.is_baby_owner(auth.uid(), baby_profile_id));

-- ========================================
-- Update Baby Profiles Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view baby profiles" ON public.baby_profiles;

CREATE POLICY "Members can view baby profiles"
  ON public.baby_profiles FOR SELECT
  USING (
    public.is_baby_member(auth.uid(), id)
    AND deleted_at IS NULL
  );

-- ========================================
-- Update Photo Squishes Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view photo squishes" ON public.photo_squishes;
DROP POLICY IF EXISTS "Members can squish photos" ON public.photo_squishes;
DROP POLICY IF EXISTS "Users can unsquish (delete own squish)" ON public.photo_squishes;

CREATE POLICY "Members can view photo squishes"
  ON public.photo_squishes FOR SELECT
  USING (is_photo_member(auth.uid(), photo_id));

CREATE POLICY "Members can squish photos"
  ON public.photo_squishes FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND is_photo_member(auth.uid(), photo_id)
  );

CREATE POLICY "Users can unsquish (delete own squish)"
  ON public.photo_squishes FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Update Photo Comments Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view photo comments" ON public.photo_comments;
DROP POLICY IF EXISTS "Members can add photo comments" ON public.photo_comments;
DROP POLICY IF EXISTS "Users can update own photo comments" ON public.photo_comments;
DROP POLICY IF EXISTS "Users and owners can delete photo comments" ON public.photo_comments;

CREATE POLICY "Members can view photo comments"
  ON public.photo_comments FOR SELECT
  USING (
    is_photo_member(auth.uid(), photo_id)
    AND deleted_at IS NULL
  );

CREATE POLICY "Members can add photo comments"
  ON public.photo_comments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND is_photo_member(auth.uid(), photo_id)
  );

CREATE POLICY "Users and owners can update photo comments"
  ON public.photo_comments FOR UPDATE
  USING (
    auth.uid() = user_id
    OR is_photo_owner(auth.uid(), photo_id)
  );

CREATE POLICY "Users and owners can delete photo comments"
  ON public.photo_comments FOR DELETE
  USING (
    auth.uid() = user_id
    OR is_photo_owner(auth.uid(), photo_id)
  );

-- ========================================
-- Update Event RSVPs Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view event RSVPs" ON public.event_rsvps;
DROP POLICY IF EXISTS "Members can create RSVPs" ON public.event_rsvps;
DROP POLICY IF EXISTS "Users can update own RSVPs" ON public.event_rsvps;
DROP POLICY IF EXISTS "Users can delete own RSVPs" ON public.event_rsvps;

CREATE POLICY "Members can view event RSVPs"
  ON public.event_rsvps FOR SELECT
  USING (is_event_member(auth.uid(), event_id));

CREATE POLICY "Members can create RSVPs"
  ON public.event_rsvps FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND is_event_member(auth.uid(), event_id)
  );

CREATE POLICY "Users can update own RSVPs"
  ON public.event_rsvps FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own RSVPs"
  ON public.event_rsvps FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Update Registry Purchases Policies
-- ========================================

DROP POLICY IF EXISTS "Members can view registry purchases" ON public.registry_purchases;
DROP POLICY IF EXISTS "Members can mark items as purchased" ON public.registry_purchases;

CREATE POLICY "Members can view registry purchases"
  ON public.registry_purchases FOR SELECT
  USING (is_registry_item_member(auth.uid(), registry_item_id));

CREATE POLICY "Members can mark items as purchased"
  ON public.registry_purchases FOR INSERT
  WITH CHECK (
    auth.uid() = purchased_by_user_id
    AND is_registry_item_member(auth.uid(), registry_item_id)
  );

-- ========================================
-- Update User Stats Policies
-- ========================================

DROP POLICY IF EXISTS "Users in same baby profile can view stats" ON public.user_stats;

CREATE POLICY "Users in same baby profile can view stats"
  ON public.user_stats FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships bm1
      INNER JOIN public.baby_memberships bm2
        ON bm1.baby_profile_id = bm2.baby_profile_id
      WHERE bm1.user_id = auth.uid()
        AND bm2.user_id = user_stats.user_id
        AND bm1.removed_at IS NULL
        AND bm2.removed_at IS NULL
    )
  );
-- Migration: Fix all tile_configs RLS policies and permissions
-- Consolidates: 20260302000009 + 20260302000010 + 20260302000011 + 20260302000012
--
-- Tile_configs table requires special RLS handling to support test execution
-- and allow different user roles (authenticated, anon, postgres) appropriate access

-- ========================================
-- Drop Old Policies (if any exist)
-- ========================================

DROP POLICY IF EXISTS "Authenticated users can view tile configs for their role" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres superuser can access all tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Authenticated users can view visible tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Anonymous users cannot see tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can access all tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can insert tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can update tile configs" ON public.tile_configs;
DROP POLICY IF EXISTS "Postgres can delete tile configs" ON public.tile_configs;

-- ========================================
-- RLS Policies for tile_configs
-- ========================================

-- Authenticated users can view visible tile configs only
CREATE POLICY "Authenticated users can view visible tile configs"
  ON public.tile_configs FOR SELECT
  TO authenticated
  USING (is_visible = TRUE);

-- Anonymous users cannot see any tile configs (returns empty result set)
CREATE POLICY "Anonymous users cannot see tile configs"
  ON public.tile_configs FOR SELECT
  TO anon
  USING (FALSE);

-- Postgres role (test runner and admin) has full access for testing and administration
CREATE POLICY "Postgres can access all tile configs"
  ON public.tile_configs FOR SELECT
  TO postgres
  USING (TRUE);

CREATE POLICY "Postgres can insert tile configs"
  ON public.tile_configs FOR INSERT
  TO postgres
  WITH CHECK (TRUE);

CREATE POLICY "Postgres can update tile configs"
  ON public.tile_configs FOR UPDATE
  TO postgres
  USING (TRUE)
  WITH CHECK (TRUE);

CREATE POLICY "Postgres can delete tile configs"
  ON public.tile_configs FOR DELETE
  TO postgres
  USING (TRUE);

-- ========================================
-- Table-Level Permissions
-- ========================================

-- Ensure anon role has SELECT permission (required even with restrictive RLS policy)
GRANT SELECT ON public.tile_configs TO anon;
-- Migration: Fix baby_profiles RLS SELECT policy paradox
-- Adds a created_by column to baby_profiles and updates the SELECT policy 
-- to allow creators to read their newly inserted rows before the membership is created.

-- 1. Add created_by column defaulting to the inserting user's ID
ALTER TABLE public.baby_profiles 
ADD COLUMN IF NOT EXISTS created_by uuid DEFAULT auth.uid();

-- 2. Drop the old SELECT policy
DROP POLICY IF EXISTS "Members can view baby profiles" ON public.baby_profiles;

-- 3. Create the new SELECT policy that includes the created_by check
CREATE POLICY "Members can view baby profiles" ON public.baby_profiles FOR SELECT
USING (is_baby_member(auth.uid(), id) OR created_by = auth.uid());

-- 4. Fix baby_memberships SELECT policy paradox
DROP POLICY IF EXISTS "Members can view memberships for their babies" ON public.baby_memberships;

CREATE POLICY "Members can view memberships for their babies" ON public.baby_memberships FOR SELECT
USING (user_id = auth.uid() OR is_baby_member(auth.uid(), baby_profile_id));
