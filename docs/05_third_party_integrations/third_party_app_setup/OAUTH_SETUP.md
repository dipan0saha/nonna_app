# Google & Facebook OAuth Setup Guide for nonna_app

## Overview

OAuth (Open Authentication) is a secure way for your app to authenticate users without storing their passwords. Instead, users sign in with their existing Google or Facebook accounts, and these services verify their identity.

### What is OAuth?

OAuth is an authentication standard where:
1. User clicks "Sign in with Google" or "Sign in with Facebook"
2. They're redirected to Google/Facebook login page
3. User enters their credentials (on Google/Facebook servers, not your app)
4. Google/Facebook returns a secure token to your app
5. Your app uses this token to create a user session

### Why nonna_app Needs OAuth

Family users benefit from OAuth because:
- **Password Fatigue**: Users don't need to create another password
- **Two-Factor Security**: Uses Google/Facebook's built-in 2FA
- **Social Connection**: Easier to invite friends with existing social accounts
- **Profile Data**: Auto-populate name, email, and profile picture
- **Account Recovery**: Users can recover access through Google/Facebook if they forget password
- **Family Trust**: Parents are more likely to use apps with familiar login methods
- **No Password Storage**: Your app never handles passwords (higher security)

### Why Google AND Facebook?

- **Google**: For Android users and Gmail users (largest user base)
- **Facebook**: For families already using Facebook to stay connected
- **Flexibility**: Users can choose their preferred login method

### Pricing

**Both Google OAuth and Facebook OAuth are FREE**.

---

## Part 1: Google OAuth Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a Project** → **New Project**
3. Enter project name: `nonna_app` or `nonna-app-family`
4. Click **Create**

### Step 2: Enable Google Sign-In API

1. In Google Cloud Console, go to **APIs & Services → Library**
2. Search for **Google Identity Services API**
3. Click **Enable**
4. Also enable **Google+ API** (legacy, but required for some implementations)

### Step 3: Create OAuth Credentials

1. Go to **APIs & Services → Credentials**
2. Click **Create Credentials → OAuth 2.0 Client ID**
3. Select **Android** (first credential)
4. Fill in the form:
   - **Package name**: `com.example.nonnaapp` (match your Android app's package)
   - **SHA-1 fingerprint**: Get from step 4 below

### Step 4: Get Android App Signing Key

To get your SHA-1 fingerprint:

```bash
# Option 1: Using keytool (if you have a keystore)
keytool -list -v -keystore $(find ~/.android -name "*.keystore" | head -1)

# Option 2: Using Flutter (recommended)
cd /path/to/nonna_app
flutter run
# During first Android build, Flutter shows SHA-1

# Option 3: If already built
cd android
./gradlew signingReport
```

Copy the **SHA-1** value and paste into Google Cloud Console.

5. Click **Create**
6. Google will show you the Client ID (for reference only)
7. Download the JSON file (don't need it for Flutter)

### Step 5: Create OAuth Credentials for Web (for deeplinks)

1. Go to **APIs & Services → Credentials**
2. Click **Create Credentials → OAuth 2.0 Client ID**
3. Select **Web application**
4. Fill in the form:
   - **Name**: `nonna-app-web`
   - **Authorized JavaScript origins**: Leave blank (mobile app)
   - **Authorized redirect URIs**: Add `https://nonna-app.firebaseapp.com/__/auth/handler` (for Supabase)

5. Click **Create** and download JSON (save for reference)

### Step 6: Enable iOS Google Sign-In (Optional)

If supporting iOS:

1. Go back to **APIs & Services → Credentials**
2. Click **Create Credentials → OAuth 2.0 Client ID**
3. Select **iOS**
4. Fill in:
   - **Bundle ID**: `com.example.nonnaapp` (match your iOS app)
   - **Team ID**: Get from [Apple Developer Account](https://developer.apple.com/)
   - **App ID Prefix**: Also from Apple

---

## Part 2: Facebook OAuth Setup

### Step 1: Create Facebook Developer Account

1. Go to [Meta Developers](https://developers.facebook.com/)
2. Click **My Apps → Create App** (or sign up if new)
3. Select **Consumer** as app type
4. Fill in app details:
   - **App Name**: `nonna_app`
   - **App Contact Email**: your-email@example.com
   - **App Purpose**: Family & Relationships or Social Networking

### Step 2: Add Facebook Login Product

1. In your app dashboard, click **+ Add Product**
2. Search for **Facebook Login**
3. Click **Set Up**
4. Choose **Integrate Facebook Login** (not web)

### Step 3: Configure Android Settings

1. Go to **Settings → Basic**
   - **App ID**: Copy this (you'll need it)
   - **App Secret**: Copy this (keep secret!)

2. Go to **Settings → Basic → App Domains**
   - Add: `nonnaapp.firebaseapp.com` (your Firebase domain)

3. Go to **Facebook Login → Settings**
   - **Redirect URI for Native Android App**:
     - Add: `https://nonnaapp.firebaseapp.com/__/auth/handler`

4. Go to **Facebook Login → Android**
   - Click **+ Add Android App**
   - **Package Name**: `com.example.nonnaapp`
   - **Class Name**: `com.example.nonnaapp.MainActivity`
   - **Key Hashes**: Get your Facebook key hash:

```bash
# Get Facebook Key Hash for Android
cd /path/to/nonna_app/android
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64

# Or for release keystore
keytool -exportcert -alias my-key-alias -keystore /path/to/keystore.jks | openssl sha1 -binary | openssl base64
```

   - Paste the key hash into Facebook console

### Step 4: Configure iOS Settings (Optional)

1. Go to **Facebook Login → iOS**
   - Click **+ Add iOS App**
   - **Bundle ID**: `com.example.nonnaapp`
   - Get your iOS key hash from Xcode project

### Step 5: Get App ID and Secret

1. Go to **Settings → Basic**
2. Copy **App ID** and **App Secret** (you'll need these for Supabase)
3. Mark **App Secret** as sensitive - don't share publicly

---

## Part 3: Supabase OAuth Configuration

### Configure Google Provider in Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Authentication → Providers**
4. Click **Google** and enable it
5. Fill in OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console (create new one if needed)

### Configure Facebook Provider in Supabase

1. In **Authentication → Providers**
2. Click **Facebook** and enable it
3. Fill in OAuth credentials:
   - **App ID**: From Meta Developers console
   - **API Secret**: From Meta Developers console

### Setup Redirect URL

In Supabase, copy your **Callback URL**:
- Usually: `https://your-supabase-project.supabase.co/auth/v1/callback`

Add this to both Google and Facebook OAuth settings as redirect URI.

---

## Part 4: Flutter Implementation

### Step 1: Add Dependencies

```yaml
dependencies:
  google_sign_in: ^6.2.0
  flutter_appauth: ^6.1.0
  flutter_facebook_sdk: ^6.0.0  # Or use flutter_facebook_sdk
```

Run:
```bash
flutter pub get
```

### Step 2: Configure Native Apps

**Android Configuration** (`android/app/build.gradle`):

```gradle
dependencies {
  implementation 'com.google.android.gms:play-services-auth:21.1.0'
  implementation 'com.facebook.android:facebook-android-sdk:15.1.0'
}
```

**Android Manifest** (`android/app/src/AndroidManifest.xml`):

```xml
<manifest>
  <!-- Internet permission -->
  <uses-permission android:name="android.permission.INTERNET" />

  <application>
    <!-- Facebook setup -->
    <meta-data
      android:name="com.facebook.sdk.ApplicationId"
      android:value="@string/facebook_app_id" />
    <meta-data
      android:name="com.facebook.sdk.ClientToken"
      android:value="@string/facebook_client_token" />

    <!-- Google setup (automatic with play-services) -->

    <activity android:name=".MainActivity">
      <!-- ... existing activity config ... -->
    </activity>
  </application>
</manifest>
```

**Android String Resources** (`android/app/src/main/res/values/strings.xml`):

```xml
<resources>
  <string name="app_name">nonna_app</string>
  <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
  <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

**iOS Configuration** (`ios/Podfile`):

Uncomment the platform line:
```ruby
platform :ios, '13.0'

# Facebook SDK requirements
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FBSDKCOCOAPODS=1'
      ]
    end
  end
end
```

**iOS Info.plist** (`ios/Runner/Info.plist`):

```xml
<dict>
  <!-- Google Sign-In -->
  <key>GIDClientID</key>
  <string>YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>

  <!-- Facebook -->
  <key>FacebookAppID</key>
  <string>YOUR_FACEBOOK_APP_ID</string>
  <key>FacebookClientToken</key>
  <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>

  <key>FacebookDisplayName</key>
  <string>nonna_app</string>

  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>fbapi</string>
    <string>fb-messenger</string>
  </array>

  <!-- Deep linking for OAuth -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        <string>fb YOUR_FACEBOOK_APP_ID</string>
      </array>
    </dict>
  </array>
</dict>
```

### Step 3: Implement Auth Service

Create an **auth_service.dart**:

```dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_sdk/flutter_facebook_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;
  late final FacebookLogin _facebookLogin;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
      ],
    );
    _facebookLogin = FacebookLogin();
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Cancelled by user

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID token from Google');
      }

      // Sign in to Supabase with Google
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      print('✅ Signed in with Google: ${googleUser.email}');
    } catch (e) {
      print('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    try {
      final result = await _facebookLogin.logIn(permissions: [
        'email',
        'public_profile',
      ]);

      if (result.isError) {
        throw Exception('Facebook login error: ${result.error}');
      }

      final accessToken = result.accessToken?.token;
      if (accessToken == null) {
        throw Exception('No access token from Facebook');
      }

      // Sign in to Supabase with Facebook
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken,
      );

      print('✅ Signed in with Facebook');
    } catch (e) {
      print('❌ Facebook sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _googleSignIn.signOut();
      await _facebookLogin.logOut();
      print('✅ Signed out');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
```

### Step 4: Create Login UI

```dart
import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to nonna_app',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Google Sign-In Button
            _buildOAuthButton(
              label: 'Sign in with Google',
              icon: '🔵',
              onPressed: _isLoading ? null : () => _handleGoogleLogin(),
            ),

            const SizedBox(height: 16),

            // Facebook Sign-In Button
            _buildOAuthButton(
              label: 'Sign in with Facebook',
              icon: '📘',
              onPressed: _isLoading ? null : () => _handleFacebookLogin(),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthButton({
    required String label,
    required String icon,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Text(icon, style: const TextStyle(fontSize: 20)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(280, 50),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showError('Google login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithFacebook();
      if (mounted) {
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showError('Facebook login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

---

## Part 5: Deep Linking Configuration

OAuth uses OAuth/URL schemes to return the user to your app after login.

### Android Deep Linking

Update **android/app/build.gradle**:

```gradle
android {
  defaultConfig {
    // This tells Android about your deep link scheme
  }
}
```

Update **AndroidManifest.xml**:

```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <!-- Deep link for OAuth callback -->
    <data
      android:scheme="com.example.nonnaapp"
      android:host="oauth"
      android:pathPrefix="/callback" />
  </intent-filter>
</activity>
```

### iOS Deep Linking

In **Info.plist**:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
      <string>fb YOUR_FACEBOOK_APP_ID</string>
    </array>
  </dict>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>oauth-callback</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>nonnaapp</string>
    </array>
  </dict>
</array>
```

---

## Part 6: Testing OAuth

### Test Google Sign-In

```bash
# Build and run on Android device/emulator
flutter run -d android

# Or iOS
flutter run -d ios
```

1. Tap "Sign in with Google"
2. Select Google account
3. Verify you're logged in (profile shows email)
4. Try signing out

### Test Facebook Sign-In

1. Tap "Sign in with Facebook"
2. Log in with Facebook test account
3. Grant permissions
4. Verify login succeeded

### Expected Flow

```
User taps "Sign in with Google"
  ↓
Google Login screen opens
  ↓
User enters email/password
  ↓
Redirects back to app with auth token
  ↓
Supabase verifies token
  ↓
App user session created
  ↓
Navigate to home screen
```

---

## Troubleshooting

### Google Sign-In Shows "Cannot Sign In"

1. **Check SHA-1**: Ensure you added correct SHA-1 to Google Cloud Console
   ```bash
   flutter pub get && cd android && ./gradlew signingReport | grep SHA-1
   ```
2. **Check Package Name**: Ensure in manifest matches Google Cloud config
3. **Wait 5 minutes**: Google Cloud changes take time to propagate

### Facebook Login Returns Error

1. **Check App ID**: Verify correct App ID in Info.plist
2. **Check Key Hash**: Ensure Facebook key hash matches Android keystore
3. **Check Permissions**: Verify `email` and `public_profile` are available
4. **Test with Facebook Tester Account**: Use test account (not real account initially)

### Deep Link Not Working

1. **Check Intent Filter**: Ensure AndroidManifest.xml has correct scheme
2. **Check URL Scheme**: iOS - verify in Info.plist
3. **Test manually**:
   ```bash
   # Android
   adb shell am start -a android.intent.action.VIEW \
     -d "com.example.nonnaapp://oauth/callback"
   ```

### Token Expired

OAuth tokens expire. Handle token refresh:

```dart
// Check if token expired
final user = _supabase.auth.currentUser;
if (user?.userMetadata?['aud'] == null) {
  // Token expired, re-authenticate
  await signInWithGoogle();
}
```

---

## Security Best Practices

### 1. Never Hardcode Credentials

❌ Bad:
```dart
const googleClientId = 'abc123xyz...';
```

✅ Good:
```dart
// Use environment variables
const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
```

### 2. Use Secure Storage for Tokens

```dart
import 'flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Save token securely
await storage.write(key: 'access_token', value: token);

// Retrieve Token
final token = await storage.read(key: 'access_token');
```

### 3. Validate Tokens on Backend

Always verify OAuth tokens on your backend (Supabase RLS policies validate this).

### 4. Revoke Access When Needed

```dart
// Google
await _googleSignIn.disconnect();

// Facebook
await _facebookLogin.logOut();
```

---

## GDPR & Privacy Compliance

### Privacy Policy

Include in your app's privacy policy:
- "We use Google and Facebook OAuth for authentication"
- "We don't access Facebook/Google data beyond email and profile picture"
- "You can revoke access anytime in Google/Facebook settings"

### Clear OAuth Data

Users can:
1. **Google**: Remove app access in [Google Account Security](https://myaccount.google.com/permissions)
2. **Facebook**: Remove app access in [Facebook Apps & Websites](https://www.facebook.com/settings/apps)

---

## Production Checklist

Before releasing to app stores:

- ✅ Google OAuth configured in Google Cloud Console
- ✅ Facebook OAuth configured in Meta Developers
- ✅ Supabase OAuth providers enabled
- ✅ OAuth credentials in Supabase (not hardcoded)
- ✅ Deep linking configured for iOS and Android
- ✅ Privacy policy includes OAuth notice
- ✅ Tested on real phone (not just emulator)
- ✅ Verified token refresh works
- ✅ Tested sign out clears all data
- ✅ Error handling for network failures

---

## Next Steps

1. **Test OAuth flows** thoroughly in staging
2. **Monitor authentication errors** with Firebase Crashlytics (see FIREBASE_CRASHLYTICS_SETUP.md)
3. **Track login events** with Firebase Analytics (see FIREBASE_ANALYTICS_SETUP.md)
4. **Set up push notifications** for login-related events (see ONESIGNAL_SETUP.md)
5. **Create user profile** from OAuth data after first login

---

## Additional Resources

- [Google Identity Documentation](https://developers.google.com/identity/sign-in/android)
- [Meta Login SDK Documentation](https://developers.facebook.com/docs/facebook-login)
- [Flutter google_sign_in Package](https://pub.dev/packages/google_sign_in)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [GDPR Compliance Guide](https://gdpr-info.eu/)
