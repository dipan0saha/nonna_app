import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/providers/loading_state_handler.dart';

void main() {
  group('LoadingStateHandler', () {
    late LoadingStateHandler loadingHandler;

    setUp(() {
      loadingHandler = LoadingStateHandler();
    });

    tearDown(() {
      loadingHandler.dispose();
    });

    group('Initial State', () {
      test('starts with no loading operations', () {
        expect(loadingHandler.state.isAnyLoading, isFalse);
        expect(loadingHandler.state.operationCount, equals(0));
        expect(loadingHandler.state.operations, isEmpty);
      });
    });

    group('Start Loading', () {
      test('starts loading for a specific key', () {
        loadingHandler.startLoading('test_operation');

        expect(loadingHandler.isLoading('test_operation'), isTrue);
        expect(loadingHandler.state.isAnyLoading, isTrue);
        expect(loadingHandler.state.operationCount, equals(1));
      });

      test('stores loading message', () {
        loadingHandler.startLoading(
          'test_operation',
          message: 'Loading data...',
        );

        expect(loadingHandler.getMessage('test_operation'),
            equals('Loading data...'));
      });

      test('enables progress tracking when requested', () {
        loadingHandler.startLoading(
          'test_operation',
          showProgress: true,
        );

        final operation = loadingHandler.getOperation('test_operation');
        expect(operation?.showProgress, isTrue);
        expect(operation?.progress, equals(0.0));
      });

      test('handles multiple concurrent operations', () {
        loadingHandler.startLoading('operation1');
        loadingHandler.startLoading('operation2');
        loadingHandler.startLoading('operation3');

        expect(loadingHandler.state.operationCount, equals(3));
        expect(loadingHandler.isLoading('operation1'), isTrue);
        expect(loadingHandler.isLoading('operation2'), isTrue);
        expect(loadingHandler.isLoading('operation3'), isTrue);
      });

      test('sets timeout when provided', () async {
        loadingHandler.startLoading(
          'test_operation',
          timeout: const Duration(milliseconds: 100),
        );

        expect(loadingHandler.isLoading('test_operation'), isTrue);

        // Wait for timeout
        await Future.delayed(const Duration(milliseconds: 150));

        expect(loadingHandler.isLoading('test_operation'), isFalse);
      });
    });

    group('Stop Loading', () {
      test('stops loading for a specific key', () {
        loadingHandler.startLoading('test_operation');
        loadingHandler.stopLoading('test_operation');

        expect(loadingHandler.isLoading('test_operation'), isFalse);
      });

      test('handles stopping non-existent operation', () {
        // Should not throw
        loadingHandler.stopLoading('non_existent');
      });

      test('cancels timeout timer', () async {
        loadingHandler.startLoading(
          'test_operation',
          timeout: const Duration(milliseconds: 200),
        );

        // Stop before timeout
        await Future.delayed(const Duration(milliseconds: 50));
        loadingHandler.stopLoading('test_operation');

        expect(loadingHandler.isLoading('test_operation'), isFalse);

        // Wait past timeout
        await Future.delayed(const Duration(milliseconds: 200));

        // Should still be stopped (timer was cancelled)
        expect(loadingHandler.isLoading('test_operation'), isFalse);
      });
    });

    group('Stop All Loading', () {
      test('stops all loading operations', () {
        loadingHandler.startLoading('operation1');
        loadingHandler.startLoading('operation2');
        loadingHandler.startLoading('operation3');

        loadingHandler.stopAllLoading();

        expect(loadingHandler.state.isAnyLoading, isFalse);
        expect(loadingHandler.state.operationCount, equals(0));
      });

      test('cancels all timeout timers', () async {
        loadingHandler.startLoading(
          'operation1',
          timeout: const Duration(milliseconds: 200),
        );
        loadingHandler.startLoading(
          'operation2',
          timeout: const Duration(milliseconds: 200),
        );

        await Future.delayed(const Duration(milliseconds: 50));
        loadingHandler.stopAllLoading();

        // Wait past timeout
        await Future.delayed(const Duration(milliseconds: 200));

        // Should still be stopped
        expect(loadingHandler.isLoading('operation1'), isFalse);
        expect(loadingHandler.isLoading('operation2'), isFalse);
      });
    });

    group('Update Progress', () {
      test('updates progress value', () {
        loadingHandler.startLoading('test_operation', showProgress: true);
        loadingHandler.updateProgress('test_operation', 0.5);

        expect(loadingHandler.getProgress('test_operation'), equals(0.5));
      });

      test('clamps progress between 0 and 1', () {
        loadingHandler.startLoading('test_operation', showProgress: true);

        loadingHandler.updateProgress('test_operation', -0.5);
        expect(loadingHandler.getProgress('test_operation'), equals(0.0));

        loadingHandler.updateProgress('test_operation', 1.5);
        expect(loadingHandler.getProgress('test_operation'), equals(1.0));
      });

      test('updates progress message', () {
        loadingHandler.startLoading('test_operation', showProgress: true);
        loadingHandler.updateProgress(
          'test_operation',
          0.5,
          message: '50% complete',
        );

        expect(loadingHandler.getMessage('test_operation'),
            equals('50% complete'));
      });

      test('handles updating non-existent operation', () {
        // Should not throw
        loadingHandler.updateProgress('non_existent', 0.5);
      });
    });

    group('Update Message', () {
      test('updates loading message', () {
        loadingHandler.startLoading('test_operation', message: 'Loading...');
        loadingHandler.updateMessage('test_operation', 'Almost done...');

        expect(loadingHandler.getMessage('test_operation'),
            equals('Almost done...'));
      });

      test('handles updating non-existent operation', () {
        // Should not throw
        loadingHandler.updateMessage('non_existent', 'Test');
      });
    });

    group('Query Methods', () {
      test('isLoading returns correct value', () {
        expect(loadingHandler.isLoading('test'), isFalse);

        loadingHandler.startLoading('test');
        expect(loadingHandler.isLoading('test'), isTrue);

        loadingHandler.stopLoading('test');
        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('isAnyLoading returns correct value', () {
        expect(loadingHandler.isAnyLoading, isFalse);

        loadingHandler.startLoading('test');
        expect(loadingHandler.isAnyLoading, isTrue);

        loadingHandler.stopLoading('test');
        expect(loadingHandler.isAnyLoading, isFalse);
      });

      test('getOperation returns operation info', () {
        loadingHandler.startLoading('test', message: 'Loading...');

        final operation = loadingHandler.getOperation('test');
        expect(operation, isNotNull);
        expect(operation!.key, equals('test'));
        expect(operation.message, equals('Loading...'));
      });

      test('getProgress returns progress value', () {
        loadingHandler.startLoading('test', showProgress: true);
        loadingHandler.updateProgress('test', 0.75);

        expect(loadingHandler.getProgress('test'), equals(0.75));
      });

      test('getProgress returns null for non-existent operation', () {
        expect(loadingHandler.getProgress('non_existent'), isNull);
      });

      test('getMessage returns message', () {
        loadingHandler.startLoading('test', message: 'Loading...');
        expect(loadingHandler.getMessage('test'), equals('Loading...'));
      });

      test('getMessage returns null for non-existent operation', () {
        expect(loadingHandler.getMessage('non_existent'), isNull);
      });

      test('getElapsedTime returns duration', () {
        loadingHandler.startLoading('test');

        final elapsed = loadingHandler.getElapsedTime('test');
        expect(elapsed, isNotNull);
        expect(elapsed!.inMilliseconds, greaterThanOrEqualTo(0));
      });

      test('getElapsedTime returns null for non-existent operation', () {
        expect(loadingHandler.getElapsedTime('non_existent'), isNull);
      });
    });

    group('Execute With Loading', () {
      test('executes operation with loading state', () async {
        var executed = false;

        final result = await loadingHandler.executeWithLoading(
          operation: () async {
            executed = true;
            return 'success';
          },
          key: 'test',
        );

        expect(executed, isTrue);
        expect(result, equals('success'));
        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('shows loading during operation', () async {
        var wasLoading = false;

        await loadingHandler.executeWithLoading(
          operation: () async {
            wasLoading = loadingHandler.isLoading('test');
            return 'done';
          },
          key: 'test',
        );

        expect(wasLoading, isTrue);
      });

      test('stops loading after operation completes', () async {
        await loadingHandler.executeWithLoading(
          operation: () async => 'done',
          key: 'test',
        );

        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('stops loading even if operation throws', () async {
        try {
          await loadingHandler.executeWithLoading(
            operation: () async => throw Exception('Test error'),
            key: 'test',
          );
        } catch (_) {
          // Expected
        }

        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('respects timeout', () async {
        await loadingHandler.executeWithLoading(
          operation: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return 'done';
          },
          key: 'test',
          timeout: const Duration(milliseconds: 100),
        );

        // Operation should complete but loading should timeout
        await Future.delayed(const Duration(milliseconds: 150));
        expect(loadingHandler.isLoading('test'), isFalse);
      });
    });

    group('Execute With Progress', () {
      test('executes operation with progress updates', () async {
        final progressValues = <double>[];

        await loadingHandler.executeWithProgress(
          operation: (onProgress) async {
            onProgress(0.25);
            progressValues.add(loadingHandler.getProgress('test')!);

            onProgress(0.50);
            progressValues.add(loadingHandler.getProgress('test')!);

            onProgress(0.75);
            progressValues.add(loadingHandler.getProgress('test')!);

            return 'done';
          },
          key: 'test',
        );

        expect(progressValues, equals([0.25, 0.50, 0.75]));
      });
    });

    group('Execute Multiple', () {
      test('executes multiple operations concurrently', () async {
        final results = await loadingHandler.executeMultiple(
          operations: {
            'op1': () async => 'result1',
            'op2': () async => 'result2',
            'op3': () async => 'result3',
          },
        );

        expect(results['op1'], equals('result1'));
        expect(results['op2'], equals('result2'));
        expect(results['op3'], equals('result3'));

        // All should be stopped
        expect(loadingHandler.isLoading('op1'), isFalse);
        expect(loadingHandler.isLoading('op2'), isFalse);
        expect(loadingHandler.isLoading('op3'), isFalse);
      });

      test('handles errors in individual operations', () async {
        final results = await loadingHandler.executeMultiple(
          operations: {
            'op1': () async => 'success',
            'op2': () async => throw Exception('Error'),
            'op3': () async => 'success',
          },
        );

        expect(results['op1'], equals('success'));
        expect(results['op2'], isNull);
        expect(results['op3'], equals('success'));
      });
    });

    group('Cancellation', () {
      test('cancels loading operation', () {
        loadingHandler.startLoading('test');
        loadingHandler.cancel('test');

        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('cancels all loading operations', () {
        loadingHandler.startLoading('op1');
        loadingHandler.startLoading('op2');
        loadingHandler.cancelAll();

        expect(loadingHandler.state.isAnyLoading, isFalse);
      });
    });

    group('Skeleton Screen', () {
      test('enables skeleton screen', () {
        loadingHandler.enableSkeleton('test');
        expect(loadingHandler.isLoading('test'), isTrue);
      });

      test('disables skeleton screen', () {
        loadingHandler.enableSkeleton('test');
        loadingHandler.disableSkeleton('test');
        expect(loadingHandler.isLoading('test'), isFalse);
      });
    });

    group('LoadingState', () {
      test('operationKeys returns all keys', () {
        loadingHandler.startLoading('op1');
        loadingHandler.startLoading('op2');

        final keys = loadingHandler.state.operationKeys;
        expect(keys, containsAll(['op1', 'op2']));
      });
    });

    group('LoadingOperation', () {
      test('elapsed returns duration since start', () async {
        loadingHandler.startLoading('test');

        await Future.delayed(const Duration(milliseconds: 50));

        final operation = loadingHandler.getOperation('test');
        expect(operation!.elapsed.inMilliseconds, greaterThanOrEqualTo(50));
      });

      test('progressPercent converts to percentage', () {
        loadingHandler.startLoading('test', showProgress: true);
        loadingHandler.updateProgress('test', 0.45);

        final operation = loadingHandler.getOperation('test');
        expect(operation!.progressPercent, equals(45));
      });

      test('copyWith creates new instance with updated values', () {
        final original = LoadingOperation(
          key: 'test',
          isLoading: true,
          message: 'Original',
          showProgress: false,
          progress: 0.0,
          startTime: DateTime.now(),
        );

        final copy = original.copyWith(
          message: 'Updated',
          progress: 0.5,
        );

        expect(copy.message, equals('Updated'));
        expect(copy.progress, equals(0.5));
        expect(copy.key, equals('test'));
      });
    });

    group('Dispose', () {
      test('cancels all timers on dispose', () async {
        loadingHandler.startLoading(
          'test',
          timeout: const Duration(milliseconds: 200),
        );

        loadingHandler.dispose();

        // Wait past timeout
        await Future.delayed(const Duration(milliseconds: 250));

        // Should not crash or throw
      });
    });

    group('Edge Cases', () {
      test('handles rapid start/stop cycles', () {
        for (var i = 0; i < 10; i++) {
          loadingHandler.startLoading('test');
          loadingHandler.stopLoading('test');
        }

        expect(loadingHandler.isLoading('test'), isFalse);
      });

      test('handles updating progress before starting', () {
        // Should not throw
        loadingHandler.updateProgress('test', 0.5);
      });

      test('handles stopping before starting', () {
        // Should not throw
        loadingHandler.stopLoading('test');
      });

      test('handles zero timeout', () {
        loadingHandler.startLoading(
          'test',
          timeout: Duration.zero,
        );

        // Should immediately timeout
        expect(loadingHandler.isLoading('test'), isFalse);
      });
    });
  });
}
