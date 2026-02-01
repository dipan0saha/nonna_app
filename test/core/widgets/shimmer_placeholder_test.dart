import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';

void main() {
  group('ShimmerPlaceholder', () {
    testWidgets('renders with specified width and height', (tester) async {
      const width = 100.0;
      const height = 50.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(
              width: width,
              height: height,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerPlaceholder),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, equals(width));
      expect(container.constraints?.maxHeight, equals(height));
    });

    testWidgets('uses rectangle shape by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerPlaceholder),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.rectangle));
    });

    testWidgets('uses circle shape when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(
              width: 50,
              height: 50,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerPlaceholder),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('uses custom border radius when provided', (tester) async {
      const borderRadius = BorderRadius.all(Radius.circular(12));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(
              width: 100,
              height: 50,
              borderRadius: borderRadius,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ShimmerPlaceholder),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(borderRadius));
    });

    testWidgets('adapts colors for dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ShimmerPlaceholder(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      // The shimmer should render without errors in dark mode
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('adapts colors for light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ShimmerPlaceholder(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      // The shimmer should render without errors in light mode
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });
  });

  group('ShimmerListTile', () {
    testWidgets('renders with all elements by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(),
          ),
        ),
      );

      final placeholders = find.byType(ShimmerPlaceholder);
      expect(placeholders, findsWidgets);
    });

    testWidgets('shows leading placeholder by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(),
          ),
        ),
      );

      final placeholders = tester.widgetList<ShimmerPlaceholder>(
        find.byType(ShimmerPlaceholder),
      );

      final hasCircular = placeholders.any(
        (p) => p.shape == BoxShape.circle && p.width == 48,
      );

      expect(hasCircular, isTrue);
    });

    testWidgets('hides leading placeholder when hasLeading is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(hasLeading: false),
          ),
        ),
      );

      final placeholders = tester.widgetList<ShimmerPlaceholder>(
        find.byType(ShimmerPlaceholder),
      );

      final hasCircular = placeholders.any(
        (p) => p.shape == BoxShape.circle && p.width == 48,
      );

      expect(hasCircular, isFalse);
    });

    testWidgets('shows subtitle by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(),
          ),
        ),
      );

      final placeholders = find.byType(ShimmerPlaceholder);
      // Should have at least 2 placeholders in the column (title and subtitle)
      expect(placeholders, findsAtLeastNWidgets(2));
    });

    testWidgets('hides subtitle when hasSubtitle is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(
              hasLeading: false,
              hasSubtitle: false,
            ),
          ),
        ),
      );

      final placeholders = find.byType(ShimmerPlaceholder);
      // Should have only 1 placeholder (title)
      expect(placeholders, findsOneWidget);
    });

    testWidgets('shows trailing when hasTrailing is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(hasTrailing: true),
          ),
        ),
      );

      final placeholders = tester.widgetList<ShimmerPlaceholder>(
        find.byType(ShimmerPlaceholder),
      );

      final hasTrailing = placeholders.any(
        (p) => p.width == 24 && p.height == 24,
      );

      expect(hasTrailing, isTrue);
    });

    testWidgets('uses custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListTile(padding: customPadding),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(Row),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, equals(customPadding));
    });
  });

  group('ShimmerCard', () {
    testWidgets('renders with specified height', (tester) async {
      const height = 250.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(height: height),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, equals(height));
    });

    testWidgets('shows image placeholder by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(),
          ),
        ),
      );

      expect(find.byType(ShimmerPlaceholder), findsWidgets);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('hides image when hasImage is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(hasImage: false),
          ),
        ),
      );

      expect(find.byType(Expanded), findsNothing);
    });

    testWidgets('shows title by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(hasImage: false),
          ),
        ),
      );

      // Should have placeholders for title and subtitle
      expect(find.byType(ShimmerPlaceholder), findsWidgets);
    });

    testWidgets('shows subtitle when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(
              hasImage: false,
              hasTitle: true,
              hasSubtitle: true,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerPlaceholder), findsAtLeastNWidgets(2));
    });

    testWidgets('uses custom width when provided', (tester) async {
      const width = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(width: width),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, equals(width));
    });

    testWidgets('uses custom margin when provided', (tester) async {
      const margin = EdgeInsets.all(16);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(margin: margin),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.margin, equals(margin));
    });
  });

  group('ShimmerText', () {
    testWidgets('renders single line by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(),
          ),
        ),
      );

      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('renders multiple lines when specified', (tester) async {
      const lines = 3;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(lines: lines),
          ),
        ),
      );

      expect(find.byType(ShimmerPlaceholder), findsNWidgets(lines));
    });

    testWidgets('uses custom height', (tester) async {
      const height = 20.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(height: height),
          ),
        ),
      );

      final placeholder = tester.widget<ShimmerPlaceholder>(
        find.byType(ShimmerPlaceholder),
      );

      expect(placeholder.height, equals(height));
    });

    testWidgets('uses custom width', (tester) async {
      const width = 200.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(width: width),
          ),
        ),
      );

      final placeholders = tester.widgetList<ShimmerPlaceholder>(
        find.byType(ShimmerPlaceholder),
      );

      // ShimmerText with 1 line creates a single placeholder with 70% width for last line
      expect(placeholders.length, equals(1));
      expect(placeholders.first.width, equals(width * 0.7));
    });

    testWidgets('last line is shorter than others', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(lines: 2, width: 100),
          ),
        ),
      );

      final placeholders = tester
          .widgetList<ShimmerPlaceholder>(
            find.byType(ShimmerPlaceholder),
          )
          .toList();

      expect(placeholders.length, equals(2));
      expect(placeholders[0].width, equals(100));
      expect(placeholders[1].width, equals(70.0)); // 100 * 0.7
    });

    testWidgets('uses custom spacing between lines', (tester) async {
      const spacing = 16.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(lines: 2, spacing: spacing),
          ),
        ),
      );

      final paddings = tester
          .widgetList<Padding>(
            find.byType(Padding),
          )
          .toList();

      // First line should have bottom padding equal to spacing
      final firstPadding = paddings.first.padding as EdgeInsets;
      expect(firstPadding.bottom, equals(spacing));
    });
  });
}
