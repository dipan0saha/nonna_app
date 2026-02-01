import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses default size when not specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(40.0));
      expect(sizedBox.height, equals(40.0));
    });

    testWidgets('uses custom size when specified', (tester) async {
      const customSize = 60.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('uses custom color when specified', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(color: customColor),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final valueColor =
          progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(customColor));
    });

    testWidgets('uses theme primary color when color not specified',
        (tester) async {
      const primaryColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          home: const Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final valueColor =
          progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(primaryColor));
    });

    testWidgets('uses custom stroke width', (tester) async {
      const customStrokeWidth = 6.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(strokeWidth: customStrokeWidth),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progressIndicator.strokeWidth, equals(customStrokeWidth));
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(
        find.ancestor(
          of: find.byType(SizedBox),
          matching: find.byType(Center),
        ),
        findsWidgets,
      );
    });
  });

  group('LoadingOverlay', () {
    testWidgets('displays child widget', (tester) async {
      const childText = 'Child Widget';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('hides loading indicator when isLoading is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsNothing);
    });

    testWidgets('displays overlay with semi-transparent background',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(LoadingIndicator),
              matching: find.byType(Container),
            )
            .first,
      );

      final color = container.color as Color;
      expect((color.a * 255.0).round().clamp(0, 255), lessThan(255));
    });

    testWidgets('uses custom size for loading indicator', (tester) async {
      const customSize = 50.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              size: customSize,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final loadingIndicator = tester.widget<LoadingIndicator>(
        find.byType(LoadingIndicator),
      );

      expect(loadingIndicator.size, equals(customSize));
    });

    testWidgets('uses custom color for loading indicator', (tester) async {
      const customColor = Colors.green;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              color: customColor,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final loadingIndicator = tester.widget<LoadingIndicator>(
        find.byType(LoadingIndicator),
      );

      expect(loadingIndicator.color, equals(customColor));
    });

    testWidgets('uses Stack to layer overlay over child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Should have a Stack that contains both the child and the loading indicator
      final stack = find.ancestor(
        of: find.text('Content'),
        matching: find.byType(Stack),
      );
      expect(stack, findsOneWidget);
    });
  });
}
