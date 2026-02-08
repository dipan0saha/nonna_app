#!/bin/bash

# Verification script for flutter analyze fixes
# Run this after the PR is merged or in a CI environment with Flutter

echo "========================================="
echo "Flutter Analyze Verification Script"
echo "========================================="
echo ""

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    echo "Please install Flutter or run this script in a Flutter environment"
    exit 1
fi

echo "✅ Flutter found"
flutter --version
echo ""

# Run flutter pub get
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Run flutter analyze
echo "🔍 Running flutter analyze..."
flutter analyze --fatal-warnings > /tmp/analyze_result.txt 2>&1
ANALYZE_EXIT_CODE=$?

if [ $ANALYZE_EXIT_CODE -eq 0 ]; then
    echo "✅ Flutter analyze passed with no errors or warnings!"
    echo ""
    cat /tmp/analyze_result.txt
    exit 0
else
    echo "❌ Flutter analyze found issues:"
    echo ""
    cat /tmp/analyze_result.txt
    echo ""
    echo "Please review the errors above"
    exit 1
fi
