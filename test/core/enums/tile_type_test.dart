import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/tile_type.dart';

void main() {
  group('TileType', () {
    test('has correct number of tile types', () {
      expect(TileType.values.length, 15);
    });

    test('contains all expected tile types', () {
      expect(TileType.values, contains(TileType.upcomingEvents));
      expect(TileType.values, contains(TileType.recentPhotos));
      expect(TileType.values, contains(TileType.registryHighlights));
      expect(TileType.values, contains(TileType.notifications));
      expect(TileType.values, contains(TileType.invitesStatus));
      expect(TileType.values, contains(TileType.rsvpTasks));
      expect(TileType.values, contains(TileType.dueDateCountdown));
      expect(TileType.values, contains(TileType.recentPurchases));
      expect(TileType.values, contains(TileType.registryDeals));
      expect(TileType.values, contains(TileType.engagementRecap));
      expect(TileType.values, contains(TileType.galleryFavorites));
      expect(TileType.values, contains(TileType.checklist));
      expect(TileType.values, contains(TileType.storageUsage));
      expect(TileType.values, contains(TileType.systemAnnouncements));
      expect(TileType.values, contains(TileType.newFollowers));
    });

    group('toJson and fromJson', () {
      test('toJson returns correct string', () {
        expect(TileType.upcomingEvents.toJson(), 'upcomingEvents');
        expect(TileType.recentPhotos.toJson(), 'recentPhotos');
      });

      test('fromJson parses correct values', () {
        expect(TileType.fromJson('upcomingEvents'), TileType.upcomingEvents);
        expect(TileType.fromJson('recentPhotos'), TileType.recentPhotos);
      });

      test('fromJson defaults to upcomingEvents for invalid input', () {
        expect(TileType.fromJson('invalid'), TileType.upcomingEvents);
        expect(TileType.fromJson(''), TileType.upcomingEvents);
      });
    });

    group('displayName', () {
      test('returns user-friendly names', () {
        expect(TileType.upcomingEvents.displayName, 'Upcoming Events');
        expect(TileType.recentPhotos.displayName, 'Recent Photos');
        expect(TileType.dueDateCountdown.displayName, 'Due Date Countdown');
      });

      test('all tiles have non-empty display names', () {
        for (final tile in TileType.values) {
          expect(tile.displayName.isNotEmpty, true);
        }
      });
    });

    group('description', () {
      test('all tiles have non-empty descriptions', () {
        for (final tile in TileType.values) {
          expect(tile.description.isNotEmpty, true);
        }
      });
    });
  });
}
