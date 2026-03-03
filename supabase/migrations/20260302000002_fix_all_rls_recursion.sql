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

CREATE POLICY "Users can update own photo comments"
  ON public.photo_comments FOR UPDATE
  USING (auth.uid() = user_id);

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
