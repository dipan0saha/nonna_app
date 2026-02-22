import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/navigation/navigation_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/screens/login_screen.dart';
import 'package:nonna_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:nonna_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:nonna_app/features/home/presentation/screens/home_screen.dart';
import 'package:nonna_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:nonna_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_creation_screen.dart';
import 'package:nonna_app/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:nonna_app/features/gallery/presentation/screens/photo_detail_screen.dart';
import 'package:nonna_app/features/gamification/presentation/screens/gamification_screen.dart';
import 'package:nonna_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/baby_profile_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/create_baby_profile_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_detail_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_creation_screen.dart';

import 'route_guards.dart';

/// Route name constants.
abstract class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const roleSelection = '/role-selection';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const calendar = '/calendar';
  // Note: event/photo/registry detail routes rely on state.extra (object passed
  // during in-app navigation) and therefore do not include a path `:id` segment,
  // as the extra payload is not available when the route is deep-linked by URL.
  static const calendarEvent = '/calendar/event/detail';
  static const calendarEventCreate = '/calendar/event/create';
  static const gallery = '/gallery';
  static const galleryPhoto = '/gallery/photo/detail';
  static const gamification = '/gamification';
  static const settings = '/settings';
  static const babyProfile = '/baby-profile';
  static const babyProfileCreate = '/baby-profile/create';
  static const babyProfileEdit = '/baby-profile/:id/edit';
  static const registry = '/registry';
  static const registryItem = '/registry/item/detail';
  static const registryItemCreate = '/registry/item/create';
}

/// ChangeNotifier used as [GoRouter.refreshListenable].
///
/// Call [notify] whenever auth state changes so the router re-evaluates its
/// redirect logic (e.g., after sign-in or sign-out).
class RouterRefreshNotifier extends ChangeNotifier {
  /// Trigger a router refresh.
  void notify() => notifyListeners();
}

/// Singleton notifier wired into [appRouter.refreshListenable].
///
/// Riverpod listeners (see [routerProvider]) call [routerRefreshNotifier.notify]
/// when auth state changes so the router re-runs its redirect.
final routerRefreshNotifier = RouterRefreshNotifier();

/// Helper to show a simple "not found" placeholder when route data is missing.
Widget _missingData(String label) => Scaffold(
      body: Center(child: Text('$label not found')),
    );

/// Extracts a [String] value from the [GoRouterState.extra] map by [key].
///
/// Returns [fallback] (default `''`) when extra is null or the key is absent.
String _extraString(GoRouterState state, String key, [String fallback = '']) {
  final extra = state.extra as Map<String, dynamic>?;
  return extra?[key] as String? ?? fallback;
}

List<RouteBase> get _routes => [
      GoRoute(
        path: '/',
        redirect: (_, __) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            ProfileScreen(userId: _extraString(state, 'userId')),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                EditProfileScreen(userId: _extraString(state, 'userId')),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarScreen(),
        routes: [
          GoRoute(
            path: 'event/create',
            builder: (context, state) => EventCreationScreen(
              babyProfileId: _extraString(state, 'babyProfileId'),
              createdByUserId: _extraString(state, 'createdByUserId'),
            ),
          ),
          GoRoute(
            path: 'event/detail',
            builder: (context, state) {
              final event = state.extra as Event?;
              if (event == null) return _missingData('Event');
              return EventDetailScreen(event: event);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const GalleryScreen(),
        routes: [
          GoRoute(
            path: 'photo/detail',
            builder: (context, state) {
              final photo = state.extra as Photo?;
              if (photo == null) return _missingData('Photo');
              return PhotoDetailScreen(photo: photo);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.gamification,
        builder: (context, state) => GamificationScreen(
          babyProfileId: _extraString(state, 'babyProfileId'),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.babyProfile,
        builder: (context, state) => BabyProfileScreen(
          babyProfileId: _extraString(state, 'babyProfileId'),
          currentUserId: _extraString(state, 'currentUserId'),
        ),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => CreateBabyProfileScreen(
              userId: _extraString(state, 'userId'),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => EditBabyProfileScreen(
              babyProfileId: state.pathParameters['id'] ?? '',
              currentUserId: _extraString(state, 'currentUserId'),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.registry,
        builder: (context, state) => const RegistryScreen(),
        routes: [
          GoRoute(
            path: 'item/create',
            builder: (context, state) => RegistryItemCreationScreen(
              babyProfileId: _extraString(state, 'babyProfileId'),
              createdByUserId: _extraString(state, 'createdByUserId'),
            ),
          ),
          GoRoute(
            path: 'item/detail',
            builder: (context, state) {
              final item = state.extra as RegistryItem?;
              if (item == null) return _missingData('Registry item');
              return RegistryItemDetailScreen(item: item);
            },
          ),
        ],
      ),
    ];

/// Global [GoRouter] instance used by [main.dart].
///
/// - Auth redirect is applied via [RouteGuards.authRedirect].
/// - [NavigationService.navigatorKey] is wired in so context-free navigation
///   helpers (goTo, pushTo, etc.) resolve correctly.
/// - [routerRefreshNotifier] triggers redirect re-evaluation on auth changes;
///   call [routerRefreshNotifier.notify] (e.g. from [routerProvider]) when
///   auth state changes.
final appRouter = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: AppRoutes.home,
  refreshListenable: routerRefreshNotifier,
  redirect: RouteGuards.authRedirect,
  routes: _routes,
  debugLogDiagnostics: kDebugMode,
);

/// Riverpod-aware router provider.
///
/// Watches [isAuthenticatedProvider] and calls [routerRefreshNotifier.notify]
/// when auth state changes so the router re-evaluates its redirect logic
/// (e.g., sends a newly signed-in user to /home or a signed-out user to /login).
final routerProvider = Provider<GoRouter>((ref) {
  ref.listen<bool>(isAuthenticatedProvider, (_, __) {
    routerRefreshNotifier.notify();
  });
  return appRouter;
});
