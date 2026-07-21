-- ============================================================
-- SECURITY MIGRATION: OTP Verification Enforcement
-- Date: 2026-07-21
-- ============================================================

-- 1. Add verified_at column to track server-side OTP verification
alter table public.otp_codes
add column if not exists verified_at timestamptz;

-- 2. Drop insecure anon policies on otp_codes
drop policy if exists "Anyone can read OTP codes (for verification)" on public.otp_codes;
drop policy if exists "Anyone can update OTP codes (mark used)" on public.otp_codes;

-- 3. Drop insecure anon INSERT on submissions (replace with authenticated-only)
drop policy if exists "Anyone can insert submissions" on public.submissions;

-- Re-create as authenticated-only
create policy "Authenticated users can insert submissions"
  on public.submissions for insert
  to authenticated
  with check (true);

-- 4. Create verify_otp RPC (SECURITY DEFINER)
create or replace function public.verify_otp(p_email text, p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_otp_id bigint;
  v_result jsonb;
begin
  -- Find matching, unexpired, unused OTP
  select id into v_otp_id
  from public.otp_codes
  where email = p_email
    and code = p_code
    and expires_at > now()
    and used = false
  order by expires_at desc
  limit 1;

  if v_otp_id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'Invalid or expired verification code.'
    );
  end if;

  -- Mark as used with verified timestamp
  update public.otp_codes
  set used = true, verified_at = now()
  where id = v_otp_id;

  return jsonb_build_object(
    'success', true,
    'message', 'Email verified successfully.'
  );
end;
$$;

-- 5. Create submit_submission RPC (SECURITY DEFINER)
create or replace function public.submit_submission(p_data jsonb, p_email text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_verified boolean;
  v_submission_id bigint;
  v_full_name text;
begin
  -- Check email was recently verified via OTP (within last 10 minutes)
  select exists (
    select 1
    from public.otp_codes
    where email = p_email
      and used = true
      and verified_at is not null
      and verified_at > now() - interval '10 minutes'
  ) into v_verified;

  if not v_verified then
    return jsonb_build_object(
      'success', false,
      'message', 'Email not verified. Please request and verify an OTP code first.'
    );
  end if;

  -- Insert submission
  insert into public.submissions (
    full_name,
    business_name,
    client_email,
    client_phone,
    domain,
    domain_idea,
    hosting,
    email,
    email_count,
    setup_help,
    business_desc,
    website_type,
    pages,
    other_pages,
    features,
    logo,
    content_text,
    content_photos,
    brand_colors,
    inspiration_links,
    timeline,
    maintenance,
    budget,
    extra_notes,
    estimated_total,
    price_breakdown,
    file_urls,
    request_time
  )
  values (
    p_data ->> 'full_name',
    p_data ->> 'business_name',
    p_data ->> 'client_email',
    p_data ->> 'client_phone',
    p_data ->> 'domain',
    p_data ->> 'domain_idea',
    p_data ->> 'hosting',
    p_data ->> 'email',
    (p_data ->> 'email_count')::int,
    p_data ->> 'setup_help',
    p_data ->> 'business_desc',
    p_data ->> 'website_type',
    (p_data ->> 'pages')::jsonb,
    p_data ->> 'other_pages',
    (p_data ->> 'features')::jsonb,
    p_data ->> 'logo',
    p_data ->> 'content_text',
    p_data ->> 'content_photos',
    p_data ->> 'brand_colors',
    p_data ->> 'inspiration_links',
    p_data ->> 'timeline',
    p_data ->> 'maintenance',
    p_data ->> 'budget',
    p_data ->> 'extra_notes',
    (p_data ->> 'estimated_total')::numeric,
    (p_data ->> 'price_breakdown')::jsonb,
    (p_data ->> 'file_urls')::jsonb,
    p_data ->> 'request_time'
  )
  returning id into v_submission_id;

  return jsonb_build_object(
    'success', true,
    'message', 'Submission created successfully.',
    'submission_id', v_submission_id
  );
end;
$$;

-- Grant execute on RPCs to anon role
grant execute on function public.verify_otp(text, text) to anon, authenticated;
grant execute on function public.submit_submission(jsonb, text, text) to anon, authenticated;
