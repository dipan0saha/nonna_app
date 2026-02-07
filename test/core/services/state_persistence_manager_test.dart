import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/services/persistence_strategies.dart';
import 'package:nonna_app/core/services/state_persistence_manager.dart';

void main() {
  group('StatePersistenceManager', () {
    late StatePersistenceManager manager;

    setUp(() {
      manager = StatePersistenceManager(
        syncInterval: const Duration(seconds: 30),
        evictionInterval: const Duration(seconds: 10),
      );
    });

    tearDown(() async {
      if (manager.isInitialized) {
        await manager.dispose();
      }
    });

    group('Initialization', () {
      test('starts as not initialized', () {
        expect(manager.isInitialized, isFalse);
      });

      test('initializes successfully', () async {
        await manager.initialize();
        expect(manager.isInitialized, isTrue);
      });

      test('handles double initialization', () async {
        await manager.initialize();
        // Should not throw
        await manager.initialize();
        expect(manager.isInitialized, isTrue);
      });

      test('throws when accessing before initialization', () async {
        expect(
          () async => await manager.saveState('key', {}),
          throwsStateError,
        );
      });
    });

    group('Save and Load State', () {
      setUp(() async {
        await manager.initialize();
      });

      test('saves and loads state successfully', () async {
        final data = {'count': 42, 'name': 'test'};
        await manager.saveState('test_key', data);

        final loaded = await manager.loadState('test_key');
        expect(loaded, equals(data));
      });

      test('returns null for non-existent key', () async {
        final loaded = await manager.loadState('non_existent');
        expect(loaded, isNull);
      });

      test('handles multiple states', () async {
        await manager.saveState('state1', {'value': 1});
        await manager.saveState('state2', {'value': 2});

        final state1 = await manager.loadState('state1');
        final state2 = await manager.loadState('state2');

        expect(state1?['value'], equals(1));
        expect(state2?['value'], equals(2));
      });

      test('respects TTL expiration', () async {
        await manager.saveState(
          'test_key',
          {'value': 'test'},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        final loaded = await manager.loadState('test_key');
        expect(loaded, isNull);
      });

      test('saves to memory by default', () async {
        await manager.saveState('key', {'value': 'test'});
        final loaded = await manager.loadState(
          'key',
          strategy: PersistenceLevel.memory,
        );
        expect(loaded, isNotNull);
      });
    });

    group('Delete State', () {
      setUp(() async {
        await manager.initialize();
      });

      test('deletes state successfully', () async {
        await manager.saveState('test_key', {'value': 'test'});
        await manager.deleteState('test_key');

        final loaded = await manager.loadState('test_key');
        expect(loaded, isNull);
      });

      test('handles deleting non-existent key', () async {
        // Should not throw
        await manager.deleteState('non_existent');
      });
    });

    group('Has State', () {
      setUp(() async {
        await manager.initialize();
      });

      test('returns true for existing state', () async {
        await manager.saveState('test_key', {'value': 'test'});
        expect(await manager.hasState('test_key'), isTrue);
      });

      test('returns false for non-existent state', () async {
        expect(await manager.hasState('non_existent'), isFalse);
      });

      test('returns false for expired state', () async {
        await manager.saveState(
          'test_key',
          {'value': 'test'},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        expect(await manager.hasState('test_key'), isFalse);
      });
    });

    group('Clear All', () {
      setUp(() async {
        await manager.initialize();
      });

      test('clears all states', () async {
        await manager.saveState('key1', {'value': 1});
        await manager.saveState('key2', {'value': 2});
        await manager.clearAll();

        expect(await manager.hasState('key1'), isFalse);
        expect(await manager.hasState('key2'), isFalse);
      });
    });

    group('Get All Keys', () {
      setUp(() async {
        await manager.initialize();
      });

      test('returns all state keys', () async {
        await manager.saveState('key1', {'value': 1});
        await manager.saveState('key2', {'value': 2});

        final keys = await manager.getAllKeys();
        expect(keys, containsAll(['key1', 'key2']));
      });

      test('returns empty list when no states', () async {
        final keys = await manager.getAllKeys();
        expect(keys, isEmpty);
      });

      test('excludes expired states', () async {
        await manager.saveState('key1', {'value': 1});
        await manager.saveState(
          'key2',
          {'value': 2},
          ttl: const Duration(milliseconds: 100),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        final keys = await manager.getAllKeys();
        expect(keys, contains('key1'));
        expect(keys, isNot(contains('key2')));
      });
    });

    group('Persistence Levels', () {
      setUp(() async {
        await manager.initialize();
      });

      test('saves to memory level', () async {
        await manager.saveState(
          'key',
          {'value': 'test'},
          strategy: PersistenceLevel.memory,
        );

        final loaded = await manager.loadState('key');
        expect(loaded, isNotNull);
      });

      test('loads from specific strategy', () async {
        await manager.saveState('key', {'value': 'test'});

        final loaded = await manager.loadState(
          'key',
          strategy: PersistenceLevel.memory,
        );
        expect(loaded, isNotNull);
      });

      test('checks existence in specific strategy', () async {
        await manager.saveState(
          'key',
          {'value': 'test'},
          strategy: PersistenceLevel.memory,
        );

        expect(
          await manager.hasState(
            'key',
            strategy: PersistenceLevel.memory,
          ),
          isTrue,
        );
      });
    });

    group('Hydration', () {
      setUp(() async {
        await manager.initialize();
      });

      test('hydrates provider state from persisted data', () async {
        final data = {'count': 42};
        await manager.saveState('counter_provider', data);

        // Mock provider ref (not full test, just structure validation)
        final hydrated = await manager.loadState('counter_provider');
        expect(hydrated, equals(data));
      });
    });

    group('Sync', () {
      setUp(() async {
        await manager.initialize();
      });

      test('manual sync completes without error', () async {
        await manager.saveState('key', {'value': 'test'});
        // Should not throw
        await manager.sync();
      });
    });

    group('Dispose', () {
      test('disposes successfully', () async {
        await manager.initialize();
        await manager.dispose();
        expect(manager.isInitialized, isFalse);
      });

      test('handles dispose when not initialized', () async {
        // Should not throw
        await manager.dispose();
      });
    });

    group('Factory Constructor', () {
      test('creates manager with services', () {
        final manager = StatePersistenceManager.withServices();
        expect(manager, isA<StatePersistenceManager>());
      });

      test('accepts custom intervals', () {
        final manager = StatePersistenceManager.withServices(
          syncInterval: const Duration(minutes: 10),
          evictionInterval: const Duration(minutes: 2),
        );
        expect(manager, isA<StatePersistenceManager>());
      });
    });

    group('Complex Data Types', () {
      setUp(() async {
        await manager.initialize();
      });

      test('handles nested objects', () async {
        final data = {
          'user': {
            'id': '123',
            'name': 'Test',
            'settings': {
              'theme': 'dark',
              'notifications': true,
            },
          },
        };

        await manager.saveState('complex', data);
        final loaded = await manager.loadState('complex');
        expect(loaded, equals(data));
      });

      test('handles arrays', () async {
        final data = {
          'items': [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
          ],
        };

        await manager.saveState('array', data);
        final loaded = await manager.loadState('array');
        expect(loaded, equals(data));
      });
    });

    group('Edge Cases', () {
      setUp(() async {
        await manager.initialize();
      });

      test('handles empty state', () async {
        final data = <String, dynamic>{};
        await manager.saveState('empty', data);
        final loaded = await manager.loadState('empty');
        expect(loaded, equals(data));
      });

      test('handles overwriting state', () async {
        await manager.saveState('key', {'version': 1});
        await manager.saveState('key', {'version': 2});

        final loaded = await manager.loadState('key');
        expect(loaded?['version'], equals(2));
      });

      test('handles concurrent saves to different keys', () async {
        await Future.wait([
          manager.saveState('key1', {'value': 1}),
          manager.saveState('key2', {'value': 2}),
          manager.saveState('key3', {'value': 3}),
        ]);

        final loaded1 = await manager.loadState('key1');
        final loaded2 = await manager.loadState('key2');
        final loaded3 = await manager.loadState('key3');

        expect(loaded1?['value'], equals(1));
        expect(loaded2?['value'], equals(2));
        expect(loaded3?['value'], equals(3));
      });
    });
  });
}
