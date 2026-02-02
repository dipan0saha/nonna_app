import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/screen_name.dart';
import 'package:nonna_app/core/models/screen_config.dart';

void main() {
  group('ScreenConfig', () {
    final now = DateTime.now();
    final screenConfig = ScreenConfig(
      id: 'screen-123',
      screenName: ScreenName.home,
      description: 'Home screen with dynamic tiles',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('creates ScreenConfig from valid JSON', () {
        final json = {
          'id': 'screen-123',
          'screen_name': 'home',
          'description': 'Home screen with dynamic tiles',
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = ScreenConfig.fromJson(json);

        expect(result.id, 'screen-123');
        expect(result.screenName, ScreenName.home);
        expect(result.description, 'Home screen with dynamic tiles');
        expect(result.isActive, true);
      });

      test('defaults isActive to true when missing', () {
        final json = {
          'id': 'screen-123',
          'screen_name': 'calendar',
          'description': 'Calendar screen',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final result = ScreenConfig.fromJson(json);

        expect(result.isActive, true);
      });
    });

    group('toJson', () {
      test('converts ScreenConfig to JSON', () {
        final json = screenConfig.toJson();

        expect(json['id'], 'screen-123');
        expect(json['screen_name'], 'home');
        expect(json['description'], 'Home screen with dynamic tiles');
        expect(json['is_active'], true);
      });
    });

    group('validate', () {
      test('returns null for valid screen config', () {
        expect(screenConfig.validate(), null);
      });

      test('returns error for empty description', () {
        final invalid = screenConfig.copyWith(description: '');
        expect(invalid.validate(), 'Description is required');
      });

      test('returns error for whitespace-only description', () {
        final invalid = screenConfig.copyWith(description: '   ');
        expect(invalid.validate(), 'Description is required');
      });

      test('returns error for description exceeding 255 characters', () {
        final invalid = screenConfig.copyWith(description: 'a' * 256);
        expect(
          invalid.validate(),
          'Description must be 255 characters or less',
        );
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = screenConfig.copyWith(
          screenName: ScreenName.gallery,
          isActive: false,
        );

        expect(updated.id, screenConfig.id);
        expect(updated.screenName, ScreenName.gallery);
        expect(updated.isActive, false);
        expect(updated.description, screenConfig.description);
      });
    });

    group('equality', () {
      test('equal configs are equal', () {
        final config1 = ScreenConfig(
          id: 'screen-123',
          screenName: ScreenName.home,
          description: 'Home screen',
          createdAt: now,
          updatedAt: now,
        );
        final config2 = ScreenConfig(
          id: 'screen-123',
          screenName: ScreenName.home,
          description: 'Home screen',
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, config2);
        expect(config1.hashCode, config2.hashCode);
      });

      test('different configs are not equal', () {
        final config1 = ScreenConfig(
          id: 'screen-123',
          screenName: ScreenName.home,
          description: 'Home screen',
          createdAt: now,
          updatedAt: now,
        );
        final config2 = ScreenConfig(
          id: 'screen-456',
          screenName: ScreenName.gallery,
          description: 'Gallery screen',
          createdAt: now,
          updatedAt: now,
        );

        expect(config1, isNot(config2));
      });
    });
  });
}
