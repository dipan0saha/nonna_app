import '../enums/gender.dart';

/// Name suggestion model representing a baby name suggestion
///
/// Maps to the `name_suggestions` table in Supabase.
/// Users can suggest names for a baby profile.
/// Supports soft delete and realtime updates.
class NameSuggestion {
  /// Unique name suggestion identifier
  final String id;

  /// Baby profile this suggestion is associated with
  final String babyProfileId;

  /// User who made this suggestion
  final String userId;

  /// Gender this name is suggested for
  final Gender gender;

  /// The suggested name
  final String suggestedName;

  /// Timestamp when the suggestion was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the suggestion was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// Creates a new NameSuggestion instance
  const NameSuggestion({
    required this.id,
    required this.babyProfileId,
    required this.userId,
    required this.gender,
    required this.suggestedName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Creates a NameSuggestion from a JSON map
  factory NameSuggestion.fromJson(Map<String, dynamic> json) {
    return NameSuggestion(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      userId: json['user_id'] as String,
      gender: Gender.fromJson(json['gender'] as String),
      suggestedName: json['suggested_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this NameSuggestion to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'user_id': userId,
      'gender': gender.toJson(),
      'suggested_name': suggestedName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Validates the name suggestion data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (suggestedName.trim().isEmpty) {
      return 'Suggested name is required';
    }
    if (suggestedName.length > 100) {
      return 'Suggested name must be 100 characters or less';
    }
    // Basic name validation - should start with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(suggestedName.trim())) {
      return 'Suggested name must start with a letter';
    }
    return null;
  }

  /// Checks if the suggestion is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Creates a copy of this NameSuggestion with the specified fields replaced
  NameSuggestion copyWith({
    String? id,
    String? babyProfileId,
    String? userId,
    Gender? gender,
    String? suggestedName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return NameSuggestion(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      suggestedName: suggestedName ?? this.suggestedName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NameSuggestion &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.userId == userId &&
        other.gender == gender &&
        other.suggestedName == suggestedName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        userId.hashCode ^
        gender.hashCode ^
        suggestedName.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'NameSuggestion(id: $id, babyProfileId: $babyProfileId, suggestedName: $suggestedName, gender: $gender, isDeleted: $isDeleted)';
  }
}
