import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:nonna_app/features/gamification/presentation/screens/gamification_screen.dart';

class _FakeGamificationNotifier extends GamificationNotifier {
  _FakeGamificationNotifier(this._initial);
  final GamificationState _initial;

  @override
  GamificationState build() => _initial;

  @override
  Future<void> load({required String babyProfileId}) async {}
}

Widget _buildScreen(GamificationState state) {
  return ProviderScope(
    overrides: [
      gamificationProvider
          .overrideWith(() => _FakeGamificationNotifier(state)),
    ],
    child: const MaterialApp(
      home: GamificationScreen(babyProfileId: 'baby-1'),
    ),
  );
}

void main() {
  group('GamificationScreen', () {
    testWidgets("renders Scaffold with key 'gamification_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(const GamificationState()));
      expect(find.byKey(const Key('gamification_screen')), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester
          .pumpWidget(_buildScreen(const GamificationState(isLoading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error is set', (tester) async {
      await tester.pumpWidget(
          _buildScreen(const GamificationState(error: 'Failed to load')));
      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('shows tab bar with Name Suggestions and Votes tabs',
        (tester) async {
      await tester.pumpWidget(_buildScreen(const GamificationState()));
      expect(find.byKey(const Key('name_suggestions_tab')), findsOneWidget);
      expect(find.byKey(const Key('votes_tab')), findsOneWidget);
    });

    testWidgets('shows empty state for name suggestions tab when empty',
        (tester) async {
      await tester.pumpWidget(_buildScreen(const GamificationState()));
      expect(
          find.byKey(const Key('no_name_suggestions_empty_state')),
          findsOneWidget);
    });

    testWidgets('shows empty state for votes tab when empty', (tester) async {
      await tester.pumpWidget(_buildScreen(const GamificationState()));
      await tester.tap(find.byKey(const Key('votes_tab')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('no_votes_empty_state')), findsOneWidget);
    });
  });
}
