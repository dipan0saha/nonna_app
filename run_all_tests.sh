#!/bin/bash

echo "Running Unit Tests..."
flutter test test/unit_test.dart

echo "Running Utility Unit Tests..."
flutter test test/utils/date_utils_test.dart
flutter test test/utils/image_utils_test.dart
flutter test test/utils/api_utils_test.dart

echo "Running Widget Tests..."
flutter test test/widget_test.dart

echo "Running Integration Tests..."
flutter test integration_test/app_test.dart
flutter test integration_test/utils_integration_test.dart

echo "All tests completed."