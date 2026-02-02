import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/tile_type.dart';
import 'package:nonna_app/tiles/core/models/tile_definition.dart';

void main() {
  group('TileDefinition', () {
    final now = DateTime.now();
    final tileDefinition = TileDefinition(
      id: 'tile-def-123',
      tileType: TileType.upcomingEvents,
      description: 'Shows upcoming events for the baby',
      schemaParams: {'limit': 5, 'timeframe': 'week'},
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates TileDefinition from valid JSON', () {
        final json = {
          'id': 'tile-def-123',
          'tile_type': 'upcomingEvents',
          'description': 'Shows upcoming events for the baby',
          'schema_params': {'limit': 5, 'timeframe': 'week'},
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileDefinition.fromJson(json);

        expect(result.id, 'tile-def-123');
        expect(result.tileType, TileType.upcomingEvents);
        expect(result.description, 'Shows upcoming events for the baby');
        expect(result.schemaParams, {'limit': 5, 'timeframe': 'week'});
        expect(result.isActive, true);
      });

      test('defaults isActive to true when missing', () {
        final json = {
          'id': 'tile-def-123',
          'tile_type': 'recentPhotos',
          'description': 'Recent photos',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileDefinition.fromJson(json);

        expect(result.isActive, true);
      });

      test('handles null schemaParams', () {
        final json = {
          'id': 'tile-def-123',
          'tile_type': 'notifications',
          'description': 'Notifications tile',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileDefinition.fromJson(json);

        expect(result.schemaParams, null);
      });
    });

    group('toJson', () {
      test('converts TileDefinition to JSON', () {
        final json = tileDefinition.toJson();

        expect(json['id'], 'tile-def-123');
        expect(json['tile_type'], 'upcomingEvents');
        expect(json['description'], 'Shows upcoming events for the baby');
        expect(json['schema_params'], {'limit': 5, 'timeframe': 'week'});
        expect(json['is_active'], true);
      });
    });

    group('validate', () {
      test('returns null for valid tile definition', () {
        expect(tileDefinition.validate(), null);
      });

      test('returns error for empty description', () {
        final invalid = tileDefinition.copyWith(description: '');
        expect(invalid.validate(), 'Description is required');
      });

      test('returns error for whitespace-only description', () {
        final invalid = tileDefinition.copyWith(description: '   ');
        expect(invalid.validate(), 'Description is required');
      });

      test('returns error for description exceeding 255 characters', () {
        final invalid = tileDefinition.copyWith(description: 'a' * 256);
        expect(
          invalid.validate(),
          'Description must be 255 characters or less',
        );
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = tileDefinition.copyWith(
          tileType: TileType.recentPhotos,
          isActive: false,
        );

        expect(updated.id, tileDefinition.id);
        expect(updated.tileType, TileType.recentPhotos);
        expect(updated.isActive, false);
        expect(updated.description, tileDefinition.description);
      });
    });

    group('equality', () {
      test('equal definitions are equal', () {
        final def1 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          createdAt: now,
          updatedAt: now,
        );
        final def2 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          createdAt: now,
          updatedAt: now,
        );

        expect(def1, def2);
        expect(def1.hashCode, def2.hashCode);
      });

      test('different definitions are not equal', () {
        final def1 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          createdAt: now,
          updatedAt: now,
        );
        final def2 = TileDefinition(
          id: 'tile-def-456',
          tileType: TileType.recentPhotos,
          description: 'Recent photos',
          createdAt: now,
          updatedAt: now,
        );

        expect(def1, isNot(def2));
      });

      test('definitions with different schemaParams are not equal', () {
        final def1 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          schemaParams: {'maxItems': 5},
          createdAt: now,
          updatedAt: now,
        );
        final def2 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          schemaParams: {'maxItems': 10},
          createdAt: now,
          updatedAt: now,
        );

        expect(def1, isNot(def2));
      });

      test('definitions with same schemaParams are equal', () {
        final def1 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          schemaParams: {'maxItems': 5, 'sortBy': 'date'},
          createdAt: now,
          updatedAt: now,
        );
        final def2 = TileDefinition(
          id: 'tile-def-123',
          tileType: TileType.upcomingEvents,
          description: 'Upcoming events',
          schemaParams: {'maxItems': 5, 'sortBy': 'date'},
          createdAt: now,
          updatedAt: now,
        );

        expect(def1, def2);
        expect(def1.hashCode, def2.hashCode);
      });
    });
  });
}
