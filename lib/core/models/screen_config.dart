import '../enums/screen_name.dart';

/// Screen configuration model defining available screens in the app
///
/// Maps to the `screen_configs` table in Supabase.
/// Manages which screens are available and active in the application.
class ScreenConfig {
  /// Unique screen config identifier
  final String id;

  /// Screen name enum
  final ScreenName screenName;

  /// Human-readable description of the screen
  final String description;

  /// Whether this screen is currently active (feature flag)
  final bool isActive;

  /// Timestamp when the config was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new ScreenConfig instance
  const ScreenConfig({
    required this.id,
    required this.screenName,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a ScreenConfig from a JSON map
  factory ScreenConfig.fromJson(Map<String, dynamic> json) {
    return ScreenConfig(
      id: json['id'] as String,
      screenName: ScreenName.fromJson(json['screen_name'] as String),
      description: json['description'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this ScreenConfig to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screen_name': screenName.toJson(),
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the screen config data
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

  /// Creates a copy of this ScreenConfig with the specified fields replaced
  ScreenConfig copyWith({
    String? id,
    ScreenName? screenName,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScreenConfig(
      id: id ?? this.id,
      screenName: screenName ?? this.screenName,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScreenConfig &&
        other.id == id &&
        other.screenName == screenName &&
        other.description == description &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        screenName.hashCode ^
        description.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ScreenConfig(id: $id, screenName: $screenName, isActive: $isActive)';
  }
}
