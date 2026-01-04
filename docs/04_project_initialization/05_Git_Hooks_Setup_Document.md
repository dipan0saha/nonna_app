# Git Hooks Setup Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Lead  
**Status**: Implemented  
**Section**: 2.2 - Project Initialization

## Executive Summary

This document describes the Git hooks configuration for the Nonna App, implemented using the `pre-commit` framework. Git hooks enforce code quality standards, prevent common mistakes, and maintain consistency across the development team by running automated checks before code is committed.

## What Are Git Hooks?

Git hooks are scripts that run automatically at specific points in the Git workflow. They enable automated quality checks, preventing issues before they enter the codebase.

### Hook Types Used in Nonna App

1. **Pre-commit hooks**: Run before a commit is created
2. **Pre-push hooks**: Run before pushing to remote repository (future implementation)

## Pre-commit Framework

### Installation

The project uses the `pre-commit` framework for managing Git hooks.

#### Prerequisites
- Python 3.7 or higher
- pip (Python package manager)

#### Installation Steps

**1. Install pre-commit globally**:
```bash
# Using pip
pip install pre-commit

# Or using pip3
pip3 install pre-commit

# Or using Homebrew (macOS)
brew install pre-commit
```

**2. Install hooks in the repository**:
```bash
cd /path/to/nonna_app
pre-commit install
```

**3. Verify installation**:
```bash
pre-commit --version
# Output: pre-commit 3.x.x
```

### Configuration File

**File**: `.pre-commit-config.yaml`

**Location**: Repository root directory

## Configured Pre-commit Hooks

### 1. Flutter Analyze

**Hook ID**: `flutter-analyze`  
**Purpose**: Run static code analysis on Dart code  
**Language**: system (uses locally installed Flutter)

**Command**:
```bash
flutter analyze --fatal-infos --fatal-warnings
```

**What it checks**:
- Syntax errors
- Type errors
- Potential runtime issues
- Code style violations
- Unused imports and variables
- Missing return statements
- Null safety issues

**Configuration**:
```yaml
- id: flutter-analyze
  name: Flutter Analyze
  entry: flutter analyze --fatal-infos --fatal-warnings
  language: system
  pass_filenames: false
```

**Flags**:
- `--fatal-infos`: Treat info-level issues as errors
- `--fatal-warnings`: Treat warnings as errors
- Ensures zero tolerance for code quality issues

**Example Output**:
```
Flutter Analyze.........................................Passed
```

### 2. Flutter Format

**Hook ID**: `flutter-format`  
**Purpose**: Enforce consistent code formatting  
**Language**: system (uses locally installed Dart)

**Command**:
```bash
dart format --set-exit-if-changed lib test
```

**What it checks**:
- Proper indentation (2 spaces)
- Line length (80 characters default)
- Spacing around operators
- Bracket placement
- Consistent code style

**Configuration**:
```yaml
- id: flutter-format
  name: Flutter Format
  entry: dart format --set-exit-if-changed lib test
  language: system
  pass_filenames: false
```

**Flags**:
- `--set-exit-if-changed`: Exits with error if formatting changes would be made
- Formats both `lib/` and `test/` directories

**Example Output**:
```
Flutter Format.........................................Passed
```

**If formatting issues exist**:
```
Flutter Format.........................................Failed
- hook id: flutter-format
- exit code: 1

Formatted lib/main.dart
Formatted lib/features/auth/login_screen.dart
```

**To fix**:
```bash
dart format lib test
git add .
git commit
```

### 3. Detect Secrets

**Hook ID**: `detect-secrets`  
**Purpose**: Prevent committing sensitive information  
**Language**: system (uses detect-secrets Python package)

**Command**:
```bash
detect-secrets-hook --baseline .secrets.baseline
```

**What it detects**:
- API keys and tokens
- Passwords and credentials
- Private keys
- Authentication tokens
- AWS keys
- Database connection strings
- OAuth secrets

**Configuration**:
```yaml
- id: detect-secrets
  name: Detect Secrets
  entry: detect-secrets-hook --baseline .secrets.baseline
  language: system
  pass_filenames: false
```

**Baseline File**: `.secrets.baseline`
- Contains known false positives
- Updated when legitimate secrets-like strings are added
- Prevents false alarms while maintaining security

**Example Output**:
```
Detect Secrets..........................................Passed
```

**If secrets detected**:
```
Detect Secrets..........................................Failed
- hook id: detect-secrets
- exit code: 1

ERROR: Potential secrets detected in your changes.
Please remove them before committing.

File: lib/config/api_config.dart
Line 5: Potential API key detected
```

**To fix**:
1. Remove the hardcoded secret
2. Move to environment variables (.env file)
3. Update .secrets.baseline if false positive

**Update baseline** (after confirming false positive):
```bash
detect-secrets scan --baseline .secrets.baseline
```

### 4. Check Pubspec Changes

**Hook ID**: `check-pubspec`  
**Purpose**: Automatically run `flutter pub get` when pubspec.yaml changes  
**Language**: system

**Command**:
```bash
bash -c "if git diff --cached --name-only | grep -q pubspec.yaml; then 
  echo 'pubspec.yaml changed - running flutter pub get'; 
  flutter pub get; 
fi"
```

**What it does**:
- Detects changes to `pubspec.yaml`
- Automatically updates dependencies
- Ensures `pubspec.lock` is in sync
- Prevents "dependency mismatch" errors

**Configuration**:
```yaml
- id: check-pubspec
  name: Check Pubspec Changes
  entry: bash -c "if git diff --cached --name-only | grep -q pubspec.yaml; then echo 'pubspec.yaml changed - running flutter pub get'; flutter pub get; fi"
  language: system
  pass_filenames: false
```

**Example Output**:
```
Check Pubspec Changes...................................Passed
pubspec.yaml changed - running flutter pub get
Resolving dependencies... (2.3s)
Got dependencies!
```

## Hook Execution Flow

```
Developer runs: git commit -m "message"
                    ↓
        Pre-commit hooks trigger
                    ↓
    ┌───────────────────────────┐
    │  1. Flutter Analyze       │
    │     (Static Analysis)     │
    └───────────┬───────────────┘
                ↓ (Pass)
    ┌───────────────────────────┐
    │  2. Flutter Format        │
    │     (Code Formatting)     │
    └───────────┬───────────────┘
                ↓ (Pass)
    ┌───────────────────────────┐
    │  3. Detect Secrets        │
    │     (Security Check)      │
    └───────────┬───────────────┘
                ↓ (Pass)
    ┌───────────────────────────┐
    │  4. Check Pubspec         │
    │     (Dependency Update)   │
    └───────────┬───────────────┘
                ↓ (All Pass)
    ┌───────────────────────────┐
    │  Commit Created ✅        │
    └───────────────────────────┘

        If any hook fails ❌
                ↓
        Commit is blocked
                ↓
        Developer fixes issues
                ↓
        Retry commit
```

## Running Hooks Manually

### Run All Hooks on All Files
```bash
pre-commit run --all-files
```

**Use cases**:
- Initial setup verification
- After updating hooks configuration
- Checking entire codebase
- CI/CD pipeline integration

**Example Output**:
```
Flutter Analyze.........................................Passed
Flutter Format.........................................Passed
Detect Secrets..........................................Passed
Check Pubspec Changes...................................Passed
```

### Run Specific Hook
```bash
# Run only Flutter analyze
pre-commit run flutter-analyze --all-files

# Run only formatting check
pre-commit run flutter-format --all-files

# Run only secrets detection
pre-commit run detect-secrets --all-files
```

### Skip Hooks (Emergency Use Only)
```bash
# Skip all pre-commit hooks
git commit --no-verify -m "Emergency fix"

# Or use short flag
git commit -n -m "Emergency fix"
```

**⚠️ Warning**: Only skip hooks in genuine emergencies. The bypassed checks must be addressed in a follow-up commit.

## Integration with Makefile

The project's Makefile includes a pre-commit target:

```makefile
pre-commit:
	pre-commit run --all-files
	@echo "✅ Pre-commit checks passed"
```

**Usage**:
```bash
make pre-commit
```

This is useful for:
- Running checks before pushing
- CI/CD integration
- Manual verification

## CI/CD Integration

Pre-commit hooks are also integrated into the GitHub Actions CI pipeline:

**In CI workflow** (`.github/workflows/ci.yml`):
```yaml
- name: Verify formatting
  run: dart format --set-exit-if-changed .

- name: Analyze code
  run: flutter analyze --fatal-infos --fatal-warnings
```

This ensures:
- Local hooks match CI checks
- No surprises when pushing code
- Consistent quality standards

## Troubleshooting

### Issue 1: Hooks Not Running

**Symptom**: Commit succeeds without running hooks

**Solution**:
```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Verify installation
ls -la .git/hooks/
# Should see pre-commit script
```

### Issue 2: Flutter Command Not Found

**Symptom**: `flutter: command not found` when hooks run

**Solution**:
```bash
# Verify Flutter is in PATH
which flutter

# If not found, add to PATH in shell config
# For bash (~/.bashrc or ~/.bash_profile):
export PATH="$PATH:/path/to/flutter/bin"

# For zsh (~/.zshrc):
export PATH="$PATH:/path/to/flutter/bin"

# Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

### Issue 3: detect-secrets Not Found

**Symptom**: `detect-secrets-hook: command not found`

**Solution**:
```bash
# Install detect-secrets
pip install detect-secrets

# Or using pip3
pip3 install detect-secrets

# Verify installation
which detect-secrets-hook
```

### Issue 4: Formatting Failures

**Symptom**: Flutter format hook fails repeatedly

**Solution**:
```bash
# Format the code manually
dart format lib test

# Stage the formatted changes
git add .

# Retry commit
git commit
```

### Issue 5: False Positive Secret Detection

**Symptom**: Legitimate code flagged as containing secrets

**Solution**:
```bash
# Update the baseline to include the false positive
detect-secrets scan --baseline .secrets.baseline

# Add updated baseline to commit
git add .secrets.baseline

# Retry commit
git commit
```

### Issue 6: Slow Hook Execution

**Symptom**: Hooks take too long to run

**Solution**:
```bash
# Run hooks only on staged files (for custom hooks)
# Current config runs on all files - this is intentional for code quality

# Alternative: Use --files flag for manual runs
pre-commit run --files lib/specific_file.dart
```

## Best Practices

### 1. Don't Skip Hooks

**❌ Avoid**:
```bash
git commit --no-verify -m "Quick fix"
```

**✅ Prefer**:
```bash
# Fix issues and commit properly
dart format lib test
git add .
git commit -m "Fix formatting issues"
```

### 2. Run Hooks Before Pushing

```bash
# Good practice before git push
make pre-commit

# Or
pre-commit run --all-files
```

### 3. Keep Hooks Updated

```bash
# Update pre-commit framework
pip install --upgrade pre-commit

# Update hook configurations
pre-commit autoupdate
```

### 4. Educate Team Members

- Ensure all team members have pre-commit installed
- Document hook installation in onboarding
- Share troubleshooting guide
- Encourage manual hook runs before big changes

### 5. Test Hook Changes

When modifying `.pre-commit-config.yaml`:

```bash
# Test changes on all files
pre-commit run --all-files

# Verify no issues
git status
```

## Advanced Configuration

### Adding New Hooks

To add a new hook, edit `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
  # ... existing hooks ...
  
  # Example: Add custom test hook
  - id: run-tests
    name: Run Unit Tests
    entry: flutter test
    language: system
    pass_filenames: false
    stages: [commit]  # or [push] for pre-push hook
```

### Configuring Hook Stages

Hooks can run at different stages:

```yaml
- id: flutter-analyze
  stages: [commit]  # Run on commit

- id: run-integration-tests
  stages: [push]    # Run on push (not implemented yet)

- id: build-check
  stages: [manual]  # Only run when manually triggered
```

### Environment-Specific Hooks

```yaml
- id: flutter-analyze
  name: Flutter Analyze
  entry: bash -c 'if [ "$CI" = "true" ]; then flutter analyze --fatal-infos; else flutter analyze; fi'
  language: system
  pass_filenames: false
```

## Performance Considerations

### Current Hook Performance

Typical execution times (on average):
- Flutter Analyze: 5-15 seconds
- Flutter Format: 2-5 seconds
- Detect Secrets: 1-3 seconds
- Check Pubspec: <1 second (when no changes)

**Total**: ~10-25 seconds per commit

### Optimization Tips

1. **Use specific paths** (already implemented):
   ```yaml
   entry: dart format lib test  # Only format necessary directories
   ```

2. **Cache dependencies**: Flutter/Dart cache improves performance over time

3. **Incremental analysis**: Flutter analyze already uses incremental mode

4. **Skip hooks for minor changes** (use sparingly):
   ```bash
   # Only for documentation changes, etc.
   git commit --no-verify -m "docs: update README"
   ```

## Security Considerations

### Secrets Management

**✅ Do**:
- Use environment variables for sensitive data
- Store secrets in `.env` file (not in version control)
- Use `.env.example` for template
- Keep `.secrets.baseline` up to date

**❌ Don't**:
- Commit hardcoded API keys
- Store passwords in code
- Share credentials in commit messages
- Bypass secrets detection without review

### Baseline Management

The `.secrets.baseline` file should:
- Be committed to version control
- Be reviewed when updated
- Only contain verified false positives
- Be regenerated periodically

```bash
# Regenerate baseline (review changes carefully)
detect-secrets scan --baseline .secrets.baseline
git diff .secrets.baseline  # Review changes
```

## Team Onboarding

### New Developer Setup

**Step 1: Install pre-commit**
```bash
pip install pre-commit
```

**Step 2: Install detect-secrets**
```bash
pip install detect-secrets
```

**Step 3: Install hooks in repository**
```bash
cd nonna_app
pre-commit install
```

**Step 4: Test hooks**
```bash
pre-commit run --all-files
```

**Step 5: Make a test commit**
```bash
# Make a small change
echo "# Test" >> README.md
git add README.md
git commit -m "test: verify pre-commit hooks"
# Hooks should run automatically
```

### Verification Checklist

After setup, verify:
- [ ] `pre-commit --version` shows installed version
- [ ] `detect-secrets --version` shows installed version
- [ ] `.git/hooks/pre-commit` file exists
- [ ] `pre-commit run --all-files` completes successfully
- [ ] Test commit triggers all hooks

## References

- Pre-commit Framework: https://pre-commit.com/
- Flutter Code Formatting: https://docs.flutter.dev/development/tools/formatting
- Flutter Analyze: https://docs.flutter.dev/testing/debugging#the-dart-analyzer
- Detect Secrets: https://github.com/Yelp/detect-secrets
- Git Hooks: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks

## Future Enhancements

### Planned Additions

1. **Pre-push hooks**:
   - Run full test suite before push
   - Verify branch naming conventions
   - Check commit message format

2. **Commit message validation**:
   - Enforce conventional commits format
   - Require issue/ticket references
   - Check message length

3. **Additional checks**:
   - Lint Dart documentation comments
   - Check for TODOs and FIXMEs
   - Validate import organization
   - Check file size limits

4. **Performance optimization**:
   - Run only on changed files where possible
   - Parallel hook execution
   - Caching improvements

## Approval

**Status**: ✅ Implemented and Functional

Git hooks are properly configured and actively enforcing code quality standards. The setup includes:
- ✅ Comprehensive pre-commit hooks
- ✅ Security scanning (detect-secrets)
- ✅ Code quality enforcement (analyze + format)
- ✅ Dependency management automation
- ✅ CI/CD integration
- ✅ Team documentation and onboarding guide

**All developers are required to install and use pre-commit hooks.**

---

**Document Maintained By**: Technical Lead Team  
**Review Frequency**: Quarterly or on hook configuration changes
