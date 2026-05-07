import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') ?? 'notifications@nonna.app';
const SENDGRID_API_KEY = Deno.env.get('SENDGRID_API_KEY');
const SENDGRID_FROM_EMAIL = Deno.env.get('SENDGRID_FROM_EMAIL') ?? 'notifications@nonna.app';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, inviterName, babyName, inviteUrl } = await req.json()

    if (!email || !inviterName || !babyName || !inviteUrl) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: email, inviterName, babyName, inviteUrl' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        },
      )
    }

    const subject = `You're invited to follow ${babyName}!`
    const html = `<h2>Welcome to Nonna App!</h2><p>${inviterName} has invited you to follow their baby profile for ${babyName}.</p><p>Click <a href="${inviteUrl}">here</a> to join!</p>`

    if (RESEND_API_KEY) {
      const resendRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${RESEND_API_KEY}`
        },
        body: JSON.stringify({
          from: `Nonna App <${RESEND_FROM_EMAIL}>`,
          to: [email],
          subject,
          html,
        })
      })

      const data = await resendRes.json()
      if (!resendRes.ok) {
        return new Response(
          JSON.stringify({ error: data?.message ?? 'Failed to send invitation email' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: resendRes.status,
          },
        )
      }

      return new Response(JSON.stringify({ id: data?.id, success: true, provider: 'resend' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    if (SENDGRID_API_KEY) {
      const sendgridRes = await fetch('https://api.sendgrid.com/v3/mail/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SENDGRID_API_KEY}`
        },
        body: JSON.stringify({
          personalizations: [
            {
              to: [{ email }],
            },
          ],
          from: {
            email: SENDGRID_FROM_EMAIL,
            name: 'Nonna App',
          },
          subject,
          content: [
            {
              type: 'text/html',
              value: html,
            },
          ],
        }),
      })

      if (!sendgridRes.ok) {
        const errorText = await sendgridRes.text()
        return new Response(
          JSON.stringify({ error: errorText || 'Failed to send invitation email' }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: sendgridRes.status,
          },
        )
      }

      return new Response(JSON.stringify({ success: true, provider: 'sendgrid' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    console.error('No email provider secret configured for send-invitation-email')
    return new Response(
      JSON.stringify({ error: 'Email provider is not configured' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
