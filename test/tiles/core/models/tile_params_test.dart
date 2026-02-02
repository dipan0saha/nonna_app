import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/tiles/core/models/tile_params.dart';

void main() {
  group('TileParams', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);
    const tileParams = TileParams(
      babyProfileIds: ['baby-123', 'baby-456'],
      limit: 10,
      offset: 0,
      customParams: {'filter': 'active'},
    );

    final tileParamsWithDates = TileParams(
      babyProfileIds: const ['baby-123'],
      startDate: startDate,
      endDate: endDate,
      limit: 5,
    );

    group('fromJson', () {
      test('creates TileParams from valid JSON', () {
        final json = {
          'baby_profile_ids': ['baby-123', 'baby-456'],
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'limit': 10,
          'offset': 0,
          'custom_params': {'filter': 'active'},
        };

        final result = TileParams.fromJson(json);

        expect(result.babyProfileIds, ['baby-123', 'baby-456']);
        expect(result.startDate, startDate);
        expect(result.endDate, endDate);
        expect(result.limit, 10);
        expect(result.offset, 0);
        expect(result.customParams, {'filter': 'active'});
      });

      test('handles null fields', () {
        final json = <String, dynamic>{};

        final result = TileParams.fromJson(json);

        expect(result.babyProfileIds, null);
        expect(result.startDate, null);
        expect(result.endDate, null);
        expect(result.limit, null);
        expect(result.offset, null);
        expect(result.customParams, null);
      });
    });

    group('toJson', () {
      test('converts TileParams to JSON', () {
        final json = tileParamsWithDates.toJson();

        expect(json['baby_profile_ids'], ['baby-123']);
        expect(json['start_date'], startDate.toIso8601String());
        expect(json['end_date'], endDate.toIso8601String());
        expect(json['limit'], 5);
        expect(json['offset'], null);
      });
    });

    group('hasValidDateRange', () {
      test('returns true when both dates are null', () {
        const params = TileParams();
        expect(params.hasValidDateRange, true);
      });

      test('returns true when start date is null', () {
        final params = TileParams(endDate: endDate);
        expect(params.hasValidDateRange, true);
      });

      test('returns true when end date is null', () {
        final params = TileParams(startDate: startDate);
        expect(params.hasValidDateRange, true);
      });

      test('returns true when start date is before end date', () {
        expect(tileParamsWithDates.hasValidDateRange, true);
      });

      test('returns false when end date is before start date', () {
        final params = TileParams(
          startDate: endDate,
          endDate: startDate,
        );
        expect(params.hasValidDateRange, false);
      });
    });

    group('validate', () {
      test('returns null for valid params', () {
        expect(tileParams.validate(), null);
      });

      test('returns null for params with valid date range', () {
        expect(tileParamsWithDates.validate(), null);
      });

      test('returns error when end date is before start date', () {
        final params = TileParams(
          startDate: endDate,
          endDate: startDate,
        );
        expect(params.validate(), contains('End date must be after start date'));
      });

      test('returns error for negative limit', () {
        const params = TileParams(limit: -1);
        expect(params.validate(), contains('Limit must be 0 or greater'));
      });

      test('returns error for negative offset', () {
        const params = TileParams(offset: -5);
        expect(params.validate(), contains('Offset must be 0 or greater'));
      });

      test('returns null for zero limit and offset', () {
        const params = TileParams(limit: 0, offset: 0);
        expect(params.validate(), null);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = tileParams.copyWith(
          limit: 20,
          offset: 10,
        );

        expect(updated.babyProfileIds, tileParams.babyProfileIds);
        expect(updated.limit, 20);
        expect(updated.offset, 10);
        expect(updated.customParams, tileParams.customParams);
      });

      test('maintains original values when no updates provided', () {
        final copy = tileParams.copyWith();

        expect(copy.babyProfileIds, tileParams.babyProfileIds);
        expect(copy.limit, tileParams.limit);
        expect(copy.offset, tileParams.offset);
      });
    });

    group('equality', () {
      test('equal params are equal', () {
        const params1 = TileParams(
          babyProfileIds: ['baby-123'],
          limit: 10,
        );
        const params2 = TileParams(
          babyProfileIds: ['baby-123'],
          limit: 10,
        );

        expect(params1, params2);
        expect(params1.hashCode, params2.hashCode);
      });

      test('different params are not equal', () {
        const params1 = TileParams(
          babyProfileIds: ['baby-123'],
          limit: 10,
        );
        const params2 = TileParams(
          babyProfileIds: ['baby-456'],
          limit: 20,
        );

        expect(params1, isNot(params2));
      });

      test('params with different list contents are not equal', () {
        const params1 = TileParams(
          babyProfileIds: ['baby-123', 'baby-456'],
        );
        const params2 = TileParams(
          babyProfileIds: ['baby-123'],
        );

        expect(params1, isNot(params2));
      });

      test('params with different customParams are not equal', () {
        const params1 = TileParams(
          customParams: {'filter': 'active'},
        );
        const params2 = TileParams(
          customParams: {'filter': 'inactive'},
        );

        expect(params1, isNot(params2));
      });

      test('params with same customParams are equal', () {
        const params1 = TileParams(
          customParams: {'filter': 'active', 'count': '5'},
        );
        const params2 = TileParams(
          customParams: {'filter': 'active', 'count': '5'},
        );

        expect(params1, params2);
        expect(params1.hashCode, params2.hashCode);
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = tileParams.toString();

        expect(str, contains('TileParams'));
        expect(str, contains('baby-123'));
        expect(str, contains('10'));
      });
    });
  });
}
