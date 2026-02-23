import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/screens/home_screen.dart';

// ---------------------------------------------------------------------------
// Fake HomeScreenNotifier
// ---------------------------------------------------------------------------

class _FakeHomeNotifier extends HomeScreenNotifier {
  _FakeHomeNotifier(this._initial);

  final HomeScreenState _initial;

  /// Optional callback invoked when [toggleRole] is called.
  ValueChanged<UserRole>? onToggleRole;

  @override
  HomeScreenState build() => _initial;

  @override
  Future<void> loadTiles({
    required String babyProfileId,
    required UserRole role,
  }) async {}

  @override
  Future<void> onPullToRefresh() async {}

  @override
  Future<void> retry() async {}

  @override
  Future<void> toggleRole(UserRole newRole) async {
    onToggleRole?.call(newRole);
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

TileConfig _makeTile(String id, String defId, int order) {
  final now = DateTime(2024, 1, 1);
  return TileConfig(
    id: id,
    screenId: 'home',
    tileDefinitionId: defId,
    role: UserRole.owner,
    displayOrder: order,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(
  HomeScreenState state, {
  String? babyProfileId,
  UserRole? userRole,
  bool isDualRole = false,
  int notificationCount = 0,
}) {
  return ProviderScope(
    overrides: [
      homeScreenProvider.overrideWith(() => _FakeHomeNotifier(state)),
    ],
    child: MaterialApp(
      home: HomeScreen(
        babyProfileId: babyProfileId,
        userRole: userRole,
        isDualRole: isDualRole,
        notificationCount: notificationCount,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen', () {
    testWidgets('renders home app bar', (tester) async {
      await tester.pumpWidget(
        _buildScreen(const HomeScreenState()),
      );
      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('shows empty prompt when no baby profile is set',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(const HomeScreenState()),
      );
      expect(
        find.text('Select a baby profile to get started'),
        findsOneWidget,
      );
    });

    testWidgets('shows shimmer cards when loading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(isLoading: true),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
        ),
      );
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(error: 'Failed to load'),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
        ),
      );
      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('renders tile cards when tiles are loaded', (tester) async {
      final tiles = [
        _makeTile('1', 'weather_tile', 1),
        _makeTile('2', 'photo_tile', 2),
      ];
      await tester.pumpWidget(
        _buildScreen(
          HomeScreenState(tiles: tiles),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
        ),
      );
      expect(find.text('weather_tile'), findsOneWidget);
      expect(find.text('photo_tile'), findsOneWidget);
    });

    testWidgets('shows empty state when tiles list is empty and loaded',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
        ),
      );
      expect(find.text('No tiles to display'), findsOneWidget);
    });

    testWidgets('shows role toggle for dual-role user', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(selectedRole: UserRole.owner),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
          isDualRole: true,
        ),
      );
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Follower'), findsOneWidget);
    });

    testWidgets('does not show role toggle for single-role user',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(),
          babyProfileId: 'p1',
          userRole: UserRole.owner,
          isDualRole: false,
        ),
      );
      // ChoiceChip labels should not appear
      expect(find.text('Follower'), findsNothing);
    });

    testWidgets('shows notification badge when count > 0', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          const HomeScreenState(),
          notificationCount: 7,
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('tapping follower role chip triggers role toggle',
        (tester) async {
      UserRole? toggled;
      final notifier = _FakeHomeNotifier(
        const HomeScreenState(selectedRole: UserRole.owner),
      )..onToggleRole = (r) => toggled = r;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeScreenProvider.overrideWith(() => notifier),
          ],
          child: const MaterialApp(
            home: HomeScreen(
              babyProfileId: 'p1',
              userRole: UserRole.owner,
              isDualRole: true,
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Follower'));
      await tester.pump();

      expect(toggled, equals(UserRole.follower));
    });
  });
}
