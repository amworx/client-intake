# AM Worx Client Intake — Setup Guide

**Total time:** ~15 minutes  
**Accounts needed:** GitHub + Supabase (free, no credit card)

---

## 1. Fork & Enable GitHub Pages

1. Push this project to a GitHub repo (or fork the source)
2. Go to **Settings → Pages**
3. Source: **Deploy from a branch** → `main` → `/` (root) → **Save**
4. Your site will be live at `https://<username>.github.io/<repo-name>/`

---

## 2. Create Supabase Project

1. Go to https://supabase.com → **Start new project**
2. Choose a **free tier** (no credit card required)
3. Note your **Project URL** and **anon key** from **Settings → API**
4. Open **SQL Editor** → paste the contents of `docs/schema.sql` → **Run**

This creates:
- `submissions` table (stores intake forms)
- `settings` table (admin config)
- `section_groups` reference table
- `otp_codes` table (email verification)
- Storage bucket for file uploads
- All RLS security policies

---

## 3. Create Admin User

1. Go to **Authentication → Users → Add User**
2. Enter your admin email + password
3. Click **Create user**
4. Use these credentials to log in at `admin/index.html`

---

## 4. Update Configuration

Open these files and replace placeholders if needed:

### `index.html`
```js
const SUPABASE_URL = 'https://jyqjkkcenuapssmstmze.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

### `admin/index.html`
```js
const SUPABASE_URL = 'https://jyqjkkcenuapssmstmze.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

---

## 5. Push & Verify

1. Commit and push to GitHub
2. Open your GitHub Pages URL
3. Submit a test intake form
4. Check Supabase **Table Editor** → `submissions` — data should appear
5. Log in to `admin/index.html` with your admin credentials
6. The new submission should appear in real-time

---

## 6. Email Notification (Optional — Configurable From Dashboard)

The app works perfectly without email — new submissions appear in real-time in the admin dashboard.

If you want email notifications, configure them directly from the **Settings → Email Notifications** page in the admin dashboard:
1. Toggle **"Gmail SMTP Notifications"** on
2. Enter your Gmail address (default: `amworxx@gmail.com`)
3. Enter your **Gmail App Password** (requires 2FA enabled on the Gmail account)
4. Click **Save Settings**

Note: The Supabase Edge Function (`supabase/functions/send-notification/`) must be deployed and a Database Webhook created for the email to actually send. This requires Supabase CLI access. The SMTP credentials are stored in the `settings` table and read by the function at runtime.

---

## File Structure

```
client_intake/
├── index.html                ← Intake form (all features)
├── admin/
│   └── index.html            ← Admin dashboard
├── docs/
│   ├── schema.sql            ← Complete SQL (tables, RLS, seed)
│   └── setup.md              ← This file
├── supabase/
│   └── functions/
│       └── send-notification/
│           └── index.ts      ← Email notification Edge Function
└── memory/
    └── (events, lessons, patterns, decisions, playbooks)
```
