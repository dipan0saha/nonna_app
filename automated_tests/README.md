# Automated Tests Suite

This folder contains all scripts and documentation for automated test execution and result tracking.

## 📁 Files

- **run_tests_and_update.py** - Main Python script to run all tests and update TEST_COMMANDS.md
- **TEST_COMMANDS.md** - Overview document with test organization and current results
- **quick_test.py** - Quick test runner for specific categories
- **run_tests.sh** - Shell script wrapper for the Python test runner
- **TEST_RUNNER_README.md** - Comprehensive documentation
- **QUICK_START.md** - Quick reference guide
- **SETUP_COMPLETE.md** - Setup summary and info

## 🚀 Quick Start

### From Project Root
```bash
# Using the convenience wrapper
./run_tests.sh

# Using make
make test-all
make test-quick CATEGORY=core

# Using Python directly
python3 automated_tests/run_tests_and_update.py
python3 automated_tests/quick_test.py core
```

### From This Directory
```bash
# Run the automation script
./run_tests.sh

# Quick test
python3 quick_test.py core
```

## 📊 Test Organization

- **Core**: 16 subcategories (config, constants, di, enums, extensions, middleware, mixins, models, navigation, network, providers, router, services, themes, utils, widgets)
- **Features**: 9 features (auth, baby_profile, calendar, gallery, gamification, home, profile, registry, settings)
- **Tiles**: 16 tile types (core, checklist, due_date_countdown, engagement_recap, gallery_favorites, invites_status, new_followers, notifications, recent_photos, recent_purchases, registry_deals, registry_highlights, rsvp_tasks, storage_usage, system_announcements, upcoming_events)
- **Other**: 2 tests (accessibility, l10n)

## 📖 Documentation

See the individual README files for detailed information:
- **QUICK_START.md** - Commands and examples
- **TEST_RUNNER_README.md** - Detailed technical documentation
- **SETUP_COMPLETE.md** - Complete setup overview

## 🔧 Options

```automated_tests/
--no-update-md       Don't update TEST_COMMANDS.md
--project-root PATH  Custom project root path
--help              Show help message
```

## ⏱️ Expected Runtime

- Full suite: 20-60 minutes
- By category: 1-5 minutes
- Individual test: <30 seconds
