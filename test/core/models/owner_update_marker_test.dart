import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/owner_update_marker.dart';

void main() {
  group('OwnerUpdateMarker', () {
    final now = DateTime.now();
    final tilesLastUpdated = DateTime.now().subtract(const Duration(hours: 2));
    final marker = OwnerUpdateMarker(
      id: 'marker-123',
      babyProfileId: 'baby-profile-123',
      tilesLastUpdatedAt: tilesLastUpdated,
      updatedByUserId: 'user-123',
      reason: 'Manual refresh requested',
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates OwnerUpdateMarker from valid JSON', () {
        final json = {
          'id': 'marker-123',
          'baby_profile_id': 'baby-profile-123',
          'tiles_last_updated_at': tilesLastUpdated.toIso8601String(),
          'updated_by_user_id': 'user-123',
          'reason': 'Manual refresh requested',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = OwnerUpdateMarker.fromJson(json);

        expect(result.id, 'marker-123');
        expect(result.babyProfileId, 'baby-profile-123');
        expect(result.tilesLastUpdatedAt, tilesLastUpdated);
        expect(result.updatedByUserId, 'user-123');
        expect(result.reason, 'Manual refresh requested');
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
      });

      test('handles null reason', () {
        final json = {
          'id': 'marker-123',
          'baby_profile_id': 'baby-profile-123',
          'tiles_last_updated_at': tilesLastUpdated.toIso8601String(),
          'updated_by_user_id': 'user-123',
          'reason': null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = OwnerUpdateMarker.fromJson(json);

        expect(result.reason, null);
        expect(result.hasReason, false);
      });
    });

    group('toJson', () {
      test('converts OwnerUpdateMarker to JSON', () {
        final json = marker.toJson();

        expect(json['id'], 'marker-123');
        expect(json['baby_profile_id'], 'baby-profile-123');
        expect(
          json['tiles_last_updated_at'],
          tilesLastUpdated.toIso8601String(),
        );
        expect(json['updated_by_user_id'], 'user-123');
        expect(json['reason'], 'Manual refresh requested');
        expect(json['created_at'], now.toIso8601String());
        expect(json['updated_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid marker', () {
        expect(marker.validate(), null);
      });

      test('returns error for empty baby profile ID', () {
        final invalid = marker.copyWith(babyProfileId: '');
        expect(invalid.validate(), 'Baby profile ID is required');
      });

      test('returns error for whitespace-only baby profile ID', () {
        final invalid = marker.copyWith(babyProfileId: '   ');
        expect(invalid.validate(), 'Baby profile ID is required');
      });

      test('returns error for empty updated by user ID', () {
        final invalid = marker.copyWith(updatedByUserId: '');
        expect(invalid.validate(), 'Updated by user ID is required');
      });

      test('returns error for whitespace-only updated by user ID', () {
        final invalid = marker.copyWith(updatedByUserId: '   ');
        expect(invalid.validate(), 'Updated by user ID is required');
      });

      test('returns error for reason exceeding 500 characters', () {
        final invalid = marker.copyWith(reason: 'a' * 501);
        expect(
          invalid.validate(),
          'Reason must be 500 characters or less',
        );
      });

      test('accepts reason with exactly 500 characters', () {
        final valid = marker.copyWith(reason: 'a' * 500);
        expect(valid.validate(), null);
      });
    });

    group('hasReason', () {
      test('returns true when reason exists', () {
        expect(marker.hasReason, true);
      });

      test('returns false when reason is null', () {
        final noReason = marker.copyWith(reason: null);
        expect(noReason.hasReason, false);
      });

      test('returns false when reason is empty', () {
        final emptyReason = marker.copyWith(reason: '');
        expect(emptyReason.hasReason, false);
      });
    });

    group('needsRefresh', () {
      test('returns true when tiles were updated after last fetch', () {
        final lastFetched = tilesLastUpdated.subtract(const Duration(hours: 1));
        expect(marker.needsRefresh(lastFetched), true);
      });

      test('returns false when tiles were updated before last fetch', () {
        final lastFetched = tilesLastUpdated.add(const Duration(hours: 1));
        expect(marker.needsRefresh(lastFetched), false);
      });

      test('returns false when tiles were updated at the same time as fetch', () {
        expect(marker.needsRefresh(tilesLastUpdated), false);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final newTime = DateTime.now();
        final copy = marker.copyWith(
          tilesLastUpdatedAt: newTime,
          reason: 'Updated reason',
        );

        expect(copy.id, marker.id);
        expect(copy.tilesLastUpdatedAt, newTime);
        expect(copy.reason, 'Updated reason');
        expect(copy.babyProfileId, marker.babyProfileId);
      });
    });

    group('equality', () {
      test('two markers with same values are equal', () {
        final marker1 = OwnerUpdateMarker(
          id: 'marker-123',
          babyProfileId: 'baby-123',
          tilesLastUpdatedAt: tilesLastUpdated,
          updatedByUserId: 'user-123',
          createdAt: now,
          updatedAt: now,
        );

        final marker2 = OwnerUpdateMarker(
          id: 'marker-123',
          babyProfileId: 'baby-123',
          tilesLastUpdatedAt: tilesLastUpdated,
          updatedByUserId: 'user-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(marker1, equals(marker2));
        expect(marker1.hashCode, equals(marker2.hashCode));
      });

      test('two markers with different values are not equal', () {
        final marker1 = marker;
        final marker2 = marker.copyWith(reason: 'Different reason');

        expect(marker1, isNot(equals(marker2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = marker.toString();

        expect(str, contains('OwnerUpdateMarker'));
        expect(str, contains('marker-123'));
        expect(str, contains('baby-profile-123'));
        expect(str, contains('hasReason: true'));
      });
    });
  });
}
