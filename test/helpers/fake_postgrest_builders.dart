import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake Postgrest Builder for testing
/// 
/// This builder implements the PostgrestFilterBuilder interface
/// to allow for proper type checking in tests
class FakePostgrestBuilder extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  bool _isMaybeSingle = false;
  bool _isSingle = false;

  FakePostgrestBuilder(this._data) : super(Uri.parse('http://localhost'));

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

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
  PostgrestTransformBuilder<String> csv() => this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>> geojson() => 
      this as ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false}) => 
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> select([String columns = '*']) => 
      this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) async {
    // Note: This is a simplified implementation for testing.
    // In real usage, single() and maybeSingle() change the generic type,
    // but for our mock purposes, we cast appropriately.
    if (_isMaybeSingle) {
      // Return null if empty, otherwise return the data
      final result = _data.isEmpty ? [] : _data;
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
class FakePostgrestUpdateBuilder extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final Map<String, dynamic>? _data;

  FakePostgrestUpdateBuilder([this._data]) : super(Uri.parse('http://localhost'));

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() => this as PostgrestTransformBuilder<Map<String, dynamic>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() => this as PostgrestTransformBuilder<Map<String, dynamic>?>;

  @override
  PostgrestTransformBuilder<String> csv() => this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>> geojson() => 
      this as ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false}) => 
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> select([String columns = '*']) =>
      this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) async {
    return onValue(_data != null ? [_data!] : []);
  }
}

/// Fake Postgrest Delete Builder for testing
class FakePostgrestDeleteBuilder extends PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  FakePostgrestDeleteBuilder() : super(Uri.parse('http://localhost'));

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() => this as PostgrestTransformBuilder<Map<String, dynamic>>;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() => this as PostgrestTransformBuilder<Map<String, dynamic>?>;

  @override
  PostgrestTransformBuilder<String> csv() => this as PostgrestTransformBuilder<String>;

  @override
  ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>> geojson() => 
      this as ResponsePostgrestBuilder<Map<String, dynamic>, Map<String, dynamic>, Map<String, dynamic>>;

  @override
  PostgrestBuilder<String, String, String> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false}) => 
      this as PostgrestBuilder<String, String, String>;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> select([String columns = '*']) =>
      this as PostgrestTransformBuilder<List<Map<String, dynamic>>>;

  @override
  Future<U> then<U>(FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) async {
    return onValue([]);
  }
}

/// Fake Postgrest Insert Builder for testing
class FakePostgrestInsertBuilder {
  final List<Map<String, dynamic>> _data;

  FakePostgrestInsertBuilder(this._data);

  FakePostgrestInsertBuilder select([String columns = '*']) => this;

  Future<List<Map<String, dynamic>>> then<R>(FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) async {
    return _data;
  }
}
