import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/spacing.dart';

void main() {
  group('AppSpacing', () {
    group('spacing scale', () {
      test('has correct spacing values based on 8px unit', () {
        expect(AppSpacing.xs, 8.0);
        expect(AppSpacing.s, 12.0);
        expect(AppSpacing.m, 16.0);
        expect(AppSpacing.l, 24.0);
        expect(AppSpacing.xl, 32.0);
        expect(AppSpacing.xxl, 48.0);
      });

      test('spacing values are positive', () {
        expect(AppSpacing.xs, greaterThan(0));
        expect(AppSpacing.s, greaterThan(0));
        expect(AppSpacing.m, greaterThan(0));
        expect(AppSpacing.l, greaterThan(0));
        expect(AppSpacing.xl, greaterThan(0));
        expect(AppSpacing.xxl, greaterThan(0));
      });

      test('spacing values follow ascending order', () {
        expect(AppSpacing.xs, lessThan(AppSpacing.s));
        expect(AppSpacing.s, lessThan(AppSpacing.m));
        expect(AppSpacing.m, lessThan(AppSpacing.l));
        expect(AppSpacing.l, lessThan(AppSpacing.xl));
        expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
      });

      test('xs follows 8px base unit', () {
        expect(AppSpacing.xs % 8, 0);
      });

      test('s is reasonable compact spacing', () {
        expect(AppSpacing.s, 12.0);
      });

      test('m is standard spacing', () {
        expect(AppSpacing.m, 16.0);
      });
    });

    group('EdgeInsets presets', () {
      test('screenPadding uses large spacing', () {
        expect(AppSpacing.screenPadding, const EdgeInsets.all(AppSpacing.l));
        expect(AppSpacing.screenPadding.left, 24.0);
        expect(AppSpacing.screenPadding.right, 24.0);
        expect(AppSpacing.screenPadding.top, 24.0);
        expect(AppSpacing.screenPadding.bottom, 24.0);
      });

      test('cardPadding uses medium spacing', () {
        expect(AppSpacing.cardPadding, const EdgeInsets.all(AppSpacing.m));
        expect(AppSpacing.cardPadding.left, 16.0);
        expect(AppSpacing.cardPadding.right, 16.0);
        expect(AppSpacing.cardPadding.top, 16.0);
        expect(AppSpacing.cardPadding.bottom, 16.0);
      });

      test('compactPadding uses small spacing', () {
        expect(AppSpacing.compactPadding, const EdgeInsets.all(AppSpacing.s));
        expect(AppSpacing.compactPadding.left, 12.0);
        expect(AppSpacing.compactPadding.right, 12.0);
      });

      test('horizontalPadding has horizontal values only', () {
        expect(
          AppSpacing.horizontalPadding,
          const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        );
        expect(AppSpacing.horizontalPadding.left, 16.0);
        expect(AppSpacing.horizontalPadding.right, 16.0);
        expect(AppSpacing.horizontalPadding.top, 0);
        expect(AppSpacing.horizontalPadding.bottom, 0);
      });

      test('verticalPadding has vertical values only', () {
        expect(
          AppSpacing.verticalPadding,
          const EdgeInsets.symmetric(vertical: AppSpacing.m),
        );
        expect(AppSpacing.verticalPadding.top, 16.0);
        expect(AppSpacing.verticalPadding.bottom, 16.0);
        expect(AppSpacing.verticalPadding.left, 0);
        expect(AppSpacing.verticalPadding.right, 0);
      });
    });

    group('SizedBox presets - vertical gaps', () {
      test('verticalGapXS has correct height', () {
        expect(AppSpacing.verticalGapXS, const SizedBox(height: AppSpacing.xs));
        expect(AppSpacing.verticalGapXS.height, 8.0);
      });

      test('verticalGapS has correct height', () {
        expect(AppSpacing.verticalGapS, const SizedBox(height: AppSpacing.s));
        expect(AppSpacing.verticalGapS.height, 12.0);
      });

      test('verticalGapM has correct height', () {
        expect(AppSpacing.verticalGapM, const SizedBox(height: AppSpacing.m));
        expect(AppSpacing.verticalGapM.height, 16.0);
      });

      test('verticalGapL has correct height', () {
        expect(AppSpacing.verticalGapL, const SizedBox(height: AppSpacing.l));
        expect(AppSpacing.verticalGapL.height, 24.0);
      });

      test('verticalGapXL has correct height', () {
        expect(AppSpacing.verticalGapXL, const SizedBox(height: AppSpacing.xl));
        expect(AppSpacing.verticalGapXL.height, 32.0);
      });
    });

    group('SizedBox presets - horizontal gaps', () {
      test('horizontalGapXS has correct width', () {
        expect(
            AppSpacing.horizontalGapXS, const SizedBox(width: AppSpacing.xs));
        expect(AppSpacing.horizontalGapXS.width, 8.0);
      });

      test('horizontalGapS has correct width', () {
        expect(AppSpacing.horizontalGapS, const SizedBox(width: AppSpacing.s));
        expect(AppSpacing.horizontalGapS.width, 12.0);
      });

      test('horizontalGapM has correct width', () {
        expect(AppSpacing.horizontalGapM, const SizedBox(width: AppSpacing.m));
        expect(AppSpacing.horizontalGapM.width, 16.0);
      });

      test('horizontalGapL has correct width', () {
        expect(AppSpacing.horizontalGapL, const SizedBox(width: AppSpacing.l));
        expect(AppSpacing.horizontalGapL.width, 24.0);
      });

      test('horizontalGapXL has correct width', () {
        expect(
            AppSpacing.horizontalGapXL, const SizedBox(width: AppSpacing.xl));
        expect(AppSpacing.horizontalGapXL.width, 32.0);
      });
    });

    group('consistency', () {
      test('preset paddings match spacing values', () {
        expect(AppSpacing.screenPadding.left, AppSpacing.l);
        expect(AppSpacing.cardPadding.left, AppSpacing.m);
        expect(AppSpacing.compactPadding.left, AppSpacing.s);
      });

      test('preset gaps match spacing values', () {
        expect(AppSpacing.verticalGapXS.height, AppSpacing.xs);
        expect(AppSpacing.verticalGapS.height, AppSpacing.s);
        expect(AppSpacing.verticalGapM.height, AppSpacing.m);
        expect(AppSpacing.verticalGapL.height, AppSpacing.l);
        expect(AppSpacing.verticalGapXL.height, AppSpacing.xl);
      });
    });

    group('8px base unit verification', () {
      test('xs is base unit', () {
        expect(AppSpacing.xs, 8.0);
      });

      test('m is 2x base unit', () {
        expect(AppSpacing.m, AppSpacing.xs * 2);
      });

      test('l is 3x base unit', () {
        expect(AppSpacing.l, AppSpacing.xs * 3);
      });

      test('xl is 4x base unit', () {
        expect(AppSpacing.xl, AppSpacing.xs * 4);
      });

      test('xxl is 6x base unit', () {
        expect(AppSpacing.xxl, AppSpacing.xs * 6);
      });
    });
  });
}
