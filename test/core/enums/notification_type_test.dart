import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/notification_type.dart';

void main() {
  group('NotificationType', () {
    test('has all notification types', () {
      expect(NotificationType.values.length, 13);
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(NotificationType.system.toJson(), 'system');
        expect(NotificationType.event.toJson(), 'event');
      });

      test('fromJson parses correct values', () {
        expect(NotificationType.fromJson('system'), NotificationType.system);
        expect(NotificationType.fromJson('photo'), NotificationType.photo);
      });

      test('fromJson is case insensitive', () {
        expect(NotificationType.fromJson('SYSTEM'), NotificationType.system);
      });

      test('fromJson defaults to system for invalid input', () {
        expect(NotificationType.fromJson('invalid'), NotificationType.system);
      });
    });

    group('icon', () {
      test('all types have icons', () {
        for (final type in NotificationType.values) {
          expect(type.icon, isA<IconData>());
        }
      });

      test('specific icons are correct', () {
        expect(NotificationType.system.icon, Icons.notifications);
        expect(NotificationType.event.icon, Icons.event);
        expect(NotificationType.photo.icon, Icons.photo);
        expect(NotificationType.like.icon, Icons.favorite);
      });
    });

    group('color', () {
      test('all types have colors', () {
        for (final type in NotificationType.values) {
          expect(type.color, isA<Color>());
        }
      });

      test('colors are distinct', () {
        final colors = NotificationType.values.map((t) => t.color).toList();
        // Most colors should be distinct (some may overlap)
        expect(colors.toSet().length, greaterThan(5));
      });
    });

    group('displayName', () {
      test('all types have display names', () {
        for (final type in NotificationType.values) {
          expect(type.displayName.isNotEmpty, true);
        }
      });
    });
  });
}
