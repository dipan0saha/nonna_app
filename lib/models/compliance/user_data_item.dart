import 'data_category.dart';

/// Represents user data that needs to be tracked for GDPR/CCPA compliance
class UserDataItem {
  final String dataType;
  final DataCategory category;
  final String? value;
  final DateTime collectedAt;
  final String? legalBasis;
  final bool isDeleted;
  final DateTime? deletedAt;

  const UserDataItem({
    required this.dataType,
    required this.category,
    this.value,
    required this.collectedAt,
    this.legalBasis,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Creates a copy with modified fields
  UserDataItem copyWith({
    String? dataType,
    DataCategory? category,
    String? value,
    DateTime? collectedAt,
    String? legalBasis,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return UserDataItem(
      dataType: dataType ?? this.dataType,
      category: category ?? this.category,
      value: value ?? this.value,
      collectedAt: collectedAt ?? this.collectedAt,
      legalBasis: legalBasis ?? this.legalBasis,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Converts to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'dataType': dataType,
      'category': category.name,
      'value': value,
      'collectedAt': collectedAt.toIso8601String(),
      'legalBasis': legalBasis,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Creates a UserDataItem from a JSON map
  factory UserDataItem.fromJson(Map<String, dynamic> json) {
    return UserDataItem(
      dataType: json['dataType'] as String,
      category: DataCategory.values.firstWhere((e) => e.name == json['category']),
      value: json['value'] as String?,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      legalBasis: json['legalBasis'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  /// Returns true if this data is within the retention period
  bool isWithinRetentionPeriod(DateTime now) {
    if (!isDeleted || deletedAt == null) {
      return true; // Active data is always within retention period
    }

    final daysSinceDeletion = now.difference(deletedAt!).inDays;
    return daysSinceDeletion < category.retentionPeriodDays;
  }

  /// Returns true if this data can be permanently deleted
  bool canPermanentlyDelete(DateTime now) {
    return isDeleted && !isWithinRetentionPeriod(now);
  }
}

/// Represents a complete user data export for GDPR/CCPA compliance
class UserDataExport {
  final String userId;
  final DateTime exportedAt;
  final List<UserDataItem> dataItems;
  final Map<String, dynamic> metadata;

  const UserDataExport({
    required this.userId,
    required this.exportedAt,
    required this.dataItems,
    this.metadata = const {},
  });

  /// Converts to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'exportedAt': exportedAt.toIso8601String(),
      'dataItems': dataItems.map((item) => item.toJson()).toList(),
      'metadata': metadata,
    };
  }

  /// Creates a UserDataExport from a JSON map
  factory UserDataExport.fromJson(Map<String, dynamic> json) {
    return UserDataExport(
      userId: json['userId'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      dataItems: (json['dataItems'] as List)
          .map((item) => UserDataItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
