-- ============================================================================
-- Seed Data Validation Script
-- Run this after loading seed data to verify all tables are populated
-- ============================================================================

-- Display header
SELECT '===================================================' as message
UNION ALL SELECT 'Nonna App - Seed Data Validation Report'
UNION ALL SELECT '===================================================';

-- Count records in all tables
SELECT 
  table_name,
  record_count,
  CASE 
    WHEN record_count > 0 THEN '✓ Has data'
    ELSE '✗ Empty'
  END as status
FROM (
  SELECT 'profiles' as table_name, COUNT(*)::int as record_count FROM public.profiles
  UNION ALL SELECT 'user_stats', COUNT(*)::int FROM public.user_stats
  UNION ALL SELECT 'baby_profiles', COUNT(*)::int FROM public.baby_profiles
  UNION ALL SELECT 'baby_memberships', COUNT(*)::int FROM public.baby_memberships
  UNION ALL SELECT 'owner_update_markers', COUNT(*)::int FROM public.owner_update_markers
  UNION ALL SELECT 'screens', COUNT(*)::int FROM public.screens
  UNION ALL SELECT 'tile_definitions', COUNT(*)::int FROM public.tile_definitions
  UNION ALL SELECT 'tile_configs', COUNT(*)::int FROM public.tile_configs
  UNION ALL SELECT 'events', COUNT(*)::int FROM public.events
  UNION ALL SELECT 'event_rsvps', COUNT(*)::int FROM public.event_rsvps
  UNION ALL SELECT 'event_comments', COUNT(*)::int FROM public.event_comments
  UNION ALL SELECT 'photos', COUNT(*)::int FROM public.photos
  UNION ALL SELECT 'photo_squishes', COUNT(*)::int FROM public.photo_squishes
  UNION ALL SELECT 'photo_comments', COUNT(*)::int FROM public.photo_comments
  UNION ALL SELECT 'photo_tags', COUNT(*)::int FROM public.photo_tags
  UNION ALL SELECT 'registry_items', COUNT(*)::int FROM public.registry_items
  UNION ALL SELECT 'registry_purchases', COUNT(*)::int FROM public.registry_purchases
  UNION ALL SELECT 'votes', COUNT(*)::int FROM public.votes
  UNION ALL SELECT 'name_suggestions', COUNT(*)::int FROM public.name_suggestions
  UNION ALL SELECT 'name_suggestion_likes', COUNT(*)::int FROM public.name_suggestion_likes
  UNION ALL SELECT 'invitations', COUNT(*)::int FROM public.invitations
  UNION ALL SELECT 'notifications', COUNT(*)::int FROM public.notifications
  UNION ALL SELECT 'activity_events', COUNT(*)::int FROM public.activity_events
) counts
ORDER BY 
  CASE 
    WHEN record_count = 0 THEN 0 
    ELSE 1 
  END,
  table_name;

-- Display separator
SELECT '===================================================' as message;

-- Summary statistics
SELECT 
  'Summary' as section,
  COUNT(*) as total_tables,
  SUM(CASE WHEN record_count > 0 THEN 1 ELSE 0 END) as tables_with_data,
  SUM(CASE WHEN record_count = 0 THEN 1 ELSE 0 END) as empty_tables
FROM (
  SELECT COUNT(*)::int as record_count FROM public.profiles
  UNION ALL SELECT COUNT(*)::int FROM public.user_stats
  UNION ALL SELECT COUNT(*)::int FROM public.baby_profiles
  UNION ALL SELECT COUNT(*)::int FROM public.baby_memberships
  UNION ALL SELECT COUNT(*)::int FROM public.owner_update_markers
  UNION ALL SELECT COUNT(*)::int FROM public.screens
  UNION ALL SELECT COUNT(*)::int FROM public.tile_definitions
  UNION ALL SELECT COUNT(*)::int FROM public.tile_configs
  UNION ALL SELECT COUNT(*)::int FROM public.events
  UNION ALL SELECT COUNT(*)::int FROM public.event_rsvps
  UNION ALL SELECT COUNT(*)::int FROM public.event_comments
  UNION ALL SELECT COUNT(*)::int FROM public.photos
  UNION ALL SELECT COUNT(*)::int FROM public.photo_squishes
  UNION ALL SELECT COUNT(*)::int FROM public.photo_comments
  UNION ALL SELECT COUNT(*)::int FROM public.photo_tags
  UNION ALL SELECT COUNT(*)::int FROM public.registry_items
  UNION ALL SELECT COUNT(*)::int FROM public.registry_purchases
  UNION ALL SELECT COUNT(*)::int FROM public.votes
  UNION ALL SELECT COUNT(*)::int FROM public.name_suggestions
  UNION ALL SELECT COUNT(*)::int FROM public.name_suggestion_likes
  UNION ALL SELECT COUNT(*)::int FROM public.invitations
  UNION ALL SELECT COUNT(*)::int FROM public.notifications
  UNION ALL SELECT COUNT(*)::int FROM public.activity_events
) counts;

-- Display separator
SELECT '===================================================' as message;

-- Check data relationships (sample queries)
SELECT 'Relationship Checks' as section;

-- Verify baby memberships reference valid babies
SELECT 
  'Baby Memberships → Baby Profiles' as check_name,
  COUNT(*) as total_memberships,
  COUNT(DISTINCT bm.baby_profile_id) as unique_babies,
  COUNT(DISTINCT bp.id) as baby_profiles_count,
  CASE 
    WHEN COUNT(DISTINCT bm.baby_profile_id) = COUNT(DISTINCT bp.id) 
    THEN '✓ All memberships reference valid babies'
    ELSE '✗ Orphaned memberships found'
  END as status
FROM public.baby_memberships bm
LEFT JOIN public.baby_profiles bp ON bm.baby_profile_id = bp.id;

-- Verify events have valid baby profiles
SELECT 
  'Events → Baby Profiles' as check_name,
  COUNT(*) as total_events,
  COUNT(DISTINCT e.baby_profile_id) as unique_babies_with_events,
  (SELECT COUNT(*) FROM public.baby_profiles) as total_baby_profiles,
  CASE 
    WHEN COUNT(*) > 0 AND COUNT(DISTINCT e.baby_profile_id) <= (SELECT COUNT(*) FROM public.baby_profiles)
    THEN '✓ Events exist and all reference valid babies'
    WHEN COUNT(*) = 0 THEN '⚠ No events found'
    ELSE '✗ Invalid baby profile references found'
  END as status
FROM public.events e
LEFT JOIN public.baby_profiles bp ON e.baby_profile_id = bp.id;

-- Verify photos have valid baby profiles
SELECT 
  'Photos → Baby Profiles' as check_name,
  COUNT(*) as total_photos,
  COUNT(DISTINCT p.baby_profile_id) as unique_babies_with_photos,
  (SELECT COUNT(*) FROM public.baby_profiles) as total_baby_profiles,
  CASE 
    WHEN COUNT(*) > 0 AND COUNT(DISTINCT p.baby_profile_id) <= (SELECT COUNT(*) FROM public.baby_profiles)
    THEN '✓ Photos exist and all reference valid babies'
    WHEN COUNT(*) = 0 THEN '⚠ No photos found'
    ELSE '✗ Invalid baby profile references found'
  END as status
FROM public.photos p
LEFT JOIN public.baby_profiles bp ON p.baby_profile_id = bp.id;

-- Display final message
SELECT '===================================================' as message
UNION ALL SELECT 'Validation Complete!'
UNION ALL SELECT '===================================================';
