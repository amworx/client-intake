// ============================================================
// AM Worx Intake — Email Notification Edge Function
// Called by the intake form after a successful submission.
// Sends two emails:
//   1. Admin notification with full submission details
//   2. Client confirmation with a summary
//
// Uses npm:nodemailer (compatible with Deno 2) to send via
// Gmail SMTP. SMTP credentials are stored in the `settings`
// table (configured via admin dashboard → Email Notifications).
// ============================================================

import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import nodemailer from 'npm:nodemailer@6.9.14'

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'apikey, content-type, authorization',
  'Access-Control-Max-Age': '86400',
}

function jsonResponse(body: Record<string, unknown>, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  })
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

function buildAdminHtml(data: Record<string, unknown>): string {
  const pricingMode = data.pricing_mode === 'bundle' ? 'Managed Bundle' : 'Per-Item Pricing'
  const bundleInfo = data.bundle_tier
    ? `<div class="field"><span class="label">Bundle Tier</span><span class="value">${escapeHtml(String(data.bundle_tier))}</span></div>`
    : ''
  const phoneHtml = data.client_phone
    ? `<div class="field"><span class="label">Phone</span><span class="value"><a href="tel:${escapeHtml(String(data.client_phone))}">${escapeHtml(String(data.client_phone))}</a></span></div>`
    : ''
  const total = data.estimated_total
    ? `$${Number(data.estimated_total).toLocaleString('en-US', { minimumFractionDigits: 2 })}`
    : 'Not calculated'

  let priceItemsHtml = ''
  if (Array.isArray(data.price_breakdown)) {
    priceItemsHtml = data.price_breakdown.map((item: Record<string, unknown>) =>
      `<div class="field"><span class="label">${escapeHtml(String(item.label || ''))}</span><span class="value">$${Number(item.lineTotal || 0).toLocaleString()}</span></div>`
    ).join('')
  }

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Inter', Arial, sans-serif; background: #f4f4f6; margin: 0; padding: 24px; }
    .card { max-width: 600px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .header { background: #0f172a; color: #fff; padding: 24px; }
    .header h1 { margin: 0 0 4px; font-size: 20px; }
    .header p { margin: 0; opacity: 0.7; font-size: 14px; }
    .body { padding: 24px; }
    .section-title { font-size: 14px; font-weight: 700; color: #0f172a; margin: 16px 0 8px; padding-bottom: 4px; border-bottom: 1px solid #e2e8f0; }
    .field { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f1f5f9; font-size: 13px; }
    .field:last-child { border-bottom: none; }
    .label { color: #64748b; flex-shrink: 0; }
    .value { color: #0f172a; font-weight: 500; text-align: right; }
    .badge { display: inline-block; padding: 2px 10px; border-radius: 999px; font-size: 12px; font-weight: 600; }
    .badge-bundle { background: #dbeafe; color: #1e40af; }
    .badge-item { background: #d1fae5; color: #065f46; }
    .footer { padding: 16px 24px; background: #f8fafc; text-align: center; font-size: 12px; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>New Intake Submission</h1>
      <p>${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}</p>
    </div>
    <div class="body">
      <div class="section-title">Contact Information</div>
      <div class="field"><span class="label">Name</span><span class="value">${escapeHtml(String(data.full_name || ''))}</span></div>
      ${data.business_name ? `<div class="field"><span class="label">Business</span><span class="value">${escapeHtml(String(data.business_name))}</span></div>` : ''}
      <div class="field"><span class="label">Email</span><span class="value"><a href="mailto:${escapeHtml(String(data.client_email))}">${escapeHtml(String(data.client_email))}</a></span></div>
      ${phoneHtml}

      <div class="section-title">Pricing</div>
      <div class="field">
        <span class="label">Mode</span>
        <span class="value"><span class="badge ${pricingMode === 'Managed Bundle' ? 'badge-bundle' : 'badge-item'}">${pricingMode}</span></span>
      </div>
      ${bundleInfo}
      ${priceItemsHtml}
      <div class="field" style="font-weight:700;border-top:2px solid #0f172a;padding-top:8px;margin-top:4px">
        <span class="label">Estimated Total</span>
        <span class="value">${total}</span>
      </div>

      ${data.primary_goal ? `<div class="section-title">Project Details</div>
      <div class="field"><span class="label">Primary Goal</span><span class="value">${escapeHtml(String(data.primary_goal))}</span></div>` : ''}
      ${data.website_type ? `<div class="field"><span class="label">Website Type</span><span class="value">${escapeHtml(String(data.website_type))}</span></div>` : ''}
      ${data.timeline ? `<div class="field"><span class="label">Timeline</span><span class="value">${escapeHtml(String(data.timeline))}</span></div>` : ''}
    </div>
    <div class="footer">
      <span>AM Worx — Client Intake System</span>
    </div>
  </div>
</body>
</html>`
}

function buildClientHtml(data: Record<string, unknown>): string {
  const studioName = String(data._studio_name || 'AM Worx')
  const total = data.estimated_total
    ? `$${Number(data.estimated_total).toLocaleString('en-US', { minimumFractionDigits: 2 })}`
    : 'Not calculated'

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Inter', Arial, sans-serif; background: #f4f4f6; margin: 0; padding: 24px; }
    .card { max-width: 520px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .header { background: #0f172a; color: #fff; padding: 24px; text-align: center; }
    .header h1 { margin: 0; font-size: 22px; }
    .body { padding: 24px; text-align: center; }
    .check { width: 56px; height: 56px; border-radius: 50%; background: #d1fae5; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; font-size: 28px; color: #065f46; }
    .greeting { font-size: 16px; font-weight: 600; color: #0f172a; margin-bottom: 8px; }
    .message { font-size: 14px; color: #64748b; line-height: 1.6; margin-bottom: 20px; }
    .detail-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; text-align: left; margin-bottom: 20px; }
    .detail-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 13px; border-bottom: 1px solid #f1f5f9; }
    .detail-row:last-child { border-bottom: none; }
    .dr-label { color: #64748b; }
    .dr-value { color: #0f172a; font-weight: 500; }
    .footer { padding: 16px 24px; background: #f8fafc; text-align: center; font-size: 12px; color: #94a3b8; }
    .footer a { color: #6366f1; text-decoration: none; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>We received your request!</h1>
    </div>
    <div class="body">
      <div class="check">&#10003;</div>
      <div class="greeting">Thanks, ${escapeHtml(String(data.full_name || ''))}!</div>
      <div class="message">
        Your website project request has been submitted to <strong>${escapeHtml(studioName)}</strong>.
        We'll review your information and get back to you within 1&ndash;2 business days.
      </div>
      <div class="detail-box">
        <div class="detail-row">
          <span class="dr-label">Submission</span>
          <span class="dr-value">${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</span>
        </div>
        <div class="detail-row">
          <span class="dr-label">Estimated Total</span>
          <span class="dr-value">${total}</span>
        </div>
        ${data.client_phone ? `<div class="detail-row">
          <span class="dr-label">Contact</span>
          <span class="dr-value">${escapeHtml(String(data.client_email))}</span>
        </div>` : ''}
      </div>
      <div class="message" style="font-size:13px">
        Have questions? Reply to this email or contact us directly.
      </div>
    </div>
    <div class="footer">
      <span>${escapeHtml(studioName)}</span>
    </div>
  </div>
</body>
</html>`
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS })
  }

  try {
    if (req.method !== 'POST') {
      return jsonResponse({ error: 'Method not allowed' }, 405)
    }

    const { submission, type } = await req.json()

    if (!submission || !submission.client_email) {
      return jsonResponse({ error: 'submission with client_email is required' }, 400)
    }

    // Initialize Supabase client with Service Role Key
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
      return jsonResponse({ error: 'Failed to read settings' }, 500)
    }

    // If SMTP is not enabled, silently skip
    if (!settings.smtp_enabled || !settings.smtp_password) {
      console.log('SMTP not enabled — skipping notification email')
      return jsonResponse({ success: true, skipped: true, reason: 'SMTP not enabled' }, 200)
    }

    const smtpUser = settings.smtp_email || settings.studio_email || 'amworxx@gmail.com'
    const smtpPass = settings.smtp_password
    const notifyEmail = settings.studio_email || 'amworxx@gmail.com'
    const studioName = settings.studio_name || 'AM Worx'

    // Attach studio name to submission data for email templates
    const submissionData = { ...submission, _studio_name: studioName }

    // Create nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    })

    const results: string[] = []

    // 1. Send admin notification
    const adminHtml = buildAdminHtml(submissionData)
    const adminSubject = `New Intake: ${submissionData.full_name || 'Unknown'}${submissionData.business_name ? ` — ${submissionData.business_name}` : ''}`

    try {
      await transporter.sendMail({
        from: `"${studioName} Intake" <${smtpUser}>`,
        to: notifyEmail,
        subject: adminSubject,
        html: adminHtml,
      })
      results.push('admin')
      console.log(`Admin notification sent to ${notifyEmail}`)
    } catch (adminErr) {
      console.error('Failed to send admin notification:', adminErr)
    }

    // 2. Send client confirmation
    const clientHtml = buildClientHtml(submissionData)
    const clientSubject = `We received your request — ${studioName}`

    try {
      await transporter.sendMail({
        from: `"${studioName}" <${smtpUser}>`,
        to: submissionData.client_email,
        subject: clientSubject,
        html: clientHtml,
      })
      results.push('client')
      console.log(`Client confirmation sent to ${submissionData.client_email}`)
    } catch (clientErr) {
      console.error('Failed to send client confirmation:', clientErr)
    }

    await transporter.close()

    return jsonResponse({
      success: true,
      sent: results,
    }, 200)
  } catch (error) {
    console.error('Error sending notification:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
