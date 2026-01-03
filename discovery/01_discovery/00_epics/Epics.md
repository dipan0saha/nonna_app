# Nonna App Project Epics

This document outlines the 37 epics for the Nonna App project in logical order, covering pre-development and development phases. Each epic includes high-level stories to break down the work.

## Epic 1: Feasibility Study
**Goal**: Evaluate technical and financial viability.

- **Story 1.1**: As a product owner, I want a feasibility study on Supabase scalability (e.g., 10,000 users, real-time updates) and cost estimates.

## Epic 2: Risk Assessment
**Goal**: Identify and mitigate operational risks.

- **Story 2.1**: As a team, I want to identify risks (e.g., data breaches, third-party failures) and create mitigation plans.
- **Story 2.2**: As a developer, I want to assess Flutter performance on Android for photo uploads and notifications.

## Epic 3: Security and Privacy Planning
**Goal**: Design proactive security and privacy measures.

- **Story 3.1**: As a developer, I want to design data encryption for photos and profiles.
- **Story 3.2**: As a team, I want a threat model for auth and storage.

## Epic 4: Vendor and Tool Selection
**Goal**: Evaluate and select external tools and vendors.

- **Story 4.1**: As a team, I want to evaluate and select vendors (e.g., Supabase vs. Firebase) based on cost, scalability, and compliance.

## Epic 5: Sustainability and Scalability Planning
**Goal**: Plan for long-term environmental and growth needs.

- **Story 5.1**: As a team, I want to plan for sustainable development (e.g., efficient data storage) and scalability beyond 10,000 users.

## Epic 6: Discovery Phase
**Goal**: Analyze requirements and gather insights for core features.

- **Story 6.1**: As a product owner, I want to review and validate all functional/non-functional requirements (e.g., user roles, security, scalability) to ensure alignment with business goals.
- **Story 6.2**: As a developer, I want to research Supabase integration for auth, database, storage, and RLS policies to confirm it meets security and performance needs (e.g., JWT, encryption).
- **Story 6.3**: As a UX researcher, I want to conduct user interviews with target audiences (new parents, families) to refine features like invitations, gamification, and accessibility.
- **Story 6.4**: As a team, I want to create a risk assessment for third-party dependencies (e.g., email, push notifications, cloud storage) and define assumptions/constraints.

## Epic 7: MVP and Roadmap Planning
**Goal**: Define the minimum viable product and long-term roadmap.

- **Story 7.1**: As a product owner, I want to define MVP features (e.g., login, baby profile creation) based on user priorities.

## Epic 8: Market and User Research
**Goal**: Deepen understanding of the target market.

- **Story 8.1**: As a researcher, I want competitive analysis of similar apps (e.g., family sharing tools) for unique selling points.
- **Story 8.2**: As a UX specialist, I want user personas and journey maps for parents vs. followers.
- **Story 8.3**: As a product owner, I want surveys on feature priorities (e.g., gamification vs. basic sharing).

## Epic 9: Stakeholder and Legal Compliance
**Goal**: Align with stakeholders and ensure legal readiness.

- **Story 9.1**: As a product owner, I want stakeholder interviews (parents, families) to validate requirements and gather feedback.
- **Story 9.2**: As a legal advisor, I want GDPR/CCPA compliance checks for user data (e.g., email, photos, profiles) and privacy policies.
- **Story 9.3**: As a team, I want to draft terms of service, data retention policies, and user consent flows.

## Epic 10: Ethics and Data Ethics Review
**Goal**: Conduct ethical reviews for data handling.

- **Story 10.1**: As a team, I want an ethics review for data handling and user trust.

## Epic 11: Design Phase
**Goal**: Create UI/UX designs and prototypes.

- **Story 11.1**: As a designer, I want to design wireframes for core screens (login/signup, baby profile creation, calendar, registry, gallery) based on user roles and permissions.
- **Story 11.2**: As a developer, I want to prototype navigation bar and main sections (calendar, registry, gallery, account) for intuitive flow and responsiveness across devices.
- **Story 11.3**: As a UX specialist, I want to ensure WCAG AA compliance (color contrast, tooltips) and add welcome screens explaining features for new users.
- **Story 11.4**: As a product owner, I want to design gamification elements (voting, name suggestions, counters) and social sharing flows with privacy controls.

## Epic 12: Accessibility and Inclusivity Planning
**Goal**: Plan for diverse user needs.

- **Story 12.1**: As a UX specialist, I want to plan for internationalization (i18n) and screen reader support.

## Epic 13: Resource and Budget Planning
**Goal**: Allocate resources and set budgets.

- **Story 13.1**: As a project manager, I want to define team roles (developers, designers, testers) and timelines using Agile (e.g., sprints).
- **Story 13.2**: As a finance lead, I want a budget breakdown for tools (Supabase, GitHub), cloud costs, and potential monetization.
- **Story 13.3**: As a team, I want to plan for contingencies (e.g., delays in third-party integrations like push notifications).

## Epic 14: Team Onboarding and Training
**Goal**: Prepare the team for the project.

- **Story 14.1**: As a project manager, I want to plan team training sessions on tools and methodologies.

## Epic 15: Local Project Setup
**Goal**: Initialize the development environment.

- **Story 15.1**: As a developer, I want to create a new Flutter project with Android configuration (app ID, signing, environment variables for Supabase URL/anon key).
- **Story 15.2**: As a developer, I want to integrate Supabase SDK for auth (email/password, verification, reset) and set up basic database tables (users, baby_profiles) with RLS.
- **Story 15.3**: As a developer, I want to configure local development tools (VS Code, terminal) for testing builds, unit tests, and hot reload on Android emulator.
- **Story 15.4**: As a team, I want to set up version control (GitHub repo) and CI/CD basics for tracking issues and deploying to test environments.

## Epic 16: Supabase Project and Database Setup
**Goal**: Create and configure the Supabase project, database schema, and initial policies.

- **Story 16.1**: As a developer, I want to create a Supabase account and project (with URL/anon key) for dev/staging/prod environments.
- **Story 16.2**: As a developer, I want to set up database tables (profiles, baby_profiles, etc.) with constraints, indexes, and RLS policies.
- **Story 16.3**: As a developer, I want to configure Supabase Auth (email/password, JWT) and Storage buckets with policies.
- **Story 16.4**: As a developer, I want to enable Realtime and test basic subscriptions.

## Epic 17: Third-Party Integrations Setup
**Goal**: Set up accounts and initial configurations for external services.

- **Story 17.1**: As a developer, I want to create and configure OneSignal for push notifications (API keys, app setup).
- **Story 17.2**: As a developer, I want to create and configure SendGrid for transactional emails (API keys, templates).
- **Story 17.3**: As a developer, I want to create and configure Sentry for error monitoring (DSN, initial setup).
- **Story 17.4**: As a team, I want to store all API keys/secrets securely (e.g., in Supabase env vars or CI secrets).

## Epic 18: CI/CD and Deployment Setup
**Goal**: Establish automated pipelines and app store accounts.

- **Story 18.1**: As a developer, I want to set up GitHub Actions for build/test/deploy (Android/iOS focus).
- **Story 18.2**: As a developer, I want to configure app store accounts (Google Play, Apple App Store) with signing keys.
- **Story 18.3**: As a team, I want to set up environment-specific configs (dev/stage/prod) for Supabase and integrations.
- **Story 18.4**: As a developer, I want to test the full CI/CD pipeline with a dummy build.

## Epic 19: Testing and Local Environment Setup
**Goal**: Prepare environments for reliable testing and development.

- **Story 19.1**: As a developer, I want to set up local Supabase (CLI + Postgres) for offline testing.
- **Story 19.2**: As a developer, I want to configure Android emulators and iOS simulators for E2E tests.
- **Story 19.3**: As a team, I want to set up shared testing accounts (e.g., test Supabase projects) and data seeding.
- **Story 19.4**: As a developer, I want to integrate accessibility/performance testing tools into the local setup.

## Epic 20: Repository Methods and Utility Libraries Setup
**Goal**: Create reusable repository methods and utility libraries for data access and common functions across features.

- **Story 20.1**: As a developer, I want to create repository classes for core entities (e.g., UserRepository for auth/profile operations, BabyProfileRepository for CRUD on baby data) using Supabase client, with methods for select, insert, update, delete, and error handling. Implement interfaces for testability (e.g., abstract class UserRepository).
- **Story 20.2**: As a developer, I want to implement utility libraries for common tasks (e.g., DateUtils for formatting dates/times, ImageUtils for compression/resizing photos, ApiUtils for handling HTTP responses and retries).
- **Story 20.3**: As a developer, I want to set up dependency injection (e.g., using GetIt or Provider) to make repositories and utilities injectable across the app, ensuring testability and modularity.
- **Story 20.4**: As a developer, I want to write unit tests for repositories and utilities, covering success/error cases, and integrate them into the CI pipeline for validation.

## Epic 21: Architecture and Data Modeling
**Goal**: Document system architecture, data models, and integration patterns.

- **Story 21.1**: As a developer, I want to create architecture diagrams (e.g., high-level system overview, data flow) using tools like Draw.io or Lucidchart.
- **Story 21.2**: As a developer, I want to document data models (e.g., ER diagrams for Supabase tables, relationships, constraints) and share with the team.
- **Story 21.3**: As a developer, I want to define integration patterns (e.g., BLoC for state management, repository patterns) and update coding standards.

## Epic 22: Navigation and App Shell
**Goal**: Build the core navigation structure and app shell.

- **Story 22.1**: As a developer, I want to implement the main navigation bar with access to Calendar, Registry, Gallery, Account, and Baby Profiles sections.
- **Story 22.2**: As a developer, I want to set up deep linking support for invitation acceptance and direct navigation to specific screens.
- **Story 22.3**: As a user, I want smooth transitions between sections with proper state preservation.
- **Story 22.4**: As a developer, I want to implement bottom navigation or side drawer based on platform conventions and user testing.

## Epic 23: App Theming and Design System
**Goal**: Implement comprehensive theming support and design system.

- **Story 23.1**: As a developer, I want to implement light and dark mode themes with user preference selection and system setting detection.
- **Story 23.2**: As a designer, I want to create a design token system (colors, typography, spacing) for consistent UI across the app.
- **Story 23.3**: As a developer, I want to ensure theme switching is smooth and persists across app sessions.
- **Story 23.4**: As a designer, I want to validate that both themes meet WCAG AA color contrast requirements.

## Epic 24: Authentication and User Management
**Goal**: Implement secure login, signup, and user profiles.

- **Story 22.1**: As a user, I want to sign up with email/password and verify my account.
- **Story 22.2**: As a user, I want to log in, reset password, and manage my profile.
- **Story 22.3**: As a developer, I want to integrate Supabase Auth with session persistence.

## Epic 25: User Profile and Settings Management
**Goal**: Enable users to manage their profile details and app preferences.

- **Story 25.1**: As a user, I want to update my display name, avatar, and contact information.
- **Story 25.2**: As a user, I want to manage notification preferences (push, in-app, email) and opt-in/opt-out controls.
- **Story 25.3**: As a user, I want to select my preferred theme (light, dark, system default) and have it persist.
- **Story 25.4**: As a user, I want to view my activity counters (events attended, items purchased) across all baby profiles.
- **Story 25.5**: As a developer, I want to implement secure profile photo upload and storage with RLS policies.

## Epic 26: Database Schema and Migrations
**Goal**: Set up core database tables and relationships.

- **Story 23.1**: As a developer, I want to create tables for users, baby_profiles, events, registry, photos with RLS.
- **Story 23.2**: As a developer, I want to set up foreign keys, indexes, and initial data seeding.
- **Story 23.3**: As a developer, I want to create migration scripts for schema changes.

## Epic 27: Feature Flags and Tile System
**Goal**: Implement the hybrid tile system with feature flags.

- **Story 27.1**: As a developer, I want to create the feature_flags table and seed initial data.
- **Story 27.2**: As a developer, I want to build the tile registry in Flutter (static widgets).
- **Story 27.3**: As a developer, I want to implement flag-based rendering for screens.

## Epic 28: Welcome and Onboarding Screens
**Goal**: Create first-time user experience and feature education.

- **Story 28.1**: As a new user, I want to see welcome screens that explain the app's main features and how to use them.
- **Story 28.2**: As a developer, I want to implement swipeable onboarding screens with skip and next options.
- **Story 28.3**: As a user, I want onboarding to show only once unless I reset it in settings.
- **Story 28.4**: As a designer, I want onboarding screens to be visually engaging and match the app's theme.

## Epic 29: Baby Profile Management
**Goal**: Enable creation and management of baby profiles.

- **Story 29.1**: As a parent, I want to create/edit/delete baby profiles with photos and details.
- **Story 29.2**: As a parent, I want to invite/manage followers with role-based access.
- **Story 29.3**: As a developer, I want to implement RLS for profile visibility.
- **Story 29.4**: As a parent, I want to enforce maximum two owners per baby profile with appropriate validation.

## Epic 30: Invitation Acceptance Flow
**Goal**: Implement secure invitation acceptance with deep linking.

- **Story 30.1**: As a follower, I want to receive an email invitation with a unique link that opens the app.
- **Story 30.2**: As a developer, I want to validate invitation tokens (not expired, not revoked, not already accepted) before allowing acceptance.
- **Story 30.3**: As a follower, I want to select my relationship (Grandma, Uncle, etc.) from a predefined list during acceptance.
- **Story 30.4**: As a developer, I want to implement deep link handling for invitation URLs with proper error handling.
- **Story 30.5**: As a parent, I want expired invitations (7 days) to be automatically invalidated and removable from my management view.

## Epic 31: Follower Self-Management
**Goal**: Allow followers to manage their own membership.

- **Story 31.1**: As a follower, I want to remove myself from a baby profile at any time.
- **Story 31.2**: As a follower, I want to update my relationship label if needed.
- **Story 31.3**: As a developer, I want to ensure follower removal doesn't affect data integrity (soft references to deleted memberships).
- **Story 31.4**: As a parent, I want to be notified when a follower removes themselves from my baby profile.

## Epic 32: Core Tile Implementations
**Goal**: Build and test initial tiles (e.g., upcoming events, photo gallery).

- **Story 32.1**: As a developer, I want to create UpcomingEventsTile with dynamic data fetching.
- **Story 32.2**: As a developer, I want to create PhotoGalleryTile with upload/view functionality.
- **Story 32.3**: As a developer, I want to integrate realtime updates for tiles.
- **Story 32.4**: As a developer, I want to create RSVPTasksTile with pending RSVP data.
- **Story 32.5**: As a developer, I want to create DueDateCountdownTile with baby profile due dates.
- **Story 32.6**: As a developer, I want to create RecentPurchasesTile with registry purchase history.
- **Story 32.7**: As a developer, I want to create RegistryRecommendationsTile with suggested items.
- **Story 32.8**: As a developer, I want to create EngagementRecapTile with recent interactions.
- **Story 32.9**: As a developer, I want to create FollowerInviteStatesTile with invite statuses.
- **Story 32.10**: As a developer, I want to create GalleryFavoritesTile with top photos.
- **Story 32.11**: As a developer, I want to create OnboardingChecklistTile with setup tasks.
- **Story 32.12**: As a developer, I want to create UsageMetricsTile with storage/event counts.
- **Story 32.13**: As a developer, I want to create SystemAnnouncementsTile with app updates.

## Epic 33: Calendar and Events
**Goal**: Implement event creation, RSVP, and calendar view.

- **Story 33.1**: As a parent, I want to add/edit/delete events with photos and details.
- **Story 33.2**: As a follower, I want to view events and RSVP.
- **Story 33.3**: As a developer, I want to build CalendarTile with event filtering.
- **Story 33.4**: As a developer, I want to enforce maximum 2 events per day per baby profile via database constraint.

## Epic 34: Registry System
**Goal**: Create a baby registry with purchase tracking.

- **Story 34.1**: As a parent, I want to add/edit/delete registry items with links and photos.
- **Story 34.2**: As a follower, I want to mark items as purchased and view history.
- **Story 34.3**: As a developer, I want to build RegistryTile with purchase notifications.
- **Story 34.4**: As a developer, I want to support up to 500 items per registry with proper pagination and performance.

## Epic 35: Photo Gallery and Storage
**Goal**: Implement photo upload, sharing, and gallery features.

- **Story 35.1**: As a user, I want to upload/compress photos with captions.
- **Story 35.2**: As a user, I want to view/comment/like photos in the gallery.
- **Story 35.3**: As a developer, I want to integrate Supabase Storage with policies.
- **Story 35.4**: As a developer, I want to enforce JPEG/PNG format, 10MB max size, and support up to 1,000 photos per gallery.
- **Story 35.5**: As a developer, I want to ensure photo uploads complete in under 5 seconds with client-side compression.

## Epic 36: Social Sharing Integration
**Goal**: Enable sharing of events, photos, and milestones via native device capabilities.

- **Story 36.1**: As a user, I want to share events or photos using my device's native share sheet.
- **Story 36.2**: As a developer, I want to implement privacy controls to ensure shared content is only accessible to invited users.
- **Story 36.3**: As a developer, I want to prevent generation of public links by default and enforce invite-only access.
- **Story 36.4**: As a user, I want to see clear messaging about who can access shared content.

## Epic 37: Notifications and Integrations
**Goal**: Add push notifications, emails, and third-party integrations.

- **Story 37.1**: As a user, I want push notifications for events/photos.
- **Story 37.2**: As a developer, I want to integrate OneSignal and SendGrid.
- **Story 37.3**: As a developer, I want to implement in-app notifications.
- **Story 37.4**: As a developer, I want to ensure realtime updates propagate within 2 seconds for up to 10,000 concurrent users.

## Epic 38: Gamification Features (V2)
**Goal**: Implement voting, name suggestions, and activity counters.

- **Story 38.1**: As a follower, I want to vote on predicted birth date and gender with anonymous voting until results are revealed.
- **Story 38.2**: As a parent, I want to reveal voting results after entering the actual birth date and gender.
- **Story 38.3**: As a follower, I want to suggest baby names with duplicate prevention for my own suggestions.
- **Story 38.4**: As a user, I want to see activity counters (events attended, items purchased) on my profile to track engagement.
- **Story 38.5**: As a developer, I want to create database tables and RLS policies for voting, name suggestions, and activity tracking.

## Epic 39: Testing and QA
**Goal**: Ensure app quality with comprehensive testing.

- **Story 39.1**: As a developer, I want unit tests for all repositories and tiles.
- **Story 39.2**: As a tester, I want integration tests for auth and CRUD operations.
- **Story 39.3**: As a team, I want user acceptance testing for MVP features.

## Epic 40: Product Analytics and Experimentation
**Goal**: Instrument product metrics and enable safe experimentation.

- **Story 40.1**: As a developer, I want to instrument privacy-safe analytics events for core flows (signup, invite sent/accepted, event created, photo uploaded, item purchased).
- **Story 40.2**: As a PM, I want dashboards for engagement and retention, with segmenting by role (owner vs follower) and by baby profile.
- **Story 40.3**: As a developer, I want an experimentation hook (e.g., feature flag variant) to support A/B tests without leaking PII.

## Epic 41: Performance and Reliability
**Goal**: Optimize app speed, offline behavior, and resiliency.

- **Story 33.1**: As a developer, I want to profile cold start and screen load times, then optimize to meet the <500ms interaction target.
- **Story 33.2**: As a developer, I want offline/cache strategies for tiles and media (graceful degradation, retries, backoff).
- **Story 33.3**: As a developer, I want resiliency patterns (retry/backoff for Edge Functions, circuit breakers for network failures).

## Epic 43: Observability and Operations
**Goal**: Provide visibility and alerting for backend and app health.

- **Story 43.1**: As an SRE, I want structured logging and tracing for Edge Functions and critical flows.
- **Story 43.2**: As an SRE, I want dashboards and alerts (latency, error rates, cache hit rates, realtime subscription counts) with defined SLOs.
- **Story 43.3**: As a team, I want runbooks for common incidents (auth outage, storage failures, notification delivery issues).

## Epic 44: Disaster Recovery and Backup Implementation
**Goal**: Implement and test backup, restore, and disaster recovery procedures.

- **Story 44.1**: As an SRE, I want to enable and configure automated database backups with defined RPO/RTO targets.
- **Story 44.2**: As a team, I want to document and test restore procedures in non-production environments.
- **Story 44.3**: As an SRE, I want to implement monitoring for backup success/failure with alerting.
- **Story 44.4**: As a team, I want disaster recovery runbooks for various failure scenarios (data corruption, accidental deletion, infrastructure failure).
- **Story 44.5**: As a developer, I want to test backup restoration quarterly to ensure recoverability.

## Epic 45: Localization and Accessibility Hardening
**Goal**: Ensure global readiness and WCAG AA compliance.

- **Story 35.1**: As a developer, I want to internationalize copy, dates, and numbers with locale support (including RTL readiness if needed).
- **Story 35.2**: As a QA engineer, I want automated accessibility audits and manual checks for critical screens.
- **Story 35.3**: As a designer, I want to validate color contrast, hit targets, and text scaling across themes.

## Epic 46: Feedback and Support Loop
**Goal**: Capture user feedback and streamline support.

- **Story 46.1**: As a user, I want an in-app feedback/contact flow with context (screen, device) captured securely.
- **Story 46.2**: As a PM, I want a lightweight help/FAQ surface and release notes/change-log in-app.
- **Story 46.3**: As a support engineer, I want a process to triage crash reports and user tickets.

## Epic 47: Privacy and Compliance Validation
**Goal**: Validate privacy, data retention, and consent flows.

- **Story 37.1**: As a compliance lead, I want a DPIA/PIA covering personal data, roles, and retention.
- **Story 37.2**: As a developer, I want to verify data retention, export, and delete flows (including the 7-year retention rule) in staging.
- **Story 37.3**: As a team, I want consent management validated (email invites, notifications, analytics opt-ins) with audit logs.