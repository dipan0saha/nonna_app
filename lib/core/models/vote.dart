import '../enums/vote_type.dart';

/// Vote model representing a prediction vote in the Nonna app
///
/// Maps to the `votes` table in Supabase.
/// Votes are predictions about baby's gender or birthdate.
/// Can only be updated before the baby is born.
class Vote {
  /// Unique vote identifier
  final String id;

  /// Baby profile this vote is associated with
  final String babyProfileId;

  /// User who cast this vote
  final String userId;

  /// Type of vote (gender or birthdate)
  final VoteType voteType;

  /// Text value for the vote (used for gender predictions)
  final String? valueText;

  /// Date value for the vote (used for birthdate predictions)
  final DateTime? valueDate;

  /// Whether the vote was cast anonymously
  final bool isAnonymous;

  /// Timestamp when the vote was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new Vote instance
  const Vote({
    required this.id,
    required this.babyProfileId,
    required this.userId,
    required this.voteType,
    this.valueText,
    this.valueDate,
    this.isAnonymous = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a Vote from a JSON map
  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      userId: json['user_id'] as String,
      voteType: VoteType.fromJson(json['vote_type'] as String),
      valueText: json['value_text'] as String?,
      valueDate: json['value_date'] != null
          ? DateTime.parse(json['value_date'] as String)
          : null,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this Vote to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'user_id': userId,
      'vote_type': voteType.toJson(),
      'value_text': valueText,
      'value_date': valueDate?.toIso8601String(),
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the vote data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    // Ensure that the correct value type is provided based on vote type
    if (voteType == VoteType.gender) {
      if (valueText == null || valueText!.trim().isEmpty) {
        return 'Gender vote must have a text value';
      }
    } else if (voteType == VoteType.birthdate) {
      if (valueDate == null) {
        return 'Birthdate vote must have a date value';
      }
    }
    return null;
  }

  /// Checks if the vote has a text value
  bool get hasTextValue => valueText != null && valueText!.isNotEmpty;

  /// Checks if the vote has a date value
  bool get hasDateValue => valueDate != null;

  /// Creates a copy of this Vote with the specified fields replaced
  Vote copyWith({
    String? id,
    String? babyProfileId,
    String? userId,
    VoteType? voteType,
    String? valueText,
    DateTime? valueDate,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vote(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      userId: userId ?? this.userId,
      voteType: voteType ?? this.voteType,
      valueText: valueText ?? this.valueText,
      valueDate: valueDate ?? this.valueDate,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Vote &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.userId == userId &&
        other.voteType == voteType &&
        other.valueText == valueText &&
        other.valueDate == valueDate &&
        other.isAnonymous == isAnonymous &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        userId.hashCode ^
        voteType.hashCode ^
        valueText.hashCode ^
        valueDate.hashCode ^
        isAnonymous.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Vote(id: $id, babyProfileId: $babyProfileId, userId: $userId, voteType: $voteType, isAnonymous: $isAnonymous)';
  }
}
