import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/extensions/context_extensions.dart';

void main() {
  group('ContextExtensions', () {
    // Helper to create a widget with context
    Widget buildTestWidget({
      required Widget child,
      ThemeData? theme,
    }) {
      return MaterialApp(
        theme: theme ?? ThemeData.light(),
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('theme access', () {
      testWidgets('theme returns current theme', (tester) async {
        late ThemeData capturedTheme;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedTheme = context.theme;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedTheme, isNotNull);
        expect(capturedTheme.brightness, Brightness.light);
      });

      testWidgets('textTheme returns current text theme', (tester) async {
        late TextTheme capturedTextTheme;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedTextTheme = context.textTheme;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedTextTheme, isNotNull);
        expect(capturedTextTheme.bodyLarge, isNotNull);
      });

      testWidgets('colorScheme returns current color scheme', (tester) async {
        late ColorScheme capturedColorScheme;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedColorScheme = context.colorScheme;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedColorScheme, isNotNull);
        expect(capturedColorScheme.primary, isNotNull);
      });

      testWidgets('primaryColor returns primary color', (tester) async {
        late Color capturedColor;
        final customTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
        
        await tester.pumpWidget(
          buildTestWidget(
            theme: customTheme,
            child: Builder(
              builder: (context) {
                capturedColor = context.primaryColor;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedColor, isNotNull);
        expect(capturedColor, equals(customTheme.colorScheme.primary));
      });

      testWidgets('secondaryColor returns secondary color', (tester) async {
        late Color capturedColor;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedColor = context.secondaryColor;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedColor, isNotNull);
      });

      testWidgets('backgroundColor returns surface color', (tester) async {
        late Color capturedColor;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedColor = context.backgroundColor;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedColor, isNotNull);
      });

      testWidgets('errorColor returns error color', (tester) async {
        late Color capturedColor;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedColor = context.errorColor;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedColor, isNotNull);
      });

      testWidgets('isDarkMode returns false for light theme', (tester) async {
        late bool isDark;
        
        await tester.pumpWidget(
          buildTestWidget(
            theme: ThemeData.light(),
            child: Builder(
              builder: (context) {
                isDark = context.isDarkMode;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isDark, false);
      });

      testWidgets('isDarkMode returns true for dark theme', (tester) async {
        late bool isDark;
        
        await tester.pumpWidget(
          buildTestWidget(
            theme: ThemeData.dark(),
            child: Builder(
              builder: (context) {
                isDark = context.isDarkMode;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isDark, true);
      });

      testWidgets('isLightMode returns true for light theme', (tester) async {
        late bool isLight;
        
        await tester.pumpWidget(
          buildTestWidget(
            theme: ThemeData.light(),
            child: Builder(
              builder: (context) {
                isLight = context.isLightMode;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isLight, true);
      });

      testWidgets('isLightMode returns false for dark theme', (tester) async {
        late bool isLight;
        
        await tester.pumpWidget(
          buildTestWidget(
            theme: ThemeData.dark(),
            child: Builder(
              builder: (context) {
                isLight = context.isLightMode;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isLight, false);
      });
    });

    group('MediaQuery shortcuts', () {
      testWidgets('screenSize returns screen dimensions', (tester) async {
        late Size capturedSize;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedSize = context.screenSize;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedSize, isNotNull);
        expect(capturedSize.width, greaterThan(0));
        expect(capturedSize.height, greaterThan(0));
      });

      testWidgets('screenWidth returns width', (tester) async {
        late double capturedWidth;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedWidth = context.screenWidth;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedWidth, greaterThan(0));
      });

      testWidgets('screenHeight returns height', (tester) async {
        late double capturedHeight;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedHeight = context.screenHeight;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedHeight, greaterThan(0));
      });

      testWidgets('devicePixelRatio returns ratio', (tester) async {
        late double capturedRatio;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedRatio = context.devicePixelRatio;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedRatio, greaterThan(0));
      });

      testWidgets('textScaleFactor returns scale factor', (tester) async {
        late double capturedScale;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedScale = context.textScaleFactor;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedScale, greaterThan(0));
      });

      testWidgets('orientation returns current orientation', (tester) async {
        late Orientation capturedOrientation;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedOrientation = context.orientation;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedOrientation, isNotNull);
      });

      testWidgets('isPortrait returns correct value', (tester) async {
        late bool isPortrait;
        
        // Set portrait orientation
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isPortrait = context.isPortrait;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isPortrait, true);
        
        addTearDown(tester.view.reset);
      });

      testWidgets('isLandscape returns correct value', (tester) async {
        late bool isLandscape;
        
        // Set landscape orientation
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isLandscape = context.isLandscape;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isLandscape, true);
        
        addTearDown(tester.view.reset);
      });

      testWidgets('padding returns safe area padding', (tester) async {
        late EdgeInsets capturedPadding;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedPadding = context.padding;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedPadding, isNotNull);
      });

      testWidgets('viewInsets returns keyboard insets', (tester) async {
        late EdgeInsets capturedInsets;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedInsets = context.viewInsets;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedInsets, isNotNull);
      });

      testWidgets('viewPadding returns view padding', (tester) async {
        late EdgeInsets capturedPadding;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedPadding = context.viewPadding;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedPadding, isNotNull);
      });

      testWidgets('isKeyboardVisible returns false when no keyboard', (tester) async {
        late bool isVisible;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isVisible = context.isKeyboardVisible;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isVisible, false);
      });

      testWidgets('isKeyboardVisible returns true with keyboard', (tester) async {
        late bool isVisible;
        
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isVisible = context.isKeyboardVisible;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isVisible, true);
        
        addTearDown(tester.view.reset);
      });
    });

    group('Navigator shortcuts', () {
      testWidgets('navigator returns NavigatorState', (tester) async {
        late NavigatorState capturedNavigator;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                capturedNavigator = context.navigator;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedNavigator, isNotNull);
      });

      testWidgets('canPop returns correct value', (tester) async {
        late bool canPopValue;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                canPopValue = context.canPop;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(canPopValue, false); // Root route cannot pop
      });

      testWidgets('push navigates to new route', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.push(
                      MaterialPageRoute(
                        builder: (_) => const Text('New Page'),
                      ),
                    );
                  },
                  child: const Text('Push'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();
        
        expect(find.text('New Page'), findsOneWidget);
      });

      testWidgets('pushNamed navigates to named route', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/test': (context) => const Text('Test Route'),
            },
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.pushNamed('/test');
                  },
                  child: const Text('Push Named'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Push Named'));
        await tester.pumpAndSettle();
        
        expect(find.text('Test Route'), findsOneWidget);
      });

      testWidgets('pop removes current route', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.push(
                      MaterialPageRoute(
                        builder: (_) => ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Pop'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Push'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Pop'));
        await tester.pumpAndSettle();
        
        expect(find.text('Pop'), findsNothing);
      });
    });

    group('ScaffoldMessenger shortcuts', () {
      testWidgets('showSnackBar displays snackbar', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.showSnackBar('Test message');
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Show'));
        await tester.pump();
        
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('showErrorSnackBar displays error snackbar', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.showErrorSnackBar('Error message');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Show Error'));
        await tester.pump();
        
        expect(find.text('Error message'), findsOneWidget);
      });

      testWidgets('showSuccessSnackBar displays success snackbar', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.showSuccessSnackBar('Success message');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Show Success'));
        await tester.pump();
        
        expect(find.text('Success message'), findsOneWidget);
      });
    });

    group('Focus shortcuts', () {
      testWidgets('unfocus dismisses keyboard', (tester) async {
        final focusNode = FocusNode();
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    TextField(focusNode: focusNode),
                    ElevatedButton(
                      onPressed: () => context.unfocus(),
                      child: const Text('Unfocus'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        
        focusNode.requestFocus();
        await tester.pump();
        
        expect(focusNode.hasFocus, true);
        
        await tester.tap(find.text('Unfocus'));
        await tester.pump();
        
        expect(focusNode.hasFocus, false);
        
        focusNode.dispose();
      });

      testWidgets('requestFocus focuses a node', (tester) async {
        final focusNode = FocusNode();
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    TextField(focusNode: focusNode),
                    ElevatedButton(
                      onPressed: () => context.requestFocus(focusNode),
                      child: const Text('Focus'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        
        expect(focusNode.hasFocus, false);
        
        await tester.tap(find.text('Focus'));
        await tester.pump();
        
        expect(focusNode.hasFocus, true);
        
        focusNode.dispose();
      });
    });

    group('Dialog shortcuts', () {
      testWidgets('showDialogCustom displays dialog', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.showDialogCustom(
                      builder: (_) => const AlertDialog(
                        title: Text('Test Dialog'),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();
        
        expect(find.text('Test Dialog'), findsOneWidget);
      });

      testWidgets('showAlertDialog displays alert', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.showAlertDialog(
                      title: 'Alert Title',
                      message: 'Alert Message',
                      positiveButton: 'OK',
                      negativeButton: 'Cancel',
                    );
                  },
                  child: const Text('Show Alert'),
                );
              },
            ),
          ),
        );
        
        await tester.tap(find.text('Show Alert'));
        await tester.pumpAndSettle();
        
        expect(find.text('Alert Title'), findsOneWidget);
        expect(find.text('Alert Message'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });
    });

    group('Responsive helpers', () {
      testWidgets('isMobile returns true for narrow screens', (tester) async {
        late bool isMobileValue;
        
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isMobileValue = context.isMobile;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isMobileValue, true);
        
        addTearDown(tester.view.reset);
      });

      testWidgets('isTablet returns true for medium screens', (tester) async {
        late bool isTabletValue;
        
        tester.view.physicalSize = const Size(700, 1000);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isTabletValue = context.isTablet;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isTabletValue, true);
        
        addTearDown(tester.view.reset);
      });

      testWidgets('isDesktop returns true for wide screens', (tester) async {
        late bool isDesktopValue;
        
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                isDesktopValue = context.isDesktop;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(isDesktopValue, true);
        
        addTearDown(tester.view.reset);
      });

      testWidgets('responsive returns correct value for mobile', (tester) async {
        late String result;
        
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'Mobile',
                  tablet: 'Tablet',
                  desktop: 'Desktop',
                );
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(result, 'Mobile');
        
        addTearDown(tester.view.reset);
      });

      testWidgets('responsive returns correct value for tablet', (tester) async {
        late String result;
        
        tester.view.physicalSize = const Size(700, 1000);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'Mobile',
                  tablet: 'Tablet',
                  desktop: 'Desktop',
                );
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(result, 'Tablet');
        
        addTearDown(tester.view.reset);
      });

      testWidgets('responsive returns correct value for desktop', (tester) async {
        late String result;
        
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'Mobile',
                  tablet: 'Tablet',
                  desktop: 'Desktop',
                );
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(result, 'Desktop');
        
        addTearDown(tester.view.reset);
      });

      testWidgets('responsive falls back to mobile when tablet not specified', (tester) async {
        late String result;
        
        tester.view.physicalSize = const Size(700, 1000);
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          buildTestWidget(
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'Mobile',
                  desktop: 'Desktop',
                );
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(result, 'Mobile');
        
        addTearDown(tester.view.reset);
      });
    });

    group('Localization shortcuts', () {
      testWidgets('locale returns current locale', (tester) async {
        late Locale capturedLocale;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            home: Builder(
              builder: (context) {
                capturedLocale = context.locale;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(capturedLocale.languageCode, 'en');
      });

      testWidgets('languageCode returns language code', (tester) async {
        late String languageCode;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('es', 'ES'),
            home: Builder(
              builder: (context) {
                languageCode = context.languageCode;
                return const SizedBox();
              },
            ),
          ),
        );
        
        expect(languageCode, 'es');
      });
    });
  });
}

// Helper class for testing view insets
class FakeViewPadding extends ViewPadding {
  const FakeViewPadding({
    super.left = 0.0,
    super.top = 0.0,
    super.right = 0.0,
    super.bottom = 0.0,
  });
}
