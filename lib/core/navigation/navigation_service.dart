import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Programmatic navigation service wrapping [GoRouter].
///
/// **Functional Requirements**: Section 3.30 - Navigation & Routing
///
/// Exposes a [GlobalKey<NavigatorState>] for imperative navigation and
/// convenience wrappers around GoRouter's context-based API.
///
/// Usage (context available — preferred):
/// ```dart
/// context.go(NavigationService.homeRoute);
/// ```
///
/// Usage (no context — e.g. service layer):
/// ```dart
/// NavigationService.goTo(NavigationService.homeRoute);
/// ```
///
/// To enable context-free navigation, pass [navigatorKey] to [GoRouter]:
/// ```dart
/// GoRouter(navigatorKey: NavigationService.navigatorKey, ...)
/// ```
class NavigationService {
  const NavigationService._();

  /// Global navigator key.
  ///
  /// Pass this to [GoRouter] (or [MaterialApp]) so that context-free
  /// navigation methods ([goTo], [pushTo], etc.) can resolve a [BuildContext].
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route path constants.
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String roleSelectionRoute = '/role-selection';
  static const String profileRoute = '/profile';
  static const String profileEditRoute = '/profile/edit';
  static const String calendarRoute = '/calendar';
  static const String galleryRoute = '/gallery';
  static const String gamificationRoute = '/gamification';
  static const String settingsRoute = '/settings';
  static const String babyProfileRoute = '/baby-profile';
  static const String registryRoute = '/registry';

  static NavigatorState? get _navigator => navigatorKey.currentState;

  /// Navigate to [path], replacing the current stack entry.
  static void goTo(String path, {Object? extra}) {
    final ctx = _navigator?.context;
    if (ctx != null && ctx.mounted) {
      GoRouter.of(ctx).go(path, extra: extra);
    }
  }

  /// Push [path] onto the navigation stack.
  static void pushTo(String path, {Object? extra}) {
    final ctx = _navigator?.context;
    if (ctx != null && ctx.mounted) {
      GoRouter.of(ctx).push(path, extra: extra);
    }
  }

  /// Replace the current route with [path].
  static void replaceWith(String path, {Object? extra}) {
    final ctx = _navigator?.context;
    if (ctx != null && ctx.mounted) {
      GoRouter.of(ctx).replace(path, extra: extra);
    }
  }

  /// Pop the top route from the stack.
  static void pop() {
    _navigator?.pop();
  }

  /// Returns `true` if there is a route that can be popped.
  static bool canPop() => _navigator?.canPop() ?? false;
}

/// Riverpod provider for [NavigationService].
final navigationServiceProvider =
    Provider<NavigationService>((_) => const NavigationService._());
