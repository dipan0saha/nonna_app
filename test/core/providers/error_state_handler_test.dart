import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/providers/error_state_handler.dart';

void main() {
  group('ErrorStateHandler', () {
    late ProviderContainer container;
    late ErrorStateHandler errorHandler;

    setUp(() {
      // Create a ProviderContainer for testing
      container = ProviderContainer();

      // Get the notifier from the container (properly initialized)
      errorHandler = container.read(errorStateHandlerProvider.notifier);
    });

    tearDown(() {
      // Dispose the container after each test
      container.dispose();
    });

    group('Initial State', () {
      test('starts with no errors', () {
        expect(errorHandler.state.hasAnyErrors, isFalse);
        expect(errorHandler.state.errorCount, equals(0));
        expect(errorHandler.state.history, isEmpty);
      });
    });

    group('Handle Error', () {
      test('handles error successfully', () {
        final error = Exception('Test error');
        errorHandler.handleError(
          error: error,
          key: 'test_error',
          userMessage: 'Test error message',
        );

        expect(errorHandler.hasError('test_error'), isTrue);
        expect(errorHandler.getErrorMessage('test_error'),
            equals('Test error message'));
      });

      test('uses default global key when not provided', () {
        errorHandler.handleError(error: Exception('Test'));

        expect(errorHandler.hasError('global'), isTrue);
        expect(errorHandler.hasError(), isTrue);
      });

      test('adds error to history', () {
        errorHandler.handleError(
          error: Exception('Error 1'),
          key: 'error1',
        );

        expect(errorHandler.state.history, hasLength(1));
        expect(errorHandler.state.history.first.key, equals('error1'));
      });

      test('maintains history limit of 50 errors', () {
        // Add 60 errors
        for (var i = 0; i < 60; i++) {
          errorHandler.handleError(
            error: Exception('Error $i'),
            key: 'error_$i',
          );
        }

        expect(errorHandler.state.history.length, lessThanOrEqualTo(50));
      });

      test('stores error timestamp', () {
        final before = DateTime.now();
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
        );
        final after = DateTime.now();

        final errorInfo = errorHandler.getError('test');
        expect(errorInfo, isNotNull);
        expect(
          errorInfo!.timestamp.isAfter(before) ||
              errorInfo.timestamp.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          errorInfo.timestamp.isBefore(after) ||
              errorInfo.timestamp.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('marks error as retryable with onRetry callback', () {
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          onRetry: () async {},
          retryable: true,
        );

        final errorInfo = errorHandler.getError('test');
        expect(errorInfo?.retryable, isTrue);
      });

      test('marks error as non-retryable when onRetry is null', () {
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          retryable: true,
        );

        final errorInfo = errorHandler.getError('test');
        expect(errorInfo?.retryable, isFalse);
      });
    });

    group('Clear Error', () {
      test('clears specific error', () {
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
        );

        errorHandler.clearError('test');
        expect(errorHandler.hasError('test'), isFalse);
      });

      test('clears global error by default', () {
        errorHandler.handleError(error: Exception('Test'));
        errorHandler.clearError();
        expect(errorHandler.hasError(), isFalse);
      });

      test('handles clearing non-existent error', () {
        // Should not throw
        errorHandler.clearError('non_existent');
      });
    });

    group('Clear All Errors', () {
      test('clears all errors', () {
        errorHandler.handleError(error: Exception('E1'), key: 'e1');
        errorHandler.handleError(error: Exception('E2'), key: 'e2');

        errorHandler.clearAllErrors();

        expect(errorHandler.state.hasAnyErrors, isFalse);
        expect(errorHandler.hasError('e1'), isFalse);
        expect(errorHandler.hasError('e2'), isFalse);
      });

      test('does not clear history', () {
        errorHandler.handleError(error: Exception('Test'), key: 'test');
        errorHandler.clearAllErrors();

        expect(errorHandler.state.history, isNotEmpty);
      });
    });

    group('Has Error', () {
      test('returns true when error exists', () {
        errorHandler.handleError(error: Exception('Test'), key: 'test');
        expect(errorHandler.hasError('test'), isTrue);
      });

      test('returns false when error does not exist', () {
        expect(errorHandler.hasError('non_existent'), isFalse);
      });
    });

    group('Get Error', () {
      test('returns error info', () {
        final error = Exception('Test error');
        errorHandler.handleError(
          error: error,
          key: 'test',
          userMessage: 'Test message',
        );

        final errorInfo = errorHandler.getError('test');
        expect(errorInfo, isNotNull);
        expect(errorInfo!.error, equals(error));
        expect(errorInfo.message, equals('Test message'));
      });

      test('returns null for non-existent error', () {
        final errorInfo = errorHandler.getError('non_existent');
        expect(errorInfo, isNull);
      });
    });

    group('Get Error Message', () {
      test('returns error message', () {
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          userMessage: 'Test message',
        );

        expect(errorHandler.getErrorMessage('test'), equals('Test message'));
      });

      test('returns null for non-existent error', () {
        expect(errorHandler.getErrorMessage('non_existent'), isNull);
      });
    });

    group('Retry', () {
      test('retries operation successfully', () async {        var callCount = 0;
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          onRetry: () async {
            callCount++;
          },
        );

        await errorHandler.retry('test');

        // Should clear error and call retry
        expect(callCount, equals(1));
      });

      test('does not retry non-retryable error', () async {        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          retryable: false,
        );

        // Should not throw
        await errorHandler.retry('test');
      });

      test('does not retry when no callback provided', () async {        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
        );

        // Should not throw
        await errorHandler.retry('test');
      });

      test('increments retry attempts', () async {        var shouldFail = true;
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          onRetry: () async {
            if (shouldFail) {
              throw Exception('Retry failed');
            }
          },
        );

        // First retry (will fail)
        await errorHandler.retry('test');

        // Allow async retry operation to complete
        await Future.delayed(const Duration(milliseconds: 10));

        final errorInfo = errorHandler.getError('test');
        expect(errorInfo?.retryAttempts, greaterThan(0));
      });

      test('stops retrying after max attempts', () async {        var retryCount = 0;
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          onRetry: () async {
            retryCount++;
            throw Exception('Always fails');
          },
        );

        // Retry multiple times
        for (var i = 0; i < 5; i++) {
          await errorHandler.retry('test');
          // Allow retry operation and delays to complete
          await Future.delayed(const Duration(seconds: 1));
        }

        // Should stop at max attempts (3)
        expect(
            retryCount, lessThanOrEqualTo(ErrorStateHandler.maxRetryAttempts));
      });
    });

    group('Execute With Error Handling', () {
      test('executes operation successfully', () async {        final result = await errorHandler.executeWithErrorHandling(
          operation: () async => 'success',
          key: 'test',
        );

        expect(result, equals('success'));
        expect(errorHandler.hasError('test'), isFalse);
      });

      test('handles operation error', () async {        final result = await errorHandler.executeWithErrorHandling(
          operation: () async => throw Exception('Test error'),
          key: 'test',
          userMessage: 'Operation failed',
        );

        expect(result, isNull);
        expect(errorHandler.hasError('test'), isTrue);
        expect(
            errorHandler.getErrorMessage('test'), equals('Operation failed'));
      });

      test('clears existing error before executing', () async {        // Add initial error
        errorHandler.handleError(error: Exception('Old'), key: 'test');

        // Execute successfully
        await errorHandler.executeWithErrorHandling(
          operation: () async => 'success',
          key: 'test',
        );

        expect(errorHandler.hasError('test'), isFalse);
      });
    });

    group('Reset', () {
      test('resets retry attempts', () {
        errorHandler.handleError(
          error: Exception('Test'),
          key: 'test',
          onRetry: () async {},
        );

        // Manually set retry attempts
        final errorInfo = errorHandler.getError('test');
        errorHandler.handleError(
          error: errorInfo!.error,
          key: 'test',
          onRetry: errorInfo.onRetry,
        );

        errorHandler.reset('test');

        final resetError = errorHandler.getError('test');
        expect(resetError?.retryAttempts, equals(0));
      });

      test('handles reset of non-existent error', () {
        // Should not throw
        errorHandler.reset('non_existent');
      });
    });

    group('Reset All', () {
      test('resets all error retry attempts', () {
        errorHandler.handleError(
          error: Exception('E1'),
          key: 'e1',
          onRetry: () async {},
        );
        errorHandler.handleError(
          error: Exception('E2'),
          key: 'e2',
          onRetry: () async {},
        );

        errorHandler.resetAll();

        expect(errorHandler.getError('e1')?.retryAttempts, equals(0));
        expect(errorHandler.getError('e2')?.retryAttempts, equals(0));
      });
    });

    group('Error History', () {
      test('returns error history', () {
        errorHandler.handleError(error: Exception('E1'), key: 'e1');
        errorHandler.handleError(error: Exception('E2'), key: 'e2');

        final history = errorHandler.getHistory();
        expect(history, hasLength(2));
      });

      test('orders history with most recent first', () {
        errorHandler.handleError(error: Exception('E1'), key: 'e1');
        errorHandler.handleError(error: Exception('E2'), key: 'e2');

        final history = errorHandler.getHistory();
        expect(history.first.key, equals('e2'));
        expect(history.last.key, equals('e1'));
      });

      test('clears history', () {
        errorHandler.handleError(error: Exception('Test'), key: 'test');
        errorHandler.clearHistory();

        expect(errorHandler.getHistory(), isEmpty);
      });
    });

    group('ErrorState', () {
      test('hasAnyErrors returns correct value', () {
        expect(errorHandler.state.hasAnyErrors, isFalse);

        errorHandler.handleError(error: Exception('Test'), key: 'test');
        expect(errorHandler.state.hasAnyErrors, isTrue);
      });

      test('errorCount returns correct count', () {
        expect(errorHandler.state.errorCount, equals(0));

        errorHandler.handleError(error: Exception('E1'), key: 'e1');
        errorHandler.handleError(error: Exception('E2'), key: 'e2');

        expect(errorHandler.state.errorCount, equals(2));
      });
    });

    group('ErrorInfo', () {
      test('copyWith creates new instance with updated values', () {
        final original = ErrorInfo(
          error: Exception('Test'),
          message: 'Original',
          timestamp: DateTime.now(),
          key: 'test',
          retryAttempts: 0,
        );

        final copy = original.copyWith(retryAttempts: 1);

        expect(copy.retryAttempts, equals(1));
        expect(copy.message, equals('Original'));
        expect(copy.error, equals(original.error));
      });
    });
  });
}
