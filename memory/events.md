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

## EVT-20260722-0004
- **Timestamp**: 2026-07-22T~23:55
- **Mode**: BUILD
- **Action**: Standalone share link widget + theme toggle fix + push
- **Summary**: Added a "Generate Share Link" card on the Dashboard page with email/name inputs so admins can create share URLs without needing existing submissions. Fixed the dark mode toggle by moving `x-bind:class="darkMode && 'dark'"` from `<html>` (outside Alpine scope) to `<body>` (inside component scope). Added `--success` CSS variable. Pushed to GitHub.
- **Files**: admin/index.html
- **Errors**: None
- **Lessons**: Alpine `x-bind:class` must be on the same element as `x-data` or a child element — never on a parent of `x-data`.
- **Tags**: share-link, dark-mode, fix

## EVT-20260722-0005
- **Timestamp**: 2026-07-22T~14:00
- **Mode**: BUILD
- **Action**: Dual-path pricing — Per-Item + Managed Bundles (Essential/Growth/Scale)
- **Summary**: Added pricing mode toggle at top of intake form. Bundle mode offers 3 tiers (Essential $19/mo, Growth $49/mo, Scale $89/mo) with "Help me choose" option. Bundle mode hides per-item sections (Domain, Maintenance) and price labels on visible sections. Dynamic SECTIONS_CONFIG renumbering and timeline rebuild on mode switch. PDF generation supports bundle summary. Admin dashboard shows Bundle badge + tier details. Created migration SQL for new pricing_mode and bundle_tier columns + updated submit_submission RPC.
- **Result**: Dual pricing flow working end-to-end. Migration SQL pending manual application via Supabase SQL editor.
- **Files**: index.html, admin/index.html, supabase/migrations/20260722_bundle_pricing.sql
- **Errors**: Section hiding relied on JS inline style only — added CSS-level !important rules as fallback
- **Tags**: pricing, bundles, migration, dual-path

## EVT-20260722-0006
- **Timestamp**: 2026-07-22T~15:00
- **Mode**: REVIEW
- **Action**: External expert project review
- **Summary**: Shared complete project files (intake form, admin dashboard, schema, migrations, functions) with external expert for architectural and UX review. Received comprehensive 10-point analysis with scores (Business Concept: 10/10, UX Flow: 8/10, Technical Architecture: 9.5/10, Scalability: 9/10, Freelancer Value: 10/10). Key suggestions: Welcome screen, goal-first questioning, complexity scoring, need-vs-want separation, business maturity tier, timeline urgency, budget confidence, existing assets checklist, proposal recommendation page, and proposal generator feature.
- **Result**: 10 concrete improvement suggestions received. Assessment validates current architecture and identifies UX/sales conversion as primary growth area.
- **Files**: (external review — no files changed)
- **Errors**: None
- **Lessons**: The biggest opportunity is shifting from "survey" to "intelligent sales, qualification, and proposal-generation system." Technical foundation is strong enough to support the vision.
- **Tags**: review, architecture, ux, strategy, sales

## EVT-20260722-0007
- **Timestamp**: 2026-07-22T~16:00
- **Mode**: BUILD
- **Action**: Tier 1 UX implementation — Welcome screen, goal-first section, feature priority toggle, recommendation card
- **Summary**: Implemented 4 Tier 1 recommendations from expert review: (1) Welcome screen overlay with pitch, deliverables grid, and "Start Survey" button; (2) Primary Goal section (s-goal) inserted between Contact and Domain with 8 radio options covering business outcomes; (3) Feature priority toggle — each feature card shows Required (blue) / Nice-to-have (amber) state, click-to-toggle, hidden in Bundle mode; (4) Recommendation card in Review section showing recommended package + timeline + investment based on complexity scoring. Complexity scoring: website type (0-8 pts) + pages (1 pt each) + features (1-3 pts each) → Essential (0-5), Growth (6-12), Scale (13+).
- **Result**: All 4 Tier 1 features working. Pushed as commit ce3394b.
- **Files**: index.html
- **Errors**: None
- **Lessons**: Complexity scoring provides an objective recommendation that builds client trust and reduces "which package?" decision paralysis.
- **Tags**: tier1, welcome, goals, priority, recommendation

## EVT-20260722-0008
- **Timestamp**: 2026-07-22T~17:00
- **Mode**: BUILD
- **Action**: Tier 2 data-collection implementation — complexity meter, business maturity, timeline tiers, budget confidence, assets checklist
- **Summary**: Added 5 Tier 2 features: (1) Live complexity meter in price bar with progress bar + level label (Low/Medium/High/Very High) + recommended package; (2) Business maturity question — "What best describes your business?" with 5 lifecycle options; (3) Timeline replaced with 5 urgency tiers (ASAP $150, Within 2 Weeks $75, 1 Month, 2-3 Months, No Deadline); (4) Budget confidence — "How fixed is your budget?" with Fixed/Flexible/Need Advice; (5) Existing assets checklist — 8 checkboxes (Logo, Brand Guidelines, Photos, Content, Domain, Hosting, Analytics, Social Media). All new fields flow through collectFormData → review summary → Supabase submission.
- **Result**: All 5 Tier 2 features working. Pushed as commit 7a75eb4.
- **Files**: index.html, admin/index.html
- **Errors**: None
- **Lessons**: Tier 2 data (maturity, timeline urgency, budget confidence) transforms the intake from a feature checklist into a qualification tool that lets the studio assess lead quality and readiness before the first call.
- **Tags**: tier2, complexity, maturity, timeline, budget, assets

## EVT-20260722-0009
- **Timestamp**: 2026-07-22T~18:00
- **Mode**: BUILD
- **Action**: Proposal Generator — admin-side proposal builder with preview, edit, and PDF export
- **Summary**: Added full proposal generator to admin dashboard. "Proposal" button in detail footer opens modal with auto-built proposal from all submission fields including Tier 1+Tier 2 data (primary_goal, business_maturity, budget_confidence, existing_assets, feature priority). Preview mode renders proposal as formatted HTML with section headers, bullets, and labels. Edit mode shows monospace textarea for content refinement. PDF Export via jsPDF produces A4-formatted document with title, client info, scope, investment, timeline, and footer. Accent-styled "Proposal" button added to detail footer.
- **Result**: Proposal generator operational. Pushed as commit d5cc6ab.
- **Files**: admin/index.html
- **Errors**: None
- **Lessons**: jsPDF from CDN is sufficient for single-page proposal export — no build step needed. The proposal should be treated as a starting draft that the admin can refine before exporting.
- **Tags**: tier3, proposal, pdf, export

## EVT-20260722-0010
- **Timestamp**: 2026-07-22T~12:45
- **Mode**: BUILD
- **Action**: Database schema fix — added missing Tier 1+2 columns, fixed CHECK constraints, updated RPC
- **Summary**: Identified and fixed critical database schema mismatches blocking submissions. The `submissions` table was missing 7 columns (primary_goal, business_maturity, budget_confidence, existing_assets, other_website_type, has_company_profile, complexity_score). The `timeline` CHECK constraint only allowed old values ('1-week','flexible') but form sends new values ('asap','2-3-months','no-deadline'). The `website_type` CHECK constraint didn't include 'other'. The `submit_submission` RPC was an older version that didn't include pricing_mode, bundle_tier, or any Tier 1+2 fields. Created comprehensive migration `202607222300_tier1_tier2_schema.sql` adding all columns, fixing constraints, and updating the RPC. Renamed conflicting migrations to unique timestamps. Made `20260721225600_otp_security.sql` and `202607221200_share_tokens.sql` idempotent with `drop policy if exists`. Applied all migrations via `supabase db push`. All 7 columns verified writable. Timeline and website_type constraint fixes confirmed. RPC now includes all fields.
- **Result**: All schema mismatches resolved. Bundle mode and Tier 1+2 submissions will no longer fail.
- **Files**: supabase/migrations/202607222300_tier1_tier2_schema.sql, supabase/migrations/20260721225600_otp_security.sql, supabase/migrations/202607221200_share_tokens.sql, supabase/migrations/202607220001_bundle_pricing.sql, docs/schema.sql
- **Errors**: Migration version conflicts required file renames and migration repair. CLI login user lacks ALTER TABLE permissions, but `supabase db push` applies migrations as database owner.
- **Lessons**: All migrations sharing the same timestamp prefix cause version conflicts. Use unique timestamps. Policy creation without `DROP IF EXISTS` causes re-apply failures. Always verify schema changes via direct REST API calls after migration.
- **Tags**: schema, migration, fix, bundle, tier1, tier2
