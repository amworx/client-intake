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
