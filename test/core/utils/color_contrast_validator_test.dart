import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/color_contrast_validator.dart';

void main() {
  group('ColorContrastValidator', () {
    group('Contrast Ratio Constants', () {
      test('WCAG AA normal text minimum is 4.5:1', () {
        expect(ColorContrastValidator.minContrastNormalText, 4.5);
      });

      test('WCAG AA large text minimum is 3:1', () {
        expect(ColorContrastValidator.minContrastLargeText, 3.0);
      });

      test('WCAG AAA normal text minimum is 7:1', () {
        expect(ColorContrastValidator.minContrastNormalTextAAA, 7.0);
      });

      test('WCAG AAA large text minimum is 4.5:1', () {
        expect(ColorContrastValidator.minContrastLargeTextAAA, 4.5);
      });

      test('large text threshold is 18pt', () {
        expect(ColorContrastValidator.largeTextSizeThreshold, 18.0);
      });
    });

    group('Contrast Ratio Calculation', () {
      test('black on white has maximum contrast', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final ratio = ColorContrastValidator.contrastRatio(black, white);
        expect(ratio, closeTo(21.0, 0.1));
      });

      test('white on white has minimum contrast', () {
        const white = Color(0xFFFFFFFF);
        
        final ratio = ColorContrastValidator.contrastRatio(white, white);
        expect(ratio, closeTo(1.0, 0.01));
      });

      test('contrast ratio is symmetric', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final ratio1 = ColorContrastValidator.contrastRatio(black, white);
        final ratio2 = ColorContrastValidator.contrastRatio(white, black);
        
        expect(ratio1, equals(ratio2));
      });

      test('gray has intermediate contrast with white', () {
        const gray = Color(0xFF808080);
        const white = Color(0xFFFFFFFF);
        
        final ratio = ColorContrastValidator.contrastRatio(gray, white);
        expect(ratio, greaterThan(1.0));
        expect(ratio, lessThan(21.0));
      });
    });

    group('Validation Methods', () {
      test('black on white passes normal text test', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidNormalText(black, white),
          isTrue,
        );
      });

      test('light gray on white fails normal text test', () {
        const lightGray = Color(0xFFCCCCCC);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidNormalText(lightGray, white),
          isFalse,
        );
      });

      test('medium gray on white passes large text test', () {
        const gray = Color(0xFF767676);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidLargeText(gray, white),
          isTrue,
        );
      });

      test('black on white passes AAA requirements', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidNormalTextAAA(black, white),
          isTrue,
        );
        expect(
          ColorContrastValidator.isValidLargeTextAAA(black, white),
          isTrue,
        );
      });

      test('isValidUI checks 3:1 ratio', () {
        const darkGray = Color(0xFF595959);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidUI(darkGray, white),
          isTrue,
        );
      });
    });

    group('Text Style Validation', () {
      test('validates normal text style', () {
        const textStyle = TextStyle(fontSize: 16.0);
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidTextStyle(
            textStyle: textStyle,
            foreground: black,
            background: white,
          ),
          isTrue,
        );
      });

      test('validates large text style', () {
        const textStyle = TextStyle(fontSize: 20.0);
        const gray = Color(0xFF767676);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidTextStyle(
            textStyle: textStyle,
            foreground: gray,
            background: white,
          ),
          isTrue,
        );
      });

      test('validates bold large text', () {
        const textStyle = TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        );
        const gray = Color(0xFF767676);
        const white = Color(0xFFFFFFFF);
        
        expect(
          ColorContrastValidator.isValidTextStyle(
            textStyle: textStyle,
            foreground: gray,
            background: white,
          ),
          isTrue,
        );
      });
    });

    group('Contrast Level Classification', () {
      test('black on white is AAA level', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final level = ColorContrastValidator.getContrastLevel(black, white);
        expect(level, ContrastLevel.aaa);
      });

      test('describes excellent contrast', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final description = ColorContrastValidator.describeContrast(black, white);
        expect(description, contains('Excellent'));
      });

      test('describes poor contrast', () {
        const lightGray = Color(0xFFCCCCCC);
        const white = Color(0xFFFFFFFF);
        
        final description = ColorContrastValidator.describeContrast(lightGray, white);
        expect(description, contains('Poor'));
      });
    });

    group('Color Adjustment', () {
      test('darkenToMeetContrast makes color darker', () {
        const lightGray = Color(0xFFCCCCCC);
        const white = Color(0xFFFFFFFF);
        
        final darkened = ColorContrastValidator.darkenToMeetContrast(
          lightGray,
          white,
        );
        
        expect(darkened, isNotNull);
        if (darkened != null) {
          expect(darkened.red, lessThanOrEqualTo(lightGray.red));
          expect(darkened.green, lessThanOrEqualTo(lightGray.green));
          expect(darkened.blue, lessThanOrEqualTo(lightGray.blue));
        }
      });

      test('lightenToMeetContrast makes color lighter', () {
        const darkGray = Color(0xFF333333);
        const black = Color(0xFF000000);
        
        final lightened = ColorContrastValidator.lightenToMeetContrast(
          darkGray,
          black,
        );
        
        expect(lightened, isNotNull);
        if (lightened != null) {
          expect(lightened.red, greaterThanOrEqualTo(darkGray.red));
          expect(lightened.green, greaterThanOrEqualTo(darkGray.green));
          expect(lightened.blue, greaterThanOrEqualTo(darkGray.blue));
        }
      });

      test('getAccessibleTextColor returns black or white', () {
        const lightGray = Color(0xFFCCCCCC);
        
        final textColor = ColorContrastValidator.getAccessibleTextColor(lightGray);
        expect(textColor == const Color(0xFF000000) || 
               textColor == const Color(0xFFFFFFFF), isTrue);
      });

      test('suggestAccessibleColor meets contrast requirements', () {
        const lightGray = Color(0xFFCCCCCC);
        const white = Color(0xFFFFFFFF);
        
        final suggested = ColorContrastValidator.suggestAccessibleColor(
          lightGray,
          white,
        );
        
        final ratio = ColorContrastValidator.contrastRatio(suggested, white);
        expect(ratio, greaterThanOrEqualTo(4.5));
      });
    });

    group('Utility Methods', () {
      test('formatRatio formats correctly', () {
        final formatted = ColorContrastValidator.formatRatio(4.53);
        expect(formatted, '4.53:1');
      });

      test('isLightColor identifies light colors', () {
        const white = Color(0xFFFFFFFF);
        const lightGray = Color(0xFFCCCCCC);
        
        expect(ColorContrastValidator.isLightColor(white), isTrue);
        expect(ColorContrastValidator.isLightColor(lightGray), isTrue);
      });

      test('isDarkColor identifies dark colors', () {
        const black = Color(0xFF000000);
        const darkGray = Color(0xFF333333);
        
        expect(ColorContrastValidator.isDarkColor(black), isTrue);
        expect(ColorContrastValidator.isDarkColor(darkGray), isTrue);
      });

      test('getPerceivedBrightness returns value between 0-255', () {
        const gray = Color(0xFF808080);
        
        final brightness = ColorContrastValidator.getPerceivedBrightness(gray);
        expect(brightness, greaterThanOrEqualTo(0));
        expect(brightness, lessThanOrEqualTo(255));
      });
    });

    group('Contrast Report', () {
      test('analyzeContrast generates complete report', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final report = ColorContrastValidator.analyzeContrast(black, white);
        
        expect(report.ratio, closeTo(21.0, 0.1));
        expect(report.level, ContrastLevel.aaa);
        expect(report.passesAANormalText, isTrue);
        expect(report.passesAALargeText, isTrue);
        expect(report.passesAAANormalText, isTrue);
        expect(report.passesAAALargeText, isTrue);
      });

      test('report toString includes all information', () {
        const black = Color(0xFF000000);
        const white = Color(0xFFFFFFFF);
        
        final report = ColorContrastValidator.analyzeContrast(black, white);
        final reportString = report.toString();
        
        expect(reportString, contains('ratio'));
        expect(reportString, contains('level'));
        expect(reportString, contains('AA Normal'));
        expect(reportString, contains('AAA Normal'));
      });
    });

    group('ContrastLevel Enum', () {
      test('enum has all levels', () {
        expect(ContrastLevel.values.length, 4);
        expect(ContrastLevel.values, contains(ContrastLevel.aaa));
        expect(ContrastLevel.values, contains(ContrastLevel.aa));
        expect(ContrastLevel.values, contains(ContrastLevel.aaLarge));
        expect(ContrastLevel.values, contains(ContrastLevel.fail));
      });
    });
  });
}
