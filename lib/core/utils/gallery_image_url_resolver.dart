import 'package:nonna_app/core/services/storage_service.dart';

/// Resolves gallery storage paths into displayable URLs.
///
/// Handles legacy and current path formats, including values that already
/// contain the bucket prefix (e.g. `gallery-photos/<path>`).
class GalleryImageUrlResolver {
  GalleryImageUrlResolver._();

  static const String galleryBucket = 'gallery-photos';

  static Future<String> resolve({
    required StorageService storageService,
    required String pathOrUrl,
  }) async {
    if (_isAbsoluteUrl(pathOrUrl)) {
      return pathOrUrl;
    }

    final normalizedPath = normalizePath(pathOrUrl);
    if (normalizedPath.isEmpty) {
      return pathOrUrl;
    }

    try {
      return await storageService.getSignedUrl(galleryBucket, normalizedPath);
    } catch (_) {
      try {
        return storageService.getPublicUrl(galleryBucket, normalizedPath);
      } catch (_) {
        return pathOrUrl;
      }
    }
  }

  static String normalizePath(String rawPath) {
    var path = rawPath.trim();
    if (path.isEmpty) return path;

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    const bucketPrefix = '$galleryBucket/';
    if (path.startsWith(bucketPrefix)) {
      return path.substring(bucketPrefix.length);
    }

    final bucketIndex = path.indexOf('/$bucketPrefix');
    if (bucketIndex >= 0) {
      return path.substring(bucketIndex + bucketPrefix.length + 1);
    }

    return path;
  }

  static bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('data:');
  }
}
