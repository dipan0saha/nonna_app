import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
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
  SettingsState build() => const SettingsState();

  /// Toggle notifications
  void toggleNotifications({required bool enabled}) {
    state = state.copyWith(notificationsEnabled: enabled, saveSuccess: false);
    debugPrint('✅ Notifications toggled: $enabled');
  }

  /// Toggle dark mode
  void toggleDarkMode({required bool enabled}) {
    state = state.copyWith(darkModeEnabled: enabled, saveSuccess: false);
    debugPrint('✅ Dark mode toggled: $enabled');
  }

  /// Change language
  void changeLanguage(String language) {
    state = state.copyWith(language: language, saveSuccess: false);
    debugPrint('✅ Language changed: $language');
  }

  /// Save settings
  Future<void> saveSettings() async {
    try {
      state = state.copyWith(isSaving: true, saveError: null, saveSuccess: false);
      // TODO: persist to storage/database
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!ref.mounted) return;
      state = state.copyWith(isSaving: false, saveSuccess: true);
      debugPrint('✅ Settings saved');
    } catch (e) {
      if (!ref.mounted) return;
      final msg = 'Failed to save settings: $e';
      debugPrint('❌ $msg');
      state = state.copyWith(isSaving: false, saveError: msg);
    }
  }
}

/// Settings provider
final settingsProvider =
    NotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
