import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.2"
import { Image } from "imagescript"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Derives the thumbnail storage path from an original file path.
 * Replaces only the final extension (after the last dot) with `_thumb.jpg`.
 * Examples:
 *   "user/baby/img.jpg"    → "user/baby/img_thumb.jpg"
 *   "user/baby/img.png"    → "user/baby/img_thumb.jpg"
 *   "user/baby/img.v2.jpg" → "user/baby/img.v2_thumb.jpg"
 */
function deriveThumbnailPath(originalPath: string): string {
  return originalPath.replace(/\.[^.]+$/, '_thumb.jpg')
}

/**
 * Validates that the required fields `bucket` and `path` are present in the request body.
 */
function validateRequest(body: Record<string, unknown>): { valid: boolean; error?: string } {
  if (!body.bucket) return { valid: false, error: 'Missing required field: bucket' }
  if (!body.path) return { valid: false, error: 'Missing required field: path' }
  return { valid: true }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { bucket, path, recordId, table } = body

    // Validate required fields
    const validation = validateRequest(body)
    if (!validation.valid) {
      return new Response(
        JSON.stringify({ error: validation.error }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    console.log(`[Thumbnail] Processing: bucket=${bucket}, path=${path}`)

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // 1. Download the original image from storage
    const { data: blob, error: dlError } = await supabase.storage.from(bucket).download(path)
    if (dlError) throw dlError

    // 2. Decode, cover-resize to 300×300, and encode as JPEG (quality 80)
    const arrayBuffer = await blob.arrayBuffer()
    const decoded = await Image.decode(new Uint8Array(arrayBuffer))
    // imagescript returns Image | GIF; for gallery photos (JPEG/PNG) it is always Image
    const image = decoded instanceof Image ? decoded : (decoded as any).frames[0] as Image
    const resized = image.cover(300, 300)
    const jpegBytes = await resized.encodeJPEG(80)

    // 3. Derive thumbnail storage path (sibling file in the same bucket folder)
    const thumbnailPath = deriveThumbnailPath(path)

    // 4. Upload thumbnail bytes to storage — upsert makes the call idempotent
    const { error: ulError } = await supabase.storage
      .from(bucket)
      .upload(thumbnailPath, jpegBytes, {
        contentType: 'image/jpeg',
        upsert: true,
      })
    if (ulError) throw ulError

    console.log(`[Thumbnail] Uploaded thumbnail to: ${thumbnailPath}`)

    // 5. Update DB row with the correct column name (thumbnail_path, not thumbnail_url)
    if (table && recordId) {
      const { error: dbError } = await supabase
        .from(table)
        .update({ thumbnail_path: thumbnailPath })
        .eq('id', recordId)
      if (dbError) throw dbError
      console.log(`[Thumbnail] Updated ${table}.thumbnail_path for id=${recordId}`)
    }

    return new Response(
      JSON.stringify({ success: true, thumbnail_path: thumbnailPath }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 },
    )
  } catch (error: any) {
    // 500 — the error is server-side processing failure, not a malformed caller request
    console.error('[Thumbnail] Processing failed:', error.message)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})

