import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/supabase_client.dart';

void main() {
  group('SupabaseClientManager', () {
    tearDown(() {
      // Reset the client after each test
      SupabaseClientManager.reset();
    });

    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(SupabaseClientManager.isInitialized, false);
      });
    });

    group('instance', () {
      test('throws StateError when not initialized', () {
        expect(
          () => SupabaseClientManager.instance,
          throwsStateError,
        );
      });
    });

    group('dispose', () {
      test('resets initialization state', () {
        SupabaseClientManager.dispose();
        expect(SupabaseClientManager.isInitialized, false);
      });
    });

    group('reset', () {
      test('clears client and initialization state', () {
        SupabaseClientManager.reset();
        expect(SupabaseClientManager.isInitialized, false);
        expect(
          () => SupabaseClientManager.instance,
          throwsStateError,
        );
      });
    });
  });
}
