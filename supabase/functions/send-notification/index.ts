// ============================================================
// AM Worx Intake — Email Notification Edge Function
// Triggered by Database Webhook on submissions INSERT
//
// Reads SMTP settings from the `settings` table (configured
// via admin dashboard Settings → Email Notifications).
// If SMTP is not enabled, silently skips — no error.
//
// Setup:
//   1. Deploy this function: `supabase functions deploy send-notification`
//   2. Create Database Webhook: Supabase Dashboard → Database → Webhooks
//      - Table: submissions, Event: INSERT
//      - URL: your Edge Function URL
//      - HTTP method: POST
//   3. Admin configures SMTP from dashboard Settings page (no env vars needed)
// ============================================================

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface Submission {
  id: number
  created_at: string
  full_name: string
  business_name: string | null
  client_email: string
  client_phone: string | null
  website_type: string | null
  estimated_total: number | null
  status: string
}

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE'
  table: string
  record: Submission
  schema: 'public'
  old_record: Submission | null
}

function buildEmailHtml(record: Submission, studioName: string): string {
  const date = record.created_at
    ? new Date(record.created_at).toLocaleDateString('en-US', {
        year: 'numeric', month: 'long', day: 'numeric',
        hour: '2-digit', minute: '2-digit'
      })
    : 'N/A'

  const estimate = record.estimated_total
    ? `$${record.estimated_total.toLocaleString('en-US', { minimumFractionDigits: 2 })}`
    : 'Not calculated'

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Inter', Arial, sans-serif; background: #f4f4f6; margin: 0; padding: 24px; }
    .card { max-width: 560px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .header { background: #0f172a; color: #fff; padding: 24px; }
    .header h1 { margin: 0 0 4px; font-size: 20px; }
    .header p { margin: 0; opacity: 0.7; font-size: 14px; }
    .body { padding: 24px; }
    .field { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
    .field:last-child { border-bottom: none; }
    .label { color: #64748b; }
    .value { color: #0f172a; font-weight: 500; }
    .badge { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; background: #3b82f6; color: #fff; }
    .footer { padding: 16px 24px; background: #f8fafc; text-align: center; font-size: 12px; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>New Intake Submission</h1>
      <p>${date}</p>
    </div>
    <div class="body">
      <div class="field">
        <span class="label">Name</span>
        <span class="value">${record.full_name}</span>
      </div>
      ${record.business_name ? `
      <div class="field">
        <span class="label">Business</span>
        <span class="value">${record.business_name}</span>
      </div>` : ''}
      <div class="field">
        <span class="label">Email</span>
        <span class="value"><a href="mailto:${record.client_email}">${record.client_email}</a></span>
      </div>
      ${record.client_phone ? `
      <div class="field">
        <span class="label">Phone</span>
        <span class="value">${record.client_phone}</span>
      </div>` : ''}
      ${record.website_type ? `
      <div class="field">
        <span class="label">Website Type</span>
        <span class="value">${record.website_type}</span>
      </div>` : ''}
      <div class="field">
        <span class="label">Estimate</span>
        <span class="value">${estimate}</span>
      </div>
      <div class="field">
        <span class="label">Status</span>
        <span class="value"><span class="badge">${record.status}</span></span>
      </div>
    </div>
    <div class="footer">
      <span>${studioName}</span>
    </div>
  </div>
</body>
</html>`
}

serve(async (req: Request) => {
  try {
    // Verify request method
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 })
    }

    // Parse webhook payload
    const payload: WebhookPayload = await req.json()
    
    // Only handle INSERT events
    if (payload.type !== 'INSERT') {
      return new Response('Ignored: not an INSERT event', { status: 200 })
    }

    const record = payload.record

    // Initialize Supabase client with Service Role Key
    // (available automatically in Supabase Edge Functions)
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Read SMTP settings from the settings table
    const { data: settings, error: settingsError } = await supabase
      .from('settings')
      .select('smtp_enabled, smtp_email, smtp_password, studio_name, studio_email')
      .eq('id', 1)
      .single()

    if (settingsError) {
      console.error('Failed to read settings:', settingsError.message)
      return new Response(JSON.stringify({ error: 'Failed to read settings' }), { status: 500 })
    }

    // If SMTP is not enabled, silently skip
    if (!settings.smtp_enabled) {
      console.log('SMTP not enabled — skipping email for submission #' + record.id)
      return new Response(JSON.stringify({ skipped: true, reason: 'SMTP not enabled' }), { status: 200 })
    }

    // Validate we have SMTP credentials
    const smtpUser = settings.smtp_email || settings.studio_email
    const smtpPass = settings.smtp_password
    const notifyEmail = settings.studio_email || 'amworxx@gmail.com'
    const studioName = settings.studio_name || 'AM Worx'

    if (!smtpPass) {
      console.error('SMTP enabled but no password configured')
      return new Response(JSON.stringify({ error: 'SMTP password not configured' }), { status: 200 })
    }

    // Build email
    const html = buildEmailHtml(record, studioName)
    const subject = `New Intake: ${record.full_name}${record.business_name ? ` — ${record.business_name}` : ''}`

    // Send via Gmail SMTP
    const { SmtpClient } = await import('https://deno.land/x/smtp@v0.7.0/mod.ts')

    const client = new SmtpClient()
    await client.connectTLS({
      hostname: 'smtp.gmail.com',
      port: 465,
      username: smtpUser,
      password: smtpPass,
    })

    await client.send({
      from: `"${studioName} Intake" <${smtpUser}>`,
      to: notifyEmail,
      subject: subject,
      html: html,
    })

    await client.close()

    console.log(`Email sent successfully for submission #${record.id}`)

    return new Response(JSON.stringify({ success: true, submission_id: record.id }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('Error sending email:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
