import '../../constants/supabase_tables.dart';

/// Tile endpoints for tile configuration and data queries
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Tile config queries
/// - Screen config queries
/// - Tile data endpoints
///
/// Dependencies: SupabaseTables
class TileEndpoints {
  // Prevent instantiation
  TileEndpoints._();

  // ============================================================
  // Tile Configuration
  // ============================================================

  /// Get all tile configs for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  static String getTileConfigs(String babyProfileId) {
    return '${SupabaseTables.tileConfigs}?baby_profile_id=eq.$babyProfileId&select=*';
  }

  /// Get a specific tile config
  ///
  /// [tileConfigId] Tile config ID
  static String getTileConfig(String tileConfigId) {
    return '${SupabaseTables.tileConfigs}?id=eq.$tileConfigId&select=*';
  }

  /// Create a new tile config
  static String createTileConfig() {
    return SupabaseTables.tileConfigs;
  }

  /// Update a tile config
  ///
  /// [tileConfigId] Tile config ID
  static String updateTileConfig(String tileConfigId) {
    return '${SupabaseTables.tileConfigs}?id=eq.$tileConfigId';
  }

  /// Delete a tile config
  ///
  /// [tileConfigId] Tile config ID
  static String deleteTileConfig(String tileConfigId) {
    return '${SupabaseTables.tileConfigs}?id=eq.$tileConfigId';
  }

  // ============================================================
  // Screen Configuration
  // ============================================================

  /// Get all screen configs for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  static String getScreenConfigs(String babyProfileId) {
    return '${SupabaseTables.screenConfigs}?baby_profile_id=eq.$babyProfileId&select=*';
  }

  /// Get screen config for a specific screen
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name
  static String getScreenConfig(String babyProfileId, String screenName) {
    return '${SupabaseTables.screenConfigs}?baby_profile_id=eq.$babyProfileId&screen_name=eq.$screenName&select=*';
  }

  /// Create a new screen config
  static String createScreenConfig() {
    return SupabaseTables.screenConfigs;
  }

  /// Update a screen config
  ///
  /// [screenConfigId] Screen config ID
  static String updateScreenConfig(String screenConfigId) {
    return '${SupabaseTables.screenConfigs}?id=eq.$screenConfigId';
  }

  // ============================================================
  // Tile Data Queries
  // ============================================================

  /// Get tiles by screen name
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name
  static String getTilesByScreen(String babyProfileId, String screenName) {
    return '${SupabaseTables.tileConfigs}?baby_profile_id=eq.$babyProfileId&screen_name=eq.$screenName&select=*&order=position.asc';
  }

  /// Get visible tiles for a screen
  ///
  /// [babyProfileId] Baby profile ID
  /// [screenName] Screen name
  static String getVisibleTiles(String babyProfileId, String screenName) {
    return '${SupabaseTables.tileConfigs}?baby_profile_id=eq.$babyProfileId&screen_name=eq.$screenName&is_visible=eq.true&select=*&order=position.asc';
  }

  /// Get tiles by type
  ///
  /// [babyProfileId] Baby profile ID
  /// [tileType] Tile type
  static String getTilesByType(String babyProfileId, String tileType) {
    return '${SupabaseTables.tileConfigs}?baby_profile_id=eq.$babyProfileId&tile_type=eq.$tileType&select=*';
  }

  /// Reorder tiles
  ///
  /// Used with bulk update operations
  static String reorderTiles() {
    return SupabaseTables.tileConfigs;
  }

  // ============================================================
  // Tile Visibility
  // ============================================================

  /// Toggle tile visibility
  ///
  /// [tileConfigId] Tile config ID
  static String toggleTileVisibility(String tileConfigId) {
    return '${SupabaseTables.tileConfigs}?id=eq.$tileConfigId';
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Build query with filters
  ///
  /// [baseQuery] Base query string
  /// [filters] Map of filter key-value pairs
  static String buildQuery(String baseQuery, Map<String, String> filters) {
    if (filters.isEmpty) return baseQuery;

    final filterString =
        filters.entries.map((e) => '${e.key}=eq.${e.value}').join('&');

    final separator = baseQuery.contains('?') ? '&' : '?';
    return '$baseQuery$separator$filterString';
  }

  /// Build select query
  ///
  /// [table] Table name
  /// [columns] List of columns to select
  /// [filters] Optional filters
  static String buildSelectQuery(
    String table,
    List<String> columns, {
    Map<String, String>? filters,
  }) {
    final selectString = columns.isEmpty ? '*' : columns.join(',');
    var query = '$table?select=$selectString';

    if (filters != null && filters.isNotEmpty) {
      final filterString =
          filters.entries.map((e) => '${e.key}=eq.${e.value}').join('&');
      query = '$query&$filterString';
    }

    return query;
  }
}
