import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nonna_app/utils/date_utils.dart';
import 'package:nonna_app/utils/image_utils.dart';
import 'package:nonna_app/utils/api_utils.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Utility Libraries Integration Tests', () {
    group('DateUtils Integration', () {
      test('complete date formatting and parsing workflow', () {
        // Create a date
        final originalDate = DateTime(2024, 1, 15, 14, 30, 45);

        // Format to string
        final dateString = DateUtils.formatDateTime(originalDate);
        expect(dateString, isNotNull);

        // Parse back to DateTime
        final parsedDate = DateUtils.parseDateTime(dateString!);
        expect(parsedDate, isNotNull);

        // Verify they match (ignoring milliseconds)
        expect(parsedDate!.year, equals(originalDate.year));
        expect(parsedDate.month, equals(originalDate.month));
        expect(parsedDate.day, equals(originalDate.day));
        expect(parsedDate.hour, equals(originalDate.hour));
        expect(parsedDate.minute, equals(originalDate.minute));
        expect(parsedDate.second, equals(originalDate.second));
      });

      test('date manipulation workflow', () {
        final startDate = DateTime(2024, 1, 1);

        // Add duration
        final futureDate = DateUtils.addDuration(
          startDate,
          const Duration(days: 30),
        );
        expect(futureDate, isNotNull);

        // Subtract duration
        final pastDate = DateUtils.subtractDuration(
          futureDate!,
          const Duration(days: 30),
        );
        expect(pastDate, isNotNull);

        // Verify we're back to the start
        expect(DateUtils.isSameDay(startDate, pastDate!), isTrue);
      });

      test('relative time workflow', () {
        final now = DateTime.now();
        final pastTime = now.subtract(const Duration(hours: 2));
        final futureTime = now.add(const Duration(days: 1));

        final relativeTimeText = DateUtils.getRelativeTime(pastTime);
        expect(relativeTimeText, contains('ago'));

        final futureTimeText = DateUtils.getRelativeTime(futureTime);
        expect(futureTimeText, contains('in'));
      });
    });

    group('ImageUtils Integration', () {
      late File testImageFile;
      late Uint8List testImageBytes;

      setUp(() {
        // Create a test image
        final image = img.Image(width: 200, height: 200);
        img.fill(image, color: img.ColorRgb8(100, 150, 200));
        testImageBytes = Uint8List.fromList(img.encodePng(image));

        // Save to temporary file
        final tempDir = Directory.systemTemp.createTempSync('integration_test');
        testImageFile = File('${tempDir.path}/test_image.png');
        testImageFile.writeAsBytesSync(testImageBytes);
      });

      tearDown(() {
        if (testImageFile.existsSync()) {
          testImageFile.deleteSync();
        }
        if (testImageFile.parent.existsSync()) {
          testImageFile.parent.deleteSync(recursive: true);
        }
      });

      test('complete image processing workflow', () async {
        // 1. Validate image
        final isValid = await ImageUtils.isValidImage(testImageFile);
        expect(isValid, isTrue);

        // 2. Get original dimensions
        final originalDimensions = await ImageUtils.getImageDimensions(
          testImageFile,
        );
        expect(originalDimensions['width'], equals(200));
        expect(originalDimensions['height'], equals(200));

        // 3. Resize image
        final resized = await ImageUtils.resizeImage(
          testImageFile,
          maxWidth: 100,
          maxHeight: 100,
        );
        expect(resized, isNotNull);

        // 4. Verify resized dimensions
        final resizedDimensions = await ImageUtils.getImageDimensionsFromBytes(
          resized,
        );
        expect(resizedDimensions['width'], lessThanOrEqualTo(100));
        expect(resizedDimensions['height'], lessThanOrEqualTo(100));

        // 5. Create thumbnail
        final thumbnail = await ImageUtils.createThumbnail(
          testImageFile,
          size: 50,
        );
        final thumbnailDimensions =
            await ImageUtils.getImageDimensionsFromBytes(thumbnail);
        expect(thumbnailDimensions['width'], equals(50));
        expect(thumbnailDimensions['height'], equals(50));

        // 6. Compress image
        final compressed = await ImageUtils.compressImage(
          testImageFile,
          quality: 70,
        );
        expect(compressed, isNotNull);

        // 7. Calculate compression ratio
        final originalSize = testImageFile.lengthSync();
        final compressedSize = compressed.length;
        final compressionRatio = ImageUtils.calculateCompressionRatio(
          originalSize,
          compressedSize,
        );
        expect(compressionRatio, isA<double>());
      });

      test('image format conversion workflow', () async {
        // Convert PNG to JPG
        final jpg = await ImageUtils.convertFormat(
          testImageBytes,
          format: 'jpg',
          quality: 85,
        );
        expect(jpg, isNotNull);
        expect(jpg.isNotEmpty, isTrue);

        // Convert back to PNG
        final png = await ImageUtils.convertFormat(jpg, format: 'png');
        expect(png, isNotNull);
        expect(png.isNotEmpty, isTrue);
      });

      test('image rotation workflow', () async {
        // Rotate 90 degrees
        final rotated90 = await ImageUtils.rotateImage(
          testImageBytes,
          angle: 90,
        );
        expect(rotated90, isNotNull);

        // Rotate another 90 degrees (total 180)
        final rotated180 = await ImageUtils.rotateImage(rotated90, angle: 90);
        expect(rotated180, isNotNull);

        // Rotate another 180 degrees (back to original orientation)
        final rotatedFull = await ImageUtils.rotateImage(
          rotated180,
          angle: 180,
        );
        expect(rotatedFull, isNotNull);
      });
    });

    group('ApiUtils Integration', () {
      test('JSON encoding and decoding workflow', () {
        // Create data
        final userData = {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'active': true,
        };

        // Encode to JSON
        final jsonString = ApiUtils.encodeJson(userData);
        expect(jsonString, isNotNull);
        expect(jsonString, contains('John Doe'));

        // Decode back
        final decoded = ApiUtils.decodeJson(jsonString);
        expect(decoded, isA<Map<String, dynamic>>());
        expect(decoded['name'], equals('John Doe'));
        expect(decoded['email'], equals('john@example.com'));

        // Parse as response
        final parsed = ApiUtils.parseJsonResponse(jsonString);
        expect(parsed['id'], equals(1));
        expect(parsed['active'], isTrue);
      });

      test('URL building workflow', () {
        const baseUrl = 'https://api.example.com/users';

        // Build query params
        final params = {
          'page': 1,
          'limit': 10,
          'sort': 'name',
          'filter': 'active',
        };

        final queryString = ApiUtils.buildQueryParams(params);
        expect(queryString, isNotEmpty);
        expect(queryString, contains('page=1'));
        expect(queryString, contains('limit=10'));

        // Append to URL
        final fullUrl = ApiUtils.appendQueryParams(baseUrl, params);
        expect(fullUrl, startsWith(baseUrl));
        expect(fullUrl, contains('?'));
        expect(fullUrl, contains('page=1'));
        expect(fullUrl, contains('limit=10'));
      });

      test('status code checking workflow', () {
        const successCode = 200;
        const clientErrorCode = 404;
        const serverErrorCode = 500;
        const retryableCode = 503;

        // Check success
        expect(ApiUtils.isSuccessStatusCode(successCode), isTrue);
        expect(ApiUtils.isClientError(successCode), isFalse);
        expect(ApiUtils.isServerError(successCode), isFalse);
        expect(ApiUtils.shouldRetry(successCode), isFalse);

        // Check client error
        expect(ApiUtils.isSuccessStatusCode(clientErrorCode), isFalse);
        expect(ApiUtils.isClientError(clientErrorCode), isTrue);
        expect(ApiUtils.isServerError(clientErrorCode), isFalse);
        expect(ApiUtils.shouldRetry(clientErrorCode), isFalse);

        // Check server error
        expect(ApiUtils.isSuccessStatusCode(serverErrorCode), isFalse);
        expect(ApiUtils.isClientError(serverErrorCode), isFalse);
        expect(ApiUtils.isServerError(serverErrorCode), isTrue);
        expect(ApiUtils.shouldRetry(serverErrorCode), isTrue);

        // Check retryable error
        expect(ApiUtils.shouldRetry(retryableCode), isTrue);
      });

      test('complex JSON parsing workflow', () {
        // Complex nested JSON
        final complexJson = '''
        {
          "users": [
            {"id": 1, "name": "Alice"},
            {"id": 2, "name": "Bob"}
          ],
          "metadata": {
            "total": 2,
            "page": 1
          }
        }
        ''';

        // Parse
        final parsed = ApiUtils.parseJsonResponse(complexJson);
        expect(parsed['users'], isA<List>());
        expect(parsed['users'].length, equals(2));
        expect(parsed['metadata']['total'], equals(2));

        // Parse array from response
        // Use json.encode directly since parsed['users'] is a List, not a Map
        final usersJson = json.encode(parsed['users']);
        final usersArray = ApiUtils.parseJsonArrayResponse(usersJson);
        expect(usersArray, isA<List>());
        expect(usersArray.length, equals(2));
        final firstUser = usersArray[0];
        expect(firstUser, isA<Map<String, dynamic>>());
        expect((firstUser as Map<String, dynamic>)['name'], equals('Alice'));
      });
    });

    group('Cross-Utility Integration', () {
      test('combined date and API workflow', () {
        // Create timestamp
        final timestamp = DateTime.now();
        final formattedDate = DateUtils.formatDateTime(timestamp);

        // Create API payload with date
        final payload = {'created_at': formattedDate, 'name': 'Test Event'};

        // Encode for API
        final jsonPayload = ApiUtils.encodeJson(payload);
        expect(jsonPayload, contains(formattedDate));

        // Decode response
        final decoded = ApiUtils.parseJsonResponse(jsonPayload);

        // Parse date back
        final parsedDate = DateUtils.parseDateTime(decoded['created_at']);
        expect(parsedDate, isNotNull);
        expect(DateUtils.isSameDay(timestamp, parsedDate!), isTrue);
      });

      test('image metadata and API workflow', () async {
        // Create test image
        final image = img.Image(width: 150, height: 150);
        img.fill(image, color: img.ColorRgb8(255, 0, 0));
        final imageBytes = Uint8List.fromList(img.encodePng(image));

        // Get image dimensions
        final dimensions = await ImageUtils.getImageDimensionsFromBytes(
          imageBytes,
        );

        // Create API payload with image metadata
        final metadata = {
          'width': dimensions['width'],
          'height': dimensions['height'],
          'format': 'png',
          'size': imageBytes.length,
        };

        // Encode for API
        final jsonMetadata = ApiUtils.encodeJson(metadata);

        // Decode and verify
        final decoded = ApiUtils.parseJsonResponse(jsonMetadata);
        expect(decoded['width'], equals(150));
        expect(decoded['height'], equals(150));
      });
    });
  });
}
