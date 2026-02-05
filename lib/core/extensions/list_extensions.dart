/// Extension methods for List
///
/// **Functional Requirements**: Section 3.3.6 - Extensions
/// Reference: docs/Core_development_component_identification.md
///
/// Provides utility methods for list manipulation and querying including:
/// - Safe access (getOrNull, getOrDefault, firstOrNull, lastOrNull)
/// - Filtering (filterMap, skipFirst, skipLast, chunk, unique, uniqueBy)
/// - Grouping (groupBy, partition)
/// - Sorting (sortedBy, sortedByDescending)
/// - Aggregation (sumBy, averageBy, minBy, maxBy)
/// - List manipulation (rotateLeft, rotateRight, interleave, slice)
/// - Searching (indexWhereOrNull, all, none, count)
/// - Conversion (toMapBy)
///
/// Dependencies: None
extension ListExtensions<T> on List<T> {
  // ============================================================
  // Safe Access
  // ============================================================

  /// Get element at index, or null if index is out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get element at index, or default value if index is out of bounds
  T getOrDefault(int index, T defaultValue) {
    return getOrNull(index) ?? defaultValue;
  }

  /// Get first element or null if list is empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if list is empty
  T? get lastOrNull => isEmpty ? null : last;

  // ============================================================
  // Filtering
  // ============================================================

  /// Filter and map in one operation
  List<R> filterMap<R>(R? Function(T) mapper) {
    final result = <R>[];
    for (final item in this) {
      final mapped = mapper(item);
      if (mapped != null) {
        result.add(mapped);
      }
    }
    return result;
  }

  /// Get all elements except the first n elements
  List<T> skipFirst([int count = 1]) {
    if (count >= length) return [];
    return sublist(count);
  }

  /// Get all elements except the last n elements
  List<T> skipLast([int count = 1]) {
    if (count >= length) return [];
    return sublist(0, length - count);
  }

  /// Split list into chunks of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  /// Get unique elements (removes duplicates)
  List<T> get unique {
    return toSet().toList();
  }

  /// Get unique elements by a key selector
  List<T> uniqueBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((item) => seen.add(keySelector(item))).toList();
  }

  // ============================================================
  // Grouping
  // ============================================================

  /// Group elements by a key selector
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final groups = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  /// Partition list into two lists based on a predicate
  (List<T>, List<T>) partition(bool Function(T) predicate) {
    final truthy = <T>[];
    final falsy = <T>[];
    for (final item in this) {
      if (predicate(item)) {
        truthy.add(item);
      } else {
        falsy.add(item);
      }
    }
    return (truthy, falsy);
  }

  // ============================================================
  // Sorting
  // ============================================================

  /// Sort by a comparable key
  List<T> sortedBy<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(a).compareTo(keySelector(b)));
    return copy;
  }

  /// Sort by a comparable key in descending order
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(b).compareTo(keySelector(a)));
    return copy;
  }

  // ============================================================
  // Aggregation
  // ============================================================

  /// Sum of elements using a selector (for numeric types)
  num sumBy(num Function(T) selector) {
    return fold<num>(0, (sum, item) => sum + selector(item));
  }

  /// Average of elements using a selector
  double averageBy(num Function(T) selector) {
    if (isEmpty) return 0;
    return sumBy(selector) / length;
  }

  /// Find minimum element by selector
  T? minBy<K extends Comparable>(K Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) <= 0 ? a : b);
  }

  /// Find maximum element by selector
  T? maxBy<K extends Comparable>(K Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) >= 0 ? a : b);
  }

  // ============================================================
  // Null Safety
  // ============================================================

  /// Remove null values from list of nullable items
  List<T> get whereNotNull {
    return where((item) => item != null).cast<T>().toList();
  }

  // ============================================================
  // List Manipulation
  // ============================================================

  /// Rotate list elements to the left
  List<T> rotateLeft([int count = 1]) {
    if (isEmpty) return this;
    final n = count % length;
    return [...skip(n), ...take(n)];
  }

  /// Rotate list elements to the right
  List<T> rotateRight([int count = 1]) {
    return rotateLeft(length - (count % length));
  }

  /// Interleave with another list
  List<T> interleave(List<T> other) {
    final result = <T>[];
    final maxLength = length > other.length ? length : other.length;
    for (var i = 0; i < maxLength; i++) {
      if (i < length) result.add(this[i]);
      if (i < other.length) result.add(other[i]);
    }
    return result;
  }

  /// Get all elements between two indices (inclusive)
  List<T> slice(int start, int end) {
    final normalizedStart = start < 0 ? 0 : start;
    final normalizedEnd = end > length ? length : end;
    if (normalizedStart >= normalizedEnd) return [];
    return sublist(normalizedStart, normalizedEnd);
  }

  // ============================================================
  // Searching
  // ============================================================

  /// Find index of first element matching predicate
  int indexWhereOrNull(bool Function(T) predicate) {
    final index = indexWhere(predicate);
    return index == -1 ? -1 : index;
  }

  /// Find last index of element matching predicate
  int lastIndexWhereOrNull(bool Function(T) predicate) {
    final index = lastIndexWhere(predicate);
    return index == -1 ? -1 : index;
  }

  /// Check if all elements match predicate
  bool all(bool Function(T) predicate) {
    return every(predicate);
  }

  /// Check if no elements match predicate
  bool none(bool Function(T) predicate) {
    return !any(predicate);
  }

  /// Count elements matching predicate
  int count(bool Function(T) predicate) {
    return where(predicate).length;
  }

  // ============================================================
  // Conversion
  // ============================================================

  /// Convert to a map using key and value selectors
  Map<K, V> toMapBy<K, V>({
    required K Function(T) keySelector,
    required V Function(T) valueSelector,
  }) {
    return {for (final item in this) keySelector(item): valueSelector(item)};
  }

  // ============================================================
  // Random Access
  // ============================================================

  /// Get a random element from the list
  T? random() {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Shuffle the list and return a new list
  List<T> shuffled() {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }
}

/// Extension for list of numbers
extension NumListExtensions on List<num> {
  /// Sum of all elements
  num get sum => fold(0, (sum, item) => sum + item);

  /// Average of all elements
  double get average => isEmpty ? 0 : sum / length;

  /// Minimum value
  num? get min => isEmpty ? null : reduce((a, b) => a < b ? a : b);

  /// Maximum value
  num? get max => isEmpty ? null : reduce((a, b) => a > b ? a : b);

  /// Median value
  num? get median {
    if (isEmpty) return null;
    final sorted = List<num>.from(this)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }
}
