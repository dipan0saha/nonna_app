import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/image_helpers.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageHelpers', () {
    // Helper to create a test image file
    Future<File> createTestImage(
      int width,
      int height, {
      String path = '/tmp/test_image.jpg',
    }) async {
      final image = img.Image(width: width, height: height);
      final bytes = img.encodeJpg(image);
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    }

    tearDown(() async {
      // Clean up test files
      final testFiles = [
        '/tmp/test_image.jpg',
        '/tmp/test_small.jpg',
        '/tmp/test_large.jpg',
        '/tmp/test_invalid.txt',
      ];
      for (final path in testFiles) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    });

    group('isValidSize', () {
      test('returns true for file within size limit', () async {
        final file = await createTestImage(100, 100);
        final maxSize = 1024 * 1024; // 1MB
        expect(ImageHelpers.isValidSize(file, maxSize), true);
      });

      test('returns false for file exceeding size limit', () async {
        final file = await createTestImage(1000, 1000);
        final maxSize = 1024; // 1KB (small limit)
        expect(ImageHelpers.isValidSize(file, maxSize), false);
      });
    });

    group('getFileSizeMB', () {
      test('returns file size in megabytes', () async {
        final file = await createTestImage(100, 100);
        final sizeMB = ImageHelpers.getFileSizeMB(file);
        expect(sizeMB, greaterThan(0));
        expect(sizeMB, lessThan(1));
      });

      test('calculates size correctly', () async {
        final file = await createTestImage(200, 200);
        final sizeMB = ImageHelpers.getFileSizeMB(file);
        final sizeBytes = file.lengthSync();
        expect(sizeMB, closeTo(sizeBytes / (1024 * 1024), 0.001));
      });
    });

    group('formatFileSize', () {
      test('formats bytes correctly', () {
        expect(ImageHelpers.formatFileSize(500), '500 B');
        expect(ImageHelpers.formatFileSize(999), '999 B');
      });

      test('formats kilobytes correctly', () {
        expect(ImageHelpers.formatFileSize(1024), '1.0 KB');
        expect(ImageHelpers.formatFileSize(2048), '2.0 KB');
        expect(ImageHelpers.formatFileSize(1536), '1.5 KB');
      });

      test('formats megabytes correctly', () {
        expect(ImageHelpers.formatFileSize(1024 * 1024), '1.0 MB');
        expect(ImageHelpers.formatFileSize(5 * 1024 * 1024), '5.0 MB');
        expect(ImageHelpers.formatFileSize(1536 * 1024), '1.5 MB');
      });

      test('handles zero bytes', () {
        expect(ImageHelpers.formatFileSize(0), '0 B');
      });
    });

    group('isValidImageFormat', () {
      test('returns true for valid formats', () {
        expect(ImageHelpers.isValidImageFormat('image.jpg'), true);
        expect(ImageHelpers.isValidImageFormat('photo.jpeg'), true);
        expect(ImageHelpers.isValidImageFormat('picture.png'), true);
        expect(ImageHelpers.isValidImageFormat('icon.gif'), true);
        expect(ImageHelpers.isValidImageFormat('modern.webp'), true);
        expect(ImageHelpers.isValidImageFormat('bitmap.bmp'), true);
      });

      test('returns false for invalid formats', () {
        expect(ImageHelpers.isValidImageFormat('file.txt'), false);
        expect(ImageHelpers.isValidImageFormat('video.mp4'), false);
        expect(ImageHelpers.isValidImageFormat('doc.pdf'), false);
        expect(ImageHelpers.isValidImageFormat('noextension'), false);
      });

      test('handles case insensitivity', () {
        expect(ImageHelpers.isValidImageFormat('IMAGE.JPG'), true);
        expect(ImageHelpers.isValidImageFormat('Photo.PNG'), true);
        expect(ImageHelpers.isValidImageFormat('File.JPEG'), true);
      });

      test('handles paths with directories', () {
        expect(ImageHelpers.isValidImageFormat('/path/to/image.jpg'), true);
        expect(ImageHelpers.isValidImageFormat('dir/subdir/photo.png'), true);
      });
    });

    group('getImageFormat', () {
      test('returns format for valid images', () {
        expect(ImageHelpers.getImageFormat('image.jpg'), 'jpg');
        expect(ImageHelpers.getImageFormat('photo.png'), 'png');
        expect(ImageHelpers.getImageFormat('image.JPEG'), 'jpeg');
      });

      test('returns null for invalid formats', () {
        expect(ImageHelpers.getImageFormat('file.txt'), isNull);
        expect(ImageHelpers.getImageFormat('video.mp4'), isNull);
      });
    });

    group('compressImage', () {
      test('compresses image successfully', () async {
        final file = await createTestImage(500, 500);
        final compressed = await ImageHelpers.compressImage(file, quality: 80);

        expect(compressed, isNotNull);
        expect(compressed!.length, greaterThan(0));
      });

      test('resizes image when maxWidth is specified', () async {
        final file = await createTestImage(1000, 500);
        final compressed = await ImageHelpers.compressImage(
          file,
          quality: 85,
          maxWidth: 500,
        );

        expect(compressed, isNotNull);
      });

      test('resizes image when maxHeight is specified', () async {
        final file = await createTestImage(500, 1000);
        final compressed = await ImageHelpers.compressImage(
          file,
          quality: 85,
          maxHeight: 500,
        );

        expect(compressed, isNotNull);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final compressed = await ImageHelpers.compressImage(file);
        expect(compressed, isNull);
      });
    });

    group('compressToSize', () {
      test('compresses image to target size', () async {
        final file = await createTestImage(500, 500);
        final targetSize = 10 * 1024; // 10KB

        final compressed = await ImageHelpers.compressToSize(
          file,
          targetSizeBytes: targetSize,
        );

        expect(compressed, isNotNull);
        expect(compressed!.length, lessThanOrEqualTo(targetSize * 1.1));
      });

      test('reduces quality iteratively', () async {
        final file = await createTestImage(800, 800);
        final targetSize = 5 * 1024; // 5KB (small target)

        final compressed = await ImageHelpers.compressToSize(
          file,
          targetSizeBytes: targetSize,
          maxIterations: 3,
        );

        expect(compressed, isNotNull);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final compressed = await ImageHelpers.compressToSize(
          file,
          targetSizeBytes: 1024,
        );

        expect(compressed, isNull);
      });
    });

    group('generateThumbnail', () {
      test('generates thumbnail successfully', () async {
        final file = await createTestImage(1000, 1000);
        final thumbnail = await ImageHelpers.generateThumbnail(
          file,
          width: 200,
          height: 200,
        );

        expect(thumbnail, isNotNull);
        expect(thumbnail!.length, greaterThan(0));
      });

      test('uses default dimensions', () async {
        final file = await createTestImage(800, 600);
        final thumbnail = await ImageHelpers.generateThumbnail(file);

        expect(thumbnail, isNotNull);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final thumbnail = await ImageHelpers.generateThumbnail(file);
        expect(thumbnail, isNull);
      });
    });

    group('generateSquareThumbnail', () {
      test('generates square thumbnail', () async {
        final file = await createTestImage(800, 600);
        final thumbnail = await ImageHelpers.generateSquareThumbnail(
          file,
          size: 150,
        );

        expect(thumbnail, isNotNull);
        expect(thumbnail!.length, greaterThan(0));
      });

      test('uses default size', () async {
        final file = await createTestImage(1000, 1000);
        final thumbnail = await ImageHelpers.generateSquareThumbnail(file);

        expect(thumbnail, isNotNull);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final thumbnail = await ImageHelpers.generateSquareThumbnail(file);
        expect(thumbnail, isNull);
      });
    });

    group('convertToJpeg', () {
      test('converts image to JPEG', () async {
        final file = await createTestImage(400, 400);
        final jpeg = await ImageHelpers.convertToJpeg(file, quality: 90);

        expect(jpeg, isNotNull);
        expect(jpeg!.length, greaterThan(0));
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final jpeg = await ImageHelpers.convertToJpeg(file);
        expect(jpeg, isNull);
      });
    });

    group('convertToPng', () {
      test('converts image to PNG', () async {
        final file = await createTestImage(400, 400);
        final png = await ImageHelpers.convertToPng(file);

        expect(png, isNotNull);
        expect(png!.length, greaterThan(0));
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final png = await ImageHelpers.convertToPng(file);
        expect(png, isNull);
      });
    });

    group('calculateAspectRatio', () {
      test('calculates aspect ratio correctly', () {
        expect(ImageHelpers.calculateAspectRatio(1920, 1080),
            closeTo(16 / 9, 0.01));
        expect(ImageHelpers.calculateAspectRatio(1000, 1000), 1.0);
        expect(
            ImageHelpers.calculateAspectRatio(800, 600), closeTo(4 / 3, 0.01));
      });

      test('handles portrait orientation', () {
        expect(
            ImageHelpers.calculateAspectRatio(600, 800), closeTo(0.75, 0.01));
      });
    });

    group('calculateDimensions', () {
      test('maintains aspect ratio with target width', () {
        final result = ImageHelpers.calculateDimensions(
          originalWidth: 1000,
          originalHeight: 500,
          targetWidth: 500,
        );

        expect(result.width, 500);
        expect(result.height, 250);
      });

      test('maintains aspect ratio with target height', () {
        final result = ImageHelpers.calculateDimensions(
          originalWidth: 800,
          originalHeight: 600,
          targetHeight: 300,
        );

        expect(result.width, 400);
        expect(result.height, 300);
      });

      test('uses both dimensions when specified', () {
        final result = ImageHelpers.calculateDimensions(
          originalWidth: 1000,
          originalHeight: 1000,
          targetWidth: 200,
          targetHeight: 300,
        );

        expect(result.width, 200);
        expect(result.height, 300);
      });

      test('returns original dimensions when no target specified', () {
        final result = ImageHelpers.calculateDimensions(
          originalWidth: 800,
          originalHeight: 600,
        );

        expect(result.width, 800);
        expect(result.height, 600);
      });
    });

    group('isLandscape', () {
      test('returns true for landscape images', () {
        expect(ImageHelpers.isLandscape(1920, 1080), true);
        expect(ImageHelpers.isLandscape(800, 600), true);
      });

      test('returns false for portrait images', () {
        expect(ImageHelpers.isLandscape(600, 800), false);
      });

      test('returns false for square images', () {
        expect(ImageHelpers.isLandscape(500, 500), false);
      });
    });

    group('isPortrait', () {
      test('returns true for portrait images', () {
        expect(ImageHelpers.isPortrait(600, 800), true);
        expect(ImageHelpers.isPortrait(1080, 1920), true);
      });

      test('returns false for landscape images', () {
        expect(ImageHelpers.isPortrait(800, 600), false);
      });

      test('returns false for square images', () {
        expect(ImageHelpers.isPortrait(500, 500), false);
      });
    });

    group('isSquare', () {
      test('returns true for square images', () {
        expect(ImageHelpers.isSquare(500, 500), true);
        expect(ImageHelpers.isSquare(1000, 1000), true);
      });

      test('returns false for non-square images', () {
        expect(ImageHelpers.isSquare(800, 600), false);
        expect(ImageHelpers.isSquare(600, 800), false);
      });
    });

    group('cropImage', () {
      test('crops image successfully', () async {
        final file = await createTestImage(800, 600);
        final cropped = await ImageHelpers.cropImage(
          file,
          x: 100,
          y: 100,
          width: 400,
          height: 300,
        );

        expect(cropped, isNotNull);
        expect(cropped!.length, greaterThan(0));
      });

      test('handles invalid coordinates gracefully', () async {
        final file = await createTestImage(400, 400);
        final cropped = await ImageHelpers.cropImage(
          file,
          x: 500, // Beyond image bounds
          y: 0,
          width: 100,
          height: 100,
        );

        // Should handle error gracefully
        expect(cropped, isNull);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final cropped = await ImageHelpers.cropImage(
          file,
          x: 0,
          y: 0,
          width: 100,
          height: 100,
        );

        expect(cropped, isNull);
      });
    });

    group('getImageDimensions', () {
      test('returns correct dimensions', () async {
        final file = await createTestImage(640, 480);
        final dimensions = await ImageHelpers.getImageDimensions(file);

        expect(dimensions, isNotNull);
        expect(dimensions!.width, 640);
        expect(dimensions.height, 480);
      });

      test('handles invalid file gracefully', () async {
        final file = File('/tmp/test_invalid.txt');
        await file.writeAsString('not an image');

        final dimensions = await ImageHelpers.getImageDimensions(file);
        expect(dimensions, isNull);
      });
    });

    group('edge cases', () {
      test('handles very small images', () async {
        final file = await createTestImage(10, 10);
        final compressed = await ImageHelpers.compressImage(file);
        expect(compressed, isNotNull);
      });

      test('handles large images', () async {
        final file = await createTestImage(2000, 2000);
        final compressed = await ImageHelpers.compressImage(
          file,
          maxWidth: 500,
        );
        expect(compressed, isNotNull);
      });

      test('handles extreme aspect ratios', () {
        final result = ImageHelpers.calculateDimensions(
          originalWidth: 4000,
          originalHeight: 100,
          targetWidth: 1000,
        );
        expect(result.width, 1000);
        expect(result.height, 25);
      });

      test('handles quality boundaries', () async {
        final file = await createTestImage(400, 400);

        final lowQuality = await ImageHelpers.compressImage(file, quality: 1);
        expect(lowQuality, isNotNull);

        final highQuality =
            await ImageHelpers.compressImage(file, quality: 100);
        expect(highQuality, isNotNull);
      });

      test('handles zero dimensions in calculations', () {
        expect(
          () => ImageHelpers.calculateAspectRatio(100, 0),
          throwsA(anything),
        );
      });
    });

    group('file operations', () {
      test('handles non-existent files', () async {
        final file = File('/tmp/nonexistent.jpg');

        expect(
          () => ImageHelpers.compressImage(file),
          throwsA(anything),
        );
      });

      test('handles different file extensions', () {
        expect(ImageHelpers.isValidImageFormat('test.jpg'), true);
        expect(ImageHelpers.isValidImageFormat('test.jpeg'), true);
        expect(ImageHelpers.isValidImageFormat('test.png'), true);
        expect(ImageHelpers.isValidImageFormat('test.gif'), true);
        expect(ImageHelpers.isValidImageFormat('test.webp'), true);
        expect(ImageHelpers.isValidImageFormat('test.bmp'), true);
      });

      test('handles paths with special characters', () {
        expect(
          ImageHelpers.isValidImageFormat('path/with spaces/image.jpg'),
          true,
        );
        expect(
          ImageHelpers.isValidImageFormat('path-with-dashes/image.png'),
          true,
        );
      });
    });
  });
}
