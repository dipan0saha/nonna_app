# Firebase Analytics Setup Guide for nonna_app

## Overview

Firebase Analytics is Google's free analytics solution that tracks user behavior, engagement metrics, and custom events in your mobile app. It provides insights into how users interact with your app without requiring additional payment.

### What is Firebase Analytics?

Firebase Analytics automatically collects key events like app opens, in-app purchases, and user engagement. You can also track custom events specific to your business logic.

### Why nonna_app Needs It

The nonna_app family platform benefits from analytics to understand:
- **User Engagement**: How often families check the calendar, view photos, or update the registry
- **Feature Usage**: Which features are most popular (calendar, gallery, gamification, etc.)
- **User Demographics**: Age groups, locations, family sizes using the app
- **Funnel Analysis**: Drop-off points in onboarding, RSVP flows, or photo sharing
- **Retention**: How long families continue using the app after installation
- **Event Tracking**: Photo uploads, RSVP confirmations, registry item selections, vote participation

### Pricing

**Firebase Analytics is FREE** with unlimited events and users. All data collected is included in Google Cloud's free tier.

---

## Setup Instructions

### Step 1: Ensure Firebase Project is Configured

Firebase Analytics is automatically initialized when you set up Firebase in your Flutter project. Verify your `firebase.json` configuration exists and is properly set up.

Check that your Flutter project has the Firebase dependencies in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.4.0
  firebase_analytics: ^11.2.0  # Add this if not present
```

### Step 2: Initialize Firebase Analytics in Your App

In your main app file, ensure Firebase is initialized:

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Analytics is now initialized automatically
  runApp(const MyApp());
}
```

### Step 3: Android Configuration

1. **Firebase Gradle Plugin**: Ensure your `android/build.gradle` includes:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

2. **Module-level `android/app/build.gradle`**:

```gradle
plugins {
  id 'com.android.application'
  id 'com.google.gms.google-services'
  id 'com.google.firebase.crashlytics'
}
```

3. **Manifest permissions** (`android/app/src/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Step 4: iOS Configuration

1. **Add Firebase to your iOS app**:

```bash
cd ios
pod install --repo-update
cd ..
```

2. **Ensure `GoogleService-Info.plist` is in Xcode**:
   - Open `ios/Runner.xcworkspace`
   - Drag `GoogleService-Info.plist` into Xcode
   - Ensure it's added to the `Runner` target

3. **iOS Deployment Target**: Ensure iOS deployment target is 13.0 or higher in Xcode

---

## Tracking Custom Events

### Core Events to Track in nonna_app

Here are the key events your family app should track:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// 1. Calendar Events
Future<void> trackCalendarEventViewed(String eventType) async {
  await analytics.logEvent(
    name: 'calendar_event_viewed',
    parameters: {
      'event_type': eventType, // 'birthday', 'holiday', 'family_gathering'
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

Future<void> trackEventRsvpSubmitted(String rsvpStatus) async {
  await analytics.logEvent(
    name: 'event_rsvp_submitted',
    parameters: {
      'status': rsvpStatus, // 'attending', 'not_attending', 'maybe'
      'event_type': 'calendar_event',
    },
  );
}

// 2. Photo Gallery Events
Future<void> trackPhotoUploaded(String photoType) async {
  await analytics.logEvent(
    name: 'photo_uploaded',
    parameters: {
      'photo_type': photoType, // 'portrait', 'landscape', 'group'
      'file_size_kb': 1024,
    },
  );
}

Future<void> trackPhotoShared(String shareMethod) async {
  await analytics.logEvent(
    name: 'photo_shared',
    parameters: {
      'share_method': shareMethod, // 'message', 'social', 'print'
    },
  );
}

Future<void> trackPhotoCommentAdded() async {
  await analytics.logEvent(
    name: 'photo_comment_added',
    parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

// 3. Registry Events
Future<void> trackRegistryItemSelected(String itemCategory) async {
  await analytics.logEvent(
    name: 'registry_item_selected',
    parameters: {
      'category': itemCategory, // 'gifts', 'wishlist', 'education'
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

Future<void> trackRegistryItemPurchased(double price) async {
  await analytics.logEvent(
    name: 'registry_item_purchased',
    parameters: {
      'value': price,
      'currency': 'USD',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

// 4. Gamification Events
Future<void> trackVoteSubmitted(String voteType) async {
  await analytics.logEvent(
    name: 'vote_submitted',
    parameters: {
      'vote_type': voteType, // 'photo_vote', 'name_suggestion'
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

Future<void> trackGameRewardEarned(String rewardType) async {
  await analytics.logEvent(
    name: 'game_reward_earned',
    parameters: {
      'reward_type': rewardType, // 'badge', 'points', 'achievement'
      'points': 100,
    },
  );
}

// 5. Engagement Events
Future<void> trackSessionStart() async {
  await analytics.logEvent(
    name: 'session_started',
    parameters: {
      'app_version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

Future<void> trackFeatureUsed(String featureName) async {
  await analytics.logEvent(
    name: 'feature_used',
    parameters: {
      'feature': featureName, // 'calendar', 'gallery', 'registry', 'gamification'
      'screen': 'unknown',
    },
  );
}
```

### Integration with Your Services

Example of tracking analytics in a feature:

```dart
// In your photo upload service
Future<void> uploadPhoto(File photoFile) async {
  try {
    // Upload photo...
    await supabase.storage.from('photos').upload(path, photoFile);

    // Track the event
    await analytics.logEvent(
      name: 'photo_uploaded',
      parameters: {
        'photo_type': 'user_uploaded',
        'file_size_kb': photoFile.lengthSync() ~/ 1024,
      },
    );
  } catch (e) {
    print('Error uploading photo: $e');
  }
}
```

---

## Firebase Console Setup

### Access Firebase Analytics Dashboard

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `nonna_app` project
3. Click **Analytics** in the left menu
4. View real-time events and user engagement

### Key Dashboards to Monitor

1. **Dashboard Tab**: Overview of active users, sessions, and engagement
2. **Events Tab**: Custom events you've implemented
3. **Conversions Tab**: Funnel analysis (e.g., photo upload → share → comment)
4. **Retention Tab**: How many users return after first use
5. **User Properties Tab**: Demographics, device info, app version

### Creating Custom Reports

1. Click **Create Report** in Analytics
2. Select **Event** as the report type
3. Choose a custom event (e.g., `photo_uploaded`)
4. Add dimensions (e.g., photo_type, user property)
5. Set date range and view trends

---

## User Privacy & GDPR Compliance

### Privacy Settings

Firebase Analytics respects user privacy by default:

1. **Disable Analytics for Specific Users** (e.g., under 13):
```dart
// Set user ID (optional)
await analytics.setUserId('user_id'); // Can be null for anonymous

// Use user properties for compliance
await analytics.setUserProperty(
  name: 'age_group',
  value: 'over_18',
);

// Disable analytics if user is under 13
await analytics.setAnalyticsCollectionEnabled(isOver13);
```

2. **Data Retention**: Firebase Analytics retains events for 60 days by default
3. **EU Compliance**: Analytics complies with GDPR

### Disabling for Testing

In development, you can disable analytics collection:

```dart
// In debug mode
if (kDebugMode) {
  await analytics.setAnalyticsCollectionEnabled(false);
}
```

---

## Testing Analytics Events

### Enable Debug Mode

To see events in real-time while developing:

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.example.nonnaapp
adb logcat | grep firebase
```

**iOS:**
```bash
# Run from Xcode console
po FIRAnalytics.setLoggingEnabled(true)
```

### Using Firebase Analytics Debugger

1. Enable debug mode (above)
2. Open [Firebase Console](https://console.firebase.google.com/)
3. Go to **Analytics** > **Debug Tab**
4. Tests events appear within 1-2 seconds

### Verify Events are Logged

Add print statements:

```dart
await analytics.logEvent(
  name: 'photo_uploaded',
  parameters: {'photo_type': 'test'},
);
print('✅ Analytics event logged');
```

---

## Best Practices

### 1. Naming Conventions

- Use snake_case for event names: `photo_uploaded`, `event_rsvp_submitted`
- Use clear, descriptive names that explain the user action
- Avoid PII (Personally Identifiable Information) in event data

### 2. Parameter Guidelines

- Limit events to 25 parameters maximum
- Keep parameter values under 100 characters
- Use consistent naming across your app

### 3. Event Timing

Track events at the right moment:
- After successful uploads (not before)
- When user confirms an action (not on every keystroke)
- After errors are fully resolved

### 4. Batch Events

For high-frequency events, consider batching:
```dart
// Bad: Logs every keystroke
onChanged: (value) => analytics.logEvent(...),

// Good: Log when user finishes typing
onSubmitted: (value) => analytics.logEvent(...),
```

---

## Troubleshooting

### Events Not Appearing in Dashboard

1. **Wait for propagation**: New events appear in 24-48 hours initially
2. **Check app initialization**: Ensure `Firebase.initializeApp()` is called first
3. **Enable DEBUG mode**: Use debug commands above to verify events are sent
4. **Check filters**: Dashboard filters may hide events (check date range, user segment)

### Debug Tab Shows No Events

1. Run app with debug commands enabled
2. Ensure device has internet connection
3. Check Logcat (Android) or Xcode console (iOS) for Firebase messages
4. Verify event name matches declaration (case-sensitive)

### No User Data Appears

1. **Wait 24 hours** for initial data to propagate
2. **Ensure app opens successfully**: First app open is required
3. **Check user count**: Must have at least 2-3 users for statistics
4. **Verify Firebase initialization**: Check console for errors

### Analytics Collection Disabled

Check if collection is disabled:
```dart
final enabled = await analytics.isAnalyticsCollectionEnabled();
print('Analytics enabled: $enabled');

// Re-enable if needed
await analytics.setAnalyticsCollectionEnabled(true);
```

---

## Next Steps

1. **Add custom events** specific to nonna_app features
2. **Set up conversion funnels** (e.g., upload → comment → share)
3. **Create custom segments** based on user properties
4. **Set up alerts** for drops in engagement
5. **Integrate with Firebase Crashlytics** for crash tracking (see FIREBASE_CRASHLYTICS_SETUP.md)

---

## Additional Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Analytics Plugin](https://pub.dev.flutter.dev/packages/firebase_analytics)
- [Google Analytics Academy (Free Course)](https://analytics.google.com/analytics/academy/)
- [Firebase Best Practices](https://firebase.google.com/docs/analytics/best-practices)
