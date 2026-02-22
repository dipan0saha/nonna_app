import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

/// Type alias for GoRouter redirect callbacks.
typedef RedirectFn = String? Function(BuildContext context, GoRouterState state);

/// Route guards for GoRouter navigation.
///
/// **Functional Requirements**: Section 3.30 - Navigation & Routing
///
/// Provides redirect functions that can be passed to [GoRouter.redirect] or
/// individual [GoRoute.redirect] to protect routes based on auth state.
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
}
