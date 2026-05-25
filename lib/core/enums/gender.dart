import 'package:flutter/material.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

/// Gender enumeration
///
/// **Functional Requirements**: Section 3.3.9 - Enums & Type Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Defines gender options for baby profiles and predictions in the Nonna app.
///
/// Gender options:
/// - male: Male
/// - female: Female
/// - unknown: Unknown or not yet determined
///
/// Used for baby profile information and prediction/voting features.
/// Includes string conversion, display names, and icon mapping.
///
/// Dependencies: None
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
        return 'Neutral';
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

/// Localized extension to resolve gender display names from BuildContext.
extension GenderL10n on Gender {
  String localizedDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Gender.male:
        return l10n.gender_male;
      case Gender.female:
        return l10n.gender_female;
      case Gender.unknown:
        return l10n.gender_neutral;
    }
  }
}
