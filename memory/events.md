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
