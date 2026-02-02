/// Vote type enumeration
///
/// **Functional Requirements**: Section 3.3.9 - Enums & Type Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Defines the type of prediction vote in the Nonna app's gamification features.
///
/// Vote types:
/// - gender: Vote for baby's gender prediction
/// - birthdate: Vote for baby's birthdate prediction
///
/// Used in the Fun section for community predictions and engagement.
/// Includes string conversion and display names.
///
/// Dependencies: None
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
