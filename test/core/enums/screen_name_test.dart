import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/screen_name.dart';

void main() {
  group('ScreenName', () {
    test('has all main screens', () {
      expect(ScreenName.values.length, 9);
      expect(ScreenName.values, contains(ScreenName.home));
      expect(ScreenName.values, contains(ScreenName.calendar));
      expect(ScreenName.values, contains(ScreenName.gallery));
      expect(ScreenName.values, contains(ScreenName.registry));
      expect(ScreenName.values, contains(ScreenName.fun));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(ScreenName.home.toJson(), 'home');
        expect(ScreenName.calendar.toJson(), 'calendar');
      });

      test('fromJson parses correct values', () {
        expect(ScreenName.fromJson('home'), ScreenName.home);
        expect(ScreenName.fromJson('calendar'), ScreenName.calendar);
      });

      test('fromJson is case insensitive', () {
        expect(ScreenName.fromJson('HOME'), ScreenName.home);
        expect(ScreenName.fromJson('Calendar'), ScreenName.home);
      });

      test('fromJson defaults to home for invalid input', () {
        expect(ScreenName.fromJson('invalid'), ScreenName.home);
      });
    });

    group('route', () {
      test('home route is root', () {
        expect(ScreenName.home.route, '/');
      });

      test('all screens have valid routes', () {
        for (final screen in ScreenName.values) {
          expect(screen.route.isNotEmpty, true);
          expect(screen.route.startsWith('/'), true);
        }
      });

      test('routes are unique', () {
        final routes = ScreenName.values.map((s) => s.route).toList();
        final uniqueRoutes = routes.toSet();
        expect(routes.length, uniqueRoutes.length);
      });
    });

    group('displayName', () {
      test('returns user-friendly names', () {
        expect(ScreenName.home.displayName, 'Home');
        expect(ScreenName.calendar.displayName, 'Calendar');
        expect(ScreenName.babyProfile.displayName, 'Baby Profile');
      });
    });
  });
}
