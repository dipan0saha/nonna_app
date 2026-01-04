# Functional Requirements Specification (FRS)

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Section**: 1.2 - Technical Requirements

## Executive Summary

This Functional Requirements Specification (FRS) defines the detailed functional requirements, user stories, and acceptance criteria for the Nonna App. Nonna is a tile-based family social platform that enables parents to share their pregnancy and parenting journey with invited friends and family through an integrated solution combining photo galleries, event calendars, and baby registries.

This document translates the business requirements defined in the Business Requirements Document (BRD) into specific, measurable, and testable functional specifications that will guide development and testing phases.

## References

This FRS is based on and references the following documents:

- `docs/00_requirement_gathering/business_requirements_document.md` - Business objectives and scope
- `docs/00_requirement_gathering/user_personas_document.md` - User characteristics and needs
- `docs/00_requirement_gathering/user_journey_maps.md` - User workflows and interactions
- `docs/00_requirement_gathering/success_metrics_kpis.md` - Success criteria and measurement
- `discovery/01_discovery/01_requirements/Requirements.md` - Initial requirements specification
- `discovery/01_discovery/04_technical_requirements/Technical_Requirements.md` - Technical specifications
- `discovery/01_discovery/04_technical_requirements/Tile_System_Design.md` - Tile-based architecture

## 1. User Authentication and Account Management

### FR-1.1: User Registration

**User Story**: As a new user, I want to create an account using email/password or OAuth so that I can access the Nonna platform.

**Functional Requirements**:
- The system SHALL support email/password registration
- The system SHALL support OAuth 2.0 registration via Google and Facebook
- The system SHALL enforce password complexity requirements:
  - Minimum 6 characters
  - At least one number or special character
- The system SHALL validate email format before account creation
- The system SHALL send email verification link upon registration
- The system SHALL prevent duplicate account creation with same email address
- The system SHALL create a profile entry in `profiles` table linked to `auth.users`

**Acceptance Criteria**:
- ✓ User can successfully register with valid email and password
- ✓ User can successfully register via Google OAuth
- ✓ User can successfully register via Facebook OAuth
- ✓ System rejects passwords not meeting complexity requirements
- ✓ System sends verification email within 30 seconds
- ✓ System displays appropriate error for duplicate email registration
- ✓ Profile is automatically created upon successful registration

**Priority**: P0 (Critical)  
**Dependencies**: Supabase Auth configuration

---

### FR-1.2: Email Verification

**User Story**: As a registered user, I want to verify my email address so that I can access the full functionality of the platform.

**Functional Requirements**:
- The system SHALL send verification email with secure token
- The system SHALL provide verification link that expires in 24 hours
- The system SHALL mark email as verified upon successful verification
- The system SHALL allow users to request new verification email
- The system SHALL restrict certain features until email is verified

**Acceptance Criteria**:
- ✓ Verification email is delivered within 30 seconds
- ✓ User can click link and verify email successfully
- ✓ Expired verification links display appropriate error message
- ✓ User can request new verification email after expiration
- ✓ Unverified users cannot create baby profiles

**Priority**: P0 (Critical)  
**Dependencies**: SendGrid email service

---

### FR-1.3: User Login

**User Story**: As a registered user, I want to securely log into my account so that I can access my baby profiles and content.

**Functional Requirements**:
- The system SHALL support email/password login
- The system SHALL support OAuth 2.0 login via Google and Facebook
- The system SHALL use JWT-based session management
- The system SHALL store session tokens securely (iOS Keychain, Android Keystore)
- The system SHALL enforce rate limiting on login attempts (5 attempts per 15 minutes)
- The system SHALL maintain session for 30 days or until user logs out
- The system SHALL redirect to appropriate screen based on user state (onboarding, home)

**Acceptance Criteria**:
- ✓ User can log in with valid credentials
- ✓ System rejects invalid credentials with clear error message
- ✓ OAuth login redirects properly and completes authentication
- ✓ Session persists across app restarts
- ✓ Rate limiting blocks excessive login attempts
- ✓ User is redirected to home screen if profiles exist

**Priority**: P0 (Critical)  
**Dependencies**: Supabase Auth

---

### FR-1.4: Password Reset

**User Story**: As a user who forgot my password, I want to reset it via email so that I can regain access to my account.

**Functional Requirements**:
- The system SHALL provide "Forgot Password" option on login screen
- The system SHALL send password reset email with secure token
- The system SHALL expire reset tokens after 1 hour
- The system SHALL allow password change via reset link
- The system SHALL enforce password complexity on new password
- The system SHALL invalidate old session tokens after password change

**Acceptance Criteria**:
- ✓ User receives reset email within 30 seconds
- ✓ Reset link successfully loads password change form
- ✓ User can set new password meeting complexity requirements
- ✓ Expired reset links display appropriate error
- ✓ User can log in with new password immediately
- ✓ Old sessions are invalidated

**Priority**: P0 (Critical)  
**Dependencies**: SendGrid email service

---

### FR-1.5: User Profile Management

**User Story**: As a user, I want to manage my profile information so that other users can identify me.

**Functional Requirements**:
- The system SHALL allow users to set/update display name
- The system SHALL allow users to upload/update profile photo
- The system SHALL support JPEG/PNG formats for profile photos (max 5MB)
- The system SHALL generate and store thumbnail for profile photos
- The system SHALL display user profile photo in comments, activity feeds
- The system SHALL allow users to enable/disable biometric authentication

**Acceptance Criteria**:
- ✓ User can update display name and see change reflected immediately
- ✓ User can upload profile photo successfully (< 5 seconds)
- ✓ Profile photo displays in all relevant locations
- ✓ System rejects unsupported file formats
- ✓ Biometric toggle enables/disables biometric login

**Priority**: P1 (High)  
**Dependencies**: Supabase Storage

---

## 2. Baby Profile Management

### FR-2.1: Create Baby Profile

**User Story**: As a parent (owner), I want to create a baby profile so that I can share my pregnancy and parenting journey with family and friends.

**Functional Requirements**:
- The system SHALL allow verified users to create baby profiles
- The system SHALL require baby name (or default to "Baby [Last Name]")
- The system SHALL require expected birth date or actual birth date
- The system SHALL allow optional gender selection (male, female, unknown)
- The system SHALL allow optional profile photo upload
- The system SHALL automatically assign creator as owner in `baby_memberships`
- The system SHALL initialize empty tiles for the baby profile
- The system SHALL create default `owner_update_markers` entry

**Acceptance Criteria**:
- ✓ User can create profile with required fields only
- ✓ User can create profile with all optional fields
- ✓ Profile photo uploads successfully (< 5 seconds)
- ✓ Creator is assigned owner role automatically
- ✓ Empty tile structure is initialized
- ✓ New profile appears in user's baby profile list immediately

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-2.2: Edit Baby Profile

**User Story**: As a baby profile owner, I want to edit profile details so that I can keep information current.

**Functional Requirements**:
- The system SHALL allow only owners to edit baby profile
- The system SHALL allow editing of name, gender, birth date, profile photo
- The system SHALL validate birth date is not in future if baby is born
- The system SHALL update `owner_update_markers` timestamp on changes
- The system SHALL broadcast real-time updates to followers via Supabase Realtime
- The system SHALL maintain audit trail with `updated_at` timestamp

**Acceptance Criteria**:
- ✓ Owner can successfully edit all editable fields
- ✓ Followers cannot access edit functionality
- ✓ Changes are reflected immediately for owner
- ✓ Followers receive real-time update within 2 seconds
- ✓ Invalid birth dates are rejected with clear error

**Priority**: P1 (High)  
**Dependencies**: Row-Level Security (RLS) policies

---

### FR-2.3: Delete Baby Profile

**User Story**: As a baby profile owner, I want to delete a profile so that I can remove data I no longer want to maintain.

**Functional Requirements**:
- The system SHALL allow only owners to delete baby profiles
- The system SHALL require confirmation before deletion
- The system SHALL implement soft delete (set `removed_at` timestamp)
- The system SHALL retain data for 7 years per retention policy
- The system SHALL remove profile from all user views immediately
- The system SHALL cancel all pending invitations for the profile
- The system SHALL notify co-owner if present

**Acceptance Criteria**:
- ✓ Owner must confirm deletion before profile is removed
- ✓ Profile no longer appears in owner's profile list
- ✓ Followers can no longer access profile
- ✓ Pending invitations are marked as revoked
- ✓ Data remains in database (soft delete)
- ✓ Co-owner receives notification of deletion

**Priority**: P2 (Medium)  
**Dependencies**: Soft delete pattern implementation

---

### FR-2.4: Co-Owner Management

**User Story**: As a baby profile owner, I want to add a co-owner so that my partner can have equal management rights.

**Functional Requirements**:
- The system SHALL allow maximum 2 owners per baby profile
- The system SHALL allow owner to invite co-owner via email
- The system SHALL require co-owner acceptance before granting owner role
- The system SHALL grant co-owner full CRUD permissions on profile
- The system SHALL prevent removing co-owner if only 2 owners exist (unless deleting profile)
- The system SHALL enforce constraint at database level (max 2 owners)

**Acceptance Criteria**:
- ✓ Owner can invite co-owner successfully
- ✓ Invited user receives co-owner invitation email
- ✓ Co-owner can accept and gain owner permissions
- ✓ System prevents adding third owner
- ✓ Both owners have equal edit/delete rights
- ✓ System maintains owner count constraint at DB level

**Priority**: P1 (High)  
**Dependencies**: Invitation system (FR-3.x)

---

## 3. Invitation and Follower Management

### FR-3.1: Send Invitations

**User Story**: As a baby profile owner, I want to invite family and friends to follow my baby profile so that they can view and interact with content.

**Functional Requirements**:
- The system SHALL allow owners to send email invitations
- The system SHALL support bulk invitation (multiple emails at once)
- The system SHALL generate unique secure token for each invitation
- The system SHALL set expiration to 7 days from creation
- The system SHALL send invitation email via SendGrid
- The system SHALL include invitation link with embedded token
- The system SHALL track invitation status (pending, accepted, expired, revoked)
- The system SHALL display invitation management dashboard for owners

**Acceptance Criteria**:
- ✓ Owner can enter multiple email addresses and send invitations
- ✓ Each invitee receives email within 30 seconds
- ✓ Email contains clear "Accept Invitation" button
- ✓ Token is securely hashed in database
- ✓ Invitation expires exactly 7 days after creation
- ✓ Owner can view status of all sent invitations

**Priority**: P0 (Critical)  
**Dependencies**: SendGrid integration

---

### FR-3.2: Accept Invitation

**User Story**: As an invited user, I want to accept an invitation so that I can follow a baby profile and view content.

**Functional Requirements**:
- The system SHALL validate invitation token on acceptance
- The system SHALL check token has not expired (< 7 days old)
- The system SHALL check token has not been used or revoked
- The system SHALL prompt user to create account if not registered
- The system SHALL prompt user to select relationship label (Grandma, Grandpa, Aunt, etc.)
- The system SHALL create `baby_memberships` entry with follower role
- The system SHALL mark invitation as accepted with timestamp
- The system SHALL notify owner of new follower

**Acceptance Criteria**:
- ✓ Valid token successfully loads acceptance flow
- ✓ Expired token displays clear error message with option to request new invitation
- ✓ User can create account during acceptance flow
- ✓ User selects relationship from predefined list
- ✓ User gains immediate access to baby profile
- ✓ Owner receives notification of new follower

**Priority**: P0 (Critical)  
**Dependencies**: User registration (FR-1.1)

---

### FR-3.3: Resend Invitation

**User Story**: As a baby profile owner, I want to resend an expired or unaccepted invitation so that users have another opportunity to join.

**Functional Requirements**:
- The system SHALL allow owners to resend invitations
- The system SHALL revoke previous invitation token
- The system SHALL generate new token with new 7-day expiration
- The system SHALL send new invitation email
- The system SHALL update invitation record with new details

**Acceptance Criteria**:
- ✓ Owner can resend invitation from invitation dashboard
- ✓ Old token becomes invalid immediately
- ✓ New email is sent within 30 seconds
- ✓ New token has fresh 7-day expiration
- ✓ Invitee receives new email successfully

**Priority**: P1 (High)  
**Dependencies**: Invitation system (FR-3.1)

---

### FR-3.4: Revoke Invitation

**User Story**: As a baby profile owner, I want to revoke a pending invitation so that the recipient can no longer accept it.

**Functional Requirements**:
- The system SHALL allow owners to revoke pending invitations
- The system SHALL mark invitation status as revoked
- The system SHALL invalidate invitation token immediately
- The system SHALL prevent acceptance of revoked invitations
- The system SHALL not send notification to invitee

**Acceptance Criteria**:
- ✓ Owner can revoke invitation from dashboard
- ✓ Token becomes invalid immediately
- ✓ Attempt to accept revoked invitation fails with clear message
- ✓ Invitation status updates to "revoked"

**Priority**: P2 (Medium)  
**Dependencies**: None

---

### FR-3.5: Remove Follower

**User Story**: As a baby profile owner, I want to remove a follower so that they can no longer access my baby profile.

**Functional Requirements**:
- The system SHALL allow owners to remove followers
- The system SHALL require confirmation before removal
- The system SHALL set `removed_at` timestamp in `baby_memberships`
- The system SHALL revoke follower access immediately
- The system SHALL remove profile from follower's followed list
- The system SHALL not send notification to removed follower

**Acceptance Criteria**:
- ✓ Owner can remove follower from follower list
- ✓ Confirmation dialog appears before removal
- ✓ Follower loses access immediately
- ✓ Profile disappears from follower's app
- ✓ Soft delete allows data retention

**Priority**: P2 (Medium)  
**Dependencies**: Soft delete pattern

---

### FR-3.6: Change Relationship Label

**User Story**: As a follower, I want to update my relationship label so that it accurately reflects my connection to the baby.

**Functional Requirements**:
- The system SHALL allow followers to change their relationship label
- The system SHALL provide predefined list of relationships (Grandma, Grandpa, Aunt, Uncle, Family Friend, etc.)
- The system SHALL update label in `baby_memberships` table
- The system SHALL reflect change in all displays (comments, activity feed)

**Acceptance Criteria**:
- ✓ Follower can access relationship settings
- ✓ Follower can select from predefined list
- ✓ Change is reflected immediately throughout app
- ✓ Owner sees updated relationship label

**Priority**: P2 (Medium)  
**Dependencies**: None

---

## 4. Photo Gallery

### FR-4.1: Upload Photos

**User Story**: As a baby profile owner, I want to upload photos so that I can share moments with followers.

**Functional Requirements**:
- The system SHALL allow owners to upload photos to baby profile
- The system SHALL support JPEG and PNG formats only
- The system SHALL enforce maximum file size of 10MB per photo
- The system SHALL support single and bulk upload (up to 10 photos at once)
- The system SHALL compress images client-side before upload
- The system SHALL generate thumbnail (300x300) for each photo
- The system SHALL store original and thumbnail in Supabase Storage
- The system SHALL create entry in `photos` table with metadata
- The system SHALL update `owner_update_markers` timestamp
- The system SHALL complete upload in < 5 seconds per photo

**Acceptance Criteria**:
- ✓ Owner can select and upload single photo successfully
- ✓ Owner can select and upload multiple photos (bulk)
- ✓ System rejects unsupported file formats with clear message
- ✓ System rejects files exceeding 10MB with clear message
- ✓ Upload completes in < 5 seconds per photo
- ✓ Thumbnail is generated and displayed in gallery
- ✓ Followers receive real-time notification of new photos

**Priority**: P0 (Critical)  
**Dependencies**: Supabase Storage, image compression library

---

### FR-4.2: Add Photo Caption and Tags

**User Story**: As a baby profile owner, I want to add captions and tags to photos so that I can provide context and organize content.

**Functional Requirements**:
- The system SHALL allow owners to add caption during or after upload
- The system SHALL support up to 500 characters for captions
- The system SHALL allow owners to add 1-5 tags per photo
- The system SHALL provide suggested tags based on common categories (ultrasound, bump_update, nursery, etc.)
- The system SHALL allow custom tag creation
- The system SHALL make tags searchable/filterable

**Acceptance Criteria**:
- ✓ Owner can add caption during upload
- ✓ Owner can edit caption after upload
- ✓ Owner can add up to 5 tags per photo
- ✓ System suggests relevant tags based on history
- ✓ Owner can create custom tags
- ✓ Photos can be filtered by tags

**Priority**: P1 (High)  
**Dependencies**: Photo upload (FR-4.1)

---

### FR-4.3: View Photo Gallery

**User Story**: As a user (owner or follower), I want to view photos in the gallery so that I can see shared moments.

**Functional Requirements**:
- The system SHALL display photos in reverse chronological order (newest first)
- The system SHALL use thumbnail for gallery grid view
- The system SHALL load full-size image on photo tap
- The system SHALL support infinite scroll with pagination (30 photos per page)
- The system SHALL display photo caption, upload date, and uploader name
- The system SHALL display squish (like) count and comment count
- For followers, the system SHALL aggregate photos from all followed babies

**Acceptance Criteria**:
- ✓ Gallery loads with thumbnails in < 500ms
- ✓ Tapping photo loads full-size image in < 2 seconds
- ✓ Photos are ordered newest to oldest
- ✓ Infinite scroll loads next page smoothly
- ✓ Caption and metadata display correctly
- ✓ Follower sees photos from all followed babies in unified view

**Priority**: P0 (Critical)  
**Dependencies**: Photo upload (FR-4.1)

---

### FR-4.4: Delete Photos

**User Story**: As a baby profile owner, I want to delete photos so that I can remove content I no longer want to share.

**Functional Requirements**:
- The system SHALL allow only owners to delete photos
- The system SHALL require confirmation before deletion
- The system SHALL implement soft delete (set `deleted_at` timestamp)
- The system SHALL remove photo from all user views immediately
- The system SHALL retain photo file and metadata for 7 years
- The system SHALL support bulk delete (select multiple photos)

**Acceptance Criteria**:
- ✓ Owner can select and delete single photo
- ✓ Owner can select and delete multiple photos (bulk)
- ✓ Confirmation dialog appears before deletion
- ✓ Photo disappears from gallery immediately
- ✓ Photo is soft deleted (data retained)

**Priority**: P1 (High)  
**Dependencies**: Soft delete pattern

---

### FR-4.5: Squish (Like) Photos

**User Story**: As a user (owner or follower), I want to squish (like) photos so that I can express appreciation.

**Functional Requirements**:
- The system SHALL allow users to squish photos once per photo
- The system SHALL create entry in `photo_squishes` table
- The system SHALL enforce unique constraint (one squish per user per photo)
- The system SHALL update squish count immediately
- The system SHALL allow users to un-squish (remove like)
- The system SHALL send notification to photo uploader (if not self)
- The system SHALL increment user's `photos_squished_count` in `user_stats`

**Acceptance Criteria**:
- ✓ User can tap heart icon to squish photo
- ✓ Squish count increments immediately
- ✓ User cannot squish same photo multiple times
- ✓ User can tap again to remove squish
- ✓ Photo owner receives notification of squish
- ✓ User stats update correctly

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-4.6: Comment on Photos

**User Story**: As a user (owner or follower), I want to comment on photos so that I can share reactions and thoughts.

**Functional Requirements**:
- The system SHALL allow users to add comments to photos
- The system SHALL support up to 500 characters per comment
- The system SHALL display commenter name, relationship label, profile photo, and timestamp
- The system SHALL order comments chronologically (oldest first)
- The system SHALL allow comment authors to edit their comments
- The system SHALL allow owners to delete any comment on their photos
- The system SHALL send notification to photo uploader
- The system SHALL increment user's `comments_added_count` in `user_stats`

**Acceptance Criteria**:
- ✓ User can add comment successfully
- ✓ Comment appears immediately with user details
- ✓ Comments are ordered chronologically
- ✓ User can edit own comment
- ✓ Owner can delete any comment
- ✓ Photo owner receives notification

**Priority**: P0 (Critical)  
**Dependencies**: None

---

## 5. Calendar and Events

### FR-5.1: Create Events

**User Story**: As a baby profile owner, I want to create calendar events so that I can share important dates with followers.

**Functional Requirements**:
- The system SHALL allow owners to create events
- The system SHALL require event title, start date/time
- The system SHALL allow optional end date/time, description, location, video link
- The system SHALL allow optional cover photo upload
- The system SHALL enforce maximum 2 events per day per baby profile
- The system SHALL create entry in `events` table
- The system SHALL send notifications to all followers
- The system SHALL update `owner_update_markers` timestamp

**Acceptance Criteria**:
- ✓ Owner can create event with required fields
- ✓ Owner can add all optional fields
- ✓ System enforces 2 events per day limit
- ✓ Event appears in calendar immediately
- ✓ Followers receive notification within 2 seconds
- ✓ Cover photo uploads successfully

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-5.2: Edit Events

**User Story**: As a baby profile owner, I want to edit event details so that I can keep information current.

**Functional Requirements**:
- The system SHALL allow only owners to edit events
- The system SHALL allow editing of all event fields
- The system SHALL update `updated_at` timestamp
- The system SHALL send notification to followers who RSVP'd
- The system SHALL broadcast real-time updates via Supabase Realtime

**Acceptance Criteria**:
- ✓ Owner can edit all event fields
- ✓ Changes reflect immediately
- ✓ RSVP'd followers receive update notification
- ✓ Event shows "Updated" indicator

**Priority**: P1 (High)  
**Dependencies**: RLS policies

---

### FR-5.3: Delete Events

**User Story**: As a baby profile owner, I want to delete events so that I can remove cancelled or past events.

**Functional Requirements**:
- The system SHALL allow only owners to delete events
- The system SHALL require confirmation before deletion
- The system SHALL implement soft delete (set `deleted_at` timestamp)
- The system SHALL remove event from all views immediately
- The system SHALL retain event data for 7 years
- The system SHALL send notification to RSVP'd followers

**Acceptance Criteria**:
- ✓ Owner must confirm deletion
- ✓ Event disappears from calendar immediately
- ✓ RSVP'd followers receive cancellation notification
- ✓ Event is soft deleted

**Priority**: P1 (High)  
**Dependencies**: Soft delete pattern

---

### FR-5.4: RSVP to Events

**User Story**: As a follower, I want to RSVP to events so that the owner knows my attendance plans.

**Functional Requirements**:
- The system SHALL allow followers to RSVP to events
- The system SHALL support three RSVP statuses: Yes, No, Maybe
- The system SHALL allow users to change RSVP status
- The system SHALL create/update entry in `event_rsvps` table
- The system SHALL display RSVP count to owner
- The system SHALL send notification to owner on RSVP
- The system SHALL increment follower's `events_attended_count` on "Yes" RSVP

**Acceptance Criteria**:
- ✓ Follower can select Yes/No/Maybe RSVP
- ✓ Follower can change RSVP status
- ✓ RSVP status reflects immediately
- ✓ Owner sees updated RSVP count
- ✓ Owner receives notification of RSVP
- ✓ User stats update correctly

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-5.5: Comment on Events

**User Story**: As a user (owner or follower), I want to comment on events so that I can ask questions or share information.

**Functional Requirements**:
- The system SHALL allow users to comment on events
- The system SHALL support up to 500 characters per comment
- The system SHALL display commenter details and timestamp
- The system SHALL order comments chronologically
- The system SHALL allow comment authors to edit their comments
- The system SHALL allow owners to delete any comment
- The system SHALL send notifications to owner and other commenters

**Acceptance Criteria**:
- ✓ User can add comment successfully
- ✓ Comment displays with user details
- ✓ Comments ordered chronologically
- ✓ User can edit own comment
- ✓ Owner can delete any comment
- ✓ Relevant users receive notifications

**Priority**: P1 (High)  
**Dependencies**: None

---

### FR-5.6: View Calendar

**User Story**: As a user (owner or follower), I want to view upcoming events so that I can stay informed about important dates.

**Functional Requirements**:
- The system SHALL display events in chronological order
- The system SHALL highlight events within next 7 days
- The system SHALL display event title, date/time, location, RSVP count
- The system SHALL support month/list view toggle
- For followers, the system SHALL aggregate events from all followed babies
- The system SHALL allow filtering by baby profile (for users following multiple)

**Acceptance Criteria**:
- ✓ Calendar displays all upcoming events
- ✓ Events within 7 days are highlighted
- ✓ User can toggle between month and list view
- ✓ Event details display correctly
- ✓ Follower sees aggregated events from all babies
- ✓ Filter works correctly for multiple profiles

**Priority**: P0 (Critical)  
**Dependencies**: None

---

## 6. Baby Registry

### FR-6.1: Create Registry Items

**User Story**: As a baby profile owner, I want to create registry items so that followers know what products I need.

**Functional Requirements**:
- The system SHALL allow owners to create registry items
- The system SHALL require item name
- The system SHALL allow optional description, link URL, priority
- The system SHALL support priority levels (1-5, 1 being highest)
- The system SHALL create entry in `registry_items` table
- The system SHALL update `owner_update_markers` timestamp
- The system SHALL send notification to followers

**Acceptance Criteria**:
- ✓ Owner can create item with name only
- ✓ Owner can add all optional fields
- ✓ Item appears in registry immediately
- ✓ Items can be sorted by priority
- ✓ Followers receive notification
- ✓ Link URL opens correctly

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-6.2: Edit Registry Items

**User Story**: As a baby profile owner, I want to edit registry items so that I can update details or priority.

**Functional Requirements**:
- The system SHALL allow only owners to edit items
- The system SHALL allow editing of all item fields
- The system SHALL update `updated_at` timestamp
- The system SHALL broadcast real-time updates

**Acceptance Criteria**:
- ✓ Owner can edit all item fields
- ✓ Changes reflect immediately
- ✓ Updated items re-sort by priority if changed
- ✓ Followers see updates in real-time

**Priority**: P1 (High)  
**Dependencies**: RLS policies

---

### FR-6.3: Delete Registry Items

**User Story**: As a baby profile owner, I want to delete registry items so that I can remove items no longer needed.

**Functional Requirements**:
- The system SHALL allow only owners to delete items
- The system SHALL require confirmation before deletion
- The system SHALL implement soft delete
- The system SHALL remove item from all views immediately
- The system SHALL retain item data for 7 years

**Acceptance Criteria**:
- ✓ Owner must confirm deletion
- ✓ Item disappears immediately
- ✓ Item is soft deleted
- ✓ Purchase history is retained

**Priority**: P1 (High)  
**Dependencies**: Soft delete pattern

---

### FR-6.4: Mark Registry Item as Purchased

**User Story**: As a follower, I want to mark registry items as purchased so that others know the item is taken care of.

**Functional Requirements**:
- The system SHALL allow followers to mark items as purchased
- The system SHALL create entry in `registry_purchases` table
- The system SHALL record purchaser user_id, timestamp, optional note
- The system SHALL display item as purchased with purchaser name
- The system SHALL move purchased items to bottom of registry list
- The system SHALL send notification to owner
- The system SHALL increment follower's `items_purchased_count` in `user_stats`
- The system SHALL allow purchaser to add note

**Acceptance Criteria**:
- ✓ Follower can mark item as purchased
- ✓ Purchaser name and date display correctly
- ✓ Item moves to "Purchased" section
- ✓ Owner receives notification
- ✓ User stats update correctly
- ✓ Optional note saves successfully

**Priority**: P0 (Critical)  
**Dependencies**: None

---

### FR-6.5: View Registry

**User Story**: As a user (owner or follower), I want to view the registry so that I can see needed and purchased items.

**Functional Requirements**:
- The system SHALL display registry items in priority order
- The system SHALL separate unpurchased and purchased items
- The system SHALL display item name, description, link, priority
- The system SHALL display purchase status with purchaser name/date
- For followers, the system SHALL aggregate registry from all followed babies
- The system SHALL allow opening product links in external browser

**Acceptance Criteria**:
- ✓ Registry displays all items correctly
- ✓ Items sorted by priority (unpurchased first)
- ✓ Purchased items show purchaser details
- ✓ Product links open in browser
- ✓ Follower sees aggregated registry
- ✓ Registry loads in < 500ms

**Priority**: P0 (Critical)  
**Dependencies**: None

---

## 7. Tile-Based UI System

### FR-7.1: Dynamic Tile Rendering

**User Story**: As a user, I want to see relevant tiles on each screen so that I can access features efficiently.

**Functional Requirements**:
- The system SHALL render tiles based on `tile_configs` and `screen_configs` tables
- The system SHALL load tile configurations from Supabase on app launch
- The system SHALL cache tile configs locally with Hive/Isar
- The system SHALL use TileFactory to instantiate tiles based on type
- The system SHALL respect role-based visibility (owner vs follower)
- The system SHALL order tiles based on `display_order` field
- The system SHALL support dynamic show/hide via `is_visible` flag

**Acceptance Criteria**:
- ✓ Tiles render in correct order per screen
- ✓ Owner sees owner-specific tiles
- ✓ Follower sees follower-specific tiles
- ✓ Hidden tiles do not render
- ✓ Tile configs load from cache on subsequent launches
- ✓ Screen loads in < 500ms

**Priority**: P0 (Critical)  
**Dependencies**: Tile system tables in Supabase

---

### FR-7.2: Role-Based Tile Behavior

**User Story**: As a user with multiple roles, I want tiles to display appropriate content based on my current role.

**Functional Requirements**:
- The system SHALL display editable tiles for owner role
- The system SHALL display read-only tiles for follower role
- The system SHALL aggregate data across all followed babies for followers
- The system SHALL scope data to specific baby for owners
- The system SHALL provide role toggle for users who are both owner and follower

**Acceptance Criteria**:
- ✓ Owner sees edit controls on tiles
- ✓ Follower sees read-only tiles
- ✓ Follower tiles aggregate data from all babies
- ✓ Owner tiles show single baby data
- ✓ Role toggle switches tile behavior correctly

**Priority**: P0 (Critical)  
**Dependencies**: Role management system

---

### FR-7.3: Tile Data Fetching

**User Story**: As a user, I want tiles to load quickly so that I can access information without delay.

**Functional Requirements**:
- The system SHALL fetch tile data independently per tile
- The system SHALL use Supabase queries scoped by RLS policies
- The system SHALL cache tile data locally
- The system SHALL implement pagination (limit per tile, e.g., 5-10 items)
- The system SHALL support infinite scroll for drill-down views
- The system SHALL complete tile data fetch in < 300ms per tile

**Acceptance Criteria**:
- ✓ Each tile loads independently
- ✓ Tiles respect RLS policies
- ✓ Cached data displays immediately
- ✓ Pagination limits initial load
- ✓ Total screen load < 500ms
- ✓ Drill-down loads more data correctly

**Priority**: P0 (Critical)  
**Dependencies**: Supabase RLS, caching strategy

---

### FR-7.4: Real-Time Tile Updates

**User Story**: As a user, I want tiles to update in real-time when content changes so that I always see current information.

**Functional Requirements**:
- The system SHALL subscribe to Supabase Realtime for tile data tables
- The system SHALL scope subscriptions by user role and accessible babies
- The system SHALL update tile UI within 2 seconds of data change
- The system SHALL use `owner_update_markers` for cache invalidation
- The system SHALL batch updates to minimize re-renders

**Acceptance Criteria**:
- ✓ Tile updates appear within 2 seconds of change
- ✓ Subscriptions scope correctly (no unauthorized data)
- ✓ UI updates smoothly without flicker
- ✓ Multiple rapid updates batch correctly
- ✓ Cache invalidates appropriately

**Priority**: P1 (High)  
**Dependencies**: Supabase Realtime

---

## 8. Notifications

### FR-8.1: Push Notifications

**User Story**: As a user, I want to receive push notifications for important updates so that I stay informed.

**Functional Requirements**:
- The system SHALL integrate with OneSignal for push notification delivery
- The system SHALL support opt-in push notifications (request permission on first launch)
- The system SHALL send push notifications for:
  - New photos uploaded (followers)
  - New events created (followers)
  - New registry items added (followers)
  - Comments on user's photos (owners)
  - Registry purchases (owners)
  - Event RSVPs (owners)
  - New followers (owners)
- The system SHALL respect notification preferences per user
- The system SHALL deliver notifications in < 30 seconds

**Acceptance Criteria**:
- ✓ User can opt-in to push notifications
- ✓ Notifications deliver within 30 seconds
- ✓ Notification content is clear and actionable
- ✓ Tapping notification opens relevant screen
- ✓ User can manage notification preferences
- ✓ System respects opt-out preferences

**Priority**: P0 (Critical)  
**Dependencies**: OneSignal integration

---

### FR-8.2: In-App Notifications

**User Story**: As a user, I want to see in-app notifications so that I can review activity history.

**Functional Requirements**:
- The system SHALL display notification feed within app
- The system SHALL persist notifications in `notifications` table
- The system SHALL mark notifications as read/unread
- The system SHALL display unread count badge
- The system SHALL order notifications chronologically (newest first)
- The system SHALL support pagination (30 notifications per page)
- The system SHALL link notifications to relevant content

**Acceptance Criteria**:
- ✓ Notification feed displays all notifications
- ✓ Unread badge shows correct count
- ✓ User can mark notifications as read
- ✓ Tapping notification navigates to relevant content
- ✓ Notifications paginate correctly
- ✓ Feed loads in < 500ms

**Priority**: P1 (High)  
**Dependencies**: None

---

### FR-8.3: Notification Preferences

**User Story**: As a user, I want to customize notification preferences so that I only receive notifications I care about.

**Functional Requirements**:
- The system SHALL provide notification settings screen
- The system SHALL allow granular control:
  - All notifications on/off
  - Push notifications on/off
  - In-app notifications on/off
  - Per-notification-type toggles (photos, events, comments, etc.)
- The system SHALL persist preferences in user profile
- The system SHALL apply preferences immediately

**Acceptance Criteria**:
- ✓ User can access notification settings
- ✓ User can toggle notification types individually
- ✓ Preferences save successfully
- ✓ Changes take effect immediately
- ✓ Push permissions respect OS-level settings

**Priority**: P2 (Medium)  
**Dependencies**: None

---

## 9. Gamification Features

### FR-9.1: Gender Prediction Voting

**User Story**: As a follower, I want to vote on predicted baby gender so that I can participate in fun activities.

**Functional Requirements**:
- The system SHALL allow followers to vote once on gender prediction
- The system SHALL support Boy, Girl, or Surprise options
- The system SHALL prevent vote changes after submission
- The system SHALL display vote count to owner only
- The system SHALL reveal votes to all users after baby birth announcement
- The system SHALL identify correct predictors

**Acceptance Criteria**:
- ✓ Follower can vote once on gender
- ✓ System prevents multiple votes
- ✓ Votes remain hidden until birth
- ✓ Results reveal after birth announcement
- ✓ Correct predictors are highlighted

**Priority**: P2 (Medium)  
**Dependencies**: Baby profile with unknown gender

---

### FR-9.2: Birth Date Prediction

**User Story**: As a follower, I want to predict the baby's birth date so that I can participate in friendly competition.

**Functional Requirements**:
- The system SHALL allow followers to vote once on predicted birth date
- The system SHALL enforce date within reasonable range (±30 days of expected date)
- The system SHALL prevent vote changes after submission
- The system SHALL display predictions to owner
- The system SHALL identify closest predictor after birth

**Acceptance Criteria**:
- ✓ Follower can submit birth date prediction
- ✓ System validates date range
- ✓ System prevents multiple predictions
- ✓ Owner sees all predictions
- ✓ Closest predictor identified after birth

**Priority**: P2 (Medium)  
**Dependencies**: Baby profile with expected date

---

### FR-9.3: Name Suggestions and Voting

**User Story**: As a follower, I want to suggest baby names and vote on suggestions so that I can participate in naming process.

**Functional Requirements**:
- The system SHALL allow followers to suggest one name per gender
- The system SHALL allow users to vote on suggested names
- The system SHALL display name suggestions with vote counts
- The system SHALL sort names by vote count
- The system SHALL allow owners to mark chosen name
- The system SHALL hide name suggestions after baby is born (optional)

**Acceptance Criteria**:
- ✓ Follower can suggest one name per gender
- ✓ Users can vote on multiple names
- ✓ Names sort by vote count
- ✓ Owner can mark chosen name
- ✓ Suggestions work for both genders

**Priority**: P2 (Medium)  
**Dependencies**: Baby profile

---

### FR-9.4: Activity Counters

**User Story**: As a user, I want to see my activity statistics so that I can track my engagement.

**Functional Requirements**:
- The system SHALL track activity counters in `user_stats` table:
  - Events attended (RSVP'd Yes)
  - Items purchased from registry
  - Photos squished (liked)
  - Comments added
- The system SHALL display counters in user profile
- The system SHALL increment counters via database triggers
- The system SHALL support gamification leaderboards (future)

**Acceptance Criteria**:
- ✓ Counters display in user profile
- ✓ Counters increment correctly on actions
- ✓ Counters persist across sessions
- ✓ Counters are accurate and consistent

**Priority**: P2 (Medium)  
**Dependencies**: User stats table and triggers

---

## 10. Baby Countdown and Announcements

### FR-10.1: Baby Countdown

**User Story**: As a user, I want to see a countdown for babies arriving soon so that I can anticipate the birth.

**Functional Requirements**:
- The system SHALL display countdown tile for babies within 10 days of expected birth
- The system SHALL calculate days remaining until expected date
- The system SHALL display countdown prominently on home screen
- The system SHALL hide countdown after baby is born
- The system SHALL show "Any day now!" for babies past expected date

**Acceptance Criteria**:
- ✓ Countdown appears within 10 days of expected date
- ✓ Days remaining calculate correctly
- ✓ Countdown displays prominently
- ✓ Countdown disappears after birth announcement
- ✓ Overdue shows "Any day now!" message

**Priority**: P1 (High)  
**Dependencies**: Baby profile with expected date

---

### FR-10.2: Birth Announcement

**User Story**: As a baby profile owner, I want to announce my baby's birth so that I can share the exciting news with all followers.

**Functional Requirements**:
- The system SHALL provide birth announcement form
- The system SHALL require baby name, birth date, birth time
- The system SHALL allow optional weight, length, first photo
- The system SHALL send push notifications to all followers
- The system SHALL display announcement prominently on home screen
- The system SHALL update baby profile with actual birth information
- The system SHALL support Instagram sharing with Nonna watermark

**Acceptance Criteria**:
- ✓ Owner can create birth announcement
- ✓ All required fields validate correctly
- ✓ Announcement sends notifications to all followers
- ✓ Announcement appears at top of home screen
- ✓ Baby profile updates with birth info
- ✓ Instagram sharing works correctly

**Priority**: P1 (High)  
**Dependencies**: Instagram sharing integration

---

## 11. Additional Features

### FR-11.1: Email Digest

**User Story**: As a user, I want to receive email digests of activity so that I can stay informed without constantly checking the app.

**Functional Requirements**:
- The system SHALL send weekly or monthly email digests (user preference)
- The system SHALL include summary of:
  - New photos uploaded
  - Upcoming events
  - Registry updates
  - New comments
- The system SHALL personalize digest by user role (owner vs follower)
- The system SHALL filter by followed babies for followers
- The system SHALL use SendGrid for email delivery
- The system SHALL allow users to opt-out

**Acceptance Criteria**:
- ✓ Users receive digest at configured interval
- ✓ Digest includes relevant activity summary
- ✓ Content personalizes by role
- ✓ Users can change digest frequency
- ✓ Users can opt-out completely
- ✓ Email renders correctly on mobile and desktop

**Priority**: P2 (Medium)  
**Dependencies**: SendGrid integration

---

### FR-11.2: Memory Lane

**User Story**: As a user, I want to see throwback content so that I can reminisce about past moments.

**Functional Requirements**:
- The system SHALL display "On this day" content from previous years
- The system SHALL show photos/events from same date in previous years
- The system SHALL display Memory Lane tile on home screen
- The system SHALL support role-based filtering (owners per baby, followers aggregated)
- The system SHALL allow users to share memory content

**Acceptance Criteria**:
- ✓ Memory Lane shows content from previous years
- ✓ Content filters by same date
- ✓ Tile displays when memories exist
- ✓ Users can view full memory details
- ✓ Role-based filtering works correctly

**Priority**: P2 (Medium)  
**Dependencies**: Photo gallery history

---

### FR-11.3: Storage Management

**User Story**: As a user, I want to see my storage usage so that I can manage my content.

**Functional Requirements**:
- The system SHALL enforce 15GB storage limit for free tier users
- The system SHALL provide unlimited storage for paid tier users
- The system SHALL display storage usage in settings
- The system SHALL show breakdown by content type (photos, videos, documents)
- The system SHALL warn users approaching storage limit (90%)
- The system SHALL prevent uploads when limit reached (free tier)

**Acceptance Criteria**:
- ✓ Storage usage displays accurately
- ✓ Breakdown shows content types
- ✓ Warning appears at 90% usage
- ✓ Free tier users blocked at 15GB
- ✓ Paid tier users have unlimited storage

**Priority**: P2 (Medium)  
**Dependencies**: Storage tracking system

---

### FR-11.4: Role Toggle

**User Story**: As a user who is both owner and follower, I want to toggle between roles so that I can access relevant views.

**Functional Requirements**:
- The system SHALL detect users with multiple roles
- The system SHALL provide role toggle control
- The system SHALL switch tile visibility based on selected role
- The system SHALL persist role selection per session
- The system SHALL allow filtering by specific baby when in follower mode

**Acceptance Criteria**:
- ✓ Toggle appears for users with multiple roles
- ✓ Switching role updates tile display
- ✓ Role selection persists during session
- ✓ Filter allows selecting specific baby
- ✓ Switching is smooth and instant

**Priority**: P1 (High)  
**Dependencies**: Role detection system

---

## Traceability Matrix

### Business Requirements → Functional Requirements Mapping

| Business Requirement | Functional Requirements |
|---------------------|------------------------|
| Private Family Social Platform | FR-1.x (Authentication), FR-3.x (Invitations), FR-2.x (Baby Profiles) |
| High User Engagement | FR-4.x (Photo Gallery), FR-5.x (Calendar), FR-6.x (Registry), FR-9.x (Gamification) |
| Product-Market Fit | All FR categories - comprehensive feature set |
| Scale to 10K Concurrent Users | Performance requirements embedded in all FRs |
| Market Differentiation | FR-7.x (Tile System), FR-9.x (Gamification), FR-11.x (Memory Lane) |

### User Personas → Functional Requirements Mapping

| Persona | Primary Functional Requirements |
|---------|--------------------------------|
| Sarah (Owner) | FR-2.x (Baby Profile), FR-4.1 (Photo Upload), FR-5.1 (Create Events), FR-6.1 (Create Registry), FR-10.2 (Birth Announcement) |
| Robert (Co-Owner) | FR-2.4 (Co-Owner Management), FR-4.1 (Photo Upload), FR-11.4 (Role Toggle) |
| Linda (Grandparent) | FR-3.2 (Accept Invitation), FR-4.3 (View Gallery), FR-4.5 (Squish Photos), FR-5.4 (RSVP), FR-6.4 (Purchase Registry) |
| Jessica (Friend) | FR-3.2 (Accept Invitation), FR-4.6 (Comment), FR-5.4 (RSVP), FR-9.3 (Name Voting) |

### Success Metrics → Functional Requirements Mapping

| KPI | Supporting Functional Requirements |
|-----|-----------------------------------|
| User Registration Rate | FR-1.1 (Registration), FR-1.3 (Login) |
| Feature Adoption (Photo Gallery) | FR-4.1 (Upload Photos), FR-4.3 (View Gallery) |
| Engagement (DAU/MAU) | FR-4.5 (Squish), FR-4.6 (Comment), FR-5.4 (RSVP) |
| Viral Coefficient | FR-3.1 (Send Invitations), FR-3.2 (Accept Invitation) |
| Session Duration | FR-7.x (Tile System providing multiple engagement points) |

## Validation and Testing Strategy

### Functional Testing
- Each functional requirement SHALL have corresponding test cases
- Test cases SHALL validate all acceptance criteria
- Automated tests SHALL cover critical paths (authentication, photo upload, invitation flow)
- Manual tests SHALL cover user experience flows per user journey maps

### User Acceptance Testing
- Test participants SHALL match user personas (Sarah, Linda, Jessica)
- UAT SHALL validate requirements against user stories
- UAT SHALL include end-to-end scenarios from user journey maps

### Performance Testing
- Load tests SHALL validate requirements under target load (10K concurrent users)
- Performance tests SHALL verify <500ms interaction times
- Real-time update tests SHALL validate <2 second delivery

### Security Testing
- Penetration tests SHALL validate authentication and authorization
- RLS policy tests SHALL ensure proper data access controls
- Input validation tests SHALL prevent injection attacks

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Team  
**Status**: Final  
**Next Review**: Before Development Phase Begins
