import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/extensions/list_extensions.dart';

void main() {
  group('ListExtensions', () {
    group('safe access', () {
      final list = [1, 2, 3, 4, 5];

      test('getOrNull returns element at valid index', () {
        expect(list.getOrNull(0), 1);
        expect(list.getOrNull(2), 3);
      });

      test('getOrNull returns null for out of bounds index', () {
        expect(list.getOrNull(-1), isNull);
        expect(list.getOrNull(10), isNull);
      });

      test('getOrDefault returns element at valid index', () {
        expect(list.getOrDefault(0, 999), 1);
      });

      test('getOrDefault returns default for out of bounds', () {
        expect(list.getOrDefault(-1, 999), 999);
        expect(list.getOrDefault(10, 999), 999);
      });

      test('firstOrNull returns first element', () {
        expect(list.firstOrNull, 1);
      });

      test('firstOrNull returns null for empty list', () {
        expect(<int>[].firstOrNull, isNull);
      });

      test('lastOrNull returns last element', () {
        expect(list.lastOrNull, 5);
      });

      test('lastOrNull returns null for empty list', () {
        expect(<int>[].lastOrNull, isNull);
      });
    });

    group('filtering', () {
      test('filterMap filters and maps', () {
        final list = [1, 2, 3, 4, 5];
        final result = list.filterMap((x) => x.isEven ? x * 2 : null);
        expect(result, [4, 8]);
      });

      test('skipFirst skips first n elements', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.skipFirst(2), [3, 4, 5]);
        expect(list.skipFirst(), [2, 3, 4, 5]);
      });

      test('skipFirst returns empty list when skipping all', () {
        final list = [1, 2, 3];
        expect(list.skipFirst(5), isEmpty);
      });

      test('skipLast skips last n elements', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.skipLast(2), [1, 2, 3]);
        expect(list.skipLast(), [1, 2, 3, 4]);
      });

      test('skipLast returns empty list when skipping all', () {
        final list = [1, 2, 3];
        expect(list.skipLast(5), isEmpty);
      });

      test('chunk splits list into chunks', () {
        final list = [1, 2, 3, 4, 5, 6, 7];
        final result = list.chunk(3);
        expect(result, [
          [1, 2, 3],
          [4, 5, 6],
          [7]
        ]);
      });

      test('unique removes duplicates', () {
        final list = [1, 2, 2, 3, 3, 3, 4];
        expect(list.unique, [1, 2, 3, 4]);
      });

      test('uniqueBy removes duplicates by key', () {
        final list = ['apple', 'banana', 'apricot', 'blueberry'];
        final result = list.uniqueBy((s) => s[0]);
        expect(result, ['apple', 'banana']);
      });
    });

    group('grouping', () {
      test('groupBy groups elements by key', () {
        final list = [1, 2, 3, 4, 5, 6];
        final result = list.groupBy((x) => x.isEven);
        expect(result[true], [2, 4, 6]);
        expect(result[false], [1, 3, 5]);
      });

      test('partition splits list by predicate', () {
        final list = [1, 2, 3, 4, 5];
        final (truthy, falsy) = list.partition((x) => x.isEven);
        expect(truthy, [2, 4]);
        expect(falsy, [1, 3, 5]);
      });
    });

    group('sorting', () {
      test('sortedBy sorts by key', () {
        final list = ['cherry', 'apple', 'banana'];
        final result = list.sortedBy((s) => s);
        expect(result, ['apple', 'banana', 'cherry']);
      });

      test('sortedByDescending sorts in descending order', () {
        final list = [1, 3, 2, 5, 4];
        final result = list.sortedByDescending((x) => x);
        expect(result, [5, 4, 3, 2, 1]);
      });

      test('sortedBy does not modify original list', () {
        final list = [3, 1, 2];
        list.sortedBy((x) => x);
        expect(list, [3, 1, 2]);
      });
    });

    group('aggregation', () {
      test('sumBy calculates sum', () {
        final list = [
          {'value': 10},
          {'value': 20},
          {'value': 30}
        ];
        final result = list.sumBy((x) => x['value'] as num);
        expect(result, 60);
      });

      test('averageBy calculates average', () {
        final list = [
          {'value': 10},
          {'value': 20},
          {'value': 30}
        ];
        final result = list.averageBy((x) => x['value'] as num);
        expect(result, 20);
      });

      test('averageBy returns 0 for empty list', () {
        expect(<int>[].averageBy((x) => x), 0);
      });

      test('minBy finds minimum element', () {
        final list = [
          {'value': 30},
          {'value': 10},
          {'value': 20}
        ];
        final result = list.minBy((x) => x['value'] as int);
        expect(result?['value'], 10);
      });

      test('minBy returns null for empty list', () {
        expect(<int>[].minBy((x) => x), isNull);
      });

      test('maxBy finds maximum element', () {
        final list = [
          {'value': 30},
          {'value': 10},
          {'value': 20}
        ];
        final result = list.maxBy((x) => x['value'] as int);
        expect(result?['value'], 30);
      });

      test('maxBy returns null for empty list', () {
        expect(<int>[].maxBy((x) => x), isNull);
      });
    });

    group('null safety', () {
      test('whereNotNull removes null values', () {
        final list = [1, null, 2, null, 3];
        final result = list.whereNotNull;
        expect(result, [1, 2, 3]);
      });
    });

    group('list manipulation', () {
      test('rotateLeft rotates elements left', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.rotateLeft(2), [3, 4, 5, 1, 2]);
      });

      test('rotateLeft with default parameter', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.rotateLeft(), [2, 3, 4, 5, 1]);
      });

      test('rotateRight rotates elements right', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.rotateRight(2), [4, 5, 1, 2, 3]);
      });

      test('rotateLeft handles empty list', () {
        expect(<int>[].rotateLeft(2), isEmpty);
      });

      test('interleave interleaves two lists', () {
        final list1 = [1, 2, 3];
        final list2 = [4, 5, 6];
        expect(list1.interleave(list2), [1, 4, 2, 5, 3, 6]);
      });

      test('interleave handles different lengths', () {
        final list1 = [1, 2];
        final list2 = [3, 4, 5, 6];
        expect(list1.interleave(list2), [1, 3, 2, 4, 5, 6]);
      });

      test('slice returns elements between indices', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.slice(1, 4), [2, 3, 4]);
      });

      test('slice handles negative start', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.slice(-1, 3), [1, 2, 3]);
      });

      test('slice handles end beyond length', () {
        final list = [1, 2, 3];
        expect(list.slice(1, 10), [2, 3]);
      });

      test('slice returns empty for invalid range', () {
        final list = [1, 2, 3];
        expect(list.slice(5, 10), isEmpty);
      });
    });

    group('searching', () {
      test('indexWhereOrNull finds matching index', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.indexWhereOrNull((x) => x == 3), 2);
      });

      test('indexWhereOrNull returns -1 when not found', () {
        final list = [1, 2, 3];
        expect(list.indexWhereOrNull((x) => x == 5), -1);
      });

      test('lastIndexWhereOrNull finds last matching index', () {
        final list = [1, 2, 3, 2, 1];
        expect(list.lastIndexWhereOrNull((x) => x == 2), 3);
      });

      test('all checks if all elements match', () {
        final list = [2, 4, 6, 8];
        expect(list.all((x) => x.isEven), true);
        expect(list.all((x) => x > 5), false);
      });

      test('none checks if no elements match', () {
        final list = [1, 3, 5, 7];
        expect(list.none((x) => x.isEven), true);
        expect(list.none((x) => x > 5), false);
      });

      test('count counts matching elements', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.count((x) => x.isEven), 2);
      });
    });

    group('conversion', () {
      test('toMapBy converts to map', () {
        final list = [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'}
        ];
        final result = list.toMapBy(
          keySelector: (x) => x['id'] as int,
          valueSelector: (x) => x['name'] as String,
        );
        expect(result, {1: 'Alice', 2: 'Bob'});
      });
    });

    group('random access', () {
      test('random returns an element from list', () {
        final list = [1, 2, 3, 4, 5];
        final result = list.random();
        expect(result, isNotNull);
        expect(list.contains(result), true);
      });

      test('random returns null for empty list', () {
        expect(<int>[].random(), isNull);
      });

      test('shuffled returns shuffled list', () {
        final list = [1, 2, 3, 4, 5];
        final result = list.shuffled();
        expect(result.length, list.length);
        expect(result.toSet(), list.toSet());
      });

      test('shuffled does not modify original list', () {
        final list = [1, 2, 3, 4, 5];
        final original = List.from(list);
        list.shuffled();
        expect(list, original);
      });
    });

    group('different list types', () {
      test('works with String lists', () {
        final list = ['apple', 'banana', 'cherry'];
        expect(list.firstOrNull, 'apple');
        expect(list.unique, list);
      });

      test('works with custom objects', () {
        final list = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25}
        ];
        final sorted = list.sortedBy((x) => x['age'] as int);
        expect(sorted.first['name'], 'Bob');
      });
    });
  });

  group('NumListExtensions', () {
    test('sum calculates total', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.sum, 15);
    });

    test('sum returns 0 for empty list', () {
      expect(<num>[].sum, 0);
    });

    test('average calculates mean', () {
      final list = [10, 20, 30];
      expect(list.average, 20);
    });

    test('average returns 0 for empty list', () {
      expect(<num>[].average, 0);
    });

    test('min finds minimum value', () {
      final list = [5, 2, 8, 1, 9];
      expect(list.min, 1);
    });

    test('min returns null for empty list', () {
      expect(<num>[].min, isNull);
    });

    test('max finds maximum value', () {
      final list = [5, 2, 8, 1, 9];
      expect(list.max, 9);
    });

    test('max returns null for empty list', () {
      expect(<num>[].max, isNull);
    });

    test('median calculates median for odd length', () {
      final list = [1, 3, 5];
      expect(list.median, 3);
    });

    test('median calculates median for even length', () {
      final list = [1, 2, 3, 4];
      expect(list.median, 2.5);
    });

    test('median returns null for empty list', () {
      expect(<num>[].median, isNull);
    });

    test('works with double values', () {
      final list = [1.5, 2.5, 3.5];
      expect(list.sum, 7.5);
      expect(list.average, 2.5);
    });

    test('works with mixed int and double', () {
      final list = <num>[1, 2.5, 3];
      expect(list.sum, 6.5);
    });
  });
}
