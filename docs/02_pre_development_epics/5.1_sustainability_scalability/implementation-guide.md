# Implementation Guide: Sustainability and Scalability

**Epic:** 5.1 - Sustainable Development and Scalability Planning  
**Version:** 1.0  
**Date:** December 2025  
**Audience:** Developers, Technical Leads

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [Database Optimization Implementation](#2-database-optimization-implementation)
3. [Storage and CDN Implementation](#3-storage-and-cdn-implementation)
4. [Real-Time Optimization Implementation](#4-real-time-optimization-implementation)
5. [Frontend Performance Implementation](#5-frontend-performance-implementation)
6. [Monitoring and Observability Implementation](#6-monitoring-and-observability-implementation)
7. [Cost Optimization Implementation](#7-cost-optimization-implementation)
8. [Testing and Validation](#8-testing-and-validation)

---

## 1. Getting Started

### 1.1 Prerequisites

**Required Tools:**
- Flutter SDK 3.x or later
- Supabase CLI
- PostgreSQL client (psql)
- Git

**Required Access:**
- Supabase project admin access
- GitHub repository write access
- Sentry admin access (for monitoring setup)

**Knowledge Requirements:**
- Flutter/Dart development
- PostgreSQL and SQL
- Supabase platform basics
- Basic DevOps concepts

### 1.2 Development Environment Setup

```bash
# Clone repository
git clone https://github.com/your-org/nonna_app.git
cd nonna_app

# Install Flutter dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Set up Supabase CLI
brew install supabase/tap/supabase  # macOS
# or
npm install -g supabase              # Cross-platform

# Login to Supabase
supabase login

# Link to project
supabase link --project-ref YOUR_PROJECT_REF
```

### 1.3 Project Structure

```
nonna_app/
├── lib/
│   ├── features/           # Feature modules
│   ├── core/               # Shared code
│   └── main.dart
├── test/                   # Unit and widget tests
├── integration_test/       # Integration tests
├── supabase/
│   ├── migrations/         # Database migrations
│   └── functions/          # Edge Functions
├── scripts/                # Utility scripts
└── docs/                   # Documentation
```

---

## 2. Database Optimization Implementation

### 2.1 Indexing Strategy

#### Step 1: Analyze Current Index Usage

```sql
-- Check existing indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

#### Step 2: Create Missing Indexes

Create a migration file:

```bash
supabase migration new add_performance_indexes
```

Add indexes to the migration:

```sql
-- Migration: YYYYMMDDHHMMSS_add_performance_indexes.sql

-- Foreign key indexes (CRITICAL)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photos_baby_profile_id 
ON photos(baby_profile_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_events_baby_profile_id 
ON events(baby_profile_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_registry_items_baby_profile_id 
ON registry_items(baby_profile_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photo_comments_photo_id 
ON photo_comments(photo_id);

-- Timestamp indexes (for sorting and filtering)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photos_created_at 
ON photos(created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_events_event_date 
ON events(event_date);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_created_at 
ON notifications(created_at DESC);

-- Composite indexes (for common query patterns)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photos_profile_created 
ON photos(baby_profile_id, created_at DESC) 
WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_events_profile_date 
ON events(baby_profile_id, event_date);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_memberships_user_profile 
ON baby_profile_memberships(user_id, baby_profile_id);

-- Partial indexes (for filtered queries)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_invitations_pending 
ON invitations(baby_profile_id, created_at DESC) 
WHERE status = 'pending' AND expires_at > NOW();

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_unread 
ON notifications(user_id, created_at DESC) 
WHERE is_read = false;

-- Full-text search indexes (if needed)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_baby_profiles_name_search 
ON baby_profiles USING gin(to_tsvector('english', name));

-- Analyze tables to update statistics
ANALYZE baby_profiles;
ANALYZE photos;
ANALYZE events;
ANALYZE registry_items;
ANALYZE notifications;
```

#### Step 3: Deploy Migration

```bash
# Apply migration locally
supabase db reset

# Test locally
supabase db push

# Deploy to production (when ready)
supabase db push --db-url "postgresql://..."
```

### 2.2 Query Optimization

#### Step 1: Identify Slow Queries

Enable slow query logging:

```sql
-- Enable slow query logging (queries > 100ms)
ALTER DATABASE postgres SET log_min_duration_statement = 100;

-- Reload configuration
SELECT pg_reload_conf();

-- Install pg_stat_statements (if not already installed)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

#### Step 2: Analyze and Optimize Queries

```dart
// Example: Optimize photo gallery query

// BEFORE (N+1 queries)
Future<List<PhotoWithStats>> getPhotosWithStats(String profileId) async {
  // Get photos
  final photos = await supabase
      .from('photos')
      .select()
      .eq('baby_profile_id', profileId)
      .order('created_at', ascending: false)
      .limit(20);
  
  // Get stats for each photo (N queries!)
  final result = <PhotoWithStats>[];
  for (final photo in photos) {
    final squishes = await supabase
        .from('photo_squishes')
        .select('id', count: CountOption.exact)
        .eq('photo_id', photo['id']);
    
    final comments = await supabase
        .from('photo_comments')
        .select('id', count: CountOption.exact)
        .eq('photo_id', photo['id']);
    
    result.add(PhotoWithStats(
      photo: Photo.fromJson(photo),
      squishCount: squishes.count,
      commentCount: comments.count,
    ));
  }
  
  return result;
}

// AFTER (Single query)
Future<List<PhotoWithStats>> getPhotosWithStats(String profileId) async {
  final data = await supabase
      .from('photos')
      .select('''
        *,
        squish_count:photo_squishes(count),
        comment_count:photo_comments(count)
      ''')
      .eq('baby_profile_id', profileId)
      .is_('deleted_at', null)
      .order('created_at', ascending: false)
      .limit(20);
  
  return data.map((row) => PhotoWithStats.fromJson(row)).toList();
}
```

#### Step 3: Use EXPLAIN ANALYZE

```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT 
    p.*,
    COUNT(DISTINCT ps.id) as squish_count,
    COUNT(DISTINCT pc.id) as comment_count
FROM photos p
LEFT JOIN photo_squishes ps ON p.id = ps.photo_id
LEFT JOIN photo_comments pc ON p.id = pc.photo_id
WHERE p.baby_profile_id = 'profile-123'
  AND p.deleted_at IS NULL
GROUP BY p.id
ORDER BY p.created_at DESC
LIMIT 20;

-- Look for:
-- ✅ Index Scan (good)
-- ❌ Seq Scan (bad - add index)
-- ✅ Low cost (<1000)
-- ❌ High cost (>10000 - optimize query)
```

### 2.3 Connection Pooling

#### Step 1: Configure Supabase Connection Pooling

Connection pooling is automatically enabled in Supabase. Verify settings:

```dart
// lib/core/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      // Optimize WebSocket connections
      eventsPerSecond: 10,
    ),
  );
}
```

#### Step 2: Implement Repository Pattern

```dart
// lib/core/data/base_repository.dart
abstract class BaseRepository {
  SupabaseClient get supabase => Supabase.instance.client;
  
  // Helper method for error handling
  Future<T> execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PostgrestException catch (e) {
      throw RepositoryException(
        message: 'Database error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw RepositoryException(
        message: 'Unexpected error: $e',
      );
    }
  }
}

// lib/features/gallery/data/photo_repository.dart
class PhotoRepository extends BaseRepository {
  Future<List<Photo>> getPhotos(String babyProfileId, {int limit = 20}) {
    return execute(() async {
      final data = await supabase
          .from('photos')
          .select()
          .eq('baby_profile_id', babyProfileId)
          .is_('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return data.map((json) => Photo.fromJson(json)).toList();
    });
  }
}
```

### 2.4 Soft Delete Implementation

#### Step 1: Add Soft Delete Migration

```sql
-- Migration: add_soft_delete_columns.sql

-- Add deleted_at column to relevant tables
ALTER TABLE baby_profiles ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
ALTER TABLE photos ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
ALTER TABLE events ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
ALTER TABLE registry_items ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

-- Create indexes for active records
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_baby_profiles_active 
ON baby_profiles(id) 
WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_photos_active 
ON photos(baby_profile_id, created_at DESC) 
WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_events_active 
ON events(baby_profile_id, event_date) 
WHERE deleted_at IS NULL;

-- Create function to soft delete with cascade
CREATE OR REPLACE FUNCTION soft_delete_baby_profile(profile_id UUID)
RETURNS void AS $$
BEGIN
  -- Soft delete the profile
  UPDATE baby_profiles
  SET deleted_at = NOW()
  WHERE id = profile_id;
  
  -- Soft delete related data
  UPDATE photos SET deleted_at = NOW() WHERE baby_profile_id = profile_id;
  UPDATE events SET deleted_at = NOW() WHERE baby_profile_id = profile_id;
  UPDATE registry_items SET deleted_at = NOW() WHERE baby_profile_id = profile_id;
END;
$$ LANGUAGE plpgsql;
```

#### Step 2: Implement Soft Delete in Application

```dart
// lib/features/baby_profile/data/baby_profile_repository.dart
class BabyProfileRepository extends BaseRepository {
  
  // Get active profiles only
  Future<List<BabyProfile>> getProfiles(String userId) {
    return execute(() async {
      final data = await supabase
          .from('baby_profiles')
          .select()
          .eq('owner_id', userId)
          .is_('deleted_at', null)  // Filter out deleted
          .order('created_at', ascending: false);
      
      return data.map((json) => BabyProfile.fromJson(json)).toList();
    });
  }
  
  // Soft delete profile
  Future<void> deleteProfile(String profileId) {
    return execute(() async {
      await supabase.rpc('soft_delete_baby_profile', params: {
        'profile_id': profileId,
      });
    });
  }
  
  // Restore deleted profile (if within grace period)
  Future<void> restoreProfile(String profileId) {
    return execute(() async {
      await supabase
          .from('baby_profiles')
          .update({'deleted_at': null})
          .eq('id', profileId);
    });
  }
}
```

---

## 3. Storage and CDN Implementation

### 3.1 Image Compression

#### Step 1: Install Image Compression Package

```yaml
# pubspec.yaml
dependencies:
  flutter_image_compress: ^2.1.0
```

#### Step 2: Implement Compression Service

```dart
// lib/core/services/image_compression_service.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int quality = 85;
  
  Future<File> compressImage(File imageFile) async {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Compress image
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    
    if (compressedBytes == null) {
      throw Exception('Failed to compress image');
    }
    
    // Write compressed file
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(compressedBytes);
    
    // Log compression results
    final originalSize = await imageFile.length();
    final compressedSize = compressedBytes.length;
    final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
    
    print('Image compressed: ${originalSize / 1024 / 1024}MB → ${compressedSize / 1024 / 1024}MB ($reduction% reduction)');
    
    return compressedFile;
  }
}
```

#### Step 3: Use in Upload Flow

```dart
// lib/features/gallery/data/photo_storage_repository.dart
class PhotoStorageRepository {
  final ImageCompressionService _compressionService;
  final SupabaseClient _supabase;
  
  PhotoStorageRepository(this._compressionService, this._supabase);
  
  Future<String> uploadPhoto({
    required File imageFile,
    required String babyProfileId,
  }) async {
    // 1. Compress image
    final compressedFile = await _compressionService.compressImage(imageFile);
    
    // 2. Generate unique filename
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$babyProfileId/$fileName';
    
    // 3. Upload to Supabase Storage
    await _supabase.storage.from('photos').upload(
      path,
      compressedFile,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );
    
    // 4. Clean up temporary file
    await compressedFile.delete();
    
    // 5. Get public URL
    final url = _supabase.storage.from('photos').getPublicUrl(path);
    
    return url;
  }
}
```

### 3.2 Thumbnail Generation

#### Step 1: Create Edge Function for Thumbnails

```bash
supabase functions new generate-thumbnails
```

```typescript
// supabase/functions/generate-thumbnails/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';

serve(async (req) => {
  try {
    const { photoId, storagePath } = await req.json();
    
    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );
    
    // Download original image
    const { data: originalData, error: downloadError } = await supabase.storage
      .from('photos')
      .download(storagePath);
    
    if (downloadError) throw downloadError;
    
    // Load image
    const arrayBuffer = await originalData.arrayBuffer();
    const image = await Image.decode(new Uint8Array(arrayBuffer));
    
    // Generate thumbnails
    const sizes = [
      { name: 'thumbnail', width: 200, height: 200 },
      { name: 'medium', width: 800, height: 800 },
    ];
    
    for (const size of sizes) {
      // Resize image (cover mode)
      const resized = image.cover(size.width, size.height);
      
      // Encode as JPEG
      const encoded = await resized.encodeJPEG(85);
      
      // Upload thumbnail
      const thumbnailPath = storagePath.replace('.jpg', `_${size.name}.jpg`);
      const { error: uploadError } = await supabase.storage
        .from('photos')
        .upload(thumbnailPath, encoded, {
          contentType: 'image/jpeg',
          cacheControl: '2592000', // 30 days
        });
      
      if (uploadError) throw uploadError;
    }
    
    return new Response(
      JSON.stringify({ success: true, photoId }),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
```

#### Step 2: Deploy Edge Function

```bash
supabase functions deploy generate-thumbnails
```

#### Step 3: Call from Application

```dart
// lib/features/gallery/data/photo_storage_repository.dart
Future<String> uploadPhoto({
  required File imageFile,
  required String babyProfileId,
}) async {
  // 1. Compress and upload original
  final path = await _uploadOriginal(imageFile, babyProfileId);
  
  // 2. Trigger thumbnail generation (async)
  _generateThumbnails(path).catchError((e) {
    // Log error but don't fail upload
    print('Thumbnail generation failed: $e');
  });
  
  return path;
}

Future<void> _generateThumbnails(String storagePath) async {
  await _supabase.functions.invoke('generate-thumbnails', body: {
    'storagePath': storagePath,
  });
}
```

### 3.3 Image Caching

#### Step 1: Install Cached Network Image

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0
```

#### Step 2: Configure Custom Cache Manager

```dart
// lib/core/services/custom_cache_manager.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'baby_photos';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
```

#### Step 3: Use in Photo Widget

```dart
// lib/features/gallery/presentation/widgets/photo_card.dart
import 'package:cached_network_image/cached_network_image.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _getThumbnailUrl(photo.url),
      cacheManager: CustomCacheManager.instance,
      placeholder: (context, url) => const ShimmerPlaceholder(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }
  
  String _getThumbnailUrl(String originalUrl) {
    // Replace .jpg with _thumbnail.jpg
    return originalUrl.replaceAll('.jpg', '_thumbnail.jpg');
  }
}
```

---

## 4. Real-Time Optimization Implementation

### 4.1 Scoped Subscriptions

```dart
// lib/features/gallery/presentation/blocs/photo_gallery_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoGalleryBloc extends Bloc<PhotoGalleryEvent, PhotoGalleryState> {
  final PhotoRepository _repository;
  final SupabaseClient _supabase;
  
  StreamSubscription<List<Map<String, dynamic>>>? _photoSubscription;
  
  PhotoGalleryBloc(this._repository, this._supabase) 
      : super(PhotoGalleryInitial()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<PhotosUpdated>(_onPhotosUpdated);
  }
  
  Future<void> _onLoadPhotos(
    LoadPhotos event,
    Emitter<PhotoGalleryState> emit,
  ) async {
    emit(PhotoGalleryLoading());
    
    try {
      // Load initial data
      final photos = await _repository.getPhotos(event.babyProfileId);
      emit(PhotoGalleryLoaded(photos));
      
      // Set up real-time subscription (scoped to this baby profile)
      _setupRealtime(event.babyProfileId);
    } catch (e) {
      emit(PhotoGalleryError(e.toString()));
    }
  }
  
  void _setupRealtime(String babyProfileId) {
    // Cancel existing subscription
    _photoSubscription?.cancel();
    
    // Subscribe only to this baby profile's photos
    _photoSubscription = _supabase
        .from('photos')
        .stream(primaryKey: ['id'])
        .eq('baby_profile_id', babyProfileId)
        .is_('deleted_at', null)
        .listen((data) {
          add(PhotosUpdated(
            data.map((json) => Photo.fromJson(json)).toList(),
          ));
        });
  }
  
  void _onPhotosUpdated(
    PhotosUpdated event,
    Emitter<PhotoGalleryState> emit,
  ) {
    emit(PhotoGalleryLoaded(event.photos));
  }
  
  @override
  Future<void> close() {
    _photoSubscription?.cancel();
    return super.close();
  }
}
```

### 4.2 Debouncing and Throttling

```dart
// lib/core/utils/stream_utils.dart
import 'dart:async';

extension StreamExtensions<T> on Stream<T> {
  /// Debounce stream events
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    late StreamController<T> controller;
    
    controller = StreamController<T>(
      onListen: () {
        listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (!controller.isClosed) {
                controller.add(data);
              }
            });
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () => timer?.cancel(),
    );
    
    return controller.stream;
  }
  
  /// Throttle stream events
  Stream<T> throttle(Duration duration) {
    Timer? timer;
    late StreamController<T> controller;
    
    controller = StreamController<T>(
      onListen: () {
        listen(
          (data) {
            if (timer == null || !timer!.isActive) {
              controller.add(data);
              timer = Timer(duration, () {});
            }
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () => timer?.cancel(),
    );
    
    return controller.stream;
  }
}

// Usage example
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      // Debounce search queries (300ms)
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 300))
          .asyncExpand(mapper),
    );
  }
}
```

---

## 5. Frontend Performance Implementation

### 5.1 Code Splitting

```dart
// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) {
        // Lazy load profile screen
        return BabyProfileScreen(
          profileId: state.pathParameters['id']!,
        );
      },
    ),
    GoRoute(
      path: '/gallery/:profileId',
      builder: (context, state) {
        // Lazy load gallery screen
        return PhotoGalleryScreen(
          profileId: state.pathParameters['profileId']!,
        );
      },
    ),
  ],
);
```

### 5.2 Memory Management

```dart
// lib/features/gallery/presentation/screens/photo_gallery_screen.dart
class PhotoGalleryScreen extends StatefulWidget {
  final String profileId;
  
  const PhotoGalleryScreen({required this.profileId});
  
  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PhotoGalleryBloc _bloc;
  
  @override
  void initState() {
    super.initState();
    _bloc = context.read<PhotoGalleryBloc>();
    _bloc.add(LoadPhotos(widget.profileId));
    
    // Set up infinite scroll
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    // IMPORTANT: Dispose controllers and cancel subscriptions
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      _bloc.add(LoadMorePhotos());
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PhotoGalleryBloc, PhotoGalleryState>(
        builder: (context, state) {
          if (state is PhotoGalleryLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.photos.length,
              itemBuilder: (context, index) {
                return PhotoCard(
                  // IMPORTANT: Provide key for efficient updates
                  key: ValueKey(state.photos[index].id),
                  photo: state.photos[index],
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### 5.3 Offline-First Implementation

```dart
// lib/core/data/local_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'nonna_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE baby_profiles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            birth_date TEXT,
            photo_url TEXT,
            updated_at INTEGER NOT NULL,
            synced_at INTEGER
          )
        ''');
        
        await db.execute('''
          CREATE TABLE photos (
            id TEXT PRIMARY KEY,
            baby_profile_id TEXT NOT NULL,
            url TEXT NOT NULL,
            caption TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced_at INTEGER,
            FOREIGN KEY (baby_profile_id) REFERENCES baby_profiles (id)
          )
        ''');
        
        await db.execute('''
          CREATE INDEX idx_photos_profile 
          ON photos(baby_profile_id, created_at DESC)
        ''');
      },
    );
  }
  
  Future<void> saveProfile(BabyProfile profile) async {
    final db = await database;
    await db.insert(
      'baby_profiles',
      {
        'id': profile.id,
        'name': profile.name,
        'birth_date': profile.birthDate?.toIso8601String(),
        'photo_url': profile.photoUrl,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'synced_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<BabyProfile?> getProfile(String id) async {
    final db = await database;
    final maps = await db.query(
      'baby_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    return BabyProfile.fromMap(maps.first);
  }
}
```

---

## 6. Monitoring and Observability Implementation

### 6.1 Sentry Setup

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 0.2; // 20% of transactions
      options.profilesSampleRate = 0.2;
      options.enableAutoPerformanceTracing = true;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.release = 'nonna-app@1.0.0';
      
      // Attach user context
      options.beforeSend = (event, hint) async {
        // Add custom context
        event = event.copyWith(
          user: SentryUser(
            id: currentUserId,
            email: currentUserEmail,
          ),
        );
        return event;
      };
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### 6.2 Custom Performance Tracking

```dart
// lib/core/services/performance_tracker.dart
import 'package:sentry_flutter/sentry_flutter.dart';

class PerformanceTracker {
  static Future<T> track<T>({
    required String operation,
    required Future<T> Function() function,
    Map<String, dynamic>? data,
  }) async {
    final transaction = Sentry.startTransaction(
      operation,
      'task',
    );
    
    try {
      // Add custom data
      if (data != null) {
        for (final entry in data.entries) {
          transaction.setData(entry.key, entry.value);
        }
      }
      
      final result = await function();
      transaction.finish(status: SpanStatus.ok());
      return result;
    } catch (e) {
      transaction.finish(status: SpanStatus.internalError());
      rethrow;
    }
  }
}

// Usage
Future<void> uploadPhoto(File photo, String profileId) async {
  await PerformanceTracker.track(
    operation: 'upload_photo',
    data: {'profile_id': profileId},
    function: () async {
      // Actual upload logic
      await _storageRepository.uploadPhoto(photo, profileId);
    },
  );
}
```

---

## 7. Cost Optimization Implementation

### 7.1 Storage Lifecycle Policies

Create an Edge Function for cleanup:

```typescript
// supabase/functions/cleanup-old-thumbnails/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );
  
  // Find old, unused thumbnails (180+ days old, not viewed in 90 days)
  const { data: oldThumbnails } = await supabase
    .from('photo_versions')
    .select('storage_path')
    .eq('version_type', 'thumbnail')
    .lt('created_at', new Date(Date.now() - 180 * 24 * 60 * 60 * 1000).toISOString())
    .not('photo_id', 'in', `(
      SELECT photo_id 
      FROM photo_views 
      WHERE viewed_at > '${new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString()}'
    )`);
  
  // Delete old thumbnails
  let deletedCount = 0;
  for (const thumbnail of oldThumbnails || []) {
    const { error } = await supabase.storage
      .from('photos')
      .remove([thumbnail.storage_path]);
    
    if (!error) deletedCount++;
  }
  
  return new Response(
    JSON.stringify({ deletedCount }),
    { headers: { 'Content-Type': 'application/json' } }
  );
});
```

### 7.2 Cost Monitoring

```typescript
// supabase/functions/daily-cost-check/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );
  
  // Get storage usage
  const { data: buckets } = await supabase.storage.listBuckets();
  let totalStorage = 0;
  for (const bucket of buckets || []) {
    // Calculate bucket size (implementation depends on Supabase API)
    totalStorage += bucket.file_size_limit || 0;
  }
  
  // Get database size
  const { data: dbSize } = await supabase.rpc('pg_database_size', {
    database_name: 'postgres',
  });
  
  // Calculate estimated costs
  const storageCost = (totalStorage / 1024 / 1024 / 1024) * 0.021; // $0.021/GB
  const dbCost = (dbSize / 1024 / 1024 / 1024) * 0.125; // $0.125/GB
  
  const totalCost = storageCost + dbCost;
  
  // Alert if exceeding budget
  const monthlyBudget = parseFloat(Deno.env.get('MONTHLY_BUDGET') || '300');
  if (totalCost > monthlyBudget * 0.8) {
    // Send alert (integrate with your alerting service)
    await sendCostAlert({
      currentCost: totalCost,
      budget: monthlyBudget,
      percentage: (totalCost / monthlyBudget * 100).toFixed(1),
    });
  }
  
  return new Response(
    JSON.stringify({ 
      totalCost,
      storageCost,
      dbCost,
      totalStorage,
      dbSize,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );
});
```

---

## 8. Testing and Validation

### 8.1 Performance Testing

```dart
// test/performance/photo_upload_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Photo Upload Performance', () {
    testWidgets('upload completes in < 5 seconds', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Navigate to upload screen
      await tester.tap(find.byIcon(Icons.add_photo));
      await tester.pumpAndSettle();
      
      // Measure upload time
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify upload completed in < 5 seconds
      expect(stopwatch.elapsed.inSeconds, lessThan(5));
    });
  });
}
```

### 8.2 Load Testing

```bash
# Use artillery for API load testing
npm install -g artillery

# Create load test config
cat > load-test.yml <<EOF
config:
  target: "YOUR_SUPABASE_URL"
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 300
      arrivalRate: 100
      name: "Sustained load (100 req/s)"
    - duration: 60
      arrivalRate: 200
      name: "Peak load (200 req/s)"

scenarios:
  - name: "Get baby profile"
    flow:
      - get:
          url: "/rest/v1/baby_profiles?id=eq.test-profile"
          headers:
            apikey: "YOUR_ANON_KEY"
          capture:
            - json: "$[0].id"
              as: "profileId"
      - get:
          url: "/rest/v1/photos?baby_profile_id=eq.{{ profileId }}"
          headers:
            apikey: "YOUR_ANON_KEY"
EOF

# Run load test
artillery run load-test.yml
```

### 8.3 Monitoring Validation

Create a monitoring dashboard checklist:

```markdown
## Pre-Production Monitoring Checklist

- [ ] Sentry configured and receiving events
- [ ] Error rate alerts configured (<1%)
- [ ] Performance monitoring enabled
- [ ] Database monitoring dashboard active
- [ ] Slow query alerts configured (>100ms)
- [ ] Connection pool monitoring active
- [ ] Storage usage tracking enabled
- [ ] Cost monitoring alerts configured
- [ ] Real-time connection monitoring active
- [ ] All critical alerts tested
```

---

## Conclusion

This implementation guide provides step-by-step instructions for implementing the sustainability and scalability strategies outlined in the main plan. Follow the phases in order, starting with database optimization and monitoring, then moving to storage and performance optimization.

**Next Steps:**
1. Complete Phase 1 (Foundation) in months 1-2
2. Implement Phase 2 (Optimization) in months 3-4
3. Prepare Phase 3 (Scaling) in months 5-6
4. Continuously monitor and optimize

**Remember:**
- Test each change thoroughly before deploying
- Monitor performance impact of optimizations
- Document any deviations from this guide
- Review and update this guide quarterly

---

**Document Version:** 1.0  
**Last Updated:** December 2025  
**Maintained by:** Nonna App Team
