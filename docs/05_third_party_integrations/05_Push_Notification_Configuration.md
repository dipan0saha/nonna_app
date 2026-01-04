# Push Notification Configuration

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Configuration Guide  
**Section**: 2.3 - Third-Party Integrations Setup

## Executive Summary

This document provides comprehensive guidance for setting up push notifications for the Nonna App using OneSignal. Push notifications enable real-time engagement with users for photo uploads, comments, events, and other important updates. This guide covers OneSignal setup, device registration, notification types, Edge Function integration, and user preference management.

## References

- `docs/01_technical_requirements/api_integration_plan.md` - Push notification strategy (Section 2.2)
- `docs/02_architecture_design/security_privacy_architecture.md` - Notification security
- `docs/05_third_party_integrations/01_Supabase_Project_Configuration.md` - Edge Functions setup
- `docs/Production_Readiness_Checklist.md` - Section 2.3 requirements

---

## 1. OneSignal Setup

### 1.1 Create OneSignal Account

1. Navigate to [https://onesignal.com](https://onesignal.com)
2. Sign up for free account
3. Click "New App/Website"
4. Enter App Name: "Nonna App"
5. Select platform: "Flutter"

**Free Tier**:
- 10,000 subscribers
- Unlimited notifications
- Basic segmentation
- Analytics

### 1.2 Configure Flutter Platform

**iOS Configuration**:

1. Navigate to App Settings → Platforms → iOS
2. Upload APNs Auth Key (.p8 file):
   - Obtain from Apple Developer Portal
   - Settings → Keys → Create new key
   - Enable "Apple Push Notifications service (APNs)"
   - Download .p8 file
3. Enter:
   - Team ID (from Apple Developer account)
   - Key ID (from .p8 filename)
   - Bundle ID: `com.nonna.app`
4. Save configuration

**Android Configuration**:

1. Navigate to App Settings → Platforms → Android
2. Upload Firebase Server Key:
   - Obtain from Firebase Console
   - Project Settings → Cloud Messaging → Server Key
3. Enter:
   - Package Name: `com.nonna.app`
4. Save configuration

### 1.3 Get OneSignal Credentials

1. Navigate to Settings → Keys & IDs
2. Copy and save:
   - **App ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - **REST API Key**: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
3. Store securely in environment variables

---

## 2. Flutter Integration

### 2.1 Install Dependencies

```yaml
# pubspec.yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

### 2.2 Initialize OneSignal

```dart
// lib/main.dart

import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  // Initialize OneSignal
  await _initOneSignal();
  
  runApp(MyApp());
}

Future<void> _initOneSignal() async {
  // Set OneSignal App ID
  OneSignal.shared.setAppId('YOUR_ONESIGNAL_APP_ID');
  
  // Request notification permission (iOS)
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print('User accepted notifications: $accepted');
  });
  
  // Set external user ID (link to Supabase user)
  OneSignal.shared.setExternalUserId(
    Supabase.instance.client.auth.currentUser?.id ?? '',
  );
  
  // Handle notification opened
  OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    _handleNotificationOpened(result);
  });
  
  // Handle notification received while app is in foreground
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
    (OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    },
  );
}

void _handleNotificationOpened(OSNotificationOpenedResult result) {
  final additionalData = result.notification.additionalData;
  
  if (additionalData != null) {
    final type = additionalData['type'];
    final babyProfileId = additionalData['baby_profile_id'];
    final photoId = additionalData['photo_id'];
    
    // Navigate to relevant screen based on notification type
    switch (type) {
      case 'new_photo':
        navigatorKey.currentState?.pushNamed(
          '/photo-detail',
          arguments: {'photoId': photoId},
        );
        break;
      case 'new_comment':
        navigatorKey.currentState?.pushNamed(
          '/photo-detail',
          arguments: {'photoId': photoId},
        );
        break;
      // Handle other notification types...
    }
  }
}
```

### 2.3 Update External User ID on Login

```dart
// After successful login
Future<void> _onLoginSuccess(User user) async {
  await OneSignal.shared.setExternalUserId(user.id);
  print('OneSignal external user ID set: ${user.id}');
}

// On logout
Future<void> _onLogout() async {
  await OneSignal.shared.removeExternalUserId();
  await Supabase.instance.client.auth.signOut();
}
```

---

## 3. Notification Types and Triggers

### 3.1 Notification Types

**1. New Photo Notification**
- **Trigger**: Owner uploads photo to gallery
- **Recipients**: All followers of the baby profile
- **Title**: "New photo from [Baby Name]!"
- **Body**: "[Owner Name] shared a new photo"
- **Payload**: `{type: 'new_photo', baby_profile_id, photo_id}`

**2. New Comment Notification**
- **Trigger**: Follower comments on photo
- **Recipients**: Photo owner
- **Title**: "New comment on your photo"
- **Body**: "[Commenter Name]: [Comment text preview]"
- **Payload**: `{type: 'new_comment', baby_profile_id, photo_id, comment_id}`

**3. Event RSVP Notification**
- **Trigger**: Follower RSVPs to event
- **Recipients**: Event creator (owner)
- **Title**: "New RSVP for [Event Name]"
- **Body**: "[Follower Name] is attending"
- **Payload**: `{type: 'event_rsvp', baby_profile_id, event_id, rsvp_id}`

**4. Registry Purchase Notification**
- **Trigger**: Follower marks registry item as purchased
- **Recipients**: Registry owner
- **Title**: "Registry item purchased!"
- **Body**: "[Purchaser Name] purchased [Item Name]"
- **Payload**: `{type: 'registry_purchase', baby_profile_id, registry_item_id, purchase_id}`

**5. New Follower Notification**
- **Trigger**: Invitation accepted
- **Recipients**: Baby profile owners
- **Title**: "New follower!"
- **Body**: "[Follower Name] is now following [Baby Name]"
- **Payload**: `{type: 'new_follower', baby_profile_id, user_id}`

**6. Birth Announcement Notification**
- **Trigger**: Owner sets actual birth date
- **Recipients**: All followers
- **Title**: "[Baby Name] is here!"
- **Body**: "Born on [Birth Date]"
- **Payload**: `{type: 'birth_announcement', baby_profile_id}`

### 3.2 Database Triggers for Notifications

```sql
-- Create notification on new photo
CREATE OR REPLACE FUNCTION notify_new_photo()
RETURNS TRIGGER AS $$
DECLARE
  follower_id UUID;
BEGIN
  -- Insert notification for each follower
  FOR follower_id IN
    SELECT user_id FROM public.baby_memberships
    WHERE baby_profile_id = NEW.baby_profile_id
      AND user_id != NEW.uploaded_by_user_id
      AND removed_at IS NULL
  LOOP
    INSERT INTO public.notifications (user_id, baby_profile_id, title, body, type, payload)
    VALUES (
      follower_id,
      NEW.baby_profile_id,
      'New photo!',
      'New photo uploaded',
      'new_photo',
      jsonb_build_object('photo_id', NEW.id)
    );
  END LOOP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER new_photo_notification
AFTER INSERT ON public.photos
FOR EACH ROW EXECUTE FUNCTION notify_new_photo();
```

---

## 4. Edge Function for Push Notifications

### 4.1 Create Send Notification Function

```typescript
// supabase/functions/send-push-notification/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  try {
    const { notification_id } = await req.json();
    
    // Initialize Supabase client with service role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );
    
    // Fetch notification details
    const { data: notification, error } = await supabaseAdmin
      .from('notifications')
      .select('user_id, title, body, type, payload')
      .eq('id', notification_id)
      .single();
    
    if (error) throw error;
    
    // Check user notification preferences
    const { data: preferences } = await supabaseAdmin
      .from('notification_preferences')
      .select('*')
      .eq('user_id', notification.user_id)
      .single();
    
    // Check if user wants push notifications for this type
    const prefKey = `push_${notification.type}` as keyof typeof preferences;
    if (preferences && preferences[prefKey] === false) {
      return new Response(
        JSON.stringify({ skipped: true, reason: 'User preference disabled' }),
        { status: 200 }
      );
    }
    
    // Send push notification via OneSignal
    const oneSignalResponse = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Deno.env.get('ONESIGNAL_API_KEY')}`,
      },
      body: JSON.stringify({
        app_id: Deno.env.get('ONESIGNAL_APP_ID'),
        include_external_user_ids: [notification.user_id],
        headings: { en: notification.title },
        contents: { en: notification.body },
        data: notification.payload,
        ios_badgeType: 'Increase',
        ios_badgeCount: 1,
      }),
    });
    
    const oneSignalResult = await oneSignalResponse.json();
    
    return new Response(
      JSON.stringify({ success: true, result: oneSignalResult }),
      { status: 200 }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
});
```

### 4.2 Deploy Edge Function

```bash
# Set OneSignal secrets
supabase secrets set ONESIGNAL_API_KEY=your_rest_api_key
supabase secrets set ONESIGNAL_APP_ID=your_app_id

# Deploy function
supabase functions deploy send-push-notification
```

### 4.3 Trigger Edge Function from Database

```sql
-- Database function to invoke Edge Function
CREATE OR REPLACE FUNCTION trigger_push_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Invoke Edge Function to send push notification
  PERFORM net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/send-push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('request.jwt.claim.sub')
    ),
    body := jsonb_build_object('notification_id', NEW.id)
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on notification insert
CREATE TRIGGER send_push_notification_trigger
AFTER INSERT ON public.notifications
FOR EACH ROW EXECUTE FUNCTION trigger_push_notification();
```

---

## 5. User Notification Preferences

### 5.1 Preference Management UI

```dart
// lib/features/settings/pages/notification_preferences_screen.dart

class NotificationPreferencesScreen extends StatefulWidget {
  @override
  _NotificationPreferencesScreenState createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  late Map<String, bool> _preferences = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      setState(() {
        _preferences = Map<String, bool>.from(data);
        _loading = false;
      });
    } catch (e) {
      // Handle error or create default preferences
      setState(() => _loading = false);
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('notification_preferences')
          .upsert({
            'user_id': userId,
            key: value,
          });

      setState(() {
        _preferences[key] = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update preference')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Notification Preferences')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Notification Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('New Photos'),
            subtitle: Text('Get notified when new photos are uploaded'),
            value: _preferences['push_new_photos'] ?? true,
            onChanged: (value) => _updatePreference('push_new_photos', value),
          ),
          SwitchListTile(
            title: Text('New Comments'),
            subtitle: Text('Get notified of new comments on your photos'),
            value: _preferences['push_new_comments'] ?? true,
            onChanged: (value) => _updatePreference('push_new_comments', value),
          ),
          SwitchListTile(
            title: Text('Event RSVPs'),
            subtitle: Text('Get notified when someone RSVPs to your events'),
            value: _preferences['push_event_rsvps'] ?? true,
            onChanged: (value) => _updatePreference('push_event_rsvps', value),
          ),
          SwitchListTile(
            title: Text('Registry Purchases'),
            subtitle: Text('Get notified when registry items are purchased'),
            value: _preferences['push_registry_purchases'] ?? true,
            onChanged: (value) => _updatePreference('push_registry_purchases', value),
          ),
          SwitchListTile(
            title: Text('New Followers'),
            subtitle: Text('Get notified when someone starts following your baby'),
            value: _preferences['push_new_followers'] ?? true,
            onChanged: (value) => _updatePreference('push_new_followers', value),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Testing Push Notifications

### 6.1 Test Notification from OneSignal Dashboard

1. Navigate to OneSignal Dashboard → Messages → New Push
2. Select "Send to Test Users"
3. Enter External User ID (Supabase user ID)
4. Compose test message
5. Send and verify receipt on device

### 6.2 Test Edge Function

```bash
# Test Edge Function locally
supabase functions serve send-push-notification

# Invoke with test payload
curl -X POST http://localhost:54321/functions/v1/send-push-notification \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"notification_id": "test-notification-id"}'
```

---

## 7. Production Checklist

- [ ] OneSignal account created and configured
- [ ] iOS APNs certificates uploaded
- [ ] Android Firebase Server Key configured
- [ ] OneSignal SDK integrated in Flutter app
- [ ] External user IDs linked to Supabase users
- [ ] All notification types defined and tested
- [ ] Edge Function deployed and functioning
- [ ] Database triggers configured
- [ ] User preference management implemented
- [ ] Notification navigation tested
- [ ] Push notification permissions requested appropriately
- [ ] Analytics tracking for notification engagement

---

## Conclusion

This Push Notification Configuration guide provides comprehensive setup for OneSignal push notifications in the Nonna App. Following these guidelines ensures timely, relevant, and user-controlled push notifications that drive engagement.

**Next Steps**:

- Review `06_Analytics_Setup_Document.md` for analytics tracking

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Status**: Configuration Guide - Ready for Implementation
