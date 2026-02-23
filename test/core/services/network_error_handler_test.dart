import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/network_error_handler.dart';

void main() {
  group('NetworkErrorHandler', () {
    // -----------------------------------------------------------------------
    // Successful execution
    // -----------------------------------------------------------------------

    group('Successful execution', () {
      test('returns success result when operation completes', () async {
        final handler = NetworkErrorHandler();
        final result = await handler.execute(() async => 42);

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(42));
        expect(result.error, isNull);
      });

      test('records one attempt on first-try success', () async {
        final handler = NetworkErrorHandler();
        final result = await handler.execute(() async => 'hello');

        expect(result.attempts, equals(1));
      });

      test('works with non-primitive result types', () async {
        final handler = NetworkErrorHandler();
        final data = {'key': 'value'};
        final result =
            await handler.execute<Map<String, String>>(() async => data);

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(data));
      });
    });

    // -----------------------------------------------------------------------
    // Timeout handling
    // -----------------------------------------------------------------------

    group('Timeout handling', () {
      test('returns timeout failure when operation exceeds timeout', () async {
        final handler = NetworkErrorHandler(
          timeout: const Duration(milliseconds: 50),
          maxRetries: 0,
        );

        final result = await handler.execute(() async {
          await Future<void>.delayed(const Duration(seconds: 5));
          return 'never';
        });

        expect(result.isFailure, isTrue);
        expect(result.errorType, equals(NetworkErrorType.timeout));
      });

      test('categorises TimeoutException as timeout', () {
        final handler = NetworkErrorHandler();
        final type =
            handler.categoriseError(TimeoutException('Request timed out'));
        expect(type, equals(NetworkErrorType.timeout));
      });
    });

    // -----------------------------------------------------------------------
    // Network connection errors
    // -----------------------------------------------------------------------

    group('Network connection errors', () {
      test('categorises SocketException as noConnection', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(
          const SocketException('Connection refused'),
        );
        expect(type, equals(NetworkErrorType.noConnection));
      });

      test('categorises NetworkException as noConnection', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(
          const NetworkException('No network'),
        );
        expect(type, equals(NetworkErrorType.noConnection));
      });

      test(
          'categorises string-based connection refused message as noConnection',
          () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(
          Exception('connection refused'),
        );
        expect(type, equals(NetworkErrorType.noConnection));
      });

      test('categorises failed host lookup as noConnection', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(
          Exception('failed host lookup: api.example.com'),
        );
        expect(type, equals(NetworkErrorType.noConnection));
      });
    });

    // -----------------------------------------------------------------------
    // Server errors
    // -----------------------------------------------------------------------

    group('Server errors', () {
      test('categorises HttpException with 500 message as serverError', () {
        final handler = NetworkErrorHandler();
        final type =
            handler.categoriseError(const HttpException('500 Internal Server Error'));
        expect(type, equals(NetworkErrorType.serverError));
      });

      test('categorises string with 503 as serverError', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(Exception('503 Service Unavailable'));
        expect(type, equals(NetworkErrorType.serverError));
      });

      test('categorises HttpException without status code as serverError', () {
        final handler = NetworkErrorHandler();
        final type =
            handler.categoriseError(const HttpException('Bad gateway'));
        expect(type, equals(NetworkErrorType.serverError));
      });
    });

    // -----------------------------------------------------------------------
    // Client errors
    // -----------------------------------------------------------------------

    group('Client errors', () {
      test('categorises HttpException with 404 message as clientError', () {
        final handler = NetworkErrorHandler();
        final type =
            handler.categoriseError(const HttpException('404 Not Found'));
        expect(type, equals(NetworkErrorType.clientError));
      });

      test('categorises string with 401 as clientError', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(Exception('401 Unauthorized'));
        expect(type, equals(NetworkErrorType.clientError));
      });

      test('does not retry client errors', () async {
        var calls = 0;
        final handler = NetworkErrorHandler(maxRetries: 3);

        final result = await handler.execute(() async {
          calls++;
          throw const HttpException('404 Not Found');
        });

        // Should give up after first attempt – no retries for 4xx
        expect(calls, equals(1));
        expect(result.isFailure, isTrue);
        expect(result.errorType, equals(NetworkErrorType.clientError));
      });
    });

    // -----------------------------------------------------------------------
    // Unknown errors
    // -----------------------------------------------------------------------

    group('Unknown errors', () {
      test('categorises unrecognised error as unknown', () {
        final handler = NetworkErrorHandler();
        final type = handler.categoriseError(Exception('Something went wrong'));
        expect(type, equals(NetworkErrorType.unknown));
      });
    });

    // -----------------------------------------------------------------------
    // Retry behaviour
    // -----------------------------------------------------------------------

    group('Retry behaviour', () {
      test('retries the specified number of times on transient errors',
          () async {
        var calls = 0;
        final handler = NetworkErrorHandler(
          maxRetries: 3,
          initialBackoff: Duration.zero,
        );

        final result = await handler.execute(() async {
          calls++;
          throw const SocketException('Unreachable');
        });

        // 1 original + 3 retries = 4 total calls
        expect(calls, equals(4));
        expect(result.attempts, equals(4));
        expect(result.isFailure, isTrue);
      });

      test('succeeds on retry after initial failure', () async {
        var calls = 0;
        final handler = NetworkErrorHandler(
          maxRetries: 2,
          initialBackoff: Duration.zero,
        );

        final result = await handler.execute(() async {
          calls++;
          if (calls < 3) throw const SocketException('Temporary failure');
          return 'recovered';
        });

        expect(result.isSuccess, isTrue);
        expect(result.data, equals('recovered'));
        expect(calls, equals(3));
      });

      test('respects maxRetries = 0 (no retries)', () async {
        var calls = 0;
        final handler = NetworkErrorHandler(
          maxRetries: 0,
          initialBackoff: Duration.zero,
        );

        await handler.execute(() async {
          calls++;
          throw const SocketException('Failure');
        });

        expect(calls, equals(1));
      });

      test('invokes onRetrying callback before each retry', () async {
        final retryAttempts = <int>[];
        final handler = NetworkErrorHandler(
          maxRetries: 2,
          initialBackoff: Duration.zero,
          onRetrying: (attempt, _) => retryAttempts.add(attempt),
        );

        await handler.execute(() async {
          throw const SocketException('Failure');
        });

        expect(retryAttempts, equals([1, 2]));
      });

      test('invokes onNetworkError for every failed attempt', () async {
        final errors = <NetworkErrorType>[];
        final handler = NetworkErrorHandler(
          maxRetries: 2,
          initialBackoff: Duration.zero,
          onNetworkError: (type, _) => errors.add(type),
        );

        await handler.execute(() async {
          throw const SocketException('Failure');
        });

        // 1 + 2 retries = 3 error notifications
        expect(errors.length, equals(3));
        expect(errors, everyElement(equals(NetworkErrorType.noConnection)));
      });
    });

    // -----------------------------------------------------------------------
    // Exponential back-off
    // -----------------------------------------------------------------------

    group('Exponential back-off', () {
      test('back-off doubles with each attempt', () async {
        final delays = <Duration>[];
        int calls = 0;

        final handler = NetworkErrorHandler(
          maxRetries: 3,
          initialBackoff: const Duration(milliseconds: 10),
          onRetrying: (attempt, _) {
            // back-off delay for attempt n = initialBackoff * 2^(n-1)
            final expected =
                Duration(milliseconds: 10 * (1 << (attempt - 1)));
            delays.add(expected);
          },
        );

        await handler.execute(() async {
          calls++;
          throw const SocketException('Failure');
        });

        expect(delays.length, equals(3));
        expect(delays[0].inMilliseconds, equals(10)); // 10 * 2^0
        expect(delays[1].inMilliseconds, equals(20)); // 10 * 2^1
        expect(delays[2].inMilliseconds, equals(40)); // 10 * 2^2
      });
    });

    // -----------------------------------------------------------------------
    // NetworkResult
    // -----------------------------------------------------------------------

    group('NetworkResult', () {
      test('success result has correct properties', () {
        const result = NetworkResult<int>.success(99, attempts: 2);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.data, equals(99));
        expect(result.error, isNull);
        expect(result.errorType, isNull);
        expect(result.attempts, equals(2));
      });

      test('failure result has correct properties', () {
        final err = Exception('oops');
        final result = NetworkResult<int>.failure(
          err,
          NetworkErrorType.timeout,
          attempts: 3,
        );
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.data, isNull);
        expect(result.error, equals(err));
        expect(result.errorType, equals(NetworkErrorType.timeout));
        expect(result.attempts, equals(3));
      });
    });

    // -----------------------------------------------------------------------
    // NetworkException
    // -----------------------------------------------------------------------

    group('NetworkException', () {
      test('has default message', () {
        const e = NetworkException();
        expect(e.message, equals('Network error'));
        expect(e.toString(), contains('NetworkException'));
      });

      test('accepts custom message', () {
        const e = NetworkException('No route to host');
        expect(e.message, equals('No route to host'));
      });
    });
  });
}
