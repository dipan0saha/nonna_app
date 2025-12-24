# Supabase Realtime Configuration for Nonna App

## Overview

This document specifies which tables require Realtime functionality and how to configure them for live updates in the Nonna App.

## Realtime Requirements

Based on the application requirements for updates to propagate within 2 seconds, the following tables need Realtime enabled:

## Tables Requiring Realtime

### 1. **High-Priority Realtime Tables** (Core User Experience)

These tables require immediate real-time updates:

- `photos` - New photo uploads should appear instantly for all members
- `events` - New calendar events should appear immediately
- `event_rsvps` - RSVP changes should update in real-time
- `event_comments` - Comments should appear immediately
- `photo_comments` - Photo comments should appear immediately
- `photo_squishes` - Photo likes should update in real-time
- `registry_purchases` - Purchase status changes should be instant
- `notifications` - In-app notifications must be real-time
- `owner_update_markers` - Critical for cache invalidation strategy

### 2. **Medium-Priority Realtime Tables** (Enhanced Experience)

These tables benefit from Realtime but can tolerate slight delays:

- `registry_items` - Registry additions should update
- `baby_memberships` - New followers should appear
- `activity_events` - Activity stream updates
- `name_suggestion_likes` - Name suggestion likes

### 3. **Low-Priority Realtime Tables** (Optional)

These tables have less frequent updates:

- `votes` - Vote submissions (anonymous, less frequent)
- `name_suggestions` - Name suggestions

## Supabase Realtime Configuration

### Enable Realtime Publication

```sql
-- Create a publication for realtime tables
-- This is typically done via Supabase Dashboard or CLI

-- Add tables to the default supabase_realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.photos;
ALTER PUBLICATION supabase_realtime ADD TABLE public.events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_rsvps;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.photo_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.photo_squishes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.registry_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.registry_purchases;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.owner_update_markers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.baby_memberships;
ALTER PUBLICATION supabase_realtime ADD TABLE public.activity_events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.name_suggestions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.name_suggestion_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.votes;
```

### Alternative: Using Supabase Dashboard

1. Navigate to **Database** → **Replication** in Supabase Dashboard
2. Enable replication for each table listed above
3. Configure filters if needed (e.g., only replicate non-deleted comments)

## Client-Side Subscription Patterns

### Flutter Implementation Guidance

#### Pattern 1: Baby-Scoped Subscriptions (Owners)
Owners subscribe to updates for a specific baby profile:

```dart
// Example: Subscribe to photos for a specific baby
final subscription = supabase
  .from('photos')
  .stream(primaryKey: ['id'])
  .eq('baby_profile_id', babyProfileId)
  .listen((List<Map<String, dynamic>> data) {
    // Update UI with new photos
  });
```

#### Pattern 2: User-Scoped Subscriptions (Followers)
Followers subscribe to updates across all followed babies:

```dart
// Example: Subscribe to notifications for current user
final subscription = supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('recipient_user_id', userId)
  .order('created_at', ascending: false)
  .listen((List<Map<String, dynamic>> data) {
    // Update notification count
  });
```

#### Pattern 3: Cache Invalidation Subscription
Followers check owner update markers to invalidate cache:

```dart
// Subscribe to marker changes for followed babies
final subscription = supabase
  .from('owner_update_markers')
  .stream(primaryKey: ['id'])
  .inFilter('baby_profile_id', followedBabyIds)
  .listen((List<Map<String, dynamic>> data) {
    // Check timestamps and refresh cache if needed
  });
```

## Performance Considerations

### Subscription Scoping
- **Always scope subscriptions** to relevant baby profiles or user IDs
- Avoid subscribing to entire tables without filters
- Use RLS policies to ensure users only receive data they have access to

### Connection Management
- Limit concurrent subscriptions to 5-10 per client
- Reuse subscriptions when possible
- Unsubscribe when navigating away from screens

### Bandwidth Optimization
- Use `select` parameter to fetch only needed columns
- Consider pagination for large result sets
- Use `throttle` or `debounce` for high-frequency updates

## Security

### RLS Integration
Realtime automatically respects Row Level Security (RLS) policies. Users will only receive real-time updates for rows they have permission to access based on:
- Their authentication status
- Their membership in baby profiles
- Their role (owner vs. follower)

### Token Refresh
Ensure JWT tokens are refreshed before expiration to maintain Realtime connections:
- Supabase client handles this automatically in most cases
- Monitor for disconnection events and reconnect as needed

## Monitoring

### Key Metrics to Track
- Connection count per user
- Message throughput (messages/second)
- Latency from database change to client notification
- Disconnection/reconnection rate

### Target Performance
- **Update latency**: < 2 seconds from database change to UI update
- **Connection stability**: > 99% uptime
- **Concurrent connections**: Support 10,000+ concurrent users

## Troubleshooting

### Common Issues

1. **Updates not appearing in real-time**
   - Verify table is added to `supabase_realtime` publication
   - Check RLS policies allow user to read the data
   - Verify subscription filter matches the changed row

2. **High bandwidth usage**
   - Review subscription filters - are they too broad?
   - Consider using owner_update_markers instead of subscribing to all content tables
   - Implement client-side throttling

3. **Connection drops**
   - Check network stability
   - Verify JWT token refresh is working
   - Review Supabase connection limits

## Configuration Checklist

- [ ] All required tables added to `supabase_realtime` publication
- [ ] RLS policies configured and tested
- [ ] Client subscriptions scoped appropriately
- [ ] Connection management implemented
- [ ] Performance monitoring in place
- [ ] Error handling for disconnections implemented
- [ ] Testing with 10K+ concurrent users completed

## References

- [Supabase Realtime Documentation](https://supabase.com/docs/guides/realtime)
- [Flutter Supabase Client](https://pub.dev/packages/supabase_flutter)
- [PostgreSQL Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html)
