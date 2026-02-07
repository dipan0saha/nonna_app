# Feature Providers Testing & Usage Guide

This guide provides instructions for testing and using the 8 Feature Providers that were implemented for Section 3.5.3.

---

## Quick Start

### Prerequisites

Ensure you have Flutter SDK installed:
```bash
flutter --version
# Should show Flutter 3.x.x or later
```

### Step 1: Generate Mock Files

The test files use Mockito for mocking dependencies. Generate the mock files:

```bash
cd /home/runner/work/nonna_app/nonna_app
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create `.mocks.dart` files alongside the test files.

### Step 2: Run All Tests

Run all Feature Provider tests:

```bash
flutter test test/features/
```

### Step 3: Run Individual Test Files

To run tests for a specific provider:

```bash
# Auth State tests
flutter test test/features/auth/presentation/providers/auth_state_test.dart

# Auth Provider tests
flutter test test/features/auth/presentation/providers/auth_provider_test.dart

# Home Screen Provider tests
flutter test test/features/home/presentation/providers/home_screen_provider_test.dart

# Calendar Screen Provider tests
flutter test test/features/calendar/presentation/providers/calendar_screen_provider_test.dart

# Gallery Screen Provider tests
flutter test test/features/gallery/presentation/providers/gallery_screen_provider_test.dart

# Registry Screen Provider tests
flutter test test/features/registry/presentation/providers/registry_screen_provider_test.dart

# Profile Provider tests
flutter test test/features/profile/presentation/providers/profile_provider_test.dart

# Baby Profile Provider tests
flutter test test/features/baby_profile/presentation/providers/baby_profile_provider_test.dart
```

### Step 4: Generate Coverage Report

Generate a code coverage report:

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open the report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

---

## Usage Examples

### 1. Auth Provider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Show loading indicator
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Navigate to home if authenticated
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show error message if any
            if (authState.hasError)
              Text(
                authState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            
            // Email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            
            // Password field
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            
            const SizedBox(height: 20),
            
            // Sign in button
            ElevatedButton(
              onPressed: () async {
                await authNotifier.signInWithEmail(
                  email: emailController.text,
                  password: passwordController.text,
                );
              },
              child: const Text('Sign In'),
            ),
            
            // Google sign in button
            ElevatedButton(
              onPressed: () async {
                await authNotifier.signInWithGoogle();
              },
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Home Screen Provider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/core/enums/user_role.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String babyProfileId;

  const HomeScreen({required this.babyProfileId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tiles on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeScreenProvider.notifier).loadTiles(
            babyProfileId: widget.babyProfileId,
            role: UserRole.owner,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeScreenProvider);
    final homeNotifier = ref.read(homeScreenProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => homeNotifier.refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => homeNotifier.onPullToRefresh(),
        child: homeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : homeState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${homeState.error}'),
                        ElevatedButton(
                          onPressed: () => homeNotifier.retry(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: homeState.tiles.length,
                    itemBuilder: (context, index) {
                      final tile = homeState.tiles[index];
                      return ListTile(
                        title: Text(tile.title),
                        subtitle: Text(tile.tileType),
                      );
                    },
                  ),
      ),
    );
  }
}
```

### 3. Calendar Screen Provider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/features/calendar/presentation/providers/calendar_screen_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final String babyProfileId;

  const CalendarScreen({required this.babyProfileId});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Load events on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarScreenProvider.notifier).loadEvents(
            babyProfileId: widget.babyProfileId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarScreenProvider);
    final calendarNotifier = ref.read(calendarScreenProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => calendarNotifier.previousMonth(),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => calendarNotifier.nextMonth(),
          ),
        ],
      ),
      body: calendarState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar widget would go here
                // For now, show selected date
                Text('Selected: ${calendarState.selectedDate}'),
                
                // Events for selected date
                Expanded(
                  child: ListView.builder(
                    itemCount: calendarState.eventsForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final event = calendarState.eventsForSelectedDate[index];
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Text(event.location ?? ''),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
```

### 4. Profile Provider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/features/profile/presentation/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    // Update text field when profile loads
    if (profileState.profile != null && !profileState.isEditMode) {
      nameController.text = profileState.profile!.displayName;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!profileState.isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => profileNotifier.enterEditMode(),
            ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.profile == null
              ? const Center(child: Text('Profile not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileState.profile!.avatarUrl != null
                            ? NetworkImage(profileState.profile!.avatarUrl!)
                            : null,
                        child: profileState.profile!.avatarUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Display name
                      if (profileState.isEditMode)
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                          ),
                        )
                      else
                        Text(
                          profileState.profile!.displayName,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Save/Cancel buttons in edit mode
                      if (profileState.isEditMode) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: profileState.isSaving
                                  ? null
                                  : () async {
                                      await profileNotifier.updateProfile(
                                        userId: widget.userId,
                                        displayName: nameController.text,
                                      );
                                    },
                              child: profileState.isSaving
                                  ? const CircularProgressIndicator()
                                  : const Text('Save'),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () => profileNotifier.cancelEdit(),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                        
                        // Error message
                        if (profileState.saveError != null)
                          Text(
                            profileState.saveError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                      
                      // User stats
                      if (profileState.stats != null) ...[
                        const SizedBox(height: 20),
                        Text('Photos: ${profileState.stats!.photosUploaded}'),
                        Text('Events: ${profileState.stats!.eventsCreated}'),
                      ],
                    ],
                  ),
                ),
    );
  }
}
```

---

## Common Patterns

### 1. Loading State

All providers follow this pattern for loading:
```dart
// Check loading state
if (state.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### 2. Error Handling

All providers expose error state:
```dart
// Check for errors
if (state.error != null) {
  return Center(
    child: Column(
      children: [
        Text('Error: ${state.error}'),
        ElevatedButton(
          onPressed: () => notifier.retry(),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### 3. Pull-to-Refresh

Providers with refresh support:
```dart
RefreshIndicator(
  onRefresh: () => notifier.refresh(),
  child: YourWidget(),
)
```

### 4. Pagination (Gallery Provider)

```dart
ListView.builder(
  itemCount: state.photos.length + 1, // +1 for loading indicator
  itemBuilder: (context, index) {
    if (index == state.photos.length) {
      // Load more when reaching end
      if (state.hasMore && !state.isLoadingMore) {
        notifier.loadMore();
      }
      return state.isLoadingMore
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox.shrink();
    }
    return PhotoTile(photo: state.photos[index]);
  },
)
```

---

## Troubleshooting

### Issue: Mock files not found

**Solution:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Tests failing due to missing dependencies

**Solution:**
```bash
flutter pub get
```

### Issue: "Bad state: No element" in tests

**Cause:** Mock not properly configured for a query that expects a result

**Solution:** Check test setup and ensure mocks return expected data:
```dart
when(mockDatabaseService.select(any)).thenReturn(
  FakePostgrestBuilder([expectedData.toJson()]),
);
```

### Issue: Real-time subscription tests timing out

**Cause:** Async operations not properly awaited

**Solution:** Use `pumpAndSettle()` in widget tests or proper async/await in unit tests

---

## Performance Tips

1. **Use autoDispose providers** where possible to free memory
2. **Cache aggressively** but with appropriate TTLs
3. **Batch database queries** when loading related data
4. **Use pagination** for large datasets (Gallery, Calendar)
5. **Debounce user inputs** in search/filter operations
6. **Unsubscribe from real-time** when not needed

---

## Security Checklist

When using these providers in production:

- [ ] Validate all user inputs
- [ ] Check authentication before sensitive operations
- [ ] Verify user permissions (especially in Baby Profile Provider)
- [ ] Sanitize data before database operations
- [ ] Use HTTPS for all API calls
- [ ] Rotate API keys regularly
- [ ] Implement rate limiting
- [ ] Log security events

---

## Support

For issues or questions:
1. Check the implementation summary: `FEATURE_PROVIDERS_IMPLEMENTATION_SUMMARY.md`
2. Review the code documentation in provider files
3. Check the test files for usage examples
4. Refer to the Core Development Component Identification document

---

**Last Updated:** February 7, 2026  
**Version:** 1.0  
**Tested With:** Flutter 3.x, Dart 3.x
