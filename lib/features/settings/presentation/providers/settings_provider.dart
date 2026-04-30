import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/di/providers.dart';

/// Settings state
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class SettingsState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const SettingsState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'en',
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    bool? isSaving,
    String? saveError,
    bool? saveSuccess,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

/// Settings Notifier
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.watch(localStorageServiceProvider);
    final theme = storage.themeMode;
    return SettingsState(
      notificationsEnabled: storage.isNotificationsEnabled,
      darkModeEnabled: theme == 'dark' ||
          theme == 'system' &&
              PlatformDispatcher.instance.platformBrightness == Brightness.dark,
      language: storage.languageCode ?? 'en',
    );
  }

  /// Toggle notifications
  void toggleNotifications({required bool enabled}) async {
    state = state.copyWith(notificationsEnabled: enabled, saveSuccess: false);
    await ref
        .read(localStorageServiceProvider)
        .setNotificationsEnabled(enabled);
    debugPrint('✅ Notifications toggled: $enabled');
  }

  /// Toggle dark mode
  void toggleDarkMode({required bool enabled}) async {
    state = state.copyWith(darkModeEnabled: enabled, saveSuccess: false);
    await ref
        .read(localStorageServiceProvider)
        .setThemeMode(enabled ? 'dark' : 'light');
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
