import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/mixins/loading_mixin.dart';

// Test widget that uses LoadingMixin
class TestWidget extends StatefulWidget {
  final Function()? onButtonPressed;

  const TestWidget({super.key, this.onButtonPressed});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> with LoadingMixin {
  String? result;
  String? errorMessage;

  Future<String> asyncOperation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'success';
  }

  Future<String> failingOperation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    throw Exception('Test error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Loading: $isLoading'),
          Text('Result: ${result ?? "none"}'),
          Text('Error: ${errorMessage ?? "none"}'),
          ElevatedButton(
            key: const Key('test_button'),
            onPressed: widget.onButtonPressed,
            child: const Text('Test'),
          ),
          buildLoadingButton(
            key: const Key('loading_button'),
            onPressed: () {},
            child: const Text('Loading Button'),
          ),
          buildOperationButton(
            key: const Key('operation_button'),
            operation: 'test_operation',
            onPressed: () {},
            child: const Text('Operation Button'),
          ),
          buildWithLoading(
            child: const Text('Content'),
          ),
          buildLoadingAware(
            child: const Text('Aware Content'),
          ),
        ],
      ),
    );
  }
}

/// Helper to wrap test widget in MaterialApp
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('LoadingMixin', () {
    testWidgets('initializes with isLoading false', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));

      expect(find.text('Loading: false'), findsOneWidget);
    });

    testWidgets('sets and gets loading state', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(TestWidget(
        onButtonPressed: () {
          state.isLoading = true;
        },
      )));

      state = tester.state(find.byType(TestWidget));

      expect(state.isLoading, false);

      await tester.tap(find.byKey(const Key('test_button')));
      await tester.pump();

      expect(state.isLoading, true);
      expect(find.text('Loading: true'), findsOneWidget);
    });

    testWidgets('handles operation-specific loading state', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      expect(state.isLoadingFor('operation1'), false);
      expect(state.isLoadingFor('operation2'), false);

      state.setLoadingFor('operation1', true);
      await tester.pump();

      expect(state.isLoadingFor('operation1'), true);
      expect(state.isLoadingFor('operation2'), false);

      state.setLoadingFor('operation2', true);
      await tester.pump();

      expect(state.isLoadingFor('operation1'), true);
      expect(state.isLoadingFor('operation2'), true);
    });

    testWidgets('clears loading state for operation', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.setLoadingFor('operation1', true);
      await tester.pump();
      expect(state.isLoadingFor('operation1'), true);

      state.clearLoadingFor('operation1');
      await tester.pump();
      expect(state.isLoadingFor('operation1'), false);
    });

    testWidgets('clears all loading states', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.isLoading = true;
      state.setLoadingFor('op1', true);
      state.setLoadingFor('op2', true);
      await tester.pump();

      expect(state.isLoading, true);
      expect(state.isLoadingFor('op1'), true);
      expect(state.isLoadingFor('op2'), true);

      state.clearAllLoading();
      await tester.pump();

      expect(state.isLoading, false);
      expect(state.isLoadingFor('op1'), false);
      expect(state.isLoadingFor('op2'), false);
    });

    testWidgets('withLoading executes async operation', (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        expect(state.isLoading, false);

        final future = state.withLoading(() => state.asyncOperation());
        await tester.pump();

        expect(state.isLoading, true);

        final result = await future;
        await tester.pump();

        expect(state.isLoading, false);
        expect(result, 'success');
      });
    });

    testWidgets('withLoading prevents concurrent execution', (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        final future1 = state.withLoading(() => state.asyncOperation());
        await tester.pump();

        expect(state.isLoading, true);

        // Try to execute while already loading
        final future2 = state.withLoading(() => state.asyncOperation());

        expect(await future2, null); // Should return null
        expect(await future1, 'success');
        await tester.pump();
      });
    });

    testWidgets('withLoadingFor executes with operation key', (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        expect(state.isLoadingFor('test_op'), false);

        final future =
            state.withLoadingFor('test_op', () => state.asyncOperation());
        await tester.pump();

        expect(state.isLoadingFor('test_op'), true);

        final result = await future;
        await tester.pump();

        expect(state.isLoadingFor('test_op'), false);
        expect(result, 'success');
      });
    });

    testWidgets('withLoadingFor prevents concurrent execution for same key',
        (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        final future1 =
            state.withLoadingFor('test_op', () => state.asyncOperation());
        await tester.pump();

        expect(state.isLoadingFor('test_op'), true);

        // Try to execute with same key
        final future2 =
            state.withLoadingFor('test_op', () => state.asyncOperation());

        expect(await future2, null);
        expect(await future1, 'success');
        await tester.pump();
      });
    });

    testWidgets('withLoadingFor allows different keys concurrently',
        (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        final future1 =
            state.withLoadingFor('op1', () => state.asyncOperation());
        final future2 =
            state.withLoadingFor('op2', () => state.asyncOperation());
        await tester.pump();

        expect(state.isLoadingFor('op1'), true);
        expect(state.isLoadingFor('op2'), true);

        expect(await future1, 'success');
        expect(await future2, 'success');
        await tester.pump();
      });
    });

    testWidgets('withLoadingAndError handles errors with callback',
        (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;
        Object? capturedError;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        final result = await state.withLoadingAndError(
          () => state.failingOperation(),
          onError: (error) {
            capturedError = error;
          },
        );

        await tester.pump();

        expect(result, null);
        expect(capturedError, isA<Exception>());
        expect(capturedError.toString(), contains('Test error'));
      });
    });

    testWidgets('withLoadingAndError shows default error message',
        (tester) async {
      await tester.runAsync(() async {
        late _TestWidgetState state;

        await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
        state = tester.state(find.byType(TestWidget));

        await state.withLoadingAndError(() => state.failingOperation());
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('An error occurred'), findsOneWidget);
      });
    });

    testWidgets('buildWithLoading shows overlay when loading', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      // Not loading - no overlay
      expect(find.byType(CircularProgressIndicator), findsNothing);

      state.isLoading = true;
      await tester.pump();

      // Loading - shows overlay
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('buildLoadingAware shows loading indicator when loading',
        (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      expect(find.text('Aware Content'), findsOneWidget);

      state.isLoading = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('buildLoadingButton disables and shows indicator when loading',
        (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('loading_button')),
      );

      expect(button.onPressed, isNotNull);

      state.isLoading = true;
      await tester.pump();

      final loadingButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('loading_button')),
      );

      expect(loadingButton.onPressed, isNull);
    });

    testWidgets('buildOperationButton uses operation-specific loading',
        (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('operation_button')),
      );

      expect(button.onPressed, isNotNull);

      state.setLoadingFor('test_operation', true);
      await tester.pump();

      final loadingButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('operation_button')),
      );

      expect(loadingButton.onPressed, isNull);

      // Global loading should not affect it
      state.setLoadingFor('test_operation', false);
      state.isLoading = true;
      await tester.pump();

      final normalButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('operation_button')),
      );

      expect(normalButton.onPressed, isNotNull);
    });

    testWidgets('executeIfNotLoading executes when not loading',
        (tester) async {
      late _TestWidgetState state;
      var executed = false;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.executeIfNotLoading(() {
        executed = true;
      });

      expect(executed, true);
    });

    testWidgets('executeIfNotLoading does not execute when loading',
        (tester) async {
      late _TestWidgetState state;
      var executed = false;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.isLoading = true;
      await tester.pump();

      state.executeIfNotLoading(() {
        executed = true;
      });

      expect(executed, false);
    });

    testWidgets('executeOperationIfNotLoading works with operation key',
        (tester) async {
      late _TestWidgetState state;
      var executed = false;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.executeOperationIfNotLoading('my_op', () {
        executed = true;
      });

      expect(executed, true);

      executed = false;
      state.setLoadingFor('my_op', true);
      await tester.pump();

      state.executeOperationIfNotLoading('my_op', () {
        executed = true;
      });

      expect(executed, false);
    });

    testWidgets('showLoadingDialog displays dialog', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.showLoadingDialog(message: 'Please wait...');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hideLoadingDialog closes dialog', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.showLoadingDialog(message: 'Loading...');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AlertDialog), findsOneWidget);

      state.hideLoadingDialog();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('loading dialog is not dismissible', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      state.showLoadingDialog();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AlertDialog), findsOneWidget);

      // Try to dismiss by tapping outside
      await tester.tapAt(Offset.zero);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog should still be visible
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('properly updates state when mounted', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      expect(state.mounted, true);

      state.isLoading = true;
      await tester.pump();

      expect(state.isLoading, true);
      expect(find.text('Loading: true'), findsOneWidget);
    });

    testWidgets('does not update state when not mounted', (tester) async {
      late _TestWidgetState state;

      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));
      state = tester.state(find.byType(TestWidget));

      // Remove the widget
      await tester.pumpWidget(const SizedBox());

      expect(state.mounted, false);

      // Should not throw
      expect(() => state.isLoading = true, returnsNormally);
    });

    testWidgets('cleans up loading states on dispose', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const TestWidget()));

      final state = tester.state<_TestWidgetState>(find.byType(TestWidget));
      state.setLoadingFor('op1', true);
      state.setLoadingFor('op2', true);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Should not throw
      expect(() => state.dispose(), returnsNormally);
    });
  });
}
