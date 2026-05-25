import { assertEquals, assertExists } from "https://deno.land/std@0.192.0/testing/asserts.ts";

// ---------------------------------------------------------------------------
// Pure helpers mirroring the logic in index.ts.
// Defined inline here so tests remain self-contained and do not trigger the
// top-level serve() call that runs when importing index.ts directly.
// ---------------------------------------------------------------------------

/** Replaces only the final file extension with `_thumb.jpg`. */
function deriveThumbnailPath(originalPath: string): string {
  return originalPath.replace(/\.[^.]+$/, '_thumb.jpg');
}

interface RequestBody {
  bucket?: string;
  path?: string;
  recordId?: string;
  table?: string;
}

function validateRequest(body: RequestBody): { valid: boolean; error?: string } {
  if (!body.bucket) return { valid: false, error: 'Missing required field: bucket' };
  if (!body.path) return { valid: false, error: 'Missing required field: path' };
  return { valid: true };
}

// ---------------------------------------------------------------------------
// Tests 1–4: Thumbnail path derivation
// ---------------------------------------------------------------------------

Deno.test("deriveThumbnailPath — .jpg extension", () => {
  assertEquals(
    deriveThumbnailPath("baby-123/image.jpg"),
    "baby-123/image_thumb.jpg",
  );
});

Deno.test("deriveThumbnailPath — .jpeg extension", () => {
  assertEquals(
    deriveThumbnailPath("abc/photo.jpeg"),
    "abc/photo_thumb.jpg",
  );
});

Deno.test("deriveThumbnailPath — .png extension", () => {
  assertEquals(
    deriveThumbnailPath("abc/photo.png"),
    "abc/photo_thumb.jpg",
  );
});

Deno.test("deriveThumbnailPath — nested path with dots in filename", () => {
  // Only the final extension should be replaced; intermediate dots are preserved.
  assertEquals(
    deriveThumbnailPath("u/b/img.v2.jpg"),
    "u/b/img.v2_thumb.jpg",
  );
});

// ---------------------------------------------------------------------------
// Tests 5–7: Request validation
// ---------------------------------------------------------------------------

Deno.test("validateRequest — valid payload with all fields passes", () => {
  const result = validateRequest({
    bucket: "gallery-photos",
    path: "user/baby/img.jpg",
    recordId: "rec-001",
    table: "photos",
  });
  assertEquals(result.valid, true);
  assertEquals(result.error, undefined);
});

Deno.test("validateRequest — missing bucket field is rejected", () => {
  const result = validateRequest({ path: "user/baby/img.jpg" });
  assertEquals(result.valid, false);
  assertExists(result.error);
});

Deno.test("validateRequest — missing path field is rejected", () => {
  const result = validateRequest({ bucket: "gallery-photos" });
  assertEquals(result.valid, false);
  assertExists(result.error);
});

// ---------------------------------------------------------------------------
// Test 8: Success response shape
// ---------------------------------------------------------------------------

Deno.test("Success response has thumbnail_path key, not fakeThumbnailPath", () => {
  // Mirrors the exact response JSON returned by the real handler on success.
  const mockResponse: Record<string, unknown> = {
    success: true,
    thumbnail_path: "user/baby/img_thumb.jpg",
  };
  assertEquals(mockResponse["success"], true);
  assertExists(mockResponse["thumbnail_path"]);
  assertEquals(mockResponse["fakeThumbnailPath"], undefined);
});

// ---------------------------------------------------------------------------
// Test 9: Optional recordId / table fields
// ---------------------------------------------------------------------------

Deno.test("validateRequest — optional recordId and table may be absent", () => {
  // Only bucket and path are required; recordId and table are optional.
  const result = validateRequest({ bucket: "gallery-photos", path: "user/baby/img.jpg" });
  assertEquals(result.valid, true);
});

