import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/name_suggestion.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/tiles/name_suggestions/providers/name_suggestions_provider.dart';
import 'package:nonna_app/tiles/name_suggestions/widgets/name_suggestions_tile.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeNameSuggestionsNotifier extends NameSuggestionsNotifier {
  _FakeNameSuggestionsNotifier(this._state);
  final NameSuggestionsState _state;

  @override
  NameSuggestionsState build() => _state;

  @override
  Future<void> load(
      {required String babyProfileId, bool forceRefresh = false}) async {}

  @override
  Future<bool> addSuggestion({
    required String babyProfileId,
    required String userId,
    required String name,
    required Gender gender,
  }) async =>
      true;

  @override
  Future<bool> likeSuggestion({
    required String suggestionId,
    required String userId,
  }) async =>
      true;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._state);
  final AuthState _state;

  @override
  AuthState build() => _state;
}

class _FakeSelectedBabyProfileNotifier extends SelectedBabyProfileNotifier {
  @override
  String? build() => 'bp_1';
}

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

NameSuggestion _makeSuggestion({
  String id = 'ns_1',
  String name = 'Olivia',
  Gender gender = Gender.female,
}) {
  final now = DateTime.now();
  return NameSuggestion(
    id: id,
    babyProfileId: 'bp_1',
    userId: 'u_1',
    gender: gender,
    suggestedName: name,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildWidget(NameSuggestionsState state, {AuthState? authState}) {
  final resolvedAuth = authState ?? const AuthState.unauthenticated();
  return ProviderScope(
    overrides: [
      nameSuggestionsProvider
          .overrideWith(() => _FakeNameSuggestionsNotifier(state)),
      authProvider.overrideWith(() => _FakeAuthNotifier(resolvedAuth)),
      selectedBabyProfileProvider
          .overrideWith(() => _FakeSelectedBabyProfileNotifier()),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: NameSuggestionsSmartTile(babyProfileId: 'bp_1'),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NameSuggestionsSmartTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();
      expect(find.byKey(const Key('name_suggestions_tile')), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading',
        (tester) async {
      await tester.pumpWidget(
          _buildWidget(const NameSuggestionsState(isLoading: true)));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when error is set', (tester) async {
      await tester.pumpWidget(
          _buildWidget(const NameSuggestionsState(error: 'Load failed')));
      await tester.pump();
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when suggestions list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();
      expect(find.byType(EmptyState), findsOneWidget);
      expect(
        find.text('No name suggestions yet.\nTap + to suggest one!'),
        findsOneWidget,
      );
    });

    testWidgets('shows suggestion rows with correct keys', (tester) async {
      final suggestions = [
        _makeSuggestion(id: 'ns_1', name: 'Olivia'),
        _makeSuggestion(id: 'ns_2', name: 'Liam', gender: Gender.male),
      ];
      await tester.pumpWidget(
          _buildWidget(NameSuggestionsState(suggestions: suggestions)));
      await tester.pump();

      expect(find.byKey(const Key('name_suggestion_ns_1')), findsOneWidget);
      expect(find.byKey(const Key('name_suggestion_ns_2')), findsOneWidget);
      expect(find.text('Olivia'), findsOneWidget);
      expect(find.text('Liam'), findsOneWidget);
    });

    testWidgets('add_name_suggestion_button is present in header',
        (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();
      expect(
        find.byKey(const Key('add_name_suggestion_button')),
        findsOneWidget,
      );
    });

    testWidgets('tapping add button reveals the name suggestion form',
        (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();

      // Form should not be visible yet
      expect(find.byKey(const Key('name_suggestion_text_field')), findsNothing);

      await tester.tap(find.byKey(const Key('add_name_suggestion_button')));
      await tester.pump();

      // After tap the form appears
      expect(
        find.byKey(const Key('name_suggestion_text_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('submit_name_suggestion_button')),
        findsOneWidget,
      );
    });

    testWidgets('tapping add button again hides the form', (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();

      // Open form
      await tester.tap(find.byKey(const Key('add_name_suggestion_button')));
      await tester.pump();
      expect(
          find.byKey(const Key('name_suggestion_text_field')), findsOneWidget);

      // Close form
      await tester.tap(find.byKey(const Key('add_name_suggestion_button')));
      await tester.pump();
      expect(find.byKey(const Key('name_suggestion_text_field')), findsNothing);
    });

    testWidgets('gender chips are shown inside the form', (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();

      await tester.tap(find.byKey(const Key('add_name_suggestion_button')));
      await tester.pump();

      // Gender.values renders one ChoiceChip per gender via key 'gender_chip_<name>'
      for (final g in Gender.values) {
        expect(find.byKey(Key('gender_chip_${g.name}')), findsOneWidget);
      }
    });

    testWidgets('header shows Name Suggestions title', (tester) async {
      await tester.pumpWidget(_buildWidget(const NameSuggestionsState()));
      await tester.pump();
      expect(find.text('Name Suggestions'), findsOneWidget);
    });
  });
}
