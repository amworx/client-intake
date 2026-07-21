# Events

## EVT-20260718-0001
- **Timestamp**: 2026-07-18T21:39
- **Mode**: BUILD
- **Action**: Project initialization + requirements gathering
- **Summary**: Created project structure, received Supabase credentials and user preferences from user
- **Result**: Project directory, memory/credentials.md created
- **Files**: memory/credentials.md
- **Errors**: None
- **Lessons**: None
- **Tags**: setup, credentials

## EVT-20260718-0002
- **Timestamp**: 2026-07-18T21:45
- **Mode**: BUILD
- **Action**: Full app build complete
- **Summary**: Built complete client intake app with Supabase backend — schema, intake form, admin dashboard, email Edge Function
- **Result**: All 14 project files created and verified
- **Files**: AGENTS.md, index.html, admin/index.html, docs/schema.sql, docs/setup.md, supabase/functions/send-notification/index.ts, tasks.md, memory/*
- **Errors**: None
- **Lessons**: Gmail App Password still needed from user to activate email notifications
- **Tags**: build, complete, intake, supabase

## EVT-20260718-0003
- **Timestamp**: 2026-07-18T21:50
- **Mode**: BUILD
- **Action**: SMTP notification made optional, configurable from dashboard Settings
- **Summary**: Added `smtp_enabled`, `smtp_email`, `smtp_password` columns to `settings` table. Added Email Notifications section to admin Settings page with toggle + password field + show/hide. Rewrote Edge Function to read SMTP config from `settings` table instead of env vars. App runs fully without email setup.
- **Files**: docs/schema.sql, admin/index.html, supabase/functions/send-notification/index.ts, docs/setup.md, memory/credentials.md, memory/lessons.md
- **Errors**: None
- **Lessons**: SMTP config belongs in the DB where admin can manage it — not in env vars
- **Tags**: smtp, email, settings, optional

## EVT-20260718-0004
- **Timestamp**: 2026-07-18T19:34
- **Mode**: BUILD
- **Action**: Applied SQL schema to Supabase database
- **Summary**: Ran full schema.sql against project jyqjkkcenuapssmstmze (eu-west-1). 4 tables created, 10 RLS policies active, seed data loaded for settings + 7 section_groups.
- **Result**: All tables verified — submissions, settings, section_groups, otp_codes. Settings row populated with SMTP disabled.
- **Files**: docs/schema.sql
- **Errors**: None
- **Lessons**: Supabase DB host may only have IPv6 AAAA record. Use pooler `aws-0-{region}.pooler.supabase.com:6543` for IPv4 connectivity. Project was in eu-west-1.
- **Tags**: schema, database, supabase

## EVT-20260718-0005
- **Timestamp**: 2026-07-18T20:10
- **Mode**: BUILD
- **Action**: Live deployment — GitHub Pages + Edge Functions
- **Summary**: Created GitHub repo `amworx/client-intake`, pushed all code, enabled GitHub Pages at `https://amworx.github.io/client-intake/`. Deployed `send-notification` + `send-otp` Edge Functions to Supabase. Updated intake form to call send-otp function via fetch. Created comprehensive README with setup guide for new users. Updated setup.md with full deployment documentation.
- **Result**: App is live at GitHub Pages URL. Both Edge Functions deployed. Webhook creation still needs Dashboard UI step (documented in setup guide).
- **Files**: README.md, docs/setup.md, index.html, supabase/functions/send-otp/index.ts
- **Errors**: None
- **Lessons**: Supabase Database Webhooks must be created through Dashboard UI — no Management API endpoint exists for programmatic creation. `pg_net` extension not available for trigger-based HTTP calls.
- **Tags**: deploy, github-pages, edge-functions, go-live

## EVT-20260721-0001
- **Timestamp**: 2026-07-21T22:56
- **Mode**: BUILD
- **Action**: Security hardening — OTP verification server-side enforcement
- **Summary**: Applied 8 security fixes from expert review. Critical: removed console.log of OTP code, removed on-screen code fallback (fail loudly), created verify_otp() SECURITY DEFINER RPC, created submit_submission() RPC that enforces OTP verification, revoked anon SELECT/UPDATE on otp_codes, revoked anon INSERT on submissions. Medium: 60-second cooldown on Send Code button, file type whitelist on uploads. Low: labeled estimates as client-side in admin dashboard.
- **Result**: 5 files changed (580 insertions, 56 deletions). Migration applied via supabase db push. Committed, pushed, deployed to GitHub Pages.
- **Files**: index.html, admin/index.html, docs/schema.sql, docs/migration_otp_security.sql, supabase/migrations/20260721225600_otp_security.sql
- **Errors**: None
- **Lessons**: SECURITY DEFINER RPCs are the correct Supabase pattern for server-side enforcement. Anon role should only have EXECUTE on specific RPCs, never direct table access for sensitive operations.
- **Tags**: security, otp, rpc, rls, hardening

## EVT-20260721-0002
- **Timestamp**: 2026-07-21T23:15
- **Mode**: BUILD
- **Action**: Form feature enhancements — hosting months, company profile, custom website type, SSL auto-require, descriptions
- **Summary**: Added 5 feature enhancements: (1) hosting months selector (12-48 months) with price multiplication, (2) company profile upload option alongside business description, (3) "Other" website type with custom text field, (4) SSL Certificate auto-required when client doesn't have a domain, (5) descriptive tooltips and field descriptions for all unclear options (hosting, email, setup, features, branding, timeline, maintenance).
- **Files**: index.html
- **Errors**: None
- **Lessons**: Form enhancement should be validated against mobile viewports. SSL auto-require uses disabled+checked state to prevent user override.
- **Tags**: features, form, hosting, ssl, ux

## EVT-20260722-0001
- **Timestamp**: 2026-07-22T~12:00
- **Mode**: BUILD
- **Action**: Emoji → Lucide icon migration
- **Summary**: Replaced every emoji icon across the intake form (section titles, card grids, timeline sidebar) with Lucide SVGs. Added runtime JS mapping function that handles ~50 emoji code points, VS16, and keycap combining chars. Fixed invalid icon name (muscle→dumbbell). Updated CSS for section-icon layout and timeline dot icon transitions.
- **Result**: 100 Lucide SVGs rendered, 0 emoji remaining, 0 console errors
- **Files**: index.html
- **Errors**: None
- **Lessons**: Variation Selector-16 (U+FE0F) must be stripped from emoji textContent before mapping to icon names. Keycap sequences (digit + VS16 + U+20E3) need multi-step cleanup.
- **Tags**: lucide, icons, emoji, refactor

## EVT-20260722-0002
- **Timestamp**: 2026-07-22T~13:00
- **Mode**: BUILD
- **Action**: Layout fixes — sidebar overlap, section width, scramble speed
- **Summary**: Fixed sidebar z-index/layering so top-bar and price-bar no longer cover it. Removed max-width constraint on main-content so sections fill available space without blank right area. Set form-section max-width 900px with auto centering. Increased section spacing (24→32px). Slowed scramble title animation (1800→3500ms) with slower pre-frames.
- **Result**: Sidebar clears both bars vertically, blank right area eliminated, sections breathe better, animation is more dramatic.
- **Files**: index.html
- **Errors**: None
- **Lessons**: Fixed sidebar needs to be sandwiched between fixed header and footer — top/bottom must match their heights exactly. Using margin auto on child elements with max-width prevents them from stretching too wide on large screens.
- **Tags**: layout, sidebar, z-index, spacing, animation

## EVT-20260722-0003
- **Timestamp**: 2026-07-22T~23:45
- **Mode**: BUILD
- **Action**: Share tokens — unique client intake links + admin dashboard UX
- **Summary**: Added `share_tokens` table + RLS + 3 RPCs (generate, validate, consume). Updated `submit_submission` to accept optional `p_token` parameter bypassing OTP if valid token matches email. Intake form reads `?token=xxx` from URL, validates token, pre-fills/locks email field, skips OTP. Admin dashboard has Share Link button + copy functionality. Added `.btn-success` CSS class. Fresh migration SQL (20260722_share_tokens.sql) applied to Supabase. pgcrypto extension and `extensions.gen_random_bytes` needed for token generation.
- **Result**: All 4 RPCs tested end-to-end — generate, validate, consume, validate-consumed. share_tokens table created with RLS. Migration SQL updated with pgcrypto CREATE EXTENSION. Functions recreated after pgcrypto install.
- **Files**: admin/index.html, supabase/migrations/20260722_share_tokens.sql, docs/schema.sql
- **Errors**: (1) gen_random_bytes needed pgcrypto extension which was not enabled. (2) pgcrypto installed in `extensions` schema (Supabase default), so function search_path needed `extensions.` prefix.
- **Lessons**: Supabase 2026+ installs pgcrypto in `extensions` schema, not `public`. Security definer functions with `set search_path = ''` must use fully qualified `extensions.gen_random_bytes()`.
- **Tags**: share-tokens, rpc, migration, pgcrypto
