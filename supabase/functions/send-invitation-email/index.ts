import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' } })
  }

  try {
    const { email, inviterName, babyName, inviteUrl } = await req.json()

    if (!RESEND_API_KEY) {
      console.warn("RESEND_API_KEY not configured. Mocking email output.")
      console.log(`Mock Email sent to: ${email} -> You have been invited by ${inviterName} to follow ${babyName}! Link: ${inviteUrl}`)
      return new Response(JSON.stringify({ success: true, message: "Mock email logged." }), { headers: { "Content-Type": "application/json" } })
    }

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`
      },
      body: JSON.stringify({
        from: 'Nonna App <notifications@nonna.app>',
        to: [email],
        subject: `You're invited to follow ${babyName}!`,
        html: `<h2>Welcome to Nonna App!</h2><p>${inviterName} has invited you to follow their baby profile for ${babyName}.</p><p>Click <a href="${inviteUrl}">here</a> to join!</p>`
      })
    })

    const data = await res.json()

    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
