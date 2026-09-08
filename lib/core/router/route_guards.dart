import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_routes.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';

/// Type alias for GoRouter redirect callbacks.
typedef RedirectFn = String? Function(
    BuildContext context, GoRouterState state);

/// Route guards for GoRouter navigation.
class RouteGuards {
  RouteGuards._();

  static const _legacyAuthRoutes = {
    '/login',
    '/signup',
    '/role-selection',
  };

  static bool isPublicRoute(String location) =>
      OnboardingRoutes.isPublicPath(location);

  static bool isLegacyAuthRoute(String location) =>
      _legacyAuthRoutes.contains(location);

  static bool isOnboardingRoute(String location) =>
      OnboardingRoutes.isOnboardingPath(location);

  /// Core redirect logic shared by [authRedirect] and [redirectForLocation].
  static String? resolveRedirect({
    required bool isAuthenticated,
    required String location,
    required bool onboardingCompleted,
    required bool hasActiveCoordinatorStep,
    String? coordinatorResumeRoute,
    bool hasPendingInvite = false,
    OnboardingPath invitePath = OnboardingPath.follower,
    bool hasBabyMemberships = false,
  }) {
    if (!isAuthenticated) {
      if (isPublicRoute(location)) return null;
      if (hasPendingInvite) {
        final inviteRoute = invitePath == OnboardingPath.coOwner
            ? OnboardingRoutes.coOwnerInvite
            : OnboardingRoutes.followerInvite;
        if (location != inviteRoute) return inviteRoute;
        return null;
      }
      if (location != OnboardingRoutes.ownerCarousel) {
        return OnboardingRoutes.ownerCarousel;
      }
      return null;
    }

    if (onboardingCompleted) {
      if (isOnboardingRoute(location)) {
        return '/home';
      }
      if (isLegacyAuthRoute(location) &&
          location != '/login' &&
          location != OnboardingRoutes.login) {
        return '/home';
      }
      return null;
    }

    // Allow invite deep-link entry and landing screens during onboarding.
    if (location == OnboardingRoutes.inviteAccept) {
      return null;
    }

    if (hasPendingInvite) {
      final inviteRoute = invitePath == OnboardingPath.coOwner
          ? OnboardingRoutes.coOwnerInvite
          : OnboardingRoutes.followerInvite;
      if (location == inviteRoute) {
        return null;
      }
    }

    if (hasActiveCoordinatorStep && coordinatorResumeRoute != null) {
      if (location != coordinatorResumeRoute) {
        return coordinatorResumeRoute;
      }
      return null;
    }

    if (isLegacyAuthRoute(location) || location == OnboardingRoutes.login) {
      return null;
    }

    if (location == '/home') {
      if (hasBabyMemberships) return null;
      return OnboardingRoutes.ownerCarousel;
    }

    if (!isOnboardingRoute(location)) {
      return OnboardingRoutes.ownerCarousel;
    }

    return null;
  }

  /// Returns a redirect function that enforces authentication and onboarding.
  static RedirectFn get authRedirect => (context, state) {
        final container = ProviderScope.containerOf(context);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        final location = state.matchedLocation;
        final coordinator = container.read(onboardingCoordinatorProvider);
        final storage = container.read(localStorageServiceProvider);
        final onboardingCompleted =
            storage.isInitialized && storage.isOnboardingCompleted;

        return resolveRedirect(
          isAuthenticated: isAuthenticated,
          location: location,
          onboardingCompleted: onboardingCompleted,
          hasActiveCoordinatorStep: coordinator.hasActiveStep,
          coordinatorResumeRoute: coordinator.resumeRoute,
          hasPendingInvite: coordinator.pendingInviteToken != null,
          invitePath: coordinator.path,
          hasBabyMemberships: container.read(userHasBabyMembershipsProvider),
        );
      };

  /// Stateless redirect helper for unit tests.
  static String? redirectForLocation(
    bool isAuthenticated,
    String location, {
    bool onboardingCompleted = false,
    bool hasActiveCoordinatorStep = false,
    String? coordinatorResumeRoute,
    bool hasPendingInvite = false,
    OnboardingPath invitePath = OnboardingPath.follower,
    bool hasBabyMemberships = false,
  }) {
    return resolveRedirect(
      isAuthenticated: isAuthenticated,
      location: location,
      onboardingCompleted: onboardingCompleted,
      hasActiveCoordinatorStep: hasActiveCoordinatorStep,
      coordinatorResumeRoute: coordinatorResumeRoute,
      hasPendingInvite: hasPendingInvite,
      invitePath: invitePath,
      hasBabyMemberships: hasBabyMemberships,
    );
  }

  /// Returns a redirect function that sends users to `/login` only when
  /// they try to access one of [protectedPaths] without being authenticated.
  static RedirectFn requiresAuth(List<String> protectedPaths) =>
      (context, state) {
        final container = ProviderScope.containerOf(context);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        if (!isAuthenticated &&
            protectedPaths.contains(state.matchedLocation)) {
          return '/login';
        }
        return null;
      };

  static RedirectFn requiresRole(
    Provider<UserRole?> roleProvider, {
    required List<UserRole> allowedRoles,
    String fallbackPath = '/home',
  }) =>
      (context, state) {
        final container = ProviderScope.containerOf(context);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        final role = container.read(roleProvider);
        return redirectForRole(
          isAuthenticated,
          role,
          allowedRoles,
          fallbackPath: fallbackPath,
        );
      };

  static String? redirectForRole(
    bool isAuthenticated,
    UserRole? currentRole,
    List<UserRole> allowedRoles, {
    String fallbackPath = '/home',
  }) {
    if (!isAuthenticated) return '/login';
    if (currentRole == null || !allowedRoles.contains(currentRole)) {
      return fallbackPath;
    }
    return null;
  }
}
