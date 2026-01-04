# API Integration Plan

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Section**: 1.2 - Technical Requirements

## Executive Summary

This API Integration Plan defines the comprehensive integration strategy for the Nonna App, detailing how the application connects with Supabase Backend-as-a-Service (BaaS), third-party services (SendGrid, OneSignal), and internal APIs. The plan ensures secure, scalable, and performant integration aligned with business requirements and technical architecture.

The integration architecture consists of:
1. **Supabase Core Services**: Auth, Database (PostgreSQL), Storage, Realtime, Edge Functions
2. **Third-Party Services**: SendGrid (email), OneSignal (push notifications)
3. **Internal APIs**: Flutter app to backend communication via Supabase client SDK
4. **Future Integrations**: Instagram sharing, registry vendor APIs (post-MVP)

## References

This document references:

- `docs/00_requirement_gathering/business_requirements_document.md` - Integration requirements from business scope
- `docs/00_requirement_gathering/competitor_analysis_report.md` - Market positioning and feature parity
- `docs/01_technical_requirements/functional_requirements_specification.md` - Feature integration needs
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Technology stack and integration patterns
- `discovery/01_discovery/04_technical_requirements/Technical_Requirements.md` - Technical constraints

---

## 1. Supabase Integration

### 1.1 Supabase Authentication (Auth)

**Purpose**: Secure user authentication and session management using JWT-based authentication.

#### 1.1.1 Authentication Methods

**Email/Password Authentication**:
```dart
// Sign up with email/password
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'display_name': displayName}, // Stored in raw_user_meta_data
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Password reset
await supabase.auth.resetPasswordForEmail(email);
```

**OAuth 2.0 Authentication (Google, Facebook)**:
```dart
// Google OAuth
await supabase.auth.signInWithOAuth(
  Provider.google,
  redirectTo: 'io.supabase.nonna://login-callback/',
);

// Facebook OAuth
await supabase.auth.signInWithOAuth(
  Provider.facebook,
  redirectTo: 'io.supabase.nonna://login-callback/',
);
```

**Technical Specifications**:
- **JWT Tokens**: Access tokens with 1-hour expiration, refresh tokens with 30-day expiration
- **Token Storage**: Stored securely using `flutter_secure_storage` (iOS Keychain, Android Keystore)
- **Session Management**: Automatic token refresh handled by Supabase client
- **Rate Limiting**: 5 login attempts per 15 minutes per IP address (configured in Supabase)

#### 1.1.2 Email Verification

```dart
// Email verification link sent automatically on sign-up
// Configure email template in Supabase dashboard
// Verification link format: https://{project}.supabase.co/auth/v1/verify?token={token}&type=signup

// Check verification status
final user = supabase.auth.currentUser;
final isVerified = user?.emailConfirmedAt != null;

// Resend verification email
await supabase.auth.resend(
  type: OtpType.signup,
  email: email,
);
```

**Integration Requirements**:
- Configure email templates in Supabase dashboard
- Implement deep link handling for email verification callback
- Restrict unverified users from creating baby profiles (enforced via RLS)

#### 1.1.3 Authentication State Management

```dart
// Listen to auth state changes with Riverpod
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

// Use auth state in UI
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (state) => state.session != null ? HomeScreen() : LoginScreen(),
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error),
    );
  },
);
```

**Security Configurations**:
- **RLS Enforcement**: All database queries automatically filtered by `auth.uid()`
- **Service Role Key**: Stored in environment variables, used only in Edge Functions
- **Anon Key**: Public key for client-side operations, safe to expose

---

### 1.2 Supabase Database (PostgreSQL)

**Purpose**: Relational database for all application data with Row-Level Security (RLS).

#### 1.2.1 Database Client SDK Integration

```dart
// Initialize Supabase client
final supabase = Supabase.instance.client;

// Query with RLS (automatically filtered by user permissions)
final photos = await supabase
  .from('photos')
  .select('*, profiles!uploaded_by_user_id(*)')
  .eq('baby_profile_id', babyProfileId)
  .is_('deleted_at', null)
  .order('created_at', ascending: false)
  .limit(30);

// Insert with RLS
await supabase.from('photos').insert({
  'baby_profile_id': babyProfileId,
  'uploaded_by_user_id': supabase.auth.currentUser!.id,
  'storage_path': storagePath,
  'thumbnail_path': thumbnailPath,
  'caption': caption,
  'tags': tags,
});

// Update with RLS
await supabase
  .from('baby_profiles')
  .update({'name': newName})
  .eq('id', babyProfileId);

// Soft delete
await supabase
  .from('photos')
  .update({'deleted_at': DateTime.now().toIso8601String()})
  .eq('id', photoId);
```

#### 1.2.2 RLS Policy Examples

**Photos Table RLS**:
```sql
-- Owners can CRUD photos for their baby profiles
CREATE POLICY "Owners can manage photos"
ON photos FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM baby_memberships
    WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
    AND baby_memberships.user_id = auth.uid()
    AND baby_memberships.role = 'owner'
    AND baby_memberships.removed_at IS NULL
  )
);

-- Followers can read photos for babies they follow
CREATE POLICY "Followers can view photos"
ON photos FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM baby_memberships
    WHERE baby_memberships.baby_profile_id = photos.baby_profile_id
    AND baby_memberships.user_id = auth.uid()
    AND baby_memberships.removed_at IS NULL
  )
  AND deleted_at IS NULL
);
```

#### 1.2.3 Database Transactions

```dart
// Multi-step transaction example: Create baby profile + membership + stats
try {
  final babyProfileId = Uuid().v4();
  
  // Begin transaction (Supabase handles this internally)
  await supabase.from('baby_profiles').insert({
    'id': babyProfileId,
    'name': babyName,
    'expected_birth_date': expectedDate,
  });
  
  await supabase.from('baby_memberships').insert({
    'baby_profile_id': babyProfileId,
    'user_id': supabase.auth.currentUser!.id,
    'role': 'owner',
  });
  
  await supabase.from('owner_update_markers').insert({
    'baby_profile_id': babyProfileId,
    'tiles_last_updated_at': DateTime.now().toIso8601String(),
  });
} catch (e) {
  // Transaction automatically rolled back on error
  throw Exception('Failed to create baby profile: $e');
}
```

**Performance Optimizations**:
- **Connection Pooling**: Supabase manages connection pool (max 100 connections)
- **Query Caching**: Implement client-side caching with Hive/Isar
- **Pagination**: Use LIMIT/OFFSET or cursor-based pagination (30-50 items per page)
- **Indexing**: All foreign keys and hot query paths indexed (see Data Model Diagram)

---

### 1.3 Supabase Storage

**Purpose**: File storage for photos, profile pictures, and event cover images with CDN delivery.

#### 1.3.1 Storage Bucket Configuration

**Buckets**:
- `baby-profile-photos`: Baby profile pictures (public read, owner write)
- `user-avatars`: User profile photos (public read, user write)
- `gallery-photos`: Photo gallery images (RLS-protected, follower read, owner write)
- `event-photos`: Event cover images (RLS-protected)

**Storage Policies**:
```sql
-- Example: Gallery photos bucket policy
CREATE POLICY "Owners can upload photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'gallery-photos'
  AND EXISTS (
    SELECT 1 FROM baby_memberships
    WHERE baby_memberships.user_id = auth.uid()
    AND baby_memberships.role = 'owner'
    AND baby_memberships.removed_at IS NULL
  )
);

CREATE POLICY "Followers can view photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'gallery-photos'
  AND EXISTS (
    SELECT 1 FROM baby_memberships bm
    INNER JOIN photos p ON p.baby_profile_id = bm.baby_profile_id
    WHERE bm.user_id = auth.uid()
    AND bm.removed_at IS NULL
    AND p.storage_path = name
  )
);
```

#### 1.3.2 Photo Upload Flow

```dart
// 1. Compress image client-side
final compressedImage = await FlutterImageCompress.compressWithFile(
  file.absolute.path,
  quality: 70,
  minWidth: 1920,
  minHeight: 1920,
);

// 2. Upload to Supabase Storage
final fileName = '${Uuid().v4()}.jpg';
final storagePath = 'baby_${babyProfileId}/$fileName';

await supabase.storage
  .from('gallery-photos')
  .uploadBinary(
    storagePath,
    compressedImage,
    fileOptions: FileOptions(
      contentType: 'image/jpeg',
      upsert: false,
    ),
  );

// 3. Generate thumbnail via Edge Function
final thumbnailPath = await supabase.functions.invoke(
  'generate-thumbnail',
  body: {'storage_path': storagePath},
);

// 4. Create database entry
await supabase.from('photos').insert({
  'baby_profile_id': babyProfileId,
  'uploaded_by_user_id': supabase.auth.currentUser!.id,
  'storage_path': storagePath,
  'thumbnail_path': thumbnailPath,
  'caption': caption,
});

// 5. Get public URL for display
final photoUrl = supabase.storage
  .from('gallery-photos')
  .getPublicUrl(storagePath);
```

**Storage Limits**:
- **Free Tier**: 15GB per user account
- **Paid Tier**: Unlimited storage
- **File Validation**: JPEG/PNG only, max 10MB per photo (enforced client-side)
- **Upload Target**: < 5 seconds per photo

#### 1.3.3 CDN and Caching

```dart
// Leverage Supabase CDN for faster delivery
final cachedImageUrl = supabase.storage
  .from('gallery-photos')
  .getPublicUrl(
    storagePath,
    transform: TransformOptions(
      width: 300,
      height: 300,
      resize: ResizeMode.cover,
    ),
  );

// Use cached_network_image for client-side caching
CachedNetworkImage(
  imageUrl: cachedImageUrl,
  placeholder: (context, url) => SkeletonLoader(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: CustomCacheManager(), // 7-day cache
);
```

---

### 1.4 Supabase Realtime

**Purpose**: Real-time data synchronization for instant updates across devices.

#### 1.4.1 Realtime Subscription Setup

```dart
// Subscribe to new photos for specific baby profile
final subscription = supabase
  .from('photos:baby_profile_id=eq.$babyProfileId')
  .on(SupabaseEventTypes.insert, (payload) {
    final newPhoto = Photo.fromJson(payload.newRecord);
    ref.read(photosProvider.notifier).addPhoto(newPhoto);
  })
  .subscribe();

// Subscribe to multiple babies (follower view)
final followedBabyIds = ['id1', 'id2', 'id3'];
for (final babyId in followedBabyIds) {
  supabase
    .from('photos:baby_profile_id=eq.$babyId')
    .on(SupabaseEventTypes.insert, (payload) {
      // Handle new photo
    })
    .subscribe();
}

// Unsubscribe when leaving screen
@override
void dispose() {
  supabase.removeSubscription(subscription);
  super.dispose();
}
```

#### 1.4.2 Realtime Update Types

**Insert Events**: New photos, events, registry items, comments
```dart
.on(SupabaseEventTypes.insert, (payload) {
  // payload.newRecord contains inserted data
});
```

**Update Events**: Profile edits, event updates, registry changes
```dart
.on(SupabaseEventTypes.update, (payload) {
  // payload.oldRecord = old data
  // payload.newRecord = updated data
});
```

**Delete Events**: Soft deletes (deleted_at set)
```dart
.on(SupabaseEventTypes.update, (payload) {
  if (payload.newRecord['deleted_at'] != null) {
    // Handle soft delete
  }
});
```

**Performance Considerations**:
- **Subscription Scoping**: Always filter by baby_profile_id to reduce unnecessary broadcasts
- **Connection Limits**: Max 10,000 concurrent WebSocket connections (Supabase)
- **Update Latency**: Target < 2 seconds from event to client notification
- **Batching**: Batch rapid updates (e.g., bulk photo uploads) on client side

---

### 1.5 Supabase Edge Functions

**Purpose**: Serverless functions for server-side logic, third-party integrations, and compute-intensive operations.

#### 1.5.1 Edge Function Architecture

**Deployment**:
```bash
# Deploy Edge Function
supabase functions deploy generate-thumbnail --project-ref abc123

# Set environment variables
supabase secrets set SENDGRID_API_KEY=sg_xxx
supabase secrets set ONESIGNAL_API_KEY=os_xxx
```

**Invocation from Flutter**:
```dart
// Invoke Edge Function with authentication
final response = await supabase.functions.invoke(
  'generate-thumbnail',
  body: {'storage_path': storagePath},
  headers: {
    'Authorization': 'Bearer ${supabase.auth.currentSession!.accessToken}',
  },
);

if (response.status == 200) {
  final thumbnailPath = response.data['thumbnail_path'];
  // Use thumbnail path
} else {
  throw Exception('Thumbnail generation failed');
}
```

#### 1.5.2 Edge Functions List

**1. `generate-thumbnail`**
- **Purpose**: Generate 300x300 thumbnail from uploaded photo
- **Trigger**: Invoked after photo upload
- **Input**: `{storage_path: string}`
- **Output**: `{thumbnail_path: string}`
- **Dependencies**: Sharp (image processing library)

**2. `send-invitation-email`**
- **Purpose**: Send invitation email via SendGrid
- **Trigger**: Database trigger on invitations INSERT
- **Input**: `{invitation_id: uuid}`
- **Output**: `{email_sent: boolean}`
- **Third-Party**: SendGrid API

**3. `send-push-notification`**
- **Purpose**: Send push notification via OneSignal
- **Trigger**: Database trigger on notifications INSERT
- **Input**: `{notification_id: uuid, user_ids: uuid[]}`
- **Output**: `{notification_sent: boolean}`
- **Third-Party**: OneSignal API

**4. `validate-invitation-token`**
- **Purpose**: Validate and accept invitation
- **Trigger**: User clicks invitation link
- **Input**: `{token: string, relationship_label: string}`
- **Output**: `{baby_profile_id: uuid, success: boolean}`
- **Security**: Validates token, checks expiration, creates membership

**5. `weekly-email-digest`**
- **Purpose**: Send weekly email digest to users
- **Trigger**: Scheduled (cron: every Monday 9am)
- **Input**: None (processes all users)
- **Output**: `{emails_sent: number}`
- **Third-Party**: SendGrid API

#### 1.5.3 Edge Function Example: Generate Thumbnail

```typescript
// generate-thumbnail/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import sharp from 'https://esm.sh/sharp@0.31.3';

serve(async (req) => {
  try {
    const { storage_path } = await req.json();
    
    // Initialize Supabase client with service role
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );
    
    // Download original image
    const { data: imageData, error: downloadError } = await supabase
      .storage
      .from('gallery-photos')
      .download(storage_path);
    
    if (downloadError) throw downloadError;
    
    // Generate thumbnail
    const thumbnail = await sharp(await imageData.arrayBuffer())
      .resize(300, 300, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toBuffer();
    
    // Upload thumbnail
    const thumbnailPath = storage_path.replace('.jpg', '_thumb.jpg');
    const { error: uploadError } = await supabase
      .storage
      .from('gallery-photos')
      .upload(thumbnailPath, thumbnail, {
        contentType: 'image/jpeg',
        upsert: false,
      });
    
    if (uploadError) throw uploadError;
    
    return new Response(
      JSON.stringify({ thumbnail_path: thumbnailPath }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
```

---

## 2. Third-Party Service Integrations

### 2.1 SendGrid (Email Delivery)

**Purpose**: Transactional email delivery for invitations, password resets, and weekly digests.

#### 2.1.1 SendGrid Configuration

**API Setup**:
- **API Key**: Stored in Supabase Edge Function secrets
- **Sender Email**: noreply@nonna.app (verified domain)
- **Free Tier**: 100 emails/day (sufficient for MVP)
- **Paid Tier**: Essentials plan $19.95/month if needed

**Email Templates**:
1. **Invitation Email**: Invite users to follow baby profile
2. **Password Reset Email**: Reset password link
3. **Email Verification**: Verify email address
4. **Weekly Digest**: Summary of activity
5. **Birth Announcement**: Notify followers of baby arrival

#### 2.1.2 SendGrid Integration via Edge Function

```typescript
// send-invitation-email/index.ts
import sgMail from 'https://esm.sh/@sendgrid/mail@7.7.0';

serve(async (req) => {
  const { invitation_id } = await req.json();
  
  // Fetch invitation details from database
  const { data: invitation } = await supabase
    .from('invitations')
    .select('*, baby_profiles(*), profiles!invited_by_user_id(*)')
    .eq('id', invitation_id)
    .single();
  
  // Configure SendGrid
  sgMail.setApiKey(Deno.env.get('SENDGRID_API_KEY')!);
  
  // Send email
  const msg = {
    to: invitation.invitee_email,
    from: 'noreply@nonna.app',
    subject: `${invitation.profiles.display_name} invited you to follow ${invitation.baby_profiles.name}`,
    html: `
      <h1>You're Invited!</h1>
      <p>${invitation.profiles.display_name} has invited you to follow ${invitation.baby_profiles.name} on Nonna.</p>
      <a href="https://nonna.app/invite/${invitation.token_hash}">Accept Invitation</a>
      <p>This invitation expires in 7 days.</p>
    `,
  };
  
  await sgMail.send(msg);
  
  return new Response(JSON.stringify({ email_sent: true }), { status: 200 });
});
```

**Error Handling**:
- Retry failed emails (3 attempts with exponential backoff)
- Log all email delivery attempts to database
- Alert on repeated failures (> 10 failures per hour)

---

### 2.2 OneSignal (Push Notifications)

**Purpose**: Push notification delivery to iOS and Android devices.

#### 2.2.1 OneSignal Configuration

**Setup**:
- **App ID**: Stored in Flutter app config
- **API Key**: Stored in Supabase Edge Function secrets
- **Free Tier**: 10,000 subscribers, unlimited notifications
- **Platforms**: iOS (APNs), Android (FCM)

**Device Registration**:
```dart
// Initialize OneSignal in Flutter
import 'package:onesignal_flutter/onesignal_flutter.dart';

OneSignal.shared.setAppId('your-onesignal-app-id');

// Request notification permission
OneSignal.shared.promptUserForPushNotificationPermission();

// Set external user ID (link to Supabase user)
OneSignal.shared.setExternalUserId(supabase.auth.currentUser!.id);

// Handle notification opened
OneSignal.shared.setNotificationOpenedHandler((notification) {
  // Navigate to relevant screen based on notification payload
  final payload = notification.notification.additionalData;
  navigateToScreen(payload);
});
```

#### 2.2.2 Push Notification Triggers

**Notification Types**:
1. **New Photo**: Follower notified when owner uploads photo
2. **New Comment**: Owner notified when follower comments
3. **Event RSVP**: Owner notified when follower RSVPs
4. **Registry Purchase**: Owner notified when item purchased
5. **New Follower**: Owner notified when invitation accepted
6. **Birth Announcement**: All followers notified of baby arrival

#### 2.2.3 OneSignal Integration via Edge Function

```typescript
// send-push-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { notification_id, user_ids } = await req.json();
  
  // Fetch notification details
  const { data: notification } = await supabase
    .from('notifications')
    .select('*')
    .eq('id', notification_id)
    .single();
  
  // Send to OneSignal
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${Deno.env.get('ONESIGNAL_API_KEY')}`,
    },
    body: JSON.stringify({
      app_id: Deno.env.get('ONESIGNAL_APP_ID'),
      include_external_user_ids: user_ids,
      headings: { en: notification.title },
      contents: { en: notification.body },
      data: notification.payload,
    }),
  });
  
  const result = await response.json();
  return new Response(JSON.stringify(result), { status: 200 });
});
```

**Notification Preferences**:
```dart
// User can customize notification preferences
await supabase.from('user_preferences').upsert({
  'user_id': supabase.auth.currentUser!.id,
  'push_new_photos': true,
  'push_new_comments': true,
  'push_event_rsvps': true,
  'push_registry_purchases': true,
  'push_new_followers': true,
});

// Edge Function checks preferences before sending
```

---

## 3. Future Integrations (Post-MVP)

### 3.1 Instagram Sharing

**Purpose**: Allow owners to share birth announcements to Instagram with Nonna watermark.

**Implementation**:
- Use native share sheet (iOS/Android) via `share_plus` package
- Generate shareable image with Nonna watermark
- No direct Instagram API integration required

```dart
import 'package:share_plus/share_plus.dart';

// Generate announcement image with watermark
final announcementImage = await generateAnnouncementImage(
  babyName: babyName,
  birthDate: birthDate,
  photoUrl: photoUrl,
);

// Share via native sheet (user selects Instagram)
await Share.shareXFiles(
  [XFile(announcementImage.path)],
  text: 'Meet our baby! Created with Nonna App.',
);
```

### 3.2 Registry Vendor APIs

**Purpose**: Direct integration with Amazon, Target, BuyBuy Baby for one-click purchasing.

**Approach**:
- Affiliate partnerships for revenue sharing
- API integrations for product search, price updates
- Deep linking to vendor apps/websites

**Not in MVP**: Manual URL entry for registry items sufficient for MVP

### 3.3 Analytics Integration

**Purpose**: Product analytics for user behavior tracking and KPI measurement.

**Recommended Services**:
- **Amplitude**: Privacy-conscious, strong retention analysis
- **Mixpanel**: Event-based analytics, funnel analysis
- **Firebase Analytics**: Free, integrated with Flutter

**Events to Track**:
- User registration, login, profile creation
- Photo upload, comment, squish
- Event creation, RSVP
- Registry item added, purchased
- Screen views, session duration

---

## 4. API Security and Best Practices

### 4.1 Authentication and Authorization

**JWT Token Management**:
```dart
// Automatically handle token refresh
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  if (session != null) {
    // Token refreshed automatically by Supabase client
    print('New access token: ${session.accessToken}');
  }
});
```

**RLS Policy Enforcement**:
- Never bypass RLS by using service role key in client
- All client queries automatically filtered by RLS
- Service role key only in Edge Functions (server-side)

### 4.2 Error Handling

```dart
// Standardized error handling
try {
  final data = await supabase.from('photos').select();
} on PostgrestException catch (e) {
  // Database query error
  print('Database error: ${e.message}');
  showErrorDialog('Failed to load photos. Please try again.');
} on StorageException catch (e) {
  // Storage operation error
  print('Storage error: ${e.message}');
  showErrorDialog('Failed to upload photo. Please try again.');
} catch (e) {
  // Generic error
  print('Unexpected error: $e');
  showErrorDialog('Something went wrong. Please try again.');
}
```

### 4.3 Rate Limiting

**Supabase Rate Limits** (Free Tier):
- **Database**: 500 requests per second
- **Storage**: 200 requests per second
- **Realtime**: 10,000 concurrent connections
- **Edge Functions**: 100,000 invocations per month

**Client-Side Rate Limiting**:
```dart
// Debounce rapid user actions
Timer? _debounce;

void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    performSearch(query);
  });
}
```

### 4.4 API Monitoring and Logging

**Supabase Dashboard Metrics**:
- API request volume and latency
- Database query performance
- Storage usage and bandwidth
- Realtime connection count

**Sentry Integration**:
```dart
// Capture API errors in Sentry
Sentry.captureException(
  exception,
  stackTrace: stackTrace,
  hint: Hint.withMap({
    'endpoint': 'photos',
    'operation': 'select',
    'user_id': supabase.auth.currentUser?.id,
  }),
);
```

---

## 5. API Testing Strategy

### 5.1 Integration Testing

```dart
// Test Supabase integration
testWidgets('Photo upload integration test', (tester) async {
  // Setup test Supabase client
  final testSupabase = SupabaseClient(
    'https://test-project.supabase.co',
    'test-anon-key',
  );
  
  // Sign in test user
  await testSupabase.auth.signInWithPassword(
    email: 'test@example.com',
    password: 'test123!',
  );
  
  // Upload photo
  final photoData = File('test_photo.jpg').readAsBytesSync();
  final storagePath = 'test/${Uuid().v4()}.jpg';
  
  await testSupabase.storage
    .from('gallery-photos')
    .uploadBinary(storagePath, photoData);
  
  // Verify photo entry created
  final photos = await testSupabase
    .from('photos')
    .select()
    .eq('storage_path', storagePath);
  
  expect(photos.length, 1);
});
```

### 5.2 Edge Function Testing

```bash
# Test Edge Function locally
supabase functions serve generate-thumbnail

# Invoke with test payload
curl -X POST http://localhost:54321/functions/v1/generate-thumbnail \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"storage_path": "test/photo.jpg"}'
```

### 5.3 Third-Party Integration Testing

**SendGrid Test Mode**:
```typescript
// Use SendGrid sandbox mode for testing
sgMail.setApiKey(Deno.env.get('SENDGRID_TEST_API_KEY')!);
// Emails sent to sandbox, not delivered to recipients
```

**OneSignal Test Users**:
```dart
// Add test user to OneSignal
OneSignal.shared.setExternalUserId('test-user-id');
// Send test notifications to verify delivery
```

---

## 6. API Documentation

### 6.1 Internal API Documentation

**Supabase Schema Documentation**:
- Generate with `supabase gen types typescript`
- Auto-generate Dart types from TypeScript definitions
- Maintain API changelog for breaking changes

**Edge Function Documentation**:
```typescript
/**
 * Generate Thumbnail Edge Function
 * 
 * @param {string} storage_path - Path to original image in Supabase Storage
 * @returns {object} { thumbnail_path: string } - Path to generated thumbnail
 * @throws {Error} If image processing fails
 * 
 * @example
 * const response = await supabase.functions.invoke('generate-thumbnail', {
 *   body: { storage_path: 'baby_123/photo.jpg' }
 * });
 */
```

### 6.2 Developer Onboarding

**Setup Guide**:
1. Clone repository
2. Install Supabase CLI
3. Run `supabase start` (local development)
4. Set environment variables (.env)
5. Run migrations: `supabase db reset`
6. Deploy Edge Functions: `supabase functions deploy`

---

## Conclusion

This API Integration Plan provides a comprehensive, secure, and scalable integration strategy for the Nonna App. The architecture leverages Supabase BaaS for core functionality (auth, database, storage, realtime), integrates essential third-party services (SendGrid, OneSignal), and prepares for future enhancements (Instagram, registry vendors, analytics).

**Key Strengths**:
1. **Supabase-First**: Unified BaaS reduces integration complexity
2. **Security**: JWT auth, RLS policies, secure token storage
3. **Real-Time**: Instant updates via Supabase Realtime subscriptions
4. **Scalability**: Edge Functions for compute-intensive operations
5. **Monitoring**: Comprehensive error tracking and performance monitoring

**Implementation Priority**:
- **P0 (Critical)**: Supabase Auth, Database, Storage, Realtime
- **P1 (High)**: SendGrid, OneSignal, Edge Functions (thumbnail, invitations)
- **P2 (Medium)**: Weekly digest, advanced monitoring
- **P3 (Future)**: Instagram sharing, registry vendor APIs, analytics

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Next Review**: Before Integration Implementation Phase
