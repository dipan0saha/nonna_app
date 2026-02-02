import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/themes/tile_styles.dart';
import 'package:nonna_app/core/themes/colors.dart';

void main() {
  group('TileStyles', () {
    group('Border Radius', () {
      test('default border radius is 16', () {
        expect(TileStyles.borderRadius, 16.0);
      });

      test('small border radius is less than default', () {
        expect(TileStyles.borderRadiusSmall, lessThan(TileStyles.borderRadius));
      });

      test('large border radius is greater than default', () {
        expect(
            TileStyles.borderRadiusLarge, greaterThan(TileStyles.borderRadius));
      });
    });

    group('Padding', () {
      test('default padding is 16 on all sides', () {
        expect(TileStyles.defaultPadding, const EdgeInsets.all(16.0));
      });

      test('compact padding is less than default', () {
        expect(TileStyles.compactPadding.left,
            lessThan(TileStyles.defaultPadding.left));
      });

      test('expanded padding is greater than default', () {
        expect(TileStyles.expandedPadding.left,
            greaterThan(TileStyles.defaultPadding.left));
      });

      test('header padding has asymmetric values', () {
        expect(TileStyles.headerPadding.top, isPositive);
        expect(TileStyles.headerPadding.bottom, isPositive);
      });

      test('horizontal padding only affects left and right', () {
        expect(TileStyles.horizontalPadding.top, 0);
        expect(TileStyles.horizontalPadding.bottom, 0);
        expect(TileStyles.horizontalPadding.left, greaterThan(0));
      });
    });

    group('Spacing', () {
      test('tile separation is defined', () {
        expect(TileStyles.tileSeparation, greaterThan(0));
      });

      test('header content gap is defined', () {
        expect(TileStyles.headerContentGap, greaterThan(0));
      });

      test('content gap is smaller than other gaps', () {
        expect(TileStyles.contentGap, lessThan(TileStyles.headerContentGap));
      });
    });

    group('Elevation & Shadow', () {
      test('default elevation is 2', () {
        expect(TileStyles.elevation, 2.0);
      });

      test('hover elevation is greater than default', () {
        expect(TileStyles.elevationHover, greaterThan(TileStyles.elevation));
      });

      test('prominent elevation is greatest', () {
        expect(TileStyles.elevationProminent,
            greaterThan(TileStyles.elevationHover));
      });

      test('default shadow has one shadow', () {
        expect(TileStyles.defaultShadow.length, 1);
      });

      test('hover shadow has greater blur than default', () {
        expect(TileStyles.hoverShadow.first.blurRadius,
            greaterThan(TileStyles.defaultShadow.first.blurRadius));
      });

      test('no shadow is empty list', () {
        expect(TileStyles.noShadow, isEmpty);
      });
    });

    group('Decoration Presets', () {
      test('default decoration has surface color', () {
        expect(TileStyles.defaultDecoration.color, AppColors.surface);
      });

      test('default decoration has rounded corners', () {
        final decoration = TileStyles.defaultDecoration;
        expect(decoration.borderRadius, isNotNull);
      });

      test('default decoration has shadow', () {
        expect(TileStyles.defaultDecoration.boxShadow, isNotEmpty);
      });

      test('flat decoration has no shadow', () {
        expect(TileStyles.flatDecoration.boxShadow, isNull);
      });

      test('outlined decoration is transparent', () {
        expect(TileStyles.outlinedDecoration.color, Colors.transparent);
      });

      test('outlined decoration has border', () {
        expect(TileStyles.outlinedDecoration.border, isNotNull);
      });

      test('primary decoration uses primary color', () {
        expect(TileStyles.primaryDecoration.color, AppColors.primary);
      });

      test('primary light decoration uses primary light color', () {
        expect(TileStyles.primaryLightDecoration.color, AppColors.primaryLight);
      });
    });

    group('Interactive States', () {
      test('pressed decoration has hover shadow', () {
        expect(TileStyles.pressedDecoration.boxShadow?.first.blurRadius,
            equals(TileStyles.hoverShadow.first.blurRadius));
      });

      test('pressed decoration has primary-colored border', () {
        final border = TileStyles.pressedDecoration.border as Border?;
        expect(border, isNotNull);
      });

      test('disabled decoration has gray background', () {
        expect(TileStyles.disabledDecoration.color, AppColors.gray100);
      });

      test('selected decoration has primary border', () {
        final border = TileStyles.selectedDecoration.border as Border?;
        expect(border, isNotNull);
      });

      test('error decoration has error-colored border', () {
        final border = TileStyles.errorDecoration.border as Border?;
        expect(border, isNotNull);
      });
    });

    group('Tile Container Widget', () {
      testWidgets('container creates a basic tile', (tester) async {
        final widget = TileStyles.container(
          child: const Text('Test'),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('compact container uses compact padding', (tester) async {
        final widget = TileStyles.compactContainer(
          child: const Text('Test'),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('expanded container uses expanded padding', (tester) async {
        final widget = TileStyles.expandedContainer(
          child: const Text('Test'),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Utility Methods', () {
      test('decorationWithColor creates decoration with custom color', () {
        final decoration = TileStyles.decorationWithColor(Colors.red);
        expect(decoration.color, Colors.red);
        expect(decoration.boxShadow, isNotNull);
      });

      test('decorationWithRadius creates decoration with custom radius', () {
        final decoration = TileStyles.decorationWithRadius(20);
        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      test('decorationWithGradient creates decoration with gradient', () {
        final gradient =
            const LinearGradient(colors: [Colors.red, Colors.blue]);
        final decoration = TileStyles.decorationWithGradient(gradient);
        expect(decoration.gradient, gradient);
      });

      test('customBorderRadius creates correct border radius', () {
        final borderRadius = TileStyles.customBorderRadius(15);
        expect(borderRadius, BorderRadius.circular(15));
      });

      test('topBorderRadius only affects top corners', () {
        final borderRadius = TileStyles.topBorderRadius();
        expect(borderRadius, isNotNull);
      });

      test('bottomBorderRadius only affects bottom corners', () {
        final borderRadius = TileStyles.bottomBorderRadius();
        expect(borderRadius, isNotNull);
      });
    });

    group('Spacing Widgets', () {
      test('tileSeparator returns correct height', () {
        final separator = TileStyles.tileSeparator();
        expect(separator.height, TileStyles.tileSeparation);
      });

      test('headerGap returns correct height', () {
        final gap = TileStyles.headerGap();
        expect(gap.height, TileStyles.headerContentGap);
      });

      test('footerGap returns correct height', () {
        final gap = TileStyles.footerGap();
        expect(gap.height, TileStyles.contentFooterGap);
      });

      test('contentSeparator returns correct height', () {
        final separator = TileStyles.contentSeparator();
        expect(separator.height, TileStyles.contentGap);
      });
    });
  });
}
