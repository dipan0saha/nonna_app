import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(cacheService.isInitialized, false);
      });
    });

    group('put', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await cacheService.put('key', 'value'),
          throwsStateError,
        );
      });
    });

    group('get', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await cacheService.get('key'),
          throwsStateError,
        );
      });
    });

    group('delete', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await cacheService.delete('key'),
          throwsStateError,
        );
      });
    });

    group('clear', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await cacheService.clear(),
          throwsStateError,
        );
      });
    });

    group('has', () {
      test('throws StateError when not initialized', () async {
        expect(
          () async => await cacheService.has('key'),
          throwsStateError,
        );
      });
    });

    group('getAllKeys', () {
      test('throws StateError when not initialized', () {
        expect(
          () => cacheService.getAllKeys(),
          throwsStateError,
        );
      });
    });
  });
}
