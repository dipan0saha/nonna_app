import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/di/network_status_notifier.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/screens/home_screen.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

/// Fake home notifier that records [refresh] calls.
class _FakeHomeNotifier extends HomeScreenNotifier {
  int refreshCallCount = 0;

  @override
  HomeScreenState build() => const HomeScreenState(
        selectedBabyProfileId: 'baby-1',
        selectedRole: UserRole.owner,
      );

  @override
  Future<void> loadTiles({
    required String babyProfileId,
    required UserRole role,
  }) async {}

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }

  @override
  Future<void> onPullToRefresh() async {}

  @override
  Future<void> retry() async {}

  @override
  Future<void> toggleRole(UserRole newRole) async {}
}

/// Simple [Notifier<bool>] that always returns [_value].
class _StaticOnlineNotifier extends NetworkStatusNotifier {
  _StaticOnlineNotifier(this._value);
  final bool _value;

  @override
  bool build() => _value;
}

// ---------------------------------------------------------------------------
// Builder helper
// ---------------------------------------------------------------------------

Widget _buildScreen({
  required bool isOnline,
  required _FakeHomeNotifier fakeHome,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuthNotifier.new),
      homeScreenProvider.overrideWith(() => fakeHome),
      isOnlineProvider.overrideWith(() => _StaticOnlineNotifier(isOnline)),
    ],
    child: const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen offline indicator', () {
    // -------------------------------------------------------------------------
    // 1. Banner hidden when online
    // -------------------------------------------------------------------------
    testWidgets('1. banner is hidden when device is online', (tester) async {
      final fakeHome = _FakeHomeNotifier();

      await tester.pumpWidget(
        _buildScreen(isOnline: true, fakeHome: fakeHome),
      );
      await tester.pump();

      expect(find.text('No internet connection'), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 2. Banner visible when offline
    // -------------------------------------------------------------------------
    testWidgets('2. banner is visible when device is offline', (tester) async {
      final fakeHome = _FakeHomeNotifier();

      await tester.pumpWidget(
        _buildScreen(isOnline: false, fakeHome: fakeHome),
      );
      await tester.pump();

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. Retry button present when offline
    // -------------------------------------------------------------------------
    testWidgets('3. Retry button is visible when offline', (tester) async {
      final fakeHome = _FakeHomeNotifier();

      await tester.pumpWidget(
        _buildScreen(isOnline: false, fakeHome: fakeHome),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. Tapping Retry calls refresh()
    // -------------------------------------------------------------------------
    testWidgets('4. tapping Retry calls homeScreenProvider.notifier.refresh()',
        (tester) async {
      final fakeHome = _FakeHomeNotifier();

      await tester.pumpWidget(
        _buildScreen(isOnline: false, fakeHome: fakeHome),
      );
      await tester.pump();

      expect(fakeHome.refreshCallCount, equals(0));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(fakeHome.refreshCallCount, equals(1));
    });
  });
}
