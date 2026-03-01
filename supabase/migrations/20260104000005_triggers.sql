-- ========================================
-- Auto-update updated_at timestamp
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_stats FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_memberships FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.invitations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.photos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.event_rsvps FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.registry_items FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.votes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.name_suggestions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.notification_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.tile_configs FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================================
-- Update owner_update_markers on content changes
-- ========================================

CREATE OR REPLACE FUNCTION update_photo_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'photo_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER photo_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.photos
FOR EACH ROW EXECUTE FUNCTION update_photo_marker();

CREATE OR REPLACE FUNCTION update_event_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'event_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_event_marker();

CREATE OR REPLACE FUNCTION update_registry_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET tiles_last_updated_at = NOW(),
      reason = 'registry_updated'
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registry_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.registry_items
FOR EACH ROW EXECUTE FUNCTION update_registry_marker();

-- ========================================
-- Enforce max 2 owners per baby profile
-- ========================================

CREATE OR REPLACE FUNCTION enforce_max_two_owners()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'owner' AND NEW.removed_at IS NULL THEN
    IF (SELECT COUNT(*) FROM public.baby_memberships
        WHERE baby_profile_id = NEW.baby_profile_id
        AND role = 'owner'
        AND removed_at IS NULL) >= 2 THEN
      RAISE EXCEPTION 'Maximum two owners allowed per baby profile';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_owners
BEFORE INSERT OR UPDATE ON public.baby_memberships
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_owners();

-- ========================================
-- Enforce max 2 events per day per baby profile
-- ========================================

CREATE OR REPLACE FUNCTION enforce_max_two_events_per_day()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM public.events
      WHERE baby_profile_id = NEW.baby_profile_id
      AND DATE(starts_at) = DATE(NEW.starts_at)
      AND deleted_at IS NULL
      AND id != NEW.id) >= 2 THEN
    RAISE EXCEPTION 'Maximum two events per day allowed per baby profile';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_events_per_day
BEFORE INSERT OR UPDATE ON public.events
FOR EACH ROW EXECUTE FUNCTION enforce_max_two_events_per_day();

-- ========================================
-- Increment user_stats counters
-- ========================================

-- Increment events_attended_count on 'yes' RSVP
CREATE OR REPLACE FUNCTION increment_events_attended()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'yes' AND (TG_OP = 'INSERT' OR OLD.status != 'yes') THEN
    UPDATE public.user_stats
    SET events_attended_count = events_attended_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_event_rsvp
AFTER INSERT OR UPDATE ON public.event_rsvps
FOR EACH ROW EXECUTE FUNCTION increment_events_attended();

-- Increment items_purchased_count on registry purchase
CREATE OR REPLACE FUNCTION increment_items_purchased()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET items_purchased_count = items_purchased_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.purchased_by_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_registry_purchase
AFTER INSERT ON public.registry_purchases
FOR EACH ROW EXECUTE FUNCTION increment_items_purchased();

-- Increment photos_squished_count on photo squish
CREATE OR REPLACE FUNCTION increment_photos_squished()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET photos_squished_count = photos_squished_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_squish
AFTER INSERT ON public.photo_squishes
FOR EACH ROW EXECUTE FUNCTION increment_photos_squished();

-- Increment comments_added_count on photo comment
CREATE OR REPLACE FUNCTION increment_comments_added()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.user_stats
  SET comments_added_count = comments_added_count + 1,
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER count_photo_comment
AFTER INSERT ON public.photo_comments
FOR EACH ROW EXECUTE FUNCTION increment_comments_added();
