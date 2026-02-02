/// Registry item model representing an item in a baby registry
///
/// Maps to the `registry_items` table in Supabase.
/// Registry items can be purchased by users and have priority levels.
class RegistryItem {
  /// Unique registry item identifier
  final String id;

  /// Baby profile this registry item is associated with
  final String babyProfileId;

  /// User who created this registry item
  final String createdByUserId;

  /// Item name
  final String name;

  /// Item description
  final String? description;

  /// URL link to the item (e.g., store product page)
  final String? linkUrl;

  /// Item priority (1-5, where 5 is highest priority)
  final int priority;

  /// Timestamp when the item was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Timestamp when the item was soft deleted (null if not deleted)
  final DateTime? deletedAt;

  /// Creates a new RegistryItem instance
  const RegistryItem({
    required this.id,
    required this.babyProfileId,
    required this.createdByUserId,
    required this.name,
    this.description,
    this.linkUrl,
    this.priority = 3,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Creates a RegistryItem from a JSON map
  factory RegistryItem.fromJson(Map<String, dynamic> json) {
    return RegistryItem(
      id: json['id'] as String,
      babyProfileId: json['baby_profile_id'] as String,
      createdByUserId: json['created_by_user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      linkUrl: json['link_url'] as String?,
      priority: json['priority'] as int? ?? 3,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this RegistryItem to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baby_profile_id': babyProfileId,
      'created_by_user_id': createdByUserId,
      'name': name,
      'description': description,
      'link_url': linkUrl,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Validates the registry item data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Registry item name is required';
    }
    if (name.length > 200) {
      return 'Registry item name must be 200 characters or less';
    }
    if (priority < 1 || priority > 5) {
      return 'Priority must be between 1 and 5';
    }
    if (description != null && description!.length > 1000) {
      return 'Description must be 1000 characters or less';
    }
    if (linkUrl != null && linkUrl!.length > 2000) {
      return 'Link URL must be 2000 characters or less';
    }
    return null;
  }

  /// Checks if the item is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Checks if the item has high priority (4 or 5)
  bool get isHighPriority => priority >= 4;

  /// Checks if the item has low priority (1 or 2)
  bool get isLowPriority => priority <= 2;

  /// Creates a copy of this RegistryItem with the specified fields replaced
  RegistryItem copyWith({
    String? id,
    String? babyProfileId,
    String? createdByUserId,
    String? name,
    String? description,
    String? linkUrl,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return RegistryItem(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      name: name ?? this.name,
      description: description ?? this.description,
      linkUrl: linkUrl ?? this.linkUrl,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegistryItem &&
        other.id == id &&
        other.babyProfileId == babyProfileId &&
        other.createdByUserId == createdByUserId &&
        other.name == name &&
        other.description == description &&
        other.linkUrl == linkUrl &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        babyProfileId.hashCode ^
        createdByUserId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        linkUrl.hashCode ^
        priority.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }

  @override
  String toString() {
    return 'RegistryItem(id: $id, name: $name, priority: $priority)';
  }
}
