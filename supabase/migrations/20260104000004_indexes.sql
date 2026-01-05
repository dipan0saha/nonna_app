-- Foreign key indexes (critical for joins)
CREATE INDEX idx_baby_memberships_baby_profile_id ON public.baby_memberships(baby_profile_id);
CREATE INDEX idx_baby_memberships_user_id ON public.baby_memberships(user_id);
CREATE INDEX idx_photos_baby_profile_id ON public.photos(baby_profile_id);
CREATE INDEX idx_photos_uploaded_by_user_id ON public.photos(uploaded_by_user_id);
CREATE INDEX idx_photo_comments_photo_id ON public.photo_comments(photo_id);
CREATE INDEX idx_photo_comments_user_id ON public.photo_comments(user_id);
CREATE INDEX idx_events_baby_profile_id ON public.events(baby_profile_id);
CREATE INDEX idx_registry_items_baby_profile_id ON public.registry_items(baby_profile_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- Composite indexes for common queries
CREATE INDEX idx_photos_baby_created ON public.photos(baby_profile_id, created_at DESC);
CREATE INDEX idx_events_baby_date ON public.events(baby_profile_id, event_date ASC);
CREATE INDEX idx_memberships_user_active ON public.baby_memberships(user_id, removed_at) WHERE removed_at IS NULL;

-- Partial indexes for filtered queries
CREATE INDEX idx_baby_profiles_active ON public.baby_profiles(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_invitations_pending ON public.invitations(baby_profile_id, status) WHERE status = 'pending';

-- GIN indexes for JSONB and array columns
CREATE INDEX idx_tile_configs_params ON public.tile_configs USING GIN (params);
CREATE INDEX idx_photos_tags ON public.photos USING GIN (tags);
