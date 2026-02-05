import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image manipulation helpers
///
/// **Functional Requirements**: Section 3.3.4 - Image Helpers
/// Reference: docs/Core_development_component_identification.md
///
/// Provides utilities for image processing and manipulation including:
/// - File size validation (isValidSize, getFileSizeMB, formatFileSize)
/// - Format validation (isValidImageFormat, getImageFormat)
/// - Image compression (compressImage, compressToSize)
/// - Thumbnail generation (generateThumbnail, generateSquareThumbnail)
/// - Format conversion (convertToJpeg, convertToPng)
/// - Aspect ratio calculations (calculateAspectRatio, calculateDimensions)
/// - Cropping utilities (cropImage, cropToSquare)
///
/// Dependencies: image package
class ImageHelpers {
  // Prevent instantiation
  ImageHelpers._();

  // ============================================================
  // File Size Validation
  // ============================================================

  /// Validate image file size
  static bool isValidSize(File file, int maxSizeBytes) {
    return file.lengthSync() <= maxSizeBytes;
  }

  /// Get file size in megabytes
  static double getFileSizeMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ============================================================
  // Format Validation
  // ============================================================

  /// Check if file is a valid image format
  static bool isValidImageFormat(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Get image format from path
  static String? getImageFormat(String path) {
    final ext = path.toLowerCase().split('.').last;
    return isValidImageFormat(path) ? ext : null;
  }

  // ============================================================
  // Image Compression
  // ============================================================

  /// Compress image to target size
  static Future<Uint8List?> compressImage(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // Read image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Resize if dimensions are specified
      img.Image resized = image;
      if (maxWidth != null || maxHeight != null) {
        resized = _resizeImage(image, maxWidth: maxWidth, maxHeight: maxHeight);
      }

      // Encode with compression
      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    } catch (e) {
      return null;
    }
  }

  /// Compress image to target file size (approximate)
  static Future<Uint8List?> compressToSize(
    File imageFile, {
    required int targetSizeBytes,
    int maxIterations = 5,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      int quality = 90;
      Uint8List? result;

      for (int i = 0; i < maxIterations; i++) {
        result = Uint8List.fromList(img.encodeJpg(image, quality: quality));

        if (result.length <= targetSizeBytes || quality <= 10) {
          break;
        }

        // Reduce quality for next iteration
        quality = (quality * 0.8).round();
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Thumbnail Generation
  // ============================================================

  /// Generate thumbnail from image file
  static Future<Uint8List?> generateThumbnail(
    File imageFile, {
    int width = 300,
    int height = 300,
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Create thumbnail with aspect ratio maintained
      final thumbnail = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: quality));
    } catch (e) {
      return null;
    }
  }

  /// Generate square thumbnail (cropped)
  static Future<Uint8List?> generateSquareThumbnail(
    File imageFile, {
    int size = 300,
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Crop to square from center
      final squareImage = _cropToSquare(image);

      // Resize to target size
      final thumbnail = img.copyResize(
        squareImage,
        width: size,
        height: size,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: quality));
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Format Conversion
  // ============================================================

  /// Convert image to JPEG
  static Future<Uint8List?> convertToJpeg(
    File imageFile, {
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      return null;
    }
  }

  /// Convert image to PNG
  static Future<Uint8List?> convertToPng(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Aspect Ratio Calculations
  // ============================================================

  /// Calculate aspect ratio
  static double calculateAspectRatio(int width, int height) {
    if (height == 0) {
      throw ArgumentError('Height cannot be zero');
    }
    return width / height;
  }

  /// Calculate dimensions maintaining aspect ratio
  static ({int width, int height}) calculateDimensions({
    required int originalWidth,
    required int originalHeight,
    int? targetWidth,
    int? targetHeight,
  }) {
    final aspectRatio = calculateAspectRatio(originalWidth, originalHeight);

    if (targetWidth != null && targetHeight != null) {
      return (width: targetWidth, height: targetHeight);
    } else if (targetWidth != null) {
      return (
        width: targetWidth,
        height: (targetWidth / aspectRatio).round(),
      );
    } else if (targetHeight != null) {
      return (
        width: (targetHeight * aspectRatio).round(),
        height: targetHeight,
      );
    } else {
      return (width: originalWidth, height: originalHeight);
    }
  }

  /// Check if image is landscape
  static bool isLandscape(int width, int height) {
    return width > height;
  }

  /// Check if image is portrait
  static bool isPortrait(int width, int height) {
    return height > width;
  }

  /// Check if image is square
  static bool isSquare(int width, int height) {
    return width == height;
  }

  // ============================================================
  // Cropping Utilities
  // ============================================================

  /// Crop image to specified dimensions
  static Future<Uint8List?> cropImage(
    File imageFile, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      final cropped =
          img.copyCrop(image, x: x, y: y, width: width, height: height);

      return Uint8List.fromList(img.encodeJpg(cropped));
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Image Metadata
  // ============================================================

  /// Get image dimensions
  static Future<({int width, int height})?> getImageDimensions(
      File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return (width: image.width, height: image.height);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Resize image maintaining aspect ratio
  static img.Image _resizeImage(
    img.Image image, {
    int? maxWidth,
    int? maxHeight,
  }) {
    if (maxWidth == null && maxHeight == null) return image;

    final aspectRatio = image.width / image.height;

    int targetWidth = image.width;
    int targetHeight = image.height;

    if (maxWidth != null && image.width > maxWidth) {
      targetWidth = maxWidth;
      targetHeight = (maxWidth / aspectRatio).round();
    }

    if (maxHeight != null && targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = (maxHeight * aspectRatio).round();
    }

    return img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Crop image to square from center
  static img.Image _cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;

    return img.copyCrop(image, x: x, y: y, width: size, height: size);
  }
}
