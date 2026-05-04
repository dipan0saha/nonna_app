import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/photo_comment.dart';
import '../../../../core/models/user.dart';

/// UI model for a photo comment with its author information
class PhotoCommentWithAuthor {
  final PhotoComment comment;
  final User author;

  const PhotoCommentWithAuthor({
    required this.comment,
    required this.author,
  });
}

/// State for the photo comments provider
class PhotoCommentsState {
  final List<PhotoCommentWithAuthor> comments;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const PhotoCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  PhotoCommentsState copyWith({
    List<PhotoCommentWithAuthor>? comments,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return PhotoCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Provider for managing comments for photos
///
/// Uses a partitioned state by photoId to isolate data for different photos
class PhotoCommentsNotifier extends Notifier<Map<String, PhotoCommentsState>> {
  @override
  Map<String, PhotoCommentsState> build() {
    return const {};
  }

  PhotoCommentsState stateFor(String photoId) =>
      state[photoId] ?? const PhotoCommentsState();

  Future<void> loadComments(String photoId) async {
    try {
      final currentState = stateFor(photoId);
      state = {
        ...state,
        photoId: currentState.copyWith(isLoading: true, error: null)
      };

      final db = ref.read(databaseServiceProvider);

      final response = await db
          .select(SupabaseTables.photoComments)
          .eq('photo_id', photoId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      final comments = (response as List)
          .map((json) => PhotoComment.fromJson(json))
          .toList();

      final userIds = comments.map((c) => c.userId).toSet().toList();
      final Map<String, User> userById = {};

      if (userIds.isNotEmpty) {
        final profilesResponse = await db
            .select(SupabaseTables.userProfiles)
            .inFilter('user_id', userIds);

        for (final json in profilesResponse as List) {
          final author = User.fromJson(json);
          userById[author.userId] = author;
        }
      }

      final commentsWithAuthors = comments
          .where((comment) => userById.containsKey(comment.userId))
          .map(
            (comment) => PhotoCommentWithAuthor(
              comment: comment,
              author: userById[comment.userId]!,
            ),
          )
          .toList();

      state = {
        ...state,
        photoId: currentState.copyWith(
          comments: commentsWithAuthors,
          isLoading: false,
          isSubmitting: false,
        )
      };
    } catch (e) {
      debugPrint('Error loading comments: $e');
      final currentState = stateFor(photoId);
      state = {
        ...state,
        photoId: currentState.copyWith(
          isLoading: false,
          isSubmitting: false,
          error: 'Failed to load comments',
        )
      };
    }
  }

  Future<bool> addComment({
    required String photoId,
    required String userId,
    required String body,
  }) async {
    if (body.trim().isEmpty) return false;

    try {
      final currentState = stateFor(photoId);
      state = {...state, photoId: currentState.copyWith(isSubmitting: true)};

      final db = ref.read(databaseServiceProvider);
      final commentId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      await db.insert(SupabaseTables.photoComments, {
        'id': commentId,
        'photo_id': photoId,
        'user_id': userId,
        'body': body,
        'created_at': now,
        'updated_at': now,
      });

      await loadComments(photoId);
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      final currentState = stateFor(photoId);
      state = {
        ...state,
        photoId: currentState.copyWith(
          isSubmitting: false,
          error: 'Failed to add comment',
        )
      };
      return false;
    }
  }

  Future<bool> updateComment({
    required String photoId,
    required String commentId,
    required String body,
  }) async {
    if (body.trim().isEmpty) return false;

    try {
      final currentState = stateFor(photoId);
      state = {...state, photoId: currentState.copyWith(isSubmitting: true)};

      final db = ref.read(databaseServiceProvider);
      await db.update(SupabaseTables.photoComments, {
        'body': body,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', commentId);

      await loadComments(photoId);
      return true;
    } catch (e) {
      debugPrint('Error updating comment: $e');
      final currentState = stateFor(photoId);
      state = {
        ...state,
        photoId: currentState.copyWith(
          isSubmitting: false,
          error: 'Failed to update comment',
        )
      };
      return false;
    }
  }

  Future<bool> deleteComment({
    required String photoId,
    required String commentId,
  }) async {
    try {
      final currentState = stateFor(photoId);
      state = {...state, photoId: currentState.copyWith(isLoading: true)};

      final db = ref.read(databaseServiceProvider);

      await db.delete(SupabaseTables.photoComments).eq('id', commentId);

      await loadComments(photoId);
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      final currentState = stateFor(photoId);
      state = {
        ...state,
        photoId: currentState.copyWith(
          isLoading: false,
          error: 'Failed to delete comment',
        )
      };
      return false;
    }
  }
}

/// Provider for managing comments for photos
final photoCommentsProvider =
    NotifierProvider<PhotoCommentsNotifier, Map<String, PhotoCommentsState>>(
  () => PhotoCommentsNotifier(),
);
