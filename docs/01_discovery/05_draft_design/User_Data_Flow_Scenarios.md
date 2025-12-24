# Nonna App - User & Data Flow Scenarios

## Document Purpose

This document provides comprehensive data flow diagrams for all user scenarios in the Nonna App. It maps user actions to database operations, showing exactly how data moves through tables for both **Owners** and **Followers**. This document is designed to support Flutter drive test creation and system validation.

## Table of Contents

1. [User Onboarding Flows](#1-user-onboarding-flows)
2. [Owner Flows](#2-owner-flows)
3. [Follower Flows](#3-follower-flows)
4. [Interaction Flows](#4-interaction-flows)
5. [Cache & Realtime Flows](#5-cache--realtime-flows)
6. [Notification Flows](#6-notification-flows)
7. [Query Patterns](#7-query-patterns)

---

## 1. User Onboarding Flows

### 1.1 User Signup & Profile Creation

**User Action**: New user signs up via email/password or OAuth

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ User Signs Up                                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Supabase Auth: auth.users                                    │
│ INSERT: id, email, created_at                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: handle_new_user()                                   │
│ Fires automatically on auth.users INSERT                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────────────────────────┐
        │                                     │
        ↓                                     ↓
┌──────────────────┐              ┌──────────────────┐
│ profiles         │              │ user_stats       │
│ INSERT:          │              │ INSERT:          │
│ - user_id (FK)   │              │ - user_id (FK)   │
│ - display_name   │              │ - counters = 0   │
│ - created_at     │              │ - updated_at     │
└──────────────────┘              └──────────────────┘
```

**Tables Modified**:
1. `auth.users` - New user record
2. `profiles` - New profile with display name from email
3. `user_stats` - New stats record with zero counters

**Test Assertions**:
- Verify `profiles.user_id` matches `auth.users.id`
- Verify `user_stats.user_id` matches `auth.users.id`
- Verify display_name is set (default from email prefix)
- Verify all counters in `user_stats` are 0

---

### 1.2 Owner Creates First Baby Profile

**User Action**: Owner creates a new baby profile

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Create Baby Profile                                   │
│ Input: name, expected_birth_date, gender, photo             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ baby_profiles                                                │
│ INSERT:                                                      │
│ - id (auto-generated UUID)                                   │
│ - name, expected_birth_date, gender, profile_photo_url      │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: create_owner_update_marker()                        │
│ Fires on baby_profiles INSERT                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────────────────────────┐
        │                                     │
        ↓                                     ↓
┌──────────────────────┐        ┌───────────────────────────┐
│ baby_memberships     │        │ owner_update_markers      │
│ INSERT:              │        │ INSERT:                   │
│ - baby_profile_id    │        │ - baby_profile_id (unique)│
│ - user_id (owner)    │        │ - tiles_last_updated_at   │
│ - role = 'owner'     │        │ - reason = 'created'      │
│ - relationship_label │        │                           │
│ - created_at         │        │                           │
└──────────────────────┘        └───────────────────────────┘
```

**Tables Modified**:
1. `baby_profiles` - New baby record
2. `baby_memberships` - Owner membership created
3. `owner_update_markers` - Cache invalidation marker created

**Test Assertions**:
- Verify baby_profile created with correct data
- Verify membership with role='owner' exists
- Verify owner_update_markers created
- Verify RLS allows owner to read baby_profile

---

### 1.3 Follower Accepts Invitation

**User Action**: Follower clicks invitation link and accepts

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Click Invitation Link                             │
│ Input: token, relationship_label                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ invitations (SELECT)                                         │
│ WHERE: token_hash = hash(token)                             │
│       AND status = 'pending'                                 │
│       AND expires_at > NOW()                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
                   [Valid Invitation?]
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ invitations (UPDATE)                                         │
│ SET: status = 'accepted'                                     │
│      accepted_at = NOW()                                     │
│      accepted_by_user_id = auth.uid()                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ baby_memberships (INSERT)                                    │
│ - baby_profile_id (from invitation)                          │
│ - user_id = auth.uid()                                       │
│ - role = 'follower'                                          │
│ - relationship_label (user provided)                         │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: create_content_notifications()                      │
│ Fires on baby_memberships INSERT                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ notifications (INSERT)                                       │
│ For all owners of the baby:                                  │
│ - recipient_user_id (each owner)                             │
│ - baby_profile_id                                            │
│ - type = 'new_follower'                                      │
│ - payload = {user_id, relationship}                          │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `invitations` - Status updated to 'accepted'
2. `baby_memberships` - New follower membership
3. `notifications` - Notification created for owners

**Test Assertions**:
- Verify invitation status changed to 'accepted'
- Verify membership created with role='follower'
- Verify notification created for owner(s)
- Verify RLS now allows follower to read baby_profile

---

## 2. Owner Flows

### 2.1 Owner Uploads Photo

**User Action**: Owner uploads photo with optional caption

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Upload Photo                                          │
│ Input: photo_file, caption, baby_profile_id                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Supabase Storage: Upload to bucket                          │
│ Path: babies/{baby_profile_id}/photos/{photo_id}.jpg        │
│ Returns: storage_path                                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ photos (INSERT)                                              │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - uploaded_by_user_id = auth.uid()                           │
│ - storage_path                                               │
│ - caption                                                    │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS: Multiple triggers fire                             │
│ 1. update_owner_marker()                                     │
│ 2. log_activity_event()                                      │
│ 3. create_content_notifications()                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┬────────────────┐
        ↓                ↓                ↓                ↓
┌──────────────┐  ┌────────────────┐  ┌──────────────┐  ┌──────────────┐
│owner_update_ │  │activity_events │  │notifications │  │Realtime      │
│markers       │  │INSERT:         │  │INSERT for    │  │Broadcast to  │
│UPDATE:       │  │- type='photo_  │  │each follower:│  │subscribers   │
│- tiles_last_ │  │  uploaded'     │  │- type='photo │  │on photos     │
│  updated_at  │  │- payload={id}  │  │  _added'     │  │table         │
│- reason      │  │                │  │- payload={id}│  │              │
└──────────────┘  └────────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `photos` - New photo record
2. `owner_update_markers` - Timestamp updated
3. `activity_events` - Activity logged
4. `notifications` - Notifications for all followers

**Realtime Events**:
- `photos` table INSERT broadcasted to subscribers
- Followers subscribed to this baby see update in < 2s

**Test Assertions**:
- Verify photo record created
- Verify storage_path is valid
- Verify owner_update_markers timestamp updated
- Verify activity_events record created
- Verify notifications created for all followers
- Verify realtime event broadcasted

---

### 2.2 Owner Creates Calendar Event

**User Action**: Owner adds event to calendar

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Create Calendar Event                                 │
│ Input: title, starts_at, description, location, etc.        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ events (INSERT)                                              │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - created_by_user_id = auth.uid()                            │
│ - title, starts_at, ends_at, description, location          │
│ - video_link, cover_photo_url                                │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS: Multiple triggers fire                             │
│ 1. update_owner_marker()                                     │
│ 2. log_activity_event()                                      │
│ 3. create_content_notifications()                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┬────────────────┐
        ↓                ↓                ↓                ↓
┌──────────────┐  ┌────────────────┐  ┌──────────────┐  ┌──────────────┐
│owner_update_ │  │activity_events │  │notifications │  │Realtime      │
│markers       │  │INSERT:         │  │INSERT for    │  │Broadcast to  │
│UPDATE:       │  │- type='event_  │  │each follower:│  │subscribers   │
│- tiles_last_ │  │  created'      │  │- type='event │  │on events     │
│  updated_at  │  │- payload={id,  │  │  _created'   │  │table         │
│- reason      │  │  title}        │  │- payload={id}│  │              │
└──────────────┘  └────────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `events` - New event record
2. `owner_update_markers` - Timestamp updated
3. `activity_events` - Activity logged
4. `notifications` - Notifications for all followers

**Test Assertions**:
- Verify event created with correct data
- Verify starts_at is in the future (if required)
- Verify owner_update_markers updated
- Verify notifications sent to followers

---

### 2.3 Owner Adds Registry Item

**User Action**: Owner adds item to registry

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Add Registry Item                                     │
│ Input: name, description, link_url, priority                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ registry_items (INSERT)                                      │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - created_by_user_id = auth.uid()                            │
│ - name, description, link_url, priority                      │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS: update_owner_marker()                              │
│          create_content_notifications()                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┐
        ↓                ↓                ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│owner_update_ │  │notifications │  │Realtime      │
│markers       │  │INSERT for    │  │Broadcast     │
│UPDATE        │  │followers     │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `registry_items` - New item
2. `owner_update_markers` - Updated
3. `notifications` - Followers notified

---

### 2.4 Owner Sends Invitation

**User Action**: Owner invites someone via email

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Send Invitation                                       │
│ Input: invitee_email, baby_profile_id                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Generate secure token (server-side)                          │
│ token_hash = hash(token)                                     │
│ expires_at = NOW() + 7 days                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ invitations (INSERT)                                         │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - invited_by_user_id = auth.uid()                            │
│ - invitee_email                                              │
│ - token_hash                                                 │
│ - expires_at                                                 │
│ - status = 'pending'                                         │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Edge Function: Send Email (via SendGrid)                    │
│ - Deep link with token                                       │
│ - Invitation details                                         │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `invitations` - New invitation record

**External Services**:
- SendGrid email sent with invitation link

**Test Assertions**:
- Verify invitation created with status='pending'
- Verify expires_at is 7 days in future
- Verify token_hash is unique
- (Mock) Verify email sending called

---

### 2.5 Owner Moderates Comment (Deletes)

**User Action**: Owner deletes a comment on their content

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner: Delete Comment                                        │
│ Input: comment_id (on photo or event)                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ photo_comments or event_comments (UPDATE)                    │
│ SET: deleted_at = NOW()                                      │
│      deleted_by_user_id = auth.uid()                         │
│ WHERE: id = comment_id                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ RLS Policy: owner_moderation allows this                     │
│ RLS checks is_baby_owner(baby_profile_id, auth.uid())       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Realtime: Broadcast UPDATE event                             │
│ Subscribers see comment disappear                            │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `photo_comments` or `event_comments` - Soft deleted

**Test Assertions**:
- Verify deleted_at is set
- Verify deleted_by_user_id = owner's ID
- Verify comment no longer visible in queries (WHERE deleted_at IS NULL)
- Verify RLS prevents non-owners from deleting

---

## 3. Follower Flows

### 3.1 Follower Opens Home Screen (First Load)

**User Action**: Follower opens app and navigates to Home

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Open Home Screen                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Load from Local Cache (Hive/Isar)                   │
│ - Instant UI render with cached data                         │
│ - Show cached photos, events, notifications                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Fetch Tile Configs (if not cached)                  │
│ SELECT * FROM tile_configs                                   │
│ WHERE screen_id = 'home' AND role = 'follower'              │
│ ORDER BY display_order                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Check Cache Invalidation Markers                    │
│ SELECT baby_profile_id, tiles_last_updated_at               │
│ FROM owner_update_markers                                    │
│ WHERE baby_profile_id IN (                                   │
│   SELECT baby_profile_id FROM baby_memberships              │
│   WHERE user_id = auth.uid() AND removed_at IS NULL         │
│ )                                                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
              [Compare with cached timestamps]
                          ↓
        ┌─────────────────────────────────┐
        │ Any markers newer than cache?   │
        └─────────────────────────────────┘
        ↓ NO (cache valid)    ↓ YES (cache stale)
┌──────────────┐        ┌───────────────────────┐
│ Use cached   │        │ Step 4: Fetch Fresh   │
│ data         │        │ Data for stale tiles  │
│ Skip queries │        │                       │
└──────────────┘        └───────────────────────┘
                                  ↓
                    ┌─────────────────────────────┐
                    │ Fetch Recent Photos:        │
                    │ SELECT * FROM photos        │
                    │ WHERE baby_profile_id IN    │
                    │   (followed babies)         │
                    │ ORDER BY created_at DESC    │
                    │ LIMIT 10                    │
                    └─────────────────────────────┘
                                  ↓
                    ┌─────────────────────────────┐
                    │ Fetch Upcoming Events:      │
                    │ SELECT * FROM events        │
                    │ WHERE baby_profile_id IN    │
                    │   (followed babies)         │
                    │   AND starts_at > NOW()     │
                    │ ORDER BY starts_at ASC      │
                    │ LIMIT 5                     │
                    └─────────────────────────────┘
                                  ↓
                    ┌─────────────────────────────┐
                    │ Update Local Cache          │
                    │ Store fetched data + marker │
                    │ timestamps                  │
                    └─────────────────────────────┘
```

**Tables Queried**:
1. `tile_configs` - Get home screen tiles for follower role
2. `owner_update_markers` - Check if cache is stale
3. `photos`, `events`, `registry_items`, etc. - If cache stale

**Performance Optimizations**:
- Local cache provides instant UI
- Only fetch if markers indicate changes
- Aggregated queries across all followed babies

**Test Assertions**:
- Verify cached data loaded instantly
- Verify cache invalidation check uses markers
- Verify fresh data fetched only when needed
- Verify aggregated queries use IN clause with baby IDs

---

### 3.2 Follower RSVPs to Event

**User Action**: Follower RSVPs to an event

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: RSVP to Event                                      │
│ Input: event_id, status (yes/no/maybe)                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ event_rsvps (INSERT or UPDATE)                               │
│ INSERT:                                                      │
│ - id (auto UUID)                                             │
│ - event_id                                                   │
│ - user_id = auth.uid()                                       │
│ - status                                                     │
│ - created_at, updated_at                                     │
│ ON CONFLICT (event_id, user_id) DO UPDATE SET status        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS:                                                    │
│ 1. increment_events_attended() - if status = 'yes'          │
│ 2. create_content_notifications()                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┐
        ↓                ↓                ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│user_stats    │  │notifications │  │Realtime      │
│UPDATE:       │  │INSERT for    │  │Broadcast to  │
│- events_     │  │owner(s):     │  │subscribers   │
│  attended_   │  │- type='event │  │on event_rsvps│
│  count += 1  │  │  _rsvp'      │  │table         │
│  (if yes)    │  │- payload={   │  │              │
│              │  │  user, status│  │              │
│              │  │  }           │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `event_rsvps` - RSVP recorded (unique per user per event)
2. `user_stats` - Counter incremented if status='yes'
3. `notifications` - Owner notified of RSVP

**Test Assertions**:
- Verify RSVP created or updated
- Verify unique constraint enforced (one RSVP per user per event)
- Verify user_stats incremented only for 'yes'
- Verify notification sent to owner
- Verify RLS allows follower to RSVP

---

### 3.3 Follower Squishes (Likes) Photo

**User Action**: Follower likes a photo

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Squish Photo                                       │
│ Input: photo_id                                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ photo_squishes (INSERT)                                      │
│ - id (auto UUID)                                             │
│ - photo_id                                                   │
│ - user_id = auth.uid()                                       │
│ - created_at                                                 │
│ CONSTRAINT: unique(photo_id, user_id)                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: increment_photos_squished()                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┐
        ↓                ↓                ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│user_stats    │  │Realtime      │  │UI Update     │
│UPDATE:       │  │Broadcast to  │  │Photo squish  │
│- photos_     │  │subscribers   │  │count         │
│  squished_   │  │on photo_     │  │increments    │
│  count += 1  │  │squishes      │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `photo_squishes` - Like recorded
2. `user_stats` - Squish counter incremented

**Test Assertions**:
- Verify squish created
- Verify unique constraint prevents double-squishing
- Verify user_stats incremented
- Verify realtime broadcast
- Verify RLS allows follower to squish

---

### 3.4 Follower Purchases Registry Item

**User Action**: Follower marks registry item as purchased

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Purchase Registry Item                             │
│ Input: registry_item_id, note (optional)                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ registry_purchases (INSERT)                                  │
│ - id (auto UUID)                                             │
│ - registry_item_id                                           │
│ - purchased_by_user_id = auth.uid()                          │
│ - purchased_at = NOW()                                       │
│ - note                                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS: Multiple triggers fire                             │
│ 1. increment_items_purchased()                               │
│ 2. update_owner_marker() (via registry_item lookup)          │
│ 3. create_content_notifications()                            │
│ 4. log_activity_event()                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┬────────────────┐
        ↓                ↓                ↓                ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│user_stats    │  │owner_update_ │  │notifications │  │activity_     │
│UPDATE:       │  │markers       │  │INSERT for    │  │events        │
│- items_      │  │UPDATE:       │  │owner(s):     │  │INSERT:       │
│  purchased_  │  │- tiles_last_ │  │- type='item_ │  │- type='item_ │
│  count += 1  │  │  updated_at  │  │  purchased'  │  │  purchased'  │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `registry_purchases` - Purchase record
2. `user_stats` - Purchase counter incremented
3. `owner_update_markers` - Cache invalidated
4. `notifications` - Owner notified
5. `activity_events` - Activity logged

**Test Assertions**:
- Verify purchase record created
- Verify user_stats incremented
- Verify owner notified
- Verify activity logged
- Verify marker updated (followers will see update)

---

### 3.5 Follower Comments on Photo

**User Action**: Follower adds comment to photo

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Comment on Photo                                   │
│ Input: photo_id, comment_body                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ photo_comments (INSERT)                                      │
│ - id (auto UUID)                                             │
│ - photo_id                                                   │
│ - user_id = auth.uid()                                       │
│ - body                                                       │
│ - created_at                                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGERS:                                                    │
│ 1. increment_comments_added()                                │
│ 2. log_activity_event()                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌────────────────┬────────────────┐
        ↓                ↓                ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│user_stats    │  │activity_     │  │Realtime      │
│UPDATE:       │  │events        │  │Broadcast to  │
│- comments_   │  │INSERT        │  │subscribers   │
│  added_count │  │              │  │on photo_     │
│  += 1        │  │              │  │comments      │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Tables Modified**:
1. `photo_comments` - Comment created
2. `user_stats` - Comment counter incremented
3. `activity_events` - Activity logged

**Test Assertions**:
- Verify comment created
- Verify user_stats incremented
- Verify activity logged
- Verify realtime broadcast
- Verify RLS allows follower to comment

---

### 3.6 Follower Suggests Baby Name

**User Action**: Follower suggests name for baby

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Follower: Suggest Baby Name                                  │
│ Input: baby_profile_id, gender, suggested_name              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ name_suggestions (INSERT)                                    │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - user_id = auth.uid()                                       │
│ - gender                                                     │
│ - suggested_name                                             │
│ - created_at, updated_at                                     │
│ CONSTRAINT: unique(baby_profile_id, user_id, gender)        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Realtime: Broadcast to subscribers                           │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `name_suggestions` - Suggestion created

**Test Assertions**:
- Verify suggestion created
- Verify unique constraint (one per user per gender per baby)
- Verify realtime broadcast
- Verify RLS allows follower to suggest

---

## 4. Interaction Flows

### 4.1 User Likes Name Suggestion

**User Action**: Any member likes another user's name suggestion

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ User: Like Name Suggestion                                   │
│ Input: name_suggestion_id                                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ name_suggestion_likes (INSERT)                               │
│ - id (auto UUID)                                             │
│ - name_suggestion_id                                         │
│ - user_id = auth.uid()                                       │
│ - created_at                                                 │
│ CONSTRAINT: unique(name_suggestion_id, user_id)             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ QUERY: Get suggestion owner for notification                │
│ SELECT user_id FROM name_suggestions                         │
│ WHERE id = name_suggestion_id                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ notifications (INSERT)                                       │
│ For suggestion owner:                                        │
│ - recipient_user_id (suggestion owner)                       │
│ - type = 'name_suggestion_liked'                             │
│ - payload = {liker_user_id, name_suggestion_id}             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Realtime: Broadcast to subscribers                           │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `name_suggestion_likes` - Like recorded
2. `notifications` - Suggestion owner notified

**Test Assertions**:
- Verify like created
- Verify unique constraint (one like per user per suggestion)
- Verify notification sent to suggestion owner
- Verify realtime broadcast

---

### 4.2 User Votes (Anonymous)

**User Action**: Member votes on gender or birthdate prediction

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ User: Vote on Gender/Birthdate                               │
│ Input: baby_profile_id, vote_type, value                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ votes (INSERT or UPDATE)                                     │
│ - id (auto UUID)                                             │
│ - baby_profile_id                                            │
│ - user_id = auth.uid()                                       │
│ - vote_type ('gender' or 'birthdate')                       │
│ - value_text (for gender: 'boy'/'girl')                     │
│ - value_date (for birthdate: date)                          │
│ - is_anonymous = true (default)                             │
│ - created_at, updated_at                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ RLS: User can only see vote counts, not individual votes    │
│ Query for results hides user_id until reveal                │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `votes` - Vote recorded

**Privacy Considerations**:
- `is_anonymous = true` by default
- Application logic hides voter identity until reveal
- Aggregated results shown (count of votes per option)

**Test Assertions**:
- Verify vote created
- Verify is_anonymous flag
- Verify RLS allows member to vote
- Verify anonymity preserved in queries

---

## 5. Cache & Realtime Flows

### 5.1 Cache Invalidation Strategy

**Scenario**: Owner updates content, followers need to know

**Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ Owner Action: Upload Photo / Create Event / Add Item        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: update_owner_marker()                               │
│ Fires on INSERT/UPDATE/DELETE of content tables             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ owner_update_markers (UPDATE)                                │
│ SET: tiles_last_updated_at = NOW()                           │
│      updated_by_user_id = auth.uid()                         │
│      reason = 'photo_uploaded' / 'event_created' etc.       │
│ WHERE: baby_profile_id = :baby_id                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Realtime: Broadcast marker UPDATE to subscribers             │
│ All followers subscribed to owner_update_markers see update  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Follower Client: Receive marker update                      │
│ Compare new tiles_last_updated_at with cached timestamp     │
└─────────────────────────────────────────────────────────────┘
                          ↓
                [Is new timestamp > cached?]
                          ↓
        ┌─────────────────────────────────┐
        │ YES: Fetch fresh tile data      │
        │ NO: Keep using cache            │
        └─────────────────────────────────┘
```

**Benefits**:
- Followers don't subscribe to all content tables (bandwidth efficient)
- Single marker check determines if cache refresh needed
- Reduces realtime subscriptions from 15 tables to 1 marker table

**Test Assertions**:
- Verify marker updates on content changes
- Verify realtime broadcast of marker
- Verify follower cache logic responds to marker
- Verify no cache refresh when marker unchanged

---

### 5.2 Realtime Subscription Patterns

#### Owner Subscription (Per Baby)

```
┌─────────────────────────────────────────────────────────────┐
│ Owner Subscriptions (scoped to single baby)                 │
└─────────────────────────────────────────────────────────────┘

Subscribe to photos:
  supabase.from('photos')
    .on('INSERT', callback)
    .eq('baby_profile_id', currentBabyId)
    .subscribe()

Subscribe to events:
  supabase.from('events')
    .on('*', callback)  // INSERT, UPDATE, DELETE
    .eq('baby_profile_id', currentBabyId)
    .subscribe()

Subscribe to registry_purchases:
  supabase.from('registry_purchases')
    .on('INSERT', callback)
    .in('registry_item_id', [item_ids_for_this_baby])
    .subscribe()

Subscribe to notifications (user-scoped):
  supabase.from('notifications')
    .on('INSERT', callback)
    .eq('recipient_user_id', auth.uid())
    .subscribe()
```

#### Follower Subscription (Aggregated)

```
┌─────────────────────────────────────────────────────────────┐
│ Follower Subscriptions (aggregated across followed babies)  │
└─────────────────────────────────────────────────────────────┘

Subscribe to owner_update_markers:
  supabase.from('owner_update_markers')
    .on('UPDATE', callback)
    .in('baby_profile_id', followedBabyIds)
    .subscribe()

Subscribe to notifications (user-scoped):
  supabase.from('notifications')
    .on('INSERT', callback)
    .eq('recipient_user_id', auth.uid())
    .subscribe()

Optional: Direct subscriptions for high-priority updates
  supabase.from('photos')
    .on('INSERT', callback)
    .in('baby_profile_id', followedBabyIds)
    .subscribe()
```

**Test Assertions**:
- Verify subscriptions scoped correctly
- Verify events received within 2s
- Verify RLS filters realtime events
- Verify no cross-baby data leaks

---

## 6. Notification Flows

### 6.1 In-App Notification Creation

**Trigger Events** → **Notification Created**

```
┌─────────────────────────────────────────────────────────────┐
│ Notification Trigger Events                                  │
│ - New photo uploaded                                         │
│ - Event created                                              │
│ - Registry item purchased                                    │
│ - Event RSVP received                                        │
│ - New follower accepted invitation                           │
│ - Name suggestion liked                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: create_content_notifications()                      │
│ Determines recipients based on:                              │
│ - Event type (photo, event, purchase, etc.)                  │
│ - Membership (owners get follower actions, followers get     │
│   owner content)                                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ QUERY: Get recipients from baby_memberships                 │
│ SELECT user_id FROM baby_memberships                         │
│ WHERE baby_profile_id = :baby_id                             │
│   AND removed_at IS NULL                                     │
│   AND user_id != :actor_user_id (exclude action taker)      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ notifications (INSERT for each recipient)                    │
│ - recipient_user_id                                          │
│ - baby_profile_id                                            │
│ - type (photo_added, event_created, etc.)                   │
│ - payload (JSON with relevant IDs)                           │
│ - created_at                                                 │
│ - read_at = NULL                                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Realtime: Broadcast to each recipient's subscription        │
│ User sees notification appear in app instantly              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Optional: Edge Function triggers push notification          │
│ OneSignal sends push to device (if user opted in)           │
└─────────────────────────────────────────────────────────────┘
```

**Test Assertions**:
- Verify notification created for correct recipients
- Verify actor excluded from notifications
- Verify payload contains correct IDs for deep linking
- Verify realtime delivery
- (Mock) Verify push notification sent

---

### 6.2 User Reads Notification

**User Action**: User taps notification to read/view

**Data Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│ User: Tap Notification                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ notifications (UPDATE)                                       │
│ SET: read_at = NOW()                                         │
│ WHERE: id = notification_id                                  │
│   AND recipient_user_id = auth.uid()                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ App Navigation: Deep link to content                         │
│ Use payload JSON to navigate to:                             │
│ - Photo detail (photo_id)                                    │
│ - Event detail (event_id)                                    │
│ - Registry (registry_item_id)                                │
└─────────────────────────────────────────────────────────────┘
```

**Tables Modified**:
1. `notifications` - Mark as read

**Test Assertions**:
- Verify read_at timestamp set
- Verify RLS allows only recipient to mark as read
- Verify unread count decrements
- Verify deep link navigation works

---

## 7. Query Patterns

### 7.1 Common Owner Queries

#### Get Baby Profile with Stats
```sql
SELECT 
  bp.*,
  (SELECT COUNT(*) FROM photos WHERE baby_profile_id = bp.id) as photo_count,
  (SELECT COUNT(*) FROM events WHERE baby_profile_id = bp.id) as event_count,
  (SELECT COUNT(*) FROM registry_items WHERE baby_profile_id = bp.id) as registry_count,
  (SELECT COUNT(*) FROM baby_memberships 
   WHERE baby_profile_id = bp.id 
     AND role = 'follower' 
     AND removed_at IS NULL) as follower_count
FROM baby_profiles bp
WHERE bp.id = :baby_id
  AND EXISTS (
    SELECT 1 FROM baby_memberships
    WHERE baby_profile_id = bp.id
      AND user_id = auth.uid()
      AND role = 'owner'
      AND removed_at IS NULL
  );
```

#### Get Upcoming Events for Baby
```sql
SELECT e.*, p.display_name as creator_name,
  (SELECT COUNT(*) FROM event_rsvps WHERE event_id = e.id) as rsvp_count,
  (SELECT COUNT(*) FROM event_comments WHERE event_id = e.id AND deleted_at IS NULL) as comment_count
FROM events e
JOIN profiles p ON e.created_by_user_id = p.user_id
WHERE e.baby_profile_id = :baby_id
  AND e.starts_at > NOW()
ORDER BY e.starts_at ASC
LIMIT 10;
```

#### Get Pending Invitations
```sql
SELECT i.*, p.display_name as invitee_name
FROM invitations i
LEFT JOIN profiles p ON i.accepted_by_user_id = p.user_id
WHERE i.baby_profile_id = :baby_id
  AND i.status = 'pending'
  AND i.expires_at > NOW()
ORDER BY i.created_at DESC;
```

### 7.2 Common Follower Queries

#### Get All Followed Babies with Latest Activity
```sql
SELECT 
  bp.*,
  oum.tiles_last_updated_at as last_update,
  bm.relationship_label as my_relationship,
  (SELECT COUNT(*) FROM photos 
   WHERE baby_profile_id = bp.id 
     AND created_at > NOW() - INTERVAL '7 days') as recent_photos
FROM baby_profiles bp
JOIN baby_memberships bm ON bp.id = bm.baby_profile_id
JOIN owner_update_markers oum ON bp.id = oum.baby_profile_id
WHERE bm.user_id = auth.uid()
  AND bm.removed_at IS NULL
ORDER BY oum.tiles_last_updated_at DESC;
```

#### Get Recent Photos Across All Followed Babies
```sql
SELECT p.*, bp.name as baby_name, u.display_name as uploader_name,
  (SELECT COUNT(*) FROM photo_squishes WHERE photo_id = p.id) as squish_count,
  (SELECT COUNT(*) FROM photo_comments WHERE photo_id = p.id AND deleted_at IS NULL) as comment_count,
  EXISTS(SELECT 1 FROM photo_squishes WHERE photo_id = p.id AND user_id = auth.uid()) as i_squished
FROM photos p
JOIN baby_profiles bp ON p.baby_profile_id = bp.id
JOIN profiles u ON p.uploaded_by_user_id = u.user_id
WHERE p.baby_profile_id IN (
  SELECT baby_profile_id FROM baby_memberships
  WHERE user_id = auth.uid() AND removed_at IS NULL
)
ORDER BY p.created_at DESC
LIMIT 20;
```

#### Get Upcoming Events Across All Followed Babies
```sql
SELECT e.*, bp.name as baby_name, p.display_name as creator_name,
  er.status as my_rsvp_status,
  (SELECT COUNT(*) FROM event_rsvps WHERE event_id = e.id AND status = 'yes') as yes_count
FROM events e
JOIN baby_profiles bp ON e.baby_profile_id = bp.id
JOIN profiles p ON e.created_by_user_id = p.user_id
LEFT JOIN event_rsvps er ON e.id = er.event_id AND er.user_id = auth.uid()
WHERE e.baby_profile_id IN (
  SELECT baby_profile_id FROM baby_memberships
  WHERE user_id = auth.uid() AND removed_at IS NULL
)
  AND e.starts_at > NOW()
ORDER BY e.starts_at ASC
LIMIT 10;
```

#### Get Unread Notifications
```sql
SELECT n.*, bp.name as baby_name, p.display_name as actor_name
FROM notifications n
JOIN baby_profiles bp ON n.baby_profile_id = bp.id
LEFT JOIN profiles p ON (n.payload->>'user_id')::uuid = p.user_id
WHERE n.recipient_user_id = auth.uid()
  AND n.read_at IS NULL
ORDER BY n.created_at DESC
LIMIT 50;
```

### 7.3 Performance-Critical Queries

All queries above use these indexes:
- `idx_baby_memberships_user_active` on `(user_id) WHERE removed_at IS NULL`
- `idx_photos_baby_created` on `(baby_profile_id, created_at DESC)`
- `idx_events_baby_starts` on `(baby_profile_id, starts_at DESC)`
- `idx_notifications_recipient_unread` on `(recipient_user_id, created_at DESC) WHERE read_at IS NULL`

**Performance Targets**:
- Single baby queries: < 50ms
- Aggregated follower queries: < 200ms
- Notification queries: < 100ms

---

## Testing Checklist for Flutter Drive Tests

### User Onboarding Tests
- [ ] Sign up → verify profile & stats auto-created
- [ ] Owner creates baby → verify membership & marker created
- [ ] Follower accepts invite → verify membership & notification

### Owner Action Tests
- [ ] Upload photo → verify marker updated, notifications sent
- [ ] Create event → verify marker updated, notifications sent
- [ ] Add registry item → verify marker updated
- [ ] Send invitation → verify invitation created with expiry
- [ ] Delete comment → verify soft delete

### Follower Action Tests
- [ ] RSVP to event → verify RSVP recorded, stats updated
- [ ] Squish photo → verify squish recorded, stats updated, no double-squish
- [ ] Comment on photo → verify comment created, stats updated
- [ ] Purchase registry item → verify purchase recorded, owner notified
- [ ] Suggest name → verify suggestion created, unique per gender
- [ ] Like name suggestion → verify like recorded, owner notified

### Cache & Realtime Tests
- [ ] Owner updates content → verify marker timestamp changes
- [ ] Follower checks marker → verify cache invalidation logic
- [ ] Realtime event → verify received within 2s
- [ ] Multiple followers → verify no cross-baby data leaks

### Notification Tests
- [ ] Action triggers notification → verify notification created
- [ ] User reads notification → verify read_at set
- [ ] Deep link navigation → verify correct content displayed

### Query Performance Tests
- [ ] Owner baby queries → verify < 100ms
- [ ] Follower aggregated queries → verify < 300ms
- [ ] Notification queries → verify < 100ms
- [ ] RLS enforcement → verify no unauthorized access

---

## Conclusion

This document provides comprehensive data flow mappings for all user scenarios in the Nonna App. Each flow shows:
- User actions
- Database operations (INSERT/UPDATE/SELECT)
- Triggered functions and side effects
- Realtime broadcasts
- Tables modified
- Test assertions

Use these flows to:
1. Create Flutter drive tests that exercise complete user journeys
2. Validate data integrity at each step
3. Verify RLS policies enforce correct permissions
4. Measure query performance
5. Test realtime event propagation
6. Ensure cache invalidation works correctly

For any scenario not covered, follow the same pattern:
1. User action
2. Initial query/insert
3. Triggers that fire
4. Side effects (stats, notifications, activity)
5. Realtime broadcasts
6. Test assertions
