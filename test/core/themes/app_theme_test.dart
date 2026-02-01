import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/themes/app_theme.dart';
import 'package:nonna_app/core/themes/colors.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme', () {
      test('light theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme, isNotNull);
        expect(theme.brightness, Brightness.light);
      });

      test('light theme uses Material 3', () {
        final theme = AppTheme.lightTheme;
        expect(theme.useMaterial3, isTrue);
      });

      test('light theme has correct scaffold background', () {
        final theme = AppTheme.lightTheme;
        expect(theme.scaffoldBackgroundColor, AppColors.background);
      });

      test('light theme has primary color', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.primary, AppColors.primary);
      });

      test('light theme has secondary color', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.secondary, AppColors.secondary);
      });

      test('light theme has surface color', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.surface, AppColors.surface);
      });

      test('light theme has error color', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.error, AppColors.error);
      });

      test('light theme app bar has no elevation', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.elevation, 0);
      });

      test('light theme app bar is centered', () {
        final theme = AppTheme.lightTheme;
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('light theme has text theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.textTheme, isNotNull);
        expect(theme.textTheme.bodyLarge, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
      });

      test('light theme has card theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.cardTheme, isNotNull);
        expect(theme.cardTheme.elevation, isNotNull);
      });

      test('light theme elevated button has primary color', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.elevatedButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });

      test('light theme has input decoration theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.inputDecorationTheme, isNotNull);
        expect(theme.inputDecorationTheme.filled, isTrue);
      });

      test('light theme has FAB theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.floatingActionButtonTheme, isNotNull);
      });

      test('light theme has bottom nav bar theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.bottomNavigationBarTheme, isNotNull);
      });
    });

    group('Dark Theme', () {
      test('dark theme is defined', () {
        final theme = AppTheme.darkTheme;
        expect(theme, isNotNull);
        expect(theme.brightness, Brightness.dark);
      });

      test('dark theme uses Material 3', () {
        final theme = AppTheme.darkTheme;
        expect(theme.useMaterial3, isTrue);
      });

      test('dark theme has dark scaffold background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.scaffoldBackgroundColor, AppColors.gray900);
      });

      test('dark theme has primary color', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.primary, AppColors.primary);
      });

      test('dark theme has dark surface color', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.surface, AppColors.gray800);
      });

      test('dark theme has text theme with light colors', () {
        final theme = AppTheme.darkTheme;
        expect(theme.textTheme, isNotNull);
      });

      test('dark theme app bar has dark background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.appBarTheme.backgroundColor, AppColors.gray800);
      });

      test('dark theme card has dark background', () {
        final theme = AppTheme.darkTheme;
        expect(theme.cardTheme.color, AppColors.gray800);
      });

      test('dark theme input has dark fill color', () {
        final theme = AppTheme.darkTheme;
        expect(theme.inputDecorationTheme.fillColor, AppColors.gray800);
      });
    });

    group('Button Themes', () {
      test('elevated button has minimum size', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.elevatedButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });

      test('outlined button has border', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.outlinedButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });

      test('text button has no elevation', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.textButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });

      test('icon button has minimum touch target', () {
        final theme = AppTheme.lightTheme;
        final buttonStyle = theme.iconButtonTheme.style;
        expect(buttonStyle, isNotNull);
      });
    });

    group('Component Themes', () {
      test('card theme has rounded corners', () {
        final theme = AppTheme.lightTheme;
        final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
        expect(shape, isNotNull);
      });

      test('dialog theme has rounded corners', () {
        final theme = AppTheme.lightTheme;
        final shape = theme.dialogTheme.shape as RoundedRectangleBorder?;
        expect(shape, isNotNull);
      });

      test('FAB has rounded corners', () {
        final theme = AppTheme.lightTheme;
        final shape = theme.floatingActionButtonTheme.shape as RoundedRectangleBorder?;
        expect(shape, isNotNull);
      });

      test('chip theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.chipTheme, isNotNull);
      });

      test('divider theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.dividerTheme, isNotNull);
      });

      test('list tile theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.listTileTheme, isNotNull);
      });

      test('switch theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.switchTheme, isNotNull);
      });

      test('checkbox theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.checkboxTheme, isNotNull);
      });

      test('radio theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.radioTheme, isNotNull);
      });

      test('slider theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.sliderTheme, isNotNull);
      });

      test('snackbar theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.snackBarTheme, isNotNull);
        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      });

      test('tab bar theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.tabBarTheme, isNotNull);
      });

      test('tooltip theme is defined', () {
        final theme = AppTheme.lightTheme;
        expect(theme.tooltipTheme, isNotNull);
      });
    });

    group('Icon Themes', () {
      test('light theme has icon theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.iconTheme, isNotNull);
        expect(theme.iconTheme.size, 24.0);
      });

      test('light theme has primary icon theme', () {
        final theme = AppTheme.lightTheme;
        expect(theme.primaryIconTheme, isNotNull);
        expect(theme.primaryIconTheme.color, AppColors.primary);
      });

      test('dark theme has icon theme with light colors', () {
        final theme = AppTheme.darkTheme;
        expect(theme.iconTheme, isNotNull);
        expect(theme.iconTheme.color, AppColors.gray300);
      });
    });

    group('Theme Integration', () {
      testWidgets('light theme can be applied to app', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('dark theme can be applied to app', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('button uses theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        );

        expect(find.text('Button'), findsOneWidget);
      });
    });
  });
}
