# Git Commands Reference

## Pushing Changes Without Pre-commit Hooks

To push changes from local to main without running the pre-commit hook checks, use these commands:

```bash
git status
git add .
git commit --no-verify -m "Fix Flutter test failures: error handler, validation mixin, role-aware mixin, and tile model hashCode issues"
git push
```

### Explanation:
- `git status`: Check the current state of your working directory and staging area
- `git add .`: Stage all modified and new files
- `git commit --no-verify`: Create a commit while skipping pre-commit hook checks
- `git push`: Push the committed changes to the remote repository

**Note:** Use `--no-verify` sparingly and only when you understand the implications of skipping pre-commit checks.

## Run all commands in one single line
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze > flutter_analyze_results.txt
flutter test --reporter expanded > flutter_test_results.txt
git status && git add . && git commit --no-verify -m "Misc changes" && git push
```

```bash

```

# Running Unit Tests
To run Flutter unit tests by groups in the nonna_app project, you can organize them by directories (based on the test structure) or use tags if tests are annotated. Here are suggestions:

## By Directory Groups
Run tests in specific subdirectories under `test/`:

- **Core tests:** `flutter test test/core/`
- **Tiles tests:** `flutter test test/tiles/`
- **Accessibility tests:** `flutter test test/accessibility/`
- **L10n tests:** `flutter test test/l10n/`
- **Integration tests** (separate from unit tests): `flutter test integration_test/`
- **Single file** (e.g., project initialization): `flutter test test/project_initialization_test.dart`

## By Tags (if available)

If tests use `@Tags` annotations (e.g., `@Tags(['unit', 'core'])`), run groups like:

- `flutter test --tags unit`
- `flutter test --tags core`

## Additional Options

- **Run with coverage:** Add `--coverage` to any command.
- **Run in verbose mode:** Add `--verbose`.
- **Run in parallel** (faster): Add `--concurrency=4` (adjust number as needed).

## To sub-divide even more:
- flutter test test/core/config/
- flutter test test/core/constants/ 10
- flutter test test/core/enums/ 3
- flutter test test/core/extensions/ 5
- flutter test test/core/middleware/
- flutter test test/core/mixins/
- flutter test test/core/models/ 8
- flutter test test/core/network/ 4
- flutter test test/core/services/ 11
- flutter test test/core/themes/
- flutter test test/core/utils/ 12
- flutter test test/core/widgets/
