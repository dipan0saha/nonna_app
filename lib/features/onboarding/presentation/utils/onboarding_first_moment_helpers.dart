import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nonna_app/core/constants/first_moment_presets.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/storage_service.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:uuid/uuid.dart';

/// Local name suggestion before persist.
class FirstMomentNameDraft {
  const FirstMomentNameDraft({required this.name, required this.gender});

  final String name;
  final Gender gender;
}

/// Result of batch First Moment persist.
class FirstMomentPersistResult {
  const FirstMomentPersistResult({this.error});

  final String? error;

  bool get success => error == null;
}

DateTime firstMomentAnchorDate({
  required BabyStatus status,
  DateTime? expectedBirthDate,
  DateTime? actualBirthDate,
}) {
  if (status == BabyStatus.born) {
    return actualBirthDate ?? DateTime.now();
  }
  return expectedBirthDate ?? DateTime.now().add(const Duration(days: 90));
}

DateTime eventStartsAt(DateTime anchor, int dayOffset) {
  final local = DateTime(
    anchor.year,
    anchor.month,
    anchor.day,
    12,
  ).add(Duration(days: dayOffset));
  return local.toUtc();
}

/// Persists selected First Moment content (names, events, registry, optional photo).
Future<FirstMomentPersistResult> persistFirstMomentContent({
  required DatabaseService database,
  required StorageService storage,
  required String babyProfileId,
  required String userId,
  required BabyStatus babyStatus,
  DateTime? expectedBirthDate,
  DateTime? actualBirthDate,
  List<FirstMomentNameDraft> nameDrafts = const [],
  Set<String> selectedEventIds = const {},
  Set<String> selectedRegistryIds = const {},
  XFile? photoFile,
}) async {
  try {
    final anchor = firstMomentAnchorDate(
      status: babyStatus,
      expectedBirthDate: expectedBirthDate,
      actualBirthDate: actualBirthDate,
    );

    if (babyStatus == BabyStatus.expecting) {
      for (final draft in nameDrafts) {
        await database.insert(SupabaseTables.nameSuggestions, {
          'baby_profile_id': babyProfileId,
          'user_id': userId,
          'suggested_name': draft.name.trim(),
          'gender': draft.gender.toJson(),
        });
      }
    }

    if (photoFile != null && babyStatus == BabyStatus.born) {
      String storagePath;
      String? thumbnailPath;
      try {
        final uploadResult = await storage.uploadPhotoWithThumbnail(
          imageFile: photoFile,
          babyProfileId: babyProfileId,
        );
        storagePath = uploadResult['photo_path']!;
        thumbnailPath = uploadResult['thumbnail_path'];
      } catch (e) {
        debugPrint('⚠️ Thumbnail upload failed, photo-only fallback: $e');
        storagePath = await storage.uploadGalleryPhoto(
          imageFile: photoFile,
          babyProfileId: babyProfileId,
        );
      }

      await database.insert(SupabaseTables.photos, {
        'baby_profile_id': babyProfileId,
        'uploaded_by_user_id': userId,
        'storage_path': storagePath,
        'thumbnail_path': thumbnailPath,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    final eventPresets = babyStatus == BabyStatus.expecting
        ? FirstMomentPresets.expectingEvents
        : FirstMomentPresets.bornEvents;
    final now = DateTime.now();
    for (final preset in eventPresets) {
      if (!selectedEventIds.contains(preset.id)) continue;
      await database.insert(SupabaseTables.events, {
        'baby_profile_id': babyProfileId,
        'created_by_user_id': userId,
        'title': preset.label,
        'starts_at': eventStartsAt(anchor, preset.dayOffset).toIso8601String(),
        'created_at': now.toUtc().toIso8601String(),
        'updated_at': now.toUtc().toIso8601String(),
      });
    }

    final registryPresets = babyStatus == BabyStatus.expecting
        ? FirstMomentPresets.expectingRegistry
        : FirstMomentPresets.bornRegistry;
    for (final preset in registryPresets) {
      if (!selectedRegistryIds.contains(preset.id)) continue;
      final item = RegistryItem(
        id: const Uuid().v4(),
        babyProfileId: babyProfileId,
        createdByUserId: userId,
        name: preset.label,
        priority: 3,
        createdAt: now,
        updatedAt: now,
      );
      await database.insert(SupabaseTables.registryItems, item.toJson());
    }

    return const FirstMomentPersistResult();
  } catch (e) {
    return FirstMomentPersistResult(error: e.toString());
  }
}

bool canSelectMoreEvents(Set<String> selected) =>
    selected.length < FirstMomentPresets.maxSelectableEvents;
