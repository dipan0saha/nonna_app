# Implementation Plan: Real Server-Side Thumbnail Generation (Gap Item #4)

## Goal Description

The Nonna app uploads gallery photos to Supabase Storage and is expected to serve small thumbnail versions for fast preview rendering in the `recent_photos` and `gallery_favorites` tiles. A Supabase Edge Function (`generate-thumbnail`) was created as the server-side thumbnail generator, but it is an unfinished stub — it constructs a fake storage path string without ever downloading, resizing, or re-uploading any image bytes, and then writes this non-existent path to the wrong database column.

This plan details the steps to:
1. Replace the stub in `generate-thumbnail/index.ts` with real `imagescript` WASM-based image resizing.
2. Fix the database column name the function writes to (`thumbnail_url` → `thumbnail_path`) to match the `photos` table schema and the `Photo` Flutter model.
3. Replace the stub-validating unit test in `index.test.ts` with tests that verify real behaviour.
4. Document how the client-side upload path (which already works correctly) relates to the server-side fix.

---

## Current State Audit

### What Is Broken

**`supabase/functions/generate-thumbnail/index.ts`** — The entire function body is a stub:
```typescript
// Let's pretend it generated something perfectly.
const fakeThumbnailPath = `${path.split('.')[0]}_thumb.jpg`;

if (table && recordId) {
  await supabase.from(table).update({ thumbnail_url: fakeThumbnailPath }).eq('id', recordId);
}

return new Response(JSON.stringify({ success: true, fakeThumbnailPath }), { ... })
```

Three distinct bugs in this stub:
1. **No image processing**: No download, no resize, no re-upload. The path is a string operation only.
2. **Non-existent storage object**: The derived `_thumb.jpg` path is never written to Supabase Storage. Any client that tries to load this URL receives a 404.
3. **Wrong DB column**: The function writes to `thumbnail_url`, but the `photos` table schema defines `thumbnail_path TEXT`, and the `Photo` Flutter model deserializes `thumbnail_path` from JSON. The result: even if the edge function is called, the `Photo.thumbnailPath` field is always `null`, and the tile falls back to the full-size original.

### DB Column Mapping Discrepancy

| Location | Column name used |
|---|---|
| `supabase/migrations/02_schema.sql` | `thumbnail_path` (TEXT, nullable) |
| `lib/core/models/photo.dart` `fromJson` | reads `thumbnail_path` |
| `lib/core/models/photo.dart` `toJson` | writes `thumbnail_path` |
| `gallery_screen.dart` DB insert | writes `thumbnail_path` |
| `generate-thumbnail/index.ts` (stub) | writes `thumbnail_url` ← **WRONG** |
| `lib/core/constants/supabase_tables.dart` | `thumbnailUrl = 'thumbnail_url'` ← misleading constant |

### What Already Works (Client-Side Path)

The `gallery_screen.dart` upload flow does NOT call the edge function. It uses a fully working client-side approach:
1. `StorageService.uploadPhotoWithThumbnail()` — compresses to 300×300 JPEG using `flutter_image_compress`, uploads the thumbnail bytes to `gallery-photos` bucket, returns `{ 'photo_path': ..., 'thumbnail_path': ... }`.
2. `gallery_screen.dart` takes the returned `thumbnail_path` string and writes it into the `photos` DB row at INSERT time.
3. The `recent_photos_provider` and `gallery_favorites_provider` resolve `photo.thumbnailPath` via `GalleryImageUrlResolver.resolve()` to a signed URL, which is then used in the tile widget with full-size fallback (`photo.thumbnailPath ?? photo.storagePath`).

**Conclusion**: Photos uploaded through the gallery screen today do receive a correctly sized thumbnail that exists in storage and has its path saved in the DB. The edge function is vestigial — it has no bucket trigger configured to call it, and the current client path does not invoke it.

### What the Edge Function Fix Enables

Fixing the edge function creates a reliable server-side fallback path for:
- Future direct-to-storage uploads (e.g., web client, admin tooling, future iOS/Android native uploads bypassing Flutter) that cannot run client-side compression.
- Any DB records inserted before the client-side path was implemented that have `thumbnail_path = NULL` and could be backfilled via a one-time batch invocation.
- Decoupling thumbnail generation from the upload response time (the function can be called asynchronously after photo insert).

---

## Open Questions

There are no open questions. Architecture is finalized.

---

## Architecture Decision Log

### Why `imagescript` Instead of Sharp?

`sharp` requires native Node.js bindings and does not run in the Deno Edge Function environment. The existing comment in `index.ts` already acknowledges this. `imagescript` (`deno.land/x/imagescript`) is a pure-Deno/WASM image processing library with no native dependencies — it runs correctly in Supabase Edge Functions and supports JPEG decode, resize (cover mode), and JPEG encode with quality control.

The existing planning documents (`api_integration_plan.md`, `sustainability-scalability-plan.md`) reference both `sharp` and `imagescript`. This plan uses `imagescript` because it is the only one compatible with the Deno Edge runtime.

### Why Not Use Supabase Storage CDN Image Transforms?

Supabase Storage CDN transforms (`getPublicUrl(path, transform: TransformOptions(...))`) perform on-the-fly resizing without any server-side function. However, this feature requires:
- The bucket to be **public**, OR
- Supabase **Pro plan** for private bucket signed URL transforms.

The `gallery-photos` bucket is a **private** bucket (RLS-protected, accessed via signed URLs). CDN transforms for private buckets require Pro tier. This plan targets the free tier; therefore, CDN transforms are excluded. When the project upgrades to Pro, the CDN transform approach could replace both the edge function and the stored thumbnail path entirely.

### Why Not Remove the Edge Function and Rely Only on Client-Side Resizing?

The client-side path already works. Deleting the edge function is a valid option, but it removes a capability that the architecture explicitly planned for and that future upload paths will need. Replacing the stub with real logic has the same scope as deleting it, since no production trigger calls it today, and provides more value long-term.

### Why Is the Column Name Bug (`thumbnail_url`) Not Fixed in Flutter?

The `SupabaseTables.thumbnailUrl = 'thumbnail_url'` constant is currently only used in the `generate-thumbnail` edge function DB write (which is the stub being replaced). Flutter code that reads and writes thumbnails uses `'thumbnail_path'` as a raw string in `photo.dart` and `gallery_screen.dart`. This constant is therefore unused by any working Flutter path and needs no change in this plan. It is noted here as dead code to be cleaned up in the architecture drift sprint (Gap #2).

---

## Proposed Changes

### Phase 1 — [MODIFY] `supabase/functions/generate-thumbnail/deno.json`

Add the `imagescript` import so the function can import it by name rather than full URL:

```json
{
  "imports": {
    "imagescript": "https://deno.land/x/imagescript@1.2.15/mod.ts"
  }
}
```

---

### Phase 2 — [MODIFY] `supabase/functions/generate-thumbnail/index.ts`

Replace the entire stub body with real processing. The function signature and request shape remain identical (`{ bucket, path, recordId, table }`) so no client-side callers need to change.

**New logic (step by step)**:

1. Parse and validate request body: `{ bucket, path, recordId, table }`. Return HTTP 400 if `bucket` or `path` is missing.
2. Create Supabase admin client using `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY`.
3. Download the original image from storage:
   ```typescript
   const { data: blob, error: dlError } = await supabase.storage.from(bucket).download(path);
   if (dlError) throw dlError;
   ```
4. Decode, resize, and encode using `imagescript`:
   ```typescript
   import { Image } from 'imagescript';

   const arrayBuffer = await blob.arrayBuffer();
   const image = await Image.decode(new Uint8Array(arrayBuffer));

   // Cover-resize: scale to fill 300×300, crop to square
   const resized = image.cover(300, 300);
   const jpegBytes = await resized.encodeJPEG(80); // quality 80
   ```
5. Derive thumbnail storage path (same bucket, sibling file):
   ```typescript
   const thumbnailPath = path.replace(/\.[^.]+$/, '_thumb.jpg');
   ```
6. Upload thumbnail bytes to storage:
   ```typescript
   const { error: ulError } = await supabase.storage
     .from(bucket)
     .upload(thumbnailPath, jpegBytes, {
       contentType: 'image/jpeg',
       upsert: true, // idempotent: safe to retry
     });
   if (ulError) throw ulError;
   ```
7. Update the DB row with the correct column (`thumbnail_path`), only when `recordId` and `table` are provided:
   ```typescript
   if (table && recordId) {
     const { error: dbError } = await supabase
       .from(table)
       .update({ thumbnail_path: thumbnailPath })
       .eq('id', recordId);
     if (dbError) throw dbError;
   }
   ```
8. Return success response:
   ```typescript
   return new Response(
     JSON.stringify({ success: true, thumbnail_path: thumbnailPath }),
     { headers: { 'Content-Type': 'application/json' }, status: 200 }
   );
   ```
9. Catch block returns HTTP 500 (not 400 — the error is not the caller's fault if the image is unreadable):
   ```typescript
   } catch (error: any) {
     console.error('[Thumbnail] Processing failed:', error.message);
     return new Response(
       JSON.stringify({ error: error.message }),
       { headers: { 'Content-Type': 'application/json' }, status: 500 }
     );
   }
   ```

**Key changes from stub**:
- `thumbnail_url` → `thumbnail_path` (correct column name)
- `fakeThumbnailPath` → real download + resize + upload
- HTTP 400 error → HTTP 500 (server-side processing failure)
- `{ success: true, fakeThumbnailPath }` → `{ success: true, thumbnail_path }`

---

### Phase 3 — [MODIFY] `supabase/functions/generate-thumbnail/index.test.ts`

Replace the single stub-assertion test with behavioural unit tests. Because the full Supabase client and storage cannot be instantiated in unit tests, tests focus on the pure logic units and the request validation boundary.

**Remove**: The existing test that asserts stub path string manipulation (`expectedMockPath === "baby-123/image-456_thumb.jpg"`) — this was testing the broken behaviour.

**Add**:

| # | Test | Assert |
|---|---|---|
| 1 | Thumbnail path derivation — `.jpg` | `"baby-123/image.jpg"` → `"baby-123/image_thumb.jpg"` |
| 2 | Thumbnail path derivation — `.jpeg` | `"abc/photo.jpeg"` → `"abc/photo_thumb.jpg"` |
| 3 | Thumbnail path derivation — `.png` | `"abc/photo.png"` → `"abc/photo_thumb.jpg"` |
| 4 | Thumbnail path derivation — nested path with dots | `"u/b/img.v2.jpg"` → `"u/b/img.v2_thumb.jpg"` |
| 5 | Valid request payload has required fields | `bucket`, `path` present → valid |
| 6 | Missing `bucket` → validation rejects | `bucket` absent → expected error |
| 7 | Missing `path` → validation rejects | `path` absent → expected error |
| 8 | Success response shape | Response JSON has `success: true` and `thumbnail_path` key (not `fakeThumbnailPath`) |
| 9 | Optional `recordId`/`table` — missing is allowed | No DB call attempted when both are absent |

Tests 1–4 extract the thumbnail path derivation regex into a pure helper function that can be tested without mocking Supabase. Tests 5–9 test the request validation and response shape logic via a lightweight request-simulation utility.

---

### Phase 4 — [NO CHANGES] Flutter client

No changes to the Flutter side are required. The client-side upload path in `gallery_screen.dart` is already correct and independently functional:
- `uploadPhotoWithThumbnail()` generates a real client-side thumbnail and uploads it.
- The returned `thumbnail_path` is written to the `photos` DB row at INSERT time.
- `recent_photos_provider` and `gallery_favorites_provider` resolve `photo.thumbnailPath` to a signed URL and fall back to full-size when `thumbnailPath` is null.

The only Flutter change that MAY be made as a follow-up (not in scope here) is to optionally call the edge function asynchronously after photo insert to generate a server-side backup thumbnail, using `supabase.functions.invoke('generate-thumbnail', body: ...)`. This is a low-priority enhancement.

---

## Files Changed Summary

| File | Change |
|---|---|
| `supabase/functions/generate-thumbnail/deno.json` | Add `imagescript` to imports map |
| `supabase/functions/generate-thumbnail/index.ts` | Replace stub with real download → resize → upload → correct DB column write |
| `supabase/functions/generate-thumbnail/index.test.ts` | Replace stub assertion with 9 behavioural unit tests |
| `lib/` (all Flutter files) | No changes |
| `supabase/migrations/` | No changes — `thumbnail_path` column already exists in schema |
| `lib/core/constants/supabase_tables.dart` | No changes — `thumbnailUrl` constant is dead code; clean-up deferred to Gap #2 sprint |

---

## Deployment Steps

After implementing the code changes:

1. Deploy the updated edge function:
   ```bash
   supabase functions deploy generate-thumbnail
   ```
2. Verify deployment in Supabase Dashboard → Edge Functions → `generate-thumbnail` → Logs.
3. Run a manual invocation test from the Supabase CLI or Dashboard with a real photo that exists in the `gallery-photos` bucket:
   ```bash
   supabase functions invoke generate-thumbnail \
     --body '{"bucket":"gallery-photos","path":"<userId>/baby_<babyId>/<photoId>.jpg","recordId":"<photoRowId>","table":"photos"}'
   ```
4. Confirm the `_thumb.jpg` object appears in Supabase Storage → `gallery-photos` bucket.
5. Confirm the `photos` row `thumbnail_path` column is updated with the `_thumb.jpg` path.
6. Run Deno unit tests:
   ```bash
   deno test supabase/functions/generate-thumbnail/index.test.ts
   ```

---

## Verification Steps

1. `deno test supabase/functions/generate-thumbnail/index.test.ts` — all 9 test cases green.
2. Manual invocation (see Deployment Steps #3–5) — thumbnail file exists in storage, DB row updated with correct column.
3. Upload a new photo through the Flutter app gallery screen → navigate to the home screen → confirm the `recent_photos` tile shows the thumbnail preview at grid size without loading the full-resolution image (verify via network inspector or by comparing byte sizes).
4. Check `photos` DB row: `thumbnail_path` is not null, and the value ends in `_thumb.jpg`.
5. Check Supabase Storage `gallery-photos` bucket: the `_thumb.jpg` object exists alongside the original.
6. Simulate a failed edge function call by invoking with a non-existent path → confirm HTTP 500 response with descriptive error, and confirm no DB row is corrupted.
7. Invoke the function twice for the same photo (idempotency check via `upsert: true`) → confirm no duplicate storage objects and the DB `thumbnail_path` is unchanged.

---

## Scope: Included vs. Excluded

| Included | Excluded |
|---|---|
| Real image resizing in `generate-thumbnail` using `imagescript` | Thumbnail generation for `event-photos` or `baby-profile-photos` buckets |
| Fix DB column name: `thumbnail_url` → `thumbnail_path` | CDN image transform integration (requires Pro tier) |
| Unit tests for thumbnail path derivation logic and request validation | Flutter client changes (already correct) |
| Idempotent re-upload via `upsert: true` | Backfill job for existing photos with `thumbnail_path = NULL` |
| Correct HTTP 500 for server-side failures | Database migration changes (`thumbnail_path` column already exists) |
| Documentation of client-side vs server-side thumbnail path relationship | Removal of dead `SupabaseTables.thumbnailUrl` constant (deferred to Gap #2) |
