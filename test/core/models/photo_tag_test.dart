import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/photo_tag.dart';

void main() {
  group('PhotoTag', () {
    final now = DateTime.now();
    final tag = PhotoTag(
      id: 'tag-123',
      photoId: 'photo-456',
      tag: 'milestone',
      createdAt: now,
    );

    group('fromJson', () {
      test('creates PhotoTag from valid JSON', () {
        final json = {
          'id': 'tag-123',
          'photo_id': 'photo-456',
          'tag': 'milestone',
          'created_at': now.toIso8601String(),
        };

        final result = PhotoTag.fromJson(json);

        expect(result.id, 'tag-123');
        expect(result.photoId, 'photo-456');
        expect(result.tag, 'milestone');
        expect(result.createdAt, now);
      });
    });

    group('toJson', () {
      test('converts PhotoTag to JSON', () {
        final json = tag.toJson();

        expect(json['id'], 'tag-123');
        expect(json['photo_id'], 'photo-456');
        expect(json['tag'], 'milestone');
        expect(json['created_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid tag', () {
        expect(tag.validate(), null);
      });

      test('returns error for empty tag', () {
        final invalidTag = tag.copyWith(tag: '');
        expect(invalidTag.validate(), 'Tag cannot be empty');
      });

      test('returns error for whitespace-only tag', () {
        final invalidTag = tag.copyWith(tag: '   ');
        expect(invalidTag.validate(), 'Tag cannot be empty');
      });

      test('returns error for tag exceeding 50 characters', () {
        final invalidTag = tag.copyWith(tag: 'a' * 51);
        expect(
          invalidTag.validate(),
          'Tag must be 50 characters or less',
        );
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final updated = tag.copyWith(
          tag: 'happy',
        );

        expect(updated.id, tag.id);
        expect(updated.photoId, tag.photoId);
        expect(updated.tag, 'happy');
        expect(updated.createdAt, tag.createdAt);
      });

      test('maintains original values when no updates provided', () {
        final copy = tag.copyWith();
        expect(copy, tag);
      });
    });

    group('equality', () {
      test('equal tags are equal', () {
        final tag1 = PhotoTag(
          id: 'tag-123',
          photoId: 'photo-456',
          tag: 'milestone',
          createdAt: now,
        );
        final tag2 = PhotoTag(
          id: 'tag-123',
          photoId: 'photo-456',
          tag: 'milestone',
          createdAt: now,
        );

        expect(tag1, tag2);
        expect(tag1.hashCode, tag2.hashCode);
      });

      test('different tags are not equal', () {
        final tag1 = PhotoTag(
          id: 'tag-123',
          photoId: 'photo-456',
          tag: 'milestone',
          createdAt: now,
        );
        final tag2 = PhotoTag(
          id: 'tag-456',
          photoId: 'photo-789',
          tag: 'happy',
          createdAt: now,
        );

        expect(tag1, isNot(tag2));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = tag.toString();

        expect(str, contains('PhotoTag'));
        expect(str, contains('tag-123'));
        expect(str, contains('photo-456'));
        expect(str, contains('milestone'));
      });
    });
  });
}
