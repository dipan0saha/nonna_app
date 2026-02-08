import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake Postgrest Builder for testing
/// 
/// This builder implements the PostgrestFilterBuilder interface
/// to allow for proper type checking in tests
class FakePostgrestBuilder extends PostgrestFilterBuilder<dynamic> {
  final List<Map<String, dynamic>> _data;
  bool _isMaybeSingle = false;
  bool _isSingle = false;

  FakePostgrestBuilder(this._data) : super(PostgrestBuilder(url: Uri.parse('http://localhost')));

  @override
  PostgrestFilterBuilder<dynamic> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

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
  Future<dynamic> then<U>(FutureOr<U> Function(dynamic value) onValue, {Function? onError}) async {
    if (_isMaybeSingle) {
      return _data.isEmpty ? null : _data.first;
    } else if (_isSingle) {
      return _data.first;
    }
    return _data;
  }
}

/// Fake Postgrest Update Builder for testing
class FakePostgrestUpdateBuilder extends PostgrestFilterBuilder<dynamic> {
  final Map<String, dynamic>? _data;

  FakePostgrestUpdateBuilder([this._data]) : super(PostgrestBuilder(url: Uri.parse('http://localhost')));

  @override
  PostgrestFilterBuilder<dynamic> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

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
  Future<dynamic> then<U>(FutureOr<U> Function(dynamic value) onValue, {Function? onError}) async {
    return _data;
  }
}

/// Fake Postgrest Delete Builder for testing
class FakePostgrestDeleteBuilder extends PostgrestFilterBuilder<dynamic> {
  FakePostgrestDeleteBuilder() : super(PostgrestBuilder(url: Uri.parse('http://localhost')));

  @override
  PostgrestFilterBuilder<dynamic> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> like(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> ilike(String column, String pattern) => this;

  @override
  PostgrestFilterBuilder<dynamic> isFilter(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGt(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeGte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeLte(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> rangeAdjacent(String column, String range) => this;

  @override
  PostgrestFilterBuilder<dynamic> overlaps(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestTransformBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> limit(int count, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

  @override
  PostgrestTransformBuilder<dynamic> range(int from, int to, {String? referencedTable}) => this as PostgrestTransformBuilder<dynamic>;

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
  Future<dynamic> then<U>(FutureOr<U> Function(dynamic value) onValue, {Function? onError}) async {
    return null;
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
