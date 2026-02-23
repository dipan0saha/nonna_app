import 'package:nonna_app/core/models/photo.dart';

/// A [Photo] paired with its squish (like) count.
///
/// Used by [RecentPhotosTile] to display thumbnails alongside engagement
/// counts without coupling the widget to any provider.
class PhotoWithSquishCount {
  final Photo photo;

  /// Total number of squishes this photo has received.
  final int squishCount;

  /// Whether the current user has squished this photo.
  final bool isSquished;

  const PhotoWithSquishCount({
    required this.photo,
    this.squishCount = 0,
    this.isSquished = false,
  });
}
