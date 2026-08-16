# Lessons

## LSN-20260718-0001
- **Event**: EVT-20260718-0002
- **Observation**: Gmail SMTP requires an App Password, which Google only generates when 2FA is enabled on the account
- **Action**: Moved SMTP config to admin dashboard Settings page — no upfront requirement
- **Severity**: Info

## LSN-20260718-0002
- **Event**: EVT-20260718-0004
- **Observation**: Supabase database hosts may only have IPv6 (AAAA) DNS records. Node.js `getaddrinfo` and `Test-NetConnection` on IPv4-only networks cannot resolve them.
- **Action**: Use pooler hostname `aws-0-{region}.pooler.supabase.com:6543` with username `postgres.{project-ref}` for IPv4-compatible connections.
- **Severity**: Info

## LSN-20260721-0003
- **Event**: EVT-20260721-0001
- **Observation**: Anon role with direct table access (SELECT/INSERT/UPDATE) bypasses all server-side security. OTP verification in client-side code is a critical vulnerability.
- **Action**: Use SECURITY DEFINER PostgreSQL functions as RPC endpoints. Grant anon only EXECUTE on specific RPCs. The RPC runs with definer privileges and can access tables that anon cannot query directly.
- **Severity**: Critical

## LSN-20260722-0004
- **Event**: EVT-20260722-0003
- **Observation**: Supabase 2026+ installs the `pgcrypto` extension in an `extensions` schema rather than `public`. SECURITY DEFINER functions with `set search_path = ''` cannot find `gen_random_bytes` without a schema qualifier.
- **Action**: Use `extensions.gen_random_bytes(16)` inside all security definer functions. Add `CREATE EXTENSION IF NOT EXISTS pgcrypto;` at top of migration files.
- **Severity**: Medium

## LSN-20260722-0005
- **Event**: EVT-20260722-0006
- **Observation**: The project's biggest lever for growth is shifting from a "survey" mindset to an "intelligent sales, qualification, and proposal-generation system." The technical foundation (Supabase + GH Pages + OTP + bundle pricing + admin dashboard) is already strong enough to support this — the next phase should focus on intelligence, not infrastructure.
- **Action**: Prioritize UX improvements that reduce abandonment (Welcome screen, goal-first questioning) and features that convert (complexity scoring, package recommendation, proposal generator). The existing architecture supports incremental addition without rework.
- **Severity**: High

## LSN-20260722-0006
- **Event**: EVT-20260722-0006
- **Observation**: Asking "Need blog/booking/gallery?" in current order skips over the client's actual business goal. Clients don't think in features — they think in outcomes (generate leads, sell online, build brand).
- **Action**: Restructure questioning order: primary goal first → features as enablers of that goal. Goal context makes every subsequent answer more useful for package recommendation.
- **Severity**: Medium

## LSN-20260722-0007
- **Event**: EVT-20260722-0007
- **Observation**: Complexity scoring with objective criteria (type + pages + features) gives clients confidence in the recommended package and reduces hesitation. When a client sees "Based on your answers, we recommend the Growth package," it feels like expert guidance rather than upselling.
- **Action**: Keep the scoring algorithm visible (meter + level label) so clients understand the recommendation logic. Update criteria weights as more submissions reveal actual project complexity patterns.
- **Severity**: Medium

## LSN-20260722-0008
- **Event**: EVT-20260722-0008
- **Observation**: Tier 2 fields (maturity stage, timeline urgency, budget confidence, existing assets) convert the intake form from a feature questionnaire into a lead qualification tool. These dimensions let the studio triage leads before the first call — a startup with "No deadline" and "Need Advice" on budget is a different prospect than an established business with "ASAP" and "Fixed" budget, even if their website specs are identical.
- **Action**: Surface Tier 2 fields prominently in the admin detail panel and add filter/sort capability to the submissions table. Consider adding lead score calculation in a future iteration.
- **Severity**: High

## LSN-20260722-0010
- **Event**: EVT-20260722-0010
- **Observation**: The database schema silently drifted from the form fields. The form collected 7 Tier 1+2 fields that didn't exist in the database. The timeline CHECK constraint allowed old values but the form had been updated to send new values. The `submit_submission` RPC was overwritten by a later migration with an older version that didn't include pricing_mode or bundle_tier. These mismatches caused silent data loss or submission failures.
- **Action**: The authoritative schema source must be `docs/schema.sql` — form changes must be validated against it. Migrations should be idempotent (use `drop policy if exists`, `add column if not exists`). All migrations sharing the same version prefix must be avoided — use unique timestamps.
- **Severity**: Critical

## LSN-20260722-0009
- **Event**: EVT-20260722-0009
- **Observation**: jsPDF loaded from CDN works well for generating simple A4 PDF proposals entirely in the browser. No server-side rendering or build step is needed. The proposal content is built from submission data and can be edited before export, giving admins flexibility without leaving the dashboard.
- **Action**: Extend proposal generation to support rich formatting (bold, links) and template customization from Settings page in a future iteration. Consider adding email-send directly from proposal modal.
- **Severity**: Low

## L-20260816-001 - PostgreSQL CHECK constraints allow NULL
- **Context**: Submission failed with "violates check constraint submissions_email_count_check" when client sent email_count=999.
- **Lesson**: A CHECK constraint like check (email_count between 1 and 100) does NOT reject NULL - NULL evaluates to NULL (not FALSE), so the row passes. To forbid NULL you need NOT NULL or an explicit IS NOT NULL in the check. Verify live behavior empirically with a throwaway insert rather than assuming.
## L-20260816-002 - Sentinel values must satisfy DB constraints
- **Context**: 'unlimited' email plan mapped to email_count=999, violating a 1-100 check.
- **Lesson**: When a UI option maps to a numeric sentinel for storage, confirm the sentinel is inside the column's CHECK range (or relax the constraint). A value like 999 for "unlimited" is a latent submission-killing bug.

## L-20260816-003 - Probe the live DB; local migrations can be wrong
- **Context**: Third report of submissions_email_count_check. Local migrations said email_count check was between 1 and 100, but live DB (changed by a dashboard-applied migration) enforced between 1 and 5.
- **Lesson**: The migration folder is not proof of the live schema. When a constraint error persists, binary-search the live DB by inserting rows with candidate values (1,2,5,50,99,100) to find the real bounds. A client-side value clamp only helps if the DB constraint actually accepts the clamped value.
## L-20260816-004 - Migrations applied via Supabase Dashboard break supabase db push
- **Context**: Remote migration history had version 202607222345 not present locally; db push refused to run.
- **Lesson**: Apply ALL schema changes through committed migration files and supabase db push. If a dashboard-applied version already exists remotely, add a local placeholder file with the same version and NO SQL (the version is already recorded as applied remotely, so push skips it) - document the situation in the file.

## L-20260816-005 - Async state setters must re-run the state evaluator
- **Context**: Submit button stayed disabled after OTP verification because the verify handler set a flag but didn't call calculate() which evaluates the button state.
- **Lesson**: If a button's disabled state is computed in a central function (e.g., calculate()), every async state change (OTP verify, upload completion, etc.) that feeds that computation MUST call the evaluator. Never rely on the user triggering a re-evaluation through unrelated inputs.
## L-20260816-006 - Disabled controls need inline explanation
- **Context**: Users couldn't tell why Submit was locked or what to do.
- **Lesson**: A disabled primary button is a dead end unless the UI explains the required action(s). Render a dynamic hint that lists each missing condition ('Verify your email...', 'Select at least one service...') and hide it once the button is enabled.
