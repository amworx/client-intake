# AM Worx Client Intake

A client intake form + admin dashboard for **AM Worx** web design studio. Clients fill out a 7-section survey, get a live price estimate, upload files, and submit — all data goes straight to Supabase. The admin dashboard lets you view and manage submissions in real-time.

**Live demo:** [https://amworx.github.io/client-intake/](https://amworx.github.io/client-intake/)

---

## Features

### Intake Form (`index.html`)
- **7 survey sections** — Hosting/Domain, Business Info, Website Type & Pages, Features, Design & Content, Timeline & Maintenance, Budget
- **Live price calculator** — updates as the client fills out the form
- **Price breakdown modal** — detailed line-item cost breakdown
- **Progress tracker** — auto-highlights the current section as client scrolls
- **File upload** — drag-and-drop, multiple files, 25 MB limit, preview + remove
- **OTP email verification** — client verifies their email with a 6-digit code
- **PDF generation** — auto-generates a summary PDF on submit
- **Dark mode** — toggle saved to localStorage
- **Draft auto-save** — 800ms debounce, restore prompt on return
- **Dynamic overrides** — prices and section options load from Supabase

### Admin Dashboard (`admin/index.html`)
- **Auth** — email/password login via Supabase Auth
- **Dashboard** — 4 stat cards (Total, New, Reviewed, Est. Revenue) + recent submissions
- **Submissions** — full table with search/filter, detail slide-in panel
- **CRUD** — toggle status (New / Reviewed), delete with confirmation
- **Settings** — general fields, pricing management (55 steppers), 7 section editors with custom options, **Gmail SMTP toggle**
- **Real-time** — new submissions appear instantly via Supabase Realtime
- **Dark mode** — toggle with persistence
- **Toast notifications** — success/error feedback

### Backend (Supabase)
- **PostgreSQL** — 4 tables (submissions, settings, section_groups, otp_codes)
- **Storage** — file upload bucket with RLS policies
- **Auth** — admin login via email/password
- **Realtime** — new submissions push to dashboard
- **Edge Function** — optional Gmail SMTP notification (configurable from dashboard)

---

## Requirements for New Users

Before setting up this project, you'll need:

| Requirement | Free? | Details |
|-------------|-------|---------|
| **GitHub account** | Yes | For hosting the static files via GitHub Pages |
| **Supabase account** | Yes | For database, auth, storage, real-time (no credit card needed) |
| **Gmail account** | Yes | Only needed if you want email notifications (with 2FA + App Password) |

**Zero email setup:** The app works without any email configuration — new submissions appear in real-time in the admin dashboard.

---

## Setup Guide

### Step 1: Fork the repo
Click the "Fork" button on GitHub to create your own copy.

### Step 2: Create a Supabase project
1. Go to [supabase.com](https://supabase.com) → **Start new project**
2. Choose a **free tier** (no credit card required)
3. Save your **Project URL** and **anon key** from **Project Settings → API**

### Step 3: Run the SQL schema
1. In your Supabase dashboard, go to **SQL Editor**
2. Open [`docs/schema.sql`](docs/schema.sql) from this repo, copy the contents
3. Paste into the SQL Editor → **Run**
4. This creates all 4 tables, RLS policies, storage bucket, and seed data

### Step 4: Create an admin user
1. Go to **Authentication → Users → Add User**
2. Enter your admin email + password
3. Click **Create user**

### Step 5: Update configuration
Edit these lines in `index.html` and `admin/index.html` to match your Supabase project:

```js
const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co'
const SUPABASE_ANON_KEY = 'your-anon-key-here'
```

Also update `admin/index.html`:
```js
const APP_NAME = 'Your Studio Name';
const FORM_URL = 'https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/';
```

### Step 6: Update seed data (optional but recommended)
Run this in the Supabase SQL Editor to set your studio's form URL:

```sql
update public.settings
set form_url = 'https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/'
where id = 1;
```

### Step 7: Deploy to GitHub Pages
1. Push your changes to GitHub
2. Go to **Settings → Pages**
3. Source: **Deploy from a branch** → `main` → `/` (root) → **Save**
4. Wait ~2 minutes — your site will be live at `https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/`

### Step 8: Test
1. Open your GitHub Pages URL → submit a test intake form
2. Open `admin/index.html` → log in with your admin credentials
3. The new submission should appear in real-time

---

## Email Notifications (Optional)

The app works perfectly without email — submissions appear instantly in the admin dashboard via Realtime.

If you want email notifications:

### Enable from the admin dashboard
1. Log in to the admin dashboard
2. Go to **Settings → Email Notifications**
3. Toggle **"Gmail SMTP Notifications"** on
4. Enter your Gmail address and **Gmail App Password** (requires 2FA)
5. Click **Save Settings**

### Deploy the Edge Function
Email sending requires a Supabase Edge Function to be deployed:

```bash
# Install Supabase CLI (one-time)
npm install -g supabase

# Log in (you need a Supabase access token from dashboard)
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy the notification function
supabase functions deploy send-notification
```

### Create a Database Webhook
1. Go to **Supabase Dashboard → Database → Webhooks**
2. Create a new webhook:
   - **Table:** `submissions`
   - **Event:** `INSERT`
   - **URL:** `https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-notification`
   - **HTTP method:** `POST`

---

## File Structure

```
client-intake/
├── index.html                   ← Intake form (all features)
├── admin/
│   └── index.html               ← Admin dashboard
├── docs/
│   ├── schema.sql               ← Complete SQL (tables, RLS, seed)
│   └── setup.md                 ← Setup guide
├── supabase/
│   └── functions/
│       └── send-notification/
│           └── index.ts         ← Optional email Edge Function
├── memory/                      ← Project knowledge (events, lessons, etc.)
├── .gitignore
├── .nojekyll                    ← Required for GitHub Pages
├── AGENTS.md                    ← Project agent rules
├── plan.md                      ← Architecture and implementation plan
└── tasks.md                     ← Task tracking
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Hosting** | GitHub Actions + GitHub Pages (static) |
| **Database** | Supabase PostgreSQL |
| **Auth** | Supabase Auth (email/password) |
| **Storage** | Supabase Storage (file uploads) |
| **Realtime** | Supabase Realtime (live dashboard) |
| **Edge Functions** | Supabase Edge Functions / Deno (optional) |
| **Intake Form** | Vanilla JS, embedded CSS |
| **Admin Dashboard** | Alpine.js 3, Tailwind CSS 3 (CDN) |
| **PDF** | jsPDF (CDN) |
| **Fonts** | Inter (Google Fonts) |
| **Icons** | Font Awesome 6 (CDN) |

---

## License

Studio use — AM Worx
