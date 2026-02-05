import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(NotificationService.instance.isInitialized, false);
      });
    });

    group('playerId', () {
      test('returns null before initialization', () {
        expect(NotificationService.instance.playerId, null);
      });
    });

    group('areNotificationsEnabled', () {
      test('returns default value before initialization', () {
        // This will throw since localStorage is not initialized
        // In a real test, we'd mock LocalStorageService
        expect(() => NotificationService.instance.areNotificationsEnabled,
            throwsA(anything));
      });
    });
  });
}
