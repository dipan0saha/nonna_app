# Supabase Monitoring Guide

## Overview

This guide provides comprehensive information on monitoring your Nonna app's Supabase backend, including database performance, API usage, storage metrics, and real-time connection statistics.

## Table of Contents

1. [Monitoring Dashboard Setup](#monitoring-dashboard-setup)
2. [Built-in Supabase Monitoring](#built-in-supabase-monitoring)
3. [Custom Monitoring Queries](#custom-monitoring-queries)
4. [Alert Configuration](#alert-configuration)
5. [Performance Benchmarks](#performance-benchmarks)
6. [Troubleshooting](#troubleshooting)

---

## Monitoring Dashboard Setup

### Accessing Supabase Studio

1. Navigate to your Supabase project dashboard at [https://supabase.com](https://supabase.com)
2. Select your project
3. Access monitoring sections from the left sidebar

### Key Dashboard Sections

- **Database**: Query performance, connection pools, table statistics
- **API**: Request volume, response times, error rates
- **Storage**: Bucket usage, file counts, bandwidth
- **Auth**: Sign-up/sign-in metrics, active users
- **Realtime**: Active connections, message throughput

---

## Built-in Supabase Monitoring

### 1. Database Performance

**Location**: Database → Performance

**Metrics Available**:
- Query execution times
- Most expensive queries
- Index usage statistics
- Connection pool utilization
- Cache hit rates

**How to Use**:
```sql
-- View slow queries
SELECT * FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 20;

-- Check active queries
SELECT pid, query, state, query_start
FROM pg_stat_activity
WHERE state != 'idle';
```

### 2. API Analytics

**Location**: API → Usage & Logs

**Metrics Available**:
- Request volume by endpoint
- Response time percentiles (p50, p95, p99)
- Error rates and types
- Geographic distribution

**Alert Thresholds**:
- ⚠️ Warning: Response time > 500ms
- 🚨 Critical: Response time > 1s or error rate > 5%

### 3. Storage Metrics

**Location**: Storage → Usage

**Metrics Available**:
- Total storage used per bucket
- File upload/download counts
- Bandwidth consumption
- Storage growth rate

**Best Practices**:
- Monitor photo bucket size (largest bucket)
- Set up alerts for 80% storage capacity
- Review file retention policies regularly

### 4. Realtime Connection Stats

**Location**: Realtime → Connections

**Metrics Available**:
- Active WebSocket connections
- Subscription counts by channel
- Message throughput
- Reconnection rates

**Performance Targets**:
- Connection latency: < 100ms
- Message delivery: < 2s
- Reconnection time: < 5s

---

## Custom Monitoring Queries

Custom SQL queries are available in `supabase/monitoring/queries.sql`.

### Quick Start

1. Open Supabase SQL Editor
2. Load queries from `monitoring/queries.sql`
3. Execute views to access metrics

### Available Views

#### Business Metrics

```sql
-- Active baby profiles
SELECT * FROM monitoring_active_baby_profiles;

-- User activity (DAU, WAU, MAU)
SELECT * FROM monitoring_user_activity;

-- Photo upload statistics
SELECT * FROM monitoring_photo_uploads;

-- Event statistics
SELECT * FROM monitoring_events;
```

#### Performance Metrics

```sql
-- Table sizes and growth
SELECT * FROM monitoring_table_sizes;

-- Index usage efficiency
SELECT * FROM monitoring_index_usage;

-- Tile configuration usage
SELECT * FROM monitoring_tile_configs;

-- Popular tiles by screen
SELECT * FROM monitoring_popular_tiles;
```

#### Storage Metrics

```sql
-- Storage usage by bucket
SELECT * FROM monitoring_storage_usage;

-- Storage growth over time
SELECT * FROM monitoring_storage_growth;
```

#### Engagement Metrics

```sql
-- Notification delivery stats
SELECT * FROM monitoring_notifications;

-- Comment activity
SELECT * FROM monitoring_comments;

-- Like/reaction activity
SELECT * FROM monitoring_reactions;

-- Registry performance
SELECT * FROM monitoring_registry_items;
```

### Scheduling Queries

Set up automatic query execution for regular monitoring:

1. Go to SQL Editor → Scheduled Queries
2. Create new scheduled query
3. Set execution frequency (hourly, daily, weekly)
4. Configure notification recipients

---

## Alert Configuration

### Critical Alerts

Configure alerts for critical thresholds:

#### Database Alerts
- **Table size > 1GB**: Review partitioning strategy
- **Connection pool > 80%**: Scale database tier
- **Query time > 5s**: Optimize queries or add indexes

#### Application Alerts
- **Unread notifications > 1000**: Check notification system
- **Failed auth attempts > 100/hour**: Potential security issue
- **Storage > 80% capacity**: Plan storage expansion

### Setting Up Alerts

**Via Supabase Dashboard**:
1. Navigate to Monitoring → Alerts
2. Click "Create Alert"
3. Select metric and threshold
4. Configure notification channels (email, Slack, webhook)

**Via Custom Queries**:
```sql
-- Run alert threshold query
SELECT * FROM (
  SELECT 'Large table size' as alert_type, tablename, 
         pg_size_pretty(pg_total_relation_size('public.'||tablename)) as value
  FROM pg_tables
  WHERE schemaname = 'public'
    AND pg_total_relation_size('public.'||tablename) > 1073741824
) alerts;
```

---

## Performance Benchmarks

### Target Metrics

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| API Response Time | < 200ms | > 500ms | > 1s |
| Database Query Time | < 100ms | > 500ms | > 1s |
| Edge Function Latency | < 100ms | > 200ms | > 500ms |
| Realtime Message Delivery | < 2s | > 5s | > 10s |
| Storage Upload Speed | > 1MB/s | < 500KB/s | < 100KB/s |

### Monitoring Best Practices

1. **Regular Reviews**: Check metrics daily
2. **Trend Analysis**: Monitor week-over-week growth
3. **Capacity Planning**: Project resource needs 3-6 months ahead
4. **Performance Baselines**: Establish normal operating ranges
5. **Incident Response**: Define escalation procedures

---

## Troubleshooting

### Common Issues

#### Slow Query Performance

**Symptoms**:
- API response times increasing
- User reports of lag
- High database CPU usage

**Investigation**:
```sql
-- Identify slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 1000  -- Queries taking > 1s
ORDER BY mean_exec_time DESC;

-- Check missing indexes
SELECT schemaname, tablename, attname, null_frac, avg_width, n_distinct
FROM pg_stats
WHERE schemaname = 'public'
  AND null_frac > 0.5;  -- High null percentage might need index
```

**Solutions**:
- Add appropriate indexes
- Optimize query structure
- Consider materialized views for complex aggregations

#### High Storage Usage

**Symptoms**:
- Storage alerts firing
- Upload failures
- Increased costs

**Investigation**:
```sql
-- Check storage usage
SELECT * FROM monitoring_storage_usage;

-- Find large files
SELECT bucket_id, name, (metadata->>'size')::bigint as size
FROM storage.objects
ORDER BY (metadata->>'size')::bigint DESC
LIMIT 100;
```

**Solutions**:
- Implement file size limits
- Enable compression for images
- Review retention policies
- Archive old data

#### Realtime Connection Issues

**Symptoms**:
- Users reporting delayed updates
- High reconnection rates
- Subscription failures

**Investigation**:
- Check Realtime dashboard for active connections
- Monitor subscription counts
- Review application logs for errors

**Solutions**:
- Optimize subscription filters
- Implement exponential backoff for reconnections
- Review RLS policies for performance
- Consider message batching for high-volume updates

#### High Error Rates

**Symptoms**:
- Increased 5xx errors
- User reports of failures
- Alert notifications

**Investigation**:
```sql
-- Check recent errors (via logs)
-- Monitor Edge Function logs
-- Review API error patterns
```

**Solutions**:
- Review error logs for patterns
- Check for deployment issues
- Verify third-party service status (OneSignal, etc.)
- Implement retry logic with backoff

---

## Integration with External Tools

### Grafana Integration

1. Install Supabase data source plugin
2. Configure connection with project URL and service key
3. Import dashboard templates from `monitoring/grafana/`
4. Customize panels for specific metrics

### DataDog Integration

1. Use Supabase webhooks for metrics export
2. Configure custom metrics collection
3. Set up anomaly detection
4. Create composite monitors

### Sentry Integration

Already configured in the app for error tracking:
- Automatic error reporting
- Performance monitoring
- Release tracking
- User feedback collection

---

## Maintenance Schedule

### Daily Tasks
- [ ] Review dashboard for anomalies
- [ ] Check error rates
- [ ] Monitor storage usage

### Weekly Tasks
- [ ] Analyze slow query report
- [ ] Review security alerts
- [ ] Check resource utilization trends

### Monthly Tasks
- [ ] Capacity planning review
- [ ] Performance benchmark comparison
- [ ] Alert threshold adjustment
- [ ] Cost optimization analysis

### Quarterly Tasks
- [ ] Full monitoring stack review
- [ ] Disaster recovery testing
- [ ] Update monitoring documentation
- [ ] Security audit

---

## Additional Resources

- [Supabase Monitoring Documentation](https://supabase.com/docs/guides/platform/metrics)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Realtime Best Practices](https://supabase.com/docs/guides/realtime/best-practices)
- [Storage Optimization Guide](https://supabase.com/docs/guides/storage)

---

## Support and Escalation

### Internal Team Contacts
- **Database Issues**: Backend Team Lead
- **API Performance**: DevOps Engineer
- **Storage Issues**: Infrastructure Team
- **Security Alerts**: Security Team

### Supabase Support
- **Email**: support@supabase.com
- **Discord**: [Supabase Community](https://discord.supabase.com)
- **Support Tickets**: Via Supabase Dashboard

---

**Last Updated**: February 3, 2026
**Version**: 1.0
**Maintained By**: DevOps Team
