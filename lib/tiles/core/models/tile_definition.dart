import '../../enums/tile_type.dart';

/// Tile definition model representing available tile types
///
/// Maps to the `tile_definitions` table in Supabase.
/// Catalog of all available tile types that can be instantiated.
class TileDefinition {
  /// Unique tile definition identifier
  final String id;

  /// Tile type enum matching TileFactory cases
  final TileType tileType;

  /// Human-readable description of the tile
  final String description;

  /// JSON schema for params validation
  final Map<String, dynamic>? schemaParams;

  /// Whether this tile type is currently active
  final bool isActive;

  /// Timestamp when the definition was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new TileDefinition instance
  const TileDefinition({
    required this.id,
    required this.tileType,
    required this.description,
    this.schemaParams,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a TileDefinition from a JSON map
  factory TileDefinition.fromJson(Map<String, dynamic> json) {
    return TileDefinition(
      id: json['id'] as String,
      tileType: TileType.fromJson(json['tile_type'] as String),
      description: json['description'] as String,
      schemaParams: json['schema_params'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this TileDefinition to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tile_type': tileType.toJson(),
      'description': description,
      'schema_params': schemaParams,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the tile definition data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (description.trim().isEmpty) {
      return 'Description is required';
    }
    if (description.length > 255) {
      return 'Description must be 255 characters or less';
    }
    return null;
  }

  /// Creates a copy of this TileDefinition with the specified fields replaced
  TileDefinition copyWith({
    String? id,
    TileType? tileType,
    String? description,
    Map<String, dynamic>? schemaParams,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TileDefinition(
      id: id ?? this.id,
      tileType: tileType ?? this.tileType,
      description: description ?? this.description,
      schemaParams: schemaParams ?? this.schemaParams,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TileDefinition &&
        other.id == id &&
        other.tileType == tileType &&
        other.description == description &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tileType.hashCode ^
        description.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TileDefinition(id: $id, tileType: $tileType, isActive: $isActive)';
  }
}
