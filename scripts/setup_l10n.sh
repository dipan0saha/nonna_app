#!/bin/bash

# Localization Setup Script
# This script generates the localization files for the Nonna app

set -e

echo "🌍 Nonna App - Localization Setup"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo "📦 Checking Flutter version..."
flutter --version

# Get dependencies
echo ""
echo "📥 Getting dependencies..."
flutter pub get

# Generate localizations
echo ""
echo "🔨 Generating localization files..."
flutter gen-l10n

# Check if generation was successful
if [ -d ".dart_tool/flutter_gen/gen_l10n" ]; then
    echo ""
    echo "✅ Localization files generated successfully!"
    echo ""
    echo "Generated files location:"
    echo "  .dart_tool/flutter_gen/gen_l10n/"
    echo ""
    echo "You can now use AppLocalizations in your app:"
    echo "  import 'package:flutter_gen/gen_l10n/app_localizations.dart';"
    echo ""
    echo "Usage example:"
    echo "  final l10n = AppLocalizations.of(context);"
    echo "  Text(l10n.welcome);"
else
    echo ""
    echo "❌ Error: Localization files were not generated"
    echo "Please check the l10n.yaml configuration and ARB files"
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
