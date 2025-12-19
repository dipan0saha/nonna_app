# Utility Libraries

This directory contains reusable utility libraries for common tasks in the Nonna App.

## Available Utilities

### 1. DateUtils (`date_utils.dart`)

Utility class for date and time formatting and manipulation operations.

#### Features:
- **Formatting**: Convert DateTime objects to various string formats
  - Default date format: `yyyy-MM-dd`
  - Display format: `MMM dd, yyyy` (e.g., "Jan 15, 2024")
  - Custom formats via `formatCustom()`
  
- **Parsing**: Convert date strings back to DateTime objects
  - Parse standard formats
  - Parse custom formats
  
- **Relative Time**: Get human-readable relative time strings
  - "2 hours ago", "in 3 days", etc.
  
- **Date Comparisons**: Check date relationships
  - `isSameDay()`, `isToday()`, `isYesterday()`, `isTomorrow()`
  
- **Date Manipulation**: Add/subtract durations, get start/end of day

#### Example Usage:
```dart
import 'package:nonna_app/utils/date_utils.dart';

// Format a date
final dateString = DateUtils.formatDate(DateTime.now());
// Output: "2024-01-15"

// Display format
final displayString = DateUtils.formatDisplayDateTime(DateTime.now());
// Output: "Jan 15, 2024 03:30 PM"

// Relative time
final relativeTime = DateUtils.getRelativeTime(
  DateTime.now().subtract(Duration(hours: 2))
);
// Output: "2 hours ago"

// Parse a date
final parsedDate = DateUtils.parseDate("2024-01-15");

// Check if today
if (DateUtils.isToday(someDate)) {
  print("This date is today!");
}
```

### 2. ImageUtils (`image_utils.dart`)

Utility class for image compression, resizing, and format conversion.

#### Features:
- **Compression**: Reduce image file size while maintaining quality
  - Configurable quality (0-100)
  - Works with files or bytes
  
- **Resizing**: Change image dimensions
  - Maintains aspect ratio
  - Supports max width/height constraints
  
- **Thumbnails**: Create square thumbnails from images
  - Crops from center
  - Configurable size
  
- **Format Conversion**: Convert between image formats
  - JPG, PNG, WebP support
  
- **Rotation**: Rotate images by 90, 180, or 270 degrees

- **Validation**: Check if a file is a valid image

- **Metadata**: Get image dimensions without loading full image

#### Example Usage:
```dart
import 'package:nonna_app/utils/image_utils.dart';
import 'dart:io';

// Compress an image
final compressed = await ImageUtils.compressImage(
  File('path/to/image.jpg'),
  quality: 85,
);

// Resize an image
final resized = await ImageUtils.resizeImage(
  imageFile,
  maxWidth: 1920,
  maxHeight: 1080,
  quality: 85,
);

// Create a thumbnail
final thumbnail = await ImageUtils.createThumbnail(
  imageFile,
  size: 150,
  quality: 80,
);

// Get dimensions
final dimensions = await ImageUtils.getImageDimensions(imageFile);
print('Width: ${dimensions['width']}, Height: ${dimensions['height']}');

// Validate image
final isValid = await ImageUtils.isValidImage(imageFile);

// Convert format
final png = await ImageUtils.convertFormat(
  imageBytes,
  format: 'png',
);

// Rotate image
final rotated = await ImageUtils.rotateImage(
  imageBytes,
  angle: 90,
);
```

### 3. ApiUtils (`api_utils.dart`)

Utility class for handling HTTP API requests with retry logic and response parsing.

#### Features:
- **HTTP Methods**: GET, POST, PUT, DELETE with automatic retry
  - Configurable timeout
  - Automatic retry for server errors and timeouts
  - Configurable retry attempts and delay
  
- **JSON Parsing**: Easy JSON encoding/decoding
  - Parse JSON objects and arrays
  - Handle parsing errors gracefully
  
- **Status Code Helpers**: Check HTTP status codes
  - `isSuccessStatusCode()`, `isClientError()`, `isServerError()`
  - `shouldRetry()` - determines if request should be retried
  
- **URL Building**: Build URLs with query parameters
  - Automatic URL encoding
  - Append parameters to existing URLs
  
- **Error Handling**: Custom ApiException for detailed error information

#### Example Usage:
```dart
import 'package:nonna_app/utils/api_utils.dart';

// Make a GET request
try {
  final response = await ApiUtils.get(
    'https://api.example.com/users',
    timeout: Duration(seconds: 30),
    maxRetries: 3,
  );
  
  final data = ApiUtils.parseJsonResponse(response);
  print('User count: ${data['count']}');
} on ApiException catch (e) {
  print('API Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
}

// Make a POST request
final userData = {'name': 'John', 'email': 'john@example.com'};
final createResponse = await ApiUtils.post(
  'https://api.example.com/users',
  body: userData,
);

// Build URL with query parameters
final params = {'page': 1, 'limit': 10, 'sort': 'name'};
final url = ApiUtils.appendQueryParams(
  'https://api.example.com/users',
  params,
);
// Result: "https://api.example.com/users?page=1&limit=10&sort=name"

// Check status codes
if (ApiUtils.isSuccessStatusCode(statusCode)) {
  // Handle success
} else if (ApiUtils.shouldRetry(statusCode)) {
  // Retry the request
}
```

## Testing

All utilities have comprehensive test coverage:

### Unit Tests
- `test/utils/date_utils_test.dart` - DateUtils unit tests
- `test/utils/image_utils_test.dart` - ImageUtils unit tests
- `test/utils/api_utils_test.dart` - ApiUtils unit tests

### Integration Tests
- `integration_test/utils_integration_test.dart` - Integration tests covering real-world workflows

### Running Tests

Run all tests:
```bash
./run_all_tests.sh
```

Run specific utility tests:
```bash
flutter test test/utils/date_utils_test.dart
flutter test test/utils/image_utils_test.dart
flutter test test/utils/api_utils_test.dart
```

Run integration tests:
```bash
flutter test integration_test/utils_integration_test.dart
```

## Dependencies

The utilities require the following packages (already added to `pubspec.yaml`):

- `intl: ^0.19.0` - For date formatting (DateUtils)
- `image: ^4.1.7` - For image processing (ImageUtils)
- `http: ^1.2.0` - For HTTP requests (ApiUtils)

## Best Practices

1. **Error Handling**: All utilities handle null inputs gracefully and return null or throw descriptive exceptions
2. **Performance**: Image processing uses isolates to avoid blocking the main thread
3. **Configurability**: Most methods accept optional parameters for customization
4. **Type Safety**: Strong typing throughout with clear parameter names
5. **Documentation**: All public methods are documented with dartdoc comments

## Contributing

When adding new utilities or modifying existing ones:

1. Follow the existing code style and patterns
2. Add comprehensive unit tests for all new functionality
3. Update this README with usage examples
4. Ensure all tests pass before committing
5. Use descriptive method and parameter names
6. Add dartdoc comments for all public APIs
