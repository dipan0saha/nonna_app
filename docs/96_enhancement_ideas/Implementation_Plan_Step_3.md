# Implementation Plan: Create Isolated Tile Test Suites (Gap Item #3)

## Goal Description
The Nonna application has a dedicated unit and widget testing infrastructure for tiles under `test/tiles/`. While 14 tiles are fully covered by isolated tests, 4 newly added smart tiles (`NewBabyWelcomeTile`, `PredictionVotesSmartTile`, `NameSuggestionsSmartTile`, and `RegistryListSmartTile`) lack dedicated test suites under `test/tiles/`. They are currently only tested implicitly inside parent screen tests (e.g. `gamification_screen_test.dart`). 

This creates a high risk of regression bugs when developer updates inadvertently break the layout boundaries or state triggers of these tiles.

This plan details how we will scaffold and write isolated widget and unit tests for the 4 smart tiles, adopting the project's standard Riverpod override test pattern, and prune the stale `test/tiles/registry_deals/` directory.

---

## User Review Required
No breaking changes or architectural updates. 

> [!IMPORTANT]
> **Stale Folder Cleanup**:
> - We will delete `test/tiles/registry_deals/` entirely as it is empty and corresponds to the ghost tile `lib/tiles/registry_deals/` (deleted in Step 2 of the gaps resolution).

---

## Open Questions
There are no open questions. The test coverage requirements and mock strategies are fully defined below.

---

## Proposed Changes

### Cleanups

#### [DELETE] [registry_deals](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/tiles/registry_deals)
Delete the stale, empty `test/tiles/registry_deals/` folder and any empty parent/child nodes.

> [!NOTE]
> **Dependency on Step 2**: `Implementation_Plan_Step_2.md` Phase 1 also deletes `test/tiles/registry_deals/` as part of its broader empty-directory cleanup. If Step 2 has already been executed before this step, this deletion is already done — no action needed here.

---

### New Test Suites

We will create four new test suites inside the `test/tiles/` directory structure.

#### [NEW] [new_baby_welcome_tile_test.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/tiles/new_baby_welcome/widgets/new_baby_welcome_tile_test.dart)
This tile is a stateless presentation tile. It takes the `BabyProfile` entity, `isLoading`, `error`, and `onRefresh` as constructor parameters.
We will write test cases covering:
1. **Initial Rendering**: Verify the tile renders with Key `'new_baby_welcome_tile'`.
2. **Loading State**: Verify `ShimmerPlaceholder` elements appear when `isLoading: true`.
3. **Error State**: Verify error text displays when `error != null`, and clicking "Retry" fires `onRefresh`.
4. **Empty State**: Verify it renders `SizedBox.shrink()` if `babyProfile == null`.
5. **Normal Rendering**: Provide a populated `BabyProfile` and verify baby name, gender chip, birthdate, weight, and height are formatted and displayed correctly.
6. **Age Plural Logic**:
   - If days old is `0`: Verify it renders `🎉 Born today!`.
   - If days old is `1`: Verify it renders `🎉 1 day old` (verifies singular plural form).
   - If days old is `5`: Verify it renders `🎉 5 days old` (verifies plural other form).

*Draft mock code setup:*
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart';

BabyProfile _makeProfile({int daysAgo = 0}) {
  return BabyProfile(
    id: 'bp_1',
    name: 'Little Alex',
    gender: Gender.male,
    actualBirthDate: DateTime.now().subtract(Duration(days: daysAgo)),
    birthWeightKg: 3.45,
    birthHeightCm: 51.0,
    ownerUserId: 'user_1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
```

#### [NEW] [prediction_votes_tile_test.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/tiles/prediction_votes/widgets/prediction_votes_tile_test.dart)
This is a smart tile. It reads state from `predictionVotesProvider` and gets the user ID from `authProvider`.
We will define a lightweight `_FakePredictionVotesNotifier` extending `PredictionVotesNotifier` and overriding `build()` to return custom mock states.
We will test:
1. **Initial Rendering**: Verify tile renders with Key `'prediction_votes_tile'`.
2. **Loading & Error**: Verify loading indicator renders when state is loading, and error text renders on state error.
3. **Gender voting list**: Verify "Boy" and "Girl" buttons show correct vote percentages and total numbers based on mocks.
4. **Gender button action**: Tap "Boy" or "Girl" option and verify it calls `voteGender` on notifier.
5. **Birthdate prediction**:
   - If user has NOT voted: Button text shows `"Pick a date"`.
   - If user HAS voted: Button text shows `"Change your prediction"`.
6. **Summary metrics**: Verify pluralized text displays the sum total of all votes correctly.

*Draft mock code setup:*
```dart
class _FakePredictionVotesNotifier extends PredictionVotesNotifier {
  _FakePredictionVotesNotifier(this._initialState);
  final PredictionVotesState _initialState;

  @override
  PredictionVotesState build() => _initialState;

  @override
  Future<void> load({required String babyProfileId}) async {}

  @override
  Future<void> voteGender({
    required String babyProfileId,
    required String userId,
    required String genderValue,
  }) async {}

  @override
  Future<bool> voteBirthdate({
    required String babyProfileId,
    required String userId,
    required DateTime date,
    bool isAnonymous = false,
  }) async => true;
}
```

#### [NEW] [name_suggestions_tile_test.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/tiles/name_suggestions/widgets/name_suggestions_tile_test.dart)
This is a smart tile that monitors name suggestion updates. It utilizes `nameSuggestionsProvider`.
We will define `_FakeNameSuggestionsNotifier` subclassing `NameSuggestionsNotifier`.
We will test:
1. **Main structure**: Renders the `'name_suggestions_tile'` correctly.
2. **List rendering**: Verify it lists items with gender badges, correct layout, and vote count totals.
3. **Action - Like**: Tap like button on a suggestion and verify it triggers `likeSuggestion` notifier call.
4. **Form Toggle**: Tap `+` action in the header, verify `_AddNameForm` appears/toggles.
5. **Submit Suggestion**: Enter name in text field, tap choice chips, and tap "Suggest Name" to verify it invokes `addSuggestion`.

#### [NEW] [registry_list_tile_test.dart](file:///Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/test/tiles/registry_list/widgets/registry_list_tile_test.dart)
This smart tile reads from `registryScreenProvider` and `homeScreenProvider`.
We will subclass `RegistryScreenNotifier` and `HomeScreenNotifier` with lightweight fakes to inject distinct states (Available list, Purchased list, Loading, Empty).
We will test:
1. **Initial Rendering**: Verify the tile renders with Key `'registry_list_smart_tile'`.
2. **Filter & Sort Header**: Verify the priority and available headers are formatted correctly.
3. **Categories Separation**: Verify available items are shown in the first section and purchased items in the second section.
4. **Role System Verification**:
   - **Follower View**: Verify lock icons appear on purchased items and they are not interactable.
   - **Owner View**: Verify owners can toggle purchase status on any item.
5. **Interactive callbacks**: Tapping a registry item row triggers context push navigation to the details screen.

---

## Verification Plan

### Automated Tests
Run the entire testing pipeline to confirm all new widget suites pass statically and runtime:
1. **Format Check**:
   ```bash
   make format
   ```
2. **Static Analysis**:
   ```bash
   make analyze
   ```
3. **Run Unit and Widget Test Targets**:
   ```bash
   make test
   ```
4. **Verification via test runner script**:
   ```bash
   ./run_tests.sh
   ```
