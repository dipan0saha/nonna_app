# Real-Time Subscription Testing

## Overview

This directory contains comprehensive integration tests for Supabase real-time subscriptions across all realtime-enabled tables in the Nonna app.

## Test Coverage

### Tables Tested (15+)
1. **photos** - Gallery photo uploads and updates
2. **events** - Calendar events
3. **event_rsvps** - RSVP status changes
4. **event_comments** - Event comment threads
5. **photo_comments** - Photo comment threads
6. **photo_squishes** - Photo likes/reactions
7. **registry_items** - Registry item updates
8. **registry_purchases** - Purchase confirmations
9. **notifications** - In-app notifications
10. **owner_update_markers** - Cache invalidation markers
11. **baby_memberships** - Follower updates
12. **activity_events** - Activity stream events
13. **name_suggestions** - Name voting suggestions
14. **name_suggestion_likes** - Like counts
15. **votes** - Anonymous voting

## Test Categories

### 1. Subscription Lifecycle
- Channel creation and management
- Filter application (baby_profile_id, user_id)
- Multiple simultaneous subscriptions
- Duplicate channel handling
- Unsubscribe operations

### 2. Event Handling
- INSERT event detection
- UPDATE event detection
- DELETE event detection
- ALL events listening (default)

### 3. Performance Benchmarks
- Subscription latency (< 2 seconds requirement)
- Multi-table subscription efficiency
- Concurrent subscription handling
- Throughput testing

### 4. Reconnection Scenarios
- Connection stability
- Auto-reconnection logic
- Subscription persistence

### 5. Memory Management
- Memory leak detection
- Resource cleanup
- Repeated subscribe/unsubscribe cycles

## Running Tests

### Run All Realtime Tests
```bash
flutter test test/integration/realtime/
```

### Run Specific Test File
```bash
flutter test test/integration/realtime/photos_realtime_test.dart
```

### Run with Coverage
```bash
flutter test --coverage test/integration/realtime/
```

### Generate Test Report
```bash
flutter test --reporter json test/integration/realtime/ > test/integration/realtime/test_reports/test_results.json
```

## Performance Requirements

All tests are designed to verify:
- **Latency**: < 2 seconds for subscription setup
- **Throughput**: Handle batched updates efficiently
- **Stability**: Maintain connections without memory leaks
- **Scalability**: Support 15+ concurrent table subscriptions

## Test Reports

Test reports are automatically generated in `test_reports/` directory:
- `test_results.json` - Raw test results
- `performance_metrics.md` - Performance benchmarks
- `coverage_report.md` - Code coverage summary

## Dependencies

Tests use:
- `flutter_test` - Testing framework
- `supabase_flutter` - Supabase client
- Real-time service implementation

## Notes

- Tests are designed to work without requiring a live Supabase connection for basic subscription setup
- For full integration testing with actual data changes, ensure `.env` is configured with valid Supabase credentials
- Some tests use timeouts to prevent hanging on connection issues
- All tests include proper cleanup in `tearDown()` to prevent resource leaks

## Future Enhancements

- [ ] Add actual data mutation tests with test database
- [ ] Implement latency measurement tools
- [ ] Add stress testing scenarios
- [ ] Create automated performance regression detection
