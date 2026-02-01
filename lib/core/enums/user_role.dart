import 'package:flutter/material.dart';

/// User role enumeration for the Nonna app
///
/// Defines the two primary roles:
/// - owner: The primary caregiver/parent creating baby profiles
/// - follower: Family and friends who follow and engage with baby profiles
enum UserRole {
  /// The owner role - creates and manages baby profiles
  owner,

  /// The follower role - views and engages with baby profiles
  follower;

  /// Convert the enum to a string representation
  String toJson() => name;

  /// Create a UserRole from a string
  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value.toLowerCase(),
      orElse: () => UserRole.follower,
    );
  }

  /// Get a display-friendly name for the role
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.follower:
        return 'Follower';
    }
  }

  /// Get an icon for the role
  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.person;
      case UserRole.follower:
        return Icons.group;
    }
  }

  /// Get a description for the role
  String get description {
    switch (this) {
      case UserRole.owner:
        return 'Create and manage baby profiles';
      case UserRole.follower:
        return 'Follow and engage with baby profiles';
    }
  }

  /// Check if this role is the owner role
  bool get isOwner => this == UserRole.owner;

  /// Check if this role is the follower role
  bool get isFollower => this == UserRole.follower;
}
