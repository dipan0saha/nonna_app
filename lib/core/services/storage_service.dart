import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'analytics_service.dart';

/// Storage service for managing file uploads/downloads
/// Handles photo compression, upload to Supabase Storage, and URL generation
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

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
      debugPrint('Error picking image from gallery: $e');
      rethrow;
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
      debugPrint('Error picking image from camera: $e');
      rethrow;
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
      await _supabase.storage
          .from('gallery-photos')
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Log analytics event
      await AnalyticsService.logPhotoUploaded(
        babyProfileId: babyProfileId,
        hasCaption: caption != null && caption.isNotEmpty,
        hasTags: tags != null && tags.isNotEmpty,
        fileSizeKb: fileSizeKb,
      );

      return storagePath;
    } catch (e) {
      debugPrint('Error uploading gallery photo: $e');
      rethrow;
    }
  }

  /// Upload user avatar
  Future<String> uploadUserAvatar({
    required File imageFile,
    required String userId,
  }) async {
    try {
      _validateImageFile(imageFile);

      final imageBytes = await imageFile.readAsBytes();
      final fileName = '${const Uuid().v4()}.jpg';
      final storagePath = 'user_$userId/$fileName';

      await _supabase.storage
          .from('user-avatars')
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      return storagePath;
    } catch (e) {
      debugPrint('Error uploading user avatar: $e');
      rethrow;
    }
  }

  /// Upload baby profile photo
  Future<String> uploadBabyProfilePhoto({
    required File imageFile,
    required String babyProfileId,
  }) async {
    try {
      _validateImageFile(imageFile);

      final imageBytes = await imageFile.readAsBytes();
      final fileName = '${const Uuid().v4()}.jpg';
      final storagePath = 'baby_$babyProfileId/$fileName';

      await _supabase.storage
          .from('baby-profile-photos')
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      return storagePath;
    } catch (e) {
      debugPrint('Error uploading baby profile photo: $e');
      rethrow;
    }
  }

  /// Upload event cover photo
  Future<String> uploadEventPhoto({
    required File imageFile,
    required String babyProfileId,
  }) async {
    try {
      _validateImageFile(imageFile);

      final imageBytes = await imageFile.readAsBytes();
      final fileName = '${const Uuid().v4()}.jpg';
      final storagePath = 'baby_$babyProfileId/$fileName';

      await _supabase.storage
          .from('event-photos')
          .uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      return storagePath;
    } catch (e) {
      debugPrint('Error uploading event photo: $e');
      rethrow;
    }
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

  // ==========================================
  // Validation
  // ==========================================

  /// Validate image file
  void _validateImageFile(File file) {
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
  }
}
