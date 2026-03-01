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

CREATE POLICY "Users can update own photo comments"
  ON public.photo_comments FOR UPDATE
  USING (auth.uid() = user_id);

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

