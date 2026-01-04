# Third-Party Integrations Setup

## Overview

This directory contains comprehensive documentation for setting up all third-party integrations and backend services for the Nonna App. These integrations form the foundation of the app's backend infrastructure, enabling authentication, data storage, file management, push notifications, and analytics.

## Document Index

### 1. [Supabase Project Configuration](./01_Supabase_Project_Configuration.md)
**Status**: ✅ Complete  
**Purpose**: Complete setup guide for Supabase project including database, authentication, storage, realtime, and Edge Functions configuration.

**Key Topics**:
- Supabase account and project creation
- Environment configuration (dev/staging/prod)
- Service setup (Database, Auth, Storage, Realtime, Edge Functions)
- Security configuration and RLS
- Performance optimization strategies
- Monitoring and maintenance
- Troubleshooting and cost management

**Dependencies**: None  
**Estimated Setup Time**: 2-3 hours

---

### 2. [Authentication Setup Guide](./02_Authentication_Setup_Guide.md)
**Status**: ✅ Complete  
**Purpose**: Comprehensive authentication configuration using Supabase Auth with email/password and OAuth providers.

**Key Topics**:
- Email/password authentication setup
- OAuth providers configuration (Google, Facebook)
- Email verification and password reset flows
- Session management and JWT token handling
- Security best practices and rate limiting
- Testing authentication flows

**Dependencies**: 01_Supabase_Project_Configuration  
**Estimated Setup Time**: 3-4 hours

---

### 3. [Cloud Storage Configuration](./03_Cloud_Storage_Configuration.md)
**Status**: ✅ Complete  
**Purpose**: Supabase Storage setup for file uploads, downloads, and CDN delivery with RLS policies.

**Key Topics**:
- Storage bucket creation and configuration
- Row-Level Security policies for storage
- Photo upload/download implementation
- CDN optimization and image transformations
- Client-side image compression
- Performance optimization
- Security best practices

**Dependencies**: 01_Supabase_Project_Configuration  
**Estimated Setup Time**: 2-3 hours

---

### 4. [Database Setup Document](./04_Database_Setup_Document.md)
**Status**: ✅ Complete  
**Purpose**: PostgreSQL database schema creation, migrations, RLS policies, indexes, and triggers setup.

**Key Topics**:
- Database schema initialization
- 28 tables across 8 domains creation
- Row-Level Security policy implementation
- Performance indexes creation
- Database triggers and automation
- Testing RLS policies with pgTAP
- Migration management

**Dependencies**: 01_Supabase_Project_Configuration  
**Estimated Setup Time**: 4-6 hours  
**Reference**: See `docs/02_architecture_design/database_schema_design.md` for complete schema design

---

### 5. [Push Notification Configuration](./05_Push_Notification_Configuration.md)
**Status**: ✅ Complete  
**Purpose**: OneSignal push notification setup for real-time user engagement.

**Key Topics**:
- OneSignal account and app configuration
- iOS (APNs) and Android (FCM) setup
- Flutter SDK integration
- Notification types and triggers
- Edge Function for push delivery
- User notification preferences
- Testing and debugging

**Dependencies**: 01_Supabase_Project_Configuration (for Edge Functions)  
**Estimated Setup Time**: 3-4 hours

---

### 6. [Analytics Setup Document](./06_Analytics_Setup_Document.md)
**Status**: ✅ Complete  
**Purpose**: Privacy-compliant analytics tracking using Firebase Analytics for data-driven product decisions.

**Key Topics**:
- Analytics strategy and key metrics
- Firebase Analytics setup and integration
- Event tracking implementation
- Privacy-first analytics with user consent
- Performance monitoring and crash reporting
- Custom dashboards and reporting
- Testing analytics events

**Dependencies**: None (standalone integration)  
**Estimated Setup Time**: 2-3 hours

---

## Quick Start Guide

### Prerequisites

Before starting, ensure you have:

- [ ] Supabase account created
- [ ] Flutter development environment set up
- [ ] Google Cloud Console account (for Google OAuth)
- [ ] Facebook Developer account (for Facebook OAuth)
- [ ] OneSignal account (for push notifications)
- [ ] Firebase account (for analytics)
- [ ] Basic understanding of PostgreSQL and RLS concepts

### Recommended Setup Order

Follow this sequence for optimal setup:

1. **Start with Supabase** (Document 01)
   - Create project and configure services
   - Set up environment variables
   - Estimated time: 2-3 hours

2. **Set up Authentication** (Document 02)
   - Configure email/password auth
   - Set up OAuth providers
   - Test authentication flows
   - Estimated time: 3-4 hours

3. **Configure Cloud Storage** (Document 03)
   - Create storage buckets
   - Set up RLS policies
   - Implement photo upload/download
   - Estimated time: 2-3 hours

4. **Initialize Database** (Document 04)
   - Run database migrations
   - Create tables and indexes
   - Implement RLS policies
   - Test with pgTAP
   - Estimated time: 4-6 hours

5. **Set up Push Notifications** (Document 05)
   - Configure OneSignal
   - Deploy Edge Functions
   - Implement notification preferences
   - Estimated time: 3-4 hours

6. **Enable Analytics** (Document 06)
   - Set up Firebase Analytics
   - Implement event tracking
   - Configure user consent
   - Estimated time: 2-3 hours

**Total Estimated Setup Time**: 16-23 hours

---

## Integration Architecture

```
┌────────────────────────────────────────────────────────────┐
│                      Nonna App (Flutter)                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Supabase SDK │  │ OneSignal SDK│  │ Firebase SDK │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                  │                  │           │
└─────────┼──────────────────┼──────────────────┼───────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                  Third-Party Services                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Supabase (Backend-as-a-Service)                 │  │
│  │  • Authentication (JWT-based)                    │  │
│  │  • PostgreSQL Database (with RLS)                │  │
│  │  • Storage (S3-compatible with CDN)              │  │
│  │  • Realtime (WebSocket subscriptions)            │  │
│  │  • Edge Functions (Serverless compute)           │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  OneSignal (Push Notifications)                  │  │
│  │  • iOS push via APNs                             │  │
│  │  • Android push via FCM                          │  │
│  │  • User segmentation                             │  │
│  │  • Notification preferences                      │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Firebase (Analytics & Performance)              │  │
│  │  • Analytics event tracking                      │  │
│  │  • Crashlytics error reporting                   │  │
│  │  • Performance monitoring                        │  │
│  │  • Custom dashboards                             │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  OAuth Providers                                 │  │
│  │  • Google OAuth (Google Cloud Console)          │  │
│  │  • Facebook OAuth (Facebook Developers)         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Email Delivery (SendGrid via Edge Functions)   │  │
│  │  • Invitation emails                             │  │
│  │  • Password reset emails                         │  │
│  │  • Email verification                            │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Security Considerations

### Critical Security Practices

1. **API Keys and Secrets**:
   - ✅ Store `SUPABASE_ANON_KEY` in client app (safe to expose)
   - ❌ Never commit `SERVICE_ROLE_KEY` to Git (server-side only)
   - ✅ Use environment variables for all secrets
   - ✅ Rotate keys every 90 days

2. **Row-Level Security (RLS)**:
   - ✅ Enable RLS on all tables
   - ✅ Test RLS policies comprehensively
   - ❌ Never disable RLS in production
   - ✅ Use `auth.uid()` in all policies

3. **Authentication**:
   - ✅ Require email verification
   - ✅ Enforce strong password requirements
   - ✅ Store JWT tokens securely (Keychain/Keystore)
   - ✅ Implement rate limiting

4. **Data Privacy**:
   - ✅ Request analytics consent
   - ✅ Never collect PII in analytics
   - ✅ Provide opt-out mechanisms
   - ✅ Comply with GDPR/CCPA

5. **File Storage**:
   - ✅ Validate file types and sizes
   - ✅ Use RLS policies on storage buckets
   - ✅ Generate signed URLs for private files
   - ✅ Implement file scanning (future)

---

## Testing Strategy

### Unit Testing
- Test authentication service methods
- Test database CRUD operations
- Test photo upload/download logic
- Mock Supabase client for isolated tests

### Integration Testing
- Test full authentication flows
- Test database operations with RLS
- Test file upload/download end-to-end
- Test push notification delivery

### RLS Policy Testing
- Use pgTAP for automated RLS testing
- Test owner CRUD permissions
- Test follower read permissions
- Test unauthorized access prevention

### Manual Testing Checklist
- [ ] Sign up and email verification
- [ ] Login with email/password
- [ ] Login with Google OAuth
- [ ] Login with Facebook OAuth
- [ ] Password reset flow
- [ ] Photo upload and display
- [ ] Photo download and caching
- [ ] Push notification receipt
- [ ] Analytics event tracking
- [ ] All RLS policies enforced

---

## Troubleshooting

### Common Issues

**Issue: "Invalid API key"**
- **Solution**: Verify `SUPABASE_ANON_KEY` is correct, check for typos

**Issue: "RLS policy violation"**
- **Solution**: Check user has required role in `baby_memberships`, verify RLS policies

**Issue: "Storage bucket not found"**
- **Solution**: Verify bucket name matches exactly (case-sensitive), check bucket exists

**Issue: "Push notification not received"**
- **Solution**: Check device registration, verify OneSignal configuration, test with OneSignal dashboard

**Issue: "Analytics events not showing"**
- **Solution**: Enable Firebase Debug View, check network connectivity, verify Firebase configuration

### Getting Help

- **Supabase Documentation**: [https://supabase.com/docs](https://supabase.com/docs)
- **Supabase Discord**: [https://discord.supabase.com](https://discord.supabase.com)
- **OneSignal Documentation**: [https://documentation.onesignal.com](https://documentation.onesignal.com)
- **Firebase Documentation**: [https://firebase.google.com/docs](https://firebase.google.com/docs)

---

## Production Readiness

### Pre-Production Checklist

Before deploying to production:

- [ ] All third-party services configured in production environment
- [ ] Environment variables set correctly for production
- [ ] Database migrations applied and tested
- [ ] RLS policies validated comprehensively
- [ ] Storage buckets created with correct policies
- [ ] Authentication flows tested on all platforms
- [ ] Push notifications working on iOS and Android
- [ ] Analytics tracking and dashboards configured
- [ ] Security audit completed
- [ ] Performance benchmarks met
- [ ] Backup and recovery procedures tested
- [ ] Monitoring and alerts configured
- [ ] Documentation reviewed and updated

### Success Criteria

Third-party integrations are production-ready when:

✅ **Authentication**: Users can sign up, log in, reset password, verify email  
✅ **Database**: All tables created, RLS policies enforced, queries performant (< 100ms)  
✅ **Storage**: Photos upload/download successfully, RLS policies protect private files  
✅ **Push Notifications**: Notifications delivered reliably on iOS and Android  
✅ **Analytics**: Events tracked correctly, user consent managed, dashboards operational  
✅ **Security**: No vulnerabilities, all secrets secured, compliance validated  
✅ **Performance**: All operations meet targets (auth < 2s, photo upload < 5s, queries < 100ms)

---

## Next Steps

After completing third-party integrations setup:

1. **Proceed to Section 3.x**: Core Development
   - Implement data models
   - Build UI components
   - Develop features using integrated services

2. **Continuous Improvement**:
   - Monitor integration performance
   - Optimize based on analytics insights
   - Update configurations as needed
   - Scale services based on usage

3. **Team Onboarding**:
   - Share this documentation with team
   - Provide access to third-party dashboards
   - Train on debugging and troubleshooting

---

## Document Maintenance

**Review Schedule**: Quarterly or when major updates occur  
**Last Reviewed**: January 4, 2026  
**Status**: All documents complete and validated  
**Maintainer**: Technical Team

**Change Log**:
- 2026-01-04: Initial documentation created for Section 2.3
- All 6 integration documents completed and validated
- README created with quick start guide and architecture overview

---

**For questions or updates, please contact the Technical Team or refer to the individual integration documents for detailed guidance.**
