SELECT
  (SELECT count(*) FROM profiles) as profiles_count,
  (SELECT count(*) FROM baby_profiles) as babies_count,
  (SELECT count(*) FROM baby_memberships) as memberships_count,
  (SELECT count(*) FROM photos) as photos_count,
  (SELECT count(*) FROM events) as events_count,
  (SELECT count(*) FROM event_rsvps) as rsvps_count,
  (SELECT count(*) FROM registry_items) as registry_items_count,
  (SELECT count(*) FROM registry_purchases) as registry_purchases_count,
  (SELECT count(*) FROM invitations) as invitations_count,
  (SELECT count(*) FROM notifications) as notifications_count,
  (SELECT count(*) FROM activity_events) as activity_count;
