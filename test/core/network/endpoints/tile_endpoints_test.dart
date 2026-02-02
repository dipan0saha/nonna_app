import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/tile_endpoints.dart';

void main() {
  group('TileEndpoints', () {
    const testBabyProfileId = 'baby-123';
    const testTileConfigId = 'tile-456';
    const testScreenName = 'home';
    const testTileType = 'upcoming_events';

    group('tile configuration endpoints', () {
      test('generates correct getTileConfigs endpoint', () {
        final endpoint = TileEndpoints.getTileConfigs(testBabyProfileId);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getTileConfig endpoint', () {
        final endpoint = TileEndpoints.getTileConfig(testTileConfigId);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('id=eq.$testTileConfigId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct createTileConfig endpoint', () {
        final endpoint = TileEndpoints.createTileConfig();
        
        expect(endpoint, 'tile_configs');
      });

      test('generates correct updateTileConfig endpoint', () {
        final endpoint = TileEndpoints.updateTileConfig(testTileConfigId);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('id=eq.$testTileConfigId'));
      });

      test('generates correct deleteTileConfig endpoint', () {
        final endpoint = TileEndpoints.deleteTileConfig(testTileConfigId);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('id=eq.$testTileConfigId'));
      });
    });

    group('screen configuration endpoints', () {
      test('generates correct getScreenConfigs endpoint', () {
        final endpoint = TileEndpoints.getScreenConfigs(testBabyProfileId);
        
        expect(endpoint, contains('screen_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct getScreenConfig endpoint', () {
        final endpoint = TileEndpoints.getScreenConfig(testBabyProfileId, testScreenName);
        
        expect(endpoint, contains('screen_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('screen_name=eq.$testScreenName'));
        expect(endpoint, contains('select=*'));
      });

      test('generates correct createScreenConfig endpoint', () {
        final endpoint = TileEndpoints.createScreenConfig();
        
        expect(endpoint, 'screen_configs');
      });

      test('generates correct updateScreenConfig endpoint', () {
        final endpoint = TileEndpoints.updateScreenConfig('screen-config-123');
        
        expect(endpoint, contains('screen_configs'));
        expect(endpoint, contains('id=eq.screen-config-123'));
      });
    });

    group('tile data queries', () {
      test('generates correct getTilesByScreen endpoint', () {
        final endpoint = TileEndpoints.getTilesByScreen(testBabyProfileId, testScreenName);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('screen_name=eq.$testScreenName'));
        expect(endpoint, contains('order=position.asc'));
      });

      test('generates correct getVisibleTiles endpoint', () {
        final endpoint = TileEndpoints.getVisibleTiles(testBabyProfileId, testScreenName);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('screen_name=eq.$testScreenName'));
        expect(endpoint, contains('is_visible=eq.true'));
        expect(endpoint, contains('order=position.asc'));
      });

      test('generates correct getTilesByType endpoint', () {
        final endpoint = TileEndpoints.getTilesByType(testBabyProfileId, testTileType);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(endpoint, contains('tile_type=eq.$testTileType'));
      });

      test('generates correct reorderTiles endpoint', () {
        final endpoint = TileEndpoints.reorderTiles();
        
        expect(endpoint, 'tile_configs');
      });

      test('generates correct toggleTileVisibility endpoint', () {
        final endpoint = TileEndpoints.toggleTileVisibility(testTileConfigId);
        
        expect(endpoint, contains('tile_configs'));
        expect(endpoint, contains('id=eq.$testTileConfigId'));
      });
    });

    group('helper methods', () {
      test('buildQuery adds filters to base query', () {
        const baseQuery = 'tile_configs?select=*';
        final filters = {
          'baby_profile_id': testBabyProfileId,
          'screen_name': testScreenName,
        };
        
        final query = TileEndpoints.buildQuery(baseQuery, filters);
        
        expect(query, contains('baby_profile_id=eq.$testBabyProfileId'));
        expect(query, contains('screen_name=eq.$testScreenName'));
      });

      test('buildQuery returns base query when no filters', () {
        const baseQuery = 'tile_configs?select=*';
        
        final query = TileEndpoints.buildQuery(baseQuery, {});
        
        expect(query, baseQuery);
      });

      test('buildSelectQuery creates correct query', () {
        final query = TileEndpoints.buildSelectQuery(
          'tile_configs',
          ['id', 'tile_type', 'position'],
          filters: {'baby_profile_id': testBabyProfileId},
        );
        
        expect(query, contains('tile_configs'));
        expect(query, contains('select=id,tile_type,position'));
        expect(query, contains('baby_profile_id=eq.$testBabyProfileId'));
      });

      test('buildSelectQuery uses * when columns empty', () {
        final query = TileEndpoints.buildSelectQuery(
          'tile_configs',
          [],
        );
        
        expect(query, contains('select=*'));
      });
    });
  });
}
