import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/persistence_strategies.dart';

void main() {
  group('MemoryPersistenceStrategy', () {
    late MemoryPersistenceStrategy strategy;

    setUp(() {
      strategy = MemoryPersistenceStrategy();
    });

    group('save and load', () {
      test('saves and loads data successfully', () async {
        final data = {'key': 'value', 'number': 42};
        await strategy.save('test_key', data);

        final loaded = await strategy.load('test_key');
        expect(loaded, equals(data));
      });

      test('returns null for non-existent key', () async {
        final loaded = await strategy.load('non_existent');
        expect(loaded, isNull);
      });

      test('respects TTL expiration', () async {
        final data = {'key': 'value'};
        await strategy.save(
          'test_key',
          data,
          ttl: const Duration(milliseconds: 100),
        );

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 150));

        final loaded = await strategy.load('test_key');
        expect(loaded, isNull);
      });

      test('saves multiple keys independently', () async {
        await strategy.save('key1', {'data': 'value1'});
        await strategy.save('key2', {'data': 'value2'});

        final loaded1 = await strategy.load('key1');
        final loaded2 = await strategy.load('key2');

        expect(loaded1?['data'], equals('value1'));
        expect(loaded2?['data'], equals('value2'));
      });
    });

    group('delete', () {
      test('deletes existing key', () async {
        await strategy.save('test_key', {'key': 'value'});
        await strategy.delete('test_key');

        final loaded = await strategy.load('test_key');
        expect(loaded, isNull);
      });

      test('handles deleting non-existent key', () async {
        // Should not throw
        await strategy.delete('non_existent');
      });
    });

    group('has', () {
      test('returns true for existing key', () async {
        await strategy.save('test_key', {'key': 'value'});
        expect(await strategy.has('test_key'), isTrue);
      });

      test('returns false for non-existent key', () async {
        expect(await strategy.has('non_existent'), isFalse);
      });

      test('returns false for expired key', () async {
        await strategy.save(
          'test_key',
          {'key': 'value'},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        expect(await strategy.has('test_key'), isFalse);
      });
    });

    group('clear', () {
      test('clears all data', () async {
        await strategy.save('key1', {'data': '1'});
        await strategy.save('key2', {'data': '2'});
        await strategy.clear();

        expect(await strategy.has('key1'), isFalse);
        expect(await strategy.has('key2'), isFalse);
      });
    });

    group('getAllKeys', () {
      test('returns all valid keys', () async {
        await strategy.save('key1', {'data': '1'});
        await strategy.save('key2', {'data': '2'});

        final keys = await strategy.getAllKeys();
        expect(keys, containsAll(['key1', 'key2']));
      });

      test('excludes expired keys', () async {
        await strategy.save('key1', {'data': '1'});
        await strategy.save(
          'key2',
          {'data': '2'},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        final keys = await strategy.getAllKeys();
        expect(keys, contains('key1'));
        expect(keys, isNot(contains('key2')));
      });
    });

    group('evict', () {
      test('removes expired entries', () async {
        await strategy.save('key1', {'data': '1'});
        await strategy.save(
          'key2',
          {'data': '2'},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        strategy.evict();

        expect(await strategy.has('key1'), isTrue);
        expect(await strategy.has('key2'), isFalse);
      });
    });
  });

  group('PersistenceStrategy Interface', () {
    test('MemoryPersistenceStrategy implements PersistenceStrategy', () {
      final strategy = MemoryPersistenceStrategy();
      expect(strategy, isA<PersistenceStrategy>());
    });
  });

  group('Data Types', () {
    late MemoryPersistenceStrategy strategy;

    setUp(() {
      strategy = MemoryPersistenceStrategy();
    });

    test('handles complex nested data', () async {
      final data = {
        'string': 'value',
        'number': 42,
        'double': 3.14,
        'bool': true,
        'list': [1, 2, 3],
        'nested': {
          'inner': 'value',
        },
      };

      await strategy.save('test', data);
      final loaded = await strategy.load('test');

      expect(loaded, equals(data));
    });

    test('handles empty maps', () async {
      final data = <String, dynamic>{};
      await strategy.save('empty', data);
      final loaded = await strategy.load('empty');

      expect(loaded, equals(data));
    });
  });

  group('Edge Cases', () {
    late MemoryPersistenceStrategy strategy;

    setUp(() {
      strategy = MemoryPersistenceStrategy();
    });

    test('handles overwriting existing key', () async {
      await strategy.save('key', {'value': 'first'});
      await strategy.save('key', {'value': 'second'});

      final loaded = await strategy.load('key');
      expect(loaded?['value'], equals('second'));
    });

    test('handles TTL of zero duration', () async {
      await strategy.save(
        'key',
        {'value': 'test'},
        ttl: Duration.zero,
      );

      // Should be immediately expired
      final loaded = await strategy.load('key');
      expect(loaded, isNull);
    });

    test('handles very long TTL', () async {
      await strategy.save(
        'key',
        {'value': 'test'},
        ttl: const Duration(days: 365),
      );

      final loaded = await strategy.load('key');
      expect(loaded, isNotNull);
    });
  });
}
