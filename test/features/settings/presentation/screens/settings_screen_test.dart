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
  void changeLanguage(String language) {}

  @override
  Future<void> saveSettings() async {}
}

Widget _buildScreen(SettingsState state) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => _FakeSettingsNotifier(state)),
    ],
    child: const MaterialApp(
      home: SettingsScreen(),
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
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('shows notifications toggle', (tester) async {
      await tester.pumpWidget(_buildScreen(const SettingsState()));
      expect(find.byKey(const Key('notifications_toggle')), findsOneWidget);
    });

    testWidgets('notifications toggle reflects state', (tester) async {
      await tester.pumpWidget(
          _buildScreen(const SettingsState(notificationsEnabled: false)));
      final toggle = tester.widget<SwitchListTile>(find.descendant(
        of: find.byKey(const Key('notifications_toggle')),
        matching: find.byType(SwitchListTile),
      ));
      expect(toggle.value, isFalse);
    });
  });
}
