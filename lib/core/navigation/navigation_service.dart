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
/// The [navigatorKey] is wired into [appRouter] so context-free navigation
/// methods ([goTo], [pushTo], etc.) resolve to the active [GoRouter].
///
/// For route path constants use `AppRoutes` from `core/router/app_router.dart`.
///
/// Usage (context available — preferred):
/// ```dart
/// context.go(AppRoutes.home);
/// ```
///
/// Usage (no context — e.g. service layer):
/// ```dart
/// NavigationService.goTo(AppRoutes.home);
/// ```
class NavigationService {
  const NavigationService._();

  /// Global navigator key.
  ///
  /// Wired into [appRouter] via `GoRouter(navigatorKey: NavigationService.navigatorKey)`.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
