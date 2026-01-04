# State Management Design Document

## Document Information

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Author**: Architecture Team  
**Status**: Final  
**Section**: 1.3 - Architecture Design

## Executive Summary

This document defines the state management strategy for the Nonna App, detailing how application state is managed, shared, and synchronized across the tile-based, multi-role family social platform. The design uses **Riverpod** as the primary state management solution, chosen for its compile-time safety, dependency injection capabilities, and seamless integration with asynchronous operations and real-time data streams.

The state management architecture is designed to support:
- Dynamic tile-based UI with role-driven content aggregation
- Real-time updates from Supabase with efficient cache invalidation
- Multi-level caching strategy (memory, local storage, CDN)
- Complex authentication and authorization flows
- Offline-first capabilities with sync on reconnection

## References

This document is informed by and aligns with:

- `docs/00_requirement_gathering/user_journey_maps.md` - State flows based on user interactions
- `docs/01_technical_requirements/functional_requirements_specification.md` - Feature-specific state requirements
- `docs/01_technical_requirements/non_functional_requirements_specification.md` - Performance targets
- `docs/02_architecture_design/system_architecture_diagram.md` - Overall architecture
- `discovery/01_discovery/02_technology_stack/Technology_Stack.md` - Riverpod selection rationale
- `discovery/01_discovery/04_technical_requirements/Tile_System_Design.md` - Tile state management needs

---

## 1. State Management Technology Selection

### 1.1 Why Riverpod?

**Decision Rationale** (from ADR-003):

Riverpod was selected over alternatives (Provider, BLoC, Redux) for the following reasons:

**Advantages Over Provider**:
- **Compile-Time Safety**: Catches errors at compile-time rather than runtime
- **No BuildContext Required**: Access providers anywhere without widget tree context
- **Better Testability**: Providers can be easily overridden in tests
- **Automatic Disposal**: Provider lifecycle managed automatically
- **Family Modifiers**: Parameterized providers for dynamic queries

**Advantages Over BLoC**:
- **Less Boilerplate**: Simpler syntax with less code for equivalent functionality
- **Built-in Async Support**: `FutureProvider` and `StreamProvider` handle async seamlessly
- **Easier Learning Curve**: More intuitive for developers familiar with Provider
- **Better Performance**: More granular rebuilds with `select` and `watch`

**Advantages Over Redux**:
- **No Global Store**: Scoped providers prevent unintended state coupling
- **More Flexible**: Supports multiple state patterns (StateNotifier, AsyncNotifier, ChangeNotifier)
- **Less Ceremony**: No actions, reducers, or middleware boilerplate

**Integration with Nonna Architecture**:
- Seamlessly integrates with Supabase Realtime streams
- Supports tile-based architecture with parameterized providers
- Enables role-based state scoping (owner vs follower)
- Facilitates multi-level caching with cache providers

### 1.2 Riverpod Version & Packages

**Core Package**:
```yaml
dependencies:
  flutter_riverpod: ^2.4.0  # Main Riverpod package
  riverpod_annotation: ^2.3.0  # Code generation annotations
  
dev_dependencies:
  riverpod_generator: ^2.3.0  # Code generation
  build_runner: ^2.4.0  # Build tool
```

**Benefits of Code Generation**:
- Reduced boilerplate with `@riverpod` annotation
- Type-safe provider access
- Automatic provider family generation
- Cleaner syntax for complex providers

---

## 2. State Architecture Overview

### 2.1 State Layer Hierarchy

```
┌─────────────────────────────────────────────────────────────────────┐
│                         APPLICATION STATE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                    GLOBAL STATE                             │   │
│  │  • Authentication State                                     │   │
│  │  • User Profile                                             │   │
│  │  • App Configuration                                        │   │
│  │  • Theme & Localization                                     │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                   FEATURE STATE                             │   │
│  │  • Baby Profiles State                                      │   │
│  │  • Role Selection State                                     │   │
│  │  • Navigation State                                         │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                    TILE STATE                               │   │
│  │  • Tile Configuration State                                 │   │
│  │  • Tile Data State (per tile type)                         │   │
│  │  • Tile Visibility State                                    │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                   SCREEN STATE                              │   │
│  │  • Screen-Specific UI State                                 │   │
│  │  • Form State                                               │   │
│  │  • Filter & Sort State                                      │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                   CACHE STATE                               │   │
│  │  • Memory Cache (Riverpod keepAlive)                       │   │
│  │  • Local Storage Cache (Hive/Isar)                         │   │
│  │  • Cache Invalidation Markers                              │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │                  REALTIME STATE                             │   │
│  │  • Subscription State                                       │   │
│  │  • Connection Status                                        │   │
│  │  • Update Queue                                             │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Provider Categories

**1. Global Providers** (Singleton, App-Level)
- Authentication provider
- Supabase client provider
- Cache service provider
- Theme provider
- Navigation provider

**2. Feature Providers** (Feature-Scoped)
- Baby profile provider
- Calendar event provider
- Photo gallery provider
- Registry provider
- Notification provider

**3. Tile Providers** (Parameterized by role and baby IDs)
- Upcoming events provider
- Recent photos provider
- Registry highlights provider
- Notifications provider
- Activity recap provider

**4. Screen Providers** (Screen-Scoped)
- Home screen provider
- Calendar screen provider
- Gallery screen provider
- Profile screen provider

**5. Cache Providers** (Data Persistence)
- Tile data cache provider
- User profile cache provider
- Photo cache provider

---

## 3. Provider Patterns & Implementations

### 3.1 Authentication State

**Purpose**: Manage user authentication, session, and profile state globally.

**Provider Type**: `StateNotifierProvider<AuthNotifier, AuthState>`

**Implementation**:

```dart
// auth_state.dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated({
    required User user,
    required Profile profile,
    required Session session,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.error(String message) = _Error;
}

// auth_notifier.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState.initial();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    
    try {
      final session = await ref.read(supabaseClientProvider).auth.currentSession;
      
      if (session != null) {
        final profile = await _fetchProfile(session.user.id);
        state = AuthState.authenticated(
          user: session.user,
          profile: profile,
          session: session,
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    
    try {
      final response = await ref.read(supabaseClientProvider)
        .auth
        .signInWithPassword(email: email, password: password);
      
      if (response.session != null) {
        final profile = await _fetchProfile(response.user!.id);
        state = AuthState.authenticated(
          user: response.user!,
          profile: profile,
          session: response.session!,
        );
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
    state = const AuthState.unauthenticated();
  }
}

// Provider declaration
@riverpod
AuthNotifier authNotifier(AuthNotifierRef ref) => AuthNotifier();
```

**Usage in Widgets**:

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return authState.when(
      initial: () => const LoadingScreen(),
      loading: () => const LoadingScreen(),
      authenticated: (user, profile, session) => HomeScreenContent(profile: profile),
      unauthenticated: () => const LoginScreen(),
      error: (message) => ErrorScreen(message: message),
    );
  }
}
```

### 3.2 Tile State (Parameterized)

**Purpose**: Fetch and cache tile data based on user role and baby profile IDs.

**Provider Type**: `FutureProvider.family<TileData, TileParams>`

**Implementation**:

```dart
// tile_params.dart
@freezed
class TileParams with _$TileParams {
  const factory TileParams({
    required UserRole role,
    required List<String> babyIds,
    @Default(5) int limit,
    @Default(0) int offset,
  }) = _TileParams;
}

// upcoming_events_provider.dart
@riverpod
Future<List<UpcomingEvent>> upcomingEvents(
  UpcomingEventsRef ref,
  TileParams params,
) async {
  // Check cache first
  final cache = ref.read(upcomingEventsCacheProvider);
  final cached = await cache.get(params);
  
  if (cached != null && !cached.isExpired) {
    return cached.data;
  }
  
  // Fetch from Supabase
  final datasource = ref.read(upcomingEventsDataSourceProvider);
  final events = await datasource.fetchEvents(params);
  
  // Update cache
  await cache.set(params, events);
  
  return events;
}

// upcoming_events_datasource.dart
class UpcomingEventsDataSource {
  final SupabaseClient _client;
  
  UpcomingEventsDataSource(this._client);
  
  Future<List<UpcomingEvent>> fetchEvents(TileParams params) async {
    var query = _client
      .from('events')
      .select()
      .order('event_date', ascending: true)
      .limit(params.limit)
      .gte('event_date', DateTime.now().toIso8601String());
    
    // Role-based query scoping
    if (params.role == UserRole.owner) {
      // Owner: query per baby
      query = query.eq('baby_profile_id', params.babyIds.first);
    } else {
      // Follower: aggregate across all followed babies
      query = query.in_('baby_profile_id', params.babyIds);
    }
    
    final data = await query;
    return data.map((json) => UpcomingEvent.fromJson(json)).toList();
  }
}
```

**Usage in Tile Widgets**:

```dart
class UpcomingEventsTile extends ConsumerWidget {
  final TileParams params;
  
  const UpcomingEventsTile({required this.params});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider(params));
    
    return eventsAsync.when(
      loading: () => const ShimmerTile(),
      error: (error, stack) => ErrorTile(error: error.toString()),
      data: (events) => TileContainer(
        title: 'Upcoming Events',
        children: events.map((event) => EventCard(event: event)).toList(),
      ),
    );
  }
}
```

### 3.3 Realtime State

**Purpose**: Manage real-time subscriptions and update tiles on data changes.

**Provider Type**: `StreamProvider<RealtimeUpdate>`

**Implementation**:

```dart
// realtime_provider.dart
@riverpod
Stream<RealtimeUpdate> realtimeUpdates(
  RealtimeUpdatesRef ref,
  List<String> babyIds,
) async* {
  final client = ref.read(supabaseClientProvider);
  final user = ref.watch(authNotifierProvider).maybeWhen(
    authenticated: (user, _, __) => user,
    orElse: () => null,
  );
  
  if (user == null) return;
  
  // Subscribe to owner_update_markers for cache invalidation
  final channel = client.channel('user_updates:${user.id}');
  
  for (final babyId in babyIds) {
    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'owner_update_markers',
        filter: 'baby_profile_id=eq.$babyId',
      ),
      (payload, [ref]) {
        // Emit update event
        yield RealtimeUpdate(
          table: 'owner_update_markers',
          babyProfileId: babyId,
          timestamp: DateTime.now(),
          payload: payload,
        );
      },
    );
  }
  
  await channel.subscribe();
  
  // Cleanup on dispose
  ref.onDispose(() {
    channel.unsubscribe();
  });
}

// Listen to realtime updates and invalidate caches
@riverpod
class RealtimeListener extends _$RealtimeListener {
  @override
  void build() {
    final authState = ref.watch(authNotifierProvider);
    
    authState.whenOrNull(
      authenticated: (user, profile, session) {
        final babyIds = _getFollowedBabyIds(user.id);
        
        ref.listen(realtimeUpdatesProvider(babyIds), (previous, next) {
          next.whenData((update) {
            _handleUpdate(update);
          });
        });
      },
    );
  }
  
  void _handleUpdate(RealtimeUpdate update) {
    // Invalidate relevant tile providers based on table
    switch (update.table) {
      case 'owner_update_markers':
        ref.invalidate(upcomingEventsProvider);
        ref.invalidate(recentPhotosProvider);
        ref.invalidate(registryHighlightsProvider);
        break;
      // Add other table invalidations
    }
  }
}
```

### 3.4 Cache State

**Purpose**: Manage local cache with TTL and invalidation.

**Provider Type**: `Provider<CacheService>`

**Implementation**:

```dart
// cache_service.dart
class CacheService {
  final Box _box;
  
  CacheService(this._box);
  
  Future<CachedData<T>?> get<T>(String key) async {
    final json = _box.get(key);
    if (json == null) return null;
    
    final cached = CachedData<T>.fromJson(json);
    
    if (cached.isExpired) {
      await _box.delete(key);
      return null;
    }
    
    return cached;
  }
  
  Future<void> set<T>(String key, T data, {Duration ttl = const Duration(minutes: 5)}) async {
    final cached = CachedData(
      data: data,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(ttl),
    );
    
    await _box.put(key, cached.toJson());
  }
  
  Future<void> invalidate(String key) async {
    await _box.delete(key);
  }
  
  Future<void> invalidateAll() async {
    await _box.clear();
  }
}

// cache_provider.dart
@riverpod
CacheService cacheService(CacheServiceRef ref) {
  final box = Hive.box('nonna_cache');
  return CacheService(box);
}

// Tile-specific cache provider
@riverpod
TileCache<UpcomingEvent> upcomingEventsCache(UpcomingEventsCacheRef ref) {
  final cache = ref.read(cacheServiceProvider);
  return TileCache<UpcomingEvent>(
    cache: cache,
    keyPrefix: 'upcoming_events',
    fromJson: UpcomingEvent.fromJson,
    toJson: (event) => event.toJson(),
  );
}
```

### 3.5 Screen State (Form & UI State)

**Purpose**: Manage screen-specific UI state like form inputs, filters, selections.

**Provider Type**: `StateNotifierProvider<ScreenNotifier, ScreenState>`

**Implementation**:

```dart
// calendar_screen_state.dart
@freezed
class CalendarScreenState with _$CalendarScreenState {
  const factory CalendarScreenState({
    @Default(CalendarView.month) CalendarView view,
    @Default(null) String? selectedBabyId,
    @Default(null) DateTime? selectedDate,
    @Default(false) bool isFilterVisible,
  }) = _CalendarScreenState;
}

// calendar_screen_notifier.dart
@riverpod
class CalendarScreenNotifier extends _$CalendarScreenNotifier {
  @override
  CalendarScreenState build() {
    return const CalendarScreenState();
  }
  
  void setView(CalendarView view) {
    state = state.copyWith(view: view);
  }
  
  void selectBaby(String? babyId) {
    state = state.copyWith(selectedBabyId: babyId);
  }
  
  void selectDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }
  
  void toggleFilter() {
    state = state.copyWith(isFilterVisible: !state.isFilterVisible);
  }
}

// Usage in screen
class CalendarScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(calendarScreenNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(screenState.view == CalendarView.month
              ? Icons.list
              : Icons.calendar_month),
            onPressed: () {
              ref.read(calendarScreenNotifierProvider.notifier).setView(
                screenState.view == CalendarView.month
                  ? CalendarView.list
                  : CalendarView.month,
              );
            },
          ),
        ],
      ),
      body: screenState.view == CalendarView.month
        ? MonthCalendarView()
        : ListCalendarView(),
    );
  }
}
```

---

## 4. State Patterns & Best Practices

### 4.1 Async Data Handling

**Pattern**: Use `AsyncValue<T>` for data that requires async fetching.

**Example**:

```dart
@riverpod
Future<BabyProfile> babyProfile(BabyProfileRef ref, String babyId) async {
  final repository = ref.read(babyProfileRepositoryProvider);
  return await repository.getProfile(babyId);
}

// In widget
final profileAsync = ref.watch(babyProfileProvider(babyId));

profileAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
  data: (profile) => ProfileCard(profile: profile),
);
```

**Benefits**:
- Handles loading, error, and data states automatically
- Type-safe state transitions
- Easy error handling

### 4.2 State Persistence

**Pattern**: Use `keepAlive` for providers that should persist across navigation.

**Example**:

```dart
@riverpod
Future<List<Photo>> photos(PhotosRef ref, String babyId) async {
  // Keep data alive across navigation
  ref.keepAlive();
  
  final repository = ref.read(photoRepositoryProvider);
  return await repository.getPhotos(babyId);
}
```

**Use Cases**:
- Tile data that shouldn't refetch on navigation
- User profile data
- App configuration

### 4.3 State Invalidation

**Pattern**: Explicitly invalidate providers when data changes.

**Example**:

```dart
// After uploading a photo
Future<void> uploadPhoto(Photo photo) async {
  await repository.uploadPhoto(photo);
  
  // Invalidate photos provider to trigger refetch
  ref.invalidate(photosProvider);
}
```

**Invalidation Strategies**:
- **Manual**: Explicitly call `ref.invalidate()`
- **Time-Based**: Use `ref.refresh()` periodically
- **Event-Based**: Invalidate on realtime updates

### 4.4 State Composition

**Pattern**: Combine multiple providers to derive new state.

**Example**:

```dart
// Combine auth state and baby profiles
@riverpod
Future<List<BabyProfile>> userBabyProfiles(UserBabyProfilesRef ref) async {
  final authState = ref.watch(authNotifierProvider);
  
  return authState.maybeWhen(
    authenticated: (user, _, __) async {
      final repository = ref.read(babyProfileRepositoryProvider);
      return await repository.getProfilesForUser(user.id);
    },
    orElse: () => [],
  );
}
```

**Benefits**:
- Reactive composition (auto-updates when dependencies change)
- Single source of truth
- Reduced boilerplate

### 4.5 State Selection

**Pattern**: Use `select` to rebuild only when specific state changes.

**Example**:

```dart
// Only rebuild when display name changes, not entire profile
final displayName = ref.watch(
  profileProvider.select((profile) => profile.displayName),
);
```

**Benefits**:
- Performance optimization (fewer rebuilds)
- Granular reactivity
- Reduced unnecessary renders

---

## 5. Tile State Management

### 5.1 Tile Provider Structure

Each tile follows a consistent provider structure:

```
lib/tiles/[tile_name]/
├── models/
│   └── [tile_model].dart
├── providers/
│   ├── [tile_name]_provider.dart       # Main data provider
│   └── [tile_name]_cache_provider.dart # Cache provider
├── data/
│   └── datasources/
│       ├── remote/
│       │   └── [tile_name]_datasource.dart
│       └── local/
│           └── [tile_name]_cache.dart
└── widgets/
    └── [tile_name]_tile.dart
```

### 5.2 Tile Provider Pattern

**Standard Pattern**:

1. Widget requests data with parameters
2. Provider checks cache
3. If cache hit and not expired, return cached data
4. If cache miss or expired, fetch from Supabase
5. Update cache with fresh data
6. Return data to widget

**Code Template**:

```dart
@riverpod
Future<List<TileData>> tileData(
  TileDataRef ref,
  TileParams params,
) async {
  // 1. Get cache
  final cache = ref.read(tileDataCacheProvider);
  
  // 2. Check cache
  final cached = await cache.get(params);
  if (cached != null && !cached.isExpired) {
    return cached.data;
  }
  
  // 3. Fetch from remote
  final datasource = ref.read(tileDataDataSourceProvider);
  final data = await datasource.fetch(params);
  
  // 4. Update cache
  await cache.set(params, data);
  
  // 5. Return data
  return data;
}
```

### 5.3 Tile Role-Based State

**Owner vs Follower State**:

```dart
@riverpod
TileParams tileParams(TileParamsRef ref, TileType tileType) {
  final authState = ref.watch(authNotifierProvider);
  
  return authState.maybeWhen(
    authenticated: (user, profile, _) {
      final memberships = ref.watch(babyMembershipsProvider(user.id));
      
      // Determine role based on memberships
      final role = _determineRole(memberships);
      
      // Get baby IDs based on role
      final babyIds = role == UserRole.owner
        ? _getOwnedBabyIds(memberships)
        : _getFollowedBabyIds(memberships);
      
      return TileParams(
        role: role,
        babyIds: babyIds,
        limit: tileType.defaultLimit,
      );
    },
    orElse: () => TileParams(
      role: UserRole.follower,
      babyIds: [],
      limit: 5,
    ),
  );
}
```

### 5.4 Tile Realtime Updates

**Update Flow**:

1. Owner makes change (e.g., uploads photo)
2. Database trigger updates `owner_update_markers`
3. Realtime subscription emits update event
4. Listener invalidates affected tile providers
5. Tiles refetch data from cache/Supabase
6. UI updates automatically

**Implementation**:

```dart
// In realtime listener
void _handleUpdate(RealtimeUpdate update) {
  switch (update.table) {
    case 'photos':
      ref.invalidate(recentPhotosProvider);
      ref.invalidate(galleryFavoritesProvider);
      break;
    case 'events':
      ref.invalidate(upcomingEventsProvider);
      ref.invalidate(rsvpTasksProvider);
      break;
    case 'registry_items':
      ref.invalidate(registryHighlightsProvider);
      ref.invalidate(recentPurchasesProvider);
      break;
  }
}
```

---

## 6. State Lifecycle Management

### 6.1 Provider Lifecycle

**Lifecycle Phases**:

1. **Creation**: Provider created on first read
2. **Active**: Provider maintains state while watched
3. **Disposal**: Provider disposed when no longer watched (unless `keepAlive`)
4. **Recreation**: Provider recreated on next read

**Lifecycle Control**:

```dart
@riverpod
Future<Data> data(DataRef ref) async {
  // Keep alive across navigation
  ref.keepAlive();
  
  // Cleanup on dispose
  ref.onDispose(() {
    // Cancel subscriptions, close streams, etc.
  });
  
  // Fetch data
  return await fetchData();
}
```

### 6.2 Memory Management

**Strategies**:

1. **Auto-Dispose**: Default behavior, providers disposed when unwatched
2. **Keep Alive**: Use `ref.keepAlive()` for data that should persist
3. **Manual Disposal**: Use `ref.invalidate()` to force disposal
4. **Cache Limits**: Implement LRU cache to limit memory usage

**Example**:

```dart
// Auto-dispose for screen-specific state
@riverpod
class FormNotifier extends _$FormNotifier {
  // No keepAlive - disposed when screen unmounted
}

// Keep alive for global state
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    ref.keepAlive(); // Never dispose
    return initialState;
  }
}
```

### 6.3 State Reset

**Pattern**: Reset state on logout or app restart.

```dart
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  void build() {
    // Listen to auth state
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        unauthenticated: () => _resetAllState(),
      );
    });
  }
  
  void _resetAllState() {
    // Invalidate all providers
    ref.invalidate(babyProfilesProvider);
    ref.invalidate(upcomingEventsProvider);
    ref.invalidate(recentPhotosProvider);
    // ... invalidate other providers
    
    // Clear cache
    ref.read(cacheServiceProvider).invalidateAll();
  }
}
```

---

## 7. State Testing Strategy

### 7.1 Provider Testing

**Unit Testing Providers**:

```dart
// Test setup
final container = ProviderContainer(
  overrides: [
    // Mock dependencies
    supabaseClientProvider.overrideWithValue(mockSupabaseClient),
    cacheServiceProvider.overrideWithValue(mockCacheService),
  ],
);

// Test provider
test('should fetch upcoming events', () async {
  final params = TileParams(role: UserRole.owner, babyIds: ['baby1']);
  
  final events = await container.read(upcomingEventsProvider(params).future);
  
  expect(events, isNotEmpty);
  expect(events.first.babyProfileId, 'baby1');
});

// Cleanup
addTearDown(container.dispose);
```

### 7.2 Widget Testing with Providers

**Testing Widgets**:

```dart
testWidgets('should display upcoming events tile', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        upcomingEventsProvider(params).overrideWith((ref) async {
          return mockEvents;
        }),
      ],
      child: MaterialApp(
        home: UpcomingEventsTile(params: params),
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text('Upcoming Events'), findsOneWidget);
  expect(find.byType(EventCard), findsNWidgets(mockEvents.length));
});
```

### 7.3 Integration Testing

**Testing State Flows**:

```dart
testWidgets('should update tile after real-time event', (tester) async {
  final container = ProviderContainer();
  
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: HomeScreen()),
    ),
  );
  
  // Wait for initial load
  await tester.pumpAndSettle();
  
  // Simulate realtime update
  container.read(realtimeUpdatesProvider(babyIds).notifier).emit(
    RealtimeUpdate(table: 'events', babyProfileId: 'baby1'),
  );
  
  // Wait for update
  await tester.pumpAndSettle();
  
  // Verify UI updated
  expect(find.text('New Event'), findsOneWidget);
});
```

---

## 8. State Performance Optimization

### 8.1 Minimizing Rebuilds

**Strategies**:

1. **Use `select`**: Only rebuild on specific state changes
2. **Use `when`**: Handle all async states efficiently
3. **Use `const` constructors**: Prevent unnecessary widget rebuilds
4. **Split providers**: Create granular providers for independent state

**Example**:

```dart
// Bad: Entire profile rebuilds on any change
final profile = ref.watch(profileProvider);

// Good: Only rebuilds when display name changes
final displayName = ref.watch(
  profileProvider.select((p) => p.displayName),
);
```

### 8.2 Caching Strategy

**Multi-Level Caching**:

1. **Memory Cache** (Riverpod keepAlive): Instant access, cleared on app restart
2. **Local Storage** (Hive/Isar): Persistent, survives app restarts
3. **CDN Cache** (Supabase Storage): For images, global distribution

**Cache TTL Strategy**:

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Tile Configs | 1 hour | Rarely changes |
| Tile Data | 5 minutes | Frequent updates |
| User Profile | 30 minutes | Moderate update frequency |
| Photos | Indefinite | Invalidate on delete only |
| Events | 5 minutes | Frequent updates |
| Registry | 5 minutes | Frequent updates |

### 8.3 Lazy Loading

**Implementation**:

```dart
@riverpod
Future<List<Photo>> photos(
  PhotosRef ref,
  String babyId, {
  int limit = 30,
  int offset = 0,
}) async {
  final datasource = ref.read(photoDataSourceProvider);
  return await datasource.fetchPhotos(
    babyId: babyId,
    limit: limit,
    offset: offset,
  );
}

// In widget with infinite scroll
class PhotoGallery extends ConsumerStatefulWidget {
  @override
  ConsumerState<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends ConsumerState<PhotoGallery> {
  int _offset = 0;
  final int _limit = 30;
  
  void _loadMore() {
    setState(() {
      _offset += _limit;
    });
    ref.read(photosProvider(babyId, limit: _limit, offset: _offset));
  }
  
  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosProvider(babyId, limit: _limit, offset: _offset));
    
    return ListView.builder(
      itemCount: photos.length + 1,
      itemBuilder: (context, index) {
        if (index == photos.length) {
          _loadMore();
          return CircularProgressIndicator();
        }
        return PhotoCard(photo: photos[index]);
      },
    );
  }
}
```

---

## 9. State Error Handling

### 9.1 Error State Modeling

**Pattern**: Use `AsyncValue` to represent loading, error, and data states.

```dart
final dataAsync = ref.watch(dataProvider);

dataAsync.when(
  loading: () => LoadingWidget(),
  error: (error, stack) {
    // Log error
    logger.error('Failed to load data', error, stack);
    
    // Show user-friendly message
    return ErrorWidget(
      message: _getErrorMessage(error),
      onRetry: () => ref.refresh(dataProvider),
    );
  },
  data: (data) => DataWidget(data: data),
);
```

### 9.2 Error Recovery

**Strategies**:

1. **Retry Logic**: Automatic retry with exponential backoff
2. **Fallback to Cache**: Use stale cache on error
3. **Partial Data**: Show cached data with error banner
4. **User-Initiated Retry**: Provide manual retry button

**Implementation**:

```dart
@riverpod
Future<List<Event>> events(EventsRef ref, String babyId) async {
  try {
    // Try to fetch from remote
    final datasource = ref.read(eventDataSourceProvider);
    return await datasource.fetchEvents(babyId);
  } catch (e) {
    // On error, fallback to cache
    final cache = ref.read(eventsCacheProvider);
    final cached = await cache.get(babyId);
    
    if (cached != null) {
      // Return stale cache with warning
      logger.warn('Using stale cache due to error', e);
      return cached.data;
    }
    
    // No cache available, rethrow error
    rethrow;
  }
}
```

### 9.3 Error Logging

**Integration with Sentry**:

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    // Listen to all provider errors
    ref.onError((error, stackTrace) {
      // Log to Sentry
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('provider', ref.origin.name);
          scope.setUser(SentryUser(id: _getCurrentUserId()));
        },
      );
      
      // Show snackbar to user
      _showErrorSnackbar(error);
    });
  }
}
```

---

## 10. State Migration & Versioning

### 10.1 State Schema Versioning

**Pattern**: Version cache schemas to handle migrations.

```dart
class CachedData<T> {
  final T data;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final int version; // Schema version
  
  static const int currentVersion = 2;
  
  factory CachedData.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;
    
    if (version < currentVersion) {
      // Migrate old data
      json = _migrate(json, from: version, to: currentVersion);
    }
    
    return CachedData(
      data: json['data'],
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      version: currentVersion,
    );
  }
  
  static Map<String, dynamic> _migrate(
    Map<String, dynamic> json,
    {required int from, required int to},
  ) {
    // Apply migrations sequentially
    for (int v = from; v < to; v++) {
      switch (v) {
        case 1:
          json = _migrateV1toV2(json);
          break;
      }
    }
    return json;
  }
}
```

### 10.2 State Cleanup on Upgrade

**Pattern**: Clear incompatible cache on app version upgrade.

```dart
@riverpod
class AppInitializer extends _$AppInitializer {
  @override
  Future<void> build() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    
    final lastVersion = prefs.getString('last_app_version');
    final currentVersion = packageInfo.version;
    
    if (lastVersion != currentVersion) {
      // Clear cache on version change
      final cache = ref.read(cacheServiceProvider);
      await cache.invalidateAll();
      
      // Update stored version
      await prefs.setString('last_app_version', currentVersion);
    }
  }
}
```

---

## 11. State Architecture Validation

### 11.1 Requirements Alignment

| Requirement | State Management Solution | Status |
|-------------|--------------------------|--------|
| Dynamic tile-based UI | Parameterized tile providers with role-based scoping | ✅ |
| Real-time updates | Realtime provider with automatic invalidation | ✅ |
| Multi-level caching | Memory (keepAlive) + Local (Hive) + CDN | ✅ |
| Offline-first | Cache-first strategy with background sync | ✅ |
| Role-based content | Role-aware providers with query scoping | ✅ |
| Sub-500ms screen load | Cache-first with instant data access | ✅ |
| < 1% crash rate | Error handling, fallback to cache, Sentry logging | ✅ |
| Testability | Provider overrides, mock-friendly architecture | ✅ |

### 11.2 Performance Metrics

**Target Performance**:

| Metric | Target | State Management Contribution |
|--------|--------|-------------------------------|
| Screen Load Time | < 500ms | Cache-first strategy provides instant data |
| Tile Render Time | < 300ms | Parameterized providers with efficient queries |
| State Update Time | < 100ms | Riverpod's efficient rebuild mechanism |
| Cache Hit Rate | > 80% | Multi-level caching with appropriate TTLs |
| Memory Usage | < 100MB | Auto-dispose, LRU cache limits |

---

## 12. State Management Best Practices Summary

**Do's**:
1. ✅ Use `@riverpod` annotation for cleaner syntax
2. ✅ Implement cache-first strategy for performance
3. ✅ Use `AsyncValue.when` to handle all states
4. ✅ Use `select` to minimize rebuilds
5. ✅ Keep providers focused (single responsibility)
6. ✅ Use `keepAlive` for persistent state
7. ✅ Invalidate providers on data changes
8. ✅ Log errors to Sentry for monitoring
9. ✅ Test providers with mocked dependencies
10. ✅ Document provider parameters and behavior

**Don'ts**:
1. ❌ Don't use global mutable state outside Riverpod
2. ❌ Don't call `ref.read` in build methods (use `ref.watch`)
3. ❌ Don't forget to dispose resources (streams, timers)
4. ❌ Don't ignore error states (always handle errors)
5. ❌ Don't cache indefinitely without TTL
6. ❌ Don't use large objects in memory cache (use local storage)
7. ❌ Don't couple providers tightly (use composition)
8. ❌ Don't skip testing providers
9. ❌ Don't hardcode values (use configuration)
10. ❌ Don't expose internal state (use read-only getters)

---

## 13. Conclusion

The Nonna App state management architecture, built on Riverpod, provides a robust foundation for managing complex application state across a dynamic, tile-based, multi-role platform. Key strengths include:

**Strengths**:
- **Type Safety**: Compile-time safety prevents runtime errors
- **Testability**: Easy mocking and provider overrides
- **Performance**: Efficient caching and granular rebuilds
- **Scalability**: Parameterized providers support role-based queries
- **Maintainability**: Clean separation of concerns, single responsibility
- **Real-Time**: Seamless integration with Supabase Realtime

**Architecture Highlights**:
- Multi-level caching for instant data access and offline support
- Role-based state scoping for owner vs follower experiences
- Realtime subscriptions with automatic cache invalidation
- Comprehensive error handling with fallback strategies
- Performance-optimized with lazy loading and selective rebuilds

This state management design ensures the Nonna App delivers a responsive, reliable, and scalable user experience while maintaining code quality and developer productivity.

---

**Document Version**: 1.0  
**Last Updated**: January 4, 2026  
**Next Review**: Before Development Phase Begins  
**Approval Status**: Pending Architecture Team Review
