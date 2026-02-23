import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/baby_profile_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/screens/edit_baby_profile_screen.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakeBabyProfileNotifier extends BabyProfileNotifier {
  _FakeBabyProfileNotifier(this._initial);
  final BabyProfileState _initial;

  @override
  BabyProfileState build() => _initial;

  @override
  Future<void> loadProfile({
    required String babyProfileId,
    required String currentUserId,
    bool forceRefresh = false,
  }) async {}

  @override
  Future<void> updateProfile({
    required String babyProfileId,
    required String name,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    Gender? gender,
    String? profilePhotoUrl,
    String? defaultLastNameSource,
  }) async {}

  @override
  Future<bool> deleteProfile({required String babyProfileId}) async => true;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

BabyProfile _makeBabyProfile({String name = 'Leo'}) {
  final now = DateTime(2024, 1, 1);
  return BabyProfile(
    id: 'baby-1',
    name: name,
    gender: Gender.male,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen(
  BabyProfileState state, {
  VoidCallback? onCancelled,
}) {
  return ProviderScope(
    overrides: [
      babyProfileProvider.overrideWith(() => _FakeBabyProfileNotifier(state)),
    ],
    child: MaterialApp(
      home: EditBabyProfileScreen(
        babyProfileId: 'baby-1',
        currentUserId: 'user-1',
        onCancelled: onCancelled,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EditBabyProfileScreen', () {
    testWidgets("renders Scaffold with key 'edit_baby_profile_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(
        find.byKey(const Key('edit_baby_profile_screen')),
        findsOneWidget,
      );
    });

    testWidgets("shows 'Baby Name' text field", (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.widgetWithText(TextFormField, 'Baby Name'), findsOneWidget);
    });

    testWidgets('shows Save button', (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets("shows 'Delete Profile' button", (tester) async {
      await tester.pumpWidget(_buildScreen(const BabyProfileState()));
      expect(find.text('Delete Profile'), findsOneWidget);
    });

    testWidgets('Save button is disabled when isSaving is true',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          BabyProfileState(
            profile: _makeBabyProfile(),
            isSaving: true,
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping Cancel triggers onCancelled', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(
        _buildScreen(
          const BabyProfileState(),
          onCancelled: () => cancelled = true,
        ),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });
  });
}
