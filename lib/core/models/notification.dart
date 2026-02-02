import 'dart:convert';
import '../enums/notification_type.dart';

/// Notification model representing a notification in the Nonna app
///
/// Maps to the `notifications` table in Supabase.
/// Notifications are sent to users for various events and activities.
/// Supports realtime updates and deep-linking.
/// Never deleted (audit trail).
class Notification {
  /// Unique notification identifier
  final String id;

  /// User who receives this notification
  final String recipientUserId;

  /// Baby profile this notification is associated with (optional)
  final String? babyProfileId;

  /// Type of notification
  final NotificationType type;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Additional payload data in JSON format
  final Map<String, dynamic>? payload;

  /// Timestamp when the notification was read (null if unread)
  final DateTime? readAt;

  /// Timestamp when the notification was created
  final DateTime createdAt;

  /// Creates a new Notification instance
  const Notification({
    required this.id,
    required this.recipientUserId,
    this.babyProfileId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.readAt,
    required this.createdAt,
  });

  /// Creates a Notification from a JSON map
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      recipientUserId: json['recipient_user_id'] as String,
      babyProfileId: json['baby_profile_id'] as String?,
      type: NotificationType.fromJson(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] != null
          ? (json['payload'] is String
              ? jsonDecode(json['payload'] as String) as Map<String, dynamic>
              : json['payload'] as Map<String, dynamic>)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this Notification to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_user_id': recipientUserId,
      'baby_profile_id': babyProfileId,
      'type': type.toJson(),
      'title': title,
      'body': body,
      'payload': payload,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the notification data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (title.trim().isEmpty) {
      return 'Notification title is required';
    }
    if (title.length > 100) {
      return 'Notification title must be 100 characters or less';
    }
    if (body.trim().isEmpty) {
      return 'Notification body is required';
    }
    if (body.length > 500) {
      return 'Notification body must be 500 characters or less';
    }
    return null;
  }

  /// Checks if the notification has been read
  bool get isRead => readAt != null;

  /// Checks if the notification is unread
  bool get isUnread => readAt == null;

  /// Checks if the notification has a payload
  bool get hasPayload => payload != null && payload!.isNotEmpty;

  /// Marks the notification as read by setting the readAt timestamp
  Notification markAsRead([DateTime? timestamp]) {
    return copyWith(readAt: timestamp ?? DateTime.now());
  }

  /// Marks the notification as unread by clearing the readAt timestamp
  Notification markAsUnread() {
    return copyWith(readAt: null);
  }

  /// Creates a copy of this Notification with the specified fields replaced
  Notification copyWith({
    String? id,
    String? recipientUserId,
    String? babyProfileId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notification &&
        other.id == id &&
        other.recipientUserId == recipientUserId &&
        other.babyProfileId == babyProfileId &&
        other.type == type &&
        other.title == title &&
        other.body == body &&
        _mapEquals(other.payload, payload) &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recipientUserId.hashCode ^
        babyProfileId.hashCode ^
        type.hashCode ^
        title.hashCode ^
        body.hashCode ^
        (payload != null ? Object.hashAll(payload!.entries) : 0) ^
        readAt.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Notification(id: $id, recipientUserId: $recipientUserId, type: $type, title: $title, isRead: $isRead)';
  }

  /// Helper method to compare two maps for equality
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
