/// Announcement priority levels
enum AnnouncementPriority {
  low,
  medium,
  high,
  critical,
}

/// System announcement model
///
/// **Functional Requirements**: Section 3.3.11 - System Announcements
/// Reference: docs/Core_development_component_identification.md
///
/// Represents a global system announcement that can be displayed to all users.
///
/// Features:
/// - Priority levels (low, medium, high, critical)
/// - Optional expiration date
/// - JSON serialization
///
/// Dependencies: None
class SystemAnnouncement {
  final String id;
  final String title;
  final String body;
  final AnnouncementPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const SystemAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
  });

  /// Check if the announcement has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SystemAnnouncement.fromJson(Map<String, dynamic> json) {
    return SystemAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      priority: AnnouncementPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => AnnouncementPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}
