import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';

void main() {
  group('TileConfig', () {
    final now = DateTime.now();
    final tileConfig = TileConfig(
      id: 'config-123',
      screenId: 'screen-456',
      tileDefinitionId: 'tile-def-789',
      role: UserRole.owner,
      displayOrder: 1,
      isVisible: true,
      params: {'key': 'value'},
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates TileConfig from valid JSON', () {
        final json = {
          'id': 'config-123',
          'screen_id': 'screen-456',
          'tile_definition_id': 'tile-def-789',
          'role': 'owner',
          'display_order': 1,
          'is_visible': true,
          'params': {'key': 'value'},
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileConfig.fromJson(json);

        expect(result.id, 'config-123');
        expect(result.screenId, 'screen-456');
        expect(result.tileDefinitionId, 'tile-def-789');
        expect(result.role, UserRole.owner);
        expect(result.displayOrder, 1);
        expect(result.isVisible, true);
        expect(result.params, {'key': 'value'});
      });

      test('defaults isVisible to true when missing', () {
        final json = {
          'id': 'config-123',
          'screen_id': 'screen-456',
          'tile_definition_id': 'tile-def-789',
          'role': 'follower',
          'display_order': 0,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileConfig.fromJson(json);

        expect(result.isVisible, true);
      });

      test('handles null params', () {
        final json = {
          'id': 'config-123',
          'screen_id': 'screen-456',
          'tile_definition_id': 'tile-def-789',
          'role': 'owner',
          'display_order': 1,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = TileConfig.fromJson(json);

        expect(result.params, null);
      });
    });

    group('toJson', () {
      test('converts TileConfig to JSON', () {
        final json = tileConfig.toJson();

        expect(json['id'], 'config-123');
        expect(json['screen_id'], 'screen-456');
        expect(json['tile_definition_id'], 'tile-def-789');
        expect(json['role'], 'owner');
        expect(json['display_order'], 1);
        expect(json['is_visible'], true);
        expect(json['params'], {'key': 'value'});
      });
    });

    group('validate', () {
      test('returns null for valid tile config', () {
        expect(tileConfig.validate(), null);
      });

      test('returns error for negative display order', () {
        final invalid = tileConfig.copyWith(displayOrder: -1);
        expect(invalid.validate(), 'Display order must be 0 or greater');
      });

      test('allows displayOrder of 0', () {
        final valid = tileConfig.copyWith(displayOrder: 0);
        expect(valid.validate(), null);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = tileConfig.copyWith(
          displayOrder: 5,
          isVisible: false,
        );

        expect(updated.id, tileConfig.id);
        expect(updated.displayOrder, 5);
        expect(updated.isVisible, false);
        expect(updated.role, tileConfig.role);
      });
    });

    group('equality', () {
      test('equal configs are equal', () {
        final config1 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          createdAt: now,
          updatedAt: now,
        );
        final config2 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, config2);
        expect(config1.hashCode, config2.hashCode);
      });

      test('different configs are not equal', () {
        final config1 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          createdAt: now,
          updatedAt: now,
        );
        final config2 = TileConfig(
          id: 'config-456',
          screenId: 'screen-789',
          tileDefinitionId: 'tile-def-999',
          role: UserRole.follower,
          displayOrder: 2,
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, isNot(config2));
      });

      test('configs with different params are not equal', () {
        final config1 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          params: {'key': 'value1'},
          createdAt: now,
          updatedAt: now,
        );
        final config2 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          params: {'key': 'value2'},
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, isNot(config2));
      });

      test('configs with same params are equal', () {
        final config1 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          params: {'key': 'value', 'count': '5'},
          createdAt: now,
          updatedAt: now,
        );
        final config2 = TileConfig(
          id: 'config-123',
          screenId: 'screen-456',
          tileDefinitionId: 'tile-def-789',
          role: UserRole.owner,
          displayOrder: 1,
          params: {'key': 'value', 'count': '5'},
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, config2);
        expect(config1.hashCode, config2.hashCode);
      });
    });
  });
}
