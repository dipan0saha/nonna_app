# Code Review Process Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Technical Lead  
**Status**: Active  
**Section**: 2.2 - Project Initialization

## Executive Summary

This document defines the code review process and guidelines for the Nonna App project. Code reviews are a critical quality assurance practice that ensures code quality, knowledge sharing, and adherence to project standards before changes are merged into the main codebase.

## Purpose of Code Reviews

### Primary Goals

1. **Quality Assurance**: Catch bugs, logic errors, and potential issues before production
2. **Knowledge Sharing**: Spread understanding of the codebase across the team
3. **Standards Enforcement**: Ensure adherence to coding standards and best practices
4. **Mentorship**: Provide learning opportunities for junior developers
5. **Architecture Alignment**: Verify changes align with system architecture
6. **Security**: Identify potential security vulnerabilities
7. **Documentation**: Ensure code is well-documented and maintainable

### Benefits

- **Fewer Bugs**: Catch issues before they reach production
- **Better Code**: Collaborative improvement leads to higher quality
- **Team Learning**: Everyone learns from reviewing and being reviewed
- **Consistent Style**: Maintain uniform coding standards
- **Reduced Technical Debt**: Prevent shortcuts that create future problems
- **Collective Ownership**: Entire team is responsible for code quality

## Code Review Workflow

### Overview

```
Developer → Create Feature Branch → Write Code → Self-Review
                                            ↓
                                    Create Pull Request
                                            ↓
                    Automated Checks (CI/CD Pipeline)
                                            ↓
                                [Checks Pass/Fail]
                                            ↓
                            Assign Reviewers (1-2 people)
                                            ↓
                                    Reviewers Assess
                                            ↓
                        [Approve / Request Changes / Comment]
                                            ↓
            Developer Addresses Feedback → Push Updates
                                            ↓
                            Reviewers Re-review
                                            ↓
                                Final Approval
                                            ↓
                            Merge to Target Branch
                                            ↓
                            Delete Feature Branch
```

## Pull Request Requirements

### Before Creating a PR

**Developer Checklist**:
- [ ] Code compiles without errors
- [ ] All tests pass locally (`flutter test`)
- [ ] Code is properly formatted (`dart format`)
- [ ] Static analysis passes (`flutter analyze`)
- [ ] Pre-commit hooks pass
- [ ] Self-review completed
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG updated (for significant changes)
- [ ] Screenshots added (for UI changes)

### Creating a Pull Request

**Required Elements**:

1. **Title**: Clear, concise description following format:
   ```
   [type]: Brief description (50 chars max)
   
   Examples:
   feat: Add feeding tile widget
   fix: Correct date formatting in diary
   docs: Update API integration guide
   refactor: Simplify authentication flow
   test: Add unit tests for tile factory
   ```

2. **Description**: Use the PR template (see section below)

3. **Labels**: Apply appropriate labels:
   - `feature`: New functionality
   - `bugfix`: Bug corrections
   - `enhancement`: Improvements to existing features
   - `documentation`: Documentation updates
   - `refactor`: Code restructuring
   - `tests`: Test additions/updates
   - `security`: Security-related changes
   - `breaking-change`: Breaking API changes

4. **Reviewers**: Assign 1-2 reviewers based on:
   - Expertise in the affected area
   - Availability
   - Balance of review load across team

5. **Linked Issues**: Reference related issues using keywords:
   ```
   Closes #123
   Fixes #456
   Relates to #789
   ```

### PR Size Guidelines

**Target Size**: 200-400 lines changed (excluding generated files)

**Why?**:
- Easier to review thoroughly
- Faster review turnaround
- Reduced merge conflicts
- Better for finding bugs

**Size Categories**:
- **Tiny** (<50 lines): Quick review, simple changes
- **Small** (50-200 lines): Standard review
- **Medium** (200-400 lines): Detailed review required
- **Large** (400-1000 lines): Consider splitting
- **Huge** (>1000 lines): Must split or provide strong justification

**Exceptions**:
- Generated code (e.g., *.g.dart files)
- Asset files
- Configuration files
- Initial project setup
- Large refactoring (requires pre-approval)

## Reviewer Responsibilities

### What Reviewers Should Check

#### 1. Functionality
- [ ] Code achieves its intended purpose
- [ ] Logic is correct and handles edge cases
- [ ] No obvious bugs or errors
- [ ] Error handling is appropriate
- [ ] User experience is considered

#### 2. Code Quality
- [ ] Follows project coding standards
- [ ] Uses appropriate design patterns
- [ ] Is maintainable and readable
- [ ] Avoids unnecessary complexity
- [ ] No code duplication
- [ ] Proper naming conventions

#### 3. Architecture & Design
- [ ] Aligns with system architecture
- [ ] Follows Clean Architecture principles
- [ ] Proper separation of concerns
- [ ] State management done correctly
- [ ] Adheres to tile-based architecture (if applicable)

#### 4. Testing
- [ ] Adequate test coverage
- [ ] Tests are meaningful and test the right things
- [ ] Tests follow project testing patterns
- [ ] Edge cases are tested
- [ ] Tests pass in CI/CD

#### 5. Documentation
- [ ] Public APIs are documented
- [ ] Complex logic has explanatory comments
- [ ] README updated (if needed)
- [ ] Architecture docs updated (if needed)

#### 6. Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation is present
- [ ] No SQL injection risks
- [ ] Secure data handling
- [ ] Authentication/authorization correct

#### 7. Performance
- [ ] No obvious performance issues
- [ ] Efficient algorithms used
- [ ] No memory leaks
- [ ] Appropriate use of async/await
- [ ] Database queries are optimized

### Review Timeline

**Response Time**:
- **Initial Review**: Within 24 hours of assignment
- **Re-review**: Within 4-8 hours after changes

**Priority Levels**:
- **Critical** (hotfix): Same day
- **High** (urgent feature): 1 day
- **Normal**: 1-2 days
- **Low** (refactor/docs): 2-3 days

### Review Types

#### 1. Standard Review
- Thorough examination of all changes
- Comments on issues and suggestions
- Approval or request for changes

#### 2. LGTM Review
"Looks Good To Me" - Quick approval for:
- Tiny changes
- Documentation updates
- Simple bug fixes
- Changes by senior developers

#### 3. Rubber Stamp Review (Discouraged)
- Approving without actually reviewing
- **Not acceptable** except for:
  - Auto-generated dependency updates (Dependabot)
  - Merge conflict resolutions (after verification)

## Providing Feedback

### Feedback Types

#### 1. **Blocking Issues** (Must Fix)
Issues that prevent approval:

```
❌ BLOCKING: This will cause a runtime error when userId is null.
Please add null check before accessing userId.toString().
```

#### 2. **Suggestions** (Nice to Have)
Improvements that would enhance quality:

```
💡 SUGGESTION: Consider using `const` here for better performance.
This widget is immutable and could benefit from compile-time constant optimization.
```

#### 3. **Questions** (Clarification Needed)
Seeking understanding:

```
❓ QUESTION: Why did you choose to use a StatefulWidget here?
Could this be a StatelessWidget with Riverpod state management?
```

#### 4. **Nitpicks** (Optional)
Minor style or preference issues:

```
🎨 NITPICK: Could we rename this to `userProfileData` for clarity?
Current name `data` is a bit generic.
```

#### 5. **Praise** (Positive Feedback)
Acknowledge good work:

```
✅ GREAT: Excellent test coverage! Love the edge case testing.
```

### Feedback Best Practices

**DO**:
- ✅ Be specific and actionable
- ✅ Explain the "why" behind suggestions
- ✅ Provide examples or alternatives
- ✅ Use constructive language
- ✅ Focus on the code, not the person
- ✅ Ask questions to understand intent
- ✅ Acknowledge good patterns and solutions
- ✅ Link to documentation or examples

**DON'T**:
- ❌ Be vague ("This looks wrong")
- ❌ Be condescending or rude
- ❌ Nitpick excessively on style (use linter instead)
- ❌ Request changes based on personal preference
- ❌ Approve without actually reviewing
- ❌ Request complete rewrites without discussion
- ❌ Focus on trivial issues while missing major problems

### Example Feedback

**Good Feedback**:
```
❌ BLOCKING: Potential null reference error on line 45.

The `user.profile?.name` might be null, but you're calling `.toUpperCase()` 
without null-checking. This will crash at runtime.

Suggested fix:
```dart
final name = user.profile?.name ?? 'Unknown';
final displayName = name.toUpperCase();
```

Or use null-aware operator:
```dart
final displayName = user.profile?.name?.toUpperCase() ?? 'UNKNOWN';
```
```

**Poor Feedback**:
```
❌ This is wrong. Fix it.
```

## Developer Responsibilities

### Responding to Reviews

**Mindset**:
- Reviews are about improving code, not criticizing you
- Feedback is a learning opportunity
- Reviewers are trying to help

**Response Guidelines**:

1. **Acknowledge Feedback**:
   ```
   Thanks for catching that! Fixed in latest commit.
   ```

2. **Ask for Clarification**:
   ```
   Could you elaborate on what you mean by "more robust error handling"?
   Are you concerned about network errors, data parsing errors, or both?
   ```

3. **Explain Decisions**:
   ```
   I chose StatefulWidget here because we need to manage the animation 
   controller lifecycle. Riverpod doesn't provide a good way to dispose 
   of animation controllers automatically.
   ```

4. **Push Back Respectfully** (when appropriate):
   ```
   I understand your concern about performance, but I profiled this code 
   and the difference is negligible (0.1ms). I think readability is more 
   important here. What do you think?
   ```

5. **Resolve Conversations**:
   - After addressing feedback, mark conversations as resolved
   - Add comment explaining what was done
   - Request re-review if significant changes made

### Making Changes

**Commit Strategy**:
- Push changes as new commits (don't force push during review)
- Use descriptive commit messages
- After approval, can squash commits before merge

**When to Request Re-review**:
- After making requested changes
- When addressing blocking issues
- After significant refactoring
- When you want confirmation on approach

## Approval Process

### Approval Requirements

**Minimum Approvals**:
- **Standard PR**: 1 approval from code owner or senior developer
- **Critical/Security PR**: 2 approvals, one must be senior developer
- **Architecture Changes**: 2 approvals, one must be technical lead

### Approval States

#### 1. **Approved ✅**
- All concerns addressed
- No blocking issues
- Ready to merge

#### 2. **Approved with Comments 💬**
- Approval granted
- Minor suggestions included
- Can merge, but consider addressing comments

#### 3. **Request Changes 🔴**
- Blocking issues found
- Cannot merge until addressed
- Developer must make changes and request re-review

#### 4. **Comment Only 💭**
- Providing feedback without blocking
- No approval or rejection
- Developer can merge if other approvals exist

### Merge Requirements

**Before Merging**:
- [x] All CI/CD checks pass
- [x] Required number of approvals received
- [x] No unresolved blocking conversations
- [x] All requested changes addressed
- [x] Conflicts resolved (if any)
- [x] Branch is up-to-date with target branch

**Who Can Merge**:
- PR author (after receiving approvals)
- Reviewer (if author requested)
- Project maintainers

**Merge Strategy**:
- **Squash and Merge**: Default for feature branches
  - Creates single commit in target branch
  - Keeps history clean
  - Use for most PRs
  
- **Merge Commit**: For release branches
  - Preserves complete history
  - Use when individual commits matter
  
- **Rebase and Merge**: For linear history
  - Avoids merge commits
  - Use when history must be linear

## Special Cases

### Hotfixes

**Process**:
1. Create branch from `main`
2. Make minimal fix
3. Fast-track review (same day)
4. Requires 1 senior developer approval
5. Merge to `main` and backport to `develop`
6. Deploy immediately

**Reduced Requirements**:
- Can skip some quality checks temporarily
- Must create follow-up PR to meet full standards
- Document reason for expedited process

### Dependabot PRs

**Process**:
1. Review changelog of updated dependency
2. Verify CI passes
3. Check for breaking changes
4. Approve and merge (automated or manual)

**Fast-track conditions**:
- Patch version updates
- No breaking changes
- All tests pass

### Documentation-Only Changes

**Process**:
1. Quick review for accuracy
2. Single approval sufficient
3. Can be merged by author

### Generated Code

**Process**:
- Review triggering code, not generated output
- Verify generator configuration
- Spot-check generated code for issues

## Code Review Metrics

### Tracking Success

**Key Metrics**:
- **Review Turnaround Time**: Time from PR creation to merge
- **Comments per PR**: Average feedback volume
- **Iterations**: Number of review rounds needed
- **Defect Escape Rate**: Bugs found in production vs. review
- **PR Size**: Lines of code changed

**Target Metrics**:
- Average review time: <48 hours
- Comments per PR: 3-10 (meaningful feedback)
- Iterations: 1-2 rounds
- Defect escape rate: <5%
- PR size: 200-400 lines

### Team Health Indicators

**Green Flags** ✅:
- Reviews completed promptly
- Constructive feedback
- Learning evident in comments
- Balanced review load
- Low iteration count

**Red Flags** 🚩:
- Reviews delayed >3 days
- Rubber-stamp approvals
- Aggressive or rude comments
- One person doing all reviews
- Excessive iterations (>3 rounds)

## Tools and Automation

### GitHub Features

**Branch Protection Rules**:
```
Settings → Branches → Branch protection rules

Enable:
- [x] Require pull request reviews before merging
- [x] Require 1 approvals
- [x] Dismiss stale pull request approvals when new commits are pushed
- [x] Require review from Code Owners
- [x] Require status checks to pass before merging
  - [x] CI - Continuous Integration
  - [x] Code Analysis
- [x] Require branches to be up to date before merging
- [x] Require conversation resolution before merging
```

**Code Owners** (CODEOWNERS file):
```
# Global owners
* @technical-lead

# Specific areas
/lib/tiles/ @tile-expert
/lib/features/auth/ @auth-expert
/docs/ @documentation-team
/.github/ @devops-team
```

### Review Automation

**GitHub Actions** (can be added):
```yaml
# Auto-assign reviewers
- uses: kentaro-m/auto-assign-action@v1
  
# Auto-label PRs
- uses: actions/labeler@v4

# Require conventional commits
- uses: amannn/action-semantic-pull-request@v5
```

### Code Review Tools

**Recommended Tools**:
- **GitHub Pull Requests**: Native interface
- **GitHub CLI**: `gh pr review` for command-line reviews
- **IDE Plugins**: GitLens (VS Code), Git Integration (Android Studio)

## Best Practices Summary

### For Developers

1. **Keep PRs small** and focused
2. **Self-review** before requesting review
3. **Write descriptive** titles and descriptions
4. **Respond promptly** to feedback
5. **Be open** to suggestions
6. **Test thoroughly** before submitting

### For Reviewers

1. **Review promptly** (within 24 hours)
2. **Be thorough** but don't nitpick
3. **Provide actionable** feedback
4. **Be respectful** and constructive
5. **Ask questions** to understand
6. **Acknowledge good** work

### For the Team

1. **Rotate reviewers** to spread knowledge
2. **Hold review** workshops periodically
3. **Discuss contentious** issues synchronously
4. **Update guidelines** based on learnings
5. **Celebrate quality** improvements
6. **Balance perfectionism** with pragmatism

## Continuous Improvement

### Monthly Review

**Team Discussion**:
- What's working well in reviews?
- What's causing friction?
- Are reviews too slow/fast?
- Is feedback quality improving?
- Do we need guideline updates?

### Retrospectives

After major releases:
- Review defects caught in code review vs. production
- Identify patterns in review comments
- Adjust guidelines as needed
- Share learnings across team

## References

- Google Engineering Practices: https://google.github.io/eng-practices/review/
- Code Review Best Practices: https://github.com/thoughtbot/guides/tree/main/code-review
- Flutter Style Guide: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
- Effective Dart: https://dart.dev/guides/language/effective-dart

## Appendix: Common Review Scenarios

### Scenario 1: Large PR (>1000 lines)

**Reviewer Action**:
```
This PR is quite large (1,245 lines). Could you split it into smaller, 
reviewable chunks? Suggested split:

1. PR 1: Data models and API client (300 lines)
2. PR 2: Business logic and state management (400 lines)
3. PR 3: UI components (400 lines)
4. PR 4: Tests and documentation (145 lines)

This will make review more thorough and faster.
```

### Scenario 2: Missing Tests

**Reviewer Action**:
```
❌ BLOCKING: No tests found for the new FeedingTile widget.

Please add:
1. Widget tests for rendering
2. Unit tests for data validation
3. Integration test for Supabase interaction

Refer to /test/tiles/diaper/diaper_tile_test.dart for examples.
```

### Scenario 3: Performance Concern

**Reviewer Action**:
```
💡 SUGGESTION: This could cause performance issues with large lists.

Current code rebuilds entire list on every state change. Consider:
- Using const constructors where possible
- Implementing shouldRebuild in ListView.builder
- Using Riverpod's select() to limit rebuilds

See: https://docs.flutter.dev/perf/best-practices
```

### Scenario 4: Architecture Violation

**Reviewer Action**:
```
❌ BLOCKING: This violates our Clean Architecture principles.

The widget is directly calling Supabase APIs. Per our architecture 
(docs/02_architecture_design/system_architecture_diagram.md):

Widgets → Providers → Services → Supabase

Please:
1. Move Supabase call to a service in core/services/
2. Create a provider to expose the data
3. Have widget consume provider

Happy to pair on this if helpful!
```

## Approval

**Status**: ✅ Active and Enforced

This code review process is:
- ✅ Documented and accessible
- ✅ Enforced through branch protection
- ✅ Integrated with CI/CD
- ✅ Supported by PR templates
- ✅ Aligned with industry best practices

**All code changes must go through code review before merging.**

---

**Document Maintained By**: Technical Lead Team  
**Review Frequency**: Quarterly or on process changes
