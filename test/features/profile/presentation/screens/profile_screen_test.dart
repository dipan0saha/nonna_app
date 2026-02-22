import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/user.dart';
import 'package:nonna_app/core/models/user_stats.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/screens/profile_screen.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._initial);
  final ProfileState _initial;

  @override
  ProfileState build() => _initial;

  @override
  Future<void> loadProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {}

  @override
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

User _makeUser() {
  final now = DateTime(2024, 1, 1);
  return User(
    userId: 'user-1',
    displayName: 'Test User',
    createdAt: now,
    updatedAt: now,
  );
}

UserStats _makeStats() => const UserStats(
      eventsAttendedCount: 3,
      itemsPurchasedCount: 5,
      photosSquishedCount: 10,
      commentsAddedCount: 2,
    );

Widget _buildScreen(
  ProfileState state, {
  VoidCallback? onEditTap,
}) {
  return ProviderScope(
    overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(state)),
    ],
    child: MaterialApp(
      home: ProfileScreen(
        userId: 'user-1',
        onEditTap: onEditTap,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProfileScreen', () {
    testWidgets("renders Scaffold with key 'profile_screen'", (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.byKey(const Key('profile_screen')), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester
          .pumpWidget(_buildScreen(const ProfileState(isLoading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(const ProfileState(error: 'Something went wrong')),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows displayName when profile is loaded', (tester) async {
      await tester.pumpWidget(
        _buildScreen(ProfileState(profile: _makeUser())),
      );
      expect(find.text('Test User'), findsWidgets);
    });

    testWidgets('shows stats section when stats are available', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          ProfileState(profile: _makeUser(), stats: _makeStats()),
        ),
      );
      expect(find.text('Events Attended'), findsOneWidget);
    });

    testWidgets("shows 'Edit Profile' settings item", (tester) async {
      await tester.pumpWidget(
        _buildScreen(ProfileState(profile: _makeUser())),
      );
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets("shows 'Settings' settings item", (tester) async {
      await tester.pumpWidget(
        _buildScreen(ProfileState(profile: _makeUser())),
      );
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets("shows 'Logout' settings item", (tester) async {
      await tester.pumpWidget(
        _buildScreen(ProfileState(profile: _makeUser())),
      );
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets("tapping 'Edit Profile' triggers onEditTap callback",
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildScreen(
          ProfileState(profile: _makeUser()),
          onEditTap: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Edit Profile'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
