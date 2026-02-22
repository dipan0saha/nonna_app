import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:nonna_app/features/settings/presentation/screens/settings_screen.dart';

class _FakeSettingsNotifier extends SettingsNotifier {
  _FakeSettingsNotifier(this._initial);
  final SettingsState _initial;

  @override
  SettingsState build() => _initial;

  @override
  void toggleNotifications({required bool enabled}) {}

  @override
  void toggleDarkMode({required bool enabled}) {}

  @override
  void changeLanguage(String language) {}

  @override
  Future<void> saveSettings() async {}
}

Widget _buildScreen(SettingsState state, {VoidCallback? onSignOut}) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => _FakeSettingsNotifier(state)),
    ],
    child: MaterialApp(
      home: SettingsScreen(onSignOut: onSignOut),
    ),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets("renders Scaffold with key 'settings_screen'", (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('settings_screen')), findsOneWidget);
    });

    testWidgets('shows app bar title "Settings"', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows notifications toggle', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('notifications_toggle')), findsOneWidget);
    });

    testWidgets('shows dark mode toggle', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('dark_mode_toggle')), findsOneWidget);
    });

    testWidgets('shows language tile', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('language_tile')), findsOneWidget);
    });

    testWidgets('shows sign out tile', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('sign_out_tile')), findsOneWidget);
    });

    testWidgets('calls onSignOut when sign out tile tapped', (tester) async {
      var called = false;
      await tester
          .pumpWidget(_buildScreen(const SettingsState(), onSignOut: () => called = true));
      await tester.tap(find.byKey(const Key('sign_out_tile')));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('notifications toggle reflects state', (tester) async {
      await tester.pumpWidget(
          _buildScreen(const SettingsState(notificationsEnabled: false)));
      final toggle = tester.widget<SwitchListTile>(
          find.byKey(const Key('notifications_toggle')));
      expect(toggle.value, isFalse);
    });
  });
}
