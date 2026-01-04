# Branching Strategy Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Development Lead  
**Status**: Final  
**Section**: 2.1 - Flutter Environment Setup

## Executive Summary

This document defines the Git branching strategy, workflow, and release management process for the Nonna App project. It establishes guidelines for branch naming, code review processes, deployment procedures, and team collaboration practices to ensure smooth development and reliable releases.

## References

This document aligns with:
- `docs/03_environment_setup/04_Git_Repository_Initialization_Confirmation.md` - Git repository setup
- `.pre-commit-config.yaml` - Pre-commit hooks and code quality checks
- CI/CD pipeline configuration (GitHub Actions)

---

## 1. Branching Model Overview

### 1.1 Selected Strategy

The Nonna App project uses a **modified Git Flow** branching strategy, optimized for continuous delivery and mobile app releases.

**Key Principles:**
- **Main Branch**: Always production-ready, reflects latest released code
- **Develop Branch**: Integration branch for features, reflects latest development state
- **Feature Branches**: Isolated development of new features
- **Release Branches**: Preparation for app store releases
- **Hotfix Branches**: Emergency fixes for production issues

### 1.2 Branch Types

| Branch Type | Purpose | Lifetime | Base Branch | Merge Into |
|-------------|---------|----------|-------------|------------|
| `main` | Production code | Permanent | - | - |
| `develop` | Development integration | Permanent | `main` | - |
| `feature/*` | New features | Temporary | `develop` | `develop` |
| `bugfix/*` | Bug fixes | Temporary | `develop` | `develop` |
| `release/*` | Release preparation | Temporary | `develop` | `main` + `develop` |
| `hotfix/*` | Production hotfixes | Temporary | `main` | `main` + `develop` |

---

## 2. Permanent Branches

### 2.1 Main Branch

**Branch Name**: `main`

**Purpose**: 
- Represents production-ready code
- Always deployable to app stores
- Protected branch with strict merge requirements

**Protection Rules:**
- ✅ Require pull request reviews (minimum 2 approvals)
- ✅ Require status checks to pass (CI/CD, tests)
- ✅ Require branches to be up to date before merging
- ✅ Restrict force pushes
- ✅ Restrict deletions
- ✅ Require signed commits (recommended)

**Merge Strategy:**
- Only merge from `release/*` or `hotfix/*` branches
- Use **squash and merge** or **merge commit** (with meaningful message)
- Tag each merge with version number (e.g., `v1.0.0`)

**Example Workflow:**
```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/1.0.0

# After testing and QA approval
git checkout main
git merge --no-ff release/1.0.0 -m "Release v1.0.0"
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags
```

### 2.2 Develop Branch

**Branch Name**: `develop`

**Purpose**:
- Integration branch for ongoing development
- Reflects latest development state
- Source for feature branches

**Protection Rules:**
- ✅ Require pull request reviews (minimum 1 approval)
- ✅ Require status checks to pass (CI/CD, tests)
- ✅ Restrict force pushes
- ✅ Allow force pushes for maintainers (with caution)

**Merge Strategy:**
- Merge from `feature/*` and `bugfix/*` branches
- Use **squash and merge** for single-commit features
- Use **merge commit** for multi-commit features (preserve history)

**Example Workflow:**
```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/AUTH-123-email-verification

# After feature completion and PR approval
git checkout develop
git merge --no-ff feature/AUTH-123-email-verification
git push origin develop
```

---

## 3. Temporary Branches

### 3.1 Feature Branches

**Branch Name Pattern**: `feature/<ticket-id>-<short-description>`

**Examples:**
- `feature/AUTH-123-email-verification`
- `feature/GALLERY-45-photo-compression`
- `feature/CALENDAR-78-event-reminders`

**Purpose**:
- Develop new features in isolation
- Prevent conflicts with other developers
- Enable parallel development

**Workflow:**

**1. Create Feature Branch:**
```bash
# Start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/AUTH-123-email-verification
```

**2. Develop Feature:**
```bash
# Make changes
git add .
git commit -m "feat(auth): implement email verification flow"

# Push to remote (create PR)
git push -u origin feature/AUTH-123-email-verification
```

**3. Keep Branch Updated:**
```bash
# Regularly sync with develop
git checkout develop
git pull origin develop
git checkout feature/AUTH-123-email-verification
git rebase develop

# Resolve conflicts if any
# Force push after rebase
git push origin feature/AUTH-123-email-verification --force-with-lease
```

**4. Merge Feature:**
```bash
# Create Pull Request on GitHub
# After approval, merge via GitHub UI (squash or merge commit)
# Delete feature branch after merge
git branch -d feature/AUTH-123-email-verification
git push origin --delete feature/AUTH-123-email-verification
```

**Best Practices:**
- Keep feature branches short-lived (< 2 weeks)
- Commit frequently with meaningful messages
- Rebase on develop regularly to avoid large conflicts
- Delete branch after merge

### 3.2 Bugfix Branches

**Branch Name Pattern**: `bugfix/<ticket-id>-<short-description>`

**Examples:**
- `bugfix/BUG-456-photo-upload-crash`
- `bugfix/BUG-789-calendar-sync-issue`
- `bugfix/BUG-234-notification-not-appearing`

**Purpose**:
- Fix non-critical bugs in development
- Similar workflow to feature branches
- Merged into `develop` via pull request

**Workflow:**
```bash
# Create bugfix branch from develop
git checkout develop
git pull origin develop
git checkout -b bugfix/BUG-456-photo-upload-crash

# Fix bug and commit
git add .
git commit -m "fix(gallery): resolve photo upload crash on iOS"

# Push and create PR
git push -u origin bugfix/BUG-456-photo-upload-crash

# After PR approval, merge into develop
# Delete branch after merge
```

### 3.3 Release Branches

**Branch Name Pattern**: `release/<version>`

**Examples:**
- `release/1.0.0` (major release)
- `release/1.1.0` (minor release)
- `release/1.0.1` (patch release)

**Purpose**:
- Prepare code for production release
- Perform final testing and QA
- Fix release-specific bugs
- Update version numbers and changelogs

**Workflow:**

**1. Create Release Branch:**
```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/1.0.0
git push -u origin release/1.0.0
```

**2. Prepare Release:**
```bash
# Update version in pubspec.yaml
# Update CHANGELOG.md
# Build release artifacts
flutter build apk --release
flutter build ios --release

# Commit version changes
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.0.0"
git push origin release/1.0.0
```

**3. QA and Bug Fixes:**
```bash
# If bugs found during QA, fix on release branch
git add .
git commit -m "fix(release): resolve issue found in QA"
git push origin release/1.0.0

# Do NOT merge new features into release branch
```

**4. Merge Release:**
```bash
# Merge into main
git checkout main
git pull origin main
git merge --no-ff release/1.0.0 -m "Release v1.0.0"
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags

# Merge back into develop
git checkout develop
git pull origin develop
git merge --no-ff release/1.0.0 -m "Merge release v1.0.0 back into develop"
git push origin develop

# Delete release branch
git push origin --delete release/1.0.0
git branch -d release/1.0.0
```

**Best Practices:**
- Create release branch when develop is feature-complete
- Only fix critical bugs on release branch
- Keep release branch short-lived (1-2 weeks max)
- Tag main branch with semantic version after merge

### 3.4 Hotfix Branches

**Branch Name Pattern**: `hotfix/<version>-<short-description>`

**Examples:**
- `hotfix/1.0.1-critical-crash`
- `hotfix/1.1.1-security-vulnerability`
- `hotfix/1.0.2-payment-issue`

**Purpose**:
- Fix critical production bugs immediately
- Bypass normal development workflow
- Deploy urgent fixes to production

**Workflow:**

**1. Create Hotfix Branch:**
```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/1.0.1-critical-crash
git push -u origin hotfix/1.0.1-critical-crash
```

**2. Fix Issue:**
```bash
# Fix critical bug
git add .
git commit -m "fix(critical): resolve app crash on startup"

# Update version (patch bump)
# Update CHANGELOG.md
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.0.1"
git push origin hotfix/1.0.1-critical-crash
```

**3. Merge Hotfix:**
```bash
# Merge into main
git checkout main
git pull origin main
git merge --no-ff hotfix/1.0.1-critical-crash -m "Hotfix v1.0.1"
git tag -a v1.0.1 -m "Hotfix version 1.0.1"
git push origin main --tags

# Merge back into develop
git checkout develop
git pull origin develop
git merge --no-ff hotfix/1.0.1-critical-crash -m "Merge hotfix v1.0.1 into develop"
git push origin develop

# If release branch exists, merge into it too
git checkout release/1.1.0
git merge --no-ff hotfix/1.0.1-critical-crash
git push origin release/1.1.0

# Delete hotfix branch
git push origin --delete hotfix/1.0.1-critical-crash
git branch -d hotfix/1.0.1-critical-crash
```

**Best Practices:**
- Use hotfix branches only for critical production issues
- Keep hotfix branches extremely short-lived (hours to 1 day)
- Thoroughly test hotfix before deploying
- Document hotfix in CHANGELOG and Git tag

---

## 4. Versioning Strategy

### 4.1 Semantic Versioning

The Nonna App follows **Semantic Versioning 2.0.0** (SemVer):

**Format**: `MAJOR.MINOR.PATCH`

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major new features
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

**Examples:**
- `1.0.0` - Initial public release
- `1.1.0` - Add calendar feature
- `1.0.1` - Fix photo upload bug
- `2.0.0` - Redesign UI (breaking changes)

### 4.2 Version Management

**Update Version in `pubspec.yaml`:**
```yaml
version: 1.0.0+1
#        ^^^^^  ^
#        |      Build number (incremented with each build)
#        Version name (semantic version)
```

**Update Version Script:**
```bash
# Bump version automatically (optional helper script)
# scripts/bump_version.sh

#!/bin/bash
VERSION=$1
BUILD_NUMBER=$2

# Update pubspec.yaml
sed -i '' "s/version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

echo "Updated version to $VERSION+$BUILD_NUMBER"
```

**Tag Releases:**
```bash
# Tag release with version
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tags to remote
git push origin --tags

# List all tags
git tag -l

# Delete tag (if needed)
git tag -d v1.0.0
git push origin --delete v1.0.0
```

---

## 5. Pull Request Process

### 5.1 PR Creation Guidelines

**Before Creating PR:**
1. ✅ Ensure all tests pass: `flutter test`
2. ✅ Run linter: `flutter analyze`
3. ✅ Format code: `dart format .`
4. ✅ Run pre-commit hooks: `pre-commit run --all-files`
5. ✅ Update documentation if needed
6. ✅ Add/update tests for new functionality

**PR Title Format:**
```
<type>(<scope>): <short description>
```

**Examples:**
- `feat(auth): add email verification flow`
- `fix(gallery): resolve photo upload crash on iOS`
- `docs: update Flutter installation guide`

**PR Description Template:**
```markdown
## Description
<!-- Brief description of changes -->

## Related Issue
<!-- Link to Jira/GitHub issue -->
Closes #123

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
<!-- Describe testing performed -->
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Tested on Android emulator (Pixel 6, API 33)
- [ ] Tested on iOS simulator (iPhone 15 Pro, iOS 17)
- [ ] Tested on physical device (Android/iOS)

## Screenshots
<!-- Add screenshots if UI changes -->

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated (if applicable)
- [ ] No new warnings introduced
- [ ] All tests pass locally
- [ ] Pre-commit hooks pass

## Additional Notes
<!-- Any additional information -->
```

### 5.2 Code Review Process

**Review Requirements:**

| Branch | Reviewers Required | Status Checks |
|--------|-------------------|---------------|
| `develop` | 1 approval | CI/CD, Tests, Linter |
| `main` | 2 approvals | CI/CD, Tests, Linter, Security |
| `release/*` | 2 approvals | CI/CD, Tests, Linter, QA Sign-off |

**Reviewer Responsibilities:**
1. ✅ Review code for correctness and quality
2. ✅ Check test coverage
3. ✅ Verify documentation updates
4. ✅ Test locally if significant changes
5. ✅ Provide constructive feedback
6. ✅ Approve or request changes

**Author Responsibilities:**
1. ✅ Address all review comments
2. ✅ Re-request review after changes
3. ✅ Resolve merge conflicts
4. ✅ Ensure CI/CD passes
5. ✅ Merge PR after approval

### 5.3 Merge Strategies

**Squash and Merge:**
- Use for feature branches with many small commits
- Creates single commit on target branch
- Keeps history clean

**Merge Commit:**
- Use for release/hotfix branches
- Preserves commit history
- Shows clear merge points

**Rebase and Merge:**
- Use for small, atomic changes
- Creates linear history
- Avoids merge commits

**Default Strategy by Branch:**
- `feature/*` → `develop`: **Squash and merge**
- `bugfix/*` → `develop`: **Squash and merge**
- `release/*` → `main`: **Merge commit**
- `hotfix/*` → `main`: **Merge commit**

---

## 6. Deployment Workflow

### 6.1 Development Deployment

**Environment**: Development/Staging

**Trigger**: Merge to `develop` branch

**Process:**
1. PR merged into `develop`
2. GitHub Actions builds app
3. Deploy to Firebase App Distribution (beta testing)
4. Notify QA team for testing

**GitHub Actions Workflow (`.github/workflows/deploy-dev.yml`):**
```yaml
name: Deploy to Development

on:
  push:
    branches: [develop]

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --debug
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID_ANDROID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          file: build/app/outputs/flutter-apk/app-debug.apk
```

### 6.2 Production Deployment

**Environment**: Production (App Stores)

**Trigger**: Merge to `main` branch via `release/*` or `hotfix/*`

**Process:**
1. Release branch created from `develop`
2. QA testing on release branch
3. Merge release into `main`
4. Tag with version number
5. GitHub Actions builds release artifacts
6. Manual review and approval required
7. Deploy to Google Play Store (Android)
8. Deploy to Apple App Store (iOS)

**GitHub Actions Workflow (`.github/workflows/deploy-prod.yml`):**
```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build appbundle --release
      - name: Upload to Google Play
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.example.nonna_app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```

---

## 7. Conflict Resolution

### 7.1 Preventing Conflicts

**Best Practices:**
- Pull latest changes frequently: `git pull origin develop`
- Keep feature branches short-lived
- Communicate with team about overlapping work
- Rebase feature branches on develop regularly

### 7.2 Resolving Conflicts

**Manual Resolution:**
```bash
# Update local branch
git checkout feature/my-feature
git pull origin develop

# Conflicts will be marked in files:
# <<<<<<< HEAD
# Your changes
# =======
# Their changes
# >>>>>>> develop

# Edit files to resolve conflicts
# Remove conflict markers

# Mark as resolved
git add <resolved-files>
git commit -m "chore: resolve merge conflicts with develop"
git push origin feature/my-feature
```

**Abort Merge:**
```bash
# If conflict resolution is too complex
git merge --abort
git rebase --abort
```

---

## 8. Team Collaboration Guidelines

### 8.1 Communication

**Before Starting Work:**
- Check Jira/GitHub issues for assignments
- Comment on issue to claim work
- Create branch with issue ID in name

**During Development:**
- Push work-in-progress commits regularly
- Create draft PR early for visibility
- Ask for feedback in PR comments
- Notify team of blockers

**After Completion:**
- Mark PR as ready for review
- Tag reviewers
- Respond to review comments promptly
- Merge PR after approval

### 8.2 Code Ownership

**Code Owners File (`.github/CODEOWNERS`):**
```
# Global owners
* @development-lead

# Feature-specific owners
/lib/features/auth/ @auth-team
/lib/features/gallery/ @gallery-team
/lib/features/calendar/ @calendar-team

# Infrastructure
/.github/ @devops-team
/docs/ @documentation-team
```

---

## 9. Branch Management

### 9.1 Branch Cleanup

**Automated Cleanup:**
```bash
# Delete merged branches (local)
git branch --merged develop | grep -v "develop" | grep -v "main" | xargs git branch -d

# Delete remote merged branches
git fetch -p

# List stale branches
git branch -vv | grep ': gone]' | awk '{print $1}'
```

**Manual Cleanup:**
```bash
# Delete local branch
git branch -d feature/old-feature

# Delete remote branch
git push origin --delete feature/old-feature

# Delete local tracking of deleted remote branch
git fetch -p
```

### 9.2 Branch Protection

**Configure on GitHub:**
1. Go to **Settings** → **Branches**
2. Add branch protection rule for `main`:
   - Require pull request reviews (2)
   - Require status checks to pass
   - Require branches to be up to date
   - Restrict force pushes
   - Restrict deletions
3. Add branch protection rule for `develop`:
   - Require pull request reviews (1)
   - Require status checks to pass

---

## 10. Monitoring and Metrics

### 10.1 Git Metrics

**Track Key Metrics:**
- PR merge time (target: < 24 hours)
- Code review cycle time (target: < 4 hours)
- Build success rate (target: > 95%)
- Number of open PRs (target: < 10)
- Branch lifetime (target: < 2 weeks)

**GitHub Insights:**
- Navigate to **Insights** → **Pulse** for activity summary
- Review **Contributors** for team activity
- Check **Network** for branch visualization

### 10.2 Quality Gates

**Automated Checks (CI/CD):**
- ✅ Flutter tests pass (`flutter test`)
- ✅ Linter passes (`flutter analyze`)
- ✅ Code formatted (`dart format --set-exit-if-changed .`)
- ✅ Security scan passes (CodeQL, detect-secrets)
- ✅ Build succeeds (Android & iOS)

**Manual Checks:**
- ✅ Code review approval(s)
- ✅ QA sign-off (for releases)
- ✅ Product owner approval (for major features)

---

## 11. Branching Strategy Checklist

### 11.1 Validation Checklist

- [ ] **Branch Structure**
  - [ ] `main` branch exists and protected
  - [ ] `develop` branch exists and protected
  - [ ] Branch naming conventions documented
  - [ ] Branch protection rules configured

- [ ] **Workflow Documentation**
  - [ ] Feature branch workflow documented
  - [ ] Release process documented
  - [ ] Hotfix process documented
  - [ ] PR process documented

- [ ] **Team Alignment**
  - [ ] Team trained on branching strategy
  - [ ] Code owners assigned
  - [ ] Review requirements defined
  - [ ] Merge strategies agreed upon

- [ ] **Automation**
  - [ ] CI/CD configured for `develop` and `main`
  - [ ] Automated deployments configured
  - [ ] Branch cleanup automated
  - [ ] Status checks configured

- [ ] **Version Management**
  - [ ] Semantic versioning adopted
  - [ ] Version bump process defined
  - [ ] Release tagging process defined
  - [ ] CHANGELOG maintained

---

## 12. References and Resources

### 12.1 Official Documentation

- Git Flow: https://nvie.com/posts/a-successful-git-branching-model/
- GitHub Flow: https://guides.github.com/introduction/flow/
- Semantic Versioning: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/

### 12.2 Internal Resources

- `docs/03_environment_setup/04_Git_Repository_Initialization_Confirmation.md`
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.github/workflows/` - CI/CD configuration
- `CHANGELOG.md` - Release history

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Quarterly or when workflow changes  
**Status**: ✅ Complete
