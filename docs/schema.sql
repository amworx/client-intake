-- ============================================================
-- AM Worx Client Intake — Supabase Schema
-- Run this in your Supabase SQL Editor (https://supabase.com)
-- ============================================================

-- 0. Extensions
create extension if not exists "pgcrypto";

-- ============================================================
-- 1. TABLES
-- ============================================================

-- 1.1 submissions
create table if not exists public.submissions (
  id            bigint generated always as identity primary key,
  created_at    timestamptz default now(),
  status        text default 'New' check (status in ('New', 'Reviewed')),

  -- Contact
  full_name      text not null,
  business_name  text,
  client_email   text not null,
  client_phone   text,

  -- Domain & Hosting
  domain         text check (domain in ('need', 'no-need', 'not-sure')),
  domain_idea    text,
  domain_years   int default 1 check (domain_years between 1 and 5),
  hosting        text check (hosting in ('need', 'no-need', 'not-sure')),
  hosting_months int default 12 check (hosting_months in (12, 24, 48)),
  email          text check (email in ('need', 'no-need', 'not-sure')),
  email_count    int default 1 check (email_count between 1 and 100),
  setup_help     text check (setup_help in ('yes', 'no')),

  -- Website
  business_desc  text,
  website_type   text check (website_type in (
    'simple', 'business', 'portfolio', 'blog',
    'ecommerce-small', 'ecommerce-large',
    'booking', 'membership', 'directory'
  )),
  pages          jsonb,
  other_pages    text,
  features       jsonb,

  -- Branding & Content
  logo           text check (logo in ('yes', 'have', 'later')),
  content_text   text check (content_text in ('self', 'need-help', 'ready')),
  content_photos text check (content_photos in ('my-own', 'free-stock', 'not-sure')),
  brand_colors   text,
  inspiration_links text,

  -- Timeline & Budget
  timeline       text check (timeline in ('1-week', '2-weeks', '1-month', 'flexible')),
  maintenance    text check (maintenance in ('no', 'basic', 'standard', 'premium')),
  budget         text check (budget in ('100-300', '300-500', '500-1000', '1000+', 'not-sure')),
  extra_notes    text,

  -- Pricing
  estimated_total    numeric(10,2),
  price_breakdown    jsonb,
  file_urls          jsonb,
  request_time       text
);

-- Index for sorting by newest first
create index if not exists idx_submissions_created_at on public.submissions (created_at desc);

-- 1.2 settings (singleton row)
create table if not exists public.settings (
  id                  int primary key check (id = 1),
  studio_name         text default 'AM Worx',
  studio_email        text default 'amworxx@gmail.com',
  form_url            text default '',
  auto_refresh_sec    int default 60,
  toast_duration_ms   int default 3000,
  session_expiry_hours int default 24,
  date_style          text default 'medium' check (date_style in ('short', 'medium', 'long')),
  prices              jsonb default '{}'::jsonb,
  sections            jsonb default '{}'::jsonb,
  smtp_enabled        boolean default false,
  smtp_email          text default 'amworxx@gmail.com',
  smtp_password       text default '',
  updated_at          timestamptz default now()
);

-- 1.3 section_groups (reference for custom option groups)
create table if not exists public.section_groups (
  section_key  text primary key,
  groups       jsonb not null default '[]'::jsonb
);

-- 1.4 otp_codes
create table if not exists public.otp_codes (
  id          bigint generated always as identity primary key,
  email       text not null,
  code        text not null,
  expires_at  timestamptz not null,
  used        boolean default false,
  verified_at timestamptz       -- set when OTP is successfully verified
);

-- Index for OTP verification lookups
create index if not exists idx_otp_codes_email on public.otp_codes (email, code);

-- ============================================================
-- 2. STORAGE BUCKET
-- ============================================================

insert into storage.buckets (id, name, public)
values ('submissions', 'submissions', true)
on conflict (id) do nothing;

-- ============================================================
-- 3. ROW LEVEL SECURITY
-- ============================================================

-- 3.1 Enable RLS on all tables
alter table public.submissions enable row level security;
alter table public.settings enable row level security;
alter table public.section_groups enable row level security;
alter table public.otp_codes enable row level security;

-- 3.2 submissions policies
-- NOTE: anon INSERT on submissions is intentionally removed.
-- All submissions go through the submit_submission() RPC (SECURITY DEFINER),
-- which enforces OTP verification server-side.

create policy "Authenticated users can insert submissions"
  on public.submissions for insert
  to authenticated
  with check (true);

create policy "Authenticated users can view submissions"
  on public.submissions for select
  to authenticated
  using (true);

create policy "Authenticated users can update submissions"
  on public.submissions for update
  to authenticated
  using (true)
  with check (true);

create policy "Authenticated users can delete submissions"
  on public.submissions for delete
  to authenticated
  using (true);

-- 3.3 settings policies
create policy "Anyone can read settings"
  on public.settings for select
  to anon, authenticated
  using (true);

create policy "Authenticated users can update settings"
  on public.settings for update
  to authenticated
  using (true)
  with check (true);

-- 3.4 section_groups policies
create policy "Anyone can read section groups"
  on public.section_groups for select
  to anon, authenticated
  using (true);

-- 3.5 otp_codes policies
create policy "Anyone can insert OTP codes"
  on public.otp_codes for insert
  to anon, authenticated
  with check (true);

-- NOTE: anon SELECT and anon UPDATE on otp_codes are intentionally removed.
-- All verification goes through the verify_otp() RPC (SECURITY DEFINER).
-- This prevents attackers from reading or manipulating OTP codes directly.

-- RPC-only access — no anon SELECT/UPDATE policies for otp_codes

-- 3.6 Storage policies
create policy "Anyone can upload files"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'submissions');

create policy "Anyone can read files"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'submissions');

create policy "Authenticated users can delete files"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'submissions');

-- ============================================================
-- 4. SEED DATA
-- ============================================================

-- 4.1 Default settings row
insert into public.settings (id, studio_name, studio_email, prices, sections)
values (
  1,
  'AM Worx',
  'amworxx@gmail.com',
  '{}'::jsonb,
  '{}'::jsonb
) on conflict (id) do nothing;

-- 4.2 Section groups (maps each section to available custom option groups)
insert into public.section_groups (section_key, groups) values
  ('domain', '[{"label": "Domain Type", "value": "domain-type"}]'),
  ('hosting', '[{"label": "Hosting Type", "value": "hosting-type"}]'),
  ('email', '[{"label": "Email Service", "value": "email-service"}]'),
  ('website', '[
    {"label": "Website Type", "value": "website-type"},
    {"label": "Pages", "value": "pages"},
    {"label": "Features", "value": "features"}
  ]'),
  ('branding', '[{"label": "Branding Service", "value": "branding-service"}]'),
  ('timeline', '[{"label": "Timeline", "value": "timeline"}]'),
  ('maintenance', '[{"label": "Maintenance Plan", "value": "maintenance-plan"}]
') on conflict (section_key) do nothing;

-- ============================================================
-- 5. RPC FUNCTIONS (SECURITY DEFINER)
-- ============================================================

-- 5.1 verify_otp(email, code)
-- Checks the OTP code server-side, marks it verified, returns success/failure.
-- Called by the intake form (anon) to verify emails without exposing DB internals.
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

-- 5.2 submit_submission(data jsonb, email text)
-- Inserts a submission only if the email has been recently OTP-verified (within 10 minutes).
-- Called by the intake form (anon) to prevent submissions without email verification.
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

  -- Extract full_name from JSON data
  v_full_name := p_data ->> 'full_name';

  -- Insert submission
  insert into public.submissions (
    full_name,
    business_name,
    client_email,
    client_phone,
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

-- Grant execute on RPCs to anon role (needed for the intake form)
grant execute on function public.verify_otp(text, text) to anon, authenticated;
grant execute on function public.submit_submission(jsonb, text) to anon, authenticated;
