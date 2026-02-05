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
git status && git add . && git commit --no-verify -m "Misc changes" && git push
```
