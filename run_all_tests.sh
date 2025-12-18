#!/bin/bash

echo "Running Unit Tests..."
flutter test test/unit_test.dart

echo "Running Widget Tests..."
flutter test test/widget_test.dart

echo "Running Integration Tests..."
flutter test integration_test/app_test.dart

echo "All tests completed."