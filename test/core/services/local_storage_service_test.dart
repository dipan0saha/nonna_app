import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalStorageService', () {
    late LocalStorageService localStorage;

    setUp(() {
      localStorage = LocalStorageService();
    });

    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(localStorage.isInitialized, false);
      });
    });

    group('isOnboardingCompleted', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.isOnboardingCompleted,
          throwsStateError,
        );
      });
    });

    group('setOnboardingCompleted', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setOnboardingCompleted(true),
          throwsStateError,
        );
      });
    });

    group('themeMode', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.themeMode,
          throwsStateError,
        );
      });
    });

    group('setThemeMode', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setThemeMode('dark'),
          throwsStateError,
        );
      });
    });

    group('languageCode', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.languageCode,
          throwsStateError,
        );
      });
    });

    group('setLanguageCode', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setLanguageCode('en'),
          throwsStateError,
        );
      });
    });

    group('isAnalyticsEnabled', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.isAnalyticsEnabled,
          throwsStateError,
        );
      });
    });

    group('setAnalyticsEnabled', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setAnalyticsEnabled(true),
          throwsStateError,
        );
      });
    });

    group('isNotificationsEnabled', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.isNotificationsEnabled,
          throwsStateError,
        );
      });
    });

    group('setNotificationsEnabled', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setNotificationsEnabled(true),
          throwsStateError,
        );
      });
    });

    group('selectedBabyProfileId', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.selectedBabyProfileId,
          throwsStateError,
        );
      });
    });

    group('setSelectedBabyProfileId', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setSelectedBabyProfileId('123'),
          throwsStateError,
        );
      });
    });

    group('isBiometricEnabled', () {
      test('throws StateError when not initialized', () {
        expect(
          () => localStorage.isBiometricEnabled,
          throwsStateError,
        );
      });
    });

    group('setBiometricEnabled', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await localStorage.setBiometricEnabled(true),
          throwsStateError,
        );
      });
    });

    group('clearPreferences onboarding protection', () {
      test('preserves onboarding keys when clearing preferences', () async {
        SharedPreferences.setMockInitialValues({});
        final service = LocalStorageService();
        await service.initialize();

        await service.setString(OnboardingStorageKeys.path, 'owner');
        await service.setString(OnboardingStorageKeys.step, 'signup');
        await service.setString(
            OnboardingStorageKeys.pendingInviteToken, 'tok');
        await service.setBool(OnboardingStorageKeys.usedOAuth, true);
        await service.setOnboardingCompleted(false);
        await service.setString('theme_mode', 'dark');

        await service.clearPreferences();

        expect(service.getString(OnboardingStorageKeys.path), 'owner');
        expect(service.getString(OnboardingStorageKeys.step), 'signup');
        expect(
          service.getString(OnboardingStorageKeys.pendingInviteToken),
          'tok',
        );
        expect(service.getBool(OnboardingStorageKeys.usedOAuth), isTrue);
        expect(service.isOnboardingCompleted, isFalse);
        expect(service.getString('theme_mode'), isNull);
      });
    });
  });
}
