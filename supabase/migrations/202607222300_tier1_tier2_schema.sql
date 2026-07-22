-- Migration: Add Tier 1+2 fields and fix CHECK constraints
-- Date: 2026-07-22
-- 
-- This migration:
-- 1. Adds primary_goal, business_maturity, budget_confidence, existing_assets,
--    other_website_type, has_company_profile, complexity_score columns
-- 2. Fixes timeline CHECK constraint to match new form values
-- 3. Adds 'other' to website_type CHECK constraint
-- 4. Updates submit_submission RPC to include all new fields

-- ============================================================
-- 1. Fix CHECK constraints
-- ============================================================

-- Fix timeline constraint — form sends: asap, 2-weeks, 1-month, 2-3-months, no-deadline
alter table public.submissions
  drop constraint if exists submissions_timeline_check;

alter table public.submissions
  add constraint submissions_timeline_check
  check (timeline in ('asap', '2-weeks', '1-month', '2-3-months', 'no-deadline'));

-- Fix website_type constraint — add 'other'
alter table public.submissions
  drop constraint if exists submissions_website_type_check;

alter table public.submissions
  add constraint submissions_website_type_check
  check (website_type in (
    'simple', 'business', 'portfolio', 'blog',
    'ecommerce-small', 'ecommerce-large',
    'booking', 'membership', 'directory', 'other'
  ));

-- ============================================================
-- 2. Add Tier 1+2 columns
-- ============================================================

alter table public.submissions
  add column if not exists primary_goal text;

alter table public.submissions
  add column if not exists business_maturity text;

alter table public.submissions
  add column if not exists budget_confidence text;

alter table public.submissions
  add column if not exists existing_assets jsonb default '[]'::jsonb;

alter table public.submissions
  add column if not exists other_website_type text;

alter table public.submissions
  add column if not exists has_company_profile boolean default false;

alter table public.submissions
  add column if not exists complexity_score int;

-- ============================================================
-- 3. Update submit_submission RPC to include all new fields
-- ============================================================

create or replace function public.submit_submission(p_data jsonb, p_email text, p_token text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_verified boolean;
  v_submission_id bigint;
  v_full_name text;
  v_token_ok boolean;
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

  -- If not OTP-verified, check for a valid share token
  if not v_verified then
    if p_token is not null then
      select exists (
        select 1
        from public.share_tokens
        where token = p_token
          and (email is null or email = p_email)
          and used = false
      ) into v_token_ok;

      if v_token_ok then
        -- Consume the token
        update public.share_tokens
        set used = true, used_at = now()
        where token = p_token;
        v_verified := true;
      end if;
    end if;
  end if;

  if not v_verified then
    return jsonb_build_object(
      'success', false,
      'message', 'Email not verified. Please request and verify an OTP code first, or use a valid share link.'
    );
  end if;

  -- Extract full_name from JSON data
  v_full_name := p_data ->> 'full_name';

  -- Insert submission
  insert into public.submissions (
    full_name,
    business_name,
    client_email,
    client_phone,
    pricing_mode,
    bundle_tier,
    primary_goal,
    business_maturity,
    budget_confidence,
    existing_assets,
    other_website_type,
    has_company_profile,
    domain,
    domain_idea,
    domain_years,
    hosting,
    hosting_months,
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
    coalesce(p_data ->> 'pricing_mode', 'per-item'),
    p_data ->> 'bundle_tier',
    p_data ->> 'primary_goal',
    p_data ->> 'business_maturity',
    p_data ->> 'budget_confidence',
    coalesce((p_data ->> 'existing_assets')::jsonb, '[]'::jsonb),
    p_data ->> 'other_website_type',
    coalesce((p_data ->> 'has_company_profile')::boolean, false),
    p_data ->> 'domain',
    p_data ->> 'domain_idea',
    (p_data ->> 'domain_years')::int,
    p_data ->> 'hosting',
    (p_data ->> 'hosting_months')::int,
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

-- Re-grant execute to anon (in case function was recreated)
grant execute on function public.submit_submission(jsonb, text, text) to anon;
grant execute on function public.submit_submission(jsonb, text, text) to authenticated;
