import 'package:test/test.dart';
import 'package:nonna_app/models/permission.dart';

void main() {
  group('Permission', () {
    group('enum values', () {
      test('platform management permissions have correct values', () {
        expect(Permission.manageUsers.value, equals('manage_users'));
        expect(Permission.manageSubscriptions.value, equals('manage_subscriptions'));
        expect(Permission.viewPlatformAnalytics.value, equals('view_platform_analytics'));
        expect(Permission.managePlatformSettings.value, equals('manage_platform_settings'));
      });

      test('ladder management permissions have correct values', () {
        expect(Permission.createLadder.value, equals('create_ladder'));
        expect(Permission.deleteLadder.value, equals('delete_ladder'));
        expect(Permission.configureLadder.value, equals('configure_ladder'));
        expect(Permission.manageLadderMembers.value, equals('manage_ladder_members'));
        expect(Permission.resolveDisputes.value, equals('resolve_disputes'));
        expect(Permission.modifyMatchResults.value, equals('modify_match_results'));
        expect(Permission.sendBroadcasts.value, equals('send_broadcasts'));
        expect(Permission.viewLadderAnalytics.value, equals('view_ladder_analytics'));
      });

      test('player action permissions have correct values', () {
        expect(Permission.viewLadder.value, equals('view_ladder'));
        expect(Permission.issueChallenges.value, equals('issue_challenges'));
        expect(Permission.reportMatchScores.value, equals('report_match_scores'));
        expect(Permission.confirmMatchScores.value, equals('confirm_match_scores'));
        expect(Permission.manageOwnProfile.value, equals('manage_own_profile'));
        expect(Permission.viewMatchHistory.value, equals('view_match_history'));
      });

      test('guest permissions have correct values', () {
        expect(Permission.viewPublicLadders.value, equals('view_public_ladders'));
        expect(Permission.viewPublicRankings.value, equals('view_public_rankings'));
      });
    });

    group('display names', () {
      test('have user-friendly display names', () {
        expect(Permission.manageUsers.displayName, equals('Manage Users'));
        expect(Permission.createLadder.displayName, equals('Create Ladder'));
        expect(Permission.issueChallenges.displayName, equals('Issue Challenges'));
        expect(Permission.viewPublicLadders.displayName, equals('View Public Ladders'));
      });
    });

    group('fromString', () {
      test('converts valid string to Permission', () {
        expect(Permission.fromString('manage_users'), equals(Permission.manageUsers));
        expect(Permission.fromString('create_ladder'), equals(Permission.createLadder));
        expect(Permission.fromString('issue_challenges'), equals(Permission.issueChallenges));
        expect(Permission.fromString('view_public_ladders'), equals(Permission.viewPublicLadders));
      });

      test('returns null for invalid string', () {
        expect(Permission.fromString('invalid'), isNull);
        expect(Permission.fromString(''), isNull);
        expect(Permission.fromString('non_existent_permission'), isNull);
      });
    });

    group('toString', () {
      test('returns display name', () {
        expect(Permission.manageUsers.toString(), equals('Manage Users'));
        expect(Permission.createLadder.toString(), equals('Create Ladder'));
        expect(Permission.issueChallenges.toString(), equals('Issue Challenges'));
      });
    });

    group('permission coverage', () {
      test('has appropriate number of permissions', () {
        // Ensure we have a reasonable set of permissions defined
        expect(Permission.values.length, greaterThanOrEqualTo(16));
      });

      test('all permissions have unique values', () {
        final values = Permission.values.map((p) => p.value).toList();
        final uniqueValues = values.toSet();
        expect(values.length, equals(uniqueValues.length));
      });

      test('all permissions have non-empty display names', () {
        for (final permission in Permission.values) {
          expect(permission.displayName.isNotEmpty, isTrue);
        }
      });
    });
  });
}
