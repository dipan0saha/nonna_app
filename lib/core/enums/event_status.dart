import 'package:flutter/material.dart';

/// Event status enumeration
///
/// Defines the lifecycle states of calendar events.
/// Each status has associated color for visual differentiation.
enum EventStatus {
  /// Event is upcoming/scheduled
  scheduled,

  /// Event is currently happening
  ongoing,

  /// Event has been completed
  completed,

  /// Event has been cancelled
  cancelled,

  /// Event is in draft state
  draft;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create an EventStatus from a string
  static EventStatus fromJson(String value) {
    return EventStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => EventStatus.scheduled,
    );
  }

  /// Get a color for the event status
  Color get color {
    switch (this) {
      case EventStatus.scheduled:
        return Colors.blue;
      case EventStatus.ongoing:
        return Colors.green;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.draft:
        return Colors.orange;
    }
  }

  /// Get a display-friendly name for the event status
  String get displayName {
    switch (this) {
      case EventStatus.scheduled:
        return 'Scheduled';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.draft:
        return 'Draft';
    }
  }

  /// Check if the event is active (scheduled or ongoing)
  bool get isActive =>
      this == EventStatus.scheduled || this == EventStatus.ongoing;

  /// Check if the event is finished (completed or cancelled)
  bool get isFinished =>
      this == EventStatus.completed || this == EventStatus.cancelled;
}
