-- Migration: Drop old 2-param submit_submission overload
-- The new 3-param version (with p_token default null) already exists
-- from 202607222310, but the old 2-param version wasn't automatically
-- replaced because the function signatures differ.

drop function if exists public.submit_submission(p_data jsonb, p_email text);
