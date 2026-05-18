import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/models/photo.dart';
import '../../../../core/models/user.dart';
import '../../../../tiles/gallery_favorites/providers/gallery_favorites_provider.dart';
import '../../../../tiles/recent_photos/providers/recent_photos_provider.dart';
import 'gallery_screen_provider.dart';

class PhotoDetailState {
  final int squishCount;
  final bool isSquished;
  final String? squishId;
  final bool isLoading;
  final bool isSavingCaption;
  final bool isOwner;
  final String? error;

  const PhotoDetailState({
    this.squishCount = 0,
    this.isSquished = false,
    this.squishId,
    this.isLoading = false,
    this.isSavingCaption = false,
    this.isOwner = false,
    this.error,
  });

  PhotoDetailState copyWith({
    int? squishCount,
    bool? isSquished,
    String? squishId,
    bool? isLoading,
    bool? isSavingCaption,
    bool? isOwner,
    String? error,
  }) {
    return PhotoDetailState(
      squishCount: squishCount ?? this.squishCount,
      isSquished: isSquished ?? this.isSquished,
      squishId: squishId ?? this.squishId,
      isLoading: isLoading ?? this.isLoading,
      isSavingCaption: isSavingCaption ?? this.isSavingCaption,
      isOwner: isOwner ?? this.isOwner,
      error: error,
    );
  }
}

class PhotoDetailNotifier extends Notifier<PhotoDetailState> {
  @override
  PhotoDetailState build() => const PhotoDetailState();

  Future<void> initialize({
    required Photo photo,
    required String? userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);

      final countResponse = await db
          .select(SupabaseTables.photoSquishes, columns: 'id')
          .eq('photo_id', photo.id);
      if (!ref.mounted) return;

      final squishCount = (countResponse as List).length;

      bool isSquished = false;
      String? squishId;
      if (userId != null) {
        final userSquish = await db
            .select(SupabaseTables.photoSquishes, columns: 'id')
            .eq('photo_id', photo.id)
            .eq('user_id', userId)
            .maybeSingle();
        if (!ref.mounted) return;

        if (userSquish != null) {
          isSquished = true;
          squishId = userSquish['id'] as String;
        }
      }

      bool isOwner = false;
      if (userId != null) {
        final ownerMembership = await db
            .select(SupabaseTables.babyMemberships, columns: 'id')
            .eq('user_id', userId)
            .eq('baby_profile_id', photo.babyProfileId)
            .eq('role', 'owner')
            .isFilter('removed_at', null)
            .maybeSingle();
        if (!ref.mounted) return;

        isOwner = ownerMembership != null;
      }

      state = state.copyWith(
        squishCount: squishCount,
        isSquished: isSquished,
        squishId: squishId,
        isOwner: isOwner,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Failed to initialize photo detail state: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load photo details',
      );
    }
  }

  Future<bool> toggleSquish({
    required Photo photo,
    required String? userId,
  }) async {
    if (userId == null) {
      state = state.copyWith(error: 'Please log in to respond.');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);
      if (state.isSquished && state.squishId != null) {
        await db.delete(SupabaseTables.photoSquishes).eq('id', state.squishId!);
        if (!ref.mounted) return false;

        state = state.copyWith(
          isSquished: false,
          squishCount: state.squishCount > 0 ? state.squishCount - 1 : 0,
          squishId: null,
          isLoading: false,
        );
      } else {
        final responseList = await db.insert(SupabaseTables.photoSquishes, {
          'photo_id': photo.id,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        if (!ref.mounted) return false;

        state = state.copyWith(
          isSquished: true,
          squishCount: state.squishCount + 1,
          squishId: responseList.isNotEmpty
              ? responseList.first['id'] as String
              : state.squishId,
          isLoading: false,
        );
      }

      await _refreshRelatedTiles(photo.babyProfileId);
      return true;
    } catch (e) {
      debugPrint('Failed to toggle squish: $e');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update favorite. Please try again.',
      );
      return false;
    }
  }

  Future<bool> updateCaption({
    required Photo photo,
    required String caption,
  }) async {
    try {
      state = state.copyWith(isSavingCaption: true, error: null);

      await ref.read(databaseServiceProvider).update(SupabaseTables.photos, {
        'caption': caption,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', photo.id);
      if (!ref.mounted) return false;

      state = state.copyWith(isSavingCaption: false);
      await _refreshRelatedTiles(photo.babyProfileId);
      return true;
    } catch (e) {
      debugPrint('Failed to update caption: $e');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSavingCaption: false,
        error: 'Failed to update caption.',
      );
      return false;
    }
  }

  Future<bool> deletePhoto({required Photo photo}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final db = ref.read(databaseServiceProvider);
      final storage = ref.read(storageServiceProvider);

      await db.delete(SupabaseTables.photos).eq('id', photo.id);

      try {
        await storage.deleteFile('gallery-photos', photo.storagePath);
        if (photo.thumbnailPath != null) {
          await storage.deleteFile('gallery-photos', photo.thumbnailPath!);
        }
      } catch (e) {
        debugPrint('Warning: Failed to delete files from storage: $e');
      }

      await _refreshRelatedTiles(photo.babyProfileId);
      return true;
    } catch (e) {
      debugPrint('Failed to delete photo: $e');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete photo.',
      );
      return false;
    }
  }

  /// Fetch the list of users who squished a photo, newest first.
  Future<List<User>> fetchSquishUsers({required String photoId}) async {
    final db = ref.read(databaseServiceProvider);

    final squishesResponse = await db
        .select(
          SupabaseTables.photoSquishes,
          columns: 'user_id, created_at',
        )
        .eq('photo_id', photoId)
        .order('created_at', ascending: false);

    final userIds = <String>[];
    for (final json in (squishesResponse as List)) {
      final userId = json['user_id'] as String?;
      if (userId != null && !userIds.contains(userId)) {
        userIds.add(userId);
      }
    }

    if (userIds.isEmpty) return const [];

    final profilesResponse = await db
        .select(SupabaseTables.userProfiles)
        .inFilter('user_id', userIds);

    final profileById = <String, User>{};
    for (final json in (profilesResponse as List)) {
      final user = User.fromJson(Map<String, dynamic>.from(json as Map));
      profileById[user.userId] = user;
    }

    return userIds
        .where((id) => profileById.containsKey(id))
        .map((id) => profileById[id]!)
        .toList();
  }

  Future<void> refreshRelatedTilesForComments(String babyProfileId) async {
    await _refreshRelatedTiles(babyProfileId);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  Future<void> _refreshRelatedTiles(String babyProfileId) async {
    ref
        .read(galleryFavoritesProvider.notifier)
        .refresh(babyProfileId: babyProfileId);
    ref
        .read(recentPhotosProvider.notifier)
        .refresh(babyProfileId: babyProfileId);
    await ref.read(galleryScreenProvider.notifier).refresh('gallery');
    await ref.read(galleryScreenProvider.notifier).refresh('gallery_recent');
    await ref.read(galleryScreenProvider.notifier).refresh('gallery_favorites');
  }
}

final photoDetailProvider =
    NotifierProvider.autoDispose<PhotoDetailNotifier, PhotoDetailState>(
  PhotoDetailNotifier.new,
);
