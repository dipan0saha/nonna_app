import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/rtl_support_handler.dart';

void main() {
  group('RTLSupportHandler - Language Detection Tests', () {
    test('isRTLLanguage returns true for Arabic', () {
      expect(RTLSupportHandler.isRTLLanguage('ar'), isTrue);
    });

    test('isRTLLanguage returns true for Hebrew', () {
      expect(RTLSupportHandler.isRTLLanguage('he'), isTrue);
    });

    test('isRTLLanguage returns true for Persian', () {
      expect(RTLSupportHandler.isRTLLanguage('fa'), isTrue);
    });

    test('isRTLLanguage returns true for Urdu', () {
      expect(RTLSupportHandler.isRTLLanguage('ur'), isTrue);
    });

    test('isRTLLanguage returns false for English', () {
      expect(RTLSupportHandler.isRTLLanguage('en'), isFalse);
    });

    test('isRTLLanguage returns false for Spanish', () {
      expect(RTLSupportHandler.isRTLLanguage('es'), isFalse);
    });

    test('isRTLLanguage handles case insensitivity', () {
      expect(RTLSupportHandler.isRTLLanguage('AR'), isTrue);
      expect(RTLSupportHandler.isRTLLanguage('He'), isTrue);
    });

    test('isRTLLocale works with Locale objects', () {
      expect(RTLSupportHandler.isRTLLocale(const Locale('ar')), isTrue);
      expect(RTLSupportHandler.isRTLLocale(const Locale('en')), isFalse);
    });
  });

  group('RTLSupportHandler - Context-based RTL Detection', () {
    testWidgets('isRTL returns true for Arabic locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(RTLSupportHandler.isRTL(context), isTrue);
            },
          ),
        ),
      );
    });

    testWidgets('isRTL returns false for English locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              expect(RTLSupportHandler.isRTL(context), isFalse);
            },
          ),
        ),
      );
    });

    testWidgets('isRTL returns true for Hebrew locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('he'),
          home: _TestWidget(
            callback: (context) {
              expect(RTLSupportHandler.isRTL(context), isTrue);
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Text Direction Tests', () {
    testWidgets('getTextDirection returns RTL for Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextDirection(context),
                equals(TextDirection.rtl),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getTextDirection returns LTR for English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextDirection(context),
                equals(TextDirection.ltr),
              );
            },
          ),
        ),
      );
    });

    test('getTextDirectionFromLocale works correctly', () {
      expect(
        RTLSupportHandler.getTextDirectionFromLocale(const Locale('ar')),
        equals(TextDirection.rtl),
      );
      expect(
        RTLSupportHandler.getTextDirectionFromLocale(const Locale('en')),
        equals(TextDirection.ltr),
      );
    });

    test('getTextDirectionFromLanguage works correctly', () {
      expect(
        RTLSupportHandler.getTextDirectionFromLanguage('ar'),
        equals(TextDirection.rtl),
      );
      expect(
        RTLSupportHandler.getTextDirectionFromLanguage('en'),
        equals(TextDirection.ltr),
      );
    });

    test('flipDirection flips correctly', () {
      expect(
        RTLSupportHandler.flipDirection(TextDirection.ltr),
        equals(TextDirection.rtl),
      );
      expect(
        RTLSupportHandler.flipDirection(TextDirection.rtl),
        equals(TextDirection.ltr),
      );
    });
  });

  group('RTLSupportHandler - Text Alignment Tests', () {
    testWidgets('getTextAlign returns correct alignment for RTL start',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextAlign(
                  context,
                  alignment: TextAlign.start,
                ),
                equals(TextAlign.right),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getTextAlign returns correct alignment for RTL end',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextAlign(
                  context,
                  alignment: TextAlign.end,
                ),
                equals(TextAlign.left),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getTextAlign returns correct alignment for LTR start',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextAlign(
                  context,
                  alignment: TextAlign.start,
                ),
                equals(TextAlign.left),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getTextAlign preserves center alignment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getTextAlign(
                  context,
                  alignment: TextAlign.center,
                ),
                equals(TextAlign.center),
              );
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Mirror Value Tests', () {
    testWidgets('mirror negates value for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(RTLSupportHandler.mirror(context, 10.0), equals(-10.0));
            },
          ),
        ),
      );
    });

    testWidgets('mirror preserves value for LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              expect(RTLSupportHandler.mirror(context, 10.0), equals(10.0));
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Edge Insets Tests', () {
    testWidgets('mirrorEdgeInsets swaps left and right for RTL',
        (WidgetTester tester) async {
      const insets = EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final mirrored = RTLSupportHandler.mirrorEdgeInsets(
                context,
                insets,
              );
              expect(mirrored.left, equals(30.0));
              expect(mirrored.right, equals(10.0));
              expect(mirrored.top, equals(20.0));
              expect(mirrored.bottom, equals(40.0));
            },
          ),
        ),
      );
    });

    testWidgets('mirrorEdgeInsets preserves insets for LTR',
        (WidgetTester tester) async {
      const insets = EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              final mirrored = RTLSupportHandler.mirrorEdgeInsets(
                context,
                insets,
              );
              expect(mirrored, equals(insets));
            },
          ),
        ),
      );
    });

    testWidgets('mirrorEdgeInsetsDirectional resolves correctly',
        (WidgetTester tester) async {
      const insets = EdgeInsetsDirectional.only(
        start: 10,
        top: 20,
        end: 30,
        bottom: 40,
      );

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final resolved = RTLSupportHandler.mirrorEdgeInsetsDirectional(
                context,
                insets,
              );
              expect(resolved.right, equals(10.0)); // start becomes right in RTL
              expect(resolved.left, equals(30.0)); // end becomes left in RTL
              expect(resolved.top, equals(20.0));
              expect(resolved.bottom, equals(40.0));
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Alignment Tests', () {
    testWidgets('getAlignment mirrors horizontal for RTL',
        (WidgetTester tester) async {
      const alignment = Alignment(0.5, 0.3);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final mirrored = RTLSupportHandler.getAlignment(
                context,
                alignment,
              );
              expect(mirrored.x, equals(-0.5));
              expect(mirrored.y, equals(0.3));
            },
          ),
        ),
      );
    });

    testWidgets('getAlignment preserves for LTR', (WidgetTester tester) async {
      const alignment = Alignment(0.5, 0.3);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              final result = RTLSupportHandler.getAlignment(
                context,
                alignment,
              );
              expect(result, equals(alignment));
            },
          ),
        ),
      );
    });

    testWidgets('resolveAlignment works correctly', (WidgetTester tester) async {
      const alignment = AlignmentDirectional.centerStart;

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final resolved = RTLSupportHandler.resolveAlignment(
                context,
                alignment,
              );
              expect(resolved, equals(Alignment.centerRight));
            },
          ),
        ),
      );
    });

    testWidgets('getStartAlignment returns correct value for RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getStartAlignment(context),
                equals(Alignment.centerRight),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getEndAlignment returns correct value for RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getEndAlignment(context),
                equals(Alignment.centerLeft),
              );
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Icon Mirroring Tests', () {
    test('shouldMirrorIcon returns true for directional icons', () {
      expect(
        RTLSupportHandler.shouldMirrorIcon(Icons.arrow_forward),
        isTrue,
      );
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.arrow_back), isTrue);
      expect(
        RTLSupportHandler.shouldMirrorIcon(Icons.chevron_right),
        isTrue,
      );
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.chevron_left), isTrue);
    });

    test('shouldMirrorIcon returns false for non-directional icons', () {
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.home), isFalse);
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.settings), isFalse);
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.check), isFalse);
      expect(RTLSupportHandler.shouldMirrorIcon(Icons.close), isFalse);
    });

    testWidgets('mirrorIconIfNeeded returns same icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final result = RTLSupportHandler.mirrorIconIfNeeded(
                context,
                Icons.arrow_forward,
              );
              expect(result, equals(Icons.arrow_forward));
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Widget Mirroring Tests', () {
    testWidgets('mirrorInRTL creates Transform for RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              return RTLSupportHandler.mirrorInRTL(
                context: context,
                child: const Icon(Icons.arrow_forward),
              );
            },
          ),
        ),
      );

      expect(find.byType(Transform), findsOneWidget);
    });

    testWidgets('mirrorInRTL returns child directly for LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              return RTLSupportHandler.mirrorInRTL(
                context: context,
                child: const Icon(Icons.arrow_forward),
              );
            },
          ),
        ),
      );

      // Should not wrap in Transform for LTR
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('mirrorInRTL respects shouldMirror flag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              return RTLSupportHandler.mirrorInRTL(
                context: context,
                child: const Icon(Icons.home),
                shouldMirror: false,
              );
            },
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('RTLSupportHandler - Directionality Widget Tests', () {
    testWidgets('withDirectionality creates Directionality widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              return RTLSupportHandler.withDirectionality(
                context: context,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      expect(find.byType(Directionality), findsOneWidget);
    });

    testWidgets('withDirectionality respects override direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              return RTLSupportHandler.withDirectionality(
                context: context,
                child: const Text('Test'),
                overrideDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );

      final directionality =
          tester.widget<Directionality>(find.byType(Directionality));
      expect(directionality.textDirection, equals(TextDirection.ltr));
    });
  });

  group('RTLSupportHandler - Axis Alignment Tests', () {
    testWidgets('getCrossAxisAlignment returns correct value for RTL start',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getCrossAxisAlignment(
                  context,
                  logicalAlignment: CrossAxisAlignment.start,
                ),
                equals(CrossAxisAlignment.end),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getMainAxisAlignment returns correct value for RTL end',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getMainAxisAlignment(
                  context,
                  logicalAlignment: MainAxisAlignment.end,
                ),
                equals(MainAxisAlignment.start),
              );
            },
          ),
        ),
      );
    });

    testWidgets('getCrossAxisAlignment preserves center',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              expect(
                RTLSupportHandler.getCrossAxisAlignment(
                  context,
                  logicalAlignment: CrossAxisAlignment.center,
                ),
                equals(CrossAxisAlignment.center),
              );
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Border Radius Tests', () {
    testWidgets('mirrorBorderRadius swaps corners for RTL',
        (WidgetTester tester) async {
      const radius = BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(40),
      );

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final mirrored = RTLSupportHandler.mirrorBorderRadius(
                context,
                radius,
              );
              expect(mirrored.topLeft, equals(const Radius.circular(20)));
              expect(mirrored.topRight, equals(const Radius.circular(10)));
              expect(mirrored.bottomLeft, equals(const Radius.circular(40)));
              expect(mirrored.bottomRight, equals(const Radius.circular(30)));
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Decoration Mirroring Tests', () {
    testWidgets('mirrorDecoration mirrors linear gradient',
        (WidgetTester tester) async {
      const decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.red, Colors.blue],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final mirrored = RTLSupportHandler.mirrorDecoration(
                context,
                decoration,
              );
              final gradient = mirrored.gradient as LinearGradient;
              expect(gradient.begin, equals(Alignment.centerRight));
              expect(gradient.end, equals(Alignment.centerLeft));
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Unicode Directional Markers', () {
    testWidgets('wrapWithDirectionalMarkers adds RTL markers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final wrapped = RTLSupportHandler.wrapWithDirectionalMarkers(
                context,
                'test',
              );
              expect(wrapped.startsWith('\u200F'), isTrue); // RLM
              expect(wrapped.endsWith('\u200F'), isTrue);
            },
          ),
        ),
      );
    });

    testWidgets('wrapWithDirectionalMarkers adds LTR markers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          home: _TestWidget(
            callback: (context) {
              final wrapped = RTLSupportHandler.wrapWithDirectionalMarkers(
                context,
                'test',
              );
              expect(wrapped.startsWith('\u200E'), isTrue); // LRM
              expect(wrapped.endsWith('\u200E'), isTrue);
            },
          ),
        ),
      );
    });

    testWidgets('wrapWithDirectionalMarkers handles forceLTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: _TestWidget(
            callback: (context) {
              final wrapped = RTLSupportHandler.wrapWithDirectionalMarkers(
                context,
                'test',
                forceLTR: true,
              );
              expect(wrapped.startsWith('\u200E'), isTrue); // LRM even in RTL
            },
          ),
        ),
      );
    });
  });

  group('RTLSupportHandler - Content Detection Tests', () {
    test('containsRTLCharacters detects Arabic text', () {
      expect(RTLSupportHandler.containsRTLCharacters('مرحبا'), isTrue);
      expect(RTLSupportHandler.containsRTLCharacters('Hello مرحبا'), isTrue);
    });

    test('containsRTLCharacters detects Hebrew text', () {
      expect(RTLSupportHandler.containsRTLCharacters('שלום'), isTrue);
    });

    test('containsRTLCharacters returns false for LTR text', () {
      expect(RTLSupportHandler.containsRTLCharacters('Hello'), isFalse);
      expect(RTLSupportHandler.containsRTLCharacters('123'), isFalse);
    });

    test('containsRTLCharacters handles empty string', () {
      expect(RTLSupportHandler.containsRTLCharacters(''), isFalse);
    });

    test('getTextDirectionFromContent detects RTL content', () {
      expect(
        RTLSupportHandler.getTextDirectionFromContent('مرحبا'),
        equals(TextDirection.rtl),
      );
    });

    test('getTextDirectionFromContent defaults to LTR', () {
      expect(
        RTLSupportHandler.getTextDirectionFromContent('Hello'),
        equals(TextDirection.ltr),
      );
    });

    test('getTextDirectionFromContent uses default for empty string', () {
      expect(
        RTLSupportHandler.getTextDirectionFromContent(
          '',
          defaultDirection: TextDirection.rtl,
        ),
        equals(TextDirection.rtl),
      );
    });
  });

  group('RTLSupportHandler - Constants', () {
    test('rtlLanguages contains expected languages', () {
      expect(RTLSupportHandler.rtlLanguages, contains('ar'));
      expect(RTLSupportHandler.rtlLanguages, contains('he'));
      expect(RTLSupportHandler.rtlLanguages, contains('fa'));
      expect(RTLSupportHandler.rtlLanguages, contains('ur'));
    });

    test('rtlLanguages does not contain LTR languages', () {
      expect(RTLSupportHandler.rtlLanguages, isNot(contains('en')));
      expect(RTLSupportHandler.rtlLanguages, isNot(contains('es')));
    });
  });
}

// Helper widget for testing context-dependent methods
class _TestWidget extends StatelessWidget {
  const _TestWidget({required this.callback});

  final void Function(BuildContext) callback;

  @override
  Widget build(BuildContext context) {
    callback(context);
    return const Scaffold(body: SizedBox.shrink());
  }
}
