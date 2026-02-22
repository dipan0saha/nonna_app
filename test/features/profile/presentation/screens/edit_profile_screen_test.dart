import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/user.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:nonna_app/features/profile/presentation/screens/edit_profile_screen.dart';

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

User _makeUser({String displayName = 'Alice'}) {
  final now = DateTime(2024, 1, 1);
  return User(
    userId: 'user-1',
    displayName: displayName,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(
  ProfileState state, {
  VoidCallback? onCancelled,
}) {
  return ProviderScope(
    overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(state)),
    ],
    child: MaterialApp(
      home: EditProfileScreen(
        userId: 'user-1',
        onCancelled: onCancelled,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EditProfileScreen', () {
    testWidgets("renders Scaffold with key 'edit_profile_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.byKey(const Key('edit_profile_screen')), findsOneWidget);
    });

    testWidgets("shows 'Display Name' text field", (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.widgetWithText(TextFormField, 'Display Name'), findsOneWidget);
    });

    testWidgets("shows 'Enable Biometric Login' switch", (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.text('Enable Biometric Login'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('shows Save button', (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.pumpWidget(_buildScreen(const ProfileState()));
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('Save button is disabled when isSaving is true', (tester) async {
      await tester
          .pumpWidget(_buildScreen(const ProfileState(isSaving: true)));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('pre-fills display name from profile', (tester) async {
      await tester.pumpWidget(
        _buildScreen(ProfileState(profile: _makeUser(displayName: 'Bob'))),
      );
      await tester.pump(); // allow post-frame callback
      expect(find.widgetWithText(TextFormField, 'Bob'), findsOneWidget);
    });

    testWidgets('tapping Cancel calls onCancelled', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(
        _buildScreen(
          const ProfileState(),
          onCancelled: () => cancelled = true,
        ),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });
  });
}
