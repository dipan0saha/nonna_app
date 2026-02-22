import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/router/route_guards.dart';

/// A simple Riverpod provider returning a fixed [UserRole?] for testing
/// [RouteGuards.requiresRole].
Provider<UserRole?> _roleProvider(UserRole? role) =>
    Provider<UserRole?>((_) => role);

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

  group('RouteGuards.requiresRole', () {
    test('requiresRole returns a non-null RedirectFn', () {
      final fn = RouteGuards.requiresRole(
        _roleProvider(UserRole.owner),
        allowedRoles: [UserRole.owner],
      );
      expect(fn, isNotNull);
    });

    test('role provider accepts owner role', () {
      final container = ProviderContainer();
      final provider = _roleProvider(UserRole.owner);
      addTearDown(container.dispose);

      expect(container.read(provider), UserRole.owner);
    });

    test('role provider accepts follower role', () {
      final container = ProviderContainer();
      final provider = _roleProvider(UserRole.follower);
      addTearDown(container.dispose);

      expect(container.read(provider), UserRole.follower);
    });

    test('role provider can be null', () {
      final container = ProviderContainer();
      final provider = _roleProvider(null);
      addTearDown(container.dispose);

      expect(container.read(provider), isNull);
    });
  });

  group('RouteGuards.redirectForRole', () {
    test('unauthenticated user is redirected to /login', () {
      expect(
        RouteGuards.redirectForRole(
          false,
          UserRole.owner,
          [UserRole.owner],
        ),
        '/login',
      );
    });

    test('unauthenticated user with null role is redirected to /login', () {
      expect(
        RouteGuards.redirectForRole(false, null, [UserRole.owner]),
        '/login',
      );
    });

    test('authenticated user with allowed role is not redirected', () {
      expect(
        RouteGuards.redirectForRole(
          true,
          UserRole.owner,
          [UserRole.owner],
        ),
        isNull,
      );
    });

    test('authenticated follower allowed through follower-only route', () {
      expect(
        RouteGuards.redirectForRole(
          true,
          UserRole.follower,
          [UserRole.follower],
        ),
        isNull,
      );
    });

    test('authenticated user with disallowed role is redirected to fallback',
        () {
      expect(
        RouteGuards.redirectForRole(
          true,
          UserRole.follower,
          [UserRole.owner],
        ),
        '/home',
      );
    });

    test('custom fallbackPath is used when role is not allowed', () {
      expect(
        RouteGuards.redirectForRole(
          true,
          UserRole.follower,
          [UserRole.owner],
          fallbackPath: '/no-access',
        ),
        '/no-access',
      );
    });

    test('null role is treated as not allowed', () {
      expect(
        RouteGuards.redirectForRole(true, null, [UserRole.owner]),
        '/home',
      );
    });

    test('multiple allowed roles — matching role is allowed', () {
      expect(
        RouteGuards.redirectForRole(
          true,
          UserRole.follower,
          [UserRole.owner, UserRole.follower],
        ),
        isNull,
      );
    });
  });
}
