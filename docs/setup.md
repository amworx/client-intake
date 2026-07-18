# AM Worx Client Intake — Setup Guide

**Total time:** ~15 minutes  
**Accounts needed:** GitHub + Supabase (free, no credit card)

---

## 1. Fork & Enable GitHub Pages

1. Push this project to a GitHub repo (or fork the source)
2. Go to **Settings → Pages**
3. Source: **Deploy from a branch** → `main` → `/` (root) → **Save**
4. Wait ~2 minutes — your site will be live at `https://<username>.github.io/<repo-name>/`
5. A `.nojekyll` file is included — required for GitHub Pages to serve files in subdirectories

---

## 2. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com) → **Start new project**
2. Choose a **free tier** (no credit card required)
3. Note your **Project URL** and **anon key** from **Project Settings → API**
4. Open **SQL Editor** → paste the contents of `docs/schema.sql` → **Run**

This creates:
- `submissions` table (stores intake forms)
- `settings` table (admin config)
- `section_groups` reference table
- `otp_codes` table (email verification)
- Storage bucket for file uploads
- All RLS security policies

> **Tip:** The database password you set during project creation is needed later for CLI operations.

---

## 3. Create Admin User

1. Go to **Authentication → Users → Add User**
2. Enter your admin email + password
3. Click **Create user**
4. Use these credentials to log in at `admin/index.html`

---

## 4. Update Configuration

Open these files and update the Supabase credentials to match YOUR project:

### `index.html`
```js
const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co'
const SUPABASE_ANON_KEY = 'your-anon-key-here'
```

### `admin/index.html`
```js
const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co'
const SUPABASE_ANON_KEY = 'your-anon-key-here'
const APP_NAME = 'Your Studio Name';
const FORM_URL = 'https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/';
```

### Update seed data (optional but recommended)
Run this in the Supabase SQL Editor to set your form URL:

```sql
update public.settings
set form_url = 'https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/'
where id = 1;
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

## 6. Edge Function: Email Notifications (Optional)

The app works perfectly without email — new submissions appear in real-time in the admin dashboard.

If you want email notifications:

### A. Get a Supabase Access Token
1. Go to [Supabase Dashboard](https://supabase.com/dashboard/account/tokens)
2. Click **Create token**
3. Give it a name (e.g., "CLI deploy")
4. Copy the generated token (starts with `sbp_`)

### B. Deploy the Edge Function
```bash
# Install Supabase CLI (one-time)
npm install -g supabase

# Log in with your access token
supabase login --token sbp_YOUR_TOKEN_HERE

# Navigate to the project directory
cd client-intake

# Link to your Supabase project
supabase link --project-ref YOUR_PROJECT_REF --password YOUR_DB_PASSWORD

# Deploy the notification function
supabase functions deploy send-notification
```

### C. Create a Database Webhook
1. Go to **Supabase Dashboard → Database → Webhooks**
2. Click **Create a webhook**
3. Fill in:
   - **Name:** `submissions-notification`
   - **Table:** `submissions`
   - **Event:** `INSERT`
   - **URL:** `https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-notification`
   - **HTTP method:** `POST`
4. Save the webhook

### D. Configure from Admin Dashboard
1. Log in to the admin dashboard
2. Go to **Settings → Email Notifications**
3. Toggle **"Gmail SMTP Notifications"** on
4. Enter your Gmail address and **Gmail App Password** (requires 2FA)
5. Click **Save Settings**

---

## 7. OTP Email Verification

The intake form includes email verification via OTP (6-digit code). The code is stored in the `otp_codes` table.

**Current behavior (for testing):**
- The OTP code is logged to the browser console
- Admin can also check the `otp_codes` table in Supabase Dashboard to find codes

**For production (recommended):**
Deploy a `send-otp` Edge Function that emails the code to the client. Follow the same steps as Section 6, but create a separate function file at `supabase/functions/send-otp/index.ts`.

---

## File Structure

```
client-intake/
├── index.html                   ← Intake form (all features)
├── admin/
│   └── index.html               ← Admin dashboard
├── docs/
│   ├── schema.sql               ← Complete SQL (tables, RLS, seed)
│   └── setup.md                 ← This file
├── supabase/
│   └── functions/
│       └── send-notification/
│           └── index.ts         ← Optional email Edge Function
├── memory/                      ← Project knowledge
├── .gitignore
├── .nojekyll                    ← Required for GitHub Pages
├── AGENTS.md
└── README.md                    ← Full project documentation
```

---

## Troubleshooting

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| Blank page on GitHub Pages | No `.nojekyll` file | Add `.nojekyll` to repo root |
| Auth login fails | Admin user not created | Add user via Supabase Auth → Users |
| File upload fails | Storage bucket not created | Run `schema.sql` or create `submissions` bucket manually |
| Form data not saving | RLS policies missing | Run `schema.sql` to create policies |
| 401 errors | Wrong anon key | Copy correct anon key from Supabase → Settings → API |
