/// Registry purchase model representing a purchase of a registry item
///
/// Maps to the `registry_purchases` table in Supabase.
/// Represents an immutable audit trail of purchases.
class RegistryPurchase {
  /// Unique purchase identifier
  final String id;

  /// Registry item that was purchased
  final String registryItemId;

  /// User who made the purchase
  final String purchasedByUserId;

  /// Timestamp when the purchase was made
  final DateTime purchasedAt;

  /// Optional note about the purchase
  final String? note;

  /// Timestamp when the record was created
  final DateTime createdAt;

  /// Creates a new RegistryPurchase instance
  const RegistryPurchase({
    required this.id,
    required this.registryItemId,
    required this.purchasedByUserId,
    required this.purchasedAt,
    this.note,
    required this.createdAt,
  });

  /// Creates a RegistryPurchase from a JSON map
  factory RegistryPurchase.fromJson(Map<String, dynamic> json) {
    return RegistryPurchase(
      id: json['id'] as String,
      registryItemId: json['registry_item_id'] as String,
      purchasedByUserId: json['purchased_by_user_id'] as String,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this RegistryPurchase to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registry_item_id': registryItemId,
      'purchased_by_user_id': purchasedByUserId,
      'purchased_at': purchasedAt.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Validates the purchase data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (purchasedAt.isAfter(DateTime.now())) {
      return 'Purchase date cannot be in the future';
    }
    if (note != null && note!.length > 500) {
      return 'Purchase note must be 500 characters or less';
    }
    return null;
  }

  /// Creates a copy of this RegistryPurchase with the specified fields replaced
  RegistryPurchase copyWith({
    String? id,
    String? registryItemId,
    String? purchasedByUserId,
    DateTime? purchasedAt,
    String? note,
    DateTime? createdAt,
  }) {
    return RegistryPurchase(
      id: id ?? this.id,
      registryItemId: registryItemId ?? this.registryItemId,
      purchasedByUserId: purchasedByUserId ?? this.purchasedByUserId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegistryPurchase &&
        other.id == id &&
        other.registryItemId == registryItemId &&
        other.purchasedByUserId == purchasedByUserId &&
        other.purchasedAt == purchasedAt &&
        other.note == note &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        registryItemId.hashCode ^
        purchasedByUserId.hashCode ^
        purchasedAt.hashCode ^
        note.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'RegistryPurchase(id: $id, registryItemId: $registryItemId, purchasedAt: $purchasedAt)';
  }
}
