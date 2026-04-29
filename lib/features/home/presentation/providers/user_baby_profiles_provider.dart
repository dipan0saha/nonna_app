import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';

/// Represents a simple baby profile model for the switcher
class BabyProfileSummary {
  final String id;
  final String name;

  String get fullName => name;

  const BabyProfileSummary({
    required this.id,
    required this.name,
  });

  factory BabyProfileSummary.fromJson(Map<String, dynamic> json) {
    return BabyProfileSummary(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// Fetches all baby profiles the current user is a member of.
final userBabyProfilesProvider = FutureProvider.autoDispose<List<BabyProfileSummary>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final databaseService = ref.watch(databaseServiceProvider);
  
  // First get the user's memberships
  final membershipsResponse = await databaseService
      .select(SupabaseTables.babyMemberships)
      .eq('user_id', user.id);
      
  if (membershipsResponse == null) return [];

  final profileIds = (membershipsResponse as List)
      .map((m) => m['baby_profile_id'] as String)
      .toList();

  if (profileIds.isEmpty) return [];

  // Then fetch the profiles
  final profilesResponse = await databaseService
      .select(SupabaseTables.babyProfiles)
      .inFilter('id', profileIds)
      .order('created_at');

  if (profilesResponse == null) return [];

  return (profilesResponse as List)
      .map((json) => BabyProfileSummary.fromJson(json as Map<String, dynamic>))
      .toList();
});
