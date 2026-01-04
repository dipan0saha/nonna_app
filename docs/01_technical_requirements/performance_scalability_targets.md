# Performance and Scalability Targets

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Section**: 1.2 - Technical Requirements

## Executive Summary

This Performance and Scalability Targets document defines specific, measurable benchmarks and scalability requirements for the Nonna App. These targets ensure the application delivers a fast, responsive, and reliable experience that meets user expectations and business objectives while supporting growth from MVP launch to 10,000+ concurrent users.

Performance and scalability are critical success factors that directly impact:
- **User Experience**: Sub-500ms response times ensure smooth interactions
- **User Retention**: Fast app performance drives higher engagement and retention
- **Business Scalability**: System must support growing user base without degradation
- **Cost Efficiency**: Optimized performance reduces infrastructure costs

This document defines targets across five key dimensions:
1. **Response Time and Latency** - Speed of user interactions
2. **Throughput and Concurrency** - Volume of operations supported
3. **Resource Utilization** - Efficient use of compute, memory, storage
4. **Scalability** - Ability to handle growth
5. **Monitoring and Alerting** - Continuous performance tracking

## References

This document references:

- `docs/00_requirement_gathering/business_requirements_document.md` - Business scalability requirements (10K users)
- `docs/00_requirement_gathering/success_metrics_kpis.md` - Performance KPIs and measurement methods
- `docs/01_technical_requirements/functional_requirements_specification.md` - Feature performance requirements
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Performance and reliability requirements
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Architecture and performance strategies

---

## 1. Response Time and Latency Targets

### 1.1 API Response Time

**Target**: All API requests SHALL complete in < 500ms at 95th percentile (P95) under normal load.

#### 1.1.1 Detailed Latency Targets by Operation

| Operation | P50 (Median) | P95 | P99 | Max Acceptable |
|-----------|--------------|-----|-----|----------------|
| **User Authentication** | | | | |
| Login (email/password) | < 200ms | < 400ms | < 600ms | 1000ms |
| OAuth redirect | < 300ms | < 500ms | < 800ms | 1500ms |
| Token refresh | < 100ms | < 200ms | < 300ms | 500ms |
| **Database Queries** | | | | |
| Fetch photos (30 items) | < 150ms | < 300ms | < 500ms | 800ms |
| Fetch events (upcoming) | < 100ms | < 250ms | < 400ms | 600ms |
| Fetch registry items | < 100ms | < 200ms | < 350ms | 500ms |
| User profile lookup | < 50ms | < 100ms | < 200ms | 300ms |
| **Write Operations** | | | | |
| Create photo entry | < 100ms | < 200ms | < 350ms | 500ms |
| Create event | < 150ms | < 300ms | < 500ms | 800ms |
| RSVP to event | < 75ms | < 150ms | < 250ms | 400ms |
| Comment on photo | < 100ms | < 200ms | < 350ms | 500ms |
| Mark registry purchased | < 100ms | < 200ms | < 350ms | 500ms |

**Measurement Method**:
- Performance monitoring via Sentry/Datadog
- Supabase dashboard API latency metrics
- Custom instrumentation in Flutter app
- Load testing with k6 or Artillery

**Acceptance Criteria**:
- ✓ 95% of requests meet P95 targets
- ✓ 99% of requests meet P99 targets
- ✓ No request exceeds Max Acceptable latency
- ✓ Latency remains stable under load (10K concurrent users)

---

### 1.2 Screen Load Time

**Target**: Screens SHALL load and render in < 500ms from cached data; < 2 seconds for fresh data.

#### 1.2.1 Screen Load Benchmarks

| Screen | Cached Load | Fresh Load | Data Fetched |
|--------|-------------|------------|--------------|
| Home Screen | < 200ms | < 1500ms | Tiles, recent activity, notifications |
| Photo Gallery | < 300ms | < 2000ms | 30 photos (thumbnails) |
| Calendar | < 250ms | < 1500ms | Upcoming events (next 30 days) |
| Registry | < 200ms | < 1500ms | Registry items (all) |
| Event Detail | < 150ms | < 1000ms | Event + comments + RSVPs |
| Photo Detail | < 200ms | < 1500ms | Photo + comments + squishes |

**Optimization Strategies**:
- **Skeleton Screens**: Display layout immediately while data loads
- **Progressive Loading**: Load above-the-fold content first
- **Lazy Loading**: Load images and below-the-fold content on demand
- **Cache-First Strategy**: Display cached data immediately, refresh in background
- **Pagination**: Load data in chunks (30 items per page)

**Measurement Method**:
- Flutter DevTools performance profiling
- Custom timing instrumentation (e.g., `Stopwatch`)
- User-perceived load time tracking in analytics
- A/B testing with different loading strategies

**Acceptance Criteria**:
- ✓ Cached screens load in < 500ms (90% of cases)
- ✓ Fresh screens load in < 2 seconds (95% of cases)
- ✓ Skeleton screens display within 100ms
- ✓ Smooth 60 FPS scrolling during load

---

### 1.3 Photo Upload Time

**Target**: Photo uploads SHALL complete in < 5 seconds from selection to confirmation.

#### 1.3.1 Upload Pipeline Breakdown

| Stage | Target Time | Description |
|-------|-------------|-------------|
| Photo selection | < 500ms | OS file picker opens and user selects |
| Client-side compression | < 1000ms | Compress to 70% quality, max 1920x1920 |
| Upload to Supabase Storage | < 2500ms | Upload compressed file (avg 1-2MB) |
| Thumbnail generation | < 1000ms | Edge Function generates 300x300 thumbnail |
| Database entry creation | < 200ms | Insert photo record in database |
| **Total** | **< 5200ms** | **End-to-end upload flow** |

**Optimization Strategies**:
- **Client-Side Compression**: Use `flutter_image_compress` to reduce file size by 60-70%
- **Parallel Operations**: Upload original and generate thumbnail in parallel
- **Progress Indicators**: Show upload progress bar (0-100%)
- **Background Upload**: Allow users to continue using app during upload
- **Retry Logic**: Auto-retry failed uploads (3 attempts)

**Network Considerations**:
- **3G Network**: Upload may take 8-10 seconds (acceptable degradation)
- **4G/5G Network**: Upload should meet < 5s target
- **WiFi**: Upload should complete in < 3 seconds

**Acceptance Criteria**:
- ✓ 90% of uploads complete in < 5 seconds on 4G/WiFi
- ✓ Upload progress displayed with accurate percentage
- ✓ Users can navigate away during upload
- ✓ Failed uploads retry automatically

---

### 1.4 Real-Time Update Latency

**Target**: Real-time updates SHALL be delivered to clients within 2 seconds of source event.

#### 1.4.1 Update Delivery Targets

| Event Type | P95 Latency | Max Latency | Priority |
|------------|-------------|-------------|----------|
| New photo uploaded | < 1.5s | 3s | High |
| New comment added | < 1.0s | 2s | High |
| Event RSVP | < 1.5s | 3s | Medium |
| Registry item purchased | < 2.0s | 4s | Medium |
| Profile updated | < 2.0s | 5s | Low |

**Realtime Architecture**:
```
Owner uploads photo
    ↓
Database INSERT (photos table)
    ↓
PostgreSQL logical replication
    ↓
Supabase Realtime server
    ↓
WebSocket broadcast
    ↓
Follower clients receive update (< 2s total)
```

**Optimization Strategies**:
- **Subscription Scoping**: Filter realtime subscriptions by baby_profile_id
- **Connection Pooling**: Maintain persistent WebSocket connections
- **Batch Updates**: Batch rapid consecutive updates (e.g., bulk photo upload)
- **Priority Queue**: Prioritize high-priority updates (comments, photos)

**Measurement Method**:
- Timestamp events at source and client
- Calculate end-to-end latency
- Track in monitoring dashboard
- Alert on latency > 5 seconds

**Acceptance Criteria**:
- ✓ 95% of updates arrive within 2 seconds
- ✓ No update takes > 5 seconds under normal conditions
- ✓ WebSocket connections remain stable (< 1% disconnection rate)

---

## 2. Throughput and Concurrency Targets

### 2.1 Concurrent Users

**Target**: System SHALL support 10,000 concurrent active users without performance degradation.

#### 2.1.1 Concurrency Breakdown by Role

| User Type | Concurrent Users | Typical Actions |
|-----------|-----------------|-----------------|
| Owners | 2,000 (20%) | Creating content (photos, events, registry) |
| Followers | 8,000 (80%) | Viewing content, commenting, RSVPing |
| **Total** | **10,000** | **Mixed read/write workload** |

**Load Profile**:
- **Read Operations**: 80% of traffic (viewing photos, events, registry)
- **Write Operations**: 15% of traffic (comments, RSVPs, squishes)
- **Upload Operations**: 5% of traffic (photos, profile updates)

**Scalability Strategy**:
- **Database Read Replicas**: Distribute read load across replicas (Supabase Pro tier)
- **Connection Pooling**: Max 100 database connections (Supabase free tier limit)
- **CDN Caching**: Serve static assets (photos) from CDN
- **Edge Functions**: Offload compute-intensive operations (thumbnails)

**Acceptance Criteria**:
- ✓ System maintains < 500ms P95 latency with 10K users
- ✓ No connection pool exhaustion (monitor connection count)
- ✓ No rate limiting triggered under normal load
- ✓ Database CPU < 80%, memory < 90%

---

### 2.2 Throughput Targets

**Target**: System SHALL handle expected transaction volumes during peak hours.

#### 2.2.1 Peak Hour Throughput

| Operation | Requests/Hour | Requests/Second | Notes |
|-----------|---------------|-----------------|-------|
| **API Requests** | | | |
| Photo fetches (gallery) | 30,000 | 8.3 | 10K users, avg 3 fetches/hour |
| Event fetches | 15,000 | 4.2 | 10K users, avg 1.5 fetches/hour |
| Registry fetches | 10,000 | 2.8 | 10K users, avg 1 fetch/hour |
| User profile lookups | 5,000 | 1.4 | Background operations |
| **Write Operations** | | | |
| Photo uploads | 500 | 0.14 | 2K owners, avg 0.25 uploads/hour |
| Comments | 2,000 | 0.56 | 10K users, avg 0.2 comments/hour |
| RSVPs | 1,000 | 0.28 | 10K users, occasional events |
| Registry purchases | 200 | 0.06 | 8K followers, infrequent |
| **Total API Requests** | **~63,700** | **~17.7** | **Peak hour aggregate** |

**Supabase Free Tier Limits**:
- **Database**: 500 requests/second (ample headroom)
- **Storage**: 200 requests/second (sufficient)
- **Realtime**: 10,000 concurrent connections (at capacity)

**Acceptance Criteria**:
- ✓ System handles peak throughput without throttling
- ✓ Request queue depth remains low (< 10 pending)
- ✓ No 429 (Too Many Requests) errors
- ✓ Database throughput < 50% of max capacity

---

### 2.3 Realtime Connection Capacity

**Target**: Support 10,000 concurrent WebSocket connections for realtime updates.

#### 2.3.1 Connection Management

| Metric | Target | Monitoring |
|--------|--------|------------|
| Concurrent connections | 10,000 | Supabase Realtime dashboard |
| Connection stability | > 99% uptime | Disconnection rate tracking |
| Message throughput | 100 msg/sec | Real-time events/second |
| Reconnection time | < 3 seconds | Automatic retry on disconnect |

**Connection Scoping**:
- **Owners**: Subscribe to 1-2 baby profiles (avg 1.5)
- **Followers**: Subscribe to 2-5 baby profiles (avg 3.2)
- **Tables per subscription**: Photos, events, registry_items, comments (4 tables)
- **Total subscriptions**: ~32,000 (10K users × 3.2 babies × 1 subscription/baby)

**Optimization Strategies**:
- **Multiplexed Connections**: Single WebSocket connection per client, multiple subscriptions
- **Presence Management**: Close subscriptions when app backgrounded
- **Heartbeat Monitoring**: Detect and reconnect stale connections

**Acceptance Criteria**:
- ✓ 10,000 concurrent connections maintained
- ✓ < 1% disconnection rate during normal operation
- ✓ Reconnection completes within 3 seconds
- ✓ Real-time updates delivered within 2 seconds

---

## 3. Resource Utilization Targets

### 3.1 Mobile App Resource Usage

**Target**: Mobile app SHALL optimize battery, memory, and data usage for positive user experience.

#### 3.1.1 Battery Consumption

| Scenario | Battery Drain | Measurement Method |
|----------|---------------|-------------------|
| Active use (browsing) | < 5% per hour | Device battery profiling |
| Background (realtime sync) | < 2% per hour | iOS Energy Impact, Android Battery Historian |
| Idle (no activity) | < 0.5% per hour | Background task monitoring |

**Battery Optimization Strategies**:
- **Adaptive Sync**: Reduce realtime update frequency when app backgrounded
- **Wake Lock Management**: Release wake locks when not needed
- **Efficient Networking**: Batch API requests, use HTTP/2 multiplexing
- **Image Optimization**: Load thumbnails, lazy load full images
- **Background Restrictions**: Minimize background tasks (iOS/Android best practices)

**Acceptance Criteria**:
- ✓ Battery drain within targets (verified via profiling)
- ✓ No "High Battery Usage" warnings from OS
- ✓ Background tasks complete efficiently

---

#### 3.1.2 Memory Footprint

| State | Memory Usage | Notes |
|-------|--------------|-------|
| App launch | < 50 MB | Initial memory allocation |
| Normal operation | < 150 MB | Viewing photos, scrolling |
| Heavy use (uploading) | < 200 MB | Photo upload in progress |
| Peak (gallery) | < 250 MB | Viewing 100+ photos |

**Memory Optimization Strategies**:
- **Image Caching**: Use `cached_network_image` with cache limits (500 MB)
- **Dispose Resources**: Properly dispose controllers, streams, subscriptions
- **Pagination**: Load data in chunks to avoid large lists
- **Memory Profiling**: Regular profiling with Flutter DevTools

**Acceptance Criteria**:
- ✓ Memory usage within targets (verified via profiling)
- ✓ No memory leaks (stable memory over time)
- ✓ App does not crash due to OOM (Out of Memory)

---

#### 3.1.3 Data Usage

| Activity | Data Consumption | Notes |
|----------|------------------|-------|
| Photo upload | 1-2 MB | Compressed image |
| Photo view (full size) | 500 KB - 1 MB | From CDN |
| Thumbnail view | 30-50 KB | Cached locally |
| Average session | < 10 MB | Excluding photo uploads |
| Monthly usage (active user) | < 500 MB | Assuming 3 sessions/week |

**Data Optimization Strategies**:
- **Thumbnail Loading**: Load thumbnails first, full images on tap
- **Adaptive Quality**: Reduce image quality on cellular (vs WiFi)
- **Compression**: Client-side compression before upload
- **Caching**: Aggressive caching to reduce redundant downloads
- **Data Saver Mode**: Optional low-bandwidth mode

**Acceptance Criteria**:
- ✓ Average session < 10 MB data (excluding uploads)
- ✓ Thumbnails load efficiently (< 50 KB each)
- ✓ Data saver mode reduces usage by 50%+

---

### 3.2 Backend Resource Utilization

#### 3.2.1 Database Resource Targets

| Metric | Target | Monitoring |
|--------|--------|------------|
| Database CPU | < 70% avg, < 90% peak | Supabase dashboard |
| Database Memory | < 80% avg, < 95% peak | Supabase dashboard |
| Connection count | < 80 (max 100) | pg_stat_activity query |
| Query execution time | < 100ms avg | Slow query log |
| Index hit ratio | > 99% | pg_stat_user_indexes |

**Database Optimization**:
- **Indexing**: All foreign keys and hot query paths indexed
- **Query Optimization**: Use EXPLAIN ANALYZE for slow queries
- **Connection Pooling**: Reuse connections efficiently
- **Vacuuming**: Auto-vacuum configured for deleted data

**Acceptance Criteria**:
- ✓ Database resources within targets under peak load
- ✓ No slow queries (all < 500ms)
- ✓ Index hit ratio > 99% (minimal disk I/O)

---

#### 3.2.2 Storage Resource Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Storage usage (free tier) | 15 GB per user | Free tier limit |
| Storage usage (paid tier) | Unlimited | Paid tier benefit |
| CDN bandwidth | < 1 TB/month | Supabase CDN included |
| Storage latency | < 200ms | Photo retrieval time |

**Storage Optimization**:
- **Compression**: Client-side compression reduces storage by 60-70%
- **Thumbnail Strategy**: Store thumbnails separately for fast loading
- **CDN Caching**: Leverage CDN for static asset delivery
- **Cleanup**: Archive soft-deleted files after 7 years

**Acceptance Criteria**:
- ✓ Free tier users stay under 15 GB limit
- ✓ Photo retrieval < 200ms via CDN
- ✓ Storage growth rate monitored and projected

---

## 4. Scalability Requirements

### 4.1 Horizontal Scalability

**Target**: System architecture SHALL support horizontal scaling to handle 10x growth (100K users).

#### 4.1.1 Scalability Strategy by Component

| Component | Current (10K users) | 10x Scale (100K users) | Scaling Strategy |
|-----------|---------------------|------------------------|------------------|
| **Database** | Single instance | Read replicas | Supabase Pro: Add read replicas for query distribution |
| **Storage** | Single bucket | Multi-region CDN | Supabase: Automatic CDN distribution |
| **Realtime** | 10K connections | 100K connections | Supabase: Auto-scales WebSocket infrastructure |
| **Edge Functions** | 100K invocations/month | 1M invocations/month | Supabase: Auto-scales serverless functions |
| **Flutter App** | N/A | N/A | Client-side; scales with app downloads |

**Database Scaling Path**:
1. **Phase 1 (MVP)**: Single Supabase instance (free tier)
2. **Phase 2 (10K users)**: Supabase Pro with read replicas
3. **Phase 3 (100K users)**: Dedicated database, additional read replicas
4. **Phase 4 (1M users)**: Sharding by baby_profile_id, multi-region deployment

**Acceptance Criteria**:
- ✓ Architecture supports read replica addition
- ✓ Database queries scoped for efficient sharding
- ✓ No hardcoded limits that prevent scaling

---

### 4.2 Vertical Scalability

**Target**: Individual components SHALL scale vertically to handle increased load per user.

#### 4.2.1 Vertical Scaling Triggers

| Component | Trigger | Action |
|-----------|---------|--------|
| Database CPU | > 80% sustained | Upgrade to larger Supabase instance |
| Database Memory | > 90% sustained | Upgrade to larger instance |
| Storage IOPS | > 80% capacity | Upgrade to higher IOPS tier |
| Edge Function timeout | > 10% failures | Optimize function or increase memory |

**Acceptance Criteria**:
- ✓ Vertical scaling documented and tested
- ✓ Monitoring alerts trigger before capacity reached
- ✓ Scaling can be performed with < 5 min downtime

---

### 4.3 Load Testing and Capacity Planning

**Target**: Conduct regular load testing to validate capacity and identify bottlenecks.

#### 4.3.1 Load Testing Schedule

| Test Type | Frequency | Target Load | Success Criteria |
|-----------|-----------|-------------|------------------|
| Smoke test | Daily (CI/CD) | 100 users | All critical paths pass |
| Load test | Weekly | 10K users | Meet P95 latency targets |
| Stress test | Monthly | 20K users (2x capacity) | Identify breaking point |
| Endurance test | Quarterly | 10K users, 24 hours | No memory leaks, stable performance |

#### 4.3.2 Load Testing Tools

**k6 Load Testing Script Example**:
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '5m', target: 1000 },  // Ramp up to 1K users
    { duration: '10m', target: 5000 }, // Ramp to 5K users
    { duration: '10m', target: 10000 }, // Ramp to 10K users
    { duration: '5m', target: 10000 },  // Sustain 10K users
    { duration: '5m', target: 0 },      // Ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500'], // 95% requests < 500ms
    'http_req_failed': ['rate<0.01'],   // < 1% failure rate
  },
};

export default function () {
  // Simulate user viewing photo gallery
  let response = http.get('https://project.supabase.co/rest/v1/photos?select=*&limit=30', {
    headers: { 'apikey': __ENV.SUPABASE_ANON_KEY },
  });
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(5); // User views photos for 5 seconds
}
```

**Acceptance Criteria**:
- ✓ Load tests run on schedule
- ✓ Test results documented and reviewed
- ✓ Performance regressions caught before production

---

## 5. Monitoring and Alerting

### 5.1 Performance Monitoring

**Target**: Comprehensive monitoring SHALL provide real-time visibility into system performance.

#### 5.1.1 Key Performance Indicators (KPIs) Dashboard

| KPI | Target | Alert Threshold | Monitoring Tool |
|-----|--------|-----------------|-----------------|
| API Latency (P95) | < 500ms | > 800ms | Sentry, Datadog |
| Photo Upload Time | < 5s | > 8s | Custom instrumentation |
| Screen Load Time | < 500ms | > 1000ms | Firebase Performance |
| Crash-Free Rate | > 99% | < 98% | Sentry |
| Database CPU | < 70% | > 85% | Supabase dashboard |
| Realtime Connections | 10K | > 9500 (95%) | Supabase Realtime metrics |
| Storage Bandwidth | < 1 TB/month | > 800 GB/month | Supabase Storage metrics |

**Dashboard Visualization**:
- Real-time graphs for latency, throughput, errors
- Historical trends (7 days, 30 days, 90 days)
- Comparison to baselines and targets
- Drill-down by endpoint, screen, user segment

---

### 5.2 Alerting and Incident Response

#### 5.2.1 Alert Severity Levels

| Severity | Criteria | Response Time | Action |
|----------|----------|---------------|--------|
| **P0 (Critical)** | Crash rate > 5%, API latency > 2s, uptime < 99% | < 15 minutes | Page on-call engineer |
| **P1 (High)** | Crash rate > 2%, API latency > 1s, CPU > 90% | < 1 hour | Engineer investigates |
| **P2 (Medium)** | Performance degradation, approaching limits | < 4 hours | Review during business hours |
| **P3 (Low)** | Minor performance issues, informational | Next sprint | Add to backlog |

#### 5.2.2 Alert Configuration Examples

**Sentry Alert (Crash Rate)**:
```yaml
alert: crash_rate_high
condition: crash_free_rate < 98% over 1 hour
severity: P0
notification: PagerDuty, Slack #incidents
```

**Supabase Alert (Database CPU)**:
```yaml
alert: database_cpu_high
condition: cpu_usage > 85% for 10 minutes
severity: P1
notification: Email, Slack #engineering
```

**Custom Alert (Upload Time)**:
```yaml
alert: photo_upload_slow
condition: p95_upload_time > 8s over 15 minutes
severity: P2
notification: Slack #engineering
```

---

### 5.3 Performance Regression Detection

**Target**: Automated detection of performance regressions in CI/CD pipeline.

#### 5.3.1 Regression Testing Strategy

**CI/CD Performance Checks**:
1. **Build-Time Checks**: App size < 50 MB, build time < 10 min
2. **Test-Time Checks**: Unit test suite runs in < 5 min
3. **Staging Deployment Checks**: Smoke test passes with < 500ms latency
4. **Pre-Production Checks**: Load test passes before production deploy

**Regression Detection**:
```bash
# Example: Compare API latency before/after deploy
current_p95=$(curl -s https://api.sentry.io/performance | jq '.p95')
baseline_p95=450  # Baseline target

if (( $(echo "$current_p95 > $baseline_p95 * 1.2" | bc -l) )); then
  echo "Performance regression detected: P95 latency $current_p95 ms"
  exit 1  # Fail deployment
fi
```

**Acceptance Criteria**:
- ✓ Performance regression caught before production
- ✓ Deployment blocked on critical regressions
- ✓ Performance metrics tracked over time

---

## 6. Optimization Strategies

### 6.1 Database Query Optimization

**Strategy**: Optimize database queries to meet < 500ms P95 target.

#### 6.1.1 Query Optimization Checklist

- [ ] **Indexing**: All foreign keys and hot query paths indexed
- [ ] **Query Analysis**: Run EXPLAIN ANALYZE on slow queries
- [ ] **Pagination**: Use LIMIT/OFFSET or cursor-based pagination
- [ ] **Select Specific Columns**: Avoid SELECT *, fetch only needed columns
- [ ] **Join Optimization**: Minimize number of joins, use indexes
- [ ] **Aggregation**: Use database aggregation functions (COUNT, SUM) instead of client-side
- [ ] **Connection Pooling**: Reuse connections, avoid repeated connect/disconnect

**Example: Optimized Photo Gallery Query**:
```sql
-- Before (slow):
SELECT * FROM photos
WHERE baby_profile_id IN (SELECT baby_profile_id FROM baby_memberships WHERE user_id = ?)
ORDER BY created_at DESC;

-- After (optimized):
SELECT p.id, p.thumbnail_path, p.caption, p.created_at
FROM photos p
INNER JOIN baby_memberships bm ON p.baby_profile_id = bm.baby_profile_id
WHERE bm.user_id = ? AND bm.removed_at IS NULL AND p.deleted_at IS NULL
ORDER BY p.created_at DESC
LIMIT 30;

-- Add index:
CREATE INDEX idx_photos_baby_profile_created ON photos(baby_profile_id, created_at DESC);
```

---

### 6.2 Caching Strategy

**Strategy**: Implement multi-layer caching to reduce latency and database load.

#### 6.2.1 Caching Layers

| Layer | Technology | Data Cached | TTL | Invalidation |
|-------|------------|-------------|-----|--------------|
| **Client Memory** | Riverpod | Active screen data | Session | On navigation away |
| **Client Storage** | Hive/Isar | Photos, profiles, tiles | 7 days | On update marker change |
| **CDN** | Supabase CDN | Images (thumbnails, full) | 30 days | Versioned URLs |
| **Database** | PostgreSQL | N/A (always fresh) | N/A | N/A |

**Cache Invalidation via Update Markers**:
```dart
// Check if cache is stale
final cachedTimestamp = await Hive.box('cache').get('photos_updated_at');
final markerTimestamp = await supabase
  .from('owner_update_markers')
  .select('tiles_last_updated_at')
  .eq('baby_profile_id', babyProfileId)
  .single();

if (cachedTimestamp == null || 
    DateTime.parse(markerTimestamp['tiles_last_updated_at'])
      .isAfter(DateTime.parse(cachedTimestamp))) {
  // Cache stale, fetch fresh data
  await fetchFreshPhotos();
} else {
  // Cache valid, use cached data
  loadCachedPhotos();
}
```

---

### 6.3 Image Optimization

**Strategy**: Optimize images to reduce upload time, storage, and bandwidth.

#### 6.3.1 Image Processing Pipeline

| Stage | Optimization | Result |
|-------|--------------|--------|
| **Client-side capture** | Camera resolution limit (1920x1920) | Max 4 MP images |
| **Client-side compression** | JPEG quality 70%, resize to 1920x1920 | 1-2 MB (from 5-10 MB) |
| **Upload** | Compressed file to Supabase Storage | < 5s upload |
| **Thumbnail generation** | Edge Function, 300x300, quality 80% | 30-50 KB thumbnail |
| **CDN delivery** | Supabase CDN caching | Fast global delivery |

**Flutter Image Compression**:
```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List> compressImage(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 1920,
    minHeight: 1920,
    quality: 70,
    format: CompressFormat.jpeg,
  );
  return result!;
}
```

---

## 7. Performance Testing Scenarios

### 7.1 User Journey Performance Tests

#### 7.1.1 Sarah (Owner) - Photo Upload Journey

**Scenario**: Sarah uploads 5 photos to her baby profile and adds captions.

**Performance Targets**:
- Photo selection to upload complete: < 5s per photo
- Total journey time: < 30s (5 photos × 5s + 5s overhead)
- Followers receive real-time notification: < 2s after upload

**Load Test**:
- Simulate 500 owners uploading 5 photos concurrently
- Total: 2,500 photo uploads in 30 seconds
- Target: All uploads complete successfully, < 5s each

---

#### 7.1.2 Linda (Follower) - Gallery Browsing Journey

**Scenario**: Linda opens app, views photo gallery, scrolls through 100 photos, and comments on 3.

**Performance Targets**:
- App launch to gallery screen: < 2s
- Initial 30 photos load: < 500ms (cached) or < 2s (fresh)
- Infinite scroll next page: < 1s
- Comment submission: < 500ms

**Load Test**:
- Simulate 8,000 followers browsing galleries concurrently
- Target: P95 screen load < 2s, P95 comment submit < 500ms

---

### 7.2 Stress Testing

**Objective**: Identify system breaking point and graceful degradation.

**Test Scenarios**:
1. **2x Normal Load**: 20K concurrent users
2. **5x Photo Upload Spike**: 2,500 photo uploads in 1 minute
3. **Database Connection Exhaustion**: Rapid connection creation (> 100)
4. **Realtime Connection Spike**: 15K concurrent WebSocket connections

**Acceptance Criteria**:
- System degrades gracefully (increased latency, not crashes)
- Error rates remain < 5% under 2x load
- Auto-recovery after load spike subsides

---

## 8. Continuous Improvement

### 8.1 Performance Review Cadence

| Review Type | Frequency | Attendees | Outcomes |
|-------------|-----------|-----------|----------|
| Weekly Performance Standup | Weekly | Engineering team | Review metrics, identify issues |
| Monthly Performance Review | Monthly | Engineering + Product | Prioritize optimizations |
| Quarterly Capacity Planning | Quarterly | Engineering + Leadership | Plan scaling, set budgets |

### 8.2 Performance Optimization Backlog

**High Priority Optimizations**:
1. Implement database read replicas (for 10K+ users)
2. Optimize hot query paths (photos, events)
3. Implement adaptive image quality based on network
4. Add performance budgets to CI/CD

**Medium Priority Optimizations**:
1. Implement CDN caching for API responses
2. Add service worker for offline support
3. Optimize real-time subscription filtering
4. Implement query result caching

**Low Priority Optimizations**:
1. Explore database sharding strategy
2. Implement multi-region deployment
3. Add advanced caching (Redis/Memcached)
4. Optimize bundle size further

---

## Conclusion

This Performance and Scalability Targets document defines comprehensive, measurable benchmarks that ensure the Nonna App delivers a fast, responsive, and reliable experience from MVP launch through 10,000+ concurrent users and beyond.

**Key Performance Commitments**:
1. **Response Time**: < 500ms P95 for all user interactions
2. **Photo Upload**: < 5 seconds from selection to confirmation
3. **Real-Time Updates**: < 2 seconds delivery latency
4. **Scalability**: Support 10,000 concurrent users without degradation
5. **Resource Efficiency**: Optimize battery, memory, and data usage

**Success Indicators**:
- User satisfaction (NPS 50+, app rating 4.5+)
- High retention (60%+ 30-day retention)
- Stable performance (crash rate < 1%, uptime 99.5%)
- Efficient scaling (linear cost growth with user growth)

These targets are continuously monitored, measured, and optimized to ensure Nonna delivers best-in-class performance and scalability.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Next Review**: Before Performance Testing Phase
