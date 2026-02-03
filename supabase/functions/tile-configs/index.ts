// Supabase Edge Function: tile-configs
// Dynamic tile configuration generation with role-based filtering

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

interface TileConfigRequest {
  babyProfileId: string;
  userRole: string;
  screenName?: string;
}

interface TileConfig {
  id: string;
  tileType: string;
  position: number;
  isVisible: boolean;
  isLocked: boolean;
  params: Record<string, any>;
  screenName: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'max-age=300', // Cache for 5 minutes
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const startTime = performance.now();

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Parse request body
    const requestData: TileConfigRequest = await req.json();
    const { babyProfileId, userRole, screenName } = requestData;

    if (!babyProfileId || !userRole) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters: babyProfileId, userRole' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Build query for tile configs
    let query = supabaseClient
      .from('tile_configs')
      .select('*')
      .eq('baby_profile_id', babyProfileId)
      .eq('is_visible', true)
      .order('position', { ascending: true });

    // Filter by screen name if provided
    if (screenName) {
      query = query.eq('screen_name', screenName);
    }

    // Fetch tile configurations
    const { data: tileConfigs, error: fetchError } = await query;

    if (fetchError) {
      console.error('Error fetching tile configs:', fetchError);
      return new Response(
        JSON.stringify({ error: 'Failed to fetch tile configurations' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Apply role-based filtering
    const filteredConfigs = (tileConfigs || []).filter((config: TileConfig) => {
      // Owner sees all tiles
      if (userRole === 'owner') {
        return true;
      }

      // Collaborators see most tiles except sensitive ones
      if (userRole === 'collaborator') {
        const restrictedTiles = ['registry_highlights', 'registry_deals', 'storage_usage'];
        return !restrictedTiles.includes(config.tileType);
      }

      // Viewers see limited tiles
      if (userRole === 'viewer') {
        const viewerAllowedTiles = [
          'upcoming_events',
          'recent_photos',
          'due_date_countdown',
          'gallery_favorites',
          'system_announcements',
        ];
        return viewerAllowedTiles.includes(config.tileType);
      }

      return false;
    });

    const endTime = performance.now();
    const executionTime = endTime - startTime;

    // Log performance (should be <100ms)
    console.log(`Tile config generation completed in ${executionTime.toFixed(2)}ms`);

    // Return filtered configurations
    return new Response(
      JSON.stringify({
        tiles: filteredConfigs,
        metadata: {
          count: filteredConfigs.length,
          role: userRole,
          executionTimeMs: executionTime,
          cached: false,
        },
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
          'X-Execution-Time': `${executionTime.toFixed(2)}ms`,
        },
      }
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/tile-configs' \
    --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
    --header 'Content-Type: application/json' \
    --data '{
      "babyProfileId": "123e4567-e89b-12d3-a456-426614174000",
      "userRole": "owner",
      "screenName": "home"
    }'

*/
