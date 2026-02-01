import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';

void main() {
  group('UserRole', () {
    test('has correct number of values', () {
      expect(UserRole.values.length, 2);
    });

    test('has owner and follower values', () {
      expect(UserRole.values, contains(UserRole.owner));
      expect(UserRole.values, contains(UserRole.follower));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(UserRole.owner.toJson(), 'owner');
        expect(UserRole.follower.toJson(), 'follower');
      });

      test('fromJson parses correct values', () {
        expect(UserRole.fromJson('owner'), UserRole.owner);
        expect(UserRole.fromJson('follower'), UserRole.follower);
      });

      test('fromJson is case insensitive', () {
        expect(UserRole.fromJson('OWNER'), UserRole.owner);
        expect(UserRole.fromJson('Follower'), UserRole.follower);
      });

      test('fromJson defaults to follower for invalid input', () {
        expect(UserRole.fromJson('invalid'), UserRole.follower);
        expect(UserRole.fromJson(''), UserRole.follower);
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(UserRole.owner.displayName, 'Owner');
        expect(UserRole.follower.displayName, 'Follower');
      });
    });

    group('icon', () {
      test('returns Icons for each role', () {
        expect(UserRole.owner.icon, Icons.person);
        expect(UserRole.follower.icon, Icons.group);
      });
    });

    group('description', () {
      test('returns non-empty description', () {
        expect(UserRole.owner.description.isNotEmpty, true);
        expect(UserRole.follower.description.isNotEmpty, true);
      });
    });

    group('isOwner and isFollower', () {
      test('isOwner returns true for owner role', () {
        expect(UserRole.owner.isOwner, true);
        expect(UserRole.follower.isOwner, false);
      });

      test('isFollower returns true for follower role', () {
        expect(UserRole.owner.isFollower, false);
        expect(UserRole.follower.isFollower, true);
      });
    });
  });
}
