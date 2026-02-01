import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/screen_size_utils.dart';

void main() {
  group('ScreenSizeUtils', () {
    group('Breakpoint Constants', () {
      test('mobile breakpoint is 600', () {
        expect(ScreenSizeUtils.mobileBreakpoint, 600.0);
      });

      test('tablet breakpoint is 1024', () {
        expect(ScreenSizeUtils.tabletBreakpoint, 1024.0);
      });

      test('desktop breakpoint is 1440', () {
        expect(ScreenSizeUtils.desktopBreakpoint, 1440.0);
      });

      test('breakpoints are in ascending order', () {
        expect(ScreenSizeUtils.mobileBreakpoint,
            lessThan(ScreenSizeUtils.tabletBreakpoint));
        expect(ScreenSizeUtils.tabletBreakpoint,
            lessThan(ScreenSizeUtils.desktopBreakpoint));
      });
    });

    group('Device Type Detection', () {
      testWidgets('detects mobile device', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.isMobile(context), isTrue);
                expect(ScreenSizeUtils.isTablet(context), isFalse);
                expect(ScreenSizeUtils.isDesktop(context), isFalse);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('detects tablet device', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.isMobile(context), isFalse);
                expect(ScreenSizeUtils.isTablet(context), isTrue);
                expect(ScreenSizeUtils.isDesktop(context), isFalse);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('detects desktop device', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.isMobile(context), isFalse);
                expect(ScreenSizeUtils.isTablet(context), isFalse);
                expect(ScreenSizeUtils.isDesktop(context), isTrue);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getDeviceType returns correct enum', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.getDeviceType(context), DeviceType.mobile);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Orientation Helpers', () {
      testWidgets('detects portrait orientation', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.isPortrait(context), isTrue);
                expect(ScreenSizeUtils.isLandscape(context), isFalse);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('detects landscape orientation', (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(ScreenSizeUtils.isPortrait(context), isFalse);
                expect(ScreenSizeUtils.isLandscape(context), isTrue);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Responsive Value Selection', () {
      testWidgets('responsive returns mobile value on mobile', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final value = ScreenSizeUtils.responsive(
                  context: context,
                  mobile: 'mobile',
                  tablet: 'tablet',
                  desktop: 'desktop',
                );
                expect(value, 'mobile');
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('responsive falls back to mobile when tablet is null',
          (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final value = ScreenSizeUtils.responsive(
                  context: context,
                  mobile: 'mobile',
                );
                expect(value, 'mobile');
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Grid Column Calculations', () {
      testWidgets('returns correct mobile columns', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final columns = ScreenSizeUtils.getGridColumns(context);
                expect(columns, 2);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('calculateColumns returns at least 1', (tester) async {
        tester.view.physicalSize = const Size(100, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final columns = ScreenSizeUtils.calculateColumns(
                  context,
                  itemWidth: 200,
                );
                expect(columns, greaterThanOrEqualTo(1));
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Padding & Spacing Helpers', () {
      testWidgets('getHorizontalPadding returns value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final padding = ScreenSizeUtils.getHorizontalPadding(context);
                expect(padding, greaterThan(0));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getContentPadding returns EdgeInsets', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final padding = ScreenSizeUtils.getContentPadding(context);
                expect(padding, isA<EdgeInsets>());
                expect(padding.horizontal, greaterThan(0));
                expect(padding.vertical, greaterThan(0));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getSpacing returns positive value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final spacing = ScreenSizeUtils.getSpacing(context);
                expect(spacing, greaterThan(0));
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Content Width Constraints', () {
      testWidgets('getMaxContentWidth returns value', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final maxWidth = ScreenSizeUtils.getMaxContentWidth(context);
                expect(maxWidth, greaterThan(0));
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getContentConstraints returns BoxConstraints', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final constraints = ScreenSizeUtils.getContentConstraints(context);
                expect(constraints, isA<BoxConstraints>());
                expect(constraints.maxWidth, isFinite);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Screen Dimension Helpers', () {
      testWidgets('getScreenWidth returns width', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final width = ScreenSizeUtils.getScreenWidth(context);
                expect(width, 400.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getScreenHeight returns height', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final height = ScreenSizeUtils.getScreenHeight(context);
                expect(height, 800.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('percentWidth calculates correctly', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final width = ScreenSizeUtils.percentWidth(context, 50);
                expect(width, 200.0);
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });
  });

  group('DeviceType', () {
    test('enum has all values', () {
      expect(DeviceType.values.length, 4);
      expect(DeviceType.values, contains(DeviceType.mobile));
      expect(DeviceType.values, contains(DeviceType.tablet));
      expect(DeviceType.values, contains(DeviceType.desktop));
      expect(DeviceType.values, contains(DeviceType.largeDesktop));
    });
  });
}
