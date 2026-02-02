import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/themes/text_styles.dart';
import 'package:nonna_app/core/themes/colors.dart';

void main() {
  group('AppTextStyles', () {
    group('Heading Styles', () {
      test('h1 is largest heading', () {
        expect(AppTextStyles.h1.fontSize, 32);
        expect(AppTextStyles.h1.fontWeight, FontWeight.w700);
      });

      test('h2 is large heading', () {
        expect(AppTextStyles.h2.fontSize, 28);
        expect(AppTextStyles.h2.fontWeight, FontWeight.w700);
      });

      test('h3 is medium-large heading', () {
        expect(AppTextStyles.h3.fontSize, 24);
        expect(AppTextStyles.h3.fontWeight, FontWeight.w600);
      });

      test('headings decrease in size h1 > h2 > h3 > h4 > h5 > h6', () {
        expect(
            AppTextStyles.h1.fontSize, greaterThan(AppTextStyles.h2.fontSize!));
        expect(
            AppTextStyles.h2.fontSize, greaterThan(AppTextStyles.h3.fontSize!));
        expect(
            AppTextStyles.h3.fontSize, greaterThan(AppTextStyles.h4.fontSize!));
        expect(
            AppTextStyles.h4.fontSize, greaterThan(AppTextStyles.h5.fontSize!));
        expect(
            AppTextStyles.h5.fontSize, greaterThan(AppTextStyles.h6.fontSize!));
      });

      test('all headings have primary text color', () {
        expect(AppTextStyles.h1.color, AppColors.textPrimary);
        expect(AppTextStyles.h2.color, AppColors.textPrimary);
        expect(AppTextStyles.h3.color, AppColors.textPrimary);
      });
    });

    group('Body Text Styles', () {
      test('bodyLarge is 18px', () {
        expect(AppTextStyles.bodyLarge.fontSize, 18);
      });

      test('bodyMedium is 16px (default)', () {
        expect(AppTextStyles.bodyMedium.fontSize, 16);
      });

      test('bodySmall is 14px', () {
        expect(AppTextStyles.bodySmall.fontSize, 14);
      });

      test('body sizes decrease: large > medium > small', () {
        expect(AppTextStyles.bodyLarge.fontSize,
            greaterThan(AppTextStyles.bodyMedium.fontSize!));
        expect(AppTextStyles.bodyMedium.fontSize,
            greaterThan(AppTextStyles.bodySmall.fontSize!));
      });

      test('bodySmall uses secondary text color', () {
        expect(AppTextStyles.bodySmall.color, AppColors.textSecondary);
      });

      test('bold variants have increased font weight', () {
        expect(AppTextStyles.bodyLargeBold.fontWeight, FontWeight.w700);
        expect(AppTextStyles.bodyMediumBold.fontWeight, FontWeight.w700);
        expect(AppTextStyles.bodySmallBold.fontWeight, FontWeight.w600);
      });
    });

    group('Caption & Label Styles', () {
      test('caption is 14px', () {
        expect(AppTextStyles.caption.fontSize, 14);
      });

      test('captionSmall is 12px', () {
        expect(AppTextStyles.captionSmall.fontSize, 12);
      });

      test('captionTiny is 10px', () {
        expect(AppTextStyles.captionTiny.fontSize, 10);
      });

      test('captions use secondary text color', () {
        expect(AppTextStyles.caption.color, AppColors.textSecondary);
        expect(AppTextStyles.captionSmall.color, AppColors.textSecondary);
      });

      test('labels are bold', () {
        expect(AppTextStyles.label.fontWeight, FontWeight.w600);
        expect(AppTextStyles.labelSmall.fontWeight, FontWeight.w600);
      });
    });

    group('Button Text Styles', () {
      test('button sizes are defined', () {
        expect(AppTextStyles.buttonLarge.fontSize, 16);
        expect(AppTextStyles.buttonMedium.fontSize, 14);
        expect(AppTextStyles.buttonSmall.fontSize, 12);
      });

      test('all button styles have increased letter spacing', () {
        expect(AppTextStyles.buttonLarge.letterSpacing, 0.5);
        expect(AppTextStyles.buttonMedium.letterSpacing, 0.5);
        expect(AppTextStyles.buttonSmall.letterSpacing, 0.5);
      });

      test('all button styles are semi-bold', () {
        expect(AppTextStyles.buttonLarge.fontWeight, FontWeight.w600);
        expect(AppTextStyles.buttonMedium.fontWeight, FontWeight.w600);
        expect(AppTextStyles.buttonSmall.fontWeight, FontWeight.w600);
      });
    });

    group('Special Purpose Styles', () {
      test('tile title is 18px semi-bold', () {
        expect(AppTextStyles.tileTitle.fontSize, 18);
        expect(AppTextStyles.tileTitle.fontWeight, FontWeight.w600);
      });

      test('tile subtitle is smaller', () {
        expect(AppTextStyles.tileSubtitle.fontSize,
            lessThan(AppTextStyles.tileTitle.fontSize!));
      });

      test('number styles are bold', () {
        expect(AppTextStyles.numberLarge.fontWeight, FontWeight.w700);
        expect(AppTextStyles.numberMedium.fontWeight, FontWeight.w700);
        expect(AppTextStyles.numberSmall.fontWeight, FontWeight.w600);
      });

      test('link style has underline', () {
        expect(AppTextStyles.link.decoration, TextDecoration.underline);
        expect(AppTextStyles.linkSmall.decoration, TextDecoration.underline);
      });

      test('link uses primary color', () {
        expect(AppTextStyles.link.color, AppColors.primary);
      });

      test('error style uses error color', () {
        expect(AppTextStyles.error.color, AppColors.error);
      });

      test('success style uses success color', () {
        expect(AppTextStyles.success.color, AppColors.success);
      });

      test('placeholder uses disabled color', () {
        expect(AppTextStyles.placeholder.color, AppColors.textDisabled);
      });

      test('overline has increased letter spacing', () {
        expect(AppTextStyles.overline.letterSpacing, greaterThan(0.5));
      });
    });

    group('Text Theme', () {
      test('textTheme includes all Material text styles', () {
        final textTheme = AppTextStyles.textTheme;

        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
      });
    });

    group('Utility Methods', () {
      test('withColor changes text color', () {
        final style =
            AppTextStyles.withColor(AppTextStyles.bodyMedium, Colors.red);
        expect(style.color, Colors.red);
        expect(style.fontSize, AppTextStyles.bodyMedium.fontSize);
      });

      test('withWeight changes font weight', () {
        final style = AppTextStyles.withWeight(
          AppTextStyles.bodyMedium,
          FontWeight.w900,
        );
        expect(style.fontWeight, FontWeight.w900);
      });

      test('withSize changes font size', () {
        final style = AppTextStyles.withSize(AppTextStyles.bodyMedium, 20);
        expect(style.fontSize, 20);
      });

      test('primary applies primary color', () {
        final style = AppTextStyles.primary(AppTextStyles.bodyMedium);
        expect(style.color, AppColors.primary);
      });

      test('secondary applies secondary text color', () {
        final style = AppTextStyles.secondary(AppTextStyles.bodyMedium);
        expect(style.color, AppColors.textSecondary);
      });

      test('disabled applies disabled color', () {
        final style = AppTextStyles.disabled(AppTextStyles.bodyMedium);
        expect(style.color, AppColors.textDisabled);
      });

      test('onPrimary applies white color', () {
        final style = AppTextStyles.onPrimary(AppTextStyles.bodyMedium);
        expect(style.color, AppColors.textOnPrimary);
      });
    });

    group('Line Heights', () {
      test('all text styles have defined line heights', () {
        expect(AppTextStyles.h1.height, isNotNull);
        expect(AppTextStyles.bodyMedium.height, isNotNull);
        expect(AppTextStyles.caption.height, isNotNull);
      });

      test('line heights are reasonable (between 1.2 and 1.6)', () {
        expect(AppTextStyles.h1.height, greaterThanOrEqualTo(1.2));
        expect(AppTextStyles.h1.height, lessThanOrEqualTo(1.6));

        expect(AppTextStyles.bodyMedium.height, greaterThanOrEqualTo(1.2));
        expect(AppTextStyles.bodyMedium.height, lessThanOrEqualTo(1.6));
      });
    });
  });
}
