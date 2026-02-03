-- Custom Monitoring Queries for Supabase
-- These queries provide insights into application performance, usage, and health

-- ============================================
-- 1. Database Performance Metrics
-- ============================================

-- Query Performance: Slow queries
-- Run this to identify queries taking longer than 1 second
-- Usage: SELECT * FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 20;

-- Table Size and Growth
CREATE OR REPLACE VIEW monitoring_table_sizes AS
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_total_relation_size(schemaname||'.'||tablename) AS size_bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index Usage Statistics
CREATE OR REPLACE VIEW monitoring_index_usage AS
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- ============================================
-- 2. Business Metrics
-- ============================================

-- Active Baby Profiles Count
CREATE OR REPLACE VIEW monitoring_active_baby_profiles AS
SELECT
  COUNT(DISTINCT id) as total_profiles,
  COUNT(DISTINCT id) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days') as new_this_month,
  COUNT(DISTINCT id) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as new_this_week
FROM baby_profiles
WHERE deleted_at IS NULL;

-- User Activity Statistics
CREATE OR REPLACE VIEW monitoring_user_activity AS
SELECT
  COUNT(DISTINCT id) as total_users,
  COUNT(DISTINCT id) FILTER (WHERE last_sign_in_at >= NOW() - INTERVAL '24 hours') as daily_active_users,
  COUNT(DISTINCT id) FILTER (WHERE last_sign_in_at >= NOW() - INTERVAL '7 days') as weekly_active_users,
  COUNT(DISTINCT id) FILTER (WHERE last_sign_in_at >= NOW() - INTERVAL '30 days') as monthly_active_users
FROM auth.users;

-- Photo Upload Statistics
CREATE OR REPLACE VIEW monitoring_photo_uploads AS
SELECT
  COUNT(*) as total_photos,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '24 hours') as uploads_24h,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as uploads_7d,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days') as uploads_30d,
  pg_size_pretty(SUM(file_size)) as total_storage_used
FROM photos
WHERE deleted_at IS NULL;

-- Event Statistics
CREATE OR REPLACE VIEW monitoring_events AS
SELECT
  COUNT(*) as total_events,
  COUNT(*) FILTER (WHERE event_date >= CURRENT_DATE) as upcoming_events,
  COUNT(*) FILTER (WHERE event_date < CURRENT_DATE) as past_events,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as created_this_week
FROM events
WHERE deleted_at IS NULL;

-- ============================================
-- 3. Tile Performance Queries
-- ============================================

-- Tile Configuration Usage
CREATE OR REPLACE VIEW monitoring_tile_configs AS
SELECT
  tile_type,
  COUNT(*) as usage_count,
  COUNT(*) FILTER (WHERE is_visible = true) as visible_count,
  COUNT(*) FILTER (WHERE is_locked = true) as locked_count,
  AVG(position) as avg_position
FROM tile_configs
GROUP BY tile_type
ORDER BY usage_count DESC;

-- Most Popular Tiles by Screen
CREATE OR REPLACE VIEW monitoring_popular_tiles AS
SELECT
  screen_name,
  tile_type,
  COUNT(*) as instances,
  AVG(position) as avg_position
FROM tile_configs
WHERE is_visible = true
GROUP BY screen_name, tile_type
ORDER BY screen_name, instances DESC;

-- ============================================
-- 4. Cache Hit Rate Queries
-- ============================================

-- Realtime Connection Statistics
-- Note: This would be tracked via application logs
-- Monitor: Active connections, subscription counts, reconnection rate

-- ============================================
-- 5. Error Rate Queries
-- ============================================

-- Failed Authentication Attempts (Last 24 hours)
-- Note: This requires audit logging to be enabled
-- Monitor via auth.audit_log_entries if available

-- Failed API Requests by Endpoint
-- Note: Track this via Edge Function logs and application monitoring

-- ============================================
-- 6. Storage Metrics
-- ============================================

-- Storage Usage by Bucket
CREATE OR REPLACE VIEW monitoring_storage_usage AS
SELECT
  bucket_id,
  COUNT(*) as file_count,
  pg_size_pretty(SUM((metadata->>'size')::bigint)) as total_size,
  SUM((metadata->>'size')::bigint) as total_size_bytes
FROM storage.objects
GROUP BY bucket_id
ORDER BY total_size_bytes DESC;

-- Storage Growth Rate (Last 30 days)
CREATE OR REPLACE VIEW monitoring_storage_growth AS
SELECT
  DATE(created_at) as upload_date,
  COUNT(*) as files_uploaded,
  pg_size_pretty(SUM((metadata->>'size')::bigint)) as size_added
FROM storage.objects
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY upload_date DESC;

-- ============================================
-- 7. Notification Metrics
-- ============================================

-- Notification Delivery Statistics
CREATE OR REPLACE VIEW monitoring_notifications AS
SELECT
  notification_type,
  COUNT(*) as total_sent,
  COUNT(*) FILTER (WHERE is_read = true) as read_count,
  COUNT(*) FILTER (WHERE is_read = false) as unread_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_read = true) / COUNT(*), 2) as read_rate_pct
FROM notifications
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY notification_type
ORDER BY total_sent DESC;

-- ============================================
-- 8. Registry Performance
-- ============================================

-- Registry Item Statistics
CREATE OR REPLACE VIEW monitoring_registry_items AS
SELECT
  COUNT(*) as total_items,
  COUNT(*) FILTER (WHERE is_purchased = true) as purchased_items,
  COUNT(*) FILTER (WHERE is_purchased = false) as available_items,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_purchased = true) / COUNT(*), 2) as purchase_rate_pct,
  SUM(price) as total_value,
  SUM(price) FILTER (WHERE is_purchased = true) as purchased_value
FROM registry_items
WHERE deleted_at IS NULL;

-- ============================================
-- 9. Engagement Metrics
-- ============================================

-- Comment Activity
CREATE OR REPLACE VIEW monitoring_comments AS
SELECT
  'photo_comments' as comment_type,
  COUNT(*) as total_comments,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '24 hours') as comments_24h
FROM photo_comments
WHERE deleted_at IS NULL
UNION ALL
SELECT
  'event_comments' as comment_type,
  COUNT(*) as total_comments,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '24 hours') as comments_24h
FROM event_comments
WHERE deleted_at IS NULL;

-- Like/Reaction Activity
CREATE OR REPLACE VIEW monitoring_reactions AS
SELECT
  COUNT(*) as total_squishes,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '24 hours') as squishes_24h,
  COUNT(DISTINCT photo_id) as unique_photos_squished,
  COUNT(DISTINCT user_id) as unique_users_squishing
FROM photo_squishes;

-- ============================================
-- 10. Alert Thresholds (For Monitoring Dashboard)
-- ============================================

-- Critical Alerts Query
-- Run this to check for conditions requiring immediate attention
SELECT
  'Large table size' as alert_type,
  tablename as detail,
  pg_size_pretty(pg_total_relation_size('public.'||tablename)) as value
FROM pg_tables
WHERE schemaname = 'public'
  AND pg_total_relation_size('public.'||tablename) > 1073741824 -- 1GB
UNION ALL
SELECT
  'High unread notification count' as alert_type,
  notification_type as detail,
  COUNT(*)::text as value
FROM notifications
WHERE is_read = false
  AND created_at < NOW() - INTERVAL '7 days'
GROUP BY notification_type
HAVING COUNT(*) > 1000;

-- ============================================
-- Usage Instructions
-- ============================================

/*
To use these monitoring queries:

1. Views are automatically created and can be queried:
   SELECT * FROM monitoring_active_baby_profiles;

2. For real-time monitoring, set up scheduled queries in Supabase:
   - Go to SQL Editor in Supabase Studio
   - Save these as snippets for quick access
   - Schedule critical queries to run periodically

3. Dashboard Integration:
   - Use these views in Supabase Studio dashboards
   - Export data to external monitoring tools (Grafana, DataDog, etc.)
   - Set up alerts based on threshold queries

4. Performance Optimization:
   - If views are slow, consider materializing them
   - Add appropriate indexes based on query patterns
   - Monitor view refresh times

5. Custom Metrics:
   - Extend these queries for application-specific needs
   - Add time-series tracking for trend analysis
   - Implement caching for expensive aggregations
*/
