import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/themes/colors.dart';

void main() {
  group('AppColors', () {
    group('Brand Colors', () {
      test('primary color is sage green', () {
        expect(AppColors.primary, const Color(0xFFA8C5AD));
      });

      test('primary dark is darker variant', () {
        expect(AppColors.primaryDark, const Color(0xFF5A7F62));
      });

      test('primary light is lighter variant', () {
        expect(AppColors.primaryLight, const Color(0xFFD4E4D6));
      });

      test('secondary color is peach/coral', () {
        expect(AppColors.secondary, const Color(0xFFFFB899));
      });
    });

    group('Neutral Colors', () {
      test('white is pure white', () {
        expect(AppColors.white, const Color(0xFFFFFFFF));
      });

      test('black is pure black', () {
        expect(AppColors.black, const Color(0xFF000000));
      });

      test('gray scale has correct values', () {
        expect(AppColors.gray50.value, greaterThan(AppColors.gray100.value));
        expect(AppColors.gray100.value, greaterThan(AppColors.gray200.value));
        expect(AppColors.gray200.value, greaterThan(AppColors.gray300.value));
      });
    });

    group('Semantic Colors', () {
      test('success color is green', () {
        expect(AppColors.success, const Color(0xFF2E7D32));
      });

      test('error color is red', () {
        expect(AppColors.error, const Color(0xFFD32F2F));
      });

      test('warning color is amber', () {
        expect(AppColors.warning, const Color(0xFFFFB74D));
      });

      test('info color is blue', () {
        expect(AppColors.info, const Color(0xFF64B5F6));
      });
    });

    group('Role-Specific Colors', () {
      test('role colors are distinct', () {
        expect(AppColors.roleOwner, isNot(equals(AppColors.rolePartner)));
        expect(AppColors.rolePartner, isNot(equals(AppColors.roleFamily)));
        expect(AppColors.roleFamily, isNot(equals(AppColors.roleFriend)));
      });

      test('role owner is blue', () {
        expect(AppColors.roleOwner, const Color(0xFF5C7CFA));
      });

      test('role partner is purple', () {
        expect(AppColors.rolePartner, const Color(0xFF9775FA));
      });
    });

    group('Text Colors', () {
      test('text primary is dark', () {
        expect(AppColors.textPrimary, AppColors.gray900);
      });

      test('text secondary is medium gray', () {
        expect(AppColors.textSecondary, AppColors.gray600);
      });

      test('text disabled is light gray', () {
        expect(AppColors.textDisabled, AppColors.gray400);
      });

      test('text on primary is white', () {
        expect(AppColors.textOnPrimary, AppColors.white);
      });
    });

    group('Opacity Variants', () {
      test('primary10 has 10% opacity', () {
        final color = AppColors.primary10;
        expect(color.alpha, closeTo(255 * 0.1, 1));
      });

      test('primary50 has 50% opacity', () {
        final color = AppColors.primary50;
        expect(color.alpha, closeTo(255 * 0.5, 1));
      });

      test('black20 has 20% opacity', () {
        final color = AppColors.black20;
        expect(color.alpha, closeTo(255 * 0.2, 1));
      });

      test('white80 has 80% opacity', () {
        final color = AppColors.white80;
        expect(color.alpha, closeTo(255 * 0.8, 1));
      });
    });

    group('Gradients', () {
      test('primary gradient uses primary colors', () {
        expect(AppColors.primaryGradient.colors, contains(AppColors.primary));
        expect(AppColors.primaryGradient.colors, contains(AppColors.primaryDark));
      });

      test('shimmer gradient has three stops', () {
        expect(AppColors.shimmerGradient.colors.length, 3);
        expect(AppColors.shimmerGradient.stops?.length, 3);
      });
    });

    group('Special Purpose Colors', () {
      test('background is light gray', () {
        expect(AppColors.background, AppColors.gray50);
      });

      test('surface is white', () {
        expect(AppColors.surface, AppColors.white);
      });

      test('divider color is defined', () {
        expect(AppColors.divider, AppColors.gray300);
      });

      test('shadow color has low opacity', () {
        expect(AppColors.shadow.alpha, lessThan(100));
      });
    });
  });
}
