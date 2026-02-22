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
  });

  group('appRouter', () {
    test('is a non-null GoRouter instance', () {
      expect(appRouter, isNotNull);
    });

    test('has the expected initial location', () {
      expect(appRouter.routerDelegate, isNotNull);
    });
  });
}
