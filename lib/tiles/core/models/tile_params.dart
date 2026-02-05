/// Query parameters for tile data fetching
///
/// Immutable parameters used to fetch and filter tile data.
/// Supports filtering by baby profiles, date ranges, and pagination.
class TileParams {
  /// List of baby profile IDs to fetch data for
  final List<String>? babyProfileIds;

  /// Start date for filtering time-based data
  final DateTime? startDate;

  /// End date for filtering time-based data
  final DateTime? endDate;

  /// Maximum number of items to return
  final int? limit;

  /// Number of items to skip for pagination
  final int? offset;

  /// Additional custom parameters
  final Map<String, dynamic>? customParams;

  /// Creates a new TileParams instance
  const TileParams({
    this.babyProfileIds,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
    this.customParams,
  });

  /// Creates a TileParams from a JSON map
  factory TileParams.fromJson(Map<String, dynamic> json) {
    return TileParams(
      babyProfileIds: (json['baby_profile_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      customParams: json['custom_params'] as Map<String, dynamic>?,
    );
  }

  /// Converts this TileParams to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'baby_profile_ids': babyProfileIds,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'limit': limit,
      'offset': offset,
      'custom_params': customParams,
    };
  }

  /// Creates a copy of this TileParams with the specified fields replaced
  TileParams copyWith({
    List<String>? babyProfileIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    Map<String, dynamic>? customParams,
  }) {
    return TileParams(
      babyProfileIds: babyProfileIds ?? this.babyProfileIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      customParams: customParams ?? this.customParams,
    );
  }

  /// Checks if date range is valid
  bool get hasValidDateRange {
    if (startDate == null || endDate == null) return true;
    return !endDate!.isBefore(startDate!);
  }

  /// Validates the tile params data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      return 'End date must be after start date';
    }
    if (limit != null && limit! < 0) {
      return 'Limit must be 0 or greater';
    }
    if (offset != null && offset! < 0) {
      return 'Offset must be 0 or greater';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TileParams &&
        _listEquals(other.babyProfileIds, babyProfileIds) &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit &&
        other.offset == offset &&
        _mapEquals(other.customParams, customParams);
  }

  @override
  int get hashCode {
    return babyProfileIds.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        limit.hashCode ^
        offset.hashCode ^
        _mapHashCode(customParams);
  }

  /// Helper method to compute hashCode for a map in a consistent way
  int _mapHashCode<K, V>(Map<K, V>? map) {
    if (map == null) return 0;
    // Sort keys to ensure consistent hash regardless of entry order
    final sortedKeys = map.keys.toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));
    return Object.hashAll(sortedKeys.map((key) => Object.hash(key, map[key])));
  }

  @override
  String toString() {
    return 'TileParams(babyProfileIds: $babyProfileIds, startDate: $startDate, endDate: $endDate, limit: $limit, offset: $offset)';
  }

  /// Helper method to check list equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper method to compare two maps for equality
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
