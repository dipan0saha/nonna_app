import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Utility class for image compression and resizing operations.
///
/// Provides methods for processing images including compression,
/// resizing, format conversion, and quality optimization.
class ImageUtils {
  ImageUtils._(); // Private constructor to prevent instantiation

  /// Default compression quality (0-100)
  static const int defaultQuality = 85;

  /// Default maximum image dimension
  static const int defaultMaxDimension = 1920;

  /// Compresses an image file and returns the compressed bytes.
  ///
  /// [imageFile] - The image file to compress
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the compressed image as bytes.
  /// Throws [Exception] if the image cannot be read or processed.
  static Future<Uint8List> compressImage(
    File imageFile, {
    int quality = defaultQuality,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await compressImageBytes(bytes, quality: quality);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Compresses image bytes and returns the compressed bytes.
  ///
  /// [imageBytes] - The image bytes to compress
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the compressed image as bytes.
  /// Throws [Exception] if the image cannot be decoded or processed.
  static Future<Uint8List> compressImageBytes(
    Uint8List imageBytes, {
    int quality = defaultQuality,
  }) async {
    return compute(_compressImageBytesIsolate, {
      'bytes': imageBytes,
      'quality': quality,
    });
  }

  /// Isolate function for compressing image bytes.
  static Uint8List _compressImageBytesIsolate(Map<String, dynamic> params) {
    final imageBytes = params['bytes'] as Uint8List;
    final quality = params['quality'] as int;

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final compressedBytes = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(compressedBytes);
  }

  /// Resizes an image file to fit within the specified dimensions while maintaining aspect ratio.
  ///
  /// [imageFile] - The image file to resize
  /// [maxWidth] - Maximum width in pixels
  /// [maxHeight] - Maximum height in pixels
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the resized and compressed image as bytes.
  /// Throws [Exception] if the image cannot be read or processed.
  static Future<Uint8List> resizeImage(
    File imageFile, {
    required int maxWidth,
    required int maxHeight,
    int quality = defaultQuality,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await resizeImageBytes(
        bytes,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );
    } catch (e) {
      throw Exception('Failed to resize image: $e');
    }
  }

  /// Resizes image bytes to fit within the specified dimensions while maintaining aspect ratio.
  ///
  /// [imageBytes] - The image bytes to resize
  /// [maxWidth] - Maximum width in pixels
  /// [maxHeight] - Maximum height in pixels
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the resized and compressed image as bytes.
  /// Throws [Exception] if the image cannot be decoded or processed.
  static Future<Uint8List> resizeImageBytes(
    Uint8List imageBytes, {
    required int maxWidth,
    required int maxHeight,
    int quality = defaultQuality,
  }) async {
    return compute(_resizeImageBytesIsolate, {
      'bytes': imageBytes,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'quality': quality,
    });
  }

  /// Isolate function for resizing image bytes.
  static Uint8List _resizeImageBytesIsolate(Map<String, dynamic> params) {
    final imageBytes = params['bytes'] as Uint8List;
    final maxWidth = params['maxWidth'] as int;
    final maxHeight = params['maxHeight'] as int;
    final quality = params['quality'] as int;

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final resized = img.copyResize(
      image,
      width: maxWidth,
      height: maxHeight,
      maintainAspect: true,
    );

    final compressedBytes = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressedBytes);
  }

  /// Resizes an image to a square thumbnail.
  ///
  /// [imageFile] - The image file to process
  /// [size] - The dimension of the square thumbnail
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the thumbnail image as bytes.
  /// Throws [Exception] if the image cannot be read or processed.
  static Future<Uint8List> createThumbnail(
    File imageFile, {
    required int size,
    int quality = defaultQuality,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await createThumbnailFromBytes(
        bytes,
        size: size,
        quality: quality,
      );
    } catch (e) {
      throw Exception('Failed to create thumbnail: $e');
    }
  }

  /// Creates a square thumbnail from image bytes.
  ///
  /// [imageBytes] - The image bytes to process
  /// [size] - The dimension of the square thumbnail
  /// [quality] - Compression quality (0-100), defaults to 85
  ///
  /// Returns the thumbnail image as bytes.
  /// Throws [Exception] if the image cannot be decoded or processed.
  static Future<Uint8List> createThumbnailFromBytes(
    Uint8List imageBytes, {
    required int size,
    int quality = defaultQuality,
  }) async {
    return compute(_createThumbnailIsolate, {
      'bytes': imageBytes,
      'size': size,
      'quality': quality,
    });
  }

  /// Isolate function for creating thumbnails.
  static Uint8List _createThumbnailIsolate(Map<String, dynamic> params) {
    final imageBytes = params['bytes'] as Uint8List;
    final size = params['size'] as int;
    final quality = params['quality'] as int;

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Crop to square from center
    final minDimension = image.width < image.height ? image.width : image.height;
    final xOffset = (image.width - minDimension) ~/ 2;
    final yOffset = (image.height - minDimension) ~/ 2;

    final cropped = img.copyCrop(
      image,
      x: xOffset,
      y: yOffset,
      width: minDimension,
      height: minDimension,
    );

    final resized = img.copyResize(cropped, width: size, height: size);

    final compressedBytes = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(compressedBytes);
  }

  /// Converts an image to a different format.
  ///
  /// [imageBytes] - The image bytes to convert
  /// [format] - The target format ('jpg', 'png', 'webp')
  /// [quality] - Compression quality (0-100), only applies to jpg and webp
  ///
  /// Returns the converted image as bytes.
  /// Throws [Exception] if the format is unsupported or conversion fails.
  static Future<Uint8List> convertFormat(
    Uint8List imageBytes, {
    required String format,
    int quality = defaultQuality,
  }) async {
    return compute(_convertFormatIsolate, {
      'bytes': imageBytes,
      'format': format.toLowerCase(),
      'quality': quality,
    });
  }

  /// Isolate function for converting image format.
  static Uint8List _convertFormatIsolate(Map<String, dynamic> params) {
    final imageBytes = params['bytes'] as Uint8List;
    final format = params['format'] as String;
    final quality = params['quality'] as int;

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    List<int> encodedBytes;
    switch (format) {
      case 'jpg':
      case 'jpeg':
        encodedBytes = img.encodeJpg(image, quality: quality);
        break;
      case 'png':
        encodedBytes = img.encodePng(image);
        break;
      case 'webp':
        encodedBytes = img.encodeJpg(image, quality: quality);
        break;
      default:
        throw Exception('Unsupported format: $format');
    }

    return Uint8List.fromList(encodedBytes);
  }

  /// Gets the dimensions of an image without loading it fully into memory.
  ///
  /// [imageFile] - The image file to analyze
  ///
  /// Returns a map with 'width' and 'height' keys.
  /// Throws [Exception] if the image cannot be read or decoded.
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await getImageDimensionsFromBytes(bytes);
    } catch (e) {
      throw Exception('Failed to get image dimensions: $e');
    }
  }

  /// Gets the dimensions of an image from bytes.
  ///
  /// [imageBytes] - The image bytes to analyze
  ///
  /// Returns a map with 'width' and 'height' keys.
  /// Throws [Exception] if the image cannot be decoded.
  static Future<Map<String, int>> getImageDimensionsFromBytes(
    Uint8List imageBytes,
  ) async {
    return compute(_getImageDimensionsIsolate, imageBytes);
  }

  /// Isolate function for getting image dimensions.
  static Map<String, int> _getImageDimensionsIsolate(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    return {
      'width': image.width,
      'height': image.height,
    };
  }

  /// Validates if a file is a supported image format.
  ///
  /// [imageFile] - The file to validate
  ///
  /// Returns true if the file is a valid image, false otherwise.
  static Future<bool> isValidImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }

  /// Calculates the file size reduction percentage after compression.
  ///
  /// [originalSize] - Original file size in bytes
  /// [compressedSize] - Compressed file size in bytes
  ///
  /// Returns the reduction percentage (0-100).
  static double calculateCompressionRatio(int originalSize, int compressedSize) {
    if (originalSize == 0) return 0.0;
    return ((originalSize - compressedSize) / originalSize) * 100;
  }

  /// Rotates an image by the specified angle.
  ///
  /// [imageBytes] - The image bytes to rotate
  /// [angle] - The rotation angle in degrees (90, 180, or 270)
  ///
  /// Returns the rotated image as bytes.
  /// Throws [Exception] if the angle is invalid or rotation fails.
  static Future<Uint8List> rotateImage(
    Uint8List imageBytes, {
    required int angle,
  }) async {
    if (angle != 90 && angle != 180 && angle != 270) {
      throw Exception('Invalid rotation angle. Use 90, 180, or 270 degrees.');
    }

    return compute(_rotateImageIsolate, {
      'bytes': imageBytes,
      'angle': angle,
    });
  }

  /// Isolate function for rotating images.
  static Uint8List _rotateImageIsolate(Map<String, dynamic> params) {
    final imageBytes = params['bytes'] as Uint8List;
    final angle = params['angle'] as int;

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    img.Image rotated;
    switch (angle) {
      case 90:
        rotated = img.copyRotate(image, angle: 90);
        break;
      case 180:
        rotated = img.copyRotate(image, angle: 180);
        break;
      case 270:
        rotated = img.copyRotate(image, angle: 270);
        break;
      default:
        throw Exception('Invalid rotation angle');
    }

    final encodedBytes = img.encodeJpg(rotated, quality: defaultQuality);
    return Uint8List.fromList(encodedBytes);
  }
}
