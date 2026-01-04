# Third-Party Integration Services

This directory contains service classes for all third-party integrations configured in the Nonna App.

## Overview

All third-party services are initialized automatically in `lib/core/services/app_initialization_service.dart`, which is called from `main.dart` before the app starts.

## Services

### 1. Authentication Service
**Location**: `lib/features/auth/services/auth_service.dart`

Handles user authentication with Supabase Auth, including:
- Email/password authentication
- Google OAuth
- Facebook OAuth
- Password reset
- Email verification

**Usage Example**:
```dart
final authService = AuthService();

// Sign up
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

// Sign in
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// OAuth
await authService.signInWithGoogle();
await authService.signInWithFacebook();

// Sign out
await authService.signOut();
```

### 2. Storage Service
**Location**: `lib/features/storage/services/storage_service.dart`

Manages file uploads/downloads with Supabase Storage, including:
- Image picking (camera/gallery)
- Image compression
- Photo uploads to various buckets
- URL generation (public, signed, optimized)

**Usage Example**:
```dart
final storageService = StorageService();

// Pick and upload gallery photo
final imageFile = await storageService.pickImageFromGallery();
if (imageFile != null) {
  final storagePath = await storageService.uploadGalleryPhoto(
    imageFile: imageFile,
    babyProfileId: 'baby-123',
    caption: 'First smile!',
    tags: ['milestone', 'happy'],
  );
  
  // Get optimized URL
  final url = storageService.getOptimizedImageUrl(
    bucketName: 'gallery-photos',
    path: storagePath,
    width: 300,
    height: 300,
  );
}
```

### 3. Analytics Service
**Location**: `lib/features/analytics/services/analytics_service.dart`

Tracks user events with Firebase Analytics, including:
- Authentication events
- Photo events
- Event (calendar) events
- Registry events
- Invitation events

**Usage Example**:
```dart
// Enable analytics (with user consent)
await AnalyticsService.enable();

// Track events
await AnalyticsService.logPhotoUploaded(
  babyProfileId: 'baby-123',
  hasCaption: true,
  hasTags: true,
  fileSizeKb: 500,
);

await AnalyticsService.logPhotoSquished(
  photoId: 'photo-456',
  babyProfileId: 'baby-123',
);

// Set user properties
await AnalyticsService.setUserId('user-789');
await AnalyticsService.setUserProperty(
  name: 'account_type',
  value: 'owner',
);
```

### 4. App Initialization Service
**Location**: `lib/core/services/app_initialization_service.dart`

Orchestrates initialization of all third-party services:
- Supabase (backend)
- OneSignal (push notifications)
- Firebase (analytics, crashlytics, performance)

**Usage**: Called automatically in `main.dart`. No manual usage required.

```dart
// Already called in main.dart
await AppInitializationService.initialize();

// Set user ID after authentication
await AppInitializationService.setUserId('user-123');

// Clear user ID on logout
await AppInitializationService.clearUserId();
```

## Configuration Files

### Supabase Config
**Location**: `lib/core/config/supabase_config.dart`

Loads Supabase URL and keys from `.env` file.

### OneSignal Config
**Location**: `lib/core/config/onesignal_config.dart`

Configures OneSignal push notifications and handles notification events.

### Firebase Config
**Location**: `lib/core/config/firebase_config.dart`

Placeholder for Firebase configuration. Run `flutterfire configure` to generate `firebase_options.dart`.

## Environment Variables

All required environment variables are documented in `.env.example`. Copy to `.env` and fill in your values:

```bash
cp .env.example .env
# Edit .env with your actual values
```

**Required Variables**:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anonymous key
- `GOOGLE_CLIENT_ID` - Google OAuth client ID (optional)
- `FACEBOOK_APP_ID` - Facebook app ID (optional)
- `ONESIGNAL_APP_ID` - OneSignal app ID (optional)

## Dependencies

All required dependencies are defined in `pubspec.yaml`:

```yaml
dependencies:
  # Backend
  supabase_flutter: ^2.5.8
  flutter_dotenv: ^5.1.0
  
  # Authentication
  google_sign_in: ^6.2.0
  flutter_facebook_auth: ^6.0.0
  flutter_secure_storage: ^9.0.0
  
  # Storage
  flutter_image_compress: ^2.1.0
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  
  # Push Notifications
  onesignal_flutter: ^5.0.0
  
  # Analytics
  firebase_core: ^2.24.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.0
  firebase_performance: ^0.9.3
```

## Setup Instructions

Complete setup instructions for each service are available in:
- `docs/05_third_party_integrations/README.md` - Quick start guide
- `docs/05_third_party_integrations/01_Supabase_Project_Configuration.md`
- `docs/05_third_party_integrations/02_Authentication_Setup_Guide.md`
- `docs/05_third_party_integrations/03_Cloud_Storage_Configuration.md`
- `docs/05_third_party_integrations/05_Push_Notification_Configuration.md`
- `docs/05_third_party_integrations/06_Analytics_Setup_Document.md`

## Testing

Services can be tested using mock implementations:

```dart
// Example: Mock AuthService for testing
class MockAuthService extends Mock implements AuthService {}

test('sign in with email', () async {
  final mockAuthService = MockAuthService();
  when(() => mockAuthService.signInWithEmail(
    email: any(named: 'email'),
    password: any(named: 'password'),
  )).thenAnswer((_) async => mockAuthResponse);
  
  // Test your feature using mockAuthService
});
```

## Error Handling

All services use try-catch blocks and log errors via `debugPrint`. In production, errors are also reported to Firebase Crashlytics automatically.

```dart
try {
  await authService.signIn(...);
} on AuthException catch (e) {
  // Handle Supabase auth errors
  print('Auth error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

## Security Notes

- **Never commit `.env` file** - It contains sensitive credentials
- **Never expose `SERVICE_ROLE_KEY`** - Only use in server-side code
- **Always validate user input** - Both client and server-side
- **Use RLS policies** - Enforce authorization at database level
- **Store tokens securely** - Use `flutter_secure_storage` (Keychain/Keystore)

## Support

For questions or issues with third-party integrations:
- Review documentation in `docs/05_third_party_integrations/`
- Check service-specific troubleshooting sections
- Consult official documentation:
  - [Supabase Docs](https://supabase.com/docs)
  - [Firebase Docs](https://firebase.google.com/docs)
  - [OneSignal Docs](https://documentation.onesignal.com)
