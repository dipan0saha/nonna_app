import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/models/registry_item.dart';
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
  static const calendarEvent = '/calendar/event/:id';
  static const calendarEventCreate = '/calendar/event/create';
  static const gallery = '/gallery';
  static const galleryPhoto = '/gallery/photo/:id';
  static const gamification = '/gamification';
  static const settings = '/settings';
  static const babyProfile = '/baby-profile';
  static const babyProfileCreate = '/baby-profile/create';
  static const babyProfileEdit = '/baby-profile/:id/edit';
  static const registry = '/registry';
  static const registryItem = '/registry/item/:id';
  static const registryItemCreate = '/registry/item/create';
}

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
            path: 'event/:id',
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
            path: 'photo/:id',
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
            path: 'item/:id',
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
/// Auth redirect is applied via [RouteGuards.authRedirect] which reads the
/// [isAuthenticatedProvider] from the ambient [ProviderScope].
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: RouteGuards.authRedirect,
  routes: _routes,
);

/// Riverpod-aware router provider.
///
/// Wraps [appRouter] for use in Riverpod-based code and tests.
/// Auth redirect is handled dynamically by [RouteGuards.authRedirect]
/// via [ProviderScope.containerOf], so no recreation is needed.
final routerProvider = Provider<GoRouter>((_) => appRouter);
