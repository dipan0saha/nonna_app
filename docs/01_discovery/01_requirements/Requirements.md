# Nonna App Requirements

## 1. Introduction

Nonna is a mobile application designed to bridge the distance between new parents and their loved ones. In a world where many families live apart, Nonna provides a dedicated and private space to share the journey of pregnancy and parenting. The app enables users to share updates, celebrate milestones, and feel connected, regardless of geographical distance. The target audience includes tech-savvy new parents, their families, and friends who want to be part of these important life events.

## 2. User Roles and Permissions

The application will have two primary user roles with distinct permissions:

### 2.1. Parents (Owners)

-   Can create, edit, and delete baby profiles (maximum of two owners per profile).
-   Can invite Friends & Family to follow a baby profile via email. Invitations must include a unique link that expires after 7 days.
-   Can manage the list of followers (view, resend, and revoke invitations).
-   Have full control over the content of their baby profile, including the calendar, baby registry, photo gallery and fun (add, edit, delete).
-   Can delete comments made by any user on their baby profile's content.
-   Cannot remove themselves as an owner if they are the only owner of a baby profile. Must delete baby profile, and when baby profile doesn't have any owners it automatically gets deactivated

### 2.2. Friends & Family (Followers)

-   Can only access a baby profile after accepting an email invitation.
-   Upon acceptance, users must provide their relationship (e.g., Grandma, Grandpa, Aunt, Uncle, Godmother, Godfather, Family Friend) from a predefined list. 
-   Can view the baby profile, calendar, baby registry, photo gallery and fun.
-   Can interact with content by RSVPing to events, commenting, "squishing" photos (liking), marking registry items as purchased, voting in gender/birthdate/name and suggesting names. 
-   Cannot create, edit, or delete baby profiles, events, registry items, photos or fun.
-   Cannot invite or manage other followers.
-   Can remove themselves from a baby profile at any time.

## 3. Functional Requirements

### 3.1. Account Creation and Management

-   Users must be able to create an account with a unique email and a password (minimum 6 characters, with at least one number or special character).
-   Email verification is required for new accounts before the first login.
-   Passwords must be securely hashed.
-   Users must be able to log in with their registered credentials.
-   A secure password reset option via email must be available.

### 3.2. Baby Profile

-   A baby profile is the central hub for each baby.
-   Only Parents (Owners) can create and manage baby profiles.
-   Each baby profile contains:
    -   Baby's Name (editable) - if NO baby name was added, defaults to Baby + <Father's Last Name>. If baby has 2 fathers, defaults to last name of user who created baby profile
    -   Profile Photo (optional, upload/change)
    -   Expected Birth Date (optional, editable)
    -   Gender (optional, editable)
    -   Name (optional, editable)
-   Logic - expected birthdate, and gender should inform what tiles are shown and should also inform what products are suggested by AI for the registry and what events are suggested by AI for the calendar. 
-   Each baby profile has its own private calendar, baby registry, photo gallery and fund.
-   Parents (Owners) will receive a notification when baby profile has a new follower and should be added to recent activity.


### 3.3. Calendar

-   A shared calendar for each baby profile to track important events (e.g., ultrasounds, gender reveals).
-   Only Parents (Owners) can add, edit, or delete events.
-   All followers can view events, RSVP, and add comments.
-   Event details include name, date, a short description, optional photo (optional), video conference link (optional), location (optional).
-   Parents (Owners) will receive a notification when an RSVP or comment is made and should be added to recent activity.
-   AI suggestions allows baby profile owners (only) to see list of events that could be added to the calendar. events are organized by different stages in life of the baby.
-   Followers get a notification when a new event is added to the calendar. (THIS MIGHT BE TOO MUCH, WE SHOULD DISCUSS)


### 3.4. Registry (Baby List)

-   A list of desired baby items.
-   Only Parents (Owners) can add, edit, or delete items from the registry.
-   Each item includes a name, short description and link (optional).
-   All followers can view the registry and mark items as "purchased."
-   Purchased items will be moved to the bottom of the list and will show the name of the user who purchased them and a timestamp of the purchase.
-   Parents (Owners) will receive a notification when an item is purchased and should be added to recent activity.
-   Followers get a notification when a new item is added to the registry. (THIS MIGHT BE TOO MUCH, WE SHOULD DISCUSS)
-   AI Suggestions allows baby profile owners (only) to see list of items they could add to their registry. it is broken out by ages and products that are great of each stage of the baby life. 

### 3.5. Photo Gallery

-   A shared gallery for photos of the pregnancy and newborn.
-   Photos must be in JPEG or PNG format and are limited to 10MB per photo. (SHOULD WE OPEN THIS UP TO OTHER FILE TYPES?)
-   Only Parents (Owners) can upload, edit, or delete photos.
-   Photos can be uploaded from the user's device storage or taken with the camera.
-   Each photo can have a short caption.
-   All followers can view, comment on, and "squish" (like) photos. A user can only "squish" a photo once.
-   The gallery will be sorted by upload date, with the most recent photos at the top.
-   Followers get a notification when a new photo is added to the gallery. (THIS MIGHT BE TOO MUCH, WE SHOULD DISCUSS)

### 3.6. Navigation Bar

-   An intuitive navigation bar will provide easy access to the main sections of the app: Home, Gallery, Calendar, Registry, Photo Gallery, and Fun.

### 3.7. Gamification

-   **Voting:** Friends & Family can vote on the baby's predicted birth date, gender and names. Voting must be anonymous until the results are revealed. Results are displayed publicly to all followers after the Parents (Owners) enter the actual birth date, with name.
-   **Name Suggestions:** Friends & Family can suggest baby names. The system should not allow for duplicate name suggestions and should limit to 1 suggestion per user per gender.
-   **Activity Counters:** User profiles will display counters for the number of events attended, items purchased, photos squished, and comments added to encourage engagement.

### 3.8. Welcome Screens (V2)

-   A set of welcome screens to explain the app's main features and how to use them.

### 3.9. Social Sharing - DISREGARD

-   Users can share events, photos, or milestones via the native sharing capabilities of their device (e.g., iOS Share Sheet).
-   Sharing will be limited to invited users only, with privacy controls to prevent public sharing.

### 3.10. Notifications

-   Notifications must be push-enabled (opt-in) and in-app.
-   Parents (Owners) will receive notifications for all new content and interactions (e.g., new comments, purchased items).
-   All users will receive notifications for new events, photos, and registry. should also receive notifications if other users LIKE their name suggestion

### 3.11. Toggle Between Owner and Follower

-   Top right of the screen has photo that has dropdown which allows user to easily switch between baby profiles.
-   Sort ordered should be with Baby profiles owned on top, and baby profiles followed below
-   once a selection is made, a filter should be applied to the rest of the app that shows only content that belongs to that baby profile selcted

### 3.12. Filtering Baby Profiles

-   Gallery, Calendar, Registry, and Fun should have a filter that allows user to select which baby they want to see activity for.
-   Content should belong only to the Baby profile selected.
-   Reset filter should be available. 

### 3.13. Baby Countdown and Baby Announcement

-   Home screen should show a countdown of all baby profiles that are within 10 days of their expected date. Countdown should say "Baby Name is arriving in less than X days!"
-   Countdown visible for baby followers only
-   Baby Arrival Announcement - visible for baby profile owners only, allows profile owners to complete information and submit and share the news with everyone that their baby is born.
-   Notification is sent to all baby profile followers, and Baby Announcement is placed on top of the Home screen for all users.
-   Baby Announcement is visible by all users, comments and baby squishes are allowed by all users.
-   Baby Announcement should have a Share in Instagram feature (only available for Profile Owners)

## 4. Non-Functional Requirements

### 4.1. Performance

-   The application must be responsive, with a response time under 500ms for all user interactions.
-   All real-time updates (e.g., new comments, purchased items) must propagate to all users within 2 seconds for up to 10,000 concurrent users.
-   Photo uploads should take less than 5 seconds.
-   The mobile application must be available for iOS and Android.

### 4.2. Security

-   All data must use AES-256 encryption at rest and TLS 1.3 in transit.
-   The application must implement OAuth 2.0 for authentication and Role-Based Access Control (RBAC) using JWT tokens.
-   Access to baby profiles and their content must be strictly limited to invited users.

### 4.3. Usability and Design

-   The UI should be modern, playful, and sophisticated, with a focus on ease of use.
-   The UI must support both light and dark modes.
-   The design must be responsive and adapt to various screen sizes (smartphones and tablets).
-   The app must adhere to WCAG AA standards for color contrast and accessibility, and include tooltips or other helpers for accessibility.

### 4.4. Scalability

-   The system should be able to handle up to 10,000 concurrent users.
-   The database must be able to support up to 1 million baby profiles and be designed for horizontal scaling.
-   A baby registry should support up to 500 items.
-   A photo gallery should support up to 1,000 photos.

## 5. Error Handling

-   The application must display user-friendly error messages for failed operations (e.g., failed uploads, invalid inputs).
-   Error messages should be clear and provide guidance on how to resolve the issue where possible.

## 6. Data Retention

-   User data must be retained for 7 years post-account deletion to comply with data retention policies.

## 7. Assumptions and Constraints

-   The initial launch will be a mobile-first design for iOS and Android, with no web version.
-   The project relies on third-party services for email delivery and push notifications.
-   Photo storage will be handled by a third-party cloud storage provider.

## 8. Glossary

-   **Parents (Owners):** The primary users who create and manage a baby profile.
-   **Friends & Family (Followers):** Invited users who can view and interact with a baby profile.
-   **Squish:** A "like" action on a photo.
-   **RSVP:** A response to an event invitation (attending, not attending, maybe).
