import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/auth/presentation/screens/role_selection_screen.dart';

// ---------------------------------------------------------------------------
// Fake AuthNotifier
// ---------------------------------------------------------------------------

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> signOut() async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildRoleSelectionScreen(
  AuthState initialState, {
  VoidCallback? onCreateProfile,
  VoidCallback? onJoinProfile,
  VoidCallback? onSkip,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(initialState)),
    ],
    child: MaterialApp(
      home: RoleSelectionScreen(
        onCreateProfile: onCreateProfile,
        onJoinProfile: onJoinProfile,
        onSkip: onSkip,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RoleSelectionScreen', () {
    testWidgets('renders role cards', (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('create_profile_card')), findsOneWidget);
      expect(find.byKey(const Key('join_profile_card')), findsOneWidget);
    });

    testWidgets('renders continue button', (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('continue_button')), findsOneWidget);
    });

    testWidgets('continue button is disabled when no role selected',
        (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      final button =
          tester.widget<ElevatedButton>(find.byKey(const Key('continue_button')));
      expect(button.onPressed, isNull);
    });

    testWidgets('continue button is enabled after selecting a role',
        (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      await tester.tap(find.byKey(const Key('create_profile_card')));
      await tester.pump();

      final button =
          tester.widget<ElevatedButton>(find.byKey(const Key('continue_button')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onCreateProfile when create card selected and continue tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildRoleSelectionScreen(
          const AuthState.unauthenticated(),
          onCreateProfile: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('create_profile_card')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onJoinProfile when join card selected and continue tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildRoleSelectionScreen(
          const AuthState.unauthenticated(),
          onJoinProfile: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('join_profile_card')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('continue_button')));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders skip button when onSkip provided', (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(
          const AuthState.unauthenticated(),
          onSkip: () {},
        ),
      );

      expect(find.byKey(const Key('skip_button')), findsOneWidget);
    });

    testWidgets('does not render skip button when onSkip is null',
        (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('skip_button')), findsNothing);
    });

    testWidgets('calls onSkip when skip button tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildRoleSelectionScreen(
          const AuthState.unauthenticated(),
          onSkip: () => tapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('skip_button')));
      expect(tapped, isTrue);
    });

    testWidgets('renders sign out button', (tester) async {
      await tester.pumpWidget(
        _buildRoleSelectionScreen(const AuthState.unauthenticated()),
      );

      expect(find.byKey(const Key('sign_out_button')), findsOneWidget);
    });
  });
}
