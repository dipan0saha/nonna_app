# Test Runner Scripts

This directory contains automated scripts to run all test subcategories for the Nonna App and update the automated_tests/TEST_COMMANDS.md file with results.

## Files

- **`run_tests_and_update.py`** - Python script that runs all tests and updates the markdown file
- **`run_tests.sh`** - Shell script wrapper for convenience
- **`TEST_COMMANDS.md`** - Master document with all test commands and results (in automated_tests/)

## Quick Start

### Using the Shell Script (Recommended)

```bash
# Make script executable (first time only)
chmod +x run_tests.sh

# Run all tests and update MD file
./run_tests.sh

# Run without updating MD file
./run_tests.sh --no-update-md

# Run from a different project directory
./run_tests.sh --project-root /path/to/nonna_app
```

### Using Python Directly

```bash
# Run tests and update MD file
python3 run_tests_and_update.py

# Run without updating MD file
python3 run_tests_and_update.py --no-update-md

# Specify project root
python3 run_tests_and_update.py --project-root /path/to/nonna_app

# Show help
python3 run_tests_and_update.py --help
```

## Features

✅ **Automated Test Execution**
- Runs all 190 unit tests across 5 categories
- Parses test output to extract pass/fail counts
- Generates comprehensive error reports

📊 **Result Tracking**
- Updates automated_tests/TEST_COMMANDS.md with latest results
- Maintains historical data
- Calculates success rates and totals

📈 **Summary Reports**
- Displays test results in the console
- Shows pass/fail counts by category
- Identifies problem areas

🔧 **Flexible Options**
- Can be run with or without updating the MD file
- Supports custom project roots
- Timeout protection for long-running tests

## Test Categories

### Core Tests (108 files, 16 subcategories)
- Config, Constants, DI, Enums, Extensions
- Middleware, Mixins, Models, Navigation, Network
- Providers, Router, Services, Themes, Utils, Widgets

### Feature Tests (37 files, 9 features)
- Auth, Baby Profile, Calendar, Gallery
- Gamification, Home, Profile, Registry, Settings

### Tiles Tests (35 files, 16 tile types)
- Core, Checklist, Due Date Countdown, Engagement Recap
- Gallery Favorites, Invites Status, New Followers, Notifications
- Recent Photos, Recent Purchases, Registry Deals, Registry Highlights
- RSVP Tasks, Storage Usage, System Announcements, Upcoming Events

### Other Tests (2 tests)
- Accessibility (1 test)
- Localization/L10n (1 test)

## Output Example

```
🚀 Starting test run for all subcategories...

🧪 Running Core Tests...
  ✅ config: 51 passed, 0 failed
  ✅ constants: 66 passed, 0 failed
  ⚠️  services: 260 passed, 5 failed
  ...

🎯 Running Feature Tests...
  ⚠️  auth: 85 passed, 14 failed
  ...

📊 TEST SUMMARY
============================================================
Total Tests:    3677
✅ Passed:       3586
❌ Failed:       91
Success Rate:   97.5%
============================================================

⚠️  FAILURES BY CATEGORY:
  • core/services: 5 failed
  • core/utils: 1 failed
  • core/widgets: 5 failed
  • features/auth: 14 failed
  • features/calendar: 17 failed
  ...

✅ Updated automated_tests/TEST_COMMANDS.md
```

## Timeout

- Each test category has a 300-second (5 minute) timeout
- If a test exceeds this, it will be skipped with an error message
- You can modify this in the Python script if needed

## Requirements

- Python 3.6+
- Flutter and Dart SDK installed and in PATH
- Project must be in a Flutter project directory with pubspec.yaml

## Troubleshooting

### "pubspec.yaml not found"
Make sure you're running the script from the project root or use `--project-root` flag.

### "flutter test not found"
Ensure Flutter SDK is installed and in your PATH:
```bash
flutter --version
```

### Script hangs
Test execution may take a long time (30-60 minutes total). Be patient or check individual test categories:
```bash
flutter test test/core/config
```

### MD file not updating
Ensure automated_tests/TEST_COMMANDS.md exists and has the expected format. The script uses regex patterns to find and update sections.

## Integration with CI/CD

Add to your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Run Tests and Update Results
  run: |
    cd ${{ github.workspace }}/CodeSpace/Git_Repos/nonna_app
    python3 run_tests_and_update.py

- name: Commit Results
  run: |
    git config user.name "Test Bot"
    git config user.email "test@example.com"
    git add automated_tests/TEST_COMMANDS.md
    git commit -m "Update test results" || true
    git push
```

## Extending the Script

To add more test categories:

1. Edit `run_tests_and_update.py`
2. Add entries to `self.test_categories` dictionary
3. The script will automatically run tests for new categories

Example:
```python
self.test_categories = {
    "core": [...],
    "features": [...],
    "tiles": [...],
    "custom": ["test1", "test2"],  # Add custom category
    "other": [...]
}
```

## Performance Tips

- Run tests serially (current behavior) to avoid resource contention
- First run will take longer as dependencies are built
- Subsequent runs are faster as builds are cached
- Run individual categories if you need quick feedback:
  ```bash
  flutter test test/core/models --reporter=compact
  ```

## License

Same as the Nonna App project
