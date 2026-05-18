// Supabase Edge Function: notification-trigger
// Serverless notification generation with OneSignal integration

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

interface NotificationRequest {
  recipientUserId: string;
  notificationType: string;
  title: string;
  message: string;
  data?: Record<string, any>;
  babyProfileId?: string;
  batch?: boolean;
}

interface OneSignalPayload {
  include_player_ids?: string[];
  include_external_user_ids?: string[];
  headings: { en: string };
  contents: { en: string };
  data?: Record<string, any>;
  android_channel_id?: string;
  ios_sound?: string;
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
    // Admin client uses service role key to bypass RLS when inserting
    // notifications on behalf of other users (e.g. owner notifying followers).
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    // Parse request body
    const requestData: NotificationRequest = await req.json();
    const {
      recipientUserId,
      notificationType,
      title,
      message,
      data,
      babyProfileId,
      batch = false,
    } = requestData;

    if (!recipientUserId || !notificationType || !title || !message) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Store notification in database
    // Schema: id, recipient_user_id, baby_profile_id, type, payload (jsonb), read_at, created_at
    const notificationData = {
      recipient_user_id: recipientUserId,
      baby_profile_id: babyProfileId ?? null,
      type: notificationType,
      payload: {
        title,
        message,
        ...(data || {}),
      },
    };

    const { data: savedNotification, error: dbError } = await adminClient
      .from('notifications')
      .insert(notificationData)
      .select()
      .single();

    if (dbError) {
      console.error('Error saving notification:', dbError);
      return new Response(
        JSON.stringify({ error: 'Failed to save notification' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Prepare OneSignal payload
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID');
    const oneSignalApiKey = Deno.env.get('ONESIGNAL_API_KEY');

    if (!oneSignalAppId || !oneSignalApiKey) {
      console.warn('OneSignal credentials not configured, skipping push notification');
      return new Response(
        JSON.stringify({
          success: true,
          notification: savedNotification,
          pushSent: false,
          message: 'Notification saved but push not sent (OneSignal not configured)',
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Build OneSignal payload
    const oneSignalPayload: OneSignalPayload = {
      include_external_user_ids: [recipientUserId],
      headings: { en: title },
      contents: { en: message },
      data: {
        ...data,
        notificationId: savedNotification.id,
        babyProfileId: babyProfileId,
        notificationType: notificationType,
      },
      android_channel_id: 'nonna_notifications',
      ios_sound: 'default',
    };

    // Send to OneSignal
    const oneSignalResponse = await fetch(
      'https://onesignal.com/api/v1/notifications',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Basic ${oneSignalApiKey}`,
        },
        body: JSON.stringify({
          app_id: oneSignalAppId,
          ...oneSignalPayload,
        }),
      }
    );

    const oneSignalResult = await oneSignalResponse.json();

    if (!oneSignalResponse.ok) {
      console.error('OneSignal error:', oneSignalResult);
      return new Response(
        JSON.stringify({
          success: true,
          notification: savedNotification,
          pushSent: false,
          error: 'Failed to send push notification',
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        notification: savedNotification,
        pushSent: true,
        oneSignalId: oneSignalResult.id,
        recipients: oneSignalResult.recipients || 0,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Unexpected error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(
      JSON.stringify({ error: 'Internal server error', message: errorMessage }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

/* To invoke locally:

  1. Run `supabase start`
  2. Set environment variables for OneSignal
  3. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/notification-trigger' \
    --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
    --header 'Content-Type: application/json' \
    --data '{
      "recipientUserId": "123e4567-e89b-12d3-a456-426614174000",
      "notificationType": "photo_upload",
      "title": "New Photo",
      "message": "A new photo was added to the gallery",
      "babyProfileId": "baby-123"
    }'

*/
