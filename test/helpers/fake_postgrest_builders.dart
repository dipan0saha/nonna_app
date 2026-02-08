import 'package:supabase_flutter/supabase_flutter.dart';

/// Fake Postgrest Builder for testing
/// 
/// This builder implements the PostgrestFilterBuilder interface
/// to allow for proper type checking in tests
class FakePostgrestBuilder extends PostgrestFilterBuilder<dynamic> {
  final List<Map<String, dynamic>> _data;
  bool _isMaybeSingle = false;
  bool _isSingle = false;

  FakePostgrestBuilder(this._data) : super(null, null, null, null, {});

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
  PostgrestFilterBuilder<dynamic> is_(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, List<dynamic> values) => this;

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
  PostgrestFilterBuilder<dynamic> overlaps(String column, List<String> values) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> limit(int count, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> range(int from, int to, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> single() {
    _isSingle = true;
    return this;
  }

  @override
  PostgrestFilterBuilder<dynamic> maybeSingle() {
    _isMaybeSingle = true;
    return this;
  }

  @override
  PostgrestFilterBuilder<dynamic> csv() => this;

  @override
  PostgrestFilterBuilder<dynamic> geojson() => this;

  @override
  PostgrestFilterBuilder<dynamic> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false, String? format}) => this;

  @override
  PostgrestTransformBuilder<dynamic> select([String columns = '*']) => 
      PostgrestTransformBuilder(null, null, null, null, {});

  @override
  Future<dynamic> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) async {
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

  FakePostgrestUpdateBuilder([this._data]) : super(null, null, null, null, {});

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
  PostgrestFilterBuilder<dynamic> is_(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, List<dynamic> values) => this;

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
  PostgrestFilterBuilder<dynamic> overlaps(String column, List<String> values) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> limit(int count, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> range(int from, int to, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> single() => this;

  @override
  PostgrestFilterBuilder<dynamic> maybeSingle() => this;

  @override
  PostgrestFilterBuilder<dynamic> csv() => this;

  @override
  PostgrestFilterBuilder<dynamic> geojson() => this;

  @override
  PostgrestFilterBuilder<dynamic> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false, String? format}) => this;

  @override
  PostgrestTransformBuilder<dynamic> select([String columns = '*']) =>
      PostgrestTransformBuilder(null, null, null, null, {});

  @override
  Future<dynamic> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) async {
    return _data;
  }
}

/// Fake Postgrest Delete Builder for testing
class FakePostgrestDeleteBuilder extends PostgrestFilterBuilder<dynamic> {
  FakePostgrestDeleteBuilder() : super(null, null, null, null, {});

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
  PostgrestFilterBuilder<dynamic> is_(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> contains(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> containedBy(String column, List<dynamic> values) => this;

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
  PostgrestFilterBuilder<dynamic> overlaps(String column, List<String> values) => this;

  @override
  PostgrestFilterBuilder<dynamic> textSearch(String column, String query, {TextSearchType? type, String? config}) => this;

  @override
  PostgrestFilterBuilder<dynamic> match(Map<String, dynamic> query) => this;

  @override
  PostgrestFilterBuilder<dynamic> not(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> or(String filters, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> filter(String column, String operator, dynamic value) => this;

  @override
  PostgrestFilterBuilder<dynamic> order(String column, {bool ascending = false, bool nullsFirst = false, String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> limit(int count, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> range(int from, int to, {String? foreignTable}) => this;

  @override
  PostgrestFilterBuilder<dynamic> single() => this;

  @override
  PostgrestFilterBuilder<dynamic> maybeSingle() => this;

  @override
  PostgrestFilterBuilder<dynamic> csv() => this;

  @override
  PostgrestFilterBuilder<dynamic> geojson() => this;

  @override
  PostgrestFilterBuilder<dynamic> explain({bool analyze = false, bool verbose = false, bool settings = false, bool buffers = false, bool wal = false, String? format}) => this;

  @override
  PostgrestTransformBuilder<dynamic> select([String columns = '*']) =>
      PostgrestTransformBuilder(null, null, null, null, {});

  @override
  Future<dynamic> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) async {
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
