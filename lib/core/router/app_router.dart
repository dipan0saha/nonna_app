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
import 'package:nonna_app/features/home/presentation/screens/main_shell_screen.dart';
import 'package:nonna_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:nonna_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_creation_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_edit_screen.dart';
import 'package:nonna_app/features/calendar/presentation/screens/upcoming_events_screen.dart';
import 'package:nonna_app/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:nonna_app/features/gallery/presentation/screens/photo_detail_screen.dart';
import 'package:nonna_app/features/gamification/presentation/screens/gamification_screen.dart';
import 'package:nonna_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/baby_profile_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/create_baby_profile_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/followers_management_screen.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/invite_followers_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_detail_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_creation_screen.dart';
import 'package:nonna_app/features/registry/presentation/screens/registry_item_edit_screen.dart';

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
  static const calendarUpcoming = '/calendar/upcoming';
  // Detail/edit routes use :id path parameters so they work from deep-links,
  // push notifications, and OS background restores — not just in-app navigation.
  // Use the static helper methods below (e.g. galleryPhotoRoute) as navigation
  // targets; the constants with `:id` are GoRoute path patterns only.
  static const calendarEvent = '/calendar/event/:id';
  static const calendarEventCreate = '/calendar/event/create';
  static const calendarEventEdit = '/calendar/event/:id/edit';
  static const gallery = '/gallery';
  static const galleryFavorites = '/gallery/favorites';
  static const galleryRecent = '/gallery/recent';
  static const galleryPhoto = '/gallery/photo/:id';

  // Navigation helper methods — embed the actual entity ID into the URL.
  // Always use these for context.push() / NavigationService.pushTo() calls.
  static String galleryPhotoRoute(String id) => '/gallery/photo/$id';
  static String calendarEventRoute(String id) => '/calendar/event/$id';
  static String calendarEventEditRoute(String id) => '/calendar/event/$id/edit';
  static String registryItemRoute(String id) => '/registry/item/$id';
  static String registryItemEditRoute(String id) => '/registry/item/$id/edit';
  static const gamification = '/gamification';
  static const settings = '/settings';
  static const babyProfile = '/baby-profile';
  static const babyProfileCreate = '/baby-profile/create';
  static const babyProfileEdit = '/baby-profile/:id/edit';
  static const babyProfileFollowers = '/baby-profile/followers';
  static const babyProfileInvite = '/baby-profile/followers/invite';
  static const registry = '/registry';
  static const registryItem = '/registry/item/:id';
  static const registryItemCreate = '/registry/item/create';
  static const registryItemEdit = '/registry/item/:id/edit';
}

// ---------------------------------------------------------------------------
// Branch navigator keys
//
// Each StatefulShellBranch needs its own GlobalKey<NavigatorState> so that
// GoRouter can maintain independent navigation stacks per tab.
// These are top-level finals so they are never recreated across rebuilds.
// The root key lives in NavigationService.navigatorKey and must NOT be reused.
// ---------------------------------------------------------------------------
final _shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellGalleryKey = GlobalKey<NavigatorState>(debugLabel: 'shellGallery');
final _shellCalendarKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellCalendar');
final _shellRegistryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellRegistry');
final _shellFunKey = GlobalKey<NavigatorState>(debugLabel: 'shellFun');

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

/// Extracts a [String] value from the [GoRouterState.extra] map by [key].
///
/// Returns [fallback] (default `''`) when extra is null or the key is absent.
String _extraString(GoRouterState state, String key, [String fallback = '']) {
  final extra = state.extra as Map<String, dynamic>?;
  return extra?[key] as String? ?? fallback;
}

List<RouteBase> get _routes => [
      // -----------------------------------------------------------------------
      // Root redirect
      // -----------------------------------------------------------------------
      GoRoute(
        path: '/',
        redirect: (_, __) => AppRoutes.home,
      ),

      // -----------------------------------------------------------------------
      // Auth routes — OUTSIDE the shell so no nav bar is shown
      // -----------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          onSignUpTap: () => context.go(AppRoutes.signup),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => SignupScreen(
          onLoginTap: () => context.go(AppRoutes.login),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // -----------------------------------------------------------------------
      // Full-screen routes — OUTSIDE the shell (parentNavigatorKey = root).
      // These cover the nav bar entirely.
      // -----------------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: NavigationService.navigatorKey,
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
        parentNavigatorKey: NavigationService.navigatorKey,
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: NavigationService.navigatorKey,
        path: AppRoutes.babyProfile,
        builder: (context, state) => BabyProfileScreen(
          babyProfileId: _extraString(state, 'babyProfileId'),
          currentUserId: _extraString(state, 'currentUserId'),
          onEditTap: () {
            context.push(
              AppRoutes.babyProfileEdit
                  .replaceFirst(':id', _extraString(state, 'babyProfileId')),
              extra: {
                'currentUserId': _extraString(state, 'currentUserId'),
              },
            );
          },
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
        parentNavigatorKey: NavigationService.navigatorKey,
        path: AppRoutes.babyProfileFollowers,
        builder: (context, state) => FollowersManagementScreen(
          babyProfileId: _extraString(state, 'babyProfileId'),
          currentUserId: _extraString(state, 'currentUserId'),
          onInviteTap: () {
            context.push(
              AppRoutes.babyProfileInvite,
              extra: {
                'babyProfileId': _extraString(state, 'babyProfileId'),
                'currentUserId': _extraString(state, 'currentUserId'),
              },
            );
          },
        ),
      ),
      GoRoute(
        parentNavigatorKey: NavigationService.navigatorKey,
        path: AppRoutes.babyProfileInvite,
        builder: (context, state) => InviteFollowersScreen(
          babyProfileId: _extraString(state, 'babyProfileId'),
          invitedByUserId: _extraString(state, 'currentUserId'),
          onDone: () => context.pop(),
        ),
      ),

      // -----------------------------------------------------------------------
      // Shell — 5 tab branches with independent navigation stacks.
      // The shell body is MainShellScreen, which renders AppBottomNavBar on
      // mobile and AppNavigationRail on tablet via ResponsiveScaffold.
      // -----------------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          // Branch 0 — HOME
          StatefulShellBranch(
            navigatorKey: _shellHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1 — GALLERY
          StatefulShellBranch(
            navigatorKey: _shellGalleryKey,
            routes: [
              GoRoute(
                path: AppRoutes.gallery,
                builder: (context, state) => const GalleryScreen(),
                routes: [
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const GalleryScreen(
                      title: 'Favorite Photos',
                      screenId: 'gallery_favorites',
                    ),
                  ),
                  GoRoute(
                    path: 'recent',
                    builder: (context, state) => const GalleryScreen(
                      title: 'Recent Photos',
                      screenId: 'gallery_recent',
                    ),
                  ),
                  // Detail escapes the shell → full-screen, nav bar hidden
                  GoRoute(
                    parentNavigatorKey: NavigationService.navigatorKey,
                    path: 'photo/:id',
                    builder: (context, state) {
                      final photo = state.extra as Photo?;
                      final id = state.pathParameters['id'] ?? '';
                      return PhotoDetailScreen(photo: photo, photoId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2 — CALENDAR
          StatefulShellBranch(
            navigatorKey: _shellCalendarKey,
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
                routes: [
                  GoRoute(
                    path: 'upcoming',
                    builder: (context, state) => const UpcomingEventsScreen(),
                  ),
                  // Creation stays before the dynamic :id route so GoRouter
                  // matches it as a static path without ambiguity.
                  GoRoute(
                    parentNavigatorKey: NavigationService.navigatorKey,
                    path: 'event/create',
                    builder: (context, state) => EventCreationScreen(
                      babyProfileId: _extraString(state, 'babyProfileId'),
                      createdByUserId: _extraString(state, 'createdByUserId'),
                    ),
                  ),
                  // Detail stays nested → nav bar remains visible.
                  // :id must come AFTER the static 'event/create' route.
                  GoRoute(
                    path: 'event/:id',
                    builder: (context, state) {
                      final event = state.extra as Event?;
                      final id = state.pathParameters['id'] ?? '';
                      return EventDetailScreen(event: event, eventId: id);
                    },
                  ),
                  // Edit escapes the shell → covers the nav bar
                  GoRoute(
                    parentNavigatorKey: NavigationService.navigatorKey,
                    path: 'event/:id/edit',
                    builder: (context, state) {
                      final event = state.extra as Event?;
                      final id = state.pathParameters['id'] ?? '';
                      return EventEditScreen(event: event, eventId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3 — REGISTRY
          StatefulShellBranch(
            navigatorKey: _shellRegistryKey,
            routes: [
              GoRoute(
                path: AppRoutes.registry,
                builder: (context, state) => const RegistryScreen(),
                routes: [
                  // Creation stays before the dynamic :id route (static wins).
                  GoRoute(
                    parentNavigatorKey: NavigationService.navigatorKey,
                    path: 'item/create',
                    builder: (context, state) => RegistryItemCreationScreen(
                      babyProfileId: _extraString(state, 'babyProfileId'),
                      createdByUserId: _extraString(state, 'createdByUserId'),
                    ),
                  ),
                  // Detail stays nested → nav bar remains visible.
                  // :id must come AFTER the static 'item/create' route.
                  GoRoute(
                    path: 'item/:id',
                    builder: (context, state) {
                      final item = state.extra as RegistryItem?;
                      final id = state.pathParameters['id'] ?? '';
                      return RegistryItemDetailScreen(item: item, itemId: id);
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: NavigationService.navigatorKey,
                    path: 'item/:id/edit',
                    builder: (context, state) {
                      final item = state.extra as RegistryItem?;
                      final id = state.pathParameters['id'] ?? '';
                      return RegistryItemEditScreen(item: item, itemId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 4 — FUN (Gamification)
          StatefulShellBranch(
            navigatorKey: _shellFunKey,
            routes: [
              GoRoute(
                path: AppRoutes.gamification,
                builder: (context, state) => const GamificationScreen(),
              ),
            ],
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
