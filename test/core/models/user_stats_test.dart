import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/user_stats.dart';

void main() {
  group('UserStats', () {
    const userStats = UserStats(
      eventsAttendedCount: 5,
      itemsPurchasedCount: 3,
      photosSquishedCount: 12,
      commentsAddedCount: 8,
    );

    group('fromJson', () {
      test('creates UserStats from valid JSON', () {
        final json = {
          'events_attended_count': 5,
          'items_purchased_count': 3,
          'photos_squished_count': 12,
          'comments_added_count': 8,
        };

        final result = UserStats.fromJson(json);

        expect(result.eventsAttendedCount, 5);
        expect(result.itemsPurchasedCount, 3);
        expect(result.photosSquishedCount, 12);
        expect(result.commentsAddedCount, 8);
      });

      test('defaults to 0 for missing counts', () {
        final json = <String, dynamic>{};

        final result = UserStats.fromJson(json);

        expect(result.eventsAttendedCount, 0);
        expect(result.itemsPurchasedCount, 0);
        expect(result.photosSquishedCount, 0);
        expect(result.commentsAddedCount, 0);
      });
    });

    group('toJson', () {
      test('converts UserStats to JSON', () {
        final json = userStats.toJson();

        expect(json['events_attended_count'], 5);
        expect(json['items_purchased_count'], 3);
        expect(json['photos_squished_count'], 12);
        expect(json['comments_added_count'], 8);
      });
    });

    group('totalActivityCount', () {
      test('calculates total activity count correctly', () {
        expect(userStats.totalActivityCount, 28);
      });

      test('returns 0 for empty stats', () {
        const emptyStats = UserStats();
        expect(emptyStats.totalActivityCount, 0);
      });
    });

    group('hasActivity', () {
      test('returns true when there is activity', () {
        expect(userStats.hasActivity, true);
      });

      test('returns false when there is no activity', () {
        const emptyStats = UserStats();
        expect(emptyStats.hasActivity, false);
      });
    });

    group('validate', () {
      test('returns null for valid stats', () {
        expect(userStats.validate(), null);
      });

      test('returns null for zero counts', () {
        const zeroStats = UserStats();
        expect(zeroStats.validate(), null);
      });

      test('returns error for negative events count', () {
        const negativeStats = UserStats(eventsAttendedCount: -1);
        expect(negativeStats.validate(), contains('Events attended count'));
      });

      test('returns error for negative items purchased count', () {
        const negativeStats = UserStats(itemsPurchasedCount: -1);
        expect(negativeStats.validate(), contains('Items purchased count'));
      });

      test('returns error for negative photos squished count', () {
        const negativeStats = UserStats(photosSquishedCount: -1);
        expect(negativeStats.validate(), contains('Photos squished count'));
      });

      test('returns error for negative comments count', () {
        const negativeStats = UserStats(commentsAddedCount: -1);
        expect(negativeStats.validate(), contains('Comments added count'));
      });
    });

    group('copyWith', () {
      test('creates a copy with all fields unchanged when no params provided', () {
        final copy = userStats.copyWith();
        expect(copy, userStats);
      });

      test('updates eventsAttendedCount only', () {
        final copy = userStats.copyWith(eventsAttendedCount: 10);
        expect(copy.eventsAttendedCount, 10);
        expect(copy.itemsPurchasedCount, userStats.itemsPurchasedCount);
        expect(copy.photosSquishedCount, userStats.photosSquishedCount);
        expect(copy.commentsAddedCount, userStats.commentsAddedCount);
      });

      test('updates itemsPurchasedCount only', () {
        final copy = userStats.copyWith(itemsPurchasedCount: 7);
        expect(copy.itemsPurchasedCount, 7);
        expect(copy.eventsAttendedCount, userStats.eventsAttendedCount);
      });

      test('updates multiple fields', () {
        final copy = userStats.copyWith(
          eventsAttendedCount: 1,
          photosSquishedCount: 2,
        );
        expect(copy.eventsAttendedCount, 1);
        expect(copy.photosSquishedCount, 2);
        expect(copy.itemsPurchasedCount, userStats.itemsPurchasedCount);
        expect(copy.commentsAddedCount, userStats.commentsAddedCount);
      });
    });

    group('equality', () {
      test('equal stats are equal', () {
        const stats1 = UserStats(
          eventsAttendedCount: 5,
          itemsPurchasedCount: 3,
          photosSquishedCount: 12,
          commentsAddedCount: 8,
        );
        const stats2 = UserStats(
          eventsAttendedCount: 5,
          itemsPurchasedCount: 3,
          photosSquishedCount: 12,
          commentsAddedCount: 8,
        );

        expect(stats1, stats2);
        expect(stats1.hashCode, stats2.hashCode);
      });

      test('different stats are not equal', () {
        const stats1 = UserStats(eventsAttendedCount: 5);
        const stats2 = UserStats(eventsAttendedCount: 3);

        expect(stats1, isNot(stats2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = userStats.toString();

        expect(str, contains('UserStats'));
        expect(str, contains('5'));
        expect(str, contains('3'));
        expect(str, contains('12'));
        expect(str, contains('8'));
      });
    });
  });
}
