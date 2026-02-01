# CI/CD Pipeline Configuration

## Document Information

**Document Version**: 1.0
**Last Updated**: January 25, 2026
**Author**: Technical Lead
**Status**: Implemented
**Section**: 2.2 - Project Initialization

## Executive Summary

This document describes the comprehensive CI/CD (Continuous Integration/Continuous Deployment) pipeline configured for the Nonna App using GitHub Actions. The pipeline automates code quality checks, testing, building, and deployment processes across multiple platforms (Android, iOS, Web).

## Pipeline Architecture

### Overview

The CI/CD pipeline consists of four main workflows:

1. **Continuous Integration (CI)** - Automated quality gates for all code changes
2. **Android Release Build** - Production builds for Google Play Store
3. **iOS Release Build** - Production builds for Apple App Store
4. **Web Deployment** - Automated web application deployment

### Workflow Trigger Strategy

```yaml
Main Branch (main)
├── On Push: Full CI + Web Deployment
├── On PR: Full CI pipeline
└── On Tag (v*.*.*): Release builds (Android + iOS)

Develop Branch (develop)
├── On Push: Full CI
└── On PR: Full CI pipeline

Feature Branches (copilot/**)
├── On Push: Full CI
└── On PR: Full CI pipeline
```

## 1. Continuous Integration Pipeline

**File**: `.github/workflows/ci.yml`

### Purpose
Ensures code quality, runs tests, and validates builds for every code change.

### Trigger Events
- Push to `main`, `develop`, or `copilot/**` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

### Jobs Overview

#### 1.1 Code Analysis Job
**Duration**: ~3-5 minutes
**Purpose**: Static code analysis and formatting checks

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies (`flutter pub get`)
4. Verify code formatting (`dart format --set-exit-if-changed`)
5. Run static analysis (`flutter analyze --fatal-infos --fatal-warnings`)
6. Check for outdated dependencies (`flutter pub outdated`)

**Quality Gates**:
- ✅ All code must be properly formatted
- ✅ Zero analyzer warnings or errors
- ✅ Awareness of outdated packages

#### 1.2 Unit & Widget Tests Job
**Duration**: ~5-10 minutes
**Purpose**: Run all unit and widget tests with coverage reporting

**Dependencies**: Requires `analyze` job to pass

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies
4. Run tests with coverage (`flutter test --coverage --reporter expanded --reporter=json > test-results.json`)
5. Post test results and coverage to PR comments using dorny/test-reporter
6. Generate HTML coverage report
7. Upload coverage artifacts

**Quality Gates**:
- ✅ All tests must pass
- ✅ Coverage report generated (skipped if no coverage data)
- ✅ No test failures

**Note**: Coverage report generation uses `--ignore-errors empty` flag to handle scenarios where tests exist but don't yet cover application code.

**Artifacts Produced**:
- Coverage report (HTML) - Available for 7 days

#### 1.3 Integration Tests Job
**Duration**: ~10-15 minutes
**Purpose**: Run end-to-end integration tests

**Dependencies**: Requires `test` job to pass

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies
4. Run integration tests (if available)

**Quality Gates**:
- ✅ All integration tests pass (if present)
- ✅ Skips gracefully if no integration tests exist

#### 1.4 Build Android Job
**Duration**: ~10-15 minutes
**Purpose**: Validate Android build process

**Dependencies**: Requires `test` job to pass

**Steps**:
1. Checkout code
2. Setup Java 17 (Temurin distribution)
3. Setup Flutter environment
4. Install dependencies
5. Build debug APK (`flutter build apk --debug`)
6. Upload APK artifact

**Artifacts Produced**:
- Android debug APK - Available for 7 days

#### 1.5 Build iOS Job
**Duration**: ~20-25 minutes
**Purpose**: Validate iOS build process (simulator only)

**Runner**: macOS-latest (required for iOS builds)

**Dependencies**: Requires `test` job to pass

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies
4. Build iOS simulator (`flutter build ios --simulator --no-codesign`)
5. Archive build
6. Upload iOS artifact

**Artifacts Produced**:
- iOS simulator build (ZIP) - Available for 7 days

#### 1.6 Build Web Job
**Duration**: ~8-12 minutes
**Purpose**: Validate web build process

**Dependencies**: Requires `test` job to pass

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies
4. Build web application (`flutter build web --release`)
5. Upload web build artifact

**Artifacts Produced**:
- Web build artifacts - Available for 7 days

#### 1.7 Security Scan Job
**Duration**: ~5-8 minutes
**Purpose**: Security vulnerability scanning

**Dependencies**: Requires `analyze` job to pass

**Steps**:
1. Checkout code
2. Setup Flutter environment
3. Install dependencies
4. Run dependency audit
5. Check for secrets (if .secrets.baseline exists)

**Quality Gates**:
- ⚠️ Non-blocking (continues on error for reporting)
- Detects hardcoded secrets
- Audits dependencies for vulnerabilities

#### 1.8 Report Status Job
**Duration**: <1 minute
**Purpose**: Aggregate and report overall CI status

**Dependencies**: Requires all previous jobs

**Steps**:
1. Check all job statuses
2. Report success/failure summary
3. Fail if any critical job failed

## 2. Android Release Build Pipeline

**File**: `.github/workflows/android-release.yml`

### Purpose
Build production-ready Android applications for Google Play Store distribution.

### Trigger Events
- Push of version tags (e.g., `v1.0.0`, `v1.2.3`)
- Manual workflow dispatch with version input

### Jobs Overview

#### 2.1 Build Job
**Duration**: ~15-20 minutes
**Runner**: ubuntu-latest

**Steps**:
1. Checkout code
2. Setup Java 17
3. Setup Flutter
4. Install dependencies
5. Run tests (quality gate)
6. Build App Bundle for Play Store (`flutter build appbundle --release`)
7. Build split APKs for direct distribution (`flutter build apk --release --split-per-abi`)
8. Upload artifacts (AAB + APKs)
9. Generate release notes

**Artifacts Produced**:
- `app-release.aab` - For Google Play Store (retained 30 days)
- `app-armeabi-v7a-release.apk` - 32-bit ARM (retained 30 days)
- `app-arm64-v8a-release.apk` - 64-bit ARM (retained 30 days)
- `app-x86_64-release.apk` - 64-bit x86 (retained 30 days)
- Release notes (retained 30 days)

**Environment Variables Required**:
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key

#### 2.2 Sign and Publish Job (Manual)
**Purpose**: Placeholder for automated signing and Play Store publishing

**Current Status**: Manual process required

**Future Automation Requirements**:
- Upload keystore to GitHub secrets (BASE64 encoded)
- Configure service account for Play Store API
- Add signing secrets:
  - `KEYSTORE_BASE64`
  - `KEYSTORE_PASSWORD`
  - `KEY_ALIAS`
  - `KEY_PASSWORD`
- Implement Fastlane or similar automation tool

## 3. iOS Release Build Pipeline

**File**: `.github/workflows/ios-release.yml`

### Purpose
Build production-ready iOS applications for Apple App Store distribution.

### Trigger Events
- Push of version tags (e.g., `v1.0.0`, `v1.2.3`)
- Manual workflow dispatch with version input

### Jobs Overview

#### 3.1 Build Job
**Duration**: ~25-35 minutes
**Runner**: macos-latest (required for iOS builds)

**Steps**:
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Run tests (quality gate)
5. Install CocoaPods dependencies
6. Build iOS release (no code sign) (`flutter build ios --release --no-codesign`)
7. Archive build
8. Upload artifact
9. Generate release notes

**Artifacts Produced**:
- `ios-release-build.zip` - iOS app bundle (retained 30 days)
- Release notes (retained 30 days)

**Environment Variables Required**:
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key

#### 3.2 Sign and Publish Job (Manual)
**Purpose**: Placeholder for automated signing and App Store publishing

**Current Status**: Manual process required

**Future Automation Requirements**:
- Apple Developer account credentials
- Provisioning profiles in GitHub secrets
- Certificates (distribution + push notification)
- App Store Connect API key
- Implement Fastlane Match or similar
- Configure automated TestFlight uploads

## 4. Web Deployment Pipeline

**File**: `.github/workflows/web-deploy.yml`

### Purpose
Build and deploy web application to hosting platforms.

### Trigger Events
- Push to `main` branch
- Manual workflow dispatch

### Jobs Overview

#### 4.1 Build and Deploy Job
**Duration**: ~10-15 minutes
**Runner**: ubuntu-latest

**Steps**:
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Run tests (quality gate)
5. Build web production (`flutter build web --release --web-renderer auto`)
6. Add `.nojekyll` for GitHub Pages
7. Upload web build artifact
8. Deploy to GitHub Pages (if configured)
9. Display deployment options

**Artifacts Produced**:
- `web-production-build` - Static web files (retained 30 days)

**Deployment Options**:

1. **GitHub Pages** (Implemented):
   - Automatic deployment on `main` branch push
   - Accessible at: `https://{username}.github.io/{repo}/`
   - Custom domain support via CNAME

2. **Firebase Hosting** (Configurable):
   - Requires `FIREBASE_SERVICE_ACCOUNT` secret
   - Uncomment deployment step in workflow

3. **Netlify** (Configurable):
   - Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` secrets
   - Uncomment deployment step in workflow

4. **Vercel** (Configurable):
   - Requires Vercel integration
   - Add Vercel deployment step

5. **AWS S3** (Configurable):
   - Requires AWS credentials
   - Add S3 sync step

## Pipeline Best Practices

### 1. Environment Variables and Secrets

**Required Secrets** (configure in GitHub repository settings):
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key

**Future Secrets** (for full automation):
- Android signing: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
- iOS signing: Apple Developer credentials, certificates, provisioning profiles
- Deployment: Platform-specific tokens (Firebase, Netlify, etc.)

### 2. Caching Strategy

All workflows use Flutter action caching:
```yaml
- uses: subosito/flutter-action@v2
  with:
    cache: true
```

Benefits:
- Faster workflow execution (2-3x speedup)
- Reduced network bandwidth
- Consistent dependency versions

### 3. Artifact Management

**Retention Policies**:
- CI artifacts (debug builds): 7 days
- Release artifacts (production builds): 30 days
- Coverage reports: 7 days

**Size Optimization**:
- Android APKs: Split per ABI (~20-30MB each vs. ~60MB universal)
- iOS builds: Compressed as ZIP
- Web builds: Minified and optimized

### 4. Timeout Configuration

All jobs have timeout limits to prevent hanging workflows:
- Analysis jobs: 10 minutes
- Test jobs: 15-20 minutes
- Build jobs: 20-30 minutes
- iOS builds: 45 minutes (longer due to CocoaPods)

### 5. Parallel Execution

Jobs run in parallel where possible:
```
analyze (runs first)
    ├── test (after analyze)
    │   ├── integration-test (after test)
    │   ├── build-android (after test)
    │   ├── build-ios (after test)
    │   └── build-web (after test)
    └── security-scan (after analyze)
```

## Quality Gates Summary

### Must Pass (Blocking)
- ✅ Code formatting
- ✅ Static analysis (zero warnings)
- ✅ All unit tests
- ✅ All widget tests
- ✅ Integration tests (if present)
- ✅ Android build
- ✅ iOS build
- ✅ Web build

### Advisory (Non-Blocking)
- ⚠️ Outdated dependencies (informational)
- ⚠️ Security scan (reported but non-blocking)
- ⚠️ Coverage thresholds (reported but non-blocking)

## Monitoring and Notifications

### Status Badges

Add to README.md:
```markdown
![CI Status](https://github.com/dipan0saha/nonna_app/workflows/CI%20-%20Continuous%20Integration/badge.svg)
![Android Build](https://github.com/dipan0saha/nonna_app/workflows/Android%20Release%20Build/badge.svg)
![iOS Build](https://github.com/dipan0saha/nonna_app/workflows/iOS%20Release%20Build/badge.svg)
![Web Deploy](https://github.com/dipan0saha/nonna_app/workflows/Web%20Deployment/badge.svg)
```

### Email Notifications

GitHub automatically sends email notifications for:
- Workflow failures
- First-time workflow success after failure
- Can be configured per user in GitHub settings

### Slack/Discord Integration (Optional)

Add notification step to workflows:
```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'CI Pipeline failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Troubleshooting Guide

### Common Issues

#### Issue 1: Flutter Version Mismatch
**Symptom**: Build fails with SDK version errors
**Solution**: Update Flutter version in workflow files
```yaml
flutter-version: '3.24.0'  # Update to match local development
```

#### Issue 2: Dependency Resolution Failures
**Symptom**: `flutter pub get` fails
**Solution**:
1. Check pubspec.yaml for invalid dependencies
2. Clear cache and retry workflow
3. Update dependency versions

#### Issue 3: Android Build Fails
**Symptom**: Gradle build errors
**Solution**:
1. Check Java version (must be 17)
2. Verify Android SDK versions in build.gradle.kts
3. Clear Gradle cache in workflow

#### Issue 4: iOS Build Fails
**Symptom**: CocoaPods or Xcode errors
**Solution**:
1. Update CocoaPods: `cd ios && pod update`
2. Check Podfile.lock compatibility
3. Verify Xcode version in runner

#### Issue 5: Test Failures in CI
**Symptom**: Tests pass locally but fail in CI
**Solution**:
1. Check for environment-dependent code
2. Verify test fixtures are committed
3. Add debug output to failing tests

### Debugging Workflows

**Enable debug logging**:
```yaml
- name: Debug step
  run: |
    echo "Debug information"
    flutter doctor -v
    flutter pub deps
```

**Download and inspect artifacts**:
1. Go to failed workflow run
2. Scroll to "Artifacts" section
3. Download relevant artifacts for inspection

## Performance Optimization

### Current Optimizations
- ✅ Flutter SDK caching enabled
- ✅ Gradle caching enabled
- ✅ Parallel job execution
- ✅ Conditional job execution
- ✅ Artifact compression

### Future Optimizations
- [ ] Self-hosted runners for faster builds
- [ ] Docker container caching
- [ ] Incremental builds
- [ ] Smart test selection (run only affected tests)

## Security Considerations

### Secret Management
- Never commit secrets to repository
- Use GitHub Secrets for sensitive data
- Rotate secrets regularly
- Use environment-specific secrets

### Dependency Security
- Automated security scanning in pipeline
- Regular dependency updates
- Monitor security advisories
- Use `dependabot` for automated PR updates

### Access Control
- Limit who can trigger workflows
- Protect main branch with required checks
- Require PR reviews before merge
- Use branch protection rules

## Maintenance Schedule

### Weekly
- Review failed workflow runs
- Check for outdated dependencies
- Monitor artifact storage usage

### Monthly
- Update Flutter version in workflows
- Review and update dependency versions
- Audit secrets and rotate if needed
- Review pipeline performance metrics

### Quarterly
- Major dependency updates
- Review and optimize workflow structure
- Update documentation
- Security audit of pipeline

## Next Steps for Full Automation

### Android Publishing
1. Generate release keystore
2. Upload keystore to GitHub secrets (BASE64 encoded)
3. Configure Google Play service account
4. Add Play Store API credentials
5. Implement Fastlane or similar tool
6. Test on internal track before production

### iOS Publishing
1. Enroll in Apple Developer Program
2. Create App Store Connect app
3. Set up certificates and provisioning profiles
4. Configure Fastlane Match
5. Add App Store Connect API key
6. Automate TestFlight uploads

### Web Hosting
1. Choose hosting platform (Firebase, Netlify, Vercel, etc.)
2. Configure DNS and custom domain
3. Add hosting credentials to secrets
4. Enable automatic deployments
5. Set up staging environment

## References

- GitHub Actions Documentation: https://docs.github.com/en/actions
- Flutter CI/CD Guide: https://docs.flutter.dev/deployment/cd
- Fastlane Documentation: https://docs.fastlane.tools/
- Codecov Documentation: https://docs.codecov.com/

## Approval

**Status**: ✅ Implemented and Functional

The CI/CD pipeline is fully configured and operational. All workflows are:
- ✅ Tested and validated
- ✅ Properly documented
- ✅ Following best practices
- ✅ Ready for production use

**Quality Gates**: All automated quality checks are in place and enforcing code quality standards.

---

**Document Maintained By**: DevOps Team / Technical Lead
**Review Frequency**: Monthly or on pipeline changes
