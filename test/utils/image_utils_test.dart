import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:nonna_app/utils/image_utils.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageUtils', () {
    late Uint8List testImageBytes;
    late File testImageFile;

    setUp(() {
      // Create a simple test image
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(255, 0, 0));
      testImageBytes = Uint8List.fromList(img.encodePng(image));

      // Create a temporary test file
      final tempDir = Directory.systemTemp.createTempSync('image_utils_test');
      testImageFile = File('${tempDir.path}/test_image.png');
      testImageFile.writeAsBytesSync(testImageBytes);
    });

    tearDown(() {
      // Clean up test file
      if (testImageFile.existsSync()) {
        testImageFile.deleteSync();
      }
      if (testImageFile.parent.existsSync()) {
        testImageFile.parent.deleteSync(recursive: true);
      }
    });

    group('compressImage', () {
      test('compresses image file successfully', () async {
        final compressed = await ImageUtils.compressImage(testImageFile);
        expect(compressed, isNotNull);
        expect(compressed, isA<Uint8List>());
        expect(compressed.isNotEmpty, isTrue);
      });

      test('compresses with custom quality', () async {
        final compressed = await ImageUtils.compressImage(
          testImageFile,
          quality: 50,
        );
        expect(compressed, isNotNull);
        expect(compressed.isNotEmpty, isTrue);
      });

      test('throws exception for non-existent file', () async {
        final tempDir = Directory.systemTemp;
        final nonExistentFile = File('${tempDir.path}/non_existent_image_${DateTime.now().millisecondsSinceEpoch}.png');
        expect(
          () => ImageUtils.compressImage(nonExistentFile),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('compressImageBytes', () {
      test('compresses image bytes successfully', () async {
        final compressed = await ImageUtils.compressImageBytes(testImageBytes);
        expect(compressed, isNotNull);
        expect(compressed, isA<Uint8List>());
        expect(compressed.isNotEmpty, isTrue);
      });

      test('compresses with custom quality', () async {
        final compressed = await ImageUtils.compressImageBytes(
          testImageBytes,
          quality: 50,
        );
        expect(compressed, isNotNull);
        expect(compressed.isNotEmpty, isTrue);
      });
    });

    group('resizeImage', () {
      test('resizes image file successfully', () async {
        final resized = await ImageUtils.resizeImage(
          testImageFile,
          maxWidth: 50,
          maxHeight: 50,
        );
        expect(resized, isNotNull);
        expect(resized.isNotEmpty, isTrue);

        // Verify dimensions
        final dimensions = await ImageUtils.getImageDimensionsFromBytes(resized);
        expect(dimensions['width'], lessThanOrEqualTo(50));
        expect(dimensions['height'], lessThanOrEqualTo(50));
      });

      test('maintains aspect ratio', () async {
        final resized = await ImageUtils.resizeImage(
          testImageFile,
          maxWidth: 50,
          maxHeight: 100,
        );
        final dimensions = await ImageUtils.getImageDimensionsFromBytes(resized);
        expect(dimensions['width'], equals(50));
        expect(dimensions['height'], equals(50)); // Original is square
      });
    });

    group('resizeImageBytes', () {
      test('resizes image bytes successfully', () async {
        final resized = await ImageUtils.resizeImageBytes(
          testImageBytes,
          maxWidth: 50,
          maxHeight: 50,
        );
        expect(resized, isNotNull);
        expect(resized.isNotEmpty, isTrue);
      });

      test('resizes with custom quality', () async {
        final resized = await ImageUtils.resizeImageBytes(
          testImageBytes,
          maxWidth: 50,
          maxHeight: 50,
          quality: 60,
        );
        expect(resized, isNotNull);
        expect(resized.isNotEmpty, isTrue);
      });
    });

    group('createThumbnail', () {
      test('creates square thumbnail', () async {
        final thumbnail = await ImageUtils.createThumbnail(
          testImageFile,
          size: 32,
        );
        expect(thumbnail, isNotNull);
        expect(thumbnail.isNotEmpty, isTrue);

        // Verify dimensions are square
        final dimensions = await ImageUtils.getImageDimensionsFromBytes(thumbnail);
        expect(dimensions['width'], equals(32));
        expect(dimensions['height'], equals(32));
      });

      test('creates thumbnail with custom quality', () async {
        final thumbnail = await ImageUtils.createThumbnail(
          testImageFile,
          size: 64,
          quality: 70,
        );
        expect(thumbnail, isNotNull);
        expect(thumbnail.isNotEmpty, isTrue);
      });
    });

    group('createThumbnailFromBytes', () {
      test('creates thumbnail from bytes', () async {
        final thumbnail = await ImageUtils.createThumbnailFromBytes(
          testImageBytes,
          size: 32,
        );
        expect(thumbnail, isNotNull);
        expect(thumbnail.isNotEmpty, isTrue);
      });
    });

    group('convertFormat', () {
      test('converts to jpg format', () async {
        final converted = await ImageUtils.convertFormat(
          testImageBytes,
          format: 'jpg',
        );
        expect(converted, isNotNull);
        expect(converted.isNotEmpty, isTrue);
      });

      test('converts to png format', () async {
        final converted = await ImageUtils.convertFormat(
          testImageBytes,
          format: 'png',
        );
        expect(converted, isNotNull);
        expect(converted.isNotEmpty, isTrue);
      });

      test('throws exception for unsupported format', () async {
        expect(
          () => ImageUtils.convertFormat(testImageBytes, format: 'bmp'),
          throwsA(isA<Exception>()),
        );
      });

      test('accepts format case-insensitively', () async {
        final converted = await ImageUtils.convertFormat(
          testImageBytes,
          format: 'JPG',
        );
        expect(converted, isNotNull);
        expect(converted.isNotEmpty, isTrue);
      });
    });

    group('getImageDimensions', () {
      test('gets dimensions from file', () async {
        final dimensions = await ImageUtils.getImageDimensions(testImageFile);
        expect(dimensions['width'], equals(100));
        expect(dimensions['height'], equals(100));
      });

      test('throws exception for non-existent file', () async {
        final tempDir = Directory.systemTemp;
        final nonExistentFile = File('${tempDir.path}/non_existent_image_${DateTime.now().millisecondsSinceEpoch}.png');
        expect(
          () => ImageUtils.getImageDimensions(nonExistentFile),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getImageDimensionsFromBytes', () {
      test('gets dimensions from bytes', () async {
        final dimensions = await ImageUtils.getImageDimensionsFromBytes(
          testImageBytes,
        );
        expect(dimensions['width'], equals(100));
        expect(dimensions['height'], equals(100));
      });
    });

    group('isValidImage', () {
      test('returns true for valid image', () async {
        final isValid = await ImageUtils.isValidImage(testImageFile);
        expect(isValid, isTrue);
      });

      test('returns false for invalid image', () async {
        final invalidFile = File('${testImageFile.parent.path}/invalid.png');
        invalidFile.writeAsStringSync('not an image');

        final isValid = await ImageUtils.isValidImage(invalidFile);
        expect(isValid, isFalse);

        invalidFile.deleteSync();
      });

      test('returns false for non-existent file', () async {
        final tempDir = Directory.systemTemp;
        final nonExistentFile = File('${tempDir.path}/non_existent_image_${DateTime.now().millisecondsSinceEpoch}.png');
        final isValid = await ImageUtils.isValidImage(nonExistentFile);
        expect(isValid, isFalse);
      });
    });

    group('calculateCompressionRatio', () {
      test('calculates compression ratio correctly', () {
        final ratio = ImageUtils.calculateCompressionRatio(1000, 500);
        expect(ratio, equals(50.0));
      });

      test('calculates zero compression', () {
        final ratio = ImageUtils.calculateCompressionRatio(1000, 1000);
        expect(ratio, equals(0.0));
      });

      test('handles zero original size', () {
        final ratio = ImageUtils.calculateCompressionRatio(0, 500);
        expect(ratio, equals(0.0));
      });

      test('calculates negative compression (expansion)', () {
        final ratio = ImageUtils.calculateCompressionRatio(500, 1000);
        expect(ratio, equals(-100.0));
      });
    });

    group('rotateImage', () {
      test('rotates image by 90 degrees', () async {
        final rotated = await ImageUtils.rotateImage(
          testImageBytes,
          angle: 90,
        );
        expect(rotated, isNotNull);
        expect(rotated.isNotEmpty, isTrue);
      });

      test('rotates image by 180 degrees', () async {
        final rotated = await ImageUtils.rotateImage(
          testImageBytes,
          angle: 180,
        );
        expect(rotated, isNotNull);
        expect(rotated.isNotEmpty, isTrue);
      });

      test('rotates image by 270 degrees', () async {
        final rotated = await ImageUtils.rotateImage(
          testImageBytes,
          angle: 270,
        );
        expect(rotated, isNotNull);
        expect(rotated.isNotEmpty, isTrue);
      });

      test('throws exception for invalid angle', () async {
        expect(
          () => ImageUtils.rotateImage(testImageBytes, angle: 45),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
