import '../enums/user_role.dart';

/// Tile configuration model for dynamic tile rendering
///
/// Maps to the `tile_configs` table in Supabase.
/// Defines which tiles appear on which screens for different roles.
class TileConfig {
  /// Unique tile config identifier
  final String id;

  /// Associated screen ID
  final String screenId;

  /// Associated tile definition ID
  final String tileDefinitionId;

  /// Role this configuration applies to (owner or follower)
  final UserRole role;

  /// Display order on the screen (lower numbers appear first)
  final int displayOrder;

  /// Whether this tile is currently visible
  final bool isVisible;

  /// JSON parameters for tile customization
  final Map<String, dynamic>? params;

  /// Timestamp when the config was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new TileConfig instance
  const TileConfig({
    required this.id,
    required this.screenId,
    required this.tileDefinitionId,
    required this.role,
    required this.displayOrder,
    this.isVisible = true,
    this.params,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a TileConfig from a JSON map
  factory TileConfig.fromJson(Map<String, dynamic> json) {
    return TileConfig(
      id: json['id'] as String,
      screenId: json['screen_id'] as String,
      tileDefinitionId: json['tile_definition_id'] as String,
      role: UserRole.fromJson(json['role'] as String),
      displayOrder: json['display_order'] as int,
      isVisible: json['is_visible'] as bool? ?? true,
      params: json['params'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this TileConfig to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screen_id': screenId,
      'tile_definition_id': tileDefinitionId,
      'role': role.toJson(),
      'display_order': displayOrder,
      'is_visible': isVisible,
      'params': params,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the tile config data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (displayOrder < 0) {
      return 'Display order must be 0 or greater';
    }
    return null;
  }

  /// Creates a copy of this TileConfig with the specified fields replaced
  TileConfig copyWith({
    String? id,
    String? screenId,
    String? tileDefinitionId,
    UserRole? role,
    int? displayOrder,
    bool? isVisible,
    Map<String, dynamic>? params,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TileConfig(
      id: id ?? this.id,
      screenId: screenId ?? this.screenId,
      tileDefinitionId: tileDefinitionId ?? this.tileDefinitionId,
      role: role ?? this.role,
      displayOrder: displayOrder ?? this.displayOrder,
      isVisible: isVisible ?? this.isVisible,
      params: params ?? this.params,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TileConfig &&
        other.id == id &&
        other.screenId == screenId &&
        other.tileDefinitionId == tileDefinitionId &&
        other.role == role &&
        other.displayOrder == displayOrder &&
        other.isVisible == isVisible &&
        _mapEquals(other.params, params) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        screenId.hashCode ^
        tileDefinitionId.hashCode ^
        role.hashCode ^
        displayOrder.hashCode ^
        isVisible.hashCode ^
        (params != null ? Object.hashAll(params!.entries) : 0) ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TileConfig(id: $id, tileDefinitionId: $tileDefinitionId, role: $role, displayOrder: $displayOrder, isVisible: $isVisible)';
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
