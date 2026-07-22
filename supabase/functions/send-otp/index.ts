// ============================================================
// AM Worx Intake — OTP Email Edge Function
// Called by the intake form when user clicks "Send Code"
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

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS })
  }

  try {
    if (req.method !== 'POST') {
      return jsonResponse({ error: 'Method not allowed' }, 405)
    }

    const { email, code, studio_name } = await req.json()

    if (!email || !code) {
      return jsonResponse({ error: 'email and code are required' }, 400)
    }

    const studioName = studio_name || 'AM Worx'

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Read SMTP settings from settings table
    const { data: settings, error: settingsError } = await supabase
      .from('settings')
      .select('smtp_enabled, smtp_email, smtp_password')
      .eq('id', 1)
      .single()

    if (settingsError) {
      console.error('Failed to read settings:', settingsError.message)
      return jsonResponse({ error: 'Failed to read settings' }, 500)
    }

    // If SMTP is not enabled, tell the frontend to skip
    if (!settings.smtp_enabled || !settings.smtp_password) {
      console.log(`SMTP not enabled — OTP for ${email}: ${code} (not emailed)`)
      return jsonResponse({ success: true, skipped: true, message: 'SMTP email delivery not configured. Contact the admin to set up email notifications.' }, 200)
    }

    const smtpUser = settings.smtp_email || 'amworxx@gmail.com'
    const smtpPass = settings.smtp_password

    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Inter', Arial, sans-serif; background: #f4f4f6; margin: 0; padding: 24px; }
    .card { max-width: 400px; margin: 0 auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .header { background: #0f172a; color: #fff; padding: 24px; text-align: center; }
    .header h1 { margin: 0 0 4px; font-size: 20px; }
    .body { padding: 24px; text-align: center; }
    .code { font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #0f172a; background: #f1f5f9; padding: 16px 24px; border-radius: 8px; display: inline-block; margin: 16px 0; }
    .note { color: #64748b; font-size: 14px; line-height: 1.5; }
    .footer { padding: 16px 24px; background: #f8fafc; text-align: center; font-size: 12px; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>Email Verification</h1>
    </div>
    <div class="body">
      <p class="note">Your verification code for <strong>${studioName}</strong></p>
      <div class="code">${code}</div>
      <p class="note">This code expires in 5 minutes.<br>If you didn't request this, please ignore this email.</p>
    </div>
    <div class="footer">
      <span>${studioName}</span>
    </div>
  </div>
</body>
</html>`

    // Send via Gmail SMTP using nodemailer
    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    })

    await transporter.sendMail({
      from: `"${studioName}" <${smtpUser}>`,
      to: email,
      subject: `Your verification code: ${code}`,
      html: html,
    })

    await transporter.close()
    console.log(`OTP sent to ${email}`)

    return jsonResponse({ success: true }, 200)
  } catch (error) {
    console.error('Error sending OTP:', error)
    return jsonResponse({ error: error.message }, 500)
  }
})
