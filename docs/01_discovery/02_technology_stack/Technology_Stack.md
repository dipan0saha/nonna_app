# Technology Stack for Nonna-App

This document outlines the definitive technology stack and architectural strategies for the Nonna-App, chosen based on a detailed analysis of the project requirements.

## 1. Core Technologies

*   **Frontend (Mobile App):** **Flutter**
    *   **Why:** A high-performance, cross-platform UI toolkit for building beautiful, natively compiled applications for iOS and Android from a single codebase.
*   **Backend as a Service (BaaS):** **Supabase**
    *   **Why:** An open-source Firebase alternative built on enterprise-grade technologies. Its PostgreSQL foundation is the ideal choice for the Nonna-App's relational data structure.

## 2. Backend Architecture (Supabase)

### 2.1. Authentication & Role-Based Access Control (RBAC)

*   **Service:** **Supabase Auth**
*   **Implementation:** Secure, JWT-based authentication will be used.
    *   **Email/password:** Used for the MVP requirements (email verification + password reset).
    *   **OAuth 2.0:** Supabase supports OAuth 2.0 providers if social login is added later; the app will still consume Supabase JWTs for session access.
    *   **Password policy enforcement:** The Flutter app will enforce the password rules (min 6 chars + at least one number/special character) before calling sign-up. If stricter enforcement is required server-side, sign-up can be routed via an Edge Function that validates input before creating the user.
    *   **Session storage:** On-device session tokens will be stored using secure storage (iOS Keychain / Android Keystore) via Flutter secure storage.
*   **Role Modeling (Important Note):** Roles like "Parent (Owner)" and "Follower" are **relationship-specific to a baby profile**, not global to a user account. Therefore:
    *   The `profiles` table stores the centralized user profile (name, email, photo, etc.).
    *   A join table (e.g., `baby_profile_memberships`) stores per-baby permissions and the relationship label (Mother, Father, Grandma, etc.).
*   **RBAC Enforcement:** Granular permissions will be enforced in the database using PostgreSQL's **Row-Level Security (RLS)**.
    *   **Example RLS Policy (for photos):** A policy on the `photos` table would ensure that only owners of the parent `baby_profile` can create/delete photos, while followers can only view them.
    *   **Frontend enforcement:** The Flutter app will also hide/disable UI actions based on membership role, but the database remains the source of truth.

### 2.2. Database (PostgreSQL)

*   **Core Data Modeling (to satisfy the requirements):**
    *   `profiles` (1:1 with `auth.users`): centralized user info.
    *   `baby_profiles`: baby details.
    *   `baby_profile_memberships`: maps users to baby profiles with role (OWNER/FOLLOWER) and relationship label; enforces "max two owners" constraint.
    *   `invitations`: invite email, baby_profile_id, token, `expires_at` (7 days), `revoked_at`, `accepted_at`.
    *   `events`, `event_comments`, `event_rsvps`: calendar + interactions.
    *   `registry_items`, `registry_comments`, `registry_purchases` (or purchase fields on item): ensures purchaser name + timestamp.
    *   `photos`, `photo_comments`, `photo_squishes`: ensures "one squish per user".
    *   `notifications`: in-app notification feed for each user (distinct from push delivery).
*   **Constraints & Indexing:**
    *   Indexes on foreign keys and hot query fields (e.g., `baby_profile_id`, `created_at`, `event_date`) to meet the 500ms interaction target.
    *   Enforce limits such as "max 2 events per day" via database constraint or trigger.
    *   Enforce "max two owners per baby profile" via constraint/trigger on `baby_profile_memberships`.

*   **Backups & Disaster Recovery (Operational Requirement):**
    *   Enable automated database backups and document restore procedures (RPO/RTO targets) for production.
    *   Periodically test restores in a non-production environment to ensure recoverability.

*   **Real-Time Implementation:**
    *   **Why:** To meet the requirement for live updates (new comments, registry changes), **Supabase Realtime** will be enabled. It listens to database changes via PostgreSQL's logical replication and broadcasts them over websockets.
    *   **Flutter Integration:** The Flutter app will use the `supabase_flutter` package to subscribe to these changes as a `Stream`.
    *   **Scope control:** Realtime subscriptions will be scoped per baby profile and per table to minimize bandwidth and help meet the "updates within 2 seconds" requirement.

*   **Data Retention Strategy:**
    *   **Implementation:** To comply with the 7-year data retention requirement, a **"soft delete"** pattern will be used. Tables with user-generated content will include an `is_deleted` boolean flag and a `deleted_at` timestamp.
    *   **Process:** When a user deletes content, these flags are set. The data remains in the database for archival but is excluded from all application queries. A scheduled **Supabase Edge Function** can be configured to permanently delete or archive data after the retention period.
    *   **Account deletion:** An account deletion request will deactivate access (Auth user disabled / session revoked) while retaining profile and content rows for the retention period.

### 2.3. File Storage & Media Delivery

*   **Service:** **Supabase Storage**
*   **Bucket Strategy:** Separate buckets for `baby_profile_photos`, `event_photos`, and `gallery_photos` (or a single bucket with folder prefixes), with policies enforced by RLS-backed signed URLs.
*   **Upload Rules (requirements alignment):**
    *   Accept only JPEG/PNG.
    *   Enforce a max 10MB per photo.
    *   Prefer client-side compression/resizing in Flutter to hit the "< 5 seconds upload" target.
*   **Thumbnails:** Generate thumbnails on upload (Edge Function) and store them alongside originals to keep gallery listing fast.
*   **Delivery:** Use CDN-backed delivery (Supabase Storage) and cache images on device to reduce repeated downloads.

### 2.4. Serverless Logic & Third-Party Integrations

*   **Service:** **Supabase Edge Functions** (TypeScript)
*   **Usage:** For secure, server-side logic and integration with external APIs.
*   **Specified Providers:**
    *   **Push Notifications:** **OneSignal**. An Edge Function will be triggered by a database event (e.g., a new photo is inserted) and will make a secure API call to OneSignal to send push notifications to relevant users.
    *   **Transactional Email:** **SendGrid**. For sending welcome emails, password resets, and invitations, an Edge Function will call the SendGrid API.
*   **Invitation Links (7-day expiry):**
    *   Create invite tokens in the `invitations` table with `expires_at`.
    *   Email the recipient a deep link containing the token.
    *   An Edge Function validates token status (not expired/revoked/used) and completes acceptance.

### 2.5. Security & Encryption

*   **Data in Transit:** All connections to Supabase (including database and storage) are secured with **TLS 1.3**, meeting the requirement.
*   **Data at Rest:** The underlying infrastructure providers for Supabase (e.g., AWS) configure PostgreSQL databases with **AES-256** encryption for all data at rest, satisfying the security requirement.
*   **Authorization Hardening:**
    *   Use RLS on all tables that reference a baby profile.
    *   Use least-privilege service role keys only inside Edge Functions.
    *   Store OneSignal/SendGrid secrets in Edge Function environment variables.

*   **Abuse Prevention & Rate Limiting (Operational Requirement):**
    *   Apply rate limits for sensitive flows such as login attempts, invitation sends/resends, and comment creation.
    *   Implement basic anti-spam controls (e.g., per-user/per-baby-profile caps) via database constraints and/or Edge Function validation.

### 2.6. Notifications (In-App + Push)

*   **In-App Notifications:** Persist notifications in a `notifications` table (recipient, type, payload, read/unread, created_at) so users can view notification history inside the app.
*   **Push Notifications:** OneSignal delivers push notifications to devices.
*   **Delivery Pattern:**
    *   Insert a notification row in DB for events like new photo, new event, purchased item.
    *   Trigger Edge Function to send push notifications to recipients (respecting opt-in).
    *   The Flutter app subscribes to `notifications` via Realtime for immediate in-app updates.

## 3. Frontend Architecture (Flutter)

### 3.1. UI/UX & Accessibility

*   **Theming:** Flutter's built-in `MaterialApp` theming capabilities will be used to support both **light and dark modes**.
*   **Accessibility (WCAG AA):** Compliance will be a continuous effort.
    *   **Tools:** Flutter's `Semantics` widget will be used to provide accessibility information. The `flutter_lints` package will be configured with accessibility rules.
    *   **Accessibility helpers:** Use Flutter widgets like `Tooltip`, proper focus order, and text scaling support to meet accessibility expectations.
    *   **Testing:** Automated accessibility checks will be part of the testing pipeline using tools compatible with Flutter.

### 3.2. State Management & Navigation

*   **State Management:** Use **BLoC** (or Provider for simpler screens) to keep business logic testable and to handle realtime streams cleanly.
*   **Navigation:** Use **GoRouter** for structured routing and deep link handling.
    *   **Deep links:** Used for invitation acceptance flows (the 7-day expiring token links).

### 3.3. Error Handling & User-Friendly Messaging

*   **Client Errors:** Wrap Supabase/API/storage failures into a small, consistent set of error types mapped to user-friendly messages (matching the requirements).
*   **Crash/Error Reporting:** Send unexpected errors to Sentry with enough context (screen, baby_profile_id, user action) to diagnose quickly.

### 3.4. Social Sharing (Device Native)

*   **Implementation:** Use the OS share sheet via a Flutter sharing package (e.g., `share_plus`).
*   **Privacy controls:** Only allow sharing of content that is explicitly marked shareable and avoid generating public links by default.

## 4. Quality & Performance

### 4.1. Testing Strategy

*   **Unit & Widget Testing:** `flutter_test` and `mockito` for testing individual functions, classes, and widgets in isolation.
*   **Integration & End-to-End (E2E) Testing:** The `integration_test` package will be used to write tests that run on a real device or simulator, verifying complete user flows (e.g., logging in, uploading a photo, and commenting).
*   **Backend Testing:** RLS policies and database functions will be tested using a framework like `pg_prove`.
*   **Local Dev & Parity:** Use Supabase local development tooling (CLI + local Postgres) so migrations, RLS, triggers, and Edge Functions can be tested in CI.

### 4.2. Scalability & Performance

*   **Database Scaling:** The initial strategy will be to ensure proper **database indexing** on frequently queried columns. As the app grows, Supabase's infrastructure allows for scaling, including the use of **read replicas** to distribute load for high-traffic queries.
*   **Image/Asset Delivery:** **Supabase Storage** uses a CDN by default to cache and serve images, ensuring fast delivery to users globally.
*   **Performance Monitoring:** In addition to stability monitoring, **Sentry** or **Datadog** will be used to track app performance metrics (e.g., screen load times, API latency) to identify and resolve bottlenecks.
*   **Meeting the 500ms interaction target:**
    *   Prefer pagination/infinite scroll for lists (gallery, registry, events).
    *   Use thumbnails for grids.
    *   Cache aggressively on-device for images and session data.
    *   Avoid large fan-out realtime subscriptions; scope to baby profile and relevant tables.

### 4.3. Stability Monitoring

*   **Recommendation:** **Sentry**
*   **Why:** Essential for monitoring the app's stability in real-time by automatically tracking, prioritizing, and debugging crashes and errors that occur on users' devices.

### 4.4. Backend Observability

*   **Edge Function Monitoring:** Capture structured logs and error reports for Edge Functions (invites, notifications, image processing) and forward critical failures to Sentry.
*   **Database Observability:** Track slow queries and realtime throughput to proactively maintain the 500ms interaction target.

## 5. DevOps

*   **CI/CD:** **GitHub Actions** will be used to automate building, testing (including accessibility and E2E tests), and deploying the app to the Apple App Store and Google Play Store.
*   **Secrets & Config:** Store Supabase/OneSignal/SendGrid configuration as environment variables in CI and in app build flavors (dev/stage/prod).
*   **Database Migrations:** Manage schema and RLS changes as versioned migrations (Supabase CLI) to keep environments reproducible.

## 6. Product Analytics (Optional, KPI Support)

To support product success metrics (active users, retention, feature engagement), integrate an analytics platform.

*   **Recommendation:** Privacy-conscious product analytics (e.g., Amplitude, Mixpanel, or a lightweight alternative).
*   **Scope:** Track high-level events only (signup completed, invite sent/accepted, event created, item purchased, photo uploaded), and avoid sensitive content in analytics payloads.

## 7. Glossary

*   **Parent (Owner):** A primary user who creates and manages a baby profile.
*   **Follower:** An invited user who can view and interact with a baby profile.
*   **Squish:** The action of "liking" a photo.
*   **RSVP:** A response to an event invitation (attending, not attending, maybe).
*   **RLS:** Row-Level Security, a PostgreSQL feature used to control data access per user.
*   **Realtime:** Supabase feature that broadcasts database changes over websockets.
*   **Deep Link:** A URL that opens the app to a specific screen (e.g., invitation acceptance).

## 8. Requirements-to-Stack Mapping

This section provides a quick trace from key requirements to the selected technologies and implementation approach.

| Requirement Area | Requirements (Summary) | Technology / Service | Free Limits | Implementation Notes |
|---|---|---|---|---|
| Account creation & login | Email/password, email verification, password reset, hashed passwords | Supabase Auth | 50,000 MAU, unlimited auth operations | Use email/password sign-up with email verification; password reset emails via Supabase/SendGrid integration; tokens stored securely on-device. |
| Authorization / RBAC | Owners vs Followers; enforce in backend + frontend | Postgres RLS + Supabase Auth JWT + Flutter UI gating | Included in Supabase free tier | Model roles per baby profile in `baby_profile_memberships`; enforce access with RLS; Flutter hides/disables actions but DB is source of truth. |
| Invitations | Owners invite via email; unique link; expires in 7 days; accept + choose relationship | Postgres (`invitations`) + Edge Functions + SendGrid + Deep Links | SendGrid: 100 emails/day; Edge Functions: 100,000 invocations/month | Create token with `expires_at`; send deep link; Edge Function validates token and creates membership after relationship selection. |
| Baby profile | Create/edit/delete by owners; max two owners | Postgres constraints + RLS | Included in Supabase free tier | Enforce max owners via constraint/trigger on memberships; RLS restricts writes to owners. |
| Calendar | Owners CRUD; followers view; comments + RSVP; max 2 events/day | Postgres + Realtime + RLS | Included in Supabase free tier | Enforce 2 events/day via constraint/trigger; `event_comments` and `event_rsvps` tables; realtime streams for updates. |
| Baby registry | Owners CRUD items; followers mark purchased; show purchaser + timestamp | Postgres + Realtime + RLS | Included in Supabase free tier | Store purchase metadata (purchaser + timestamp) in item or purchases table; realtime updates for reorder/move-to-bottom UX. |
| Photo gallery | Owners upload/edit/delete; followers view/comment/squish once; JPEG/PNG <= 10MB; newest first; fast uploads | Supabase Storage + Postgres + Edge Functions + Realtime | Storage: 500MB; Edge Functions: 100,000 invocations/month | Validate file type/size; client-side compression; thumbnail generation; `photo_squishes` unique per (user, photo). |
| Notifications | Push-enabled (opt-in) + in-app; owners get interactions; everyone gets new events/photos | OneSignal + Postgres (`notifications`) + Edge Functions + Realtime | OneSignal: 10,000 subscribers, unlimited notifications; Edge Functions: 100,000 invocations/month | Insert in-app notification rows; Edge Function triggers push delivery; app subscribes to `notifications` for instant in-app updates. |
| Performance | <500ms interactions; realtime within 2s; uploads <5s | Postgres indexing + Realtime scoping + CDN + caching | Included in Supabase free tier | Index hot query columns; scope realtime subscriptions; use thumbnails; cache images; compress before upload. |
| Security | TLS 1.3 in transit; AES-256 at rest; invite-only access | Supabase (TLS) + encrypted storage at rest + RLS + secrets management | Included in Supabase free tier | RLS everywhere; least-privilege service role in Edge Functions; store provider secrets in env vars. |
| Accessibility | WCAG AA, tooltips/helpers, text scaling | Flutter Semantics + theming + linting + tests | Free (open-source) | Use Semantics, focus management, Tooltips, text scaling; include accessibility checks in CI where practical. |
| Error handling | User-friendly error messages | Flutter error mapping + Sentry | Sentry: 5,000 events/month, 1 user | Normalize errors from Supabase/storage; show actionable messages; report unexpected failures to Sentry. |
| Data retention | Retain 7 years post-account deletion | Soft delete + scheduled Edge Function | Included in Supabase free tier | Soft-delete records and revoke access; retain for archival; scheduled cleanup/archival after retention period. |
| DevOps | CI/CD, reproducible environments | GitHub Actions + Supabase CLI | GitHub Actions: 2,000 minutes/month (free account) | Build/test/deploy pipeline; run migrations/RLS changes consistently across dev/stage/prod. |
| Backups & DR | Recoverability and continuity | Supabase/Postgres backups | Basic backups included | Enable automated backups; document and test restore procedures. |
| Abuse prevention | Prevent invite/login/comment abuse | Edge Functions + DB constraints | Edge Functions: 100,000 invocations/month | Rate limit sensitive flows and enforce caps to reduce spam/abuse. |
| Analytics (optional) | KPI tracking (engagement/retention) | Analytics SDK | Varies by provider (e.g., Amplitude free tier: 10M events/month) | Track only high-level events; avoid sensitive payloads. |
