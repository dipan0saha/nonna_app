import 'package:flutter/material.dart';

/// Gender enumeration
///
/// Defines gender options for baby profiles and predictions.
enum Gender {
  /// Male
  male,

  /// Female
  female,

  /// Unknown or not yet determined
  unknown;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a Gender from a string
  static Gender fromJson(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.name == value.toLowerCase(),
      orElse: () => Gender.unknown,
    );
  }

  /// Get a display-friendly name for the gender
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.unknown:
        return 'Unknown';
    }
  }

  /// Get an icon for the gender
  IconData get icon {
    switch (this) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      case Gender.unknown:
        return Icons.help_outline;
    }
  }

  /// Get a color for the gender (traditional colors)
  Color get color {
    switch (this) {
      case Gender.male:
        return Colors.blue;
      case Gender.female:
        return Colors.pink;
      case Gender.unknown:
        return Colors.grey;
    }
  }
}
