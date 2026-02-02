import 'package:flutter/material.dart';

/// RSVP status enumeration
///
/// Defines the possible responses to an event invitation.
enum RsvpStatus {
  /// User confirmed attendance
  yes,

  /// User declined attendance
  no,

  /// User is uncertain about attendance
  maybe;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create an RsvpStatus from a string
  static RsvpStatus fromJson(String value) {
    return RsvpStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => RsvpStatus.maybe,
    );
  }

  /// Get a display-friendly name for the RSVP status
  String get displayName {
    switch (this) {
      case RsvpStatus.yes:
        return 'Yes';
      case RsvpStatus.no:
        return 'No';
      case RsvpStatus.maybe:
        return 'Maybe';
    }
  }

  /// Get an icon for the RSVP status
  IconData get icon {
    switch (this) {
      case RsvpStatus.yes:
        return Icons.check_circle;
      case RsvpStatus.no:
        return Icons.cancel;
      case RsvpStatus.maybe:
        return Icons.help;
    }
  }

  /// Get a color for the RSVP status
  Color get color {
    switch (this) {
      case RsvpStatus.yes:
        return Colors.green;
      case RsvpStatus.no:
        return Colors.red;
      case RsvpStatus.maybe:
        return Colors.orange;
    }
  }
}
