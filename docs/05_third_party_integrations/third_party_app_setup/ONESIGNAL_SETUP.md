# OneSignal Setup Guide for Nonna App

## Table of Contents
1. [What is OneSignal?](#what-is-onesignal)
2. [Why Does Nonna App Need It?](#why-does-nonna-app-need-it)
3. [Pricing & Capacity](#pricing--capacity)
4. [Pre-requisites](#pre-requisites)
5. [Step-by-Step Setup](#step-by-step-setup)
6. [Flutter Integration](#flutter-integration)
7. [Testing Push Notifications](#testing-push-notifications)
8. [Troubleshooting](#troubleshooting)

---

## What is OneSignal?

**OneSignal** is a leading customer engagement platform that specializes in **push notifications**. It provides:

- **Cross-platform push notification delivery** - Send notifications to iOS and Android users from a single platform
- **User segmentation** - Target specific groups of users based on behavior, demographics, or custom properties
- **Analytics & reporting** - Track notification delivery, opens, and user engagement
- **API access** - Integrate push notifications into your backend servers
- **Rich notifications** - Support for images, buttons, and interactive content
- **Scheduling** - Schedule notifications to send at specific times or conditions
- **A/B testing** - Test different message variations to optimize engagement

Think of it as a **smart postal service for your app** - it handles delivery, tracking, and analytics of push notifications.

---

## Why Does Nonna App Need It?

Nonna App is a **family event and reminder management application**. Push notifications are **critical** for:

### 1. **Event Reminders**
   - Remind family members about upcoming events/dinners
   - Send notifications 1 hour, 1 day, or 1 week before events
   - Increase attendance rates

### 2. **RSVP Notifications**
   - Notify when someone RSVPs to an event
   - Alert if someone cancels their RSVP
   - Keep event organizers informed in real-time

### 3. **Photo & Memory Updates**
   - Notify when new family photos are uploaded
   - Inform about photo comments or reactions
   - Encourage family engagement

### 4. **Registry Updates**
   - Alert when someone adds items to a registry
   - Notify when items are claimed
   - Update on registry progress

### 5. **User Re-engagement**
   - Bring back inactive users
   - Remind them to check app for new content
   - Improve daily active users (DAU)

### 6. **Important Announcements**
   - Broadcast family announcements
   - Emergency notifications
   - Schedule changes or cancellations

**Without push notifications**, users must manually open the app to see updates, resulting in:
- ❌ Lower engagement
- ❌ Missed events
- ❌ Poor user retention
- ❌ Less app usage

**With OneSignal**, you get:
- ✅ Real-time updates even when app is closed
- ✅ 4-10x increase in user engagement
- ✅ Better event attendance
- ✅ Higher user retention

---

## Pricing & Capacity

### Free Tier
- **Cost**: $0
- **Monthly Active Users (MAU)**: Up to 30,000
- **Features**: All core features included
- **Support**: Community support
- **Perfect for**: Startups, development, testing
- **No credit card required** to get started

### Paid Tiers
- **Starter**: $99-299/month (depends on MAU)
- **Standard**: $499+/month
- **Enterprise**: Custom pricing

### Nonna App Usage
For a family app with ~100-1000 active users, the **free tier is more than sufficient**. You only pay when you exceed 30,000 monthly active users.

---

## Pre-requisites

Before setting up OneSignal, ensure you have:

### Required
- [ ] OneSignal account (free signup)
- [ ] Apple Developer Account (for iOS push certificates)
- [ ] Google Cloud Console project with Firebase Cloud Messaging (FCM) enabled
- [ ] Flutter project with pubspec.yaml
- [ ] Android keystore files (release & debug)
- [ ] iOS provisioning profiles

### Recommended
- [ ] Understanding of Firebase Cloud Messaging (FCM)
- [ ] Access to your app's code repository
- [ ] 30-45 minutes of setup time

---

## Step-by-Step Setup

### Phase 1: OneSignal Account Setup

#### Step 1.1: Create OneSignal Account
1. Go to https://onesignal.com
2. Click **"Sign up free"** button
3. Enter your email and create password
4. Verify your email address
5. Complete your profile

#### Step 1.2: Create a New App
1. In OneSignal dashboard, click **"New App or Website"**
2. Enter app name: **`nonna_app`**
3. Select **"Native Mobile App"**
4. Choose platforms: **Select both Android AND iOS**
5. Click **"Create"**

#### Step 1.3: Get Your App ID
1. Navigate to **Settings → Keys & IDs**
2. Copy the **App ID** (format: `12345678-1234-1234-1234-123456789012`)
3. Save this in a safe place - you'll need it for Flutter

---

### Phase 2: Android Configuration

#### Step 2.1: Set Up Firebase Cloud Messaging (FCM)

**A. In Google Cloud Console:**

1. Go to https://console.cloud.google.com
2. Create a new project or select existing:
   - Project name: `nonna-app` (or similar)
   - Click **Create**
3. Enable Firebase Cloud Messaging:
   - In search bar, search for "Cloud Messaging API"
   - Click on result
   - Click **Enable**
4. Create Service Account:
   - Go to **IAM & Admin → Service Accounts**
   - Click **Create Service Account**
   - Service account name: `onesignal-fcm`
   - Click **Create and Continue**
   - Grant role: **Editor** (under "Basic" roles)
   - Click **Continue** then **Done**
5. Create API Key:
   - Click the service account you just created
   - Go to **Keys** tab
   - Click **Add Key → Create new key**
   - Choose **JSON**
   - Click **Create**
   - Download the JSON file (keep it safe!)

**B. In OneSignal Dashboard:**

1. Go to OneSignal → Settings → Android
2. Under **Firebase Server API Key**:
   - Open the downloaded JSON file
   - Find the field `"private_key"`
   - Copy the entire key (including `-----BEGIN...` and `-----END...`)
3. Paste into OneSignal's **Firebase Server API Key** field
4. Also add your **Google Project Number**:
   - In Google Cloud Console, go to project settings
   - Copy **Project Number** (not Project ID)
   - Paste in OneSignal under **GCM/FCM Project Number**
5. Click **Save**

#### Step 2.2: Configure Android in OneSignal

1. Still in OneSignal → Settings → Android
2. Fill in:
   - **Android Package Name**: `com.la_nonna.nonna_app` (from Android manifest)
   - **Icon Size**: 256x256
3. Upload app icon (PNG format)
4. Click **Save**

---

### Phase 3: iOS Configuration

#### Step 3.1: Generate Apple Push Certificate

**A. In Apple Developer Account:**

1. Go to https://developer.apple.com/account
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Keys** on the left
4. Click **Create a new key** (+ icon)
5. Name it: `onesignal_push_key`
6. Check **Apple Push Notifications service (APNs)**
7. Click **Continue** → **Register** → **Download**
8. Save the `.p8` file securely

**B. Get Your Apple Team ID:**

1. From Apple Developer, go to **Membership**
2. Copy your **Team ID** (8-character code like `A1B2C3D4E5`)

#### Step 3.2: Configure iOS in OneSignal

1. Go to OneSignal → Settings → iOS
2. Upload the `.p8` certificate:
   - Click **Choose File**
   - Select your downloaded `.p8` file
3. Enter:
   - **Apple Team ID**: (from step 3.1)
   - **Key ID**: (shown in Apple Developer account, matches filename)
   - **Bundle ID**: `com.laNonna.nonnaApp` (from iOS Info.plist)
4. Click **Save**

#### Step 3.3: Update iOS Provisioning Profiles

Ensure your development and distribution provisioning profiles include APNs capability:

1. In Apple Developer → Identifiers
2. Select your app ID (`com.laNonna.nonnaApp`)
3. Verify **Push Notifications** is enabled
4. Regenerate provisioning profiles if needed
5. Download and install in Xcode

---

## Flutter Integration

### Step 1: Add OneSignal to pubspec.yaml

Open `pubspec.yaml` and add:

```yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

Then run:
```bash
flutter pub get
```

### Step 2: Initialize OneSignal in main.dart

Update `lib/main.dart`:

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  OneSignal.initialize("YOUR_ONESIGNAL_APP_ID");
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}
```

Replace `YOUR_ONESIGNAL_APP_ID` with your App ID from OneSignal dashboard.

### Step 3: Update .env File

Update your `.env` file:

```env
ONESIGNAL_APP_ID=12345678-1234-1234-1234-123456789012
```

### Step 4: Load Environment Variables (Optional)

If using a `.env` loader in Flutter:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}
```

### Step 5: Handle Notification Events (Optional but Recommended)

Add notification listeners to handle when users tap notifications:

```dart
void _setupOneSignalListeners() {
  // Listen for notification open
  OneSignal.Notifications.addClickListener((event) {
    print('Notification clicked: ${event.notification.body}');

    // Navigate to relevant screen based on notification data
    final data = event.notification.additionalData;
    if (data != null) {
      String? eventId = data['event_id'];
      String? type = data['type'];

      // Navigate based on type
      if (type == 'event') {
        // Navigate to event details
      } else if (type == 'photo') {
        // Navigate to photos
      }
    }
  });

  // Listen for notification display
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print('Notification will display: ${event.notification.body}');
    // Decide whether to show notification in foreground
    event.notification.display();
  });
}
```

Call this in your app initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);

  _setupOneSignalListeners();

  runApp(const MyApp());
}
```

### Step 6: Request Notification Permissions

The app should request notification permissions. Add this when app launches or on first login:

```dart
void requestNotificationPermissions() async {
  final permission = await OneSignal.Notifications.requestPermission(true);
  if (permission) {
    print('Notification permission granted');
  } else {
    print('Notification permission denied');
  }
}
```

---

## Testing Push Notifications

### Test 1: Send Via OneSignal Dashboard

1. Open OneSignal dashboard
2. Click **Campaigns** → **New Campaign**
3. Select **Notification**
4. Fill in:
   - **Message**: "Test notification from OneSignal"
   - **Heading**: "Hello Nonna!"
5. Under "Recipients":
   - Select **All Users** (or test user)
6. Click **Review** → **Send Now**
7. Watch your phone - notification should appear!

### Test 2: Send Per User

1. Get your device's **OneSignal Player ID**:
   ```dart
   String? playerId = await OneSignal.User.pushSubscription.id;
   print('Player ID: $playerId');
   ```

2. In OneSignal dashboard → **Campaigns** → **New Campaign**
3. Under Recipients, select **Specific Players**
4. Paste your Player ID
5. Send notification

### Test 3: Check Notification History

1. In OneSignal dashboard → **Campaigns**
2. Click on sent campaign
3. View:
   - ✅ Delivered count
   - 👁️ Opened count
   - ❌ Failed count

---

## Troubleshooting

### Common Issues & Solutions

#### "OneSignal Not Showing Notifications"

**Problem**: Notifications sent but not appearing on device

**Solutions**:
1. Check notification permissions are granted
   ```bash
   # Android: Settings → Apps → Permissions → Notifications
   # iOS: Settings → App → Notifications
   ```
2. Verify FCM credentials are correct in OneSignal
3. Check Android logcat for errors:
   ```bash
   flutter logs | grep onesignal
   ```

#### "Invalid Firebase Credentials"

**Problem**: OneSignal shows red error for Firebase Server API Key

**Solutions**:
1. Verify API key format (should have `-----BEGIN PRIVATE KEY-----` at start)
2. Ensure you used the `private_key` field from JSON, not entire file
3. Regenerate the key in Google Cloud Console if needed
4. Double-check Project Number vs Project ID

#### "iOS Certificate Expired"

**Problem**: iOS push notifications stop working after time period

**Solutions**:
1. Go to Apple Developer and download new `.p8` file
2. Update in OneSignal → Settings → iOS
3. Re-upload certificate

#### "Not Receiving Push on App Closed"

**Problem**: Notifications only work when app is open

**Solutions**:
1. Ensure app is not force-closed
2. Check notification permissions in OS settings
3. Verify FCM service is running properly
4. Check `AndroidManifest.xml` has correct permissions:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

#### "Wrong Notification Count"

**Problem**: OneSignal shows different count than devices received

**Solutions**:
1. Some devices may not have notifications enabled
2. Tests devices may filter notifications
3. Check OneSignal logs for delivery failures
4. Wait 5-10 minutes - stats update with delay

---

## Backend Integration (Optional)

If you want to send notifications from your backend (Supabase Edge Functions), use OneSignal REST API:

```javascript
// Example: Supabase Edge Function
const response = await fetch('https://onesignal.com/api/v1/notifications', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': 'Basic YOUR_REST_API_KEY',
  },
  body: JSON.stringify({
    app_id: 'YOUR_ONESIGNAL_APP_ID',
    contents: { en: 'Notification body' },
    headings: { en: 'Notification title' },
    included_segments: ['All'], // or specific user IDs
  }),
});
```

Get your REST API Key from: OneSignal → Settings → Keys & IDs

---

## Next Steps

After setup is complete:

1. ✅ Test push notifications work on iOS and Android
2. ✅ Add notification handling in your app
3. ✅ Design notification templates for each feature
4. ✅ Document notification types and payloads
5. ✅ Set up notification scheduling (events, reminders)
6. ✅ Monitor OneSignal analytics
7. ✅ Optimize frequency to prevent user opt-out

---

## Useful Links

- **OneSignal Documentation**: https://documentation.onesignal.com
- **Flutter OneSignal Plugin**: https://pub.dev/packages/onesignal_flutter
- **FCM Setup Guide**: https://firebase.google.com/docs/cloud-messaging/

---

## Support

If you encounter issues:

1. Check OneSignal docs: https://documentation.onesignal.com/docs
2. Review Flutter plugin GitHub: https://github.com/OneSignal/OneSignal-Flutter-SDK
3. Check OneSignal support: https://onesignal.com/support
4. See FCM troubleshooting: https://firebase.google.com/docs/cloud-messaging/troubleshooting

---

**Last Updated**: March 2, 2026
**Status**: Ready for Production
