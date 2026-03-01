#!/bin/bash

# Convenience wrapper - runs the automated test suite from project root
# This script is located in the project root for easy access

cd "$(dirname "${BASH_SOURCE[0]}")"
./automated_tests/run_tests.sh "$@"
