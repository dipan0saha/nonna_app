import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/event_status.dart';

void main() {
  group('EventStatus', () {
    test('has all status types', () {
      expect(EventStatus.values.length, 5);
      expect(EventStatus.values, contains(EventStatus.scheduled));
      expect(EventStatus.values, contains(EventStatus.ongoing));
      expect(EventStatus.values, contains(EventStatus.completed));
      expect(EventStatus.values, contains(EventStatus.cancelled));
      expect(EventStatus.values, contains(EventStatus.draft));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(EventStatus.scheduled.toJson(), 'scheduled');
        expect(EventStatus.completed.toJson(), 'completed');
      });

      test('fromJson parses correct values', () {
        expect(EventStatus.fromJson('scheduled'), EventStatus.scheduled);
        expect(EventStatus.fromJson('ongoing'), EventStatus.ongoing);
      });

      test('fromJson is case insensitive', () {
        expect(EventStatus.fromJson('SCHEDULED'), EventStatus.scheduled);
      });

      test('fromJson defaults to scheduled for invalid input', () {
        expect(EventStatus.fromJson('invalid'), EventStatus.scheduled);
      });
    });

    group('color', () {
      test('all statuses have colors', () {
        for (final status in EventStatus.values) {
          expect(status.color, isA<Color>());
        }
      });

      test('specific colors are correct', () {
        expect(EventStatus.scheduled.color, Colors.blue);
        expect(EventStatus.ongoing.color, Colors.green);
        expect(EventStatus.completed.color, Colors.grey);
        expect(EventStatus.cancelled.color, Colors.red);
      });
    });

    group('displayName', () {
      test('returns user-friendly names', () {
        expect(EventStatus.scheduled.displayName, 'Scheduled');
        expect(EventStatus.ongoing.displayName, 'Ongoing');
        expect(EventStatus.completed.displayName, 'Completed');
      });
    });

    group('status checks', () {
      test('isActive identifies active statuses', () {
        expect(EventStatus.scheduled.isActive, true);
        expect(EventStatus.ongoing.isActive, true);
        expect(EventStatus.completed.isActive, false);
        expect(EventStatus.cancelled.isActive, false);
        expect(EventStatus.draft.isActive, false);
      });

      test('isFinished identifies finished statuses', () {
        expect(EventStatus.scheduled.isFinished, false);
        expect(EventStatus.ongoing.isFinished, false);
        expect(EventStatus.completed.isFinished, true);
        expect(EventStatus.cancelled.isFinished, true);
        expect(EventStatus.draft.isFinished, false);
      });
    });
  });
}
