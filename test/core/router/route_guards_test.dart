import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/router/route_guards.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

Provider<UserRole?> _roleProvider(UserRole? role) =>
    Provider<UserRole?>((_) => role);

void main() {
  group('RouteGuards.redirectForLocation', () {
    test('redirects unauthenticated user from /home to owner carousel', () {
      expect(
        RouteGuards.redirectForLocation(false, '/home'),
        OnboardingRoutes.ownerCarousel,
      );
    });

    test('allows unauthenticated user on owner carousel', () {
      expect(
        RouteGuards.redirectForLocation(
          false,
          OnboardingRoutes.ownerCarousel,
        ),
        isNull,
      );
    });

    test('allows unauthenticated user on /login', () {
      expect(
        RouteGuards.redirectForLocation(false, '/login'),
        isNull,
      );
    });

    test('allows unauthenticated user on /signup', () {
      expect(
        RouteGuards.redirectForLocation(false, '/signup'),
        isNull,
      );
    });

    test('allows unauthenticated user on /invite-accept', () {
      expect(
        RouteGuards.redirectForLocation(false, OnboardingRoutes.inviteAccept),
        isNull,
      );
    });

    test('redirects unauthenticated pending invite to follower invite landing',
        () {
      expect(
        RouteGuards.redirectForLocation(
          false,
          '/settings',
          hasPendingInvite: true,
        ),
        OnboardingRoutes.followerInvite,
      );
    });

    test('redirects authenticated completed user away from onboarding', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          OnboardingRoutes.ownerCarousel,
          onboardingCompleted: true,
        ),
        '/home',
      );
    });

    test('resumes coordinator step over /home (#55)', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          '/home',
          hasActiveCoordinatorStep: true,
          coordinatorResumeRoute: OnboardingRoutes.ownerFirstMoment,
          hasBabyMemberships: true,
        ),
        OnboardingRoutes.ownerFirstMoment,
      );
    });

    test('redirects co-owner pending invite to co-owner landing', () {
      expect(
        RouteGuards.redirectForLocation(
          false,
          '/settings',
          hasPendingInvite: true,
          invitePath: OnboardingPath.coOwner,
        ),
        OnboardingRoutes.coOwnerInvite,
      );
    });

    test('allows authenticated incomplete user on /home with memberships', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          '/home',
          hasBabyMemberships: true,
        ),
        isNull,
      );
    });

    test(
        'redirects authenticated incomplete user without memberships from /home',
        () {
      expect(
        RouteGuards.redirectForLocation(true, '/home'),
        OnboardingRoutes.ownerCarousel,
      );
    });

    test('allows authenticated user on onboarding login when incomplete', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          OnboardingRoutes.login,
        ),
        isNull,
      );
    });

    test('allows authenticated incomplete user on /invite-accept', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          OnboardingRoutes.inviteAccept,
        ),
        isNull,
      );
    });

    test('allows authenticated incomplete user on follower invite landing', () {
      expect(
        RouteGuards.redirectForLocation(
          true,
          OnboardingRoutes.followerInvite,
          hasPendingInvite: true,
        ),
        isNull,
      );
    });

    test('redirects authenticated incomplete user from /settings to carousel',
        () {
      expect(
        RouteGuards.redirectForLocation(true, '/settings'),
        OnboardingRoutes.ownerCarousel,
      );
    });
  });

  group('RouteGuards.isPublicRoute', () {
    test('onboarding paths are public', () {
      expect(
        RouteGuards.isPublicRoute(OnboardingRoutes.emailVerify),
        isTrue,
      );
    });

    test('invite accept is public', () {
      expect(
        RouteGuards.isPublicRoute(OnboardingRoutes.inviteAccept),
        isTrue,
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
  });
}
