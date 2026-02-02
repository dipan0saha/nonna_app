import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/tiles/core/models/tile_state.dart';

void main() {
  group('TileState', () {
    group('loading state', () {
      test('creates loading state correctly', () {
        const state = TileState<String>.loading();

        expect(state.isLoading, true);
        expect(state.hasError, false);
        expect(state.hasData, false);
        expect(state.isEmpty, false);
        expect(state.data, null);
        expect(state.error, null);
      });
    });

    group('error state', () {
      test('creates error state correctly', () {
        const state = TileState<String>.error('Something went wrong');

        expect(state.isLoading, false);
        expect(state.hasError, true);
        expect(state.hasData, false);
        expect(state.isEmpty, false);
        expect(state.error, 'Something went wrong');
        expect(state.data, null);
      });

      test('includes error details', () {
        const errorDetails = {'code': 500, 'message': 'Internal error'};
        const state = TileState<String>.error('Server error', errorDetails);

        expect(state.error, 'Server error');
        expect(state.errorDetails, errorDetails);
      });
    });

    group('data state', () {
      test('creates data state correctly', () {
        const state = TileState<String>.data('Hello, World!');

        expect(state.isLoading, false);
        expect(state.hasError, false);
        expect(state.hasData, true);
        expect(state.isEmpty, false);
        expect(state.data, 'Hello, World!');
        expect(state.error, null);
      });

      test('works with different data types', () {
        const stringState = TileState<String>.data('text');
        const intState = TileState<int>.data(42);
        const listState = TileState<List<String>>.data(['a', 'b', 'c']);

        expect(stringState.data, 'text');
        expect(intState.data, 42);
        expect(listState.data, ['a', 'b', 'c']);
      });
    });

    group('empty state', () {
      test('creates empty state correctly', () {
        const state = TileState<String>.empty();

        expect(state.isLoading, false);
        expect(state.hasError, false);
        expect(state.hasData, false);
        expect(state.isEmpty, true);
        expect(state.data, null);
        expect(state.error, null);
      });
    });

    group('when', () {
      test('calls loading callback for loading state', () {
        const state = TileState<String>.loading();
        var called = false;

        state.when(
          loading: () {
            called = true;
            return 'loading';
          },
          error: (_, __) => 'error',
          data: (_) => 'data',
          empty: () => 'empty',
        );

        expect(called, true);
      });

      test('calls error callback for error state', () {
        const state = TileState<String>.error('Error message', {'code': 500});
        String? receivedError;
        dynamic receivedDetails;

        state.when(
          loading: () => 'loading',
          error: (error, details) {
            receivedError = error;
            receivedDetails = details;
            return 'error';
          },
          data: (_) => 'data',
          empty: () => 'empty',
        );

        expect(receivedError, 'Error message');
        expect(receivedDetails, {'code': 500});
      });

      test('calls data callback for data state', () {
        const state = TileState<String>.data('Hello');
        String? receivedData;

        state.when(
          loading: () => 'loading',
          error: (_, __) => 'error',
          data: (data) {
            receivedData = data;
            return 'data';
          },
          empty: () => 'empty',
        );

        expect(receivedData, 'Hello');
      });

      test('calls empty callback for empty state', () {
        const state = TileState<String>.empty();
        var called = false;

        state.when(
          loading: () => 'loading',
          error: (_, __) => 'error',
          data: (_) => 'data',
          empty: () {
            called = true;
            return 'empty';
          },
        );

        expect(called, true);
      });
    });

    group('maybeWhen', () {
      test('calls specific callback if provided', () {
        const state = TileState<String>.loading();
        var loadingCalled = false;

        state.maybeWhen(
          loading: () {
            loadingCalled = true;
            return 'loading';
          },
          orElse: () => 'else',
        );

        expect(loadingCalled, true);
      });

      test('calls orElse if specific callback not provided', () {
        const state = TileState<String>.loading();
        var elseCalled = false;

        state.maybeWhen(
          data: (_) => 'data',
          orElse: () {
            elseCalled = true;
            return 'else';
          },
        );

        expect(elseCalled, true);
      });
    });

    group('equality', () {
      test('equal loading states are equal', () {
        const state1 = TileState<String>.loading();
        const state2 = TileState<String>.loading();

        expect(state1, state2);
        expect(state1.hashCode, state2.hashCode);
      });

      test('equal data states are equal', () {
        const state1 = TileState<String>.data('Hello');
        const state2 = TileState<String>.data('Hello');

        expect(state1, state2);
        expect(state1.hashCode, state2.hashCode);
      });

      test('different states are not equal', () {
        const state1 = TileState<String>.loading();
        const state2 = TileState<String>.data('Hello');

        expect(state1, isNot(state2));
      });

      test('error states with same error are equal', () {
        const state1 = TileState<String>.error('Error');
        const state2 = TileState<String>.error('Error');

        expect(state1, state2);
      });
    });

    group('toString', () {
      test('returns correct string for loading state', () {
        const state = TileState<String>.loading();
        expect(state.toString(), 'TileState.loading()');
      });

      test('returns correct string for error state', () {
        const state = TileState<String>.error('Error message');
        expect(state.toString(), 'TileState.error(Error message)');
      });

      test('returns correct string for data state', () {
        const state = TileState<String>.data('Hello');
        expect(state.toString(), 'TileState.data(Hello)');
      });

      test('returns correct string for empty state', () {
        const state = TileState<String>.empty();
        expect(state.toString(), 'TileState.empty()');
      });
    });
  });
}
