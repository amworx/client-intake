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

## EVT-20260722-0011
- **Timestamp**: 2026-07-22T~10:00
- **Mode**: BUILD
- **Action**: Fixed complexity_score storage — form captures score, RPC stores it, old RPC overload dropped
- **Summary**: Identified that `complexity_score` was calculated client-side in the complexity meter but never sent to the database. The column existed in the table (added by tier1_tier2_schema migration) but the RPC's INSERT statement didn't include it. Also discovered that the old 2-param `submit_submission(jsonb,text)` RPC overload remained from the initial OTP migration, causing "Could not choose best candidate function" errors. Fixed by: (1) adding `window._complexityScore` capture after score calculation, (2) adding `complexity_score` to submission data in `submitForm()`, (3) creating follow-up migration `202607222310` to add it to the RPC INSERT, (4) creating migration `202607222320` to drop the old 2-param overload. All 6 migrations now synced between local and remote.
- **Result**: `complexity_score` now stored with each submission. RPC overload error eliminated.
- **Files**: index.html, supabase/migrations/202607222310_complexity_score_rpc.sql, supabase/migrations/202607222320_drop_old_rpc_overload.sql, docs/schema.sql
- **Errors**: Old 2-param RPC overload caused ambiguous function error; resolved by dropping it.
- **Lessons**: `create or replace function` only works when the function signature (parameter types/count) matches. Adding a parameter with a default value creates a separate overload.
- **Tags**: complexity_score, rpc, overload, fix

## EVT-20260722-0012
- **Timestamp**: 2026-07-22T~18:30
- **Mode**: BUILD
- **Action**: Fixed 3 production bugs + UI polish
- **Summary**: (1) "submissionData is not defined" error on submit — `var submissionData` was scoped to one `.then()` callback but referenced in a subsequent `.then()`. Hoisted declaration to `submitForm()` outer scope. (2) OTP showed "Code sent!" then later "Email delivery not configured" — the success toast and UI reveal fired immediately after the Edge Function `fetch()` was initiated, not after it resolved. Moved success path inside the `.then()` that runs only after the Edge Function confirms send. Applied to both main form and bundle confirmation form. (3) Recommendation card UI upgraded — added gradient background, shimmering accent bar, lucide sparkles icon, pill badges with colored dots, single-column hover-slide row layout, slide-up entrance animation, and soft accent-tinted box-shadow.
- **Result**: All 3 bugs fixed. Submission flow works end-to-end. OTP show success only on actual email send. Recommendation card looks polished in right sidebar.
- **Files**: index.html
- **Errors**: None
- **Lessons**: (a) In promise chains, each `.then()` callback has its own function scope — `var` declarations don't carry across. Hoist to the outer function or pass values through the chain. (b) Never fire a success toast/toast/UI reveal before an async operation completes — wrap inside the success callback. The same bug existed in two places (main + bundle OTP). (c) For sidebar recommendation cards, single-column label-value rows work better than 3-column grids in 280px width.
- **Tags**: bug-fix, scoping, otp, toast, async, ui, sidebar, animation

## EVT-20260816-0001
- **Timestamp**: 2026-08-16
- **Mode**: BUILD
- **Action**: Fixed submission failure - email_count check constraint violation
- **Summary**: User reported "Submission failed: new row for relation "submissions" violates check constraint "submissions_email_count_check"" when submitting the form. Diagnosed by querying the live Supabase DB: inserted a throwaway test row with email_count=null (succeeded, then deleted id=42), proving NULL passes the CHECK constraint. Root cause: the main intake form sent email_count=999 when the user selects the "Unlimited" business email plan, and the DB constraint is check (email_count between 1 and 100). 999 is out of range, so every Unlimited-email submission failed. Bundle/not-sure flow was NOT the cause (it omits email_count, which becomes NULL and passes). Fixed by clamping Unlimited to 100 (max allowed). Also audited other constrained fields (domain_years 1-3, hosting_months 12/24/48) - all valid.
- **Result**: Unlimited email plan now submits email_count=100. All email_count values within 1-100. Committed and pushed as d2ef15c.
- **Files**: index.html (line 5115)
- **Errors**: submissions_email_count_check violation on submit with Unlimited email plan.
- **Lessons**: (a) PostgreSQL CHECK constraints allow NULL (NULL evaluates to NULL, not FALSE) - a NULL insert does NOT violate a check like "between 1 and 100". (b) When the client sends a value that maps to a fixed DB enum/range, always verify every possible client value satisfies the constraint - a "sentinel" value like 999 for 'unlimited' is a latent bug. (c) Verify live-DB behavior empirically (service-role REST insert with a throwaway row) instead of assuming docs match reality - the remote had a migration (202607222345) not present locally.
- **Tags**: bug-fix, check-constraint, email_count, supabase, submissions, production

## EVT-20260816-0002
- **Timestamp**: 2026-08-16
- **Mode**: BUILD / RESEARCH
- **Action**: Re-investigated persistent submissions_email_count_check error after fix
- **Summary**: User reported the same "violates check constraint submissions_email_count_check" error after commit d2ef15c fixed the unlimited->999 bug. Verified the LIVE RPC empirically: seeded a fake OTP-verified email in otp_codes via service role, then called submit_submission RPC with (a) bundle payload WITHOUT email_count -> HTTP 200 success (submission_id 46, cleaned up), and (b) email_count=999 -> HTTP 400 exact constraint error (id 47, cleaned up). Confirmed live RPC matches docs; NULL passes, 999 fails. Then verified the deployed GitHub Pages site (https://amworx.github.io/client-intake/) has the fix live (no 'unlimited ? 999', only the fixed 'unlimited ? 100'), all 4 remaining "999" strings are CSS (border-radius 999px, z-index 9999/9998/99999), Cache-Control max-age=600, Last-Modified fresh 19:13Z. Conclusion: the error the client hit came from a stale browser tab/page loaded before the fix deployed (in-memory old JS), not from the live site.
- **Result**: Live site confirmed fixed. Mitigation for handoff: cache-busting URL (query param) + hard refresh.
- **Files**: none changed (index.html already fixed in d2ef15c)
- **Errors**: None on live site; reproduced via RPC test payload.
- **Lessons**: (a) When a constraint error persists after a fix, reproduce the exact failing call against the live backend to isolate whether the backend or the client (stale cache) is at fault. (b) GitHub Pages caches HTML for max-age=600 and a tab left open keeps old JS in memory - a cache-busting query param on the shared link guarantees the client fetches the fixed version.
- **Tags**: check-constraint, email_count, rpc-test, cache, github-pages, reproduction

## EVT-20260816-0003
- **Timestamp**: 2026-08-16
- **Mode**: BUILD
- **Action**: Found and fixed the REAL root cause of submissions_email_count_check + submissions_maintenance_check
- **Summary**: User reported the email_count constraint error a third time after commit d2ef15c (999->100 clamp). Empirically tested the LIVE DB by inserting rows with various email_count values: 1,2,5 PASS; 50,99,100 FAIL -> the live constraint is "email_count between 1 and 5", NOT "between 1 and 100" as the local migrations/docs claim. The remote-only dashboard migration 202607222345 (never committed to the repo) had tightened the constraint. So every 100-mailbox or Unlimited email plan submission (email_count=100) failed - the 999->100 fix was necessary but insufficient. Also discovered maintenance='none' (the form's "No maintenance" option) violates submissions_maintenance_check on live. budget check on live already accepts the real form values. Fix: created migration 20260816190000_fix_budget_maintenance_checks.sql (email_count -> between 1 and 100, maintenance -> +'none', budget -> union of old+new sets), reconciled migration history with a documented placeholder for the dashboard-applied 202607222345, and pushed to live via supabase db push (also applied the pending 202607230000 bundle tiers settings migration - bundles column already existed on live, so it was a no-op + seed). Verified end-to-end: direct inserts with email_count=100/maintenance=none/budget=under-1000 all PASS, and the live submit_submission RPC with a full realistic payload (unlimited, none, under-1000) returned success (submission 66, cleaned up). Updated docs/schema.sql to match.
- **Result**: All client submission paths now succeed against the live backend. The user's reported error was real (not stale cache as previously suspected) - the live DB constraint was stricter than the form's plans.
- **Files**: supabase/migrations/20260816190000_fix_budget_maintenance_checks.sql (new), supabase/migrations/202607222345_dashboard_applied_placeholder.sql (new), docs/schema.sql
- **Errors**: submissions_email_count_check with email_count=100; submissions_maintenance_check with maintenance='none'.
- **Lessons**: (a) NEVER trust local migration files to describe the live DB - a dashboard-applied migration can silently change constraints. Probe the live DB empirically (binary search the failing values). (b) A client-side clamp is not enough when the DB constraint is stricter than the UI's options - the constraint itself must match the product's plans. (c) supabase db push fails when remote history has versions absent locally; add a documented placeholder file (no SQL) to map the dashboard-applied version, since the version is already recorded as applied remotely.
- **Tags**: check-constraint, email_count, maintenance, live-db, migration, supabase-push, root-cause

## EVT-20260816-0004
- **Timestamp**: 2026-08-16
- **Mode**: BUILD
- **Action**: Fixed submit button stuck disabled + no guidance for the user
- **Summary**: User reported the Submit button stayed disabled with no explanation of how to enable it. Root cause: the main form's OTP verify success handler set window._emailVerified=true but never called calculate(), which owns the button enable/disable logic (btn.disabled = !(priceItems.length>0 && emailVerified)). So after verifying email, the button remained disabled until the user happened to change another form field. There was also no visible feedback explaining the disabled state. Fix: (1) call calculate() after OTP verify succeeds in both main and bundle OTP handlers, (2) add a dynamic .submit-hint under the Submit button that shows 'Verify your email to unlock Submit' / 'Select at least one service to unlock Submit' (hidden when enabled). Verified in browser at 375px: hint shows both blockers initially, narrows to email-only after selecting a service, button enables + hint hides once email is verified. Committed 3147232, pushed, deployed (GitHub Pages build success).
- **Result**: Submit button now enables immediately after email verification and the UI explains exactly what the user must do while it is disabled.
- **Files**: index.html (CSS .submit-hint, HTML hint element, calculate() hint logic, 2 OTP handler fixes)
- **Errors**: None.
- **Lessons**: When a button's enabled state depends on async state (OTP verification), the state-setter must re-run the state evaluator - a plain boolean flag is not enough. Also: a disabled control with no explanation is a UX dead-end; show the required action(s) inline.
- **Tags**: bug-fix, otp, submit-button, ux, disabled-state, calculate
