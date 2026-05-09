import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/gallery_image_url_resolver.dart';

void main() {
  group('GalleryImageUrlResolver.normalizePath', () {
    test('returns plain storage path unchanged', () {
      const input = 'b9867ae8-500d-4f5c-bceb-4d467931d480/baby_abc/photo.jpg';

      expect(GalleryImageUrlResolver.normalizePath(input), input);
    });

    test('strips leading slash and bucket prefix', () {
      const input = '/gallery-photos/u123/baby_abc/photo.jpg';

      expect(
        GalleryImageUrlResolver.normalizePath(input),
        'u123/baby_abc/photo.jpg',
      );
    });

    test('extracts path from storage API style string', () {
      const input =
          'storage/v1/object/public/gallery-photos/u123/baby_abc/photo.jpg';

      expect(
        GalleryImageUrlResolver.normalizePath(input),
        'u123/baby_abc/photo.jpg',
      );
    });

    test('preserves absolute URLs for caller-level passthrough', () {
      const input = 'https://example.com/photo.jpg';

      // normalizePath itself is path-oriented; resolve() handles URL bypass.
      expect(GalleryImageUrlResolver.normalizePath(input), input);
    });
  });
}
