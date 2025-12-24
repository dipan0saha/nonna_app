-- ============================================================================
-- Nonna App - Database Triggers and Functions
-- Version: 1.0.0
-- Target: PostgreSQL 15+ (Supabase Managed)
-- Description: Automated triggers for profile creation, timestamps, and cache invalidation
-- ============================================================================

-- ============================================================================
-- SECTION 1: Auto-Create Profile on User Signup
-- ============================================================================

-- Function: Create profile when new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert profile for new auth user
    INSERT INTO public.profiles (user_id, display_name, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NOW(),
        NOW()
    );
    
    -- Insert initial user stats
    INSERT INTO public.user_stats (user_id, updated_at)
    VALUES (NEW.id, NOW());
    
    RETURN NEW;
END;
$$;

-- Trigger: Execute handle_new_user after auth.users insert
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates profile and stats when new user signs up via Supabase Auth';

-- ============================================================================
-- SECTION 2: Auto-Update Timestamps
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Apply update_updated_at trigger to all relevant tables
CREATE TRIGGER set_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_user_stats
    BEFORE UPDATE ON public.user_stats
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_baby_profiles
    BEFORE UPDATE ON public.baby_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_baby_memberships
    BEFORE UPDATE ON public.baby_memberships
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_invitations
    BEFORE UPDATE ON public.invitations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_tile_configs
    BEFORE UPDATE ON public.tile_configs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_events
    BEFORE UPDATE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_event_rsvps
    BEFORE UPDATE ON public.event_rsvps
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_registry_items
    BEFORE UPDATE ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_photos
    BEFORE UPDATE ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_votes
    BEFORE UPDATE ON public.votes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_updated_at_name_suggestions
    BEFORE UPDATE ON public.name_suggestions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

COMMENT ON FUNCTION public.update_updated_at_column() IS 'Auto-updates updated_at timestamp on row modification';

-- ============================================================================
-- SECTION 3: Owner Update Marker Management
-- ============================================================================

-- Function: Create owner update marker on baby profile creation
CREATE OR REPLACE FUNCTION public.create_owner_update_marker()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Create initial marker for new baby profile
    INSERT INTO public.owner_update_markers (baby_profile_id, tiles_last_updated_at, reason)
    VALUES (NEW.id, NOW(), 'baby_profile_created');
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_baby_profile_created
    AFTER INSERT ON public.baby_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.create_owner_update_marker();

COMMENT ON FUNCTION public.create_owner_update_marker() IS 'Creates cache invalidation marker when baby profile is created';

-- Function: Update owner marker on content changes
CREATE OR REPLACE FUNCTION public.update_owner_marker()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_reason text;
BEGIN
    -- Determine baby_profile_id and reason based on table
    IF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'event_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'photo_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'registry_items' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_reason := 'registry_item_' || TG_OP;
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_reason := 'registry_purchase_' || TG_OP;
    ELSE
        RETURN NEW;
    END IF;
    
    -- Update marker timestamp
    UPDATE public.owner_update_markers
    SET tiles_last_updated_at = NOW(),
        updated_by_user_id = auth.uid(),
        reason = v_reason
    WHERE baby_profile_id = v_baby_profile_id;
    
    RETURN NEW;
END;
$$;

-- Apply marker update triggers to content tables
CREATE TRIGGER update_marker_on_event_change
    AFTER INSERT OR UPDATE OR DELETE ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_photo_change
    AFTER INSERT OR UPDATE OR DELETE ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_registry_item_change
    AFTER INSERT OR UPDATE OR DELETE ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

CREATE TRIGGER update_marker_on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.update_owner_marker();

COMMENT ON FUNCTION public.update_owner_marker() IS 'Updates cache invalidation marker when owners modify content';

-- ============================================================================
-- SECTION 4: User Stats Update Triggers
-- ============================================================================

-- Function: Increment events attended count
CREATE OR REPLACE FUNCTION public.increment_events_attended()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only count 'yes' RSVPs
    IF NEW.status = 'yes' THEN
        UPDATE public.user_stats
        SET events_attended_count = events_attended_count + 1,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_event_rsvp_yes
    AFTER INSERT OR UPDATE ON public.event_rsvps
    FOR EACH ROW
    WHEN (NEW.status = 'yes')
    EXECUTE FUNCTION public.increment_events_attended();

-- Function: Increment items purchased count
CREATE OR REPLACE FUNCTION public.increment_items_purchased()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET items_purchased_count = items_purchased_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.purchased_by_user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_items_purchased();

-- Function: Increment photos squished count
CREATE OR REPLACE FUNCTION public.increment_photos_squished()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET photos_squished_count = photos_squished_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_photo_squish
    AFTER INSERT ON public.photo_squishes
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_photos_squished();

-- Function: Increment comments added count
CREATE OR REPLACE FUNCTION public.increment_comments_added()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.user_stats
    SET comments_added_count = comments_added_count + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_event_comment
    AFTER INSERT ON public.event_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_comments_added();

CREATE TRIGGER on_photo_comment
    AFTER INSERT ON public.photo_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.increment_comments_added();

COMMENT ON FUNCTION public.increment_events_attended() IS 'Updates user stats when RSVP changes to yes';
COMMENT ON FUNCTION public.increment_items_purchased() IS 'Updates user stats when registry item purchased';
COMMENT ON FUNCTION public.increment_photos_squished() IS 'Updates user stats when photo squished';
COMMENT ON FUNCTION public.increment_comments_added() IS 'Updates user stats when comment added';

-- ============================================================================
-- SECTION 5: Activity Event Logging
-- ============================================================================

-- Function: Log activity events
CREATE OR REPLACE FUNCTION public.log_activity_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_type text;
    v_payload jsonb;
BEGIN
    -- Determine activity type and payload based on table
    IF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'photo_uploaded';
        v_payload := jsonb_build_object('photo_id', NEW.id, 'caption', NEW.caption);
        
    ELSIF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'event_created';
        v_payload := jsonb_build_object('event_id', NEW.id, 'title', NEW.title);
        
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_type := 'item_purchased';
        v_payload := jsonb_build_object('registry_item_id', NEW.registry_item_id);
        
    ELSIF TG_TABLE_NAME = 'event_comments' THEN
        -- Get baby_profile_id from events
        SELECT e.baby_profile_id INTO v_baby_profile_id
        FROM public.events e
        WHERE e.id = NEW.event_id;
        v_type := 'comment_added';
        v_payload := jsonb_build_object('event_id', NEW.event_id, 'comment_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'photo_comments' THEN
        -- Get baby_profile_id from photos
        SELECT p.baby_profile_id INTO v_baby_profile_id
        FROM public.photos p
        WHERE p.id = NEW.photo_id;
        v_type := 'comment_added';
        v_payload := jsonb_build_object('photo_id', NEW.photo_id, 'comment_id', NEW.id);
        
    ELSE
        RETURN NEW;
    END IF;
    
    -- Insert activity event
    INSERT INTO public.activity_events (baby_profile_id, actor_user_id, type, payload)
    VALUES (v_baby_profile_id, auth.uid(), v_type, v_payload);
    
    RETURN NEW;
END;
$$;

-- Apply activity logging triggers
CREATE TRIGGER log_photo_activity
    AFTER INSERT ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_event_activity
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_purchase_activity
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_event_comment_activity
    AFTER INSERT ON public.event_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

CREATE TRIGGER log_photo_comment_activity
    AFTER INSERT ON public.photo_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.log_activity_event();

COMMENT ON FUNCTION public.log_activity_event() IS 'Logs significant actions to activity_events for Recent Activity tiles';

-- ============================================================================
-- SECTION 6: Notification Triggers
-- ============================================================================

-- Constant for null UUID (used when actor is unknown)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'null_uuid') THEN
        CREATE FUNCTION public.null_uuid() RETURNS uuid AS
        'SELECT ''00000000-0000-0000-0000-000000000000''::uuid;'
        LANGUAGE SQL IMMUTABLE;
    END IF;
END
$$;

-- Function: Create notifications for new content
CREATE OR REPLACE FUNCTION public.create_content_notifications()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_baby_profile_id uuid;
    v_type text;
    v_payload jsonb;
    v_recipient record;
BEGIN
    -- Determine notification type and payload
    IF TG_TABLE_NAME = 'photos' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'photo_added';
        v_payload := jsonb_build_object('photo_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'events' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'event_created';
        v_payload := jsonb_build_object('event_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'registry_items' THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'registry_item_added';
        v_payload := jsonb_build_object('registry_item_id', NEW.id);
        
    ELSIF TG_TABLE_NAME = 'registry_purchases' THEN
        -- Get baby_profile_id from registry_items
        SELECT ri.baby_profile_id INTO v_baby_profile_id
        FROM public.registry_items ri
        WHERE ri.id = NEW.registry_item_id;
        v_type := 'registry_item_purchased';
        v_payload := jsonb_build_object('registry_item_id', NEW.registry_item_id, 'purchased_by', NEW.purchased_by_user_id);
        
    ELSIF TG_TABLE_NAME = 'event_rsvps' THEN
        -- Get baby_profile_id from events
        SELECT e.baby_profile_id INTO v_baby_profile_id
        FROM public.events e
        WHERE e.id = NEW.event_id;
        v_type := 'event_rsvp';
        v_payload := jsonb_build_object('event_id', NEW.event_id, 'user_id', NEW.user_id, 'status', NEW.status);
        
    ELSIF TG_TABLE_NAME = 'baby_memberships' AND NEW.removed_at IS NULL THEN
        v_baby_profile_id := NEW.baby_profile_id;
        v_type := 'new_follower';
        v_payload := jsonb_build_object('user_id', NEW.user_id, 'relationship', NEW.relationship_label);
        
    ELSE
        RETURN NEW;
    END IF;
    
    -- Create notifications for all members (excluding actor)
    FOR v_recipient IN
        SELECT DISTINCT user_id
        FROM public.baby_memberships
        WHERE baby_profile_id = v_baby_profile_id
          AND removed_at IS NULL
          AND user_id != COALESCE(auth.uid(), public.null_uuid())
    LOOP
        INSERT INTO public.notifications (recipient_user_id, baby_profile_id, type, payload)
        VALUES (v_recipient.user_id, v_baby_profile_id, v_type, v_payload);
    END LOOP;
    
    RETURN NEW;
END;
$$;

-- Apply notification triggers
CREATE TRIGGER notify_on_photo_upload
    AFTER INSERT ON public.photos
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_event_creation
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_registry_item_added
    AFTER INSERT ON public.registry_items
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_registry_purchase
    AFTER INSERT ON public.registry_purchases
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_event_rsvp
    AFTER INSERT OR UPDATE ON public.event_rsvps
    FOR EACH ROW
    EXECUTE FUNCTION public.create_content_notifications();

CREATE TRIGGER notify_on_new_follower
    AFTER INSERT ON public.baby_memberships
    FOR EACH ROW
    WHEN (NEW.removed_at IS NULL AND NEW.role = 'follower')
    EXECUTE FUNCTION public.create_content_notifications();

COMMENT ON FUNCTION public.create_content_notifications() IS 'Creates in-app notifications for significant events';

-- ============================================================================
-- SECTION 7: Constraint Enforcement via Triggers
-- ============================================================================

-- Function: Enforce max 2 owners per baby profile
CREATE OR REPLACE FUNCTION public.check_max_owners()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_owner_count int;
BEGIN
    -- Only check for owner role insertions
    IF NEW.role = 'owner' AND NEW.removed_at IS NULL THEN
        SELECT COUNT(*)
        INTO v_owner_count
        FROM public.baby_memberships
        WHERE baby_profile_id = NEW.baby_profile_id
          AND role = 'owner'
          AND removed_at IS NULL
          AND id != NEW.id; -- Exclude current row for updates
        
        IF v_owner_count >= 2 THEN
            RAISE EXCEPTION 'Maximum 2 owners allowed per baby profile';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_max_owners
    BEFORE INSERT OR UPDATE ON public.baby_memberships
    FOR EACH ROW
    EXECUTE FUNCTION public.check_max_owners();

COMMENT ON FUNCTION public.check_max_owners() IS 'Enforces maximum 2 owners per baby profile requirement';

-- Function: Validate invitation expiry
CREATE OR REPLACE FUNCTION public.validate_invitation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Auto-expire invitations past expiration date
    IF NEW.expires_at < NOW() AND NEW.status = 'pending' THEN
        NEW.status := 'expired';
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER check_invitation_expiry
    BEFORE INSERT OR UPDATE ON public.invitations
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_invitation();

COMMENT ON FUNCTION public.validate_invitation() IS 'Auto-expires invitations past 7-day expiration';

-- ============================================================================
-- END OF TRIGGERS AND FUNCTIONS SCRIPT
-- ============================================================================
