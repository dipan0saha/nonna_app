import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/core/models/notification.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/models/registry_item.dart';
import 'package:nonna_app/core/models/user.dart';

/// Factory for creating test data objects with sensible defaults
///
/// This factory provides convenient methods for creating test data
/// that can be used across multiple tests, ensuring consistency.
///
/// ## Usage
///
/// ```dart
/// // Create test data with defaults
/// final user = TestDataFactory.createUser();
/// final baby = TestDataFactory.createBabyProfile();
///
/// // Create test data with custom values
/// final customUser = TestDataFactory.createUser(
///   id: 'custom-id',
///   email: 'custom@example.com',
/// );
/// ```
class TestDataFactory {
  // ==========================================
  // User & Authentication Data
  // ==========================================

  /// Create a test User instance
  static User createUser({
    String? id,
    String? email,
    String? displayName,
    String? profilePictureUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email ?? 'testuser@example.com',
      displayName: displayName ?? 'Test User',
      profilePictureUrl:
          profilePictureUrl ?? 'https://example.com/avatar.jpg',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // ==========================================
  // Baby Profile Data
  // ==========================================

  /// Create a test BabyProfile instance
  static BabyProfile createBabyProfile({
    String? id,
    String? name,
    DateTime? dueDate,
    DateTime? birthDate,
    String? gender,
    String? profilePictureUrl,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return BabyProfile(
      id: id ?? 'test-baby-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Baby Test',
      dueDate: dueDate,
      birthDate: birthDate,
      gender: gender,
      profilePictureUrl: profilePictureUrl,
      ownerId: ownerId ?? 'test-owner-id',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Create a test BabyMembership instance
  static BabyMembership createBabyMembership({
    String? babyProfileId,
    String? userId,
    UserRole? role,
    String? relationshipLabel,
    DateTime? createdAt,
    DateTime? removedAt,
  }) {
    return BabyMembership(
      babyProfileId:
          babyProfileId ?? 'test-baby-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      role: role ?? UserRole.follower,
      relationshipLabel: relationshipLabel ?? 'Aunt',
      createdAt: createdAt ?? DateTime.now(),
      removedAt: removedAt,
    );
  }

  // ==========================================
  // Event Data
  // ==========================================

  /// Create a test Event instance
  static Event createEvent({
    String? id,
    String? babyProfileId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? 'test-event-${DateTime.now().millisecondsSinceEpoch}',
      babyProfileId:
          babyProfileId ?? 'test-baby-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Event',
      description: description ?? 'This is a test event',
      eventDate: eventDate ?? DateTime.now().add(const Duration(days: 30)),
      location: location ?? 'Test Location',
      createdBy:
          createdBy ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // ==========================================
  // Photo Data
  // ==========================================

  /// Create a test Photo instance
  static Photo createPhoto({
    String? id,
    String? babyProfileId,
    String? uploadedBy,
    String? url,
    String? thumbnailUrl,
    String? caption,
    DateTime? takenAt,
    DateTime? uploadedAt,
  }) {
    return Photo(
      id: id ?? 'test-photo-${DateTime.now().millisecondsSinceEpoch}',
      babyProfileId:
          babyProfileId ?? 'test-baby-${DateTime.now().millisecondsSinceEpoch}',
      uploadedBy:
          uploadedBy ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      url: url ?? 'https://example.com/photo.jpg',
      thumbnailUrl: thumbnailUrl ?? 'https://example.com/photo-thumb.jpg',
      caption: caption,
      takenAt: takenAt ?? DateTime.now(),
      uploadedAt: uploadedAt ?? DateTime.now(),
    );
  }

  // ==========================================
  // Registry Data
  // ==========================================

  /// Create a test RegistryItem instance
  static RegistryItem createRegistryItem({
    String? id,
    String? babyProfileId,
    String? name,
    String? description,
    double? price,
    String? url,
    String? imageUrl,
    bool? isPurchased,
    String? purchasedBy,
    DateTime? createdAt,
  }) {
    return RegistryItem(
      id: id ?? 'test-item-${DateTime.now().millisecondsSinceEpoch}',
      babyProfileId:
          babyProfileId ?? 'test-baby-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Registry Item',
      description: description ?? 'This is a test registry item',
      price: price ?? 29.99,
      url: url ?? 'https://example.com/product',
      imageUrl: imageUrl ?? 'https://example.com/product.jpg',
      isPurchased: isPurchased ?? false,
      purchasedBy: purchasedBy,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // ==========================================
  // Notification Data
  // ==========================================

  /// Create a test Notification instance
  static Notification createNotification({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? 'test-notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
      type: type ?? 'info',
      title: title ?? 'Test Notification',
      message: message ?? 'This is a test notification',
      metadata: metadata ?? {},
      isRead: isRead ?? false,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // ==========================================
  // Batch Data Creation
  // ==========================================

  /// Create multiple users at once
  static List<User> createUsers(int count) {
    return List.generate(
      count,
      (index) => createUser(
        id: 'test-user-$index',
        email: 'testuser$index@example.com',
        displayName: 'Test User $index',
      ),
    );
  }

  /// Create multiple baby profiles at once
  static List<BabyProfile> createBabyProfiles(int count) {
    return List.generate(
      count,
      (index) => createBabyProfile(
        id: 'test-baby-$index',
        name: 'Baby Test $index',
      ),
    );
  }

  /// Create multiple events at once
  static List<Event> createEvents(int count, {String? babyProfileId}) {
    return List.generate(
      count,
      (index) => createEvent(
        id: 'test-event-$index',
        babyProfileId: babyProfileId ?? 'test-baby-1',
        title: 'Test Event $index',
        eventDate: DateTime.now().add(Duration(days: index + 1)),
      ),
    );
  }

  /// Create multiple photos at once
  static List<Photo> createPhotos(int count, {String? babyProfileId}) {
    return List.generate(
      count,
      (index) => createPhoto(
        id: 'test-photo-$index',
        babyProfileId: babyProfileId ?? 'test-baby-1',
        url: 'https://example.com/photo$index.jpg',
      ),
    );
  }

  /// Create multiple registry items at once
  static List<RegistryItem> createRegistryItems(
    int count, {
    String? babyProfileId,
  }) {
    return List.generate(
      count,
      (index) => createRegistryItem(
        id: 'test-item-$index',
        babyProfileId: babyProfileId ?? 'test-baby-1',
        name: 'Test Item $index',
        price: (index + 1) * 10.0,
      ),
    );
  }

  /// Create multiple notifications at once
  static List<Notification> createNotifications(int count, {String? userId}) {
    return List.generate(
      count,
      (index) => createNotification(
        id: 'test-notif-$index',
        userId: userId ?? 'test-user-1',
        title: 'Test Notification $index',
        isRead: index.isEven, // Alternate read status
      ),
    );
  }

  // ==========================================
  // JSON Data Helpers
  // ==========================================

  /// Convert User to JSON (for mock database responses)
  static Map<String, dynamic> userToJson(User user) {
    return user.toJson();
  }

  /// Convert BabyProfile to JSON (for mock database responses)
  static Map<String, dynamic> babyProfileToJson(BabyProfile profile) {
    return profile.toJson();
  }

  /// Convert Event to JSON (for mock database responses)
  static Map<String, dynamic> eventToJson(Event event) {
    return event.toJson();
  }

  /// Convert Photo to JSON (for mock database responses)
  static Map<String, dynamic> photoToJson(Photo photo) {
    return photo.toJson();
  }

  /// Convert RegistryItem to JSON (for mock database responses)
  static Map<String, dynamic> registryItemToJson(RegistryItem item) {
    return item.toJson();
  }

  /// Convert Notification to JSON (for mock database responses)
  static Map<String, dynamic> notificationToJson(Notification notification) {
    return notification.toJson();
  }

  /// Convert BabyMembership to JSON (for mock database responses)
  static Map<String, dynamic> babyMembershipToJson(BabyMembership membership) {
    return membership.toJson();
  }

  // ==========================================
  // Batch JSON Conversion
  // ==========================================

  /// Convert list of users to JSON array
  static List<Map<String, dynamic>> usersToJson(List<User> users) {
    return users.map((u) => u.toJson()).toList();
  }

  /// Convert list of baby profiles to JSON array
  static List<Map<String, dynamic>> babyProfilesToJson(
    List<BabyProfile> profiles,
  ) {
    return profiles.map((p) => p.toJson()).toList();
  }

  /// Convert list of events to JSON array
  static List<Map<String, dynamic>> eventsToJson(List<Event> events) {
    return events.map((e) => e.toJson()).toList();
  }

  /// Convert list of photos to JSON array
  static List<Map<String, dynamic>> photosToJson(List<Photo> photos) {
    return photos.map((p) => p.toJson()).toList();
  }

  /// Convert list of registry items to JSON array
  static List<Map<String, dynamic>> registryItemsToJson(
    List<RegistryItem> items,
  ) {
    return items.map((i) => i.toJson()).toList();
  }

  /// Convert list of notifications to JSON array
  static List<Map<String, dynamic>> notificationsToJson(
    List<Notification> notifications,
  ) {
    return notifications.map((n) => n.toJson()).toList();
  }

  /// Convert list of baby memberships to JSON array
  static List<Map<String, dynamic>> babyMembershipsToJson(
    List<BabyMembership> memberships,
  ) {
    return memberships.map((m) => m.toJson()).toList();
  }
}
