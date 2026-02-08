import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper method to create a base PostgrestBuilder for testing purposes
PostgrestBuilder<List<Map<String, dynamic>>, List<Map<String, dynamic>>,
    List<Map<String, dynamic>>> _createBaseBuilder() {
  final client = SupabaseClient('http://localhost', 'fake-key');
  // Call select() to get a PostgrestFilterBuilder which extends PostgrestBuilder
  final selectBuilder = client.from('fake_table').select();
  return selectBuilder as PostgrestBuilder<List<Map<String, dynamic>>,
      List<Map<String, dynamic>>, List<Map<String, dynamic>>>;
}

/// Fake Postgrest Builder for testing
///
/// This builder implements the PostgrestFilterBuilder interface
/// to allow for proper type checking in tests.
///
/// ## Usage
///
/// ```dart
/// // Return data from a mock select
/// when(mockDatabase.select(any))
///   .thenReturn(FakePostgrestBuilder([{'id': '1', 'name': 'Test'}]));
///
/// // Simulate an error
/// when(mockDatabase.select(any))
///   .thenReturn(FakePostgrestBuilder.withError(Exception('Test error')));
///
/// // Simulate a delayed response
/// when(mockDatabase.select(any))
///   .thenReturn(FakePostgrestBuilder.withDelay(
///     [{'id': '1'}],
///     delay: Duration(seconds: 1),
///   ));
/// ```
class FakePostgrestBuilder
    extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  final Exception? _error;
  final Duration? _delay;
  bool _isMaybeSingle = false;
  bool _isSingle = false;

  FakePostgrestBuilder(this._data, {Exception? error, Duration? delay})
      : _error = error,
        _delay = delay,
        super(_createBaseBuilder());

  /// Create a builder that will throw an error
  factory FakePostgrestBuilder.withError(Exception error) {
    return FakePostgrestBuilder([], error: error);
  }

  /// Create a builder that will delay before returning data
  factory FakePostgrestBuilder.withDelay(
    List<Map<String, dynamic>> data, {
    required Duration delay,
  }) {
    return FakePostgrestBuilder(data, delay: delay);
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(
          String column, String query,
          {TextSearchType? type, String? config}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(
          Map<String, dynamic> query) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters,
          {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    _isSingle = true;
    return this as PostgrestTransformBuilder<Map<String, dynamic>>;
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    _isMaybeSingle = true;
    return this as PostgrestTransformBuilder<Map<String, dynamic>?>;
  }

  @override
  PostgrestTransformBuilder<String> csv() =>
      this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>,
          Map<String, dynamic>>
      geojson() => this as ResponsePostgrestBuilder<Map<String, dynamic>,
          Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain(
          {bool analyze = false,
          bool verbose = false,
          bool settings = false,
          bool buffers = false,
          bool wal = false}) =>
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
          [String columns = '*']) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(
      FutureOr<U> Function(List<Map<String, dynamic>> value) onValue,
      {Function? onError}) async {
    // Handle delay if specified
    if (_delay != null) {
      await Future.delayed(_delay);
    }

    // Handle error if specified
    if (_error != null) {
      if (onError != null) {
        return onError(_error, StackTrace.current);
      }
      throw _error;
    }

    // Note: This is a simplified implementation for testing.
    // In real usage, single() and maybeSingle() change the generic type,
    // but for our mock purposes, we cast appropriately.
    if (_isMaybeSingle) {
      // Return null if empty, otherwise return the data
      final List<Map<String, dynamic>> result = _data.isEmpty ? [] : _data;
      return onValue(result);
    } else if (_isSingle) {
      // Return the first item
      if (_data.isEmpty) {
        throw Exception('No data found for single()');
      }
      return onValue(_data);
    }
    return onValue(_data);
  }
}

/// Fake Postgrest Update Builder for testing
class FakePostgrestUpdateBuilder
    extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final Map<String, dynamic>? _data;

  FakePostgrestUpdateBuilder([this._data]) : super(_createBaseBuilder() as PostgrestBuilder<
      List<Map<String, dynamic>>,
      List<Map<String, dynamic>>,
      List<Map<String, dynamic>>>);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(
          String column, String query,
          {TextSearchType? type, String? config}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(
          Map<String, dynamic> query) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters,
          {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      this as PostgrestTransformBuilder<Map<String, dynamic>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      this as PostgrestTransformBuilder<Map<String, dynamic>?>;

  @override
  PostgrestTransformBuilder<String> csv() =>
      this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>,
          Map<String, dynamic>>
      geojson() => this as ResponsePostgrestBuilder<Map<String, dynamic>,
          Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain(
          {bool analyze = false,
          bool verbose = false,
          bool settings = false,
          bool buffers = false,
          bool wal = false}) =>
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
          [String columns = '*']) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(
      FutureOr<U> Function(List<Map<String, dynamic>> value) onValue,
      {Function? onError}) async {
    return onValue(_data != null ? [_data] : []);
  }
}

/// Fake Postgrest Delete Builder for testing
class FakePostgrestDeleteBuilder
    extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  FakePostgrestDeleteBuilder()
      : super(_createBaseBuilder() as PostgrestBuilder<
            List<Map<String, dynamic>>,
            List<Map<String, dynamic>>,
            List<Map<String, dynamic>>>);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(
          String column, String pattern) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(
          String column, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(
          String column, String range) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(
          String column, String query,
          {TextSearchType? type, String? config}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(
          Map<String, dynamic> query) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters,
          {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(
          String column, String operator, dynamic value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          bool nullsFirst = false,
          String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to,
          {String? referencedTable}) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      this as PostgrestTransformBuilder<Map<String, dynamic>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      this as PostgrestTransformBuilder<Map<String, dynamic>?>;

  @override
  PostgrestTransformBuilder<String> csv() =>
      this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>,
          Map<String, dynamic>>
      geojson() => this as ResponsePostgrestBuilder<Map<String, dynamic>,
          Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain(
          {bool analyze = false,
          bool verbose = false,
          bool settings = false,
          bool buffers = false,
          bool wal = false}) =>
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
          [String columns = '*']) =>
      this as PostgrestFilterBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(
      FutureOr<U> Function(List<Map<String, dynamic>> value) onValue,
      {Function? onError}) async {
    return onValue([]);
  }
}

/// Fake Postgrest Insert Builder for testing
class FakePostgrestInsertBuilder {
  final List<Map<String, dynamic>> _data;

  FakePostgrestInsertBuilder(this._data);

  FakePostgrestInsertBuilder select([String columns = '*']) => this;

  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>> value) onValue,
      {Function? onError}) async {
    return _data;
  }
}
