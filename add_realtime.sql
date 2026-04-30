BEGIN;
  -- Drop current to be safe
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime;

  -- Add tables
  ALTER PUBLICATION supabase_realtime ADD TABLE 
    user_stats,
    photos,
    photo_squishes,
    events,
    votes,
    name_suggestions,
    name_suggestion_likes,
    activity_events,
    app_versions,
    event_comments,
    event_rsvps,
    photo_comments,
    photo_tags,
    notification_preferences,
    invitations,
    owner_update_markers,
    registry_items,
    registry_purchases,
    profiles,
    screens,
    tile_definitions,
    notifications,
    tile_configs,
    baby_memberships,
    baby_profiles;
COMMIT;
