import '../enums/gender.dart';

/// Baby profile model representing a baby in the Nonna app
///
/// Maps to the `baby_profiles` table in Supabase.
/// Owners can create baby profiles and followers can be invited to follow them.
class BabyProfile {
  /// Unique baby profile identifier
  final String id;

  /// Baby's name
  final String name;

  /// Source for the default last name ('mother' or 'father')
  final String? defaultLastNameSource;

  /// URL to the baby's profile photo
  final String? profilePhotoUrl;

  /// Expected birth date
  final DateTime? expectedBirthDate;

  /// Actual birth date (null if not yet born)
  final DateTime? actualBirthDate;

  /// Baby's gender
  final Gender gender;

  /// Timestamp when the profile was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the profile was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// Creates a new BabyProfile instance
  const BabyProfile({
    required this.id,
    required this.name,
    this.defaultLastNameSource,
    this.profilePhotoUrl,
    this.expectedBirthDate,
    this.actualBirthDate,
    this.gender = Gender.unknown,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Creates a BabyProfile from a JSON map
  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultLastNameSource: json['default_last_name_source'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      expectedBirthDate: json['expected_birth_date'] != null
          ? DateTime.parse(json['expected_birth_date'] as String)
          : null,
      actualBirthDate: json['actual_birth_date'] != null
          ? DateTime.parse(json['actual_birth_date'] as String)
          : null,
      gender: json['gender'] != null
          ? Gender.fromJson(json['gender'] as String)
          : Gender.unknown,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this BabyProfile to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_last_name_source': defaultLastNameSource,
      'profile_photo_url': profilePhotoUrl,
      'expected_birth_date': expectedBirthDate?.toIso8601String(),
      'actual_birth_date': actualBirthDate?.toIso8601String(),
      'gender': gender.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Validates the baby profile data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Baby name is required';
    }
    if (name.length > 100) {
      return 'Baby name must be 100 characters or less';
    }
    if (actualBirthDate != null &&
        expectedBirthDate != null &&
        actualBirthDate!.isBefore(expectedBirthDate!.subtract(const Duration(days: 90)))) {
      return 'Actual birth date cannot be more than 90 days before expected date';
    }
    if (actualBirthDate != null && actualBirthDate!.isAfter(DateTime.now())) {
      return 'Actual birth date cannot be in the future';
    }
    return null;
  }

  /// Checks if the baby has been born
  bool get isBorn => actualBirthDate != null;

  /// Checks if the profile is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Creates a copy of this BabyProfile with the specified fields replaced
  BabyProfile copyWith({
    String? id,
    String? name,
    String? defaultLastNameSource,
    String? profilePhotoUrl,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    Gender? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return BabyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultLastNameSource: defaultLastNameSource ?? this.defaultLastNameSource,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
      actualBirthDate: actualBirthDate ?? this.actualBirthDate,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BabyProfile &&
        other.id == id &&
        other.name == name &&
        other.defaultLastNameSource == defaultLastNameSource &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.expectedBirthDate == expectedBirthDate &&
        other.actualBirthDate == actualBirthDate &&
        other.gender == gender &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        defaultLastNameSource.hashCode ^
        profilePhotoUrl.hashCode ^
        expectedBirthDate.hashCode ^
        actualBirthDate.hashCode ^
        gender.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'BabyProfile(id: $id, name: $name, gender: $gender, isBorn: $isBorn)';
  }
}
