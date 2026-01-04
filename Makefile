# Makefile for Local CI/CD

.PHONY: help doctor deps format analyze test build-android build-ios build-web ci all clean run test-integration coverage-report pre-commit lint-fix

# Default target
help:
	@echo "Available targets:"
	@echo "  doctor         - Verify Flutter installation"
	@echo "  deps           - Get and verify dependencies"
	@echo "  upgrade-safe   - Upgrade to latest compatible versions (safe)"
	@echo "  upgrade-deps   - Upgrade dependencies to latest major versions (CAUTION)"
	@echo "  format         - Format Dart code (fail if changes needed)"
	@echo "  analyze        - Analyze Flutter code (fatal warnings)"
	@echo "  lint-fix       - Auto-fix lints where possible"
	@echo "  test           - Run Flutter tests with coverage"
	@echo "  test-integration - Run integration tests"
	@echo "  pre-commit     - Run pre-commit hooks"
	@echo "  coverage-report - Generate HTML coverage report"
	@echo "  clean          - Clean build artifacts"
	@echo "  run            - Run the app in debug mode"
	@echo "  build-android  - Build Android APK"
	@echo "  build-ios      - Build iOS simulator"
	@echo "  build-web      - Build Web app"
	@echo "  ci             - Run full CI pipeline"
	@echo "  all            - Run full pipeline + all builds"

# Verify Flutter installation
doctor:
	flutter --version
	flutter doctor -v

# Get and verify dependencies
deps:
	flutter pub get
	flutter pub get --offline
	flutter pub outdated
upgrade-deps:
	@echo "⚠️  WARNING: Major version upgrades can introduce BREAKING CHANGES!"
	@echo "   Examples of what can break:"
	@echo "   - API changes in packages (method names, parameters)"
	@echo "   - Removed deprecated features"
	@echo "   - Changes in widget behavior"
	@echo "   - Incompatible Flutter SDK requirements"
	@echo ""
	@echo "   Recommended approach:"
	@echo "   1. Check package changelogs for breaking changes"
	@echo "   2. Update one package at a time: flutter pub upgrade <package>"
	@echo "   3. Test thoroughly after each upgrade"
	@echo "   4. Have git commits ready to rollback if needed"
	@echo ""
	@read -p "Are you sure you want to continue? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		flutter pub upgrade --major-versions; \
		echo "✅ Dependencies upgraded to latest major versions"; \
		echo "🔄 Please run 'make ci' to verify everything still works"; \
	else \
		echo "❌ Upgrade cancelled"; \
	fi

# Safer alternative: upgrade to latest compatible versions (patch/minor only)
upgrade-safe:
	@echo "🔄 Upgrading to latest compatible versions (patch/minor updates only)"
	flutter pub upgrade
	@echo "✅ Safe upgrade completed - no breaking changes expected"

# Format code
format:
	dart format .
analyze:
	flutter analyze --fatal-warnings

# Run tests with coverage
test:
	flutter test --coverage --reporter expanded

# Build Android APK
build-android:
	flutter build apk --release
	@echo "✅ Android APK built successfully"

# Build iOS (simulator)
build-ios:
	flutter build ios --simulator
	@echo "✅ iOS simulator build completed successfully"

# Build Web
build-web:
	flutter config --enable-web
	flutter build web --release
	@echo "✅ Web build completed successfully"

# Auto-fix lints
lint-fix:
	dart fix --apply
	@echo "✅ Auto-fixable lints applied"

# Run integration tests
test-integration:
	flutter test integration_test/
	@echo "✅ Integration tests completed"

# Run pre-commit checks
pre-commit:
	pre-commit run --all-files
	@echo "✅ Pre-commit checks passed"

# Generate coverage report
coverage-report:
	genhtml coverage/lcov.info -o coverage/html
	@echo "✅ Coverage report generated at coverage/html/index.html"
	open coverage/html/index.html

# Clean project
clean:
	flutter clean
	@echo "✅ Project cleaned"

# Run app
run:
	flutter run

# Full CI pipeline
ci: doctor deps format analyze test pre-commit

# Everything
all: ci build-android build-ios build-web