# GitHub Copilot Instructions for nonna_app

This is a Flutter-based application repository focused on building a mobile-first, tile-based family social platform designed to bridge the distance between new parents and their loved ones. The app integrates with Supabase for backend services and follows a structured production readiness checklist for development. Please follow these guidelines when contributing:

## Code Standards

### Required Before Each Commit
- Run `flutter analyze` to check for any linting issues and ensure code quality
- Run `dart format .` to format all Dart files consistently
- Execute `make test` or `./run_all_tests.sh` to run the full test suite

### Development Flow
- Build: `flutter build apk`
- Test: `flutter test` (unit tests) and `flutter drive` (integration tests)
- Full CI check: `make ci` or `./run_all_tests.sh` (includes analyze, format, test)
- Analyze: `flutter analyze` for static analysis

## Repository Structure
- `lib/`: Main Flutter application code
  - `models/`: Data models and entities (Section 3.1 from production checklist)
  - `services/`: API and business logic services (Section 3.2)
  - `utils/`: Helper utilities and extensions (Section 3.3)
  - `widgets/`: Reusable UI components (Section 3.4)
  - `screens/`: Application screens and pages (Section 3.5)
  - `providers/`: State management using Riverpod or similar (Section 3.6)
- `test/`: Unit tests for individual components
- `integration_test/`: End-to-end integration tests
- `android/`: Android-specific configuration and code
- `ios/`: iOS-specific configuration and code
- `web/`: Web platform support
- `supabase/`: Supabase configuration and migrations
- `docs/`: Documentation and guides
- `scripts/`: Utility scripts for development and deployment
- `config/`: Configuration files and environment setups
- `packages/`: Local packages and modules

## Key Guidelines
1. Follow Flutter and Dart best practices, including the guidelines in `analysis_options.yaml`
2. Maintain the existing code structure aligned with the production readiness checklist
3. Use Riverpod for state management and dependency injection where appropriate
4. Write comprehensive unit tests for new functionality, aiming for high test coverage
5. Use Supabase best practices for database operations and real-time features
