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

## Admin Proposal Generator Pattern

When building admin-side proposal generation:

1. **Build from submission data** — auto-populate scope, pricing, and timeline from the submission record. Use the `proposalContent` state variable as the source of truth.
2. **Edit before export** — show editable monospace textarea (Edit mode) and formatted preview (Preview mode). Toggle between them without losing content.
3. **Client-side PDF** — jsPDF CDN is sufficient. Format as A4 with title, client info, scope bullets, investment summary, timeline, and studio footer. No server needed.
4. **Rich HTML preview** — render proposal text as formatted HTML using computed getter with regex replacements for section titles, bullets, labels, and separators.
5. **Reuse existing data** — the proposal pulls from all submission fields including Tier 1+2 (primary_goal, business_maturity, budget_confidence, existing_assets, feature priority). No duplicate data entry needed.

## Complexity Scoring Pattern

When implementing package recommendation from form answers:

1. **Assign points per dimension**: website type (0-8), pages (1 pt each), features (1-3 pts based on complexity)
2. **Sum into total score**: map to tiers — Essential (0-5), Growth (6-12), Scale (13+)
3. **Display live**: show progress bar + level label + recommended package that updates as user answers questions
4. **Include in recommendation card**: show the recommended package with timeline and investment estimate in review section
5. **Log in submission**: store `complexity_score` with submission for admin visibility

## Promise Chain Variable Scope Pattern

When variables defined inside one `.then()` callback need to be referenced in subsequent `.then()` callbacks:

```js
// ❌ WRONG — var is scoped to the .then() callback function
Promise.resolve().then(function() {
  // ... work ...
  var submissionData = { ... };
  return supabaseClient.rpc('submit', { p_data: submissionData });
}).then(function(res) {
  submissionData.submission_id = res.id; // ReferenceError: submissionData is not defined
});

// ✅ RIGHT — hoist declaration to outer scope
var submissionData;
Promise.resolve().then(function() {
  // ... work ...
  submissionData = { ... };
  return supabaseClient.rpc('submit', { p_data: submissionData });
}).then(function(res) {
  submissionData.submission_id = res.id; // works
});
```

**Key insight:** Each `.then()` callback creates a new function scope. `var` declarations do NOT carry across. `let`/`const` are block-scoped — same problem. Hoist to the function that owns the entire chain.

## Async Success Toast Pattern

When firing UI feedback (toast, reveal input, start cooldown) after an async operation like `fetch()`:

```js
// ❌ WRONG — fires immediately after fetch is initiated, not resolved
fetch(url, opts).then(handleResponse);
showToast('Success!', 'success');           // fires TOO EARLY
input.style.display = 'block';              // fires TOO EARLY
startCooldown();                            // fires TOO EARLY

// ✅ RIGHT — only fires after the async operation actually succeeds
fetch(url, opts).then(function(res) {
  return res.json().then(function(data) {
    if (data.error) { showError(); return; }
    if (data.skipped) { showError(); return; }
    showToast('Success!', 'success');       // fires AFTER success
    input.style.display = 'block';
    startCooldown();
  });
}).catch(showError);
```

**Key insight:** Success UI must live inside the `.then()` callback that runs after the async operation resolves successfully. If you need both success and cooldown logic, chain them: put the immediate success path inside the first `.then()`, then add a second `.then()` for the cooldown that only runs if the first one didn't error/return early.

## Sidebar Recommendation Card UI Pattern

When placing a live-updating recommendation/preview card in a 280px right sidebar:

1. **Single-column rows, not multi-column grids** — three columns at 280px width is cramped and unreadable. Use `display: flex; justify-content: space-between` with label on left, value on right.
2. **Visual depth** — gradient background + soft shadow with accent tint + shimmering top accent bar (3s shimmer animation).
3. **Pill badges with colored dots** — circle dot inside the badge makes it look like a status indicator, not just colored text.
4. **Icon in header** — Lucide icon (e.g., `sparkles`) next to the card title adds personality and visual anchor.
5. **Hover feedback on items** — `transform: translateX(2px)` + accent border on hover creates interactivity without noise.
6. **Entrance animation** — subtle slide-up + scale (`cubic-bezier(0.16, 1, 0.3, 1)`) when the card transitions from hidden to visible feels premium.
7. **Dashed-border note** — adds visual rhythm between the data grid and the disclaimer, breaking the monotony of solid cards.
