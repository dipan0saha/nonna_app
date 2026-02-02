import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/custom_button.dart';

void main() {
  group('CustomButton', () {
    testWidgets('displays label text', (tester) async {
      const label = 'Click Me';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              onPressed: () {},
              label: label,
            ),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              onPressed: () => tapped = true,
              label: 'Button',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Button'));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              onPressed: null,
              label: 'Button',
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    group('Primary variant', () {
      testWidgets('renders as ElevatedButton', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                variant: ButtonVariant.primary,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('uses primary color from theme', (tester) async {
        const primaryColor = Colors.blue;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: primaryColor),
            ),
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                variant: ButtonVariant.primary,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        final backgroundColor = button.style?.backgroundColor?.resolve({});
        expect(backgroundColor, equals(primaryColor));
      });
    });

    group('Secondary variant', () {
      testWidgets('renders as OutlinedButton', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                variant: ButtonVariant.secondary,
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('has border with primary color', (tester) async {
        const primaryColor = Colors.green;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: primaryColor),
            ),
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                variant: ButtonVariant.secondary,
              ),
            ),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );

        final side = button.style?.side?.resolve({});
        expect(side?.color, equals(primaryColor));
      });
    });

    group('Tertiary variant', () {
      testWidgets('renders as TextButton', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                variant: ButtonVariant.tertiary,
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('Loading state', () {
      testWidgets('shows loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Button'), findsNothing);
      });

      testWidgets('is disabled when loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                isLoading: true,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        expect(button.onPressed, isNull);
      });

      testWidgets('does not show label when loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.text('Button'), findsNothing);
      });
    });

    group('Icon support', () {
      testWidgets('displays icon when provided', (tester) async {
        const icon = Icons.add;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                icon: icon,
              ),
            ),
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
      });

      testWidgets('does not display icon when not provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsNothing);
      });

      testWidgets('icon appears before label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                icon: Icons.add,
              ),
            ),
          ),
        );

        final row = tester.widget<Row>(find.byType(Row).first);
        final children = row.children;

        // Icon should be first
        expect(children.first, isA<Icon>());
        // Text is wrapped in a Flexible widget for overflow handling
        expect(children.last, isA<Flexible>());
        // Verify the Flexible contains a Text widget
        final flexible = children.last as Flexible;
        expect(flexible.child, isA<Text>());
      });
    });

    group('Full width', () {
      testWidgets('expands to full width when fullWidth is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                fullWidth: true,
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byType(ElevatedButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );

        expect(sizedBox.width, equals(double.infinity));
      });

      testWidgets('does not expand when fullWidth is false', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                fullWidth: false,
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byType(ElevatedButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );

        expect(sizedBox.width, isNull);
      });
    });

    group('Custom padding', () {
      testWidgets('uses custom padding when provided', (tester) async {
        const customPadding = EdgeInsets.all(20);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                onPressed: () {},
                label: 'Button',
                padding: customPadding,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        final padding = button.style?.padding?.resolve({});
        expect(padding, equals(customPadding));
      });
    });
  });

  group('CustomIconButton', () {
    testWidgets('displays icon', (tester) async {
      const icon = Icons.favorite;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: icon,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<IconButton>(
        find.byType(IconButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('displays tooltip when provided', (tester) async {
      const tooltip = 'Favorite';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: null,
              tooltip: tooltip,
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('does not display tooltip when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('uses custom size when provided', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: () {},
              size: customSize,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.size, equals(customSize));
    });

    testWidgets('uses custom color when provided', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: () {},
              color: customColor,
            ),
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.color, equals(customColor));
    });

    testWidgets('uses theme primary color when color not specified',
        (tester) async {
      const primaryColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          home: Scaffold(
            body: CustomIconButton(
              icon: Icons.favorite,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.color, equals(primaryColor));
    });
  });
}
