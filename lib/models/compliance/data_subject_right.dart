/// Represents GDPR/CCPA data subject rights
enum DataSubjectRight {
  /// Right to access personal data (GDPR Art. 15, CCPA)
  access,

  /// Right to rectification/correction (GDPR Art. 16, CCPA)
  rectification,

  /// Right to erasure/"right to be forgotten" (GDPR Art. 17, CCPA)
  erasure,

  /// Right to data portability (GDPR Art. 20, CCPA)
  portability,

  /// Right to restrict processing (GDPR Art. 18)
  restrictProcessing,

  /// Right to object to processing (GDPR Art. 21)
  objectToProcessing,

  /// Right to opt-out of sale of personal information (CCPA)
  optOutOfSale,

  /// Right to withdraw consent (GDPR)
  withdrawConsent,
}

extension DataSubjectRightExtension on DataSubjectRight {
  /// Returns a human-readable description of the right
  String get description {
    switch (this) {
      case DataSubjectRight.access:
        return 'Right to access personal data';
      case DataSubjectRight.rectification:
        return 'Right to rectify incorrect personal data';
      case DataSubjectRight.erasure:
        return 'Right to erasure (right to be forgotten)';
      case DataSubjectRight.portability:
        return 'Right to data portability';
      case DataSubjectRight.restrictProcessing:
        return 'Right to restrict processing';
      case DataSubjectRight.objectToProcessing:
        return 'Right to object to processing';
      case DataSubjectRight.optOutOfSale:
        return 'Right to opt-out of sale of personal information';
      case DataSubjectRight.withdrawConsent:
        return 'Right to withdraw consent';
    }
  }

  /// Returns true if this right is GDPR-specific
  bool get isGDPR {
    return this == DataSubjectRight.restrictProcessing ||
        this == DataSubjectRight.objectToProcessing ||
        this == DataSubjectRight.withdrawConsent;
  }

  /// Returns true if this right is CCPA-specific
  bool get isCCPA {
    return this == DataSubjectRight.optOutOfSale;
  }
}
