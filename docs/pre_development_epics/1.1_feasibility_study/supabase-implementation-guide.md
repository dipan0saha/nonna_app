# Supabase Implementation Guide for Nonna App

**Companion Document to:** Supabase Scalability Feasibility Study  
**Target Audience:** Development Team  
**Purpose:** Technical implementation details and best practices

---

## 1. Initial Setup and Configuration

### 1.1 Supabase Project Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Initialize local development
supabase init

# Start local Supabase instance
supabase start
```

### 1.2 Flutter Project Configuration

Already included in `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

Initialize in `main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // More secure
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
  
  runApp(const MyApp());
}

// Global accessor
final supabase = Supabase.instance.client;
```

---

## 2. Database Schema Design

### 2.1 User Profile Table

```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row-Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Indexes
CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at DESC);

-- Function to handle updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 2.2 Messages/Chat Table (Real-time Example)

```sql
-- Messages table
CREATE TABLE public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  edited_at TIMESTAMP WITH TIME ZONE,
  is_deleted BOOLEAN DEFAULT FALSE
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Only room members can view messages
CREATE POLICY "Users can view messages in their rooms"
  ON public.messages FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = messages.room_id
    )
  );

-- Users can insert their own messages
CREATE POLICY "Users can insert own messages"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update/delete their own messages
CREATE POLICY "Users can update own messages"
  ON public.messages FOR UPDATE
  USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX idx_messages_room_id ON public.messages(room_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_user_id ON public.messages(user_id);

-- Composite index for common queries
CREATE INDEX idx_messages_room_created ON public.messages(room_id, created_at DESC);
```

### 2.3 Room Members Table

```sql
CREATE TABLE public.room_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID NOT NULL,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  UNIQUE(room_id, user_id)
);

ALTER TABLE public.room_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view room members"
  ON public.room_members FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = room_members.room_id
    )
  );

CREATE INDEX idx_room_members_room ON public.room_members(room_id);
CREATE INDEX idx_room_members_user ON public.room_members(user_id);
```

---

## 3. Authentication Implementation

### 3.1 Email/Password Authentication

```dart
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // Stored in auth.users.raw_user_meta_data
    );
    
    // Create profile after signup
    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
      });
    }
    
    return response;
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
```

### 3.2 Social Authentication (Google)

```dart
Future<bool> signInWithGoogle() async {
  try {
    final response = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.nonna://login-callback',
    );
    return response;
  } catch (e) {
    print('Error signing in with Google: $e');
    return false;
  }
}
```

---

## 4. Real-time Implementation

### 4.1 Real-time Message Subscription

```dart
class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription? _messageSubscription;

  // Subscribe to new messages in a room
  Stream<List<Map<String, dynamic>>> subscribeToMessages(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .limit(50);  // Initial load limit
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String content,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'content': content,
    });
  }

  // Clean up
  void dispose() {
    _messageSubscription?.cancel();
  }
}
```

### 4.2 Presence/Typing Indicators with Broadcast

```dart
class PresenceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _presenceChannel;

  void joinRoom(String roomId, String username) {
    _presenceChannel = _supabase.channel('room:$roomId')
      ..onPresenceSync((payload) {
        // Handle presence sync
        print('Online users: ${payload.presences}');
      })
      ..onPresenceJoin((payload) {
        print('User joined: ${payload.user}');
      })
      ..onPresenceLeave((payload) {
        print('User left: ${payload.user}');
      })
      ..subscribe(
        (status, _) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _presenceChannel?.track({
              'user': username,
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        },
      );
  }

  void leaveRoom() {
    _presenceChannel?.unsubscribe();
    _presenceChannel = null;
  }

  // Typing indicator
  void sendTypingIndicator(String roomId) {
    _presenceChannel?.sendBroadcastMessage(
      event: 'typing',
      payload: {'user': _supabase.auth.currentUser?.id},
    );
  }

  Stream<dynamic> onTyping() {
    return _presenceChannel!.stream
        .where((event) => event.event == 'typing')
        .map((event) => event.payload);
  }
}
```

---

## 5. CRUD Operations

### 5.1 Read Operations with Optimization

```dart
class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get posts with pagination
  Future<List<Map<String, dynamic>>> getPosts({
    int page = 0,
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles!inner(username, avatar_url)')  // Join with profiles
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);
    
    return response as List<Map<String, dynamic>>;
  }

  // Get single post
  Future<Map<String, dynamic>?> getPost(String postId) async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles!inner(username, avatar_url)')
        .eq('id', postId)
        .single();
    
    return response;
  }

  // Get user's posts
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final response = await _supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return response as List<Map<String, dynamic>>;
  }
}
```

### 5.2 Create/Update Operations

```dart
// Create post
Future<Map<String, dynamic>> createPost({
  required String title,
  required String content,
}) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  final response = await _supabase
      .from('posts')
      .insert({
        'user_id': userId,
        'title': title,
        'content': content,
      })
      .select()
      .single();
  
  return response;
}

// Update post
Future<void> updatePost({
  required String postId,
  String? title,
  String? content,
}) async {
  final updates = <String, dynamic>{};
  if (title != null) updates['title'] = title;
  if (content != null) updates['content'] = content;

  await _supabase
      .from('posts')
      .update(updates)
      .eq('id', postId);
}

// Delete post (soft delete)
Future<void> deletePost(String postId) async {
  await _supabase
      .from('posts')
      .update({'is_deleted': true})
      .eq('id', postId);
}
```

---

## 6. File Storage

### 6.1 Upload Files

```dart
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload profile picture
  Future<String> uploadProfilePicture(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final extension = file.path.split('.').last;
    final fileName = '$userId/avatar.${extension}';

    await _supabase.storage
        .from('avatars')
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    // Get public URL
    final publicUrl = _supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

    return publicUrl;
  }

  // Upload post image
  Future<String> uploadPostImage(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final extension = file.path.split('.').last;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from('posts')
        .upload(fileName, file);

    return _supabase.storage
        .from('posts')
        .getPublicUrl(fileName);
  }

  // Download file
  Future<Uint8List> downloadFile(String path, String bucket) async {
    final data = await _supabase.storage
        .from(bucket)
        .download(path);
    
    return data;
  }

  // Delete file
  Future<void> deleteFile(String path, String bucket) async {
    await _supabase.storage
        .from(bucket)
        .remove([path]);
  }
}
```

### 6.2 Storage Bucket Setup

```sql
-- Create storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('avatars', 'avatars', true),
  ('posts', 'posts', true);

-- Storage policies for avatars
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

---

## 7. Performance Optimization

### 7.1 Connection Management

```dart
// Singleton pattern for Supabase client
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10, // Throttle events
      ),
    );
    _client = Supabase.instance.client;
  }
}
```

### 7.2 Caching with Hive

```dart
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _profilesBox = 'profiles';
  static const String _postsBox = 'posts';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_profilesBox);
    await Hive.openBox(_postsBox);
  }

  // Cache profile
  static Future<void> cacheProfile(String userId, Map<String, dynamic> data) async {
    final box = Hive.box(_profilesBox);
    await box.put(userId, data);
  }

  // Get cached profile
  static Map<String, dynamic>? getCachedProfile(String userId) {
    final box = Hive.box(_profilesBox);
    return box.get(userId);
  }

  // Clear cache
  static Future<void> clearCache() async {
    await Hive.box(_profilesBox).clear();
    await Hive.box(_postsBox).clear();
  }
}

// Usage in service
Future<Map<String, dynamic>> getProfile(String userId) async {
  // Try cache first
  final cached = CacheService.getCachedProfile(userId);
  if (cached != null) {
    return cached;
  }

  // Fetch from Supabase
  final profile = await _supabase
      .from('profiles')
      .select()
      .eq('id', userId)
      .single();

  // Cache for next time
  await CacheService.cacheProfile(userId, profile);
  
  return profile;
}
```

### 7.3 Debouncing Search

```dart
import 'dart:async';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _debounceTimer;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create completer for delayed search
    final completer = Completer<List<Map<String, dynamic>>>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        completer.complete([]);
        return;
      }

      final results = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      completer.complete(results as List<Map<String, dynamic>>);
    });

    return completer.future;
  }
}
```

---

## 8. Error Handling

### 8.1 Centralized Error Handling

```dart
class SupabaseException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  SupabaseException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'SupabaseException: $message';
}

class ErrorHandler {
  static SupabaseException handleError(dynamic error) {
    if (error is PostgrestException) {
      return SupabaseException(
        message: error.message,
        statusCode: int.tryParse(error.code ?? ''),
        originalError: error,
      );
    } else if (error is AuthException) {
      return SupabaseException(
        message: error.message,
        originalError: error,
      );
    } else if (error is StorageException) {
      return SupabaseException(
        message: error.message,
        originalError: error,
      );
    } else {
      return SupabaseException(
        message: 'An unexpected error occurred',
        originalError: error,
      );
    }
  }

  static String getUserFriendlyMessage(SupabaseException error) {
    if (error.originalError is AuthException) {
      final authError = error.originalError as AuthException;
      if (authError.message.contains('Invalid login credentials')) {
        return 'Incorrect email or password';
      } else if (authError.message.contains('Email not confirmed')) {
        return 'Please confirm your email address';
      }
    }
    
    return error.message;
  }
}

// Usage
try {
  await authService.signIn(email: email, password: password);
} catch (e) {
  final error = ErrorHandler.handleError(e);
  final message = ErrorHandler.getUserFriendlyMessage(error);
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

---

## 9. Testing

### 9.1 Unit Testing with Mock

```dart
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('AuthService Tests', () {
    late MockSupabaseClient mockClient;
    late AuthService authService;

    setUp(() {
      mockClient = MockSupabaseClient();
      // Inject mock client
    });

    test('signIn should return user on success', () async {
      // Arrange
      when(mockClient.auth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => AuthResponse(
        session: Session(/* mock data */),
      ));

      // Act
      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.user, isNotNull);
    });
  });
}
```

### 9.2 Integration Testing

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Integration Tests', () {
    setUpAll(() async {
      // Initialize with test project
      await Supabase.initialize(
        url: 'https://test-project.supabase.co',
        anonKey: 'test-anon-key',
      );
    });

    testWidgets('User can sign up and sign in', (tester) async {
      // Create test app
      await tester.pumpWidget(MyApp());

      // Navigate to sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(Key('email')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password')), 'password123');
      
      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

---

## 10. Monitoring and Analytics

### 10.1 Custom Analytics Events

```dart
class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    await _supabase.from('analytics_events').insert({
      'user_id': _supabase.auth.currentUser?.id,
      'event_name': eventName,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Example usage
  Future<void> logPageView(String pageName) async {
    await logEvent(
      eventName: 'page_view',
      properties: {'page': pageName},
    );
  }

  Future<void> logButtonClick(String buttonName) async {
    await logEvent(
      eventName: 'button_click',
      properties: {'button': buttonName},
    );
  }
}
```

### 10.2 Performance Monitoring

```dart
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};

  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  static Future<void> endTimer(String operation) async {
    if (!_startTimes.containsKey(operation)) return;
    
    final startTime = _startTimes[operation]!;
    final duration = DateTime.now().difference(startTime);
    
    // Log to Supabase
    await Supabase.instance.client.from('performance_metrics').insert({
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _startTimes.remove(operation);
  }
}

// Usage
PerformanceMonitor.startTimer('fetch_posts');
final posts = await postService.getPosts();
await PerformanceMonitor.endTimer('fetch_posts');
```

---

## 11. Migration Strategy

### 11.1 Database Migrations

```sql
-- migrations/20231201_create_profiles.sql
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- migrations/20231202_add_avatar_to_profiles.sql
ALTER TABLE public.profiles
ADD COLUMN avatar_url TEXT;
```

Apply with Supabase CLI:
```bash
supabase db push
```

### 11.2 Data Migration

```dart
class MigrationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> migrateUserProfiles() async {
    // Fetch users without profiles
    final users = await _supabase
        .from('auth.users')
        .select()
        .isFilter('profiles.id', null);

    // Create profiles
    for (final user in users) {
      await _supabase.from('profiles').insert({
        'id': user['id'],
        'username': user['email'].split('@')[0],
      });
    }
  }
}
```

---

## 12. Environment Configuration

### 12.1 Environment Variables

Create `.env` file:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

Load in Flutter:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}
```

### 12.2 Multiple Environments

```dart
enum Environment { dev, staging, prod }

class Config {
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return Environment.values.firstWhere((e) => e.name == env);
  }

  static String get supabaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://dev-project.supabase.co';
      case Environment.staging:
        return 'https://staging-project.supabase.co';
      case Environment.prod:
        return 'https://prod-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    // Load from secure storage or environment
    return dotenv.env['SUPABASE_ANON_KEY_${environment.name.toUpperCase()}']!;
  }
}
```

---

## 13. Security Best Practices

### 13.1 Row-Level Security Checklist

- ✅ Enable RLS on all tables
- ✅ Use `auth.uid()` for user-specific policies
- ✅ Test policies with different user roles
- ✅ Use `USING` clause for SELECT/UPDATE/DELETE
- ✅ Use `WITH CHECK` clause for INSERT/UPDATE
- ✅ Avoid exposing sensitive data in public policies

### 13.2 API Key Management

```dart
// NEVER commit API keys to version control
// Use environment variables or secure storage

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'supabase_key', value: key);
  }

  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'supabase_key');
  }
}
```

---

## 14. Deployment Checklist

### Pre-Launch
- [ ] Enable RLS on all tables
- [ ] Set up proper indexes
- [ ] Configure CORS settings
- [ ] Set up custom domain (optional)
- [ ] Configure email templates
- [ ] Set up monitoring and alerts
- [ ] Load test with expected traffic
- [ ] Review and optimize slow queries
- [ ] Set up database backups
- [ ] Configure rate limiting

### Post-Launch
- [ ] Monitor database performance
- [ ] Monitor API error rates
- [ ] Track real-time connection count
- [ ] Review and optimize queries
- [ ] Scale compute as needed
- [ ] Review security logs
- [ ] Monitor storage usage
- [ ] Set up automated backups

---

## 15. Common Patterns and Recipes

### 15.1 Infinite Scroll

```dart
class InfiniteScrollService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int _pageSize = 20;
  
  Future<List<Map<String, dynamic>>> loadMore(int page) async {
    final from = page * _pageSize;
    final to = from + _pageSize - 1;
    
    final response = await _supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);
    
    return response as List<Map<String, dynamic>>;
  }
}
```

### 15.2 Optimistic Updates

```dart
Future<void> likePost(String postId) async {
  // Update UI optimistically
  setState(() {
    post.likes++;
    post.isLiked = true;
  });

  try {
    // Update database
    await _supabase
        .from('post_likes')
        .insert({'post_id': postId, 'user_id': currentUserId});
  } catch (e) {
    // Revert on error
    setState(() {
      post.likes--;
      post.isLiked = false;
    });
    // Show error
  }
}
```

---

**Document Status:** Final  
**Last Updated:** December 2025  
**Maintainer:** Development Team
