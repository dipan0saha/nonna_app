import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

/// Type alias for GoRouter redirect callbacks.
typedef RedirectFn = String? Function(
    BuildContext context, GoRouterState state);

/// Route guards for GoRouter navigation.
///
/// **Functional Requirements**: Section 3.30 - Navigation & Routing
///
/// Provides redirect functions that can be passed to [GoRouter.redirect] or
/// individual [GoRoute.redirect] to protect routes based on auth state and
/// user role.
class RouteGuards {
  RouteGuards._();

  static const _authRoutes = {'/login', '/signup', '/role-selection'};

  /// Returns a redirect function that enforces authentication.
  ///
  /// - Unauthenticated users accessing protected routes → `/login`
  /// - Authenticated users accessing auth routes → `/home`
  static RedirectFn get authRedirect => (context, state) {
        final container = ProviderScope.containerOf(context);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        return redirectIfNotAuthenticated(isAuthenticated, state);
      };

  /// Stateless redirect helper — useful when [isAuthenticated] is already known
  /// (e.g., inside a Riverpod [Provider] where `ref.watch` is available).
  static String? redirectIfNotAuthenticated(
    bool isAuthenticated,
    GoRouterState state,
  ) =>
      redirectForLocation(isAuthenticated, state.matchedLocation);

  /// Location-string variant of [redirectIfNotAuthenticated].
  ///
  /// Useful for unit tests that cannot easily construct a [GoRouterState].
  static String? redirectForLocation(bool isAuthenticated, String location) {
    final onAuthRoute = _authRoutes.contains(location);

    if (!isAuthenticated && !onAuthRoute) return '/login';
    if (isAuthenticated && onAuthRoute) return '/home';
    return null;
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

  /// Returns a redirect function that enforces role-based access.
  ///
  /// [roleProvider] must be a Riverpod provider that returns the current user's
  /// [UserRole] (or `null` when unauthenticated / role not yet loaded).
  ///
  /// Users whose current role is not in [allowedRoles] are redirected to
  /// [fallbackPath] (defaults to `/home`).
  ///
  /// Unauthenticated users are always redirected to `/login`.
  ///
  /// For unit tests use [redirectForRole] which avoids the need for a
  /// [BuildContext].
  ///
  /// Example:
  /// ```dart
  /// GoRoute(
  ///   path: '/owner-only',
  ///   redirect: RouteGuards.requiresRole(
  ///     currentUserRoleProvider,
  ///     allowedRoles: [UserRole.owner],
  ///   ),
  ///   builder: (_, __) => OwnerOnlyScreen(),
  /// )
  /// ```
  static RedirectFn requiresRole(
    ProviderListenable<UserRole?> roleProvider, {
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

  /// Pure role-based redirect helper — useful for unit tests that cannot
  /// easily construct a [BuildContext] with a [ProviderScope].
  ///
  /// - Unauthenticated → `/login`
  /// - Authenticated but role not in [allowedRoles] → [fallbackPath]
  /// - Authenticated and role allowed → `null` (no redirect)
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
