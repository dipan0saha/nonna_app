import 'dart:io';
import 'package:test/test.dart';
import 'package:nonna_app/utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiUtils', () {
    group('parseJsonResponse', () {
      test('parses valid JSON object', () {
        const jsonString = '{"name": "John", "age": 30}';
        final result = ApiUtils.parseJsonResponse(jsonString);
        expect(result, isA<Map<String, dynamic>>());
        expect(result['name'], equals('John'));
        expect(result['age'], equals(30));
      });

      test('throws ApiException for invalid JSON', () {
        const invalidJson = 'not json';
        expect(
          () => ApiUtils.parseJsonResponse(invalidJson),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException for JSON array', () {
        const jsonArray = '[1, 2, 3]';
        expect(
          () => ApiUtils.parseJsonResponse(jsonArray),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('parseJsonArrayResponse', () {
      test('parses valid JSON array', () {
        const jsonString = '[{"id": 1}, {"id": 2}]';
        final result = ApiUtils.parseJsonArrayResponse(jsonString);
        expect(result, isA<List<dynamic>>());
        expect(result.length, equals(2));
      });

      test('throws ApiException for invalid JSON', () {
        const invalidJson = 'not json';
        expect(
          () => ApiUtils.parseJsonArrayResponse(invalidJson),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException for JSON object', () {
        const jsonObject = '{"key": "value"}';
        expect(
          () => ApiUtils.parseJsonArrayResponse(jsonObject),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('isSuccessStatusCode', () {
      test('returns true for 200', () {
        expect(ApiUtils.isSuccessStatusCode(200), isTrue);
      });

      test('returns true for 201', () {
        expect(ApiUtils.isSuccessStatusCode(201), isTrue);
      });

      test('returns true for 299', () {
        expect(ApiUtils.isSuccessStatusCode(299), isTrue);
      });

      test('returns false for 199', () {
        expect(ApiUtils.isSuccessStatusCode(199), isFalse);
      });

      test('returns false for 300', () {
        expect(ApiUtils.isSuccessStatusCode(300), isFalse);
      });

      test('returns false for 404', () {
        expect(ApiUtils.isSuccessStatusCode(404), isFalse);
      });

      test('returns false for 500', () {
        expect(ApiUtils.isSuccessStatusCode(500), isFalse);
      });
    });

    group('isClientError', () {
      test('returns true for 400', () {
        expect(ApiUtils.isClientError(400), isTrue);
      });

      test('returns true for 404', () {
        expect(ApiUtils.isClientError(404), isTrue);
      });

      test('returns true for 499', () {
        expect(ApiUtils.isClientError(499), isTrue);
      });

      test('returns false for 399', () {
        expect(ApiUtils.isClientError(399), isFalse);
      });

      test('returns false for 500', () {
        expect(ApiUtils.isClientError(500), isFalse);
      });
    });

    group('isServerError', () {
      test('returns true for 500', () {
        expect(ApiUtils.isServerError(500), isTrue);
      });

      test('returns true for 503', () {
        expect(ApiUtils.isServerError(503), isTrue);
      });

      test('returns true for 599', () {
        expect(ApiUtils.isServerError(599), isTrue);
      });

      test('returns false for 499', () {
        expect(ApiUtils.isServerError(499), isFalse);
      });

      test('returns false for 600', () {
        expect(ApiUtils.isServerError(600), isFalse);
      });
    });

    group('shouldRetry', () {
      test('returns true for 500 (server error)', () {
        expect(ApiUtils.shouldRetry(500), isTrue);
      });

      test('returns true for 503 (service unavailable)', () {
        expect(ApiUtils.shouldRetry(503), isTrue);
      });

      test('returns true for 408 (request timeout)', () {
        expect(ApiUtils.shouldRetry(408), isTrue);
      });

      test('returns true for 429 (too many requests)', () {
        expect(ApiUtils.shouldRetry(429), isTrue);
      });

      test('returns false for 200 (success)', () {
        expect(ApiUtils.shouldRetry(200), isFalse);
      });

      test('returns false for 404 (not found)', () {
        expect(ApiUtils.shouldRetry(404), isFalse);
      });

      test('returns false for 400 (bad request)', () {
        expect(ApiUtils.shouldRetry(400), isFalse);
      });
    });

    group('encodeJson', () {
      test('encodes Map to JSON string', () {
        final data = {'name': 'John', 'age': 30};
        final result = ApiUtils.encodeJson(data);
        expect(result, equals('{"name":"John","age":30}'));
      });

      test('encodes nested Map', () {
        final data = {
          'user': {'name': 'John', 'age': 30}
        };
        final result = ApiUtils.encodeJson(data);
        expect(result, contains('"user"'));
        expect(result, contains('"name"'));
      });
    });

    group('decodeJson', () {
      test('decodes JSON string to Map', () {
        const jsonString = '{"name":"John","age":30}';
        final result = ApiUtils.decodeJson(jsonString);
        expect(result, isA<Map<String, dynamic>>());
        expect(result['name'], equals('John'));
      });

      test('decodes JSON string to List', () {
        const jsonString = '[1,2,3]';
        final result = ApiUtils.decodeJson(jsonString);
        expect(result, isA<List<dynamic>>());
        expect(result.length, equals(3));
      });

      test('throws FormatException for invalid JSON', () {
        const invalidJson = 'not json';
        expect(
          () => ApiUtils.decodeJson(invalidJson),
          throwsFormatException,
        );
      });
    });

    group('buildQueryParams', () {
      test('builds query string from Map', () {
        final params = {'key1': 'value1', 'key2': 'value2'};
        final result = ApiUtils.buildQueryParams(params);
        expect(result, contains('key1=value1'));
        expect(result, contains('key2=value2'));
        expect(result, contains('&'));
      });

      test('encodes special characters', () {
        final params = {'query': 'hello world', 'email': 'test@example.com'};
        final result = ApiUtils.buildQueryParams(params);
        expect(result, contains('hello%20world'));
        expect(result, contains('test%40example.com'));
      });

      test('returns empty string for empty Map', () {
        final result = ApiUtils.buildQueryParams({});
        expect(result, equals(''));
      });

      test('handles numeric values', () {
        final params = {'page': 1, 'limit': 10};
        final result = ApiUtils.buildQueryParams(params);
        expect(result, contains('page=1'));
        expect(result, contains('limit=10'));
      });
    });

    group('appendQueryParams', () {
      test('appends query params to URL without existing params', () {
        const url = 'https://api.example.com/users';
        final params = {'page': 1, 'limit': 10};
        final result = ApiUtils.appendQueryParams(url, params);
        expect(result, startsWith(url));
        expect(result, contains('?'));
        expect(result, contains('page=1'));
        expect(result, contains('limit=10'));
      });

      test('appends query params to URL with existing params', () {
        const url = 'https://api.example.com/users?sort=name';
        final params = {'page': 1};
        final result = ApiUtils.appendQueryParams(url, params);
        expect(result, contains('?'));
        expect(result, contains('&'));
        expect(result, contains('page=1'));
      });

      test('returns original URL for empty params', () {
        const url = 'https://api.example.com/users';
        final result = ApiUtils.appendQueryParams(url, {});
        expect(result, equals(url));
      });
    });

    group('ApiException', () {
      test('creates exception with message and status code', () {
        final exception = ApiException('Error message', 404);
        expect(exception.message, equals('Error message'));
        expect(exception.statusCode, equals(404));
        expect(exception.responseBody, isNull);
      });

      test('creates exception with response body', () {
        final exception = ApiException('Error message', 500, 'Server error');
        expect(exception.message, equals('Error message'));
        expect(exception.statusCode, equals(500));
        expect(exception.responseBody, equals('Server error'));
      });

      test('toString includes message and status code', () {
        final exception = ApiException('Error message', 404);
        final string = exception.toString();
        expect(string, contains('Error message'));
        expect(string, contains('404'));
      });

      test('toString includes response body when present', () {
        final exception = ApiException('Error message', 500, 'Server error');
        final string = exception.toString();
        expect(string, contains('Server error'));
      });
    });
  });
}
