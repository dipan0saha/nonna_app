import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/interceptors/logging_interceptor.dart';

void main() {
  late LoggingInterceptor loggingInterceptor;

  setUp(() {
    loggingInterceptor = LoggingInterceptor();
  });

  group('LoggingInterceptor', () {
    group('logRequest', () {
      test('logs request with method and URL', () {
        // This test verifies the method doesn't throw
        expect(
          () => loggingInterceptor.logRequest(
              'GET', 'https://api.example.com/users'),
          returnsNormally,
        );
      });

      test('logs request with headers', () {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        };

        expect(
          () => loggingInterceptor.logRequest(
              'POST', 'https://api.example.com/data',
              headers: headers),
          returnsNormally,
        );
      });

      test('logs request with body', () {
        final body = {'key': 'value', 'password': 'secret'};

        expect(
          () => loggingInterceptor
              .logRequest('POST', 'https://api.example.com/data', body: body),
          returnsNormally,
        );
      });

      test('logs request with all parameters', () {
        final headers = {'Content-Type': 'application/json'};
        final body = {'data': 'test'};

        expect(
          () => loggingInterceptor.logRequest(
            'PUT',
            'https://api.example.com/data/123',
            headers: headers,
            body: body,
          ),
          returnsNormally,
        );
      });
    });

    group('logResponse', () {
      test('logs successful response', () {
        expect(
          () => loggingInterceptor.logResponse(
            'GET',
            'https://api.example.com/users',
            200,
            responseBody: {'users': []},
          ),
          returnsNormally,
        );
      });

      test('logs error response', () {
        expect(
          () => loggingInterceptor.logResponse(
            'POST',
            'https://api.example.com/data',
            500,
            responseBody: {'error': 'Internal server error'},
          ),
          returnsNormally,
        );
      });

      test('logs response with duration', () {
        expect(
          () => loggingInterceptor.logResponse(
            'GET',
            'https://api.example.com/users',
            200,
            duration: const Duration(milliseconds: 150),
          ),
          returnsNormally,
        );
      });

      test('logs response without body', () {
        expect(
          () => loggingInterceptor.logResponse(
            'DELETE',
            'https://api.example.com/data/123',
            204,
          ),
          returnsNormally,
        );
      });
    });

    group('logError', () {
      test('logs error without stack trace', () {
        final error = Exception('Test error');

        expect(
          () => loggingInterceptor.logError(
              'GET', 'https://api.example.com/users', error),
          returnsNormally,
        );
      });

      test('logs error with stack trace', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        expect(
          () => loggingInterceptor.logError(
            'POST',
            'https://api.example.com/data',
            error,
            stackTrace: stackTrace,
          ),
          returnsNormally,
        );
      });
    });

    group('logBulkOperation', () {
      test('logs bulk operation without duration', () {
        expect(
          () => loggingInterceptor.logBulkOperation('Import users', 100),
          returnsNormally,
        );
      });

      test('logs bulk operation with duration', () {
        expect(
          () => loggingInterceptor.logBulkOperation(
            'Export data',
            250,
            duration: const Duration(seconds: 5),
          ),
          returnsNormally,
        );
      });
    });
  });
}
