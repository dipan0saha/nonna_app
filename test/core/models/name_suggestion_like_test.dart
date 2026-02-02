import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/name_suggestion_like.dart';

void main() {
  group('NameSuggestionLike', () {
    final now = DateTime.now();
    final like = NameSuggestionLike(
      id: 'like-123',
      nameSuggestionId: 'suggestion-123',
      userId: 'user-123',
      createdAt: now,
    );

    group('fromJson', () {
      test('creates NameSuggestionLike from valid JSON', () {
        final json = {
          'id': 'like-123',
          'name_suggestion_id': 'suggestion-123',
          'user_id': 'user-123',
          'created_at': now.toIso8601String(),
        };

        final result = NameSuggestionLike.fromJson(json);

        expect(result.id, 'like-123');
        expect(result.nameSuggestionId, 'suggestion-123');
        expect(result.userId, 'user-123');
        expect(result.createdAt, now);
      });
    });

    group('toJson', () {
      test('converts NameSuggestionLike to JSON', () {
        final json = like.toJson();

        expect(json['id'], 'like-123');
        expect(json['name_suggestion_id'], 'suggestion-123');
        expect(json['user_id'], 'user-123');
        expect(json['created_at'], now.toIso8601String());
      });
    });

    group('validate', () {
      test('returns null for valid like', () {
        expect(like.validate(), null);
      });

      test('returns error for empty name suggestion ID', () {
        final invalid = like.copyWith(nameSuggestionId: '');
        expect(invalid.validate(), 'Name suggestion ID is required');
      });

      test('returns error for whitespace-only name suggestion ID', () {
        final invalid = like.copyWith(nameSuggestionId: '   ');
        expect(invalid.validate(), 'Name suggestion ID is required');
      });

      test('returns error for empty user ID', () {
        final invalid = like.copyWith(userId: '');
        expect(invalid.validate(), 'User ID is required');
      });

      test('returns error for whitespace-only user ID', () {
        final invalid = like.copyWith(userId: '   ');
        expect(invalid.validate(), 'User ID is required');
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final copy = like.copyWith(
          userId: 'user-456',
        );

        expect(copy.id, like.id);
        expect(copy.userId, 'user-456');
        expect(copy.nameSuggestionId, like.nameSuggestionId);
      });
    });

    group('equality', () {
      test('two likes with same values are equal', () {
        final like1 = NameSuggestionLike(
          id: 'like-123',
          nameSuggestionId: 'suggestion-123',
          userId: 'user-123',
          createdAt: now,
        );

        final like2 = NameSuggestionLike(
          id: 'like-123',
          nameSuggestionId: 'suggestion-123',
          userId: 'user-123',
          createdAt: now,
        );

        expect(like1, equals(like2));
        expect(like1.hashCode, equals(like2.hashCode));
      });

      test('two likes with different values are not equal', () {
        final like1 = like;
        final like2 = like.copyWith(userId: 'user-456');

        expect(like1, isNot(equals(like2)));
      });
    });

    group('toString', () {
      test('returns string representation', () {
        final str = like.toString();

        expect(str, contains('NameSuggestionLike'));
        expect(str, contains('like-123'));
        expect(str, contains('suggestion-123'));
        expect(str, contains('user-123'));
      });
    });
  });
}
