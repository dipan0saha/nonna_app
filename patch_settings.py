import re

with open("lib/features/settings/presentation/providers/settings_provider.dart", "r") as f:
    content = f.read()

new_notifier = """class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.watch(localStorageServiceProvider);
    final theme = storage.themeMode;
    return SettingsState(
      notificationsEnabled: storage.isNotificationsEnabled,
      darkModeEnabled: theme == 'dark' || theme == 'system' && PlatformDispatcher.instance.platformBrightness == Brightness.dark,
      language: storage.languageCode ?? 'en',
    );
  }

  /// Toggle notifications
  void toggleNotifications({required bool enabled}) async {
    state = state.copyWith(notificationsEnabled: enabled, saveSuccess: false);
    await ref.read(localStorageServiceProvider).setNotificationsEnabled(enabled);
    debugPrint('✅ Notifications toggled: $enabled');
  }

  /// Toggle dark mode
  void toggleDarkMode({required bool enabled}) async {
    state = state.copyWith(darkModeEnabled: enabled, saveSuccess: false);
    await ref.read(localStorageServiceProvider).setThemeMode(enabled ? 'dark' : 'light');
    debugPrint('✅ Dark mode toggled: $enabled');
  }

  /// Change language
  void changeLanguage(String language) async {
    state = state.copyWith(language: language, saveSuccess: false);
    await ref.read(localStorageServiceProvider).setLanguageCode(language);
    debugPrint('✅ Language changed: $language');
  }

  /// Save settings
  Future<void> saveSettings() async {
    // Left for explicit save buttons if necessary, though now auto-saved
    state = state.copyWith(saveSuccess: true);
  }
}

/// Settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
"""

# Replace from `class SettingsNotifier extends Notifier<SettingsState> {` to the end
start_idx = content.find("class SettingsNotifier extends Notifier<SettingsState> {")
content = content[:start_idx] + new_notifier

with open("lib/features/settings/presentation/providers/settings_provider.dart", "w") as f:
    f.write(content)
