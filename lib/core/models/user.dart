/// User profile model representing the authenticated user in the Nonna app
///
/// Maps to the `profiles` table in Supabase.
/// Contains user identity and preference information.
class User {
  /// Unique user identifier (matches auth.users.id)
  final String userId;

  /// User's display name
  final String displayName;

  /// URL to user's avatar image
  final String? avatarUrl;

  /// Whether biometric authentication is enabled for this user
  final bool biometricEnabled;

  /// Timestamp when the user was created
  final DateTime createdAt;

  /// Timestamp of the last update
  final DateTime updatedAt;

  /// Creates a new User instance
  const User({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.biometricEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this User to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'biometric_enabled': biometricEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Validates the user data
  ///
  /// Returns an error message if validation fails, null otherwise.
  String? validate() {
    if (displayName.trim().isEmpty) {
      return 'Display name is required';
    }
    if (displayName.length > 100) {
      return 'Display name must be 100 characters or less';
    }
    return null;
  }

  /// Creates a copy of this User with the specified fields replaced
  User copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.biometricEnabled == biometricEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        displayName.hashCode ^
        avatarUrl.hashCode ^
        biometricEnabled.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, biometricEnabled: $biometricEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
