import '../../constants/supabase_tables.dart';

/// Event endpoints for event CRUD operations
///
/// **Functional Requirements**: Section 3.2.6 - Endpoint Definitions
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Event CRUD endpoints
/// - RSVP endpoints
/// - Event comment endpoints
///
/// Dependencies: SupabaseTables
class EventEndpoints {
  // Prevent instantiation
  EventEndpoints._();

  // ============================================================
  // Event CRUD Operations
  // ============================================================

  /// Get all events for a baby profile
  ///
  /// [babyProfileId] Baby profile ID
  static String getEvents(String babyProfileId) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=starts_at.asc';
  }

  /// Get a specific event
  ///
  /// [eventId] Event ID
  static String getEvent(String eventId) {
    return '${SupabaseTables.events}?id=eq.$eventId&select=*';
  }

  /// Get upcoming events
  ///
  /// [babyProfileId] Baby profile ID
  /// [currentDate] Current date in ISO format
  static String getUpcomingEvents(String babyProfileId, String currentDate) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&starts_at=gte.$currentDate&is:deleted_at.null&select=*&order=starts_at.asc';
  }

  /// Get past events
  ///
  /// [babyProfileId] Baby profile ID
  /// [currentDate] Current date in ISO format
  static String getPastEvents(String babyProfileId, String currentDate) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&starts_at=lt.$currentDate&is:deleted_at.null&select=*&order=starts_at.desc';
  }

  /// Create a new event
  static String createEvent() {
    return SupabaseTables.events;
  }

  /// Update an event
  ///
  /// [eventId] Event ID
  static String updateEvent(String eventId) {
    return '${SupabaseTables.events}?id=eq.$eventId';
  }

  /// Delete an event (soft delete)
  ///
  /// [eventId] Event ID
  static String deleteEvent(String eventId) {
    return '${SupabaseTables.events}?id=eq.$eventId';
  }

  // ============================================================
  // RSVP Operations
  // ============================================================

  /// Get all RSVPs for an event
  ///
  /// [eventId] Event ID
  static String getRsvps(String eventId) {
    return '${SupabaseTables.eventRsvps}?event_id=eq.$eventId&select=*';
  }

  /// Get RSVP for a specific user
  ///
  /// [eventId] Event ID
  /// [userId] User ID
  static String getUserRsvp(String eventId, String userId) {
    return '${SupabaseTables.eventRsvps}?event_id=eq.$eventId&user_id=eq.$userId&select=*';
  }

  /// Create or update RSVP
  static String upsertRsvp() {
    return SupabaseTables.eventRsvps;
  }

  /// Get RSVP counts by status
  ///
  /// [eventId] Event ID
  static String getRsvpCounts(String eventId) {
    return '${SupabaseTables.eventRsvps}?event_id=eq.$eventId&select=status';
  }

  // ============================================================
  // Event Comments
  // ============================================================

  /// Get all comments for an event
  ///
  /// [eventId] Event ID
  static String getEventComments(String eventId) {
    return '${SupabaseTables.eventComments}?event_id=eq.$eventId&select=*&order=created_at.desc';
  }

  /// Create a new comment
  static String createEventComment() {
    return SupabaseTables.eventComments;
  }

  /// Update a comment
  ///
  /// [commentId] Comment ID
  static String updateEventComment(String commentId) {
    return '${SupabaseTables.eventComments}?id=eq.$commentId';
  }

  /// Delete a comment
  ///
  /// [commentId] Comment ID
  static String deleteEventComment(String commentId) {
    return '${SupabaseTables.eventComments}?id=eq.$commentId';
  }

  // ============================================================
  // Event Search & Filter
  // ============================================================

  /// Search events by title
  ///
  /// [babyProfileId] Baby profile ID
  /// [searchTerm] Search term
  static String searchEvents(String babyProfileId, String searchTerm) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&title=ilike.*$searchTerm*&is:deleted_at.null&select=*';
  }

  /// Get events by date range
  ///
  /// [babyProfileId] Baby profile ID
  /// [startDate] Start date in ISO format
  /// [endDate] End date in ISO format
  static String getEventsByDateRange(
    String babyProfileId,
    String startDate,
    String endDate,
  ) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&starts_at=gte.$startDate&starts_at=lte.$endDate&is:deleted_at.null&select=*&order=starts_at.asc';
  }

  /// Get events created by a user
  ///
  /// [babyProfileId] Baby profile ID
  /// [userId] User ID
  static String getEventsByCreator(String babyProfileId, String userId) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&created_by_user_id=eq.$userId&is:deleted_at.null&select=*&order=created_at.desc';
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Build event query with pagination
  ///
  /// [babyProfileId] Baby profile ID
  /// [limit] Number of events to return
  /// [offset] Number of events to skip
  static String getEventsWithPagination(
    String babyProfileId, {
    int limit = 10,
    int offset = 0,
  }) {
    return '${SupabaseTables.events}?baby_profile_id=eq.$babyProfileId&is:deleted_at.null&select=*&order=starts_at.desc&limit=$limit&offset=$offset';
  }
}
