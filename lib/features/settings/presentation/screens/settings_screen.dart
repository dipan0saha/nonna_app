import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/features/settings/presentation/providers/settings_provider.dart';

/// Settings screen for configuring app preferences.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      key: const Key('settings_screen'),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            key: const Key('notifications_toggle'),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications about events and updates'),
            value: state.notificationsEnabled,
            onChanged: (v) => notifier.toggleNotifications(enabled: v),
          ),
          SwitchListTile(
            key: const Key('dark_mode_toggle'),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: state.darkModeEnabled,
            onChanged: (v) => notifier.toggleDarkMode(enabled: v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Language'),
          ListTile(
            key: const Key('language_tile'),
            title: const Text('Language'),
            subtitle: Text(_languageLabel(state.language)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, state.language, notifier),
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            key: const Key('sign_out_tile'),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onSignOut,
          ),
          if (state.saveError != null)
            Padding(
              padding: AppSpacing.screenPadding,
              child: Text(
                state.saveError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _languageLabel(String code) {
    const labels = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
    };
    return labels[code] ?? code;
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    String current,
    SettingsNotifier notifier,
  ) async {
    final languages = [
      ('en', 'English'),
      ('es', 'Spanish'),
      ('fr', 'French'),
      ('de', 'German'),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        children: languages
            .map(
              (lang) => SimpleDialogOption(
                key: Key('language_option_${lang.$1}'),
                onPressed: () {
                  notifier.changeLanguage(lang.$1);
                  Navigator.of(ctx).pop();
                },
                child: Text(lang.$2),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
