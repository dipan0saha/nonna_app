import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

type JsonMap = Record<string, unknown>;
type RelationValue<T> = T | T[] | null;

interface TileConfigRequest {
  babyProfileId: string;
  userRole: string;
  screenName?: string;
}

interface TileConfigRow {
  id: string;
  screen_id: string;
  tile_definition_id: string;
  role: string;
  display_order: number;
  is_visible: boolean;
  params: JsonMap | null;
  updated_at: string;
  screens: RelationValue<{ screen_name: string }>;
  tile_definitions: RelationValue<{ tile_type: string }>;
}

interface ContentProbeResult {
  hasContent: boolean;
  probe: string;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Cache-Control": "max-age=300",
};

const ALWAYS_VISIBLE_TILE_TYPES = new Set<string>([
  "CountdownTile",
  "ChecklistTile",
  "ActivityListTile",
  "StorageUsageTile",
  "SystemAnnouncementsTile",
  // The RegistryListTile is the primary content surface of the registry screen.
  // It must always be visible so users can add items to an empty registry.
  "RegistryListTile",
]);

function parseRequestBody(body: JsonMap): TileConfigRequest {
  const babyProfileId =
    (typeof body.babyProfileId === "string" && body.babyProfileId) ||
    (typeof body.baby_profile_id === "string" && body.baby_profile_id) ||
    "";

  const userRole =
    (typeof body.userRole === "string" && body.userRole) ||
    (typeof body.user_role === "string" && body.user_role) ||
    (typeof body.role === "string" && body.role) ||
    "";

  const screenName =
    (typeof body.screenName === "string" && body.screenName) ||
    (typeof body.screen_name === "string" && body.screen_name) ||
    undefined;

  return {
    babyProfileId,
    userRole: userRole.toLowerCase(),
    screenName,
  };
}

function firstRelation<T>(value: RelationValue<T>): T | null {
  if (!value) return null;
  return Array.isArray(value) ? value[0] ?? null : value;
}

function normalizeTileType(tileType: string): string {
  return tileType.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function parseBool(value: unknown): boolean | undefined {
  if (typeof value === "boolean") return value;
  return undefined;
}

function shouldHideWhenEmpty(tileType: string, params: JsonMap | null): boolean {
  const direct = parseBool(params?.hideWhenEmpty) ?? parseBool(params?.hide_when_empty);
  if (direct !== undefined) return direct;

  const visibilityConfig = params?.visibility;
  if (visibilityConfig && typeof visibilityConfig === "object") {
    const visibility = visibilityConfig as JsonMap;
    const nested =
      parseBool(visibility.hideWhenEmpty) ?? parseBool(visibility.hide_when_empty);
    if (nested !== undefined) return nested;
  }

  return !ALWAYS_VISIBLE_TILE_TYPES.has(tileType);
}

async function hasRows(
  countPromise: Promise<{ count: number | null; error: unknown }>,
): Promise<boolean> {
  const { count, error } = await countPromise;
  if (error) {
    console.error("tile-configs probe query failed", error);
    // Fail-open to avoid hiding tiles due to probe/query failures.
    return true;
  }
  return (count ?? 0) > 0;
}

async function checkTileContent(
  supabaseClient: ReturnType<typeof createClient>,
  userId: string | null,
  babyProfileId: string,
  tileType: string,
): Promise<ContentProbeResult> {
  const type = normalizeTileType(tileType);
  const nowIso = new Date().toISOString();

  switch (type) {
    case "recentphotostile":
    case "galleryfavoritestile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("photos")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .is("deleted_at", null)
            .limit(1),
        ),
        probe: "photos",
      };

    case "upcomingeventstile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("events")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .is("deleted_at", null)
            .gte("starts_at", nowIso)
            .limit(1),
        ),
        probe: "events_upcoming",
      };

    case "activitylisttile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("activity_events")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .limit(1),
        ),
        probe: "activity_events",
      };

    case "invitesstatustile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("invitations")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .eq("status", "pending")
            .limit(1),
        ),
        probe: "invitations_pending",
      };

    case "newfollowerstile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("baby_memberships")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .eq("role", "follower")
            .is("removed_at", null)
            .limit(1),
        ),
        probe: "baby_memberships_followers",
      };

    case "notificationstile":
      if (!userId) {
        return { hasContent: true, probe: "notifications_user_unknown" };
      }
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("notifications")
            .select("id", { count: "exact", head: true })
            .eq("recipient_user_id", userId)
            .limit(1),
        ),
        probe: "notifications",
      };

    case "registryhighlightstile":
    case "registrylisttile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("registry_items")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .is("deleted_at", null)
            .limit(1),
        ),
        probe: "registry_items",
      };

    case "recentpurchasestile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("registry_purchases")
            .select("id, registry_items!inner(baby_profile_id, deleted_at)", {
              count: "exact",
              head: true,
            })
            .eq("registry_items.baby_profile_id", babyProfileId)
            .is("registry_items.deleted_at", null)
            .limit(1),
        ),
        probe: "registry_purchases",
      };

    case "rsvptaskstile":
      if (!userId) {
        return { hasContent: true, probe: "event_rsvps_user_unknown" };
      }
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("event_rsvps")
            .select("id, events!inner(baby_profile_id, deleted_at, starts_at)", {
              count: "exact",
              head: true,
            })
            .eq("user_id", userId)
            .eq("events.baby_profile_id", babyProfileId)
            .is("events.deleted_at", null)
            .gte("events.starts_at", nowIso)
            .limit(1),
        ),
        probe: "event_rsvps",
      };

    case "namesuggestionstile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("name_suggestions")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .is("deleted_at", null)
            .limit(1),
        ),
        probe: "name_suggestions",
      };

    case "predictionvotestile":
      return {
        hasContent: await hasRows(
          supabaseClient
            .from("votes")
            .select("id", { count: "exact", head: true })
            .eq("baby_profile_id", babyProfileId)
            .limit(1),
        ),
        probe: "votes",
      };

    default:
      return {
        hasContent: true,
        probe: "unsupported_tile",
      };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const startTime = performance.now();

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: {
            Authorization: authHeader,
          },
        },
      },
    );

    const body = (await req.json()) as JsonMap;
    const { babyProfileId, userRole, screenName } = parseRequestBody(body);

    if (!babyProfileId || !userRole) {
      return new Response(
        JSON.stringify({
          error: "Missing required parameters: babyProfileId, userRole",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (userRole !== "owner" && userRole !== "follower") {
      return new Response(
        JSON.stringify({
          error: "Invalid userRole. Expected 'owner' or 'follower'.",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    let currentUserId: string | null = null;
    const { data: authData } = await supabaseClient.auth.getUser();
    currentUserId = authData.user?.id ?? null;

    let tileQuery = supabaseClient
      .from("tile_configs")
      .select(
        "id, screen_id, tile_definition_id, role, display_order, is_visible, params, updated_at, screens!inner(screen_name), tile_definitions!inner(tile_type)",
      )
      .eq("role", userRole)
      .eq("is_visible", true)
      .order("display_order", { ascending: true });

    if (screenName) {
      tileQuery = tileQuery.eq("screens.screen_name", screenName);
    }

    const { data, error } = await tileQuery;
    if (error) {
      console.error("tile-configs query failed", error);
      return new Response(
        JSON.stringify({ error: "Failed to fetch tile configurations" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const tileConfigs = (data ?? []) as TileConfigRow[];
    const probeCache = new Map<string, Promise<ContentProbeResult>>();
    const filteredTiles: TileConfigRow[] = [];
    let hiddenByEmptyCount = 0;

    for (const tile of tileConfigs) {
      const tileDefinition = firstRelation(tile.tile_definitions);
      const tileType = tileDefinition?.tile_type;

      if (!tileType) {
        continue;
      }

      const hideWhenEmpty = shouldHideWhenEmpty(tileType, tile.params);
      if (!hideWhenEmpty) {
        filteredTiles.push(tile);
        continue;
      }

      const probeCacheKey = `${tileType}::${babyProfileId}::${currentUserId ?? "anon"}`;
      const probePromise =
        probeCache.get(probeCacheKey) ??
        checkTileContent(supabaseClient, currentUserId, babyProfileId, tileType);

      if (!probeCache.has(probeCacheKey)) {
        probeCache.set(probeCacheKey, probePromise);
      }

      const probeResult = await probePromise;
      if (probeResult.hasContent) {
        filteredTiles.push(tile);
      } else {
        hiddenByEmptyCount += 1;
      }
    }

    const executionTimeMs = performance.now() - startTime;

    return new Response(
      JSON.stringify({
        tiles: filteredTiles,
        metadata: {
          count: filteredTiles.length,
          role: userRole,
          screenName: screenName ?? null,
          hiddenByEmptyCount,
          probeCount: probeCache.size,
          executionTimeMs,
          cached: false,
        },
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          "X-Execution-Time": `${executionTimeMs.toFixed(2)}ms`,
        },
      },
    );
  } catch (error) {
    console.error("Unexpected tile-configs error", error);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
