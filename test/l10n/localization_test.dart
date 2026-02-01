import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/l10n/l10n.dart';

void main() {
  group('L10n', () {
    test('should contain supported locales', () {
      expect(L10n.all, isNotEmpty);
      expect(L10n.all.length, equals(2));
      expect(L10n.all, contains(const Locale('en')));
      expect(L10n.all, contains(const Locale('es')));
    });

    test('should have English as fallback locale', () {
      expect(L10n.fallback, equals(const Locale('en')));
    });

    test('should return correct locale names', () {
      expect(L10n.getLocaleName(const Locale('en')), equals('English'));
      expect(L10n.getLocaleName(const Locale('es')), equals('Español'));
    });

    test('should return correct native locale names', () {
      expect(L10n.getNativeLocaleName(const Locale('en')), equals('English'));
      expect(L10n.getNativeLocaleName(const Locale('es')), equals('Español'));
    });

    test('should check if locale is supported', () {
      expect(L10n.isSupported(const Locale('en')), isTrue);
      expect(L10n.isSupported(const Locale('es')), isTrue);
      expect(L10n.isSupported(const Locale('fr')), isFalse);
      expect(L10n.isSupported(const Locale('de')), isFalse);
    });

    test('should return locale from language code', () {
      expect(L10n.fromLanguageCode('en'), equals(const Locale('en')));
      expect(L10n.fromLanguageCode('es'), equals(const Locale('es')));
      expect(L10n.fromLanguageCode('fr'), equals(L10n.fallback));
      expect(L10n.fromLanguageCode(null), isNull);
    });

    group('localeResolutionCallback', () {
      test('should return fallback when no locale provided', () {
        final result = L10n.localeResolutionCallback(null, L10n.all);
        expect(result, equals(L10n.fallback));
      });

      test('should return exact match when available', () {
        final result = L10n.localeResolutionCallback(
          const Locale('es', 'ES'),
          [const Locale('en'), const Locale('es', 'ES')],
        );
        expect(result, equals(const Locale('es', 'ES')));
      });

      test('should return language match when country code differs', () {
        final result = L10n.localeResolutionCallback(
          const Locale('es', 'MX'),
          [const Locale('en'), const Locale('es')],
        );
        expect(result, equals(const Locale('es')));
      });

      test('should return fallback for unsupported locale', () {
        final result = L10n.localeResolutionCallback(
          const Locale('fr'),
          L10n.all,
        );
        expect(result, equals(L10n.fallback));
      });
    });
  });

  group('AppLocalizations', () {
    testWidgets('should load English localizations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.appTitle);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Nonna'), findsOneWidget);
    });

    testWidgets('should load Spanish localizations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.welcome);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Bienvenido'), findsOneWidget);
    });

    testWidgets('should have all common translations in English',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.common_ok),
                  Text(l10n.common_cancel),
                  Text(l10n.common_save),
                  Text(l10n.common_delete),
                  Text(l10n.common_retry),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should have all common translations in Spanish',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.common_ok),
                  Text(l10n.common_cancel),
                  Text(l10n.common_save),
                  Text(l10n.common_delete),
                  Text(l10n.common_retry),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should handle parametrized messages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.helloUser('Maria'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Hello, Maria!'), findsOneWidget);
    });

    testWidgets('should handle parametrized messages in Spanish',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.helloUser('María'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('¡Hola, María!'), findsOneWidget);
    });

    testWidgets('should handle plural forms in English', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.plurals_recipes(0)),
                  Text(l10n.plurals_recipes(1)),
                  Text(l10n.plurals_recipes(5)),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No recipes'), findsOneWidget);
      expect(find.text('1 recipe'), findsOneWidget);
      expect(find.text('5 recipes'), findsOneWidget);
    });

    testWidgets('should handle plural forms in Spanish', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.plurals_recipes(0)),
                  Text(l10n.plurals_recipes(1)),
                  Text(l10n.plurals_recipes(5)),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Sin recetas'), findsOneWidget);
      expect(find.text('1 receta'), findsOneWidget);
      expect(find.text('5 recetas'), findsOneWidget);
    });

    testWidgets('should have error messages in both locales', (tester) async {
      for (final locale in L10n.all) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.all,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Column(
                  children: [
                    Text(l10n.error_title),
                    Text(l10n.error_generic),
                    Text(l10n.error_network),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that error translations exist (not checking exact text)
        expect(find.byType(Text), findsNWidgets(3));
      }
    });

    testWidgets('should have navigation labels in both locales',
        (tester) async {
      for (final locale in L10n.all) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.all,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Column(
                  children: [
                    Text(l10n.nav_home),
                    Text(l10n.nav_recipes),
                    Text(l10n.nav_favorites),
                    Text(l10n.nav_profile),
                    Text(l10n.nav_settings),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that navigation translations exist
        expect(find.byType(Text), findsNWidgets(5));
      }
    });

    testWidgets('should have auth strings in both locales', (tester) async {
      for (final locale in L10n.all) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.all,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Column(
                  children: [
                    Text(l10n.auth_login),
                    Text(l10n.auth_signup),
                    Text(l10n.auth_email),
                    Text(l10n.auth_password),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that auth translations exist
        expect(find.byType(Text), findsNWidgets(4));
      }
    });

    testWidgets('should switch locale dynamically', (tester) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: L10n.all,
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Column(
                    children: [
                      Text(l10n.welcome),
                      ElevatedButton(
                        onPressed: () {
                          localeNotifier.value = const Locale('es');
                        },
                        child: const Text('Switch to Spanish'),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsOneWidget);

      // Switch to Spanish
      await tester.tap(find.text('Switch to Spanish'));
      await tester.pumpAndSettle();

      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.text('Welcome'), findsNothing);
    });
  });

  group('Localization Coverage', () {
    testWidgets('should have recipe-related strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.recipe_title),
                  Text(l10n.recipe_ingredients),
                  Text(l10n.recipe_instructions),
                  Text(l10n.recipe_difficulty_easy),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNWidgets(4));
    });

    testWidgets('should have empty state strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.empty_state_no_data),
                  Text(l10n.empty_state_no_results),
                  Text(l10n.empty_state_recipes_title),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNWidgets(3));
    });

    testWidgets('should have settings strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.settings_language),
                  Text(l10n.settings_theme),
                  Text(l10n.settings_notifications),
                  Text(l10n.settings_privacy),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNWidgets(4));
    });
  });
}
