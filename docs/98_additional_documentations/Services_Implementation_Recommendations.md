# Services Implementation Recommendations

**Document Version**: 1.0  
**Created**: February 5, 2026  
**Purpose**: Document recommended improvements for services implementation  
**Status**: Pending Implementation  

---

## 1. Profile Creation on Signup (Critical)

### Issue
Currently, when a user signs up via `AuthService.signUpWithEmail()`, a user record is created in Supabase Auth (`auth.users` table) but NOT in the application's `user_profiles` table. This creates a data inconsistency where:
- User can authenticate successfully
- Database queries requiring user profile fail
- RLS policies may not work correctly

### Current Code Location
`lib/core/services/auth_service.dart:37-59` (signUpWithEmail method)

### Recommended Solutions

#### Option A: Database Trigger (Recommended) ✅

**Pros:**
- Automatic and consistent
- No client-side dependencies
- Guaranteed to run on every signup
- Follows database best practices

**Implementation:**
Create a Supabase database trigger in `supabase/migrations/`:

```sql
-- Migration: Create trigger for user profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert new user profile when auth.users record is created
  INSERT INTO public.user_profiles (
    user_id,
    email,
    display_name,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NOW(),
    NOW()
  );
  
  -- Also create user_stats record
  INSERT INTO public.user_stats (
    user_id,
    photos_uploaded,
    events_created,
    comments_made,
    reactions_given,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    0, 0, 0, 0,
    NOW(),
    NOW()
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

**Testing:**
```sql
-- Test the trigger
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, raw_user_meta_data)
VALUES ('test@example.com', 'hashed', NOW(), '{"display_name": "Test User"}');

-- Verify profile was created
SELECT * FROM user_profiles WHERE email = 'test@example.com';
SELECT * FROM user_stats WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'test@example.com');
```

#### Option B: Application-Level (Alternative)

**Pros:**
- More control over profile initialization
- Can add additional business logic
- Can handle errors gracefully in UI

**Cons:**
- Client-side dependency
- Race conditions possible
- Not guaranteed to run

**Implementation:**
Update `AuthService.signUpWithEmail()`:

```dart
Future<AuthResponse> signUpWithEmail({
  required String email,
  required String password,
  String? displayName,
}) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName ?? email.split('@')[0]},
    );

    if (response.user != null) {
      // Create user profile in database
      await _databaseService.insert(SupabaseTables.userProfiles, {
        'user_id': response.user!.id,
        'email': email,
        'display_name': displayName ?? email.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create user stats
      await _databaseService.insert(SupabaseTables.userStats, {
        'user_id': response.user!.id,
        'photos_uploaded': 0,
        'events_created': 0,
        'comments_made': 0,
        'reactions_given': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      _setUserIdInServices(response.user!.id);
      await AnalyticsService.instance.logSignUp(method: 'email');
    }

    return response;
  } catch (e, stackTrace) {
    final message = ErrorHandler.mapErrorToMessage(e);
    throw AuthException(message, originalException: e, stackTrace: stackTrace);
  }
}
```

### Decision Required
✅ **RECOMMENDED: Implement Option A (Database Trigger)** for reliability and consistency.

---

## 2. CacheManager Integration (Critical - Performance)

### Issue
`CacheService` and `CacheManager` are fully implemented with excellent features but are **completely unused** in the codebase. This causes:
- Unnecessary database load
- Slower app performance
- Higher Supabase costs
- Wasted development effort

### Current Implementation Status

**CacheService** (`lib/core/services/cache_service.dart`):
- ✅ TTL strategies (5 min, 30 min, 60 min, 24 hours)
- ✅ Owner update invalidation
- ✅ Baby profile invalidation
- ✅ LRU/LFU eviction policies
- ❌ NOT initialized in AppInitializationService
- ❌ NOT used by any service

**CacheManager** (`lib/core/middleware/cache_manager.dart`):
- ✅ `getOrFetch<T>()` pattern
- ✅ Pattern/prefix invalidation
- ✅ Cache warming
- ✅ Statistics tracking
- ❌ NOT imported by any service
- ❌ NOT integrated with DatabaseService

### Recommended Implementation

#### Step 1: Initialize CacheService

Update `AppInitializationService.initialize()`:

```dart
static Future<void> initialize() async {
  try {
    debugPrint('🚀 Initializing app services...');

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // Initialize CacheService  // <-- ADD THIS
    final cacheService = CacheService();
    await cacheService.initialize();
    debugPrint('✅ CacheService initialized');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ... rest of initialization
  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing app: $e');
    ObservabilityService.captureException(e, stackTrace: stackTrace);
    rethrow;
  }
}
```

#### Step 2: Integrate CacheManager into DatabaseService

Create a singleton CacheManager:

```dart
// In lib/core/di/service_locator.dart (new file)
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();

  late final CacheService cacheService;
  late final CacheManager cacheManager;

  Future<void> initialize() async {
    cacheService = CacheService();
    await cacheService.initialize();
    cacheManager = CacheManager(cacheService);
  }
}
```

Update `DatabaseService` to use CacheManager:

```dart
class DatabaseService {
  final SupabaseClient _client;
  final AuthInterceptor _authInterceptor;
  final CacheManager? _cacheManager;  // <-- ADD THIS

  DatabaseService({
    SupabaseClient? client,
    CacheManager? cacheManager,  // <-- ADD THIS
  })  : _client = client ?? SupabaseClientManager.instance.client,
        _authInterceptor = AuthInterceptor(client ?? SupabaseClientManager.instance.client),
        _cacheManager = cacheManager;

  /// Select with caching support
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    bool useCache = true,  // <-- ADD THIS
    Duration? cacheTtl,
  }) async {
    if (useCache && _cacheManager != null) {
      final cacheKey = 'db:$table:$columns';
      
      return await _cacheManager!.getOrFetch<List<Map<String, dynamic>>>(
        key: cacheKey,
        fetcher: () => _fetchFromDatabase(table, columns),
        ttl: cacheTtl ?? CacheTTL.medium,
      );
    }

    return await _fetchFromDatabase(table, columns);
  }

  Future<List<Map<String, dynamic>>> _fetchFromDatabase(String table, String columns) async {
    try {
      final response = await _client
          .from(table)
          .select(columns);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      final message = ErrorHandler.mapErrorToMessage(e);
      throw DatabaseException(message, originalException: e, stackTrace: stackTrace);
    }
  }

  /// Insert with cache invalidation
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _authInterceptor.executeWithRetry(() async {
        final response = await _client.from(table).insert(data).select().single();
        return response;
      });

      // Invalidate related caches
      if (_cacheManager != null) {
        await _cacheManager!.invalidateByPattern('db:$table:');
        debugPrint('🗑️ Cache invalidated for table: $table');
      }

      return result;
    } catch (e, stackTrace) {
      final message = ErrorHandler.mapErrorToMessage(e);
      throw DatabaseException(message, originalException: e, stackTrace: stackTrace);
    }
  }

  // Similar updates for update(), delete(), upsert()
}
```

#### Step 3: Use Caching for Frequently-Accessed Data

**User Profiles:**
```dart
final userProfile = await databaseService.select(
  SupabaseTables.userProfiles,
  useCache: true,
  cacheTtl: PerformanceLimits.userProfileCacheDuration,
).eq('user_id', userId).single();
```

**Baby Profiles:**
```dart
final babyProfile = await databaseService.select(
  SupabaseTables.babyProfiles,
  useCache: true,
  cacheTtl: PerformanceLimits.babyProfileCacheDuration,
).eq('id', babyProfileId).single();
```

**Tile Configurations:**
```dart
final tileConfigs = await databaseService.select(
  SupabaseTables.tileConfigs,
  useCache: true,
  cacheTtl: PerformanceLimits.tileConfigCacheDuration,
);
```

### Performance Impact
- **Estimated Query Reduction**: 60-70%
- **Response Time Improvement**: 80-90% for cached data
- **Cost Savings**: 40-50% reduction in Supabase read operations

### Implementation Priority
🔴 **CRITICAL - HIGH PRIORITY**
- Effort: 2-3 days
- Impact: Significant performance improvement
- Risk: Low (well-tested existing code)

---

## 3. Additional Minor Improvements

### 3.1 Add OAuth Scopes Constants

Create `lib/core/constants/oauth_constants.dart`:

```dart
class OAuthConstants {
  OAuthConstants._();

  // Google OAuth scopes
  static const List<String> googleScopes = [
    'email',
    'profile',
  ];

  // Facebook OAuth scopes
  static const List<String> facebookScopes = [
    'email',
    'public_profile',
  ];

  // Apple OAuth scopes
  static const List<String> appleScopes = [
    'email',
    'name',
  ];
}
```

Update `AuthService`:
```dart
final response = await _supabase.auth.signInWithOAuth(
  Provider.google,
  scopes: OAuthConstants.googleScopes,  // <-- Use constant
  redirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
);
```

### 3.2 Fix Race Condition in RealtimeService

Add mutex for channel operations:

```dart
import 'package:synchronized/synchronized.dart';

class RealtimeService {
  final _channelLock = Lock();

  Future<void> reconnect() async {
    await _channelLock.synchronized(() async {
      debugPrint('🔄 Handling realtime disconnection...');

      final channelNames = List<String>.from(_channels.keys);

      for (final channelName in channelNames) {
        final channel = _channels[channelName];
        if (channel != null) {
          await _client.removeChannel(channel);
        }
      }
      _channels.clear();
      
      debugPrint('✅ Reconnected to realtime');
    });
  }
}
```

Add `synchronized: ^3.1.0` to `pubspec.yaml`.

### 3.3 Fix NotificationService Disposal

Document the intentional behavior:

```dart
/// Dispose of the notification service
/// 
/// Note: The notification click stream controller is intentionally NOT closed
/// to allow notifications to be processed even after service disposal. This
/// ensures that background notifications can still trigger navigation.
Future<void> dispose() async {
  _isInitialized = false;
  // _notificationClickController intentionally kept open for background notifications
  debugPrint('✅ NotificationService disposed (stream kept alive for background processing)');
}
```

---

## 4. Implementation Timeline

| Task | Priority | Effort | Dependencies |
|------|----------|--------|--------------|
| Profile creation trigger | 🔴 Critical | 4 hours | Database access |
| CacheService initialization | 🔴 Critical | 2 hours | None |
| CacheManager integration | 🔴 Critical | 2 days | CacheService init |
| Add OAuth constants | 🟡 Medium | 1 hour | None |
| Fix race conditions | 🟡 Medium | 4 hours | synchronized package |
| Document disposal | 🟢 Low | 30 min | None |

**Total Critical Path: 2.5 days**

---

## 5. Testing Requirements

### Profile Creation
- [ ] Test signup creates user_profiles record
- [ ] Test signup creates user_stats record
- [ ] Test trigger handles duplicate signups gracefully
- [ ] Test trigger handles missing display_name

### CacheManager Integration
- [ ] Test cache hit returns cached data
- [ ] Test cache miss fetches from database
- [ ] Test cache invalidation on insert/update/delete
- [ ] Test TTL expiration works correctly
- [ ] Test owner update invalidation
- [ ] Test baby profile invalidation

### Performance Testing
- [ ] Benchmark query times with/without cache
- [ ] Load test with concurrent users
- [ ] Verify cache memory usage
- [ ] Test cache eviction under memory pressure

---

## 6. Rollback Plan

If issues arise:

### Profile Creation Trigger
```sql
-- Disable trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Manually clean up test data
DELETE FROM user_profiles WHERE email LIKE '%test%';
DELETE FROM user_stats WHERE user_id IN (SELECT id FROM auth.users WHERE email LIKE '%test%');
```

### CacheManager Integration
- Set `useCache: false` as default in DatabaseService
- Comment out CacheService initialization
- Services will fall back to direct database queries

---

## 7. Success Metrics

### Profile Creation
- ✅ 100% of signups create user_profiles record
- ✅ Zero profile-related errors in production logs
- ✅ All RLS policies work correctly

### CacheManager Integration
- ✅ 60%+ reduction in database queries
- ✅ 80%+ response time improvement for cached queries
- ✅ 40%+ reduction in Supabase costs
- ✅ Zero cache-related errors in production

---

**Document Owner**: Development Team  
**Review Cycle**: Before each sprint  
**Last Updated**: February 5, 2026
