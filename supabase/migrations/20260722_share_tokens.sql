-- ============================================================
-- Migration: Share Tokens (one-time unique client links)
-- ============================================================

-- 0. Ensure pgcrypto (for gen_random_bytes)
create extension if not exists pgcrypto;

-- 1. share_tokens table
create table if not exists public.share_tokens (
  id          bigint generated always as identity primary key,
  email       text,
  token       text not null unique,
  full_name   text,
  used        boolean default false,
  used_by_ip  text,
  created_at  timestamptz default now(),
  used_at     timestamptz
);

create index if not exists idx_share_tokens_token on public.share_tokens (token);

-- 2. RLS
alter table public.share_tokens enable row level security;

create policy "Authenticated users can view share_tokens"
  on public.share_tokens for select
  to authenticated
  using (true);

create policy "Authenticated users can insert share_tokens"
  on public.share_tokens for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update share_tokens"
  on public.share_tokens for update
  to authenticated
  using (true)
  with check (true);

-- 3. RPC: generate_share_token
create or replace function public.generate_share_token(p_full_name text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_token text;
begin
  v_token := encode(extensions.gen_random_bytes(16), 'hex');
  insert into public.share_tokens (email, token, full_name)
  values (null, v_token, p_full_name);
  return jsonb_build_object('success', true, 'token', v_token, 'full_name', p_full_name);
end;
$$;

-- 4. RPC: validate_share_token
create or replace function public.validate_share_token(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_record record;
begin
  select email, full_name, used into v_record
  from public.share_tokens where token = p_token;
  if not found then
    return jsonb_build_object('valid', false, 'message', 'Invalid token.');
  end if;
  if v_record.used then
    return jsonb_build_object('valid', false, 'message', 'This link has already been used. Please contact us for a new link.');
  end if;
  return jsonb_build_object('valid', true, 'email', v_record.email, 'full_name', v_record.full_name, 'has_email', v_record.email is not null);
end;
$$;

-- 5. RPC: consume_share_token
create or replace function public.consume_share_token(p_token text, p_ip text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.share_tokens
  set used = true, used_at = now(), used_by_ip = p_ip
  where token = p_token and used = false;
  if not found then
    return jsonb_build_object('success', false, 'message', 'Token not found or already used.');
  end if;
  return jsonb_build_object('success', true, 'message', 'Token consumed.');
end;
$$;

-- 6. Update submit_submission to accept optional token
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
  -- Check OTP verification (within last 10 minutes)
  select exists (
    select 1 from public.otp_codes
    where email = p_email and used = true and verified_at is not null
      and verified_at > now() - interval '10 minutes'
  ) into v_verified;

  -- Fallback to share token
  if not v_verified then
    if p_token is not null then
      select exists (
        select 1 from public.share_tokens
        where token = p_token and (email is null or email = p_email) and used = false
      ) into v_token_ok;
      if v_token_ok then
        update public.share_tokens set used = true, used_at = now() where token = p_token;
        v_verified := true;
      end if;
    end if;
  end if;

  if not v_verified then
    return jsonb_build_object('success', false, 'message', 'Email not verified. Please request and verify an OTP code first, or use a valid share link.');
  end if;

  v_full_name := p_data ->> 'full_name';

  insert into public.submissions (
    full_name, business_name, client_email, client_phone,
    domain, domain_idea, domain_years, hosting, hosting_months,
    email, email_count, setup_help,
    business_desc, website_type, pages, other_pages, features,
    logo, content_text, content_photos, brand_colors, inspiration_links,
    timeline, maintenance, budget, extra_notes,
    estimated_total, price_breakdown, file_urls, request_time
  ) values (
    p_data ->> 'full_name', p_data ->> 'business_name', p_data ->> 'client_email', p_data ->> 'client_phone',
    p_data ->> 'domain', p_data ->> 'domain_idea', (p_data ->> 'domain_years')::int,
    p_data ->> 'hosting', (p_data ->> 'hosting_months')::int,
    p_data ->> 'email', (p_data ->> 'email_count')::int, p_data ->> 'setup_help',
    p_data ->> 'business_desc', p_data ->> 'website_type', (p_data ->> 'pages')::jsonb,
    p_data ->> 'other_pages', (p_data ->> 'features')::jsonb,
    p_data ->> 'logo', p_data ->> 'content_text', p_data ->> 'content_photos',
    p_data ->> 'brand_colors', p_data ->> 'inspiration_links',
    p_data ->> 'timeline', p_data ->> 'maintenance', p_data ->> 'budget', p_data ->> 'extra_notes',
    (p_data ->> 'estimated_total')::numeric, (p_data ->> 'price_breakdown')::jsonb,
    (p_data ->> 'file_urls')::jsonb, p_data ->> 'request_time'
  ) returning id into v_submission_id;

  return jsonb_build_object('success', true, 'message', 'Submission created successfully.', 'submission_id', v_submission_id);
end;
$$;

-- 7. Grants
grant execute on function public.generate_share_token(text) to authenticated;
grant execute on function public.validate_share_token(text) to anon, authenticated;
grant execute on function public.consume_share_token(text, text) to anon, authenticated;
