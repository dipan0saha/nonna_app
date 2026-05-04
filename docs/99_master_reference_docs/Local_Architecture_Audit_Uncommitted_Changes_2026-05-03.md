# Local Architecture Audit - Uncommitted Changes (2026-05-03)

## Scope
This audit evaluates current uncommitted local changes related to three bug-fix areas:
1. Gallery Favorites and Recent Photos View All navigation
2. Photo caption editing
3. Photo comments (create, edit-by-author, delete-by-author-or-owner, comment count)

Reviewed code includes UI, provider, routing, model, and Supabase migration/RLS updates.

## Executive Assessment
The changes are functionally close to target behavior, but architectural quality is mixed.

1. View All routing fix is mostly correct and aligns with existing tile-based navigation.
2. Caption and comment features work conceptually, but the implementation places too much business logic inside the screen layer.
3. There are state-consistency risks that can produce incorrect comment counts in UI when provider operations fail.
4. Permission security is mostly enforced correctly at database level through RLS, which is a strong point.

Overall verdict: Partially aligned with architecture standards. Refactor is recommended before commit.

## Severity-Ranked Findings

### High
1. Comment count can become incorrect after failed write operations.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L584)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L588)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L621)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L629)
- [lib/features/gallery/presentation/providers/photo_comments_provider.dart](lib/features/gallery/presentation/providers/photo_comments_provider.dart#L140)
- [lib/features/gallery/presentation/providers/photo_comments_provider.dart](lib/features/gallery/presentation/providers/photo_comments_provider.dart#L201)
Why this matters:
- UI increments/decrements local comment count regardless of whether provider operations truly succeeded.
- Provider methods swallow errors instead of surfacing success/failure contract to UI.
Impact:
- Users may see wrong counts, causing trust and consistency issues.

2. New model field commentCount is missing from equality and hashCode.
Evidence:
- [lib/core/models/photo.dart](lib/core/models/photo.dart#L158)
- [lib/core/models/photo.dart](lib/core/models/photo.dart#L173)
Why this matters:
- State comparison can treat changed commentCount as unchanged.
- Reactive updates and cache/list diff behavior can become inconsistent.

### Medium
1. Layer boundary violation: substantial data-access and orchestration logic moved into view layer.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L74)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L188)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L564)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L599)
Why this matters:
- Screen directly performs database writes, permission-sensitive operations, and cross-provider refresh orchestration.
- This weakens separation of concerns and makes testing harder.

2. N+1 query pattern in comments provider (performance and scalability risk).
Evidence:
- [lib/features/gallery/presentation/providers/photo_comments_provider.dart](lib/features/gallery/presentation/providers/photo_comments_provider.dart#L76)
- [lib/features/gallery/presentation/providers/photo_comments_provider.dart](lib/features/gallery/presentation/providers/photo_comments_provider.dart#L79)
Why this matters:
- One query fetches comments, then one query per comment fetches author profile.
- Cost increases linearly with comment count.

3. Owner detection in UI relies on homeScreenProvider selectedRole context.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L297)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L434)
Why this matters:
- Role can be null/stale outside home-driven flows.
- UI affordances may not match real permissions in some navigation paths.

4. Comment count trigger can underflow in edge cases and has no backfill strategy noted.
Evidence:
- [supabase/migrations/03_functions_and_triggers.sql](supabase/migrations/03_functions_and_triggers.sql#L198)
- [supabase/migrations/03_functions_and_triggers.sql](supabase/migrations/03_functions_and_triggers.sql#L208)
- [supabase/migrations/03_functions_and_triggers.sql](supabase/migrations/03_functions_and_triggers.sql#L228)
Why this matters:
- Decrement logic does not clamp to non-negative.
- Existing historical comments may require backfill for accurate initial comment_count.

### Low
1. Route literals in tile factory instead of central route constants.
Evidence:
- [lib/core/utils/tile_factory.dart](lib/core/utils/tile_factory.dart#L183)
- [lib/core/utils/tile_factory.dart](lib/core/utils/tile_factory.dart#L192)
- [lib/core/utils/tile_factory.dart](lib/core/utils/tile_factory.dart#L491)
- [lib/core/utils/tile_factory.dart](lib/core/utils/tile_factory.dart#L500)
Why this matters:
- Slight DRY and maintainability regression.

2. New UI strings are hardcoded and bypass localization pipeline.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L253)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L294)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L450)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L606)
Why this matters:
- App already uses localization; these strings are not translation-ready.

3. Static analysis warnings present in changed code.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L19)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L220)
Warnings:
- Unused import photo_comment
- Unused local variable role

## Evaluation Against Requested Audit Dimensions

### Architectural Integrity
Assessment: Needs improvement.

Positives:
- Comments state extracted into a dedicated provider.
- Gallery screen state evolution for multiple gallery variants is cleaner and more scalable.
Evidence:
- [lib/features/gallery/presentation/providers/gallery_screen_provider.dart](lib/features/gallery/presentation/providers/gallery_screen_provider.dart#L12)

Concerns:
- Photo detail screen now contains significant data and workflow orchestration logic that belongs in provider/controller layer.

### State Management
Assessment: Mixed.

Positives:
- Comments provider introduces reactive state map keyed by photoId.
- Gallery provider refactor improves per-screen state isolation.

Concerns:
- UI-local comment counter is manually mutated and can diverge from provider/database truth.
- Provider methods do not provide reliable success/failure signaling back to UI.

### Code Quality
Assessment: Fair, with actionable issues.

Positives:
- Functional flow for View All, caption edit, and comments is mostly complete.
- Route additions for favorites/recent are correctly integrated.
Evidence:
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart#L210)
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart#L217)

Concerns:
- Hardcoded strings and route literals.
- N+1 author lookup in comments.
- Static analysis warnings.

### Permissions
Assessment: Good at DB enforcement, acceptable in UI controls.

Strong points:
- Photo update policy remains owner-only.
Evidence:
- [supabase/migrations/04_rls_policies.sql](supabase/migrations/04_rls_policies.sql#L242)

- Comment update/delete now allow author or owner.
Evidence:
- [supabase/migrations/04_rls_policies.sql](supabase/migrations/04_rls_policies.sql#L990)
- [supabase/migrations/04_rls_policies.sql](supabase/migrations/04_rls_policies.sql#L997)

UI-level behavior:
- Edit appears only for author.
- Delete appears for author or owner.
Evidence:
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L486)
- [lib/features/gallery/presentation/screens/photo_detail_screen.dart](lib/features/gallery/presentation/screens/photo_detail_screen.dart#L499)

Residual risk:
- UI owner check based on home screen role context may not always represent actual membership role for current photo context.

## Bug-Fix Coverage Validation
1. Gallery Favorites View All not working
- Status: Addressed.
- Route and tile updates are present and wired.
Evidence:
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart#L210)
- [lib/core/utils/tile_factory.dart](lib/core/utils/tile_factory.dart#L497)

2. Caption cannot be edited
- Status: Addressed functionally for owner-gated UI and DB update path.
- Architectural note: logic should be moved to provider/controller.

3. Comments missing
- Status: Addressed functionally (add/edit/delete + count icon).
- Architectural note: state consistency and provider contracts need hardening.

## Recommended Refactor Before Commit
1. Move caption and comment command logic from screen into dedicated feature providers/controllers.
2. Make provider methods return explicit result types (success/failure) and stop silent error swallowing.
3. Remove local manual comment count mutation and derive count from provider state or refetched photo state.
4. Include commentCount in Photo equality and hashCode.
5. Replace N+1 author fetching with joined/select strategy or batched profile fetch.
6. Replace route and UI string literals with route constants and localization resources.
7. Add migration note/script for backfilling photos.comment_count and guard decrements with non-negative clamp.

## Additional Notes
This working tree also contains documentation and other unrelated local edits. The above findings focus on the three requested bug-fix areas and their direct architectural impact.