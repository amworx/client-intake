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

## Supabase Connection Pattern

When `db.{ref}.supabase.co` only resolves to IPv6:
- Use pooler: `aws-0-{region}.pooler.supabase.com:6543`
- Username format: `postgres.{project-ref}`
- Probe regions to find the correct one
- Use `pg` npm module for running SQL scripts
