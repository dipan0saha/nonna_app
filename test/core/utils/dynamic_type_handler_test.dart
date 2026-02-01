import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/dynamic_type_handler.dart';

void main() {
  group('DynamicTypeHandler - Text Scale Factor Tests', () {
    testWidgets('getTextScaleFactor returns correct scale factor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scale = DynamicTypeHandler.getTextScaleFactor(context);
              expect(scale, equals(1.0));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getTextScaleFactor reflects MediaQuery changes',
        (WidgetTester tester) async {
      const testScale = 1.5;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(testScale),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scale = DynamicTypeHandler.getTextScaleFactor(context);
                expect(scale, equals(testScale));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getClampedTextScaleFactor respects min/max bounds',
        (WidgetTester tester) async {
      // Test minimum clamping
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(0.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scale = DynamicTypeHandler.getClampedTextScaleFactor(
                  context,
                  minScale: 0.8,
                  maxScale: 2.0,
                );
                expect(scale, equals(0.8));
                return Container();
              },
            ),
          ),
        ),
      );

      // Test maximum clamping
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(3.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scale = DynamicTypeHandler.getClampedTextScaleFactor(
                  context,
                  minScale: 0.8,
                  maxScale: 2.0,
                );
                expect(scale, equals(2.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getClampedTextScaleFactor handles normal range',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.2),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scale = DynamicTypeHandler.getClampedTextScaleFactor(
                  context,
                  minScale: 0.8,
                  maxScale: 2.0,
                );
                expect(scale, equals(1.2));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Font Scaling Tests', () {
    testWidgets('scale applies correct scaling with default settings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                );
                expect(scaled, equals(24.0)); // 16.0 * 1.5
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('scale respects minimum scale factor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(0.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                  minScale: 0.8,
                );
                expect(scaled, equals(12.8)); // 16.0 * 0.8 (clamped)
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('scale respects maximum scale factor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(3.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                  maxScale: 2.0,
                );
                expect(scaled, equals(32.0)); // 16.0 * 2.0 (clamped)
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('scale ignores system settings when respectSystemSettings is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                  respectSystemSettings: false,
                );
                expect(scaled, equals(16.0)); // No scaling applied
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - TextStyle Scaling Tests', () {
    testWidgets('scaledTextStyle preserves all style properties',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        letterSpacing: 1.2,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaledStyle = DynamicTypeHandler.scaledTextStyle(
                  context,
                  baseStyle: baseStyle,
                );
                expect(scaledStyle.fontSize, equals(24.0));
                expect(scaledStyle.fontWeight, equals(FontWeight.bold));
                expect(scaledStyle.color, equals(Colors.blue));
                expect(scaledStyle.letterSpacing, equals(1.2));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('scaledTextStyle returns original style when fontSize is null',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scaledStyle = DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: baseStyle,
              );
              expect(scaledStyle, equals(baseStyle));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('scaledTextStyle respects min and max scale',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(fontSize: 16.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(3.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaledStyle = DynamicTypeHandler.scaledTextStyle(
                  context,
                  baseStyle: baseStyle,
                  maxScale: 1.5,
                );
                expect(scaledStyle.fontSize, equals(24.0)); // 16.0 * 1.5
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Line Height Calculation', () {
    test('calculateLineHeight returns correct values for small text', () {
      final lineHeight = DynamicTypeHandler.calculateLineHeight(14.0);
      expect(lineHeight, equals(21.0)); // 14.0 * 1.5
    });

    test('calculateLineHeight returns correct values for medium text', () {
      final lineHeight = DynamicTypeHandler.calculateLineHeight(16.0);
      expect(lineHeight, equals(22.4)); // 16.0 * 1.4
    });

    test('calculateLineHeight returns correct values for large text', () {
      final lineHeight = DynamicTypeHandler.calculateLineHeight(28.0);
      expect(lineHeight, equals(36.4)); // 28.0 * 1.3
    });

    test('calculateLineHeight handles edge cases', () {
      expect(DynamicTypeHandler.calculateLineHeight(0.0), equals(0.0));
      expect(
        DynamicTypeHandler.calculateLineHeight(100.0),
        equals(130.0),
      );
    });
  });

  group('DynamicTypeHandler - Padding Tests', () {
    testWidgets('getScaledPadding scales with text',
        (WidgetTester tester) async {
      const basePadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.getScaledPadding(
                  context,
                  basePadding: basePadding,
                );
                // Scale factor = (1.5 - 1.0) * 0.5 + 1.0 = 1.25
                expect(scaled.left, equals(20.0)); // 16.0 * 1.25
                expect(scaled.top, equals(20.0));
                expect(scaled.right, equals(20.0));
                expect(scaled.bottom, equals(20.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getScaledPadding respects scaleWithText flag',
        (WidgetTester tester) async {
      const basePadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.getScaledPadding(
                  context,
                  basePadding: basePadding,
                  scaleWithText: false,
                );
                expect(scaled, equals(basePadding));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Scale Detection Tests', () {
    testWidgets('isNormalTextScale returns true for normal scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(DynamicTypeHandler.isNormalTextScale(context), isTrue);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isNormalTextScale returns false for large scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(DynamicTypeHandler.isNormalTextScale(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isLargeTextScale returns true for large scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(DynamicTypeHandler.isLargeTextScale(context), isTrue);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isLargeTextScale returns false for normal scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(DynamicTypeHandler.isLargeTextScale(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isExtraLargeTextScale returns true for extra large scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(
                  DynamicTypeHandler.isExtraLargeTextScale(context),
                  isTrue,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Touch Target Tests', () {
    testWidgets('getMinimumTouchTarget maintains WCAG minimum',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(0.8),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final size = DynamicTypeHandler.getMinimumTouchTarget(context);
                expect(size, greaterThanOrEqualTo(44.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getMinimumTouchTarget scales with large text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final size = DynamicTypeHandler.getMinimumTouchTarget(
                  context,
                  baseSize: 44.0,
                );
                expect(size, equals(66.0)); // 44.0 * 1.5
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Adaptive Text Style Tests', () {
    testWidgets('adaptiveTextStyle simplifies at extra large scale',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(
        fontSize: 16.0,
        decoration: TextDecoration.underline,
        fontStyle: FontStyle.italic,
        shadows: [Shadow(blurRadius: 2.0)],
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final adaptiveStyle = DynamicTypeHandler.adaptiveTextStyle(
                  context,
                  baseStyle: baseStyle,
                );
                expect(adaptiveStyle.fontSize, equals(32.0));
                expect(adaptiveStyle.decoration, equals(TextDecoration.none));
                expect(adaptiveStyle.fontStyle, equals(FontStyle.normal));
                expect(adaptiveStyle.shadows, isNull);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('adaptiveTextStyle preserves style at normal scale',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(
        fontSize: 16.0,
        decoration: TextDecoration.underline,
        fontStyle: FontStyle.italic,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final adaptiveStyle = DynamicTypeHandler.adaptiveTextStyle(
                  context,
                  baseStyle: baseStyle,
                );
                expect(adaptiveStyle.fontSize, equals(16.0));
                expect(
                  adaptiveStyle.decoration,
                  equals(TextDecoration.underline),
                );
                expect(adaptiveStyle.fontStyle, equals(FontStyle.italic));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Icon Size Tests', () {
    testWidgets('getScaledIconSize scales proportionally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final size = DynamicTypeHandler.getScaledIconSize(
                  context,
                  baseIconSize: 24.0,
                );
                expect(size, equals(36.0)); // 24.0 * 1.5
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getScaledIconSize respects maximum',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(3.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final size = DynamicTypeHandler.getScaledIconSize(
                  context,
                  baseIconSize: 24.0,
                  maxIconSize: 48.0,
                );
                expect(size, equals(48.0)); // Clamped to max
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Custom Text Scale Tests', () {
    testWidgets('withCustomTextScale applies custom scaling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (outerContext) {
                return DynamicTypeHandler.withCustomTextScale(
                  context: outerContext,
                  textScaleFactor: 1.5,
                  child: Builder(
                    builder: (innerContext) {
                      final scale =
                          DynamicTypeHandler.getTextScaleFactor(innerContext);
                      expect(scale, equals(1.5));
                      return Container();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    });

    testWidgets('createCustomTextScaleData creates correct data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final customData = DynamicTypeHandler.createCustomTextScaleData(
                context,
                textScaleFactor: 1.8,
              );
              expect(customData.textScaler.scale(1.0), equals(1.8));
              return Container();
            },
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Layout Reflow Tests', () {
    testWidgets('shouldReflowLayout returns true for large scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(
                  DynamicTypeHandler.shouldReflowLayout(context),
                  isTrue,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('shouldReflowLayout returns false for normal scale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(
                  DynamicTypeHandler.shouldReflowLayout(context),
                  isFalse,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('shouldReflowLayout respects custom threshold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.4),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(
                  DynamicTypeHandler.shouldReflowLayout(
                    context,
                    threshold: 1.5,
                  ),
                  isFalse,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Edge Cases', () {
    testWidgets('handles zero font size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scaled = DynamicTypeHandler.scale(
                context,
                baseFontSize: 0.0,
              );
              expect(scaled, equals(0.0));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('handles extreme scale factors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(10.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                  maxScale: 2.0,
                );
                expect(scaled, equals(32.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('handles negative scale gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(-1.0),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final scaled = DynamicTypeHandler.scale(
                  context,
                  baseFontSize: 16.0,
                  minScale: 0.8,
                );
                expect(scaled, equals(12.8)); // Clamped to min
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DynamicTypeHandler - Constants', () {
    test('defaultMinScale is correct', () {
      expect(DynamicTypeHandler.defaultMinScale, equals(0.8));
    });

    test('defaultMaxScale is correct', () {
      expect(DynamicTypeHandler.defaultMaxScale, equals(2.0));
    });

    test('referenceScale is correct', () {
      expect(DynamicTypeHandler.referenceScale, equals(1.0));
    });

    test('largeTextThreshold is correct', () {
      expect(DynamicTypeHandler.largeTextThreshold, equals(24.0));
    });
  });
}
