# Services Layer

This directory contains all service classes for the Nonna App, including third-party integrations and core services.

## Overview

All services are initialized in `lib/core/services/app_initialization_service.dart`, which is called from `main.dart` before the app starts.

## Services Categories

### Core Supabase Services (3.2.1) ✅

#### 1. Supabase Client Manager
**Location**: `lib/core/network/supabase_client.dart`

Singleton Supabase client manager for the application.

**Features**:
- Singleton pattern
- Environment-based initialization
- PKCE authentication flow
- Debug mode support

**Usage Example**:
```dart
// Initialize in main.dart
await SupabaseClientManager.initialize();

// Access the client
final client = SupabaseClientManager.instance;
```

#### 2. Supabase Service
**Location**: `lib/core/services/supabase_service.dart`

Wrapper service for Supabase operations with centralized error handling.

**Features**:
- Database operations
- Storage operations
- Realtime operations
- Connection management
- Error handling
- Health checks

**Usage Example**:
```dart
final supabaseService = SupabaseService();

// Database query
final data = await supabaseService.from('profiles').select().execute();

// RPC call
final result = await supabaseService.rpc('my_function', params: {'id': 123});

// Health check
final isHealthy = await supabaseService.healthCheck();
```

#### 3. Database Service
**Location**: `lib/core/services/database_service.dart`

Query builder wrapper with pagination and batch operations.

**Features**:
- Typed query execution
- Pagination helpers
- Batch operations
- Transaction support via RPC

**Usage Example**:
```dart
final databaseService = DatabaseService();

// Paginated query
final result = await databaseService.getPaginated(
  'photos',
  page: 0,
  pageSize: 20,
  orderBy: 'created_at',
  ascending: false,
);

// Insert data
await databaseService.insert('photos', {
  'baby_profile_id': 'baby-123',
  'storage_path': 'path/to/photo.jpg',
});

// Batch insert
await databaseService.batchInsert('events', eventsData);
```

### Data Persistence Services (3.2.2) ✅

#### 4. Cache Service
**Location**: `lib/core/services/cache_service.dart`

Hive-based local caching with TTL and invalidation.

**Features**:
- TTL (Time-To-Live) support
- Cache invalidation via owner_update_markers
- Offline data access
- Cache size management

**Usage Example**:
```dart
final cacheService = CacheService();
await cacheService.initialize();

// Cache data with TTL
await cacheService.put(
  'user_profile_123',
  userProfile.toJson(),
  ttlMinutes: 60,
);

// Retrieve cached data
final cachedProfile = await cacheService.get<Map<String, dynamic>>(
  'user_profile_123',
);

// Invalidate cache
await cacheService.invalidateByBabyProfile('baby-123');
```

#### 5. Local Storage Service
**Location**: `lib/core/services/local_storage_service.dart`

SharedPreferences and secure storage wrapper.

**Features**:
- User preferences
- App settings
- Secure storage for sensitive data
- Onboarding flags

**Usage Example**:
```dart
final localStorage = LocalStorageService();
await localStorage.initialize();

// Save preferences
await localStorage.setThemeMode('dark');
await localStorage.setLanguageCode('en');

// Secure storage
await localStorage.saveAuthToken('jwt-token');
final token = await localStorage.getAuthToken();
```

### Real-Time & Notifications (3.2.3) ✅

#### 6. Realtime Service
**Location**: `lib/core/services/realtime_service.dart`

Supabase real-time subscriptions with channel management.

**Features**:
- Role/baby-scoped channels
- Connection management
- Automatic reconnection
- <2 second latency

**Usage Example**:
```dart
final realtimeService = RealtimeService();
await realtimeService.initialize();

// Subscribe to photos
final photosStream = realtimeService.subscribeToPhotos('baby-123');
photosStream.listen((event) {
  print('Photo event: ${event.eventType}');
});

// Unsubscribe
await realtimeService.unsubscribe('photos_baby-123');
```

#### 7. Notification Service
**Location**: `lib/core/services/notification_service.dart`

OneSignal push notifications integration.

**Features**:
- Push notification registration
- Deep-linking support
- Notification preferences
- Badge count management
- User targeting with tags

**Usage Example**:
```dart
// Initialize
await NotificationService.initialize(
  appId: 'your-onesignal-app-id',
);

// Set user
await NotificationService.setExternalUserId('user-123');

// Set tags
await NotificationService.setTags({
  'role': 'owner',
  'baby_profile_id': 'baby-123',
});

// Handle clicks
NotificationService.notificationClickStream.listen((data) {
  // Navigate based on notification data
});
```

### Monitoring & Analytics (3.2.4) ✅

#### 8. Observability Service
**Location**: `lib/core/services/observability_service.dart`

Sentry crash reporting and error logging.

**Features**:
- Crash reporting
- Error logging
- Performance monitoring
- Custom breadcrumbs
- User context

**Usage Example**:
```dart
// Initialize
await ObservabilityService.initialize(
  dsn: 'your-sentry-dsn',
  environment: 'production',
);

// Capture exception
await ObservabilityService.captureException(
  error,
  stackTrace: stackTrace,
);

// Add breadcrumb
ObservabilityService.addNavigationBreadcrumb(
  from: 'home',
  to: 'profile',
);

// Set user context
await ObservabilityService.setUser(
  userId: 'user-123',
  email: 'user@example.com',
);
```

### Authentication & Storage (Legacy)
**Location**: `lib/core/services/auth_service.dart`

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

### Authentication & Storage (Legacy)

#### 9. Authentication Service
**Location**: `lib/core/services/auth_service.dart`
**Location**: `lib/core/services/storage_service.dart`

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

#### 10. Storage Service
**Location**: `lib/core/services/storage_service.dart`
**Location**: `lib/core/services/analytics_service.dart`

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

#### 11. Analytics Service
**Location**: `lib/core/services/analytics_service.dart`
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

#### 12. App Initialization Service
**Location**: `lib/core/services/app_initialization_service.dart`

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
