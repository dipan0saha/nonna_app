#!/bin/bash

# Flutter-Supabase Project Creator and GitHub Pusher
# This script automates creating a new Flutter project with Supabase integration,
# applies the ideal project structure, runs basic commands, and pushes to GitHub.
#
# Prerequisites:
# - Flutter SDK installed and in PATH
# - Git installed
# - Dart SDK (comes with Flutter)
# - pre-commit installed (optional, for hooks)
# - Supabase project created at https://supabase.com (get URL and anon key)
#
# Usage: ./create_flutter_supabase_project.sh <project_name> <supabase_url> <supabase_anon_key> <github_username> <github_repo_name> [description] [--private] [--extra-deps]

set -e  # Exit on any error

# Default values
PRIVATE=false
EXTRA_DEPS=false

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    --private)
      PRIVATE=true
      shift
      ;;
    --extra-deps)
      EXTRA_DEPS=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Input parameters
PROJECT_NAME=$1
SUPABASE_URL=$2
SUPABASE_ANON_KEY=$3
GITHUB_USERNAME=$4
GITHUB_REPO_NAME=$5
DESCRIPTION=${6:-"A new Flutter app with Supabase integration"}

if [ -z "$PROJECT_NAME" ] || [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_REPO_NAME" ]; then
    echo "Usage: $0 <project_name> <supabase_url> <supabase_anon_key> <github_username> <github_repo_name> [description] [--private] [--extra-deps]"
    exit 1
fi

# Error handling
cleanup() {
  echo "Script failed. Cleaning up..."
  # Add cleanup logic if needed
}
trap cleanup ERR

echo "Creating Flutter project: $PROJECT_NAME"

# Step 1: Create Flutter project
flutter create $PROJECT_NAME
cd $PROJECT_NAME

# Step 2: Add Supabase dependencies to pubspec.yaml
echo "Adding Supabase dependencies..."
cat >> pubspec.yaml << EOF

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.8
  supabase: ^2.2.0
  riverpod: ^2.4.9
  intl: ^0.19.0
  go_router: ^13.2.0
  local_auth: ^2.2.0
  flutter_localizations:
    sdk: flutter
EOF

if [ "$EXTRA_DEPS" = true ]; then
  cat >> pubspec.yaml << EOF
  dio: ^5.4.0
EOF
fi

cat >> pubspec.yaml << EOF

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
EOF

# Run flutter pub get
flutter pub get

# Format code
echo "Formatting code..."
flutter format .

# Step 3: Setup Supabase project and config
echo "Setting up Supabase..."
echo "Please complete the following steps in your Supabase dashboard (https://supabase.com/dashboard):"
echo "1. Create a new project or use an existing one."
echo "2. Go to Settings > API to get your Project URL and anon public key."
echo "3. Enable desired services:"
echo "   - Authentication: Go to Authentication > Settings to configure providers (e.g., email, Google)."
echo "   - Database: Go to SQL Editor to create tables/schemas (e.g., users, posts)."
echo "   - Storage: Go to Storage to create buckets for file uploads."
echo "   - Edge Functions: Go to Edge Functions to deploy serverless functions (optional)."
echo "   - Realtime: Enabled by default for database changes."
echo "4. Configure any additional settings (e.g., Row Level Security in Database > Tables)."
echo ""
echo "Ensure your project URL and anon key match the inputs: $SUPABASE_URL and $SUPABASE_ANON_KEY"
echo "Press Enter once you've set up the services in the dashboard..."
read

echo "Setting up Supabase config..."
mkdir -p lib/core/config
cat > lib/core/config/supabase_config.dart << EOF
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = '$SUPABASE_URL';
  static const String supabaseAnonKey = '$SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
EOF

# Create basic main.dart
cat > lib/main.dart << EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: '$PROJECT_NAME',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
EOF

# Create basic app_router.dart
cat > lib/core/router/app_router.dart << EOF
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Welcome to $PROJECT_NAME')),
      ),
    ),
  ],
);
EOF

# Create basic localization
mkdir -p lib/l10n
cat > lib/l10n/app_en.arb << EOF
{
  "appTitle": "$PROJECT_NAME",
  "welcome": "Welcome"
}
EOF

# Create README.md
cat > README.md << EOF
# $PROJECT_NAME

A new Flutter app with Supabase integration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
EOF

# Step 4: Apply ideal project structure
echo "Applying project structure..."

# Create directories
mkdir -p packages docs/adr docs/architecture.md docs/testing.md docs/supabase_schema.md .github/workflows example config test/mocks test/fixtures test_driver supabase/migrations supabase/functions

mkdir -p lib/l10n

mkdir -p lib/core/models lib/core/repositories/interfaces lib/core/network/interceptors lib/core/network/endpoints lib/core/utils lib/core/extensions lib/core/mixins lib/core/enums lib/core/typedefs lib/core/contracts lib/core/di lib/core/themes lib/core/config lib/core/constants lib/core/services lib/core/middleware lib/core/exceptions lib/core/router lib/core/widgets

mkdir -p lib/tiles/core/models lib/tiles/core/widgets lib/tiles/core/providers lib/tiles/core/data/repositories lib/tiles/core/data/datasources/remote lib/tiles/core/data/datasources/local lib/tiles/core/test

# Tile directories
for tile in upcoming_events recent_photos registry_highlights notifications invites_status rsvp_tasks due_date_countdown recent_purchases registry_deals engagement_recap gallery_favorites checklist storage_usage system_announcements new_followers; do
  mkdir -p lib/tiles/$tile/models lib/tiles/$tile/providers lib/tiles/$tile/data/datasources/remote lib/tiles/$tile/data/datasources/local lib/tiles/$tile/data/mappers lib/tiles/$tile/widgets lib/tiles/$tile/test
done

# Feature directories
mkdir -p lib/features/auth/presentation/providers lib/features/auth/presentation/screens lib/features/auth/presentation/widgets lib/features/auth/data/models lib/features/auth/data/mappers lib/features/auth/data/repositories lib/features/auth/data/datasources/remote lib/features/auth/data/datasources/local lib/features/auth/domain/use_cases lib/features/auth/domain/entities lib/features/auth/test

mkdir -p lib/features/home/presentation/providers lib/features/home/presentation/screens lib/features/home/presentation/widgets lib/features/home/test

mkdir -p lib/features/calendar/presentation/providers lib/features/calendar/presentation/screens lib/features/calendar/presentation/widgets lib/features/calendar/test

mkdir -p lib/features/gallery/presentation/providers lib/features/gallery/presentation/screens lib/features/gallery/presentation/widgets lib/features/gallery/test

mkdir -p lib/features/registry/presentation/providers lib/features/registry/presentation/screens lib/features/registry/presentation/widgets lib/features/registry/data/models lib/features/registry/data/mappers lib/features/registry/data/repositories lib/features/registry/data/datasources/remote lib/features/registry/data/datasources/local lib/features/registry/domain/use_cases lib/features/registry/domain/entities lib/features/registry/test

mkdir -p lib/features/photo_gallery/presentation/providers lib/features/photo_gallery/presentation/screens lib/features/photo_gallery/presentation/widgets lib/features/photo_gallery/test

mkdir -p lib/features/fun/presentation/providers lib/features/fun/presentation/screens lib/features/fun/presentation/widgets lib/features/fun/test

mkdir -p lib/features/profile/presentation/providers lib/features/profile/presentation/screens lib/features/profile/presentation/widgets lib/features/profile/data/models lib/features/profile/data/mappers lib/features/profile/data/repositories lib/features/profile/data/datasources/remote lib/features/profile/data/datasources/local lib/features/profile/domain/use_cases lib/features/profile/domain/entities lib/features/profile/test

# Create Makefile
cat > Makefile << 'EOF'
.PHONY: help pub-get format analyze test build clean run

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

pub-get: ## Get dependencies
	flutter pub get

format: ## Format the code
	flutter format .

analyze: ## Run static analysis
	flutter analyze

test: ## Run all tests
	flutter test

build: test analyze format ## Build the app for Android and iOS
	flutter build apk --release
	flutter build ios --release --no-codesign

clean: ## Clean the project
	flutter clean

run: ## Run the app in debug mode
	flutter run
EOF

# Create basic files
touch .env.example
touch config/.env.example

# Setup environment file
cp .env.example .env
echo "SUPABASE_URL=$SUPABASE_URL" >> .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env

# Create basic files

# Step 5: Run Flutter commands
echo "Running Flutter analyze..."
flutter analyze

echo "Running unit and widget tests..."
flutter test

echo "Running integration tests..."
flutter test integration_test/

# Note: Flutter Drive tests require a connected device/emulator. Run manually: flutter drive --target=test_driver/app.dart
echo "Flutter Drive tests: Requires device/emulator. Run manually if needed."

# Step 6: Initialize Git and push to GitHub
echo "Initializing Git..."
git init

# Setup pre-commit hooks
if command -v pre-commit &> /dev/null; then
  cat > .pre-commit-config.yaml << EOF
repos:
- repo: local
  hooks:
  - id: flutter-analyze
    name: Flutter Analyze
    entry: flutter analyze
    language: system
    pass_filenames: false
  - id: flutter-format
    name: Flutter Format
    entry: flutter format --set-exit-if-changed .
    language: system
    pass_filenames: false
EOF
  pre-commit install
  echo "Running pre-commit hooks locally..."
  pre-commit run --all-files
else
  echo "pre-commit not installed. Skipping hooks setup."
fi

git add .
git commit -m "Initial commit: Flutter-Supabase project with ideal structure"

echo "Creating GitHub repository..."
if [ "$PRIVATE" = true ]; then
  gh repo create $GITHUB_REPO_NAME --description "$DESCRIPTION" --private --source . --remote origin --push
else
  gh repo create $GITHUB_REPO_NAME --description "$DESCRIPTION" --public --source . --remote origin --push
fi

echo "Project created and pushed to GitHub successfully!"
echo "GitHub URL: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME"