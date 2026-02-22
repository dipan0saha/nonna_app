import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/services/crash_recovery_handler.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CrashRecoveryHandler', () {
    test('hasPreviousCrash returns false before initialize', () {
      expect(CrashRecoveryHandler.hasPreviousCrash(), isFalse);
    });

    test('initialize completes without throwing', () async {
      await expectLater(CrashRecoveryHandler.initialize(), completes);
    });

    test('handleCrash completes without throwing', () async {
      await expectLater(
        CrashRecoveryHandler.handleCrash(
          Exception('boom'),
          StackTrace.current,
        ),
        completes,
      );
    });

    test('clearCrashState completes without throwing', () {
      expect(CrashRecoveryHandler.clearCrashState, returnsNormally);
    });

    test('restoreState completes without throwing', () async {
      await expectLater(CrashRecoveryHandler.restoreState(), completes);
    });

    test('hasPreviousCrash returns false after clearCrashState', () async {
      await CrashRecoveryHandler.initialize();
      CrashRecoveryHandler.clearCrashState();
      expect(CrashRecoveryHandler.hasPreviousCrash(), isFalse);
    });

    test('crash flag is persisted and cleared across initialize calls',
        () async {
      // Start with a clean SharedPreferences instance.
      final prefsBefore = await SharedPreferences.getInstance();
      expect(prefsBefore.getKeys(), isEmpty);

      // Simulate a crash — the flag should be persisted.
      await CrashRecoveryHandler.handleCrash(
        Exception('boom'),
        StackTrace.current,
      );
      final prefsAfterCrash = await SharedPreferences.getInstance();
      expect(prefsAfterCrash.getKeys(), isNotEmpty);

      // Simulate a new app startup; initialize should detect the previous
      // crash, call restoreState, and then clear the persisted flag.
      await CrashRecoveryHandler.initialize();
      final prefsAfterInitialize = await SharedPreferences.getInstance();
      expect(prefsAfterInitialize.getKeys(), isEmpty);

      // After initialize has handled the previous crash, there should be
      // no pending crash reported.
      expect(CrashRecoveryHandler.hasPreviousCrash(), isFalse);
    });
  });
}
