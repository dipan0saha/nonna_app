# Firebase Setup Guide for Nonna App

## Table of Contents
1. [What is Firebase?](#what-is-firebase)
2. [Why Does Nonna App Need It?](#why-does-nonna-app-need-it)
3. [Firebase Services Breakdown](#firebase-services-breakdown)
4. [Pre-requisites](#pre-requisites)
5. [Step-by-Step Setup](#step-by-step-setup)
6. [Android Configuration](#android-configuration)
7. [iOS Configuration](#ios-configuration)
8. [Flutter Integration](#flutter-integration)
9. [Troubleshooting](#troubleshooting)

---

## What is Firebase?

**Firebase** is Google's comprehensive platform for building high-quality mobile and web applications. It provides:

- **Real-time Database** - Sync data across users in real-time
- **Cloud Storage** - Store user-generated files (photos, documents)
- **Authentication** - Manage user logins and accounts
- **Cloud Functions** - Run backend code without servers
- **Messaging** - Send push notifications and in-app messages
- **Analytics** - Track user behavior and app performance
- **Crash Reporting** - Monitor app crashes and errors
- **Remote Config** - Control app behavior without updates
- **Testing Lab** - Test app on real devices

For Nonna App, the most important services are:

- ✅ **Cloud Storage** - Store family photos and memories
- ✅ **Analytics** - Understand user behavior
- ✅ **Cloud Messaging** - Backup push notification system
- ✅ **Crash Reporting** - Monitor app stability

Firebase is **free to start** with generous quotas and scales as you grow.

---

## Why Does Nonna App Need It?

Firebase is essential for Nonna App because:

### 1. **Cloud Storage for Photos**
   - Store family photos and memories securely
   - Scale from 1 to 1 million photos without infrastructure
   - Control who can upload and view photos via security rules
   - Automatic backups and CDN distribution
   - Easy thumbnail generation

### 2. **Analytics & User Insights**
   - Track which features users engage with most
   - Monitor user retention and churn
   - Identify broken flows in the app
   - A/B test new features
   - Optimize app performance

### 3. **Crash Reporting**
   - Get instant alerts when app crashes
   - See stack traces and device information
   - Fix bugs before users report them
   - Monitor app stability over time
   - Understand which crashes affect most users

### 4. **Cloud Messaging (FCM)**
   - Backup to OneSignal for redundancy
   - Direct integration with no third-party vendor
   - Send notifications from backend
   - Handle topics and subscriptions

### 5. **Cloud Functions**
   - Trigger functions on database changes
   - Process photos (resize, optimize)
   - Send automated emails or notifications
   - Validate data before storage
   - Handle complex business logic

### 6. **Remote Config**
   - Toggle features on/off remotely
   - A/B test feature rollouts
   - Change app behavior without app update
   - Gradual feature adoption

**Without Firebase**, you'd need to:
- ❌ Build your own photo storage infrastructure
- ❌ Buy separate analytics platform
- ❌ Implement custom crash reporting
- ❌ Pay more for scalability

**With Firebase**, you get:
- ✅ Automatic scaling at no extra cost
- ✅ Built-in security and compliance
- ✅ 99.95% uptime guarantee
- ✅ Zero DevOps setup required

---

## Firebase Services Breakdown

### Services Used in Nonna App

| Service | Purpose | Free Tier | When to Pay |
|---------|---------|-----------|------------|
| **Cloud Storage** | Store family photos | 5 GB | >5 GB stored |
| **Analytics** | Track user behavior | Unlimited | - (Always free) |
| **Crash Reporting** | Monitor crashes | Unlimited | - (Always free) |
| **Cloud Messaging** | Send push notifications | Unlimited | - (Always free) |
| **Cloud Functions** | Backend code | 2M invocations/month | >2M invocations |
| **Remote Config** | Control app behavior | Unlimited | - (Always free) |

### Pricing Example
For a typical family app with ~500 users:
- **Storage**: 100 GB family photos = ~$2-3/month
- **Cloud Functions**: 10K invocations/month = **Free**
- **Analytics**: Unlimited tracking = **Free**
- **Crash Reporting**: Unlimited = **Free**
- **Total**: ~$3-5/month (mostly just storage)

---

## Pre-requisites

Before setting up Firebase, ensure you have:

### Required
- [ ] Google account (or create one)
- [ ] Flutter project with pubspec.yaml
- [ ] Android project files (AndroidManifest.xml)
- [ ] iOS project files (Info.plist)
- [ ] Apple Developer Account (for iOS)
- [ ] 30-45 minutes for setup

### Recommended
- [ ] Understanding of Google Cloud Platform basics
- [ ] Access to your app's signing certificate SHA-1 fingerprints
- [ ] Understanding of security rules for Cloud Storage

---

## Step-by-Step Setup

### Phase 1: Create Firebase Project

#### Step 1.1: Create a Firebase Project
1. Go to https://firebase.google.com
2. Click **"Get started"** or **"Go to console"**
3. Click **"Create a project"**
4. Project name: `nonna-app`
5. **Disable Google Analytics** (optional, can enable later)
6. Click **"Create project"**
7. Wait 1-2 minutes for project creation to complete

#### Step 1.2: Get Project Configuration
1. In Firebase Console, click your project
2. Click **Settings** (⚙️ icon) → **Project Settings**
3. Copy:
   - **Project ID**: (e.g., `nonna-app-xyz123`)
   - **Project Number**: (e.g., `123456789012`)
4. Save these for later

---

### Phase 2: Android Configuration

#### Step 2.1: Register Android App in Firebase

1. In Firebase Console, click **"Add app"** → **Android**
2. Enter:
   - **Android Package Name**: `com.la_nonna.nonna_app`
   - **Android Nickname** (optional): `Nonna App Android`
   - **SHA-1 Certificate Fingerprint** (see below)
3. To get SHA-1:
   ```bash
   # For debug key
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

   # For release key (if you have one)
   keytool -list -v -keystore android/app/release.keystore | grep SHA1
   ```
4. Copy the SHA1 fingerprint (format: `AB:CD:EF:12:34:56...`)
5. Paste into Firebase registration
6. Click **"Register app"**

#### Step 2.2: Download google-services.json

1. Firebase will prompt to download `google-services.json`
2. Download the file
3. Move to your project:
   ```
   android/app/google-services.json
   ```
4. Click **"Next"** to skip setup steps (we'll do it in Flutter)

#### Step 2.3: Add Google Services Plugin

Update `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    // Add this line
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  // Add Firebase dependencies if not using flutter plugins
  implementation 'com.google.firebase:firebase-bom:32.2.3'
  implementation 'com.google.firebase:firebase-analytics'
  implementation 'com.google.firebase:firebase-storage'
  implementation 'com.google.firebase:firebase-messaging'
}
```

---

### Phase 3: iOS Configuration

#### Step 3.1: Register iOS App in Firebase

1. In Firebase Console, click **"Add app"** → **iOS**
2. Enter:
   - **Bundle ID**: `com.laNonna.nonnaApp`
   - **App Nickname** (optional): `Nonna App iOS`
   - **App Store ID** (optional, leave blank for now)
3. Click **"Register app"**

#### Step 3.2: Download GoogleService-Info.plist

1. Firebase will prompt to download `GoogleService-Info.plist`
2. Download the file
3. In Xcode:
   - Open `ios/Runner.xcworkspace` (not .xcodeproj)
   - Right-click on "Runner" folder
   - Select **"Add Files to Runner"**
   - Choose the downloaded `GoogleService-Info.plist`
   - Check **"Copy items if needed"**
   - Select **"Runner"** target
   - Click **"Add"**

#### Step 3.3: Update iOS Build Settings

1. In Xcode, select **Runner** project
2. Select **Runner** target
3. Go to **Build Settings**
4. Search for `GCC_PREPROCESSOR_DEFINITIONS`
5. Add (if not present):
   ```
   Firebase=1
   ```
6. Update `ios/Podfile` to include Firebase pods:
   ```ruby
   # In ios/Podfile, ensure Firebase is installed
   pod 'FirebaseCore'
   pod 'FirebaseAnalytics'
   pod 'FirebaseStorage'
   pod 'FirebaseMessaging'
   ```

#### Step 3.4: Run Pod Install

```bash
cd ios
pod install --repo-update
cd ..
```

---

## Flutter Integration

### Step 1: Add Firebase Packages to pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.6.0
  firebase_crashlytics: ^3.3.0
  firebase_remote_config: ^4.3.0
```

Then run:
```bash
flutter pub get
```

### Step 2: Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

Flutter will automatically generate `lib/firebase_options.dart` based on your configs.

### Step 3: Enable Analytics

Analytics is automatically enabled. To log custom events:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class EventTracker {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> logEventCreated() async {
    await _analytics.logEvent(
      name: 'event_created',
      parameters: {
        'event_type': 'family_dinner',
        'attendees': 5,
      },
    );
  }

  static Future<void> logPhotoUploaded() async {
    await _analytics.logEvent(
      name: 'photo_uploaded',
      parameters: {
        'album_id': 'album_123',
        'file_size_mb': 2.5,
      },
    );
  }
}
```

### Step 4: Enable Crash Reporting

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Pass all uncaught errors from Flutter to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  runApp(const MyApp());
}
```

### Step 5: Setup Cloud Storage

Create a service class:

```dart
import 'package:firebase_storage/firebase_storage.dart';

class PhotoStorageService {
  static final _storage = FirebaseStorage.instance;
  static const String _bucketPath = 'family-photos';

  // Upload photo
  static Future<String> uploadPhoto(File photoFile, String userId) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage
          .ref()
          .child(_bucketPath)
          .child(userId)
          .child('$fileName.jpg');

      await ref.putFile(photoFile);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  // Delete photo
  static Future<void> deletePhoto(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  // List user photos
  static Future<List<String>> getUserPhotos(String userId) async {
    try {
      ListResult result = await _storage
          .ref()
          .child(_bucketPath)
          .child(userId)
          .listAll();

      List<String> urls = [];
      for (var file in result.items) {
        String url = await file.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('List error: $e');
      return [];
    }
  }
}
```

### Step 6: Setup Cloud Messaging (Optional)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message from Firebase: ${message.notification?.title}');
      // Show notification or update UI
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  static Future<void> _backgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }

  // Get FCM token for this device
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }
}
```

---

## Cloud Storage Security Rules

Update your storage security rules in Firebase Console:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /family-photos/{userId}/{allPaths=**} {
      // Only authenticated users can access
      allow read, write: if request.auth.uid == userId;

      // Admins can do anything
      allow read, write: if request.auth.token.email_verified
        && request.auth.token.admin == true;
    }

    // Public family albums
    match /public-albums/{albumId}/{allPaths=**} {
      allow read: if true;  // Anyone can read
      allow write: if request.auth != null;  // Only authenticated users
    }
  }
}
```

---

## Troubleshooting

### Common Issues & Solutions

#### "google-services.json not found"

**Problem**: Build fails with firebase plugin not found

**Solutions**:
1. Verify `android/app/google-services.json` exists
2. Run: `flutter clean && flutter pub get`
3. Rebuild Android: `flutter build apk --debug`

#### "GoogleService-Info.plist not included in build"

**Problem**: iOS build fails or Firebase not initializing

**Solutions**:
1. In Xcode, verify `GoogleService-Info.plist` is in Runner folder
2. In Build Phases → Copy Bundle Resources, verify plist is listed
3. Check file permissions: `ls -la ios/Runner/GoogleService-Info.plist`

#### "Crash Reporting not Working"

**Problem**: App crashes but Firebase doesn't report them

**Solutions**:
1. Ensure `FlutterError.onError` is set before runApp()
2. For Dart errors, they should auto-report
3. For native Android/iOS crashes, may need additional setup
4. Verify app has internet permission

#### "Cloud Storage Upload Returns 403"

**Problem**: Permission denied when uploading files

**Solutions**:
1. Check storage security rules allow write
2. Verify user is authenticated (uid matches path)
3. Check file size is within limits (5GB max per file)
4. Ensure user has "Editor" role in Firebase Console

#### "Analytics Shows No Data"

**Problem**: Analytics events not appearing in dashboard

**Solutions**:
1. Wait 24-48 hours - Firebase batches analytics
2. Verify `firebase_analytics` package is initialized
3. Check Flutter debug output for analytics logs
4. Ensure app has internet connection
5. Test with manual events and refresh page

---

## Environment-Specific Configuration

### Development vs Production

You may want different Firebase projects for dev/prod:

```dart
Future<void> initializeFirebase() async {
  String projectId = const bool.fromEnvironment('PROJECT_ID') ?? 'nonna-app-dev';

  // Use appropriate Firebase config based on environment
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

Run with environment variable:
```bash
flutter run --dart-define=PROJECT_ID=nonna-app-prod
```

---

## Monitoring Firebase Usage

1. **Firebase Console** → **Project Settings** → **Usage**
2. Track:
   - Storage used and monthly egress
   - Cloud Functions invocations
   - Analytics events processed
3. Set up billing alerts:
   - **Billing** → **Budget alerts**
   - Set limit (e.g., $10/month)

---

## Best Practices

### 1. **Security**
- ✅ Use security rules, never allow open access
- ✅ Validate data before storage
- ✅ Use custom claims for admin checks

### 2. **Performance**
- ✅ Compress images before upload
- ✅ Use cloud functions to process large files
- ✅ Cache downloaded data locally

### 3. **Cost Optimization**
- ✅ Delete old data automatically
- ✅ Compress text and logs
- ✅ Use Cloud Functions efficiently

### 4. **Monitoring**
- ✅ Set up Crashlytics alerts
- ✅ Monitor storage growth
- ✅ Track analytics trends

---

## Useful Links

- **Firebase Documentation**: https://firebase.google.com/docs
- **Firebase Console**: https://console.firebase.google.com
- **Flutter Firebase Plugin**: https://pub.dev/packages/firebase_core
- **Cloud Storage Security Rules**: https://firebase.google.com/docs/storage/security

---

## Next Steps

1. ✅ Create Firebase project
2. ✅ Configure Android and iOS
3. ✅ Add Firebase packages to Flutter
4. ✅ Initialize Firebase in main.dart
5. ✅ Set up Cloud Storage for photos
6. ✅ Enable Crashlytics monitoring
7. ✅ Track key events with Analytics
8. ✅ Set up security rules
9. ✅ Test with sample uploads
10. ✅ Monitor usage and costs

---

**Last Updated**: March 3, 2026
**Status**: Ready for Production
