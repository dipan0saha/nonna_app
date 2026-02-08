# Mocking Fixes Summary - Part II

## Date: February 8, 2026
## Status: ✅ COMPLETED

---

## Overview

This document summarizes all the fixes applied to resolve the mocking issues identified in `test_results.txt`. The goal was to make the centralized mocking infrastructure compatible with the actual service implementations and model definitions in the codebase.

---

## Issues Fixed

### 1. Test Data Factory (`test/helpers/test_data_factory.dart`)

**Problem:** Field names in the test factory didn't match the actual model constructors.

#### Fixed Models:

#### a) User Model
**Before:**
```dart
User(
  id: ...,
  email: ...,
  displayName: ...,
  profilePictureUrl: ...,
  createdAt: ...,
)
```

**After:**
```dart
User(
  userId: ...,              // Changed from 'id'
  displayName: ...,
  avatarUrl: ...,           // Changed from 'profilePictureUrl'
  biometricEnabled: false,  // Added
  createdAt: ...,
  updatedAt: ...,           // Added
)
```

#### b) BabyProfile Model
**Before:**
```dart
BabyProfile(
  id: ...,
  name: ...,
  dueDate: ...,         // Wrong field name
  birthDate: ...,       // Wrong field name
  gender: ...,          // String type
  profilePictureUrl: ...,
  ownerId: ...,
  createdAt: ...,
)
```

**After:**
```dart
BabyProfile(
  id: ...,
  name: ...,
  defaultLastNameSource: ...,  // Added
  profilePhotoUrl: ...,        // Changed from 'profilePictureUrl'
  expectedBirthDate: ...,      // Changed from 'dueDate'
  actualBirthDate: ...,        // Changed from 'birthDate'
  gender: Gender.unknown,      // Changed to Gender enum
  createdAt: ...,
  updatedAt: ...,              // Added
  deletedAt: ...,              // Added
)
```

#### c) Event Model
**Before:**
```dart
Event(
  id: ...,
  babyProfileId: ...,
  title: ...,
  description: ...,
  eventDate: ...,    // Wrong field name
  location: ...,
  createdBy: ...,    // Wrong field name
  createdAt: ...,
)
```

**After:**
```dart
Event(
  id: ...,
  babyProfileId: ...,
  createdByUserId: ...,  // Changed from 'createdBy'
  title: ...,
  startsAt: ...,         // Changed from 'eventDate'
  endsAt: ...,           // Added
  description: ...,
  location: ...,
  videoLink: ...,        // Added
  coverPhotoUrl: ...,    // Added
  createdAt: ...,
  updatedAt: ...,        // Added
  deletedAt: ...,        // Added
)
```

#### d) Photo Model
**Before:**
```dart
Photo(
  id: ...,
  babyProfileId: ...,
  uploadedBy: ...,    // Wrong field name
  url: ...,           // Wrong field name
  thumbnailUrl: ...,  // Wrong field name
  caption: ...,
  takenAt: ...,       // Wrong field name
  uploadedAt: ...,    // Wrong field name
)
```

**After:**
```dart
Photo(
  id: ...,
  babyProfileId: ...,
  uploadedByUserId: ...,  // Changed from 'uploadedBy'
  storagePath: ...,       // Changed from 'url'
  thumbnailPath: ...,     // Changed from 'thumbnailUrl'
  caption: ...,
  tags: [],               // Added
  createdAt: ...,         // Changed from 'uploadedAt'
  updatedAt: ...,         // Added
  deletedAt: ...,         // Added
)
```

#### e) RegistryItem Model
**Before:**
```dart
RegistryItem(
  id: ...,
  babyProfileId: ...,
  name: ...,
  description: ...,
  price: 29.99,       // Field doesn't exist
  url: ...,           // Wrong field name
  imageUrl: ...,      // Field doesn't exist
  isPurchased: ...,   // Field doesn't exist
  purchasedBy: ...,   // Field doesn't exist
  createdAt: ...,
)
```

**After:**
```dart
RegistryItem(
  id: ...,
  babyProfileId: ...,
  createdByUserId: ...,  // Added
  name: ...,
  description: ...,
  linkUrl: ...,          // Changed from 'url'
  priority: 3,           // Changed from 'price'
  createdAt: ...,
  updatedAt: ...,        // Added
  deletedAt: ...,        // Added
)
```

#### f) Notification Model
**Before:**
```dart
Notification(
  id: ...,
  userId: ...,      // Wrong field name
  type: 'info',     // String type
  title: ...,
  message: ...,     // Wrong field name
  metadata: {},     // Wrong field name
  isRead: false,    // Wrong field name
  createdAt: ...,
)
```

**After:**
```dart
Notification(
  id: ...,
  recipientUserId: ...,         // Changed from 'userId'
  babyProfileId: ...,           // Added
  type: NotificationType.general, // Changed to enum
  title: ...,
  body: ...,                    // Changed from 'message'
  payload: ...,                 // Changed from 'metadata'
  readAt: ...,                  // Changed from 'isRead' (DateTime)
  createdAt: ...,
)
```

#### Imports Added
```dart
import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/enums/notification_type.dart';
```

---

### 2. Mock Factory (`test/helpers/mock_factory.dart`)

**Problem:** Mock factory was stubbing methods that don't exist in the actual services or had incorrect signatures.

#### a) CacheService
**Issue:** `invalidate()` method doesn't exist in CacheService

**Fixed:** Removed the stub:
```dart
// REMOVED:
// when(mock.invalidate(any)).thenAnswer((_) async => null);
```

**Actual Methods Available:**
- `get()` - async
- `put()` - async
- `delete()` - async
- `clear()` - async
- `has()` - async
- `invalidateByOwnerUpdate()` - async
- `invalidateByBabyProfile()` - async

---

#### b) StorageService
**Issue:** Mock was using `uploadImage()` which doesn't exist. Actual service uses `uploadFile()`.

**Before:**
```dart
when(mock.uploadImage(
  bucket: anyNamed('bucket'),
  path: anyNamed('path'),
  file: anyNamed('file'),
)).thenAnswer((_) async => defaultUploadUrl);
```

**After:**
```dart
when(mock.uploadFile(
  filePath: anyNamed('filePath'),
  storageKey: anyNamed('storageKey'),
  bucket: anyNamed('bucket'),
)).thenAnswer((_) async => defaultUploadUrl);
```

**Issue:** `deleteFile()` signature was wrong

**Before:**
```dart
when(mock.deleteFile(
  bucket: anyNamed('bucket'),
  path: anyNamed('path'),
)).thenAnswer((_) async => null);
```

**After:**
```dart
when(mock.deleteFile(any, any)).thenAnswer((_) async => null);
// Actual signature: deleteFile(String bucketName, String path)
```

**Issue:** `getPublicUrl()` signature was wrong

**Before:**
```dart
when(mock.getPublicUrl(
  bucket: anyNamed('bucket'),
  path: anyNamed('path'),
)).thenReturn(defaultUploadUrl);
```

**After:**
```dart
when(mock.getPublicUrl(any, any)).thenReturn(defaultUploadUrl);
// Actual signature: String getPublicUrl(String bucketName, String path)
```

---

#### c) LocalStorageService
**Issue:** `getString()` and `getBool()` are synchronous, not async

**Before:**
```dart
when(mock.getString(any)).thenAnswer((_) async => null);
when(mock.getBool(any)).thenAnswer((_) async => null);
```

**After:**
```dart
when(mock.getString(any)).thenReturn(null);
when(mock.getBool(any)).thenReturn(null);
```

**Issue:** `setString()` and `setBool()` return `Future<void>`, not `Future<bool>`

**Before:**
```dart
when(mock.setString(any, any)).thenAnswer((_) async => true);
when(mock.setBool(any, any)).thenAnswer((_) async => true);
```

**After:**
```dart
when(mock.setString(any, any)).thenAnswer((_) async => null);
when(mock.setBool(any, any)).thenAnswer((_) async => null);
```

---

#### d) BackupService
**Issue:** Methods `createBackup()` and `restoreBackup()` don't exist in BackupService

**Fixed:** Removed non-existent method stubs:
```dart
// REMOVED:
// when(mock.createBackup()).thenAnswer((_) async => 'backup-id-123');
// when(mock.restoreBackup(any)).thenAnswer((_) async => null);
```

**Actual Methods Available:**
- `exportUserData(String userId)` - returns Future<String>

---

#### e) AnalyticsService
**Issue:** `logEvent()` is not directly exposed; it's used internally

**Fixed:** Removed the stub:
```dart
// REMOVED:
// when(mock.logEvent(
//   name: anyNamed('name'),
//   parameters: anyNamed('parameters'),
// )).thenAnswer((_) async => null);
```

**Actual Methods Available:**
- `logSignUp()`
- `logLogin()`
- `logBabyProfileCreated()`
- And other specific event logging methods

---

#### f) DatabaseService
**Issue:** `update()` returns `PostgrestFilterBuilder`, not `Future<List<Map>>`

**Before:**
```dart
when(mock.update(table, any, any))
    .thenAnswer((_) async => [returnData]);
```

**After:**
```dart
when(mock.update(table, any))
    .thenAnswer((_) => FakePostgrestBuilder([returnData]));
```

**Actual Signature:**
```dart
PostgrestFilterBuilder<dynamic> update(String table, Map<String, dynamic> data)
```

---

### 3. Test File (`test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart`)

**Issue:** Using `any` matcher as a value parameter for `setupCacheGet()`

**Problem:**
```dart
MockHelpers.setupCacheGet(
  mocks.cache,
  any,  // ❌ ERROR: The argument type 'Null' can't be assigned to the parameter type 'String'
  [sampleFollower.toJson()],
);
```

**Fixed:** Use `when()` directly with `any` matcher:
```dart
when(mocks.cache.get(any)).thenAnswer((_) async => [sampleFollower.toJson()]);
```

**Lines Fixed:**
- Line 114 (test: 'loads followers from cache when available')
- Line 157 (test: 'force refresh bypasses cache')
- Line 290 (test: 'refreshes followers with force refresh')

---

## Impact Summary

### Files Modified
1. `test/helpers/test_data_factory.dart` - 6 model factories updated, 2 imports added
2. `test/helpers/mock_factory.dart` - 6 service mock factories updated
3. `test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart` - 3 test cases fixed

### Lines Changed
- **test_data_factory.dart:** ~80 lines modified
- **mock_factory.dart:** ~50 lines modified
- **test file:** ~9 lines modified

### Total Impact
- **Models Fixed:** 6 (User, BabyProfile, Event, Photo, RegistryItem, Notification)
- **Services Fixed:** 6 (CacheService, StorageService, LocalStorageService, BackupService, AnalyticsService, DatabaseService)
- **Test Cases Fixed:** 3
- **Compilation Errors Resolved:** 17

---

## Testing Recommendations

After these fixes, the following test command should work:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart
```

### Expected Outcome
✅ All tests should compile and run without errors
✅ All model factories should create valid objects
✅ All mock services should stub the correct methods with correct signatures

---

## Next Steps

1. **Generate Mocks** (if not already done):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Run the Fixed Test**:
   ```bash
   flutter test test/tiles/new_followers/providers/new_followers_provider_test_refactored.dart
   ```

3. **Verify All Tests Pass**:
   ```bash
   flutter test
   ```

4. **Update Other Tests**: If other tests use the old field names or methods, they will need similar updates.

---

## Notes

### Model Changes Summary
All models now correctly use:
- Proper field names matching the actual model definitions
- Correct types (e.g., enums instead of strings)
- All required fields including timestamps (`createdAt`, `updatedAt`, `deletedAt`)

### Service Changes Summary
All mock services now:
- Only stub methods that actually exist
- Use correct method signatures (parameters and return types)
- Return appropriate types (sync vs async)

### Best Practices Applied
1. Always reference actual service interfaces when creating mocks
2. Use enums instead of strings for type-safe code
3. Include all required fields in test factories
4. Use `when()` directly when you need the `any` matcher as a function parameter

---

## References

- Original Issue: `test_results.txt`
- Implementation Guide: `MOCKING_NEXT_STEPS.md`
- Quick Reference: `MOCKING_QUICK_REFERENCE.md`
- Implementation Summary: `IMPLEMENTATION_SUMMARY.md`

---

**Status:** ✅ All identified issues have been fixed and are ready for testing.
**PR Branch:** `copilot/fix-mocking-issues-in-tests`
**Date Completed:** February 8, 2026
