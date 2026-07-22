# Playbooks

## Security Hardening — OTP/Submission Enforcement

### Trigger
Expert review identifies OTP or submission security vulnerabilities.

### Steps
1. **Database**:
   - Add `verified_at timestamptz` column to `otp_codes`
   - Drop anon SELECT/UPDATE policies on `otp_codes`
   - Create `verify_otp(email, code)` SECURITY DEFINER RPC
   - Drop anon INSERT policy on `submissions`
   - Create `submit_submission(data, email)` SECURITY DEFINER RPC
   - Grant EXECUTE on both RPCs to anon
2. **Client**:
   - Remove any console.log of OTP codes
   - Replace on-screen code fallback with error message
   - Call `verify_otp` RPC for verification
   - Call `submit_submission` RPC for submissions
   - Add 60s cooldown on Send Code button
   - Add file type whitelist on uploads
3. **Deploy**: `supabase db push --linked` → commit → push → verify Pages build
4. **Memory**: Log event, update lessons, update patterns, update playbooks

## Feature Rollout — Expert Review Suggestion

### Trigger
External expert review produces ranked suggestions for product improvement.

### Steps
1. **Log suggestions** — record all suggestions in events.md, lessons.md, patterns.md, decisions.md
2. **Prioritize with user** — present suggestions grouped by Tier (quick wins, strategic features, future considerations). Let user pick direction.
3. **Implement per tier** — each tier is a single build session with clear scope boundaries
4. **Extend data model** — new form fields flow through `collectFormData()` → review summary → Supabase submission payload. Admin detail panel auto-displays new fields via template conditionals.
5. **Push after each tier** — commit message describes all changes in that tier, push immediately so user can verify live
6. **Update memory** — log event, lesson, pattern, and decision entries for each tier

## Admin Proposal Generation

### Trigger
Admin views submission detail and wants to generate a professional proposal.

### Steps
1. **Open detail** — click any submission row to open the detail panel
2. **Click Proposal** — accent-styled button in footer triggers auto-build from all submission fields
3. **Review auto-generated content** — proposal includes scope, pricing, timeline, and studio info
4. **Edit if needed** — toggle to Edit mode, refine proposal text, toggle back to Preview
5. **Export PDF** — click "Export PDF" to download A4-formatted proposal document
6. **Close** — modal closes, content is discarded (regenerate when needed)

### Content sources
- All form fields (primary_goal, website_type, pages, features with priority, business_maturity, domain, hosting, email, maintenance, existing_assets, extra_notes)
- Pricing (bundle or itemized with breakdown)
- Timeline
- Studio name and email from Settings
