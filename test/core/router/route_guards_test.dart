import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/router/route_guards.dart';

void main() {
  group('RouteGuards.redirectForLocation', () {
    test('redirects unauthenticated user from /home to /login', () {
      expect(
        RouteGuards.redirectForLocation(false, '/home'),
        '/login',
      );
    });

    test('redirects unauthenticated user from /settings to /login', () {
      expect(
        RouteGuards.redirectForLocation(false, '/settings'),
        '/login',
      );
    });

    test('allows unauthenticated user to stay on /login', () {
      expect(
        RouteGuards.redirectForLocation(false, '/login'),
        isNull,
      );
    });

    test('allows unauthenticated user to stay on /signup', () {
      expect(
        RouteGuards.redirectForLocation(false, '/signup'),
        isNull,
      );
    });

    test('allows unauthenticated user to stay on /role-selection', () {
      expect(
        RouteGuards.redirectForLocation(false, '/role-selection'),
        isNull,
      );
    });

    test('redirects authenticated user away from /login to /home', () {
      expect(
        RouteGuards.redirectForLocation(true, '/login'),
        '/home',
      );
    });

    test('redirects authenticated user away from /signup to /home', () {
      expect(
        RouteGuards.redirectForLocation(true, '/signup'),
        '/home',
      );
    });

    test('redirects authenticated user away from /role-selection to /home', () {
      expect(
        RouteGuards.redirectForLocation(true, '/role-selection'),
        '/home',
      );
    });

    test('allows authenticated user to access /home', () {
      expect(
        RouteGuards.redirectForLocation(true, '/home'),
        isNull,
      );
    });

    test('allows authenticated user to access /profile', () {
      expect(
        RouteGuards.redirectForLocation(true, '/profile'),
        isNull,
      );
    });

    test('allows authenticated user to access /calendar', () {
      expect(
        RouteGuards.redirectForLocation(true, '/calendar'),
        isNull,
      );
    });
  });
}
