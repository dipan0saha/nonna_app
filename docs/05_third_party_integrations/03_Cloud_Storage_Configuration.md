# Cloud Storage Configuration

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Configuration Guide  
**Section**: 2.3 - Third-Party Integrations Setup

## Executive Summary

This document provides comprehensive guidance for setting up and configuring Supabase Storage for the Nonna App. Supabase Storage provides S3-compatible object storage with CDN delivery, image transformations, and Row-Level Security (RLS) integration. This guide covers bucket creation, access policies, photo upload/download flows, CDN optimization, and security best practices.

## References

This document is informed by:

- `docs/01_technical_requirements/api_integration_plan.md` - Storage integration strategy (Section 1.3)
- `docs/02_architecture_design/security_privacy_architecture.md` - Storage security requirements (Section 6.3)
- `docs/05_third_party_integrations/01_Supabase_Project_Configuration.md` - Supabase project setup
- `docs/Production_Readiness_Checklist.md` - Section 2.3 requirements

---

## 1. Supabase Storage Overview

### 1.1 Storage Architecture

**Supabase Storage Features**:

- **S3-Compatible**: Built on AWS S3 with standard S3 API
- **CDN Delivery**: Automatic CDN distribution for fast file access
- **Image Transformations**: On-the-fly image resizing, cropping, format conversion
- **Row-Level Security**: Access control integrated with PostgreSQL RLS
- **Resumable Uploads**: Support for large file uploads with resumption
- **Signed URLs**: Temporary access URLs for private files
- **Bucket Organization**: Organize files into buckets (containers)

**Storage Use Cases in Nonna App**:

1. **User Avatars**: Profile pictures for users
2. **Baby Profile Photos**: Profile pictures for baby profiles
3. **Gallery Photos**: Photo gallery images (main feature)
4. **Event Photos**: Cover images for events
5. **Thumbnails**: Auto-generated thumbnails for performance

### 1.2 Storage Quotas

**Free Tier**:
- 1 GB storage
- 2 GB bandwidth per month
- 50MB max file size

**Pro Tier ($25/month)**:
- 100 GB storage
- 200 GB bandwidth per month
- 50MB max file size (configurable)

**Recommendation for Nonna App**:
- Start with Free tier for MVP (< 1000 users)
- Upgrade to Pro when approaching limits
- Implement image compression to maximize quota usage

---

## 2. Bucket Setup

### 2.1 Create Storage Buckets

Navigate to Supabase Dashboard → Storage and create the following buckets:

#### Bucket 1: `user-avatars` (Public)

**Configuration**:
- **Public**: Yes (files accessible without authentication)
- **File size limit**: 5MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`
- **Purpose**: User profile photos

**Create Bucket**:
```sql
-- Via SQL Editor
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'user-avatars',
  'user-avatars',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/webp']
);
```

#### Bucket 2: `baby-profile-photos` (Public)

**Configuration**:
- **Public**: Yes
- **File size limit**: 5MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`
- **Purpose**: Baby profile pictures

#### Bucket 3: `gallery-photos` (Private with RLS)

**Configuration**:
- **Public**: No (RLS-protected, accessible only to followers)
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg`, `image/png`
- **Purpose**: Photo gallery images

#### Bucket 4: `event-photos` (Private with RLS)

**Configuration**:
- **Public**: No (RLS-protected)
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg`, `image/png`
- **Purpose**: Event cover images

### 2.2 Storage Policies (RLS)

**Enable RLS on Storage**:

```sql
-- Enable RLS on storage.objects table
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

#### Policy for `gallery-photos` Bucket

**Policy 1: Owners can upload photos**

```sql
CREATE POLICY "Owners can upload gallery photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'gallery-photos'
  AND EXISTS (
    SELECT 1 FROM public.photos p
    INNER JOIN public.baby_memberships bm
      ON bm.baby_profile_id = p.baby_profile_id
    WHERE bm.user_id = auth.uid()
      AND bm.role = 'owner'
      AND bm.removed_at IS NULL
      AND p.storage_path = name
  )
);
```

**Policy 2: Followers can view photos**

```sql
CREATE POLICY "Followers can view gallery photos"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'gallery-photos'
  AND EXISTS (
    SELECT 1 FROM public.photos p
    INNER JOIN public.baby_memberships bm
      ON bm.baby_profile_id = p.baby_profile_id
    WHERE bm.user_id = auth.uid()
      AND bm.removed_at IS NULL
      AND p.storage_path = name
  )
);
```

**Policy 3: Owners can delete photos**

```sql
CREATE POLICY "Owners can delete gallery photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'gallery-photos'
  AND EXISTS (
    SELECT 1 FROM public.photos p
    INNER JOIN public.baby_memberships bm
      ON bm.baby_profile_id = p.baby_profile_id
    WHERE bm.user_id = auth.uid()
      AND bm.role = 'owner'
      AND bm.removed_at IS NULL
      AND p.storage_path = name
  )
);
```

---

## 3. Photo Upload Implementation

### 3.1 Client-Side Image Compression

**Install Dependencies**:

```yaml
# pubspec.yaml
dependencies:
  flutter_image_compress: ^2.0.0
  image_picker: ^1.0.0
```

**Compression Implementation**:

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickAndCompressImage({
    required ImageSource source,
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return null;

      // Compress image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedImage == null) return image;

      // Save compressed image to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedImage);

      return XFile(tempFile.path);
    } catch (e) {
      print('Error picking/compressing image: $e');
      return null;
    }
  }

  Future<Uint8List?> compressImageBytes(
    Uint8List imageBytes, {
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    return await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
    );
  }
}
```

### 3.2 Photo Upload Flow

**Complete Upload Flow** (photo gallery):

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PhotoUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImageService _imageService = ImageService();

  Future<String?> uploadPhotoToGallery({
    required String babyProfileId,
    required String caption,
    List<String> tags = const [],
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Step 1: Pick and compress image
      final compressedImage = await _imageService.pickAndCompressImage(
        source: source,
        quality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (compressedImage == null) {
        throw Exception('No image selected');
      }

      // Step 2: Read image bytes
      final imageBytes = await File(compressedImage.path).readAsBytes();

      // Step 3: Generate unique file name
      final fileName = '${Uuid().v4()}.jpg';
      final storagePath = 'baby_$babyProfileId/$fileName';

      // Step 4: Upload to Supabase Storage
      await _supabase.storage
          .from('gallery-photos')
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Step 5: Generate thumbnail via Edge Function (optional)
      String? thumbnailPath;
      try {
        final response = await _supabase.functions.invoke(
          'generate-thumbnail',
          body: {'storage_path': storagePath},
        );
        if (response.status == 200) {
          thumbnailPath = response.data['thumbnail_path'];
        }
      } catch (e) {
        print('Thumbnail generation failed: $e');
        // Continue without thumbnail
      }

      // Step 6: Create database entry
      final photoData = {
        'baby_profile_id': babyProfileId,
        'uploaded_by_user_id': _supabase.auth.currentUser!.id,
        'storage_path': storagePath,
        'thumbnail_path': thumbnailPath,
        'caption': caption.isNotEmpty ? caption : null,
        'tags': tags.isNotEmpty ? tags : null,
      };

      await _supabase.from('photos').insert(photoData);

      // Step 7: Return photo URL
      final photoUrl = _supabase.storage
          .from('gallery-photos')
          .getPublicUrl(storagePath);

      return photoUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }
}
```

### 3.3 Upload Progress Tracking

**Track Upload Progress**:

```dart
Future<void> uploadPhotoWithProgress({
  required String babyProfileId,
  required File imageFile,
  required Function(double progress) onProgress,
}) async {
  try {
    final imageBytes = await imageFile.readAsBytes();
    final fileName = '${Uuid().v4()}.jpg';
    final storagePath = 'baby_$babyProfileId/$fileName';

    // Use uploadBinary with progress callback (if supported)
    // Note: Supabase Flutter SDK may not directly support progress callbacks
    // Consider implementing chunked uploads for large files

    await _supabase.storage
        .from('gallery-photos')
        .uploadBinary(
          storagePath,
          imageBytes,
          fileOptions: FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    onProgress(1.0); // Upload complete
  } catch (e) {
    throw Exception('Upload failed: $e');
  }
}
```

---

## 4. Photo Download and Display

### 4.1 Get Public URLs

**For Public Buckets** (user-avatars, baby-profile-photos):

```dart
String getPublicUrl(String bucketName, String path) {
  return Supabase.instance.client.storage
      .from(bucketName)
      .getPublicUrl(path);
}

// Usage
final avatarUrl = getPublicUrl('user-avatars', 'user_123/avatar.jpg');
```

**For Private Buckets with RLS** (gallery-photos, event-photos):

```dart
Future<String> getPrivatePhotoUrl(String storagePath) async {
  // Create signed URL (temporary access, expires in 1 hour)
  final signedUrl = await Supabase.instance.client.storage
      .from('gallery-photos')
      .createSignedUrl(storagePath, 3600); // 3600 seconds = 1 hour

  return signedUrl;
}
```

### 4.2 Image Transformations (CDN)

**Resize and Optimize Images**:

```dart
String getOptimizedImageUrl({
  required String bucketName,
  required String path,
  int? width,
  int? height,
  String quality = 'auto',
  String format = 'webp',
}) {
  final baseUrl = Supabase.instance.client.storage
      .from(bucketName)
      .getPublicUrl(path);

  // Add transformation parameters
  final transformParams = <String>[];
  
  if (width != null) transformParams.add('width=$width');
  if (height != null) transformParams.add('height=$height');
  transformParams.add('quality=$quality');
  transformParams.add('format=$format');

  return '$baseUrl?${transformParams.join('&')}';
}

// Usage - Thumbnail
final thumbnailUrl = getOptimizedImageUrl(
  bucketName: 'gallery-photos',
  path: 'baby_123/photo.jpg',
  width: 300,
  height: 300,
  quality: '80',
  format: 'webp',
);

// Usage - Full size optimized
final fullSizeUrl = getOptimizedImageUrl(
  bucketName: 'gallery-photos',
  path: 'baby_123/photo.jpg',
  width: 1920,
  height: 1920,
  quality: 'auto',
  format: 'webp',
);
```

### 4.3 Cached Image Display

**Use cached_network_image Package**:

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
import 'package:cached_network_image/cached_network_image.dart';

Widget buildPhotoGalleryItem(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => Center(
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
    fit: BoxFit.cover,
    cacheManager: CacheManager(
      Config(
        'nonna_photo_cache',
        stalePeriod: Duration(days: 7), // Cache for 7 days
        maxNrOfCacheObjects: 200,
      ),
    ),
  );
}
```

---

## 5. Photo Deletion

### 5.1 Soft Delete (Recommended)

**Mark photo as deleted in database** (file remains in storage for retention period):

```dart
Future<void> softDeletePhoto(String photoId) async {
  await Supabase.instance.client
      .from('photos')
      .update({'deleted_at': DateTime.now().toIso8601String()})
      .eq('id', photoId);
}
```

### 5.2 Hard Delete (Permanent)

**Delete file from storage AND database**:

```dart
Future<void> hardDeletePhoto(String photoId) async {
  try {
    // Step 1: Get photo details
    final photoData = await Supabase.instance.client
        .from('photos')
        .select('storage_path, thumbnail_path')
        .eq('id', photoId)
        .single();

    final storagePath = photoData['storage_path'] as String;
    final thumbnailPath = photoData['thumbnail_path'] as String?;

    // Step 2: Delete from storage
    await Supabase.instance.client.storage
        .from('gallery-photos')
        .remove([storagePath]);

    // Step 3: Delete thumbnail if exists
    if (thumbnailPath != null) {
      await Supabase.instance.client.storage
          .from('gallery-photos')
          .remove([thumbnailPath]);
    }

    // Step 4: Delete from database
    await Supabase.instance.client
        .from('photos')
        .delete()
        .eq('id', photoId);
  } catch (e) {
    throw Exception('Failed to delete photo: $e');
  }
}
```

---

## 6. Security Best Practices

### 6.1 File Validation

**Client-Side Validation**:

```dart
bool validateImageFile(File file) {
  // Check file size (max 10MB)
  final fileSize = file.lengthSync();
  if (fileSize > 10 * 1024 * 1024) {
    throw Exception('File size exceeds 10MB limit');
  }

  // Check file extension
  final extension = path.extension(file.path).toLowerCase();
  if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
    throw Exception('Only JPEG and PNG files are allowed');
  }

  return true;
}
```

**Server-Side Validation** (Edge Function):

```typescript
// Edge Function: validate-upload
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  try {
    const { file_path, file_size, mime_type } = await req.json();

    // Validate file size
    if (file_size > 10 * 1024 * 1024) {
      return new Response(
        JSON.stringify({ error: 'File size exceeds 10MB limit' }),
        { status: 400 }
      );
    }

    // Validate MIME type
    const allowedTypes = ['image/jpeg', 'image/png'];
    if (!allowedTypes.includes(mime_type)) {
      return new Response(
        JSON.stringify({ error: 'Only JPEG and PNG files are allowed' }),
        { status: 400 }
      );
    }

    return new Response(JSON.stringify({ valid: true }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
```

### 6.2 Access Control

**Use RLS Policies** (see Section 2.2)

**Signed URLs for Private Files**:

```dart
// Generate temporary access URL (expires in 1 hour)
final signedUrl = await Supabase.instance.client.storage
    .from('gallery-photos')
    .createSignedUrl('photo.jpg', 3600);
```

### 6.3 CORS Configuration

**Configure CORS** (if needed for web app):

Navigate to Supabase Dashboard → Storage → Configuration:

```json
{
  "allowedOrigins": [
    "https://nonna.app",
    "https://www.nonna.app",
    "http://localhost:3000"
  ],
  "allowedHeaders": ["*"],
  "allowedMethods": ["GET", "POST", "PUT", "DELETE"]
}
```

---

## 7. Performance Optimization

### 7.1 Image Compression

**Target Compression Settings**:

- **Original photos**: 70% quality, max 1920x1920px → ~500KB-1MB
- **Thumbnails**: 80% quality, 300x300px → ~30-50KB
- **Profile pictures**: 85% quality, 500x500px → ~100-150KB

### 7.2 CDN Caching

**Leverage Supabase CDN**:

- Files automatically distributed via CDN
- Use image transformations for auto-caching
- Set appropriate cache headers

### 7.3 Lazy Loading

**Implement Lazy Loading**:

```dart
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Widget buildPhotoGrid(List<Photo> photos) {
  return MasonryGridView.count(
    crossAxisCount: 3,
    itemCount: photos.length,
    itemBuilder: (context, index) {
      return CachedNetworkImage(
        imageUrl: photos[index].thumbnailUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration(milliseconds: 200),
      );
    },
  );
}
```

---

## 8. Troubleshooting

### Common Issues

**Issue: "Upload failed: 413 Payload Too Large"**

Solutions:
- Compress image before upload
- Check file size limit in bucket settings
- Verify image is < 10MB

**Issue: "Access denied" when viewing photos**

Solutions:
- Verify user has active membership in baby_memberships
- Check RLS policies are correctly defined
- Verify storage_path in photos table matches actual file path
- Test policies with SQL Editor

**Issue: "Image not displaying"**

Solutions:
- Verify file exists in storage
- Check getPublicUrl() or createSignedUrl() returns valid URL
- Test URL in browser
- Check network connectivity
- Verify cached_network_image configuration

---

## Conclusion

This Cloud Storage Configuration guide provides comprehensive setup for Supabase Storage in the Nonna App, covering bucket creation, RLS policies, photo upload/download flows, CDN optimization, and security best practices. Following these guidelines ensures secure, performant, and scalable file storage.

**Next Steps**:

- Review `04_Database_Setup_Document.md` for database schema
- Review `05_Push_Notification_Configuration.md` for notifications
- Review `06_Analytics_Setup_Document.md` for analytics tracking

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Status**: Configuration Guide - Ready for Implementation
