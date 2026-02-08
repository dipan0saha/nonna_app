/// Represents types of user consent for data processing
enum ConsentType {
  /// Consent for processing personal data
  dataProcessing,

  /// Consent for marketing communications
  marketing,

  /// Consent for push notifications
  pushNotifications,

  /// Consent for analytics and performance monitoring
  analytics,

  /// Consent for sharing data with third parties
  thirdPartySharing,

  /// Consent for photo and media storage
  mediaStorage,
}

extension ConsentTypeExtension on ConsentType {
  /// Returns a human-readable description of the consent type
  String get description {
    switch (this) {
      case ConsentType.dataProcessing:
        return 'Processing of personal data';
      case ConsentType.marketing:
        return 'Marketing communications';
      case ConsentType.pushNotifications:
        return 'Push notifications';
      case ConsentType.analytics:
        return 'Analytics and performance monitoring';
      case ConsentType.thirdPartySharing:
        return 'Sharing data with third parties';
      case ConsentType.mediaStorage:
        return 'Storage of photos and media';
    }
  }

  /// Returns true if this consent is required for the app to function
  bool get isRequired {
    return this == ConsentType.dataProcessing;
  }

  /// Returns true if this consent can be withdrawn at any time
  bool get canWithdraw {
    return !isRequired;
  }
}

/// Represents a user's consent record
class ConsentRecord {
  final ConsentType type;
  final bool granted;
  final DateTime timestamp;
  final String? purpose;

  const ConsentRecord({
    required this.type,
    required this.granted,
    required this.timestamp,
    this.purpose,
  });

  /// Creates a copy with modified fields
  ConsentRecord copyWith({
    ConsentType? type,
    bool? granted,
    DateTime? timestamp,
    String? purpose,
  }) {
    return ConsentRecord(
      type: type ?? this.type,
      granted: granted ?? this.granted,
      timestamp: timestamp ?? this.timestamp,
      purpose: purpose ?? this.purpose,
    );
  }

  /// Converts to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'granted': granted,
      'timestamp': timestamp.toIso8601String(),
      'purpose': purpose,
    };
  }

  /// Creates a ConsentRecord from a JSON map
  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      type: ConsentType.values.firstWhere((e) => e.name == json['type']),
      granted: json['granted'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      purpose: json['purpose'] as String?,
    );
  }
}
