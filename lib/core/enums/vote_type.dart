/// Vote type enumeration
///
/// Defines the type of prediction vote in the Nonna app.
enum VoteType {
  /// Vote for baby's gender
  gender,

  /// Vote for baby's birthdate
  birthdate;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a VoteType from a string
  static VoteType fromJson(String value) {
    return VoteType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => VoteType.gender,
    );
  }

  /// Get a display-friendly name for the vote type
  String get displayName {
    switch (this) {
      case VoteType.gender:
        return 'Gender';
      case VoteType.birthdate:
        return 'Birthdate';
    }
  }
}
