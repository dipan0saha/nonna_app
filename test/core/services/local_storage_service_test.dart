import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';

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
  });
}
