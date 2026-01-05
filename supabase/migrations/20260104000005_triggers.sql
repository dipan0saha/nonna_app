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
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.baby_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.photos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
-- ... (apply to all tables with updated_at)

-- ========================================
-- Update owner_update_markers on content changes
-- ========================================

CREATE OR REPLACE FUNCTION update_photo_marker()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.owner_update_markers
  SET last_updated_at = NOW(),
      photo_updated_at = NOW()
  WHERE baby_profile_id = COALESCE(NEW.baby_profile_id, OLD.baby_profile_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER photo_marker_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.photos
FOR EACH ROW EXECUTE FUNCTION update_photo_marker();

-- Similar triggers for events and registry items...

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
