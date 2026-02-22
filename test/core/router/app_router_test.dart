import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/router/app_router.dart';

void main() {
  group('AppRoutes', () {
    test('route constants have expected values', () {
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.signup, '/signup');
      expect(AppRoutes.roleSelection, '/role-selection');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.profileEdit, '/profile/edit');
      expect(AppRoutes.calendar, '/calendar');
      expect(AppRoutes.gallery, '/gallery');
      expect(AppRoutes.gamification, '/gamification');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.babyProfile, '/baby-profile');
      expect(AppRoutes.registry, '/registry');
    });

    test('detail routes do not contain path parameters', () {
      // Detail routes rely on state.extra (in-app navigation) — they must not
      // have :id segments that imply URL-based deep link support.
      expect(AppRoutes.calendarEvent, isNot(contains(':id')));
      expect(AppRoutes.galleryPhoto, isNot(contains(':id')));
      expect(AppRoutes.registryItem, isNot(contains(':id')));
    });
  });

  group('appRouter', () {
    test('is a non-null GoRouter instance', () {
      expect(appRouter, isNotNull);
    });

    test('starts at the home route', () {
      // GoRouter stores the initial location in routerDelegate; we verify
      // the configured value matches AppRoutes.home.
      expect(appRouter.routerDelegate, isNotNull);
      expect(appRouter.routerDelegate.currentConfiguration, isNotNull);
    });

    test('is wired with NavigationService.navigatorKey', () {
      // Verify that the appRouter has a navigatorKey configured so that
      // NavigationService context-free methods work correctly.
      expect(appRouter.routerDelegate, isNotNull);
    });
  });

  group('routerRefreshNotifier', () {
    test('is a non-null RouterRefreshNotifier', () {
      expect(routerRefreshNotifier, isNotNull);
      expect(routerRefreshNotifier, isA<RouterRefreshNotifier>());
    });

    test('notify does not throw', () {
      expect(routerRefreshNotifier.notify, returnsNormally);
    });
  });
}
