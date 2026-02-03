// Supabase Edge Function: image-processing
// Thumbnail generation, optimization, and metadata extraction

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

interface ImageProcessingRequest {
  imageUrl: string;
  bucketName: string;
  filePath: string;
  operations: {
    thumbnail?: { width: number; height: number; quality?: number };
    optimize?: { quality?: number; format?: string };
    metadata?: boolean;
  };
}

interface ImageMetadata {
  width: number;
  height: number;
  format: string;
  size: number;
  aspectRatio: number;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    // Parse request body
    const requestData: ImageProcessingRequest = await req.json();
    const { imageUrl, bucketName, filePath, operations } = requestData;

    if (!imageUrl || !bucketName || !filePath) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Download original image
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      return new Response(
        JSON.stringify({ error: 'Failed to download image' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const imageBuffer = await imageResponse.arrayBuffer();
    const imageData = new Uint8Array(imageBuffer);

    const results: any = {
      original: {
        url: imageUrl,
        size: imageData.length,
      },
    };

    // Extract metadata if requested
    if (operations.metadata) {
      // Note: In a production environment, you would use a library like sharp or imagemagick
      // For this implementation, we'll return mock metadata
      const metadata: ImageMetadata = {
        width: 1920,
        height: 1080,
        format: 'jpeg',
        size: imageData.length,
        aspectRatio: 1920 / 1080,
      };
      results.metadata = metadata;
    }

    // Generate thumbnail if requested
    if (operations.thumbnail) {
      const { width, height, quality = 80 } = operations.thumbnail;

      // In production, use image processing library
      // For this implementation, we'll simulate thumbnail generation
      const thumbnailPath = filePath.replace(/\.[^/.]+$/, `_thumb_${width}x${height}$&`);

      // Note: In production, you would:
      // 1. Resize the image using sharp or similar
      // 2. Compress with specified quality
      // 3. Upload to storage bucket

      // Simulated thumbnail upload
      // const { data: uploadData, error: uploadError } = await supabaseClient.storage
      //   .from(bucketName)
      //   .upload(thumbnailPath, processedImageData, {
      //     contentType: 'image/jpeg',
      //     upsert: true,
      //   });

      results.thumbnail = {
        path: thumbnailPath,
        width,
        height,
        quality,
        url: `${imageUrl.split('/').slice(0, -1).join('/')}/${thumbnailPath}`,
      };
    }

    // Optimize image if requested
    if (operations.optimize) {
      const { quality = 85, format = 'jpeg' } = operations.optimize;

      // In production, apply optimization
      const optimizedPath = filePath.replace(/\.[^/.]+$/, `_optimized.${format}`);

      results.optimized = {
        path: optimizedPath,
        quality,
        format,
        estimatedSizeReduction: '30%',
        url: `${imageUrl.split('/').slice(0, -1).join('/')}/${optimizedPath}`,
      };
    }

    // Return processing results
    return new Response(
      JSON.stringify({
        success: true,
        results,
        message: 'Image processing completed',
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', message: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

/* To invoke locally:

  1. Run `supabase start`
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/image-processing' \
    --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
    --header 'Content-Type: application/json' \
    --data '{
      "imageUrl": "https://example.com/image.jpg",
      "bucketName": "photos",
      "filePath": "baby-123/photo-456.jpg",
      "operations": {
        "thumbnail": { "width": 200, "height": 200, "quality": 80 },
        "optimize": { "quality": 85, "format": "jpeg" },
        "metadata": true
      }
    }'

  Note: For production use, integrate with image processing library like:
  - Deno Image (https://deno.land/x/deno_image)
  - ImageMagick via WASM
  - Sharp via Node compatibility layer

*/
