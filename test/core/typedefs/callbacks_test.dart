import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/typedefs/callbacks.dart';

void main() {
  group('Callbacks TypeDef', () {
    group('VoidCallback', () {
      test('accepts no parameters and returns void', () {
        VoidCallback callback = () {};
        expect(() => callback(), returnsNormally);
      });

      test('can be assigned to function with no parameters', () {
        void testFunction() {}
        VoidCallback callback = testFunction;
        expect(() => callback(), returnsNormally);
      });
    });

    group('ValueCallback', () {
      test('accepts single parameter and returns void', () {
        ValueCallback<int> callback = (value) {
          expect(value, 42);
        };
        callback(42);
      });

      test('works with different types', () {
        ValueCallback<String> stringCallback = (value) {
          expect(value, 'test');
        };
        stringCallback('test');

        ValueCallback<bool> boolCallback = (value) {
          expect(value, true);
        };
        boolCallback(true);
      });

      test('can capture and modify external state', () {
        int capturedValue = 0;
        ValueCallback<int> callback = (value) {
          capturedValue = value;
        };
        callback(100);
        expect(capturedValue, 100);
      });
    });

    group('TwoValueCallback', () {
      test('accepts two parameters and returns void', () {
        TwoValueCallback<int, String> callback = (value1, value2) {
          expect(value1, 42);
          expect(value2, 'test');
        };
        callback(42, 'test');
      });

      test('works with same types', () {
        TwoValueCallback<int, int> callback = (value1, value2) {
          expect(value1 + value2, 10);
        };
        callback(4, 6);
      });
    });

    group('ThreeValueCallback', () {
      test('accepts three parameters and returns void', () {
        ThreeValueCallback<int, String, bool> callback =
            (value1, value2, value3) {
          expect(value1, 42);
          expect(value2, 'test');
          expect(value3, true);
        };
        callback(42, 'test', true);
      });

      test('can perform operations on all parameters', () {
        int sum = 0;
        ThreeValueCallback<int, int, int> callback = (v1, v2, v3) {
          sum = v1 + v2 + v3;
        };
        callback(1, 2, 3);
        expect(sum, 6);
      });
    });

    group('BoolCallback', () {
      test('accepts no parameters and returns boolean', () {
        BoolCallback callback = () => true;
        expect(callback(), true);
      });

      test('can return false', () {
        BoolCallback callback = () => false;
        expect(callback(), false);
      });

      test('can use logic', () {
        bool condition = true;
        BoolCallback callback = () => condition;
        expect(callback(), true);

        condition = false;
        expect(callback(), false);
      });
    });

    group('BoolValueCallback', () {
      test('accepts parameter and returns boolean', () {
        BoolValueCallback<int> callback = (value) => value > 0;
        expect(callback(5), true);
        expect(callback(-5), false);
      });

      test('works with different types', () {
        BoolValueCallback<String> callback = (value) => value.isNotEmpty;
        expect(callback('test'), true);
        expect(callback(''), false);
      });
    });

    group('ValueGetter', () {
      test('accepts no parameters and returns value', () {
        ValueGetter<int> getter = () => 42;
        expect(getter(), 42);
      });

      test('works with different return types', () {
        ValueGetter<String> stringGetter = () => 'test';
        expect(stringGetter(), 'test');

        ValueGetter<List<int>> listGetter = () => [1, 2, 3];
        expect(listGetter(), [1, 2, 3]);
      });

      test('can access external state', () {
        int value = 100;
        ValueGetter<int> getter = () => value;
        expect(getter(), 100);

        value = 200;
        expect(getter(), 200);
      });
    });

    group('ValueTransformer', () {
      test('accepts parameter and returns transformed value', () {
        ValueTransformer<int, String> transformer = (value) => value.toString();
        expect(transformer(42), '42');
      });

      test('can transform between different types', () {
        ValueTransformer<String, int> transformer = (value) => value.length;
        expect(transformer('hello'), 5);
      });

      test('can apply complex transformations', () {
        ValueTransformer<List<int>, int> transformer =
            (list) => list.fold(0, (sum, val) => sum + val);
        expect(transformer([1, 2, 3, 4]), 10);
      });
    });

    group('AsyncCallback', () {
      test('accepts no parameters and returns Future<void>', () async {
        AsyncCallback callback = () async {};
        await expectLater(callback(), completes);
      });

      test('can perform async operations', () async {
        bool executed = false;
        AsyncCallback callback = () async {
          await Future.delayed(Duration(milliseconds: 10));
          executed = true;
        };
        await callback();
        expect(executed, true);
      });
    });

    group('AsyncValueCallback', () {
      test('accepts parameter and returns Future<void>', () async {
        AsyncValueCallback<int> callback = (value) async {
          expect(value, 42);
        };
        await callback(42);
      });

      test('can perform async operations with parameter', () async {
        int capturedValue = 0;
        AsyncValueCallback<int> callback = (value) async {
          await Future.delayed(Duration(milliseconds: 10));
          capturedValue = value;
        };
        await callback(100);
        expect(capturedValue, 100);
      });
    });

    group('AsyncValueGetter', () {
      test('accepts no parameters and returns Future<T>', () async {
        AsyncValueGetter<int> getter = () async => 42;
        final result = await getter();
        expect(result, 42);
      });

      test('can perform async operations', () async {
        AsyncValueGetter<String> getter = () async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'test';
        };
        final result = await getter();
        expect(result, 'test');
      });
    });

    group('AsyncValueTransformer', () {
      test('accepts parameter and returns Future<R>', () async {
        AsyncValueTransformer<int, String> transformer =
            (value) async => value.toString();
        final result = await transformer(42);
        expect(result, '42');
      });

      test('can perform complex async transformations', () async {
        AsyncValueTransformer<String, int> transformer = (value) async {
          await Future.delayed(Duration(milliseconds: 10));
          return value.length;
        };
        final result = await transformer('hello');
        expect(result, 5);
      });
    });

    group('ErrorCallback', () {
      test('accepts error and stackTrace parameters', () {
        ErrorCallback callback = (error, stackTrace) {
          expect(error, isA<Exception>());
          expect(stackTrace, isNull);
        };
        callback(Exception('test'), null);
      });

      test('can handle errors with stackTrace', () {
        ErrorCallback callback = (error, stackTrace) {
          expect(error.toString(), contains('test error'));
          expect(stackTrace, isNotNull);
        };

        try {
          throw Exception('test error');
        } catch (e, stackTrace) {
          callback(e, stackTrace);
        }
      });

      test('can log or store errors', () {
        Object? capturedError;
        StackTrace? capturedStackTrace;

        ErrorCallback callback = (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
        };

        final testError = Exception('test');
        callback(testError, null);

        expect(capturedError, testError);
        expect(capturedStackTrace, isNull);
      });
    });

    group('SuccessCallback', () {
      test('accepts no parameters and returns void', () {
        SuccessCallback callback = () {};
        expect(() => callback(), returnsNormally);
      });

      test('can update state on success', () {
        bool success = false;
        SuccessCallback callback = () {
          success = true;
        };
        callback();
        expect(success, true);
      });
    });

    group('ConfirmCallback', () {
      test('accepts no parameters and returns Future<bool>', () async {
        ConfirmCallback callback = () async => true;
        final result = await callback();
        expect(result, true);
      });

      test('can simulate user confirmation', () async {
        ConfirmCallback confirmCallback = () async {
          await Future.delayed(Duration(milliseconds: 10));
          return true;
        };

        ConfirmCallback cancelCallback = () async {
          await Future.delayed(Duration(milliseconds: 10));
          return false;
        };

        expect(await confirmCallback(), true);
        expect(await cancelCallback(), false);
      });
    });

    group('real-world usage examples', () {
      test('button onPressed uses VoidCallback', () {
        int clickCount = 0;
        VoidCallback onPressed = () {
          clickCount++;
        };

        // Simulate button clicks
        onPressed();
        onPressed();
        onPressed();

        expect(clickCount, 3);
      });

      test('form validation uses BoolValueCallback', () {
        BoolValueCallback<String> emailValidator = (email) {
          return email.contains('@') && email.contains('.');
        };

        expect(emailValidator('test@example.com'), true);
        expect(emailValidator('invalid-email'), false);
      });

      test('async data fetcher uses AsyncValueGetter', () async {
        AsyncValueGetter<Map<String, dynamic>> fetchUser = () async {
          await Future.delayed(Duration(milliseconds: 10));
          return {'id': 1, 'name': 'Test User'};
        };

        final user = await fetchUser();
        expect(user['id'], 1);
        expect(user['name'], 'Test User');
      });

      test('error handler uses ErrorCallback', () {
        Object? lastError;

        ErrorCallback errorHandler = (error, stackTrace) {
          lastError = error;
          // In real app, might log to analytics or show error message
        };

        try {
          throw Exception('Network error');
        } catch (e, stackTrace) {
          errorHandler(e, stackTrace);
        }

        expect(lastError.toString(), contains('Network error'));
      });

      test('confirmation dialog uses ConfirmCallback', () async {
        ConfirmCallback showDeleteConfirmation = () async {
          // In real app, would show dialog
          await Future.delayed(Duration(milliseconds: 10));
          return true; // User confirmed
        };

        bool deleted = false;
        final confirmed = await showDeleteConfirmation();
        if (confirmed) {
          deleted = true;
        }

        expect(deleted, true);
      });

      test('data transformer pipeline', () {
        // Transform string to uppercase
        ValueTransformer<String, String> toUpperCase =
            (value) => value.toUpperCase();

        // Transform string to length
        ValueTransformer<String, int> getLength = (value) => value.length;

        // Chain transformations
        final result1 = toUpperCase('hello');
        expect(result1, 'HELLO');

        final result2 = getLength(result1);
        expect(result2, 5);
      });

      test('async pipeline with error handling', () async {
        bool errorHandled = false;
        String? result;

        AsyncValueGetter<String> fetchData = () async {
          await Future.delayed(Duration(milliseconds: 10));
          throw Exception('Network error');
        };

        ErrorCallback handleError = (error, stackTrace) {
          errorHandled = true;
        };

        SuccessCallback onSuccess = () {
          // This shouldn't be called in this test
        };

        try {
          result = await fetchData();
          onSuccess();
        } catch (e, stackTrace) {
          handleError(e, stackTrace);
        }

        expect(errorHandled, true);
        expect(result, isNull);
      });
    });

    group('type safety', () {
      test('compiler enforces correct types for ValueCallback', () {
        ValueCallback<int> intCallback = (int value) {};
        intCallback(42);
        // intCallback("string"); // This would be a compile error
      });

      test('compiler enforces correct types for ValueTransformer', () {
        ValueTransformer<int, String> transformer = (int value) => '$value';
        final result = transformer(42);
        expect(result, isA<String>());
      });

      test('async types are properly enforced', () async {
        AsyncValueGetter<int> getter = () async => 42;
        final result = await getter();
        expect(result, isA<int>());
      });
    });

    group('null safety', () {
      test('handles nullable return values', () {
        ValueGetter<String?> getter = () => null;
        expect(getter(), isNull);
      });

      test('handles nullable parameters', () {
        ValueCallback<String?> callback = (value) {
          expect(value, isNull);
        };
        callback(null);
      });

      test('ErrorCallback handles nullable stackTrace', () {
        ErrorCallback callback = (error, stackTrace) {
          expect(error, isNotNull);
          expect(stackTrace, isNull);
        };
        callback(Exception('test'), null);
      });
    });
  });
}
