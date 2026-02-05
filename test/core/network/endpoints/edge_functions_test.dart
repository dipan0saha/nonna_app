import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/network/endpoints/edge_functions.dart';

void main() {
  group('EdgeFunctions', () {
    group('function paths', () {
      test('has correct tile config function path', () {
        expect(EdgeFunctions.tileConfigFunction, '/functions/v1/tile-configs');
      });

      test('has correct notification trigger function path', () {
        expect(EdgeFunctions.notificationTriggerFunction,
            '/functions/v1/notification-trigger');
      });

      test('has correct image processing function path', () {
        expect(EdgeFunctions.imageProcessingFunction,
            '/functions/v1/image-processing');
      });

      test('has correct analytics function path', () {
        expect(EdgeFunctions.analyticsFunction, '/functions/v1/analytics');
      });

      test('has correct data export function path', () {
        expect(EdgeFunctions.dataExportFunction, '/functions/v1/data-export');
      });

      test('has correct webhook function path', () {
        expect(EdgeFunctions.webhookFunction, '/functions/v1/webhook');
      });
    });

    group('tile config function payloads', () {
      test('creates correct getTileConfigsPayload', () {
        final payload = EdgeFunctions.getTileConfigsPayload(
          babyProfileId: 'baby-123',
          screenName: 'home',
        );

        expect(payload['action'], 'get_configs');
        expect(payload['baby_profile_id'], 'baby-123');
        expect(payload['screen_name'], 'home');
      });

      test('creates getTileConfigsPayload without screen name', () {
        final payload = EdgeFunctions.getTileConfigsPayload(
          babyProfileId: 'baby-123',
        );

        expect(payload['action'], 'get_configs');
        expect(payload['baby_profile_id'], 'baby-123');
        expect(payload.containsKey('screen_name'), false);
      });

      test('creates correct updateTileOrderPayload', () {
        final payload = EdgeFunctions.updateTileOrderPayload(
          babyProfileId: 'baby-123',
          screenName: 'home',
          tileOrders: ['tile-1', 'tile-2', 'tile-3'],
        );

        expect(payload['action'], 'update_order');
        expect(payload['baby_profile_id'], 'baby-123');
        expect(payload['screen_name'], 'home');
        expect(payload['tile_orders'], ['tile-1', 'tile-2', 'tile-3']);
      });

      test('creates correct resetTileConfigsPayload', () {
        final payload = EdgeFunctions.resetTileConfigsPayload(
          babyProfileId: 'baby-123',
          screenName: 'home',
        );

        expect(payload['action'], 'reset_configs');
        expect(payload['baby_profile_id'], 'baby-123');
        expect(payload['screen_name'], 'home');
      });
    });

    group('notification function payloads', () {
      test('creates correct sendNotificationPayload', () {
        final payload = EdgeFunctions.sendNotificationPayload(
          recipientId: 'user-123',
          type: 'new_event',
          data: {'event_id': 'event-456'},
        );

        expect(payload['action'], 'send');
        expect(payload['recipient_id'], 'user-123');
        expect(payload['type'], 'new_event');
        expect(payload['data'], {'event_id': 'event-456'});
      });

      test('creates sendNotificationPayload without data', () {
        final payload = EdgeFunctions.sendNotificationPayload(
          recipientId: 'user-123',
          type: 'reminder',
        );

        expect(payload['action'], 'send');
        expect(payload['recipient_id'], 'user-123');
        expect(payload['type'], 'reminder');
        expect(payload.containsKey('data'), false);
      });

      test('creates correct sendBulkNotificationsPayload', () {
        final payload = EdgeFunctions.sendBulkNotificationsPayload(
          recipientIds: ['user-1', 'user-2', 'user-3'],
          type: 'announcement',
          data: {'message': 'Test'},
        );

        expect(payload['action'], 'send_bulk');
        expect(payload['recipient_ids'], ['user-1', 'user-2', 'user-3']);
        expect(payload['type'], 'announcement');
        expect(payload['data'], {'message': 'Test'});
      });
    });

    group('image processing function payloads', () {
      test('creates correct processImagePayload', () {
        final payload = EdgeFunctions.processImagePayload(
          imageUrl: 'https://example.com/image.jpg',
          operations: ['resize', 'compress'],
          options: {'quality': 80},
        );

        expect(payload['action'], 'process');
        expect(payload['image_url'], 'https://example.com/image.jpg');
        expect(payload['operations'], ['resize', 'compress']);
        expect(payload['options'], {'quality': 80});
      });

      test('creates correct generateThumbnailPayload', () {
        final payload = EdgeFunctions.generateThumbnailPayload(
          imageUrl: 'https://example.com/image.jpg',
          width: 150,
          height: 150,
        );

        expect(payload['action'], 'thumbnail');
        expect(payload['image_url'], 'https://example.com/image.jpg');
        expect(payload['width'], 150);
        expect(payload['height'], 150);
      });

      test('creates generateThumbnailPayload with default dimensions', () {
        final payload = EdgeFunctions.generateThumbnailPayload(
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(payload['width'], 200);
        expect(payload['height'], 200);
      });

      test('creates correct compressImagePayload', () {
        final payload = EdgeFunctions.compressImagePayload(
          imageUrl: 'https://example.com/image.jpg',
          quality: 70,
        );

        expect(payload['action'], 'compress');
        expect(payload['image_url'], 'https://example.com/image.jpg');
        expect(payload['quality'], 70);
      });
    });

    group('analytics function payloads', () {
      test('creates correct trackEventPayload', () {
        final payload = EdgeFunctions.trackEventPayload(
          userId: 'user-123',
          eventName: 'photo_uploaded',
          properties: {'photo_count': 5},
        );

        expect(payload['action'], 'track');
        expect(payload['user_id'], 'user-123');
        expect(payload['event_name'], 'photo_uploaded');
        expect(payload['properties'], {'photo_count': 5});
      });

      test('creates correct getUserAnalyticsPayload', () {
        final payload = EdgeFunctions.getUserAnalyticsPayload(
          userId: 'user-123',
          startDate: '2024-01-01',
          endDate: '2024-01-31',
        );

        expect(payload['action'], 'get_analytics');
        expect(payload['user_id'], 'user-123');
        expect(payload['start_date'], '2024-01-01');
        expect(payload['end_date'], '2024-01-31');
      });
    });

    group('data export function payloads', () {
      test('creates correct exportDataPayload', () {
        final payload = EdgeFunctions.exportDataPayload(
          userId: 'user-123',
          babyProfileId: 'baby-456',
          format: 'csv',
        );

        expect(payload['action'], 'export');
        expect(payload['user_id'], 'user-123');
        expect(payload['baby_profile_id'], 'baby-456');
        expect(payload['format'], 'csv');
      });

      test('creates exportDataPayload with default format', () {
        final payload = EdgeFunctions.exportDataPayload(
          userId: 'user-123',
        );

        expect(payload['format'], 'json');
      });
    });

    group('helper methods', () {
      test('getFunctionUrl builds correct URL', () {
        final url = EdgeFunctions.getFunctionUrl(
          'https://project.supabase.co',
          '/functions/v1/test',
        );

        expect(url, 'https://project.supabase.co/functions/v1/test');
      });

      test('buildInvocationHeaders creates correct headers', () {
        final headers = EdgeFunctions.buildInvocationHeaders(
          apiKey: 'test-api-key',
          accessToken: 'test-access-token',
        );

        expect(headers['Content-Type'], 'application/json');
        expect(headers['apikey'], 'test-api-key');
        expect(headers['Authorization'], 'Bearer test-access-token');
      });

      test('buildInvocationHeaders without access token', () {
        final headers = EdgeFunctions.buildInvocationHeaders(
          apiKey: 'test-api-key',
        );

        expect(headers['Content-Type'], 'application/json');
        expect(headers['apikey'], 'test-api-key');
        expect(headers.containsKey('Authorization'), false);
      });
    });
  });
}
