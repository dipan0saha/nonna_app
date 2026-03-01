-- Foreign key indexes (critical for joins)
CREATE INDEX idx_baby_memberships_baby_profile_id ON public.baby_memberships(baby_profile_id);
CREATE INDEX idx_baby_memberships_user_id ON public.baby_memberships(user_id);
CREATE INDEX idx_photos_baby_profile_id ON public.photos(baby_profile_id);
CREATE INDEX idx_photos_uploaded_by_user_id ON public.photos(uploaded_by_user_id);
CREATE INDEX idx_photo_comments_photo_id ON public.photo_comments(photo_id);
CREATE INDEX idx_photo_comments_user_id ON public.photo_comments(user_id);
CREATE INDEX idx_photo_tags_photo_id ON public.photo_tags(photo_id);
CREATE INDEX idx_events_baby_profile_id ON public.events(baby_profile_id);
CREATE INDEX idx_event_comments_event_id ON public.event_comments(event_id);
CREATE INDEX idx_event_rsvps_event_id ON public.event_rsvps(event_id);
CREATE INDEX idx_registry_items_baby_profile_id ON public.registry_items(baby_profile_id);
CREATE INDEX idx_registry_purchases_item_id ON public.registry_purchases(registry_item_id);
CREATE INDEX idx_votes_baby_profile_id ON public.votes(baby_profile_id);
CREATE INDEX idx_votes_user_id ON public.votes(user_id);
CREATE INDEX idx_name_suggestions_baby_profile_id ON public.name_suggestions(baby_profile_id);
CREATE INDEX idx_name_suggestion_likes_suggestion_id ON public.name_suggestion_likes(name_suggestion_id);
CREATE INDEX idx_notifications_recipient_user_id ON public.notifications(recipient_user_id);
CREATE INDEX idx_invitations_token_hash ON public.invitations(token_hash);

-- Composite indexes for common queries
CREATE INDEX idx_photos_baby_created ON public.photos(baby_profile_id, created_at DESC);
CREATE INDEX idx_events_baby_starts_at ON public.events(baby_profile_id, starts_at ASC);
CREATE INDEX idx_memberships_user_active ON public.baby_memberships(user_id, removed_at) WHERE removed_at IS NULL;
CREATE INDEX idx_notifications_unread ON public.notifications(recipient_user_id, created_at DESC) WHERE read_at IS NULL;

-- Partial indexes for filtered queries
CREATE INDEX idx_baby_profiles_active ON public.baby_profiles(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_invitations_pending ON public.invitations(baby_profile_id, status) WHERE status = 'pending';
CREATE INDEX idx_photos_active ON public.photos(baby_profile_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_events_active ON public.events(baby_profile_id, starts_at) WHERE deleted_at IS NULL;

-- GIN indexes for JSONB and array columns
CREATE INDEX idx_tile_configs_params ON public.tile_configs USING GIN (params);
CREATE INDEX idx_photos_tags ON public.photos USING GIN (tags);

-- Activity events indexes
CREATE INDEX idx_activity_events_baby_profile ON public.activity_events(baby_profile_id);
CREATE INDEX idx_activity_events_created_at ON public.activity_events(created_at DESC);
