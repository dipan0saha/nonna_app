# Business Requirements Document (BRD)

## Executive Summary

Nonna is a mobile-first, tile-based family social platform designed to bridge the distance between new parents and their loved ones. In an era where families are often geographically dispersed, Nonna provides a dedicated, private, and secure space for parents to share their pregnancy and parenting journey with invited friends and family. The platform enables baby profile owners (parents) to create and manage profiles, while followers (friends and family) can view, interact, and celebrate milestones through features like photo galleries, calendars, baby registries, and gamification elements.

This document defines the business objectives, scope, target audience, success criteria, and strategic direction for the Nonna app development. The platform differentiates itself through its tile-based UI architecture, role-driven permissions (owners vs. followers), and family-centric privacy model that ensures content is shared only with invited users.

## Business Objectives

### Primary Objectives
1. **Create a Private Family Social Platform**: Establish Nonna as the go-to solution for parents to share pregnancy and parenting updates with close family and friends in a secure, invite-only environment
2. **Drive User Engagement**: Achieve high daily active user (DAU) rates through compelling features like photo sharing, event calendars, baby registries, and gamification elements (voting, name suggestions)
3. **Achieve Product-Market Fit**: Launch an MVP that resonates with tech-savvy new parents (ages 25-40) who value privacy and meaningful family connections
4. **Scale to Support Growing Families**: Build a platform capable of supporting up to 10,000 concurrent users with sub-500ms response times and real-time updates within 2 seconds
5. **Establish Market Differentiation**: Position Nonna uniquely through its tile-based UI, dual-role system (owner/follower), and family-focused feature set that goes beyond simple photo sharing

### Secondary Objectives
1. **Foster Community and Connection**: Enable meaningful interactions through features like photo "squishing" (likes), event RSVPs, registry purchases, and name suggestion voting
2. **Monetization Readiness**: Build a foundation for future monetization through premium features, registry partnerships, or subscription tiers (post-MVP)
3. **Data Privacy Leadership**: Demonstrate commitment to data privacy and security with AES-256 encryption, TLS 1.3, invite-only access, and 7-year data retention compliance
4. **Cross-Platform Excellence**: Deliver a consistent, high-quality experience across iOS and Android through Flutter's single codebase approach
5. **Analytics-Driven Optimization**: Implement comprehensive KPI tracking to continuously improve user experience and feature adoption

## Scope and Boundaries

### In Scope
**Core Features (MVP):**
- **User Authentication & Account Management**: Email/password and OAuth (Google/Facebook) sign-up and login with email verification, password reset, and secure session management
- **Baby Profile Management**: Parents can create, edit, and manage baby profiles with details like name, profile photo, expected birth date, and gender (max 2 owners per profile)
- **Role-Based Access Control**: Dual-role system with Parents (Owners) having full CRUD permissions and Friends & Family (Followers) having view and interaction permissions
- **Invitation System**: Email-based invitations with unique 7-day expiring tokens and relationship labeling (Grandma, Grandpa, Aunt, Uncle, etc.)
- **Calendar Feature**: Shared calendar for events (ultrasounds, gender reveals, baby showers) with RSVP, comments, and AI-suggested events
- **Baby Registry**: List of desired baby items with follower purchase marking, AI-suggested items by baby age/stage, and purchaser tracking
- **Photo Gallery**: JPEG/PNG photo uploads (max 10MB) with captions, comments, "squishing" (likes), tagging, and bulk upload/delete
- **Gamification**: Voting on predicted birth date, gender, and names; name suggestions (1 per gender per user); activity counters (events attended, items purchased, photos squished, comments)
- **Notifications**: Push (opt-in) and in-app notifications for content updates, interactions, and follower activities
- **Tile-Based UI**: Dynamic, role-driven tile system with Supabase-configured tiles for Home, Gallery, Calendar, Registry, Photo Gallery, and Fun screens
- **Baby Countdown & Announcement**: Countdown for babies arriving within 10 days; birth announcement feature with Instagram sharing
- **Filtering & Role Toggle**: Filter content by baby profile; toggle between owner and follower roles for users with multiple memberships

**Technical Infrastructure:**
- **Frontend**: Flutter (cross-platform mobile app for iOS and Android)
- **Backend**: Supabase (BaaS with PostgreSQL, Auth, Storage, Realtime, Edge Functions)
- **Authentication**: JWT-based with Supabase Auth and Row-Level Security (RLS)
- **Database**: PostgreSQL with comprehensive ERD (24 tables, 45+ relationships, RLS policies)
- **File Storage**: Supabase Storage with CDN delivery for photos and thumbnails
- **Third-Party Integrations**: SendGrid (email), OneSignal (push notifications)
- **Security**: AES-256 encryption at rest, TLS 1.3 in transit, OAuth 2.0, RBAC with RLS
- **Performance**: Sub-500ms interaction times, real-time updates within 2 seconds, photo uploads under 5 seconds
- **DevOps**: GitHub Actions CI/CD, Supabase CLI for migrations, Sentry for monitoring

### Out of Scope (for MVP)
- **Web Application**: Mobile-first approach only; web version deferred to post-MVP
- **Public Social Sharing**: No public sharing capabilities; all content remains private to invited users
- **Welcome Screens/Onboarding**: Deferred to V2 (noted in requirements)
- **Advanced Analytics Dashboard**: Basic analytics only; comprehensive dashboards post-MVP
- **Monetization Features**: Premium features, subscriptions, or registry partnerships deferred
- **Video Content**: Focus on photos only; video support deferred
- **Multiple Languages**: English-only for MVP; localization post-MVP
- **Third-Party Registry Integration**: Manual registry management only; API integrations deferred
- **Advanced Gamification**: Basic voting and name suggestions only; leaderboards, badges deferred
- **AI-Generated Content**: AI suggestions for events and registry items only; no AI-generated photos or captions
- **Offline Mode**: Basic caching only; full offline functionality deferred
- **Accessibility Beyond WCAG AA**: WCAG AA compliance required; AAA level deferred

## Success Criteria

### Business Success Metrics
1. **User Acquisition**: 10,000+ registered users within 6 months of launch
2. **User Retention**: 60% 30-day retention rate (users returning after initial registration)
3. **Engagement**: 40% DAU/MAU ratio (daily active users / monthly active users)
4. **Viral Growth**: Viral coefficient of 1.5+ (each user invites 1.5 new users on average)
5. **Feature Adoption**: 80%+ of users create at least one baby profile within first week
6. **App Store Ratings**: 4.5+ star average across iOS and Android
7. **Customer Satisfaction**: Net Promoter Score (NPS) of 50+

### User Adoption Targets
- **Month 1**: 1,000 registered users, 500 baby profiles created
- **Month 3**: 5,000 registered users, 2,500 baby profiles created, 50% DAU engagement
- **Month 6**: 10,000+ registered users, 5,000+ baby profiles created, 40% DAU/MAU ratio
- **Engagement Targets**: Average 3 photos uploaded per profile per week, 5+ followers per baby profile, 70%+ RSVP rate for events

### Technical Success Metrics (see `success_metrics_kpis.md` for detailed KPIs)
- Response time < 500ms for all user interactions
- Real-time updates within 2 seconds for up to 10,000 concurrent users
- Photo upload time < 5 seconds
- App crash rate < 1% of sessions
- 99.5% uptime SLA

## Stakeholder Analysis

### Key Stakeholders
1. **Product Team**: Responsible for product vision, roadmap, and feature prioritization; primary decision-makers for scope and requirements
2. **Engineering Team**: Flutter developers, backend engineers, DevOps; responsible for technical implementation and architecture
3. **Design Team**: UX/UI designers; responsible for user experience, accessibility (WCAG AA), and visual design
4. **Quality Assurance**: Testing team ensuring functional, performance, and security requirements are met
5. **Marketing & Growth Team**: Responsible for user acquisition, onboarding, and retention strategies
6. **Customer Support**: Post-launch support for user issues, feedback collection
7. **Legal & Compliance**: Ensuring data privacy compliance, terms of service, and 7-year data retention requirements
8. **Executive Leadership**: Budget approval, strategic direction, and business success oversight

### User Groups
1. **Primary Users - Parents (Owners)** (see `user_personas_document.md` for details):
   - Tech-savvy new parents and expectant parents (ages 25-40)
   - Value privacy and control over family content
   - Want a dedicated platform separate from public social media
   - Need to manage multiple aspects (photos, events, registry) in one place
   - Primarily female (70%) but growing male adoption (30%)

2. **Secondary Users - Friends & Family (Followers)**:
   - Ages 30-70+ (parents, grandparents, aunts, uncles, close friends)
   - Varying tech-savviness (must be easy to use for all ages)
   - Want to stay connected with baby's growth and milestones
   - Seek meaningful ways to interact (not just passive viewing)
   - Geographically dispersed from baby owners

3. **Tertiary Stakeholders**:
   - Baby registry vendors (potential future partners)
   - Parenting product brands (potential advertisers post-MVP)
   - Healthcare providers (potential integrations for appointments/milestones)

## Business Risks and Assumptions

### Key Assumptions
1. **Market Demand**: Sufficient demand exists for a private, family-focused alternative to public social media platforms
2. **Technology Choices**: Flutter + Supabase stack can deliver required performance (<500ms, real-time) and scale to 10,000+ concurrent users within free/low-cost tiers initially
3. **User Behavior**: Parents will actively invite followers (target 5+ per profile) and followers will engage regularly (not just passive viewing)
4. **Privacy Preference**: Users prefer invite-only privacy over public sharing for baby content
5. **Cross-Platform Parity**: Single Flutter codebase can deliver equal quality on iOS and Android
6. **Third-Party Reliability**: SendGrid and OneSignal will provide reliable email and push notification delivery
7. **Onboarding Simplicity**: Users can successfully navigate invitation acceptance and role understanding without extensive onboarding (deferred to V2)
8. **Freemium Viability**: Free tier can support MVP growth until monetization features are introduced

### Business Risks
1. **Market Competition** (HIGH):
   - **Risk**: Established competitors (FamilyAlbum, Tinybeans, Lifecake) have significant market share and brand recognition
   - **Mitigation**: Differentiate through tile-based UI, dual-role system, and integrated features (calendar + registry + photos) that competitors lack in a unified experience

2. **User Acquisition Cost** (HIGH):
   - **Risk**: High customer acquisition costs in crowded parenting app market
   - **Mitigation**: Leverage viral invitation model (each user invites 5+ followers), word-of-mouth, parenting community partnerships, and app store optimization

3. **Feature Complexity** (MEDIUM):
   - **Risk**: Rich feature set (calendar, registry, photos, gamification) may overwhelm users or delay MVP launch
   - **Mitigation**: Phased rollout with core features first, intuitive tile-based UI to organize complexity, analytics to guide feature prioritization

4. **Technical Scalability** (MEDIUM):
   - **Risk**: Performance degradation as user base grows beyond initial projections
   - **Mitigation**: Comprehensive performance testing (target 10K concurrent), database indexing, caching strategy (Hive/Isar), CDN for media delivery, Supabase horizontal scaling options

5. **Data Privacy & Security** (HIGH):
   - **Risk**: Data breaches or privacy violations could irreparably damage trust and brand
   - **Mitigation**: Multi-layered security (RLS, AES-256, TLS 1.3, rate limiting, abuse prevention), regular security audits, transparent privacy policy, compliance with data retention regulations

6. **Cross-Platform Quality** (MEDIUM):
   - **Risk**: Flutter app may not meet platform-specific quality standards or performance expectations
   - **Mitigation**: Platform-specific testing, adherence to Material Design (Android) and Human Interface Guidelines (iOS), performance monitoring via Sentry

7. **User Retention** (HIGH):
   - **Risk**: Users create profiles but don't return regularly (low retention)
   - **Mitigation**: Push notifications for new content, gamification to drive engagement, compelling features (registry purchases, event RSVPs), analytics-driven optimization

8. **Monetization Uncertainty** (LOW for MVP, HIGH long-term):
   - **Risk**: Unclear monetization path could limit long-term sustainability
   - **Mitigation**: Build user base first, test willingness to pay through surveys, explore premium features (additional storage, advanced analytics), registry partnerships, or subscription tiers

## Timeline and Milestones

### Project Phases
**Phase 1: Foundation & Planning (Weeks 1-4)**
- Complete requirement gathering documents (Section 1.1) ✓
- Finalize technical requirements (Section 1.2)
- Complete architecture and design (Section 1.3)
- Set up development environment and CI/CD

**Phase 2: Core Infrastructure (Weeks 5-8)**
- Supabase schema implementation (24 tables, RLS policies, triggers)
- Authentication flow (email/password, OAuth)
- User profile and baby profile management
- Invitation system with email delivery

**Phase 3: Content Features (Weeks 9-14)**
- Photo gallery with upload, comments, squishing
- Calendar with events, RSVPs, comments
- Baby registry with purchase marking
- Real-time updates implementation

**Phase 4: Advanced Features (Weeks 15-18)**
- Tile-based UI implementation
- Gamification (voting, name suggestions)
- Notifications (push and in-app)
- Role toggle and filtering

**Phase 5: Testing & Optimization (Weeks 19-22)**
- Performance testing (10K concurrent users)
- Security audits and penetration testing
- Accessibility (WCAG AA) validation
- Bug fixes and optimization

**Phase 6: Launch Preparation (Weeks 23-24)**
- App store submission (iOS and Android)
- Marketing materials and landing page
- Customer support setup
- Launch!

### Key Milestones
1. **M1 - Requirements Approved** (End of Week 4): All Section 1.1-1.3 documents approved by stakeholders
2. **M2 - Database & Auth Live** (End of Week 8): Supabase fully configured, users can sign up and create profiles
3. **M3 - MVP Feature Complete** (End of Week 18): All core features implemented and functional
4. **M4 - Beta Testing Begins** (End of Week 20): Internal and external beta testing underway
5. **M5 - App Store Approval** (End of Week 23): Apps approved for iOS and Android
6. **M6 - Public Launch** (Week 24): Nonna app publicly available in app stores
7. **M7 - 1,000 Users** (Month 1 post-launch): First user acquisition milestone
8. **M8 - Product-Market Fit Validation** (Month 3 post-launch): 5,000 users, 50% DAU engagement, NPS 50+

## Budget and Resources

### Estimated Budget (MVP Development)
**Development Costs (6 months):**
- **Engineering Team**: 2 Flutter developers, 1 backend engineer, 1 DevOps = $200,000-$300,000 (contractor rates) or internal team allocation
- **Design**: 1 UX/UI designer (part-time or contract) = $30,000-$50,000
- **QA**: 1 QA engineer (part-time) = $20,000-$40,000

**Infrastructure & Services (Year 1):**
- **Supabase**: Free tier initially, Pro tier $25/month post-launch = $0-$300/year
- **SendGrid**: Free tier (100 emails/day), Essentials plan $19.95/month if needed = $0-$240/year
- **OneSignal**: Free tier (10,000 subscribers) = $0/year
- **Sentry**: Free tier (5,000 events/month), Team plan $26/month if needed = $0-$312/year
- **Domain & Hosting**: $50-$100/year
- **Apple Developer Account**: $99/year
- **Google Play Developer Account**: $25 one-time
- **Total Infrastructure**: ~$500-$1,000/year for MVP, scaling to $2,000-$5,000/year as user base grows

**Marketing & Launch:**
- **App Store Assets**: $5,000-$10,000 (screenshots, videos, copy)
- **Initial Marketing**: $10,000-$20,000 (ads, influencer partnerships, PR)

**Total Estimated MVP Budget**: $265,000-$380,000 (development) + $15,000-$30,000 (launch)

### Resource Requirements
**Human Resources:**
- **Engineering**: 2 Flutter developers (mobile), 1 backend engineer (Supabase/PostgreSQL), 1 DevOps engineer (CI/CD, monitoring)
- **Design**: 1 UX/UI designer with mobile app experience and accessibility knowledge
- **Product Management**: 1 Product Manager to lead requirements, prioritization, and stakeholder coordination
- **QA**: 1 QA engineer for functional, performance, and security testing
- **Marketing**: 1 Growth/Marketing lead for user acquisition strategy (post-launch)
- **Customer Support**: 1 part-time support representative (post-launch)

**Technical Resources:**
- **Development Environment**: Supabase local development, Flutter SDK, Android Studio, Xcode
- **Testing Devices**: iOS devices (iPhone 12+, iPad), Android devices (Samsung, Pixel across OS versions)
- **Testing Tools**: Flutter integration_test, pg_prove (database testing), performance testing tools
- **Monitoring**: Sentry for crash reporting, Supabase dashboard for performance metrics
- **CI/CD**: GitHub Actions runners (included in GitHub account)

**External Dependencies:**
- **Supabase**: For BaaS, database, auth, storage, realtime, Edge Functions
- **SendGrid**: For transactional email delivery (invitations, password reset)
- **OneSignal**: For push notification delivery
- **Apple & Google**: For app store distribution

## Success Metrics Alignment

This BRD aligns with the detailed KPIs defined in `success_metrics_kpis.md`. Key alignment areas:

1. **Business Objectives → User Acquisition Metrics**: Primary objective of achieving product-market fit maps directly to user registration rate, viral coefficient, and user retention rate KPIs

2. **Engagement Goals → User Engagement Metrics**: DAU/MAU ratio, session duration, and feature adoption rate KPIs directly measure the "Drive User Engagement" objective

3. **Technical Excellence → Performance Metrics**: Sub-500ms response time and real-time updates within 2 seconds map to app load time, crash rate, and API latency KPIs

4. **User Satisfaction → Business Impact Metrics**: NPS and customer satisfaction scores directly measure user satisfaction and likelihood to recommend

5. **Scale Targets → Scalability Metrics**: 10,000 concurrent users target aligns with database performance, CDN delivery, and infrastructure scalability KPIs

All KPIs defined in the success metrics document have clear owners, targets, measurement methods, and reporting frequencies to ensure this BRD's objectives are tracked and achieved.

## References

This Business Requirements Document is informed by and references:
- `discovery/01_discovery/01_requirements/Requirements.md` - Functional and non-functional requirements
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Technical architecture and constraints
- `discovery/01_discovery/04_technical_requirements/Technical_Requirements.md` - Tile system design
- `discovery/01_discovery/04_technical_requirements/Tile_System_Design.md` - Dynamic UI architecture
- `discovery/01_discovery/05_draft_design/ERD.md` - Database schema and relationships
- `docs/00_requirement_gathering/user_personas_document.md` - Target user definitions
- `docs/00_requirement_gathering/success_metrics_kpis.md` - Detailed KPI definitions
- `docs/00_requirement_gathering/competitor_analysis_report.md` - Market positioning

---

**Document Version**: 1.0  
**Last Updated**: January 3, 2026  
**Author**: Product Management Team  
**Status**: Final  
**Approval**: Pending Stakeholder Review</content>
<parameter name="filePath">/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/docs/01_discovery/00_foundation/business_requirements_document.md