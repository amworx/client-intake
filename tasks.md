# Tasks — Client Intake App

Status: 🔴 Not Started | 🟡 In Progress | 🟢 Complete

---

## Task 1 — Create docs/schema.sql  🟢
- [x] Create `docs/schema.sql` with:
  - [x] `submissions` table (all columns per plan §2.1)
  - [x] `settings` table (singleton row, all columns)
  - [x] `section_groups` reference table
  - [x] `otp_codes` table
  - [x] Storage bucket (`submissions`) creation
  - [x] RLS policies for all tables + storage
  - [x] Seed data for `settings` (id=1 with defaults) and `section_groups`

## Task 2 — Create docs/setup.md  🟢
- [x] Create step-by-step setup guide covering: Supabase project creation, SQL execution, Storage setup, GitHub Pages deployment

## Task 3 — Build intake form (index.html)  🟢
- [x] Create `index.html` with:
  - [x] HTML structure: all 7 survey sections, progress tracker, price bar
  - [x] CSS: light + dark mode, responsive layout
  - [x] Supabase client init with credentials
  - [x] Live price calculator (`calculate()` function, `data-price` attributes)
  - [x] Price breakdown modal
  - [x] Progress tracker (IntersectionObserver, auto-highlight)
  - [x] Dark mode toggle (localStorage)
  - [x] Draft auto-save (localStorage, 800ms debounce)
  - [x] File upload (drag area, multiple files, 25MB limit, preview + remove)
  - [x] OTP email verification flow (send + verify)
  - [x] Form validation (name, email, OTP, required fields)
  - [x] PDF generation (jsPDF multi-page summary)
  - [x] Dynamic overrides (load prices + sections from Supabase)
  - [x] Section visibility (hide disabled sections + progress steps)
  - [x] Custom options injection
  - [x] Submit flow (upload files → upload PDF → insert submission → thank-you screen)
  - [x] Thank-you screen with green checkmark
  - [x] Loading/error states

## Task 4 — Build admin dashboard (admin/index.html)  🟢
- [x] Create `admin/index.html` with:
  - [x] Supabase Auth login (email/password)
  - [x] Layout: sidebar (logo, nav, connection status), header (title, new badge, dark toggle, refresh), main content
  - [x] Dashboard view: 4 stat cards (Total, New, Reviewed, Revenue), recent submissions table (5 rows)
  - [x] Submissions view: full table with search/filter, detail slide-in panel
  - [x] CRUD: status toggle (New ↔ Reviewed), delete with confirmation modal
  - [x] Settings view: general fields, 55 price steppers, 7 section cards with CRUD custom options
  - [x] Real-time subscription (new submissions push to dashboard)
  - [x] HeroUI-style number stepper CSS component
  - [x] Dark mode toggle
  - [x] Toast notifications
  - [x] Loading skeleton + error states
  - [x] Auto-refresh / real-time updates

## Task 5 — Build Edge Function (supabase/functions/send-notification/index.ts)  🟢
- [x] Create `supabase/functions/send-notification/index.ts`:
  - [x] Gmail SMTP integration using Deno SMTP client
  - [x] Email template for new submission notification
  - [x] Webhook handler for `submissions` INSERT event

## Task 6 — Apply SQL schema to Supabase database  🟢
- [x] Installed Supabase CLI (v2.109.1) via npm
- [x] Installed `pg` npm module for Node.js database connectivity
- [x] Discovered project region: eu-west-1 (via pooler probe)
- [x] Connected to pooler `aws-0-eu-west-1.pooler.supabase.com:6543`
- [x] Executed `docs/schema.sql` successfully
- [x] Verified: 4 tables (submissions, settings, section_groups, otp_codes)
- [x] Verified: 10 RLS policies active
- [x] Verified: Seed data loaded (settings + 7 section_groups)
- [x] Recorded event + lesson in memory

## Task 7 — Verify project structure  🟢
- [x] Final check: all files in place per plan §7
- [x] Record final event + lessons in memory

## Task 8 — Deploy to GitHub Pages  🟢
- [x] Created GitHub repo `amworx/client-intake`
- [x] Initialized git, committed all files, pushed to `main`
- [x] Enabled GitHub Pages via API (branch: main, path: /)
- [x] Added `.nojekyll` file to prevent Jekyll processing
- [x] Created comprehensive `README.md`
- [x] Updated `docs/setup.md` with full deployment guide

## Task 9 — Deploy Edge Functions  🟢
- [x] Logged into Supabase CLI with access token
- [x] Linked to project `jyqjkkcenuapssmstmze`
- [x] Deployed `send-notification` Edge Function
- [x] Created `send-otp` Edge Function and deployed it
- [x] Updated `index.html` to call `send-otp` function on OTP send
- [ ] Webhook setup: Manual step needed via Supabase Dashboard → Database → Webhooks

## Task 10 — Update memory & docs  🟢
- [x] Created event EVT-20260718-0005
- [x] Updated patterns.md with deployment patterns
- [x] Updated tasks.md with all completed items
