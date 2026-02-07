import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../constants/performance_limits.dart';
import '../middleware/error_handler.dart';
import '../network/interceptors/auth_interceptor.dart';
import 'analytics_service.dart';

/// Storage service for managing file uploads/downloads
/// Handles photo compression, upload to Supabase Storage, and URL generation
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  late final AuthInterceptor _authInterceptor;

  StorageService() {
    _authInterceptor = AuthInterceptor(_supabase);
  }

  // ==========================================
  // Image Picking
  // ==========================================

  /// Pick and compress image from gallery
  Future<File?> pickImageFromGallery({
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      return await _compressImage(
        File(image.path),
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error picking image from gallery: $message');
      throw Exception(message);
    }
  }

  /// Pick and compress image from camera
  Future<File?> pickImageFromCamera({
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      return await _compressImage(
        File(image.path),
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } catch (e) {
      final message = ErrorHandler.mapErrorToMessage(e);
      debugPrint('❌ Error picking image from camera: $message');
      throw Exception(message);
    }
  }

  // ==========================================
  // Image Compression
  // ==========================================

  /// Compress image file
  Future<File> _compressImage(
    File file, {
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) return file;

      // Save compressed image to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/${const Uuid().v4()}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  /// Compress image bytes
  Future<Uint8List?> compressImageBytes(
    Uint8List imageBytes, {
    int quality = 70,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
    } catch (e) {
      debugPrint('Error compressing image bytes: $e');
      return null;
    }
  }

  // ==========================================
  // File Upload
  // ==========================================

  /// Upload photo to gallery bucket
  Future<String> uploadGalleryPhoto({
    required File imageFile,
    required String babyProfileId,
    String? caption,
    List<String>? tags,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        // Validate file
        _validateImageFile(imageFile);

        // Read image bytes
        final imageBytes = await imageFile.readAsBytes();
        final fileSizeKb = (imageBytes.length / 1024).round();

        // Generate unique file name
        final fileName = '${const Uuid().v4()}.jpg';
        final storagePath = 'baby_$babyProfileId/$fileName';

        // Upload to Supabase Storage
        await _supabase.storage.from('gallery-photos').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        // Log analytics event
        await AnalyticsService.instance.logPhotoUploaded(
          babyProfileId: babyProfileId,
          hasCaption: caption != null && caption.isNotEmpty,
          hasTags: tags != null && tags.isNotEmpty,
          fileSizeKb: fileSizeKb,
        );

        return storagePath;
      } catch (e) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error uploading gallery photo: $message');
        throw Exception(message);
      }
    });
  }

  /// Upload user avatar
  Future<String> uploadUserAvatar({
    required File imageFile,
    required String userId,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        _validateImageFile(imageFile);

        final imageBytes = await imageFile.readAsBytes();
        final fileName = '${const Uuid().v4()}.jpg';
        final storagePath = 'user_$userId/$fileName';

        await _supabase.storage.from('user-avatars').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        return storagePath;
      } catch (e) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error uploading user avatar: $message');
        throw Exception(message);
      }
    });
  }

  /// Upload baby profile photo
  Future<String> uploadBabyProfilePhoto({
    required File imageFile,
    required String babyProfileId,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        _validateImageFile(imageFile);

        final imageBytes = await imageFile.readAsBytes();
        final fileName = '${const Uuid().v4()}.jpg';
        final storagePath = 'baby_$babyProfileId/$fileName';

        await _supabase.storage.from('baby-profile-photos').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        return storagePath;
      } catch (e) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error uploading baby profile photo: $message');
        throw Exception(message);
      }
    });
  }

  /// Upload event cover photo
  Future<String> uploadEventPhoto({
    required File imageFile,
    required String babyProfileId,
  }) async {
    return await _authInterceptor.executeWithRetry(() async {
      try {
        _validateImageFile(imageFile);

        final imageBytes = await imageFile.readAsBytes();
        final fileName = '${const Uuid().v4()}.jpg';
        final storagePath = 'baby_$babyProfileId/$fileName';

        await _supabase.storage.from('event-photos').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        return storagePath;
      } catch (e) {
        final message = ErrorHandler.mapErrorToMessage(e);
        debugPrint('❌ Error uploading event photo: $message');
        throw Exception(message);
      }
    });
  }

  // ==========================================
  // File Download / URL Generation
  // ==========================================

  /// Get public URL for file
  String getPublicUrl(String bucketName, String path) {
    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  /// Get signed URL for private file (expires in 1 hour)
  Future<String> getSignedUrl(String bucketName, String path) async {
    try {
      return await _supabase.storage
          .from(bucketName)
          .createSignedUrl(path, 3600); // 3600 seconds = 1 hour
    } catch (e) {
      debugPrint('Error getting signed URL: $e');
      rethrow;
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedImageUrl({
    required String bucketName,
    required String path,
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'webp',
  }) {
    final baseUrl = getPublicUrl(bucketName, path);
    final transformParams = <String>[];

    if (width != null) transformParams.add('width=$width');
    if (height != null) transformParams.add('height=$height');
    transformParams.add('quality=$quality');
    transformParams.add('format=$format');

    return '$baseUrl?${transformParams.join('&')}';
  }

  // ==========================================
  // File Deletion
  // ==========================================

  /// Delete file from storage
  Future<void> deleteFile(String bucketName, String path) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete multiple files from storage
  Future<void> deleteFiles(String bucketName, List<String> paths) async {
    try {
      await _supabase.storage.from(bucketName).remove(paths);
    } catch (e) {
      debugPrint('Error deleting files: $e');
      rethrow;
    }
  }

  // ==========================================
  // Batch Operations
  // ==========================================

  /// Upload multiple photos in batch
  Future<List<String>> batchUploadPhotos({
    required List<File> imageFiles,
    required String babyProfileId,
    List<String>? captions,
    List<List<String>>? tags,
  }) async {
    final uploadedPaths = <String>[];

    for (var i = 0; i < imageFiles.length; i++) {
      try {
        final String? captionForImage =
            (captions != null && i < captions.length) ? captions[i] : null;
        final List<String>? tagsForImage =
            (tags != null && i < tags.length) ? tags[i] : null;

        final path = await uploadGalleryPhoto(
          imageFile: imageFiles[i],
          babyProfileId: babyProfileId,
          caption: captionForImage,
          tags: tagsForImage,
        );
        uploadedPaths.add(path);
      } catch (e) {
        debugPrint('Error uploading photo $i: $e');
        // Continue with next photo even if one fails
      }
    }

    return uploadedPaths;
  }

  // ==========================================
  // Thumbnail Generation
  // ==========================================

  /// Generate thumbnail for image
  Future<File> generateThumbnail(
    File imageFile, {
    int maxWidth = PerformanceLimits.thumbnailMaxWidth,
    int maxHeight = PerformanceLimits.thumbnailMaxHeight,
    int quality = PerformanceLimits.thumbnailCompressionQuality,
  }) async {
    try {
      return await _compressImage(
        imageFile,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      rethrow;
    }
  }

  /// Upload photo with thumbnail
  Future<Map<String, String>> uploadPhotoWithThumbnail({
    required File imageFile,
    required String babyProfileId,
    String? caption,
    List<String>? tags,
  }) async {
    try {
      // Upload main photo
      final photoPath = await uploadGalleryPhoto(
        imageFile: imageFile,
        babyProfileId: babyProfileId,
        caption: caption,
        tags: tags,
      );

      // Generate and upload thumbnail
      final thumbnail = await generateThumbnail(imageFile);
      final thumbnailBytes = await thumbnail.readAsBytes();
      final thumbnailFileName = '${const Uuid().v4()}_thumb.jpg';
      final thumbnailPath = 'baby_$babyProfileId/$thumbnailFileName';

      await _supabase.storage.from('gallery-photos').uploadBinary(
            thumbnailPath,
            thumbnailBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      return {
        'photo_path': photoPath,
        'thumbnail_path': thumbnailPath,
      };
    } catch (e) {
      debugPrint('Error uploading photo with thumbnail: $e');
      rethrow;
    }
  }

  // ==========================================
  // Storage Quota Management
  // ==========================================

  /// Get storage usage for a baby profile
  Future<int> getStorageUsage(String babyProfileId) async {
    try {
      final files = await _supabase.storage
          .from('gallery-photos')
          .list(path: 'baby_$babyProfileId');

      int totalSize = 0;
      for (final file in files) {
        totalSize += file.metadata?['size'] as int? ?? 0;
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting storage usage: $e');
      return 0;
    }
  }

  /// Check if storage quota is available
  Future<bool> hasStorageQuota(
    String babyProfileId, {
    int maxStorageMb = PerformanceLimits.maxStoragePerUserMb,
  }) async {
    try {
      final usageBytes = await getStorageUsage(babyProfileId);
      final usageMb = usageBytes / (1024 * 1024);

      return usageMb < maxStorageMb;
    } catch (e) {
      debugPrint('Error checking storage quota: $e');
      return true; // Allow upload if quota check fails
    }
  }

  // ==========================================
  // Validation
  // ==========================================

  /// Validate image file
  void _validateImageFile(File file) {
    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > PerformanceLimits.maxImageSizeBytes) {
      throw Exception('File size exceeds ${PerformanceLimits.maxImageSizeBytes ~/ (1024 * 1024)}MB limit');
    }

    // Check file extension
    final extension = path.extension(file.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
      throw Exception('Only JPEG and PNG files are allowed');
    }
  }
}
