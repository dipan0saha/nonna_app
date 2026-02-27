import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/utils/breakpoint_system.dart';

void main() {
  group('Breakpoint predicates', () {
    test('isXs returns true for widths below sm', () {
      expect(BreakpointSystem.isXs(300), isTrue);
      expect(BreakpointSystem.isXs(599), isTrue);
      expect(BreakpointSystem.isXs(600), isFalse);
    });

    test('isSm returns true for 600–1023', () {
      expect(BreakpointSystem.isSm(600), isTrue);
      expect(BreakpointSystem.isSm(800), isTrue);
      expect(BreakpointSystem.isSm(1023), isTrue);
      expect(BreakpointSystem.isSm(1024), isFalse);
      expect(BreakpointSystem.isSm(400), isFalse);
    });

    test('isMd returns true for 1024–1439', () {
      expect(BreakpointSystem.isMd(1024), isTrue);
      expect(BreakpointSystem.isMd(1200), isTrue);
      expect(BreakpointSystem.isMd(1439), isTrue);
      expect(BreakpointSystem.isMd(1440), isFalse);
      expect(BreakpointSystem.isMd(600), isFalse);
    });

    test('isLg returns true for 1440–1919', () {
      expect(BreakpointSystem.isLg(1440), isTrue);
      expect(BreakpointSystem.isLg(1600), isTrue);
      expect(BreakpointSystem.isLg(1919), isTrue);
      expect(BreakpointSystem.isLg(1920), isFalse);
      expect(BreakpointSystem.isLg(1000), isFalse);
    });

    test('isXl returns true for widths ≥ 1920', () {
      expect(BreakpointSystem.isXl(1920), isTrue);
      expect(BreakpointSystem.isXl(2560), isTrue);
      expect(BreakpointSystem.isXl(1919), isFalse);
    });
  });

  group('BreakpointSystem.current', () {
    Widget buildBreakpointWidget(double width, Key key) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: Builder(
              builder: (ctx) {
                final bp = BreakpointSystem.current(ctx);
                return Text(bp.name, key: key);
              },
            ),
          ),
        );

    testWidgets('returns xs for 400 dp', (tester) async {
      const k = Key('bp');
      await tester.pumpWidget(buildBreakpointWidget(400, k));
      expect(find.text('xs'), findsOneWidget);
    });

    testWidgets('returns sm for 700 dp', (tester) async {
      const k = Key('bp');
      await tester.pumpWidget(buildBreakpointWidget(700, k));
      expect(find.text('sm'), findsOneWidget);
    });

    testWidgets('returns md for 1100 dp', (tester) async {
      const k = Key('bp');
      await tester.pumpWidget(buildBreakpointWidget(1100, k));
      expect(find.text('md'), findsOneWidget);
    });

    testWidgets('returns lg for 1500 dp', (tester) async {
      const k = Key('bp');
      await tester.pumpWidget(buildBreakpointWidget(1500, k));
      expect(find.text('lg'), findsOneWidget);
    });

    testWidgets('returns xl for 2000 dp', (tester) async {
      const k = Key('bp');
      await tester.pumpWidget(buildBreakpointWidget(2000, k));
      expect(find.text('xl'), findsOneWidget);
    });
  });

  group('BreakpointSystem.value', () {
    testWidgets('falls back to xs when only xs provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (ctx) {
                final v = BreakpointSystem.value<int>(ctx, xs: 1);
                return Text('$v');
              },
            ),
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('selects md value when on md breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (ctx) {
                final v = BreakpointSystem.value<int>(
                  ctx,
                  xs: 1,
                  sm: 2,
                  md: 3,
                  lg: 4,
                );
                return Text('$v');
              },
            ),
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });
  });
}
