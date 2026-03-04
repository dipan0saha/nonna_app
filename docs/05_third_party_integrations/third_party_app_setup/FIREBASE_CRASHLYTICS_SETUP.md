# Firebase Crashlytics Setup Guide for nonna_app

## Overview

Firebase Crashlytics is a real-time crash reporting solution that helps you track, prioritize, and fix stability issues in your app. It provides detailed crash reports with stack traces, user context, and device information—all for free.

### What is Firebase Crashlytics?

Crashlytics automatically detects crashes and exceptions in your app, groups them by similarity, and provides detailed reports including:
- Stack traces showing exactly where the crash occurred
- Device information (OS version, manufacturer, RAM)
- User session logs (bread crumbs before the crash)
- Custom logs and error messages

### Why nonna_app Needs It

A family application needs reliable crash reporting because:
- **User Trust**: Families trust the app with personal memories (photos, events, registry)
- **Data Integrity**: Crashes could corrupt calendar events, photos, or registry data
- **Parental Confidence**: Adults need to know the app is stable before installing for their families
- **Bug Tracking**: Identify which features crash most often and prioritize fixes
- **Performance Monitoring**: Track method count, frame rate, and memory issues
- **User Context**: Know what user was doing when app crashed (viewing photo? uploading event?)

### Pricing

**Firebase Crashlytics is FREE** with unlimited crash reports and users.

---

## Setup Instructions

### Step 1: Add Dependencies

Add Firebase Crashlytics to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.4.0
  firebase_crashlytics: ^4.0.0
  # Optional: For better error tracking
  sentry_flutter: ^0.0.0  # REMOVE THIS - redundant with Crashlytics
```

⚠️ **Important**: Remove `sentry_flutter` if present - it's redundant with Firebase Crashlytics and costs money.

Run:
```bash
flutter pub get
```

### Step 2: Initialize Crashlytics in Your App

Update your `main.dart` to initialize Crashlytics:

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Set user context (optional but recommended)
  await FirebaseCrashlytics.instance.setUserIdentifier('user_id');

  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };

  // Capture async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

**Complete Example with Error Handling:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics in production only
  if (kReleaseMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Capture Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Capture async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

### Step 3: Android Configuration

1. **Update `android/build.gradle`**:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.0'
  }
}
```

2. **Update `android/app/build.gradle`**:

```gradle
plugins {
  id 'com.android.application'
  id 'com.google.gms.google-services'
  id 'com.google.firebase.crashlytics'
}

// Request write external storage for crash logs
android {
  defaultConfig {
    // ...
  }
}

dependencies {
  // Crashlytics mapping files
  // (automatically handled by plugin)
}
```

3. **Register NDK Crash Reporting** (Android native crash detection):

In your `android/app/build.gradle`:

```gradle
android {
  packagingOptions {
    // Include crash reporting native libraries
    pickFirst 'lib/arm64-v8a/libcrashlytics.so'
    pickFirst 'lib/armeabi-v7a/libcrashlytics.so'
    pickFirst 'lib/x86/libcrashlytics.so'
  }
}
```

### Step 4: iOS Configuration

1. **Install pods**:

```bash
cd ios
pod install --repo-update
cd ..
```

2. **Ensure `GoogleService-Info.plist` is added**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Drag `GoogleService-Info.plist` into the project
   - Check all targets: Runner, RunnerTests

3. **Update Info.plist** (`ios/Runner/Info.plist`):

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<true/>
```

4. **iOS Deployment Target**: Ensure iOS 13.0 or higher in Xcode

---

## Tracking Custom Errors

### Basic Error Reporting

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Record a caught exception
try {
  // Your code
  performRiskyOperation();
} catch (e, st) {
  // Report to Crashlytics
  FirebaseCrashlytics.instance.recordError(e, st);
}
```

### Recording Fatal Errors

For critical errors that should crash the app:

```dart
try {
  // Critical database operation
  await database.saveUserData();
} catch (e, st) {
  // This will mark the crash as fatal in reports
  FirebaseCrashlytics.instance.recordError(
    e,
    st,
    fatal: true, // Marks as fatal crash
  );
  // Optionally rethrow to crash the app
  rethrow;
}
```

### Adding Custom Logging (Bread Crumbs)

Log user actions before crashes occur:

```dart
// Log important app events
FirebaseCrashlytics.instance.log('📸 Photo upload started');
FirebaseCrashlytics.instance.log('🔄 Syncing calendar events');
FirebaseCrashlytics.instance.log('✅ RSVP submitted');

// Later, if crash occurs, these logs appear in the report
try {
  await uploadPhoto();
} catch (e, st) {
  FirebaseCrashlytics.instance.recordError(e, st);
}
```

### Integration with Your Services

Example error handling in photo service:

```dart
class PhotoService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> uploadPhoto(File photoFile) async {
    try {
      _crashlytics.log('📸 Starting photo upload...');

      final response = await supabase.storage
          .from('photos')
          .upload('user_photos/${DateTime.now().millisecondsSinceEpoch}.jpg', photoFile);

      _crashlytics.log('✅ Photo uploaded successfully');
    } catch (e, st) {
      _crashlytics.log('❌ Photo upload failed: $e');
      _crashlytics.recordError(e, st);
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      _crashlytics.log('🗑️ Deleting photo: $photoId');
      await supabase.from('photos').delete().eq('id', photoId);
      _crashlytics.log('✅ Photo deleted');
    } catch (e, st) {
      _crashlytics.log('❌ Delete photo failed');
      _crashlytics.recordError(e, st, fatal: true);
      rethrow;
    }
  }
}
```

### Setting User Context

Help identify affected users:

```dart
// Set when user logs in
Future<void> setUserContext(String userId, String email) async {
  await FirebaseCrashlytics.instance.setUserIdentifier(userId);

  // Optional: Set custom user properties
  await FirebaseCrashlytics.instance.setCustomKey('email', email);
  await FirebaseCrashlytics.instance.setCustomKey('app_version', '1.0.0');
  await FirebaseCrashlytics.instance.setCustomKey('user_plan', 'family');
}

// Clear when user logs out
Future<void> clearUserContext() async {
  await FirebaseCrashlytics.instance.setUserIdentifier('');
}
```

### Setting Custom Keys

Track additional context:

```dart
// Track feature usage in crashes
await FirebaseCrashlytics.instance.setCustomKey('last_feature', 'gallery');
await FirebaseCrashlytics.instance.setCustomKey('photo_count', 42);
await FirebaseCrashlytics.instance.setCustomKey('is_premium', true);

// Track network state
await FirebaseCrashlytics.instance.setCustomKey('connected', true);
```

---

## Firebase Console Setup

### Access Crashlytics Dashboard

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `nonna_app` project
3. Click **Crashlytics** in the left menu

### Understanding Crash Reports

Each crash shows:

1. **Crash Overview**:
   - Number of crashes and affected users
   - Crash rate trend (increasing/decreasing)
   - App version and platform breakdown

2. **Stack Trace**:
   - Exact line of code causing the crash
   - Call stack showing how you got there
   - File names and line numbers

3. **Device Details**:
   - Android/iOS version
   - Device model and manufacturer
   - RAM and storage info

4. **Custom Logging**:
   - Bread crumbs (logs before crash)
   - User context (ID, email)
   - Custom keys you set

### Example Crash Report Flow

```
User uploads photo (logged: "📸 Starting photo upload")
  ↓
Photo compression fails (logged: "❌ Photo upload failed")
  ↓
App crashes with null pointer exception
  ↓
Crashlytics captures:
  - Stack trace pointing to compression code
  - Bread crumbs showing upload attempt
  - Device: iPhone 14, iOS 17.5
  - User: john_doe@family.com
  - Custom key: last_feature=gallery
```

---

## Testing Crashlytics

### Force a Test Crash (Android/iOS)

Add a button to test crash reporting:

```dart
// In a test screen or settings menu
ElevatedButton(
  onPressed: () {
    // Throws a test exception
    throw Exception('Test crash for Crashlytics');
  },
  child: const Text('Test Crash'),
),
```

### Build and Install App

For testing to work, build a **release** version:

```bash
# Build release APK
flutter build apk --release

# Or for iOS
flutter build ios --release
```

**Why release build?**
- Crashlytics is often disabled in debug mode
- Release builds process stack traces for better readability
- Matches production behavior

### Verify in Console

1. Trigger the test crash
2. Wait 5 minutes
3. Open [Firebase Console → Crashlytics](https://console.firebase.google.com/)
4. Your test crash should appear in the list

---

## Best Practices

### 1. Error Handling Strategy

```dart
// Good: Catch specific errors
try {
  await uploadPhoto();
} on StorageException catch (e) {
  // Handle storage error
  showErrorSnackBar('Storage full');
  _crashlytics.recordError(e, StackTrace.current);
} catch (e, st) {
  // Handle unexpected errors
  _crashlytics.recordError(e, st, fatal: true);
}
```

### 2. Use Meaningful Logs

```dart
// Good: Descriptive logs
_crashlytics.log('🚀 Starting sync of ${events.length} calendar events');
_crashlytics.log('🔐 Auth token refreshed at ${DateTime.now()}');

// Bad: Vague logs
_crashlytics.log('doing something');
_crashlytics.log('error');
```

### 3. Set User Context Early

```dart
// In onAuthStateChanged
authProvider.onAuthStateChanged.listen((user) {
  if (user != null) {
    FirebaseCrashlytics.instance.setUserIdentifier(user.id);
  } else {
    FirebaseCrashlytics.instance.setUserIdentifier('');
  }
});
```

### 4. Disable in Debug Mode

```dart
// In main.dart
if (kReleaseMode) {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
} else {
  // In debug, you'll see errors in console instead
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
}
```

### 5. Handle Null Safety Issues

```dart
// Help Crashlytics understand nullable values
String? getUserName() {
  try {
    final user = _currentUser;
    if (user == null) {
      _crashlytics.log('⚠️ Current user is null');
      return null;
    }
    return user.name;
  } catch (e, st) {
    _crashlytics.recordError(e, st);
    return null;
  }
}
```

---

## Advanced Configuration

### Performance Monitoring Integration

Link crashes to performance issues:

```dart
import 'package:firebase_performance/firebase_performance.dart';

void trackOperationWithError() {
  final trace = FirebasePerformance.instance.newTrace('photo_upload');
  trace.start();

  try {
    // Perform operation
    uploadPhoto();
    trace.stop();
  } catch (e, st) {
    trace.stop();
    FirebaseCrashlytics.instance.recordError(e, st);
  }
}
```

### Remote Configuration with Crashlytics

Use Remote Config to enable/disable features if crashes spike:

```dart
// In production, disable feature if crashes exceed threshold
if (crashlytics.crashRate > 0.05) {
  // Disable photo upload feature temporarily
  remoteConfig.getBoolean('enable_photo_upload') // false
}
```

---

## Troubleshooting

### Crashes Not Appearing

1. **Wait 5-10 minutes**: First crashes have processing delay
2. **Check Release Mode**: Ensure app is built as release (`flutter build apk --release`)
3. **Verify Firebase initialization**: Check init code is first in main()
4. **Check Collection Enabled**:
   ```dart
   final enabled = await FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled();
   print('Crashlytics enabled: $enabled');
   ```
5. **Check Internet**: Device must have internet to report crashes

### Stack Traces Not Readable

1. **Upload Symbols**: For native crashes, ensure native debugging symbols are uploaded:
   ```bash
   # Android - automatic with Gradle plugin
   # iOS - check Xcode build settings
   ```
2. **Check ProGuard/R8**: Ensure obfuscation rules aren't hiding stack traces:
   ```gradle
   android {
     buildTypes {
       release {
         debuggable false
         minifyEnabled true
       }
     }
   }
   ```

### Performance Impact

Crashlytics is extremely lightweight:
- **Minimal overhead**: <1% impact on app performance
- **Lazy initialization**: Doesn't run until needed
- **Batched reporting**: Crashes grouped before sending

### Privacy Concerns

Crashlytics respects user privacy:
- ✅ No automatic tracking of user input/passwords
- ✅ Custom logs don't include sensitive data unless you add it
- ✅ Compliant with GDPR/CCPA
- ❌ Don't log passwords, tokens, or PII

---

## Integration with Analytics

Combine Crashlytics with Analytics for complete picture:

1. **Track feature → Crash correlation**:
   ```dart
   // Analytics logs user accessed gallery
   analytics.logEvent(name: 'gallery_opened');

   // If crash happens, you see it was in gallery
   crashlytics.log('🖼️ Gallery feature - Viewing photos');
   ```

2. **Monitor crash impact**:
   - Crashes reduce engagement metrics
   - Use Analytics to measure recovery after fixes

---

## Recommended Crash Handling Checklist

- ✅ Initialize Crashlytics before any other code
- ✅ Capture Flutter errors from `FlutterError.onError`
- ✅ Capture async errors from `PlatformDispatcher.onError`
- ✅ Set user context when users authenticate
- ✅ Add meaningful logs (bread crumbs) before operations
- ✅ Test crash reporting with release build
- ✅ Monitor dashboard weekly for new crashes
- ✅ Prioritize crashes by affected user count
- ✅ Track crash-free user percentage

---

## Next Steps

1. **Configure custom error categories** for your app
2. **Set up Slack notifications** for critical crashes
3. **Create crash report dashboards** for your team
4. **Establish crash-fix SLA** (Service Level Agreement)
5. **Combine with Analytics** (see FIREBASE_ANALYTICS_SETUP.md)
6. **Review OneSignal integration** for user notification on fixes (see ONESIGNAL_SETUP.md)

---

## Additional Resources

- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Flutter Firebase Crashlytics Plugin](https://pub.dev/packages/firebase_crashlytics)
- [Crash Data Best Practices](https://firebase.google.com/docs/crashlytics/best-practices)
- [Firebase Console](https://console.firebase.google.com/)
