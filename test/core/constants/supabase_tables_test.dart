import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';

void main() {
  group('SupabaseTables', () {
    group('table names', () {
      test('has user-related tables', () {
        expect(SupabaseTables.users, 'users');
        expect(SupabaseTables.userProfiles, 'user_profiles');
        expect(SupabaseTables.userStats, 'user_stats');
      });

      test('has baby profile tables', () {
        expect(SupabaseTables.babyProfiles, 'baby_profiles');
        expect(SupabaseTables.babyMemberships, 'baby_memberships');
        expect(SupabaseTables.invitations, 'invitations');
      });

      test('has calendar tables', () {
        expect(SupabaseTables.events, 'events');
        expect(SupabaseTables.eventRsvps, 'event_rsvps');
        expect(SupabaseTables.eventComments, 'event_comments');
      });

      test('has photo gallery tables', () {
        expect(SupabaseTables.photos, 'photos');
        expect(SupabaseTables.photoComments, 'photo_comments');
        expect(SupabaseTables.photoTags, 'photo_tags');
      });

      test('has registry tables', () {
        expect(SupabaseTables.registryItems, 'registry_items');
        expect(SupabaseTables.registryPurchases, 'registry_purchases');
      });
    });

    group('common column names', () {
      test('has primary keys', () {
        expect(SupabaseTables.id, 'id');
        expect(SupabaseTables.userId, 'user_id');
        expect(SupabaseTables.babyProfileId, 'baby_profile_id');
      });

      test('has timestamps', () {
        expect(SupabaseTables.createdAt, 'created_at');
        expect(SupabaseTables.updatedAt, 'updated_at');
        expect(SupabaseTables.deletedAt, 'deleted_at');
      });

      test('has common fields', () {
        expect(SupabaseTables.name, 'name');
        expect(SupabaseTables.email, 'email');
        expect(SupabaseTables.status, 'status');
      });
    });

    group('storage buckets', () {
      test('has image storage buckets', () {
        expect(SupabaseTables.profilePhotos, 'profile-photos');
        expect(SupabaseTables.babyPhotos, 'baby-photos');
        expect(SupabaseTables.galleryPhotos, 'gallery-photos');
      });
    });
  });
}
