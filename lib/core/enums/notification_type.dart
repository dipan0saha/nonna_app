import 'package:flutter/material.dart';

/// Notification type enumeration
///
/// Defines different categories of notifications in the Nonna app.
/// Each type has associated icon and color for visual differentiation.
enum NotificationType {
  /// General system notification
  system,

  /// New event notification
  event,

  /// New photo uploaded
  photo,

  /// Registry item purchased
  registryPurchase,

  /// Comment added
  comment,

  /// Like received
  like,

  /// New follower
  follower,

  /// Invitation sent/received
  invitation,

  /// RSVP reminder
  rsvp,

  /// Name suggestion
  nameSuggestion,

  /// Vote received
  vote,

  /// Owner update
  ownerUpdate,

  /// Milestone reached
  milestone;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a NotificationType from a string
  static NotificationType fromJson(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }

  /// Get an icon for the notification type
  IconData get icon {
    switch (this) {
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.photo:
        return Icons.photo;
      case NotificationType.registryPurchase:
        return Icons.shopping_cart;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.follower:
        return Icons.person_add;
      case NotificationType.invitation:
        return Icons.mail;
      case NotificationType.rsvp:
        return Icons.calendar_today;
      case NotificationType.nameSuggestion:
        return Icons.lightbulb;
      case NotificationType.vote:
        return Icons.how_to_vote;
      case NotificationType.ownerUpdate:
        return Icons.info;
      case NotificationType.milestone:
        return Icons.stars;
    }
  }

  /// Get a color for the notification type
  Color get color {
    switch (this) {
      case NotificationType.system:
        return Colors.blue;
      case NotificationType.event:
        return Colors.purple;
      case NotificationType.photo:
        return Colors.pink;
      case NotificationType.registryPurchase:
        return Colors.green;
      case NotificationType.comment:
        return Colors.orange;
      case NotificationType.like:
        return Colors.red;
      case NotificationType.follower:
        return Colors.teal;
      case NotificationType.invitation:
        return Colors.indigo;
      case NotificationType.rsvp:
        return Colors.amber;
      case NotificationType.nameSuggestion:
        return Colors.yellow;
      case NotificationType.vote:
        return Colors.deepPurple;
      case NotificationType.ownerUpdate:
        return Colors.cyan;
      case NotificationType.milestone:
        return Colors.deepOrange;
    }
  }

  /// Get a display-friendly name for the notification type
  String get displayName {
    switch (this) {
      case NotificationType.system:
        return 'System';
      case NotificationType.event:
        return 'Event';
      case NotificationType.photo:
        return 'Photo';
      case NotificationType.registryPurchase:
        return 'Registry Purchase';
      case NotificationType.comment:
        return 'Comment';
      case NotificationType.like:
        return 'Like';
      case NotificationType.follower:
        return 'New Follower';
      case NotificationType.invitation:
        return 'Invitation';
      case NotificationType.rsvp:
        return 'RSVP';
      case NotificationType.nameSuggestion:
        return 'Name Suggestion';
      case NotificationType.vote:
        return 'Vote';
      case NotificationType.ownerUpdate:
        return 'Owner Update';
      case NotificationType.milestone:
        return 'Milestone';
    }
  }
}
