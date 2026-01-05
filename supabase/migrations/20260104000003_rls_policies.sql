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
-- Baby Profiles RLS Policies
-- ========================================

CREATE POLICY "Followers can view baby profiles"
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

CREATE POLICY "Owners can CRUD baby profiles"
  ON public.baby_profiles FOR ALL
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
-- Photos RLS Policies
-- ========================================

CREATE POLICY "Followers can view photos"
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

CREATE POLICY "Owners can CRUD photos"
  ON public.photos FOR ALL
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
-- Photo Comments RLS Policies
-- ========================================

CREATE POLICY "Followers can view photo comments"
  ON public.photo_comments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
    AND photo_comments.deleted_at IS NULL
  );

CREATE POLICY "Followers can add photo comments"
  ON public.photo_comments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.photos p
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = p.baby_profile_id
      WHERE p.id = photo_comments.photo_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

CREATE POLICY "Users can delete own comments"
  ON public.photo_comments FOR DELETE
  USING (auth.uid() = user_id);

-- ========================================
-- Events RLS Policies (Similar pattern to Photos)
-- ========================================

CREATE POLICY "Followers can view events"
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

CREATE POLICY "Owners can CRUD events"
  ON public.events FOR ALL
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
-- Registry Items RLS Policies
-- ========================================

CREATE POLICY "Followers can view registry items"
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

CREATE POLICY "Owners can CRUD registry items"
  ON public.registry_items FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.baby_memberships
      WHERE baby_memberships.baby_profile_id = registry_items.baby_profile_id
        AND baby_memberships.user_id = auth.uid()
        AND baby_memberships.role = 'owner'
        AND baby_memberships.removed_at IS NULL
    )
  );

CREATE POLICY "Followers can mark items as purchased"
  ON public.registry_purchases FOR INSERT
  WITH CHECK (
    auth.uid() = purchased_by_user_id
    AND EXISTS (
      SELECT 1 FROM public.registry_items ri
      INNER JOIN public.baby_memberships bm
        ON bm.baby_profile_id = ri.baby_profile_id
      WHERE ri.id = registry_purchases.registry_item_id
        AND bm.user_id = auth.uid()
        AND bm.removed_at IS NULL
    )
  );

-- ========================================
-- Notifications RLS Policies
-- ========================================

CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- ========================================
-- Apply similar RLS policies for remaining tables
-- (See docs/01_technical_requirements/data_model_diagram.md for complete policies)
-- ========================================
