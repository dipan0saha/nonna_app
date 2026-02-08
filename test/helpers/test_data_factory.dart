import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/notification_type.dart';
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
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return User(
      userId: userId ?? 'test-user-${now.millisecondsSinceEpoch}',
      displayName: displayName ?? 'Test User',
      avatarUrl: avatarUrl ?? 'https://example.com/avatar.jpg',
      biometricEnabled: biometricEnabled ?? false,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  // ==========================================
  // Baby Profile Data
  // ==========================================

  /// Create a test BabyProfile instance
  static BabyProfile createBabyProfile({
    String? id,
    String? name,
    String? defaultLastNameSource,
    String? profilePhotoUrl,
    DateTime? expectedBirthDate,
    DateTime? actualBirthDate,
    Gender? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final now = DateTime.now();
    return BabyProfile(
      id: id ?? 'test-baby-${now.millisecondsSinceEpoch}',
      name: name ?? 'Baby Test',
      defaultLastNameSource: defaultLastNameSource,
      profilePhotoUrl: profilePhotoUrl,
      expectedBirthDate: expectedBirthDate,
      actualBirthDate: actualBirthDate,
      gender: gender ?? Gender.unknown,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      deletedAt: deletedAt,
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
    String? createdByUserId,
    String? title,
    DateTime? startsAt,
    DateTime? endsAt,
    String? description,
    String? location,
    String? videoLink,
    String? coverPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final now = DateTime.now();
    return Event(
      id: id ?? 'test-event-${now.millisecondsSinceEpoch}',
      babyProfileId: babyProfileId ?? 'test-baby-${now.millisecondsSinceEpoch}',
      createdByUserId: createdByUserId ?? 'test-user-${now.millisecondsSinceEpoch}',
      title: title ?? 'Test Event',
      startsAt: startsAt ?? now.add(const Duration(days: 30)),
      endsAt: endsAt,
      description: description ?? 'This is a test event',
      location: location ?? 'Test Location',
      videoLink: videoLink,
      coverPhotoUrl: coverPhotoUrl,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      deletedAt: deletedAt,
    );
  }

  // ==========================================
  // Photo Data
  // ==========================================

  /// Create a test Photo instance
  static Photo createPhoto({
    String? id,
    String? babyProfileId,
    String? uploadedByUserId,
    String? storagePath,
    String? thumbnailPath,
    String? caption,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final now = DateTime.now();
    return Photo(
      id: id ?? 'test-photo-${now.millisecondsSinceEpoch}',
      babyProfileId: babyProfileId ?? 'test-baby-${now.millisecondsSinceEpoch}',
      uploadedByUserId: uploadedByUserId ?? 'test-user-${now.millisecondsSinceEpoch}',
      storagePath: storagePath ?? 'baby_test/photo_${now.millisecondsSinceEpoch}.jpg',
      thumbnailPath: thumbnailPath,
      caption: caption,
      tags: tags ?? const [],
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      deletedAt: deletedAt,
    );
  }

  // ==========================================
  // Registry Data
  // ==========================================

  /// Create a test RegistryItem instance
  static RegistryItem createRegistryItem({
    String? id,
    String? babyProfileId,
    String? createdByUserId,
    String? name,
    String? description,
    String? linkUrl,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final now = DateTime.now();
    return RegistryItem(
      id: id ?? 'test-item-${now.millisecondsSinceEpoch}',
      babyProfileId: babyProfileId ?? 'test-baby-${now.millisecondsSinceEpoch}',
      createdByUserId: createdByUserId ?? 'test-user-${now.millisecondsSinceEpoch}',
      name: name ?? 'Test Registry Item',
      description: description ?? 'This is a test registry item',
      linkUrl: linkUrl ?? 'https://example.com/product',
      priority: priority ?? 3,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      deletedAt: deletedAt,
    );
  }

  // ==========================================
  // Notification Data
  // ==========================================

  /// Create a test Notification instance
  static Notification createNotification({
    String? id,
    String? recipientUserId,
    String? babyProfileId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return Notification(
      id: id ?? 'test-notif-${now.millisecondsSinceEpoch}',
      recipientUserId: recipientUserId ?? 'test-user-${now.millisecondsSinceEpoch}',
      babyProfileId: babyProfileId,
      type: type ?? NotificationType.system,
      title: title ?? 'Test Notification',
      body: body ?? 'This is a test notification',
      payload: payload,
      readAt: readAt,
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
        userId: 'test-user-$index',
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
        startsAt: DateTime.now().add(Duration(days: index + 1)),
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
        storagePath: 'baby_test/photo$index.jpg',
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
        priority: 3,
      ),
    );
  }

  /// Create multiple notifications at once
  static List<Notification> createNotifications(int count, {String? recipientUserId}) {
    return List.generate(
      count,
      (index) => createNotification(
        id: 'test-notif-$index',
        recipientUserId: recipientUserId ?? 'test-user-1',
        title: 'Test Notification $index',
        readAt: index.isEven ? DateTime.now() : null, // Alternate read status
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
