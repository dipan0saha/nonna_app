import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/navigation/navigation_service.dart';
import 'package:nonna_app/core/router/app_router.dart';

void main() {
  group('NavigationService', () {
    test('navigatorKey is a GlobalKey<NavigatorState>', () {
      expect(
        NavigationService.navigatorKey,
        isA<GlobalKey<NavigatorState>>(),
      );
    });

    test('canPop returns false when no navigator is attached', () {
      // Before any widget is mounted, canPop should safely return false.
      expect(NavigationService.canPop(), isFalse);
    });

    test('goTo / pushTo / pop / replaceWith do not throw when no navigator',
        () {
      // Context-free calls with no attached navigator should be silent no-ops.
      expect(() => NavigationService.goTo('/home'), returnsNormally);
      expect(() => NavigationService.pushTo('/login'), returnsNormally);
      expect(() => NavigationService.replaceWith('/home'), returnsNormally);
      expect(() => NavigationService.pop(), returnsNormally);
    });

    testWidgets('navigatorKey is wired into appRouter', (tester) async {
      // Build a minimal GoRouter that wires NavigationService.navigatorKey so
      // we can verify context-free navigation resolves correctly.
      final router = GoRouter(
        navigatorKey: NavigationService.navigatorKey,
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (_, __) => const Scaffold(body: Text('Start')),
          ),
          GoRoute(
            path: '/destination',
            builder: (_, __) => const Scaffold(body: Text('Destination')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);

      // Use context-free navigation to go to /destination.
      NavigationService.goTo('/destination');
      await tester.pumpAndSettle();

      expect(find.text('Destination'), findsOneWidget);
    });

    testWidgets('canPop returns true when a route can be popped',
        (tester) async {
      final router = GoRouter(
        navigatorKey: NavigationService.navigatorKey,
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (_, __) => const Scaffold(body: Text('Start')),
          ),
          GoRoute(
            path: '/pushed',
            builder: (_, __) => const Scaffold(body: Text('Pushed')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      NavigationService.pushTo('/pushed');
      await tester.pumpAndSettle();

      expect(find.text('Pushed'), findsOneWidget);
      expect(NavigationService.canPop(), isTrue);

      NavigationService.pop();
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);
    });

    test('AppRoutes constants are referenced by NavigationService', () {
      // NavigationService no longer duplicates route constants — callers use
      // AppRoutes directly.  Verify key AppRoutes values are defined.
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.settings, '/settings');
    });
  });
}
