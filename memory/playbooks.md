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
