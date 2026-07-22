# Patterns

## Deployment Pattern: Supabase + GitHub Pages

### Prerequisites
- GitHub account with `gh` CLI authenticated
- Supabase project created (free tier)
- Supabase access token (`sbp_`) from dashboard
- Database password from Supabase project creation

### Steps
1. **Schema**: Run `docs/schema.sql` in Supabase SQL Editor or via `supabase db query`
2. **Auth**: Create admin user in Supabase Auth → Users
3. **Storage**: Create `submissions` bucket (included in schema.sql)
4. **Database connection**: Use pooler `aws-0-{region}.pooler.supabase.com:6543` with user `postgres.{project-ref}` when direct DB host is IPv6-only
5. **GitHub Pages**: Create repo → `git init` → push → enable Pages via API `POST repos/{owner}/{repo}/pages`
6. **Edge Functions**: `supabase login --token sbp_...` → `supabase link` → `supabase functions deploy {name} --no-verify-jwt`
7. **Webhooks**: Must be created manually in Supabase Dashboard → Database → Webhooks (no Management API endpoint available)
8. **OTP Edge Function**: Intake form calls `SUPABASE_EDGE_URL + '/send-otp'` with POST body `{email, code}`

## OTP Security Enforcement Pattern

When building email verification flows with Supabase:

1. **Never trust the client**: OTP codes must never be logged to console or displayed on screen. Verification must happen server-side.
2. **Never grant anon table access**: Anon role should never SELECT/UPDATE on `otp_codes`. Instead:
   - Create a SECURITY DEFINER RPC `verify_otp(email, code)` that checks the code, marks it used, sets `verified_at`
   - Grant only `EXECUTE` on the RPC to anon role
3. **Enforce verification on writes**: For any write operation that requires verified email:
   - Create a SECURITY DEFINER RPC that checks for recently verified OTP (`verified_at > now() - interval '10 minutes'`)
   - Revoke anon INSERT on the target table — all writes go through the RPC
4. **Rate limit**: Implement client-side cooldown on the "Send Code" button (60s minimum)
5. **Fail loudly**: When email delivery fails, show an error message — never expose the code

## Supabase Connection Pattern

When `db.{ref}.supabase.co` only resolves to IPv6:
- Use pooler: `aws-0-{region}.pooler.supabase.com:6543`
- Username format: `postgres.{project-ref}`
- Probe regions to find the correct one
- Use `pg` npm module for running SQL scripts

## Intake Flow — Question Order Pattern

When designing intake forms that serve both qualification and proposal generation:

1. **Welcome screen first** — set expectations (duration, what they'll receive), reduce abandonment
2. **Goal before features** — ask primary business goal first, then map features as enablers
3. **Need vs Want separation** — distinguish "required at launch" from "nice to have later"
4. **Business context** — maturity stage, timeline urgency, budget confidence, existing assets
5. **Complexity scoring** — every feature contributes points; score maps to recommended package
6. **Recommendation page** — show projected package, timeline, investment before submit
7. **Proposal generation** — admin clicks to produce a 90% complete proposal from submitted data
