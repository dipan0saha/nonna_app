#!/bin/bash

# Nonna App Test Runner Wrapper
# Usage: ./run_tests.sh [--no-update-md] [--project-root PATH]

set -euo pipefail

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

# Default values
UPDATE_MD=true
CUSTOM_PROJECT_ROOT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-update-md)
            UPDATE_MD=false
            shift
            ;;
        --project-root)
            CUSTOM_PROJECT_ROOT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-update-md       Don't update automated_tests/TEST_COMMANDS.md after running tests"
            echo "  --project-root PATH  Path to project root (default: parent of this script)"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Override project root if specified
if [ -n "$CUSTOM_PROJECT_ROOT" ]; then
    PROJECT_ROOT="$CUSTOM_PROJECT_ROOT"
fi

# Verify project root exists
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "❌ Project root not found: $PROJECT_ROOT"
    exit 1
fi

# Verify pubspec.yaml exists
if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found in $PROJECT_ROOT"
    exit 1
fi

# Find Python script
PYTHON_SCRIPT="$SCRIPT_DIR/run_tests_and_update.py"
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "❌ Python script not found: $PYTHON_SCRIPT"
    exit 1
fi

# Prepare Python arguments
PYTHON_ARGS=("--project-root" "$PROJECT_ROOT")
if [ "$UPDATE_MD" = false ]; then
    PYTHON_ARGS+=("--no-update-md")
fi

# Run Python script
cd "$PROJECT_ROOT"
echo "📋 Running test suite from: $PROJECT_ROOT"
echo ""

python3 "$PYTHON_SCRIPT" "${PYTHON_ARGS[@]}"

exit $?
