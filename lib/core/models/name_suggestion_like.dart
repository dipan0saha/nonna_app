/// Name suggestion like model representing a vote/like on a name suggestion
///
/// Maps to the `name_suggestion_likes` table in Supabase.
/// Users can like name suggestions. Each user can only like a suggestion once.
/// Supports toggle functionality and realtime updates.
class NameSuggestionLike {
  /// Unique like identifier
  final String id;

  /// Name suggestion this like is associated with
  final String nameSuggestionId;

  /// User who liked this suggestion
  final String userId;

  /// Timestamp when the like was created
  final DateTime createdAt;

  /// Creates a new NameSuggestionLike instance
  const NameSuggestionLike({
    required this.id,
    required this.nameSuggestionId,
    required this.userId,
    required this.createdAt,
  });

  /// Creates a NameSuggestionLike from a JSON map
  factory NameSuggestionLike.fromJson(Map<String, dynamic> json) {
    return NameSuggestionLike(
      id: json['id'] as String,
      nameSuggestionId: json['name_suggestion_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this NameSuggestionLike to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_suggestion_id': nameSuggestionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the like data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    // Basic validation - IDs should not be empty
    if (nameSuggestionId.trim().isEmpty) {
      return 'Name suggestion ID is required';
    }
    if (userId.trim().isEmpty) {
      return 'User ID is required';
    }
    return null;
  }

  /// Creates a copy of this NameSuggestionLike with the specified fields replaced
  NameSuggestionLike copyWith({
    String? id,
    String? nameSuggestionId,
    String? userId,
    DateTime? createdAt,
  }) {
    return NameSuggestionLike(
      id: id ?? this.id,
      nameSuggestionId: nameSuggestionId ?? this.nameSuggestionId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NameSuggestionLike &&
        other.id == id &&
        other.nameSuggestionId == nameSuggestionId &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nameSuggestionId.hashCode ^
        userId.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'NameSuggestionLike(id: $id, nameSuggestionId: $nameSuggestionId, userId: $userId)';
  }
}
