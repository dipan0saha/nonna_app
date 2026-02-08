#!/bin/bash

# Mock Generation Script for Centralized Mocking Strategy
#
# This script helps generate the centralized mock files using build_runner.
# Run this after making changes to test/mocks/mock_services.dart

set -e  # Exit on error

echo "======================================"
echo "Centralized Mock Generation"
echo "======================================"
echo

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: flutter command not found"
    echo "Please ensure Flutter SDK is installed and in your PATH"
    exit 1
fi

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo
echo "🧹 Cleaning previous build artifacts..."
flutter pub run build_runner clean

echo
echo "🔨 Generating mocks from test/mocks/mock_services.dart..."
flutter pub run build_runner build --delete-conflicting-outputs

echo
echo "✅ Mock generation complete!"
echo
echo "Generated file: test/mocks/mock_services.mocks.dart"
echo
echo "Next steps:"
echo "1. Verify the generated mock file looks correct"
echo "2. Start refactoring tests to use the centralized mocks"
echo "3. See test/README.md for migration guide"
echo

# Check if the mock file was generated
if [ -f "test/mocks/mock_services.mocks.dart" ]; then
    echo "✓ Mock file successfully generated"
    line_count=$(wc -l < test/mocks/mock_services.mocks.dart)
    echo "  File size: $line_count lines"
else
    echo "⚠️  Warning: Expected mock file not found"
    echo "  Check build_runner output for errors"
fi

echo
echo "======================================"
