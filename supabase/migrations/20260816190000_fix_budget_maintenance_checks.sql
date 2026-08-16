-- Fix live-DB check constraint mismatches that block client submissions.
--
-- Empirically verified against the live database (service-role inserts):
--   * email_count check is "between 1 and 5" on the live DB (set by a
--     dashboard-applied migration not present in this repo), but the intake
--     form sells 2 / 100 / Unlimited mailboxes -> any 100-mailbox or
--     Unlimited submission failed with submissions_email_count_check.
--   * maintenance check rejected 'none', but the form's "No maintenance"
--     option sends 'none' -> submissions_maintenance_check.
--   * budget check on live ALREADY accepts the real form values, so we keep
--     both old and new value sets for safety.
--
-- Relax email_count to match the intended schema (docs/schema.sql and the
-- form plans: 2, 100, unlimited -> 100).
alter table public.submissions drop constraint if exists submissions_email_count_check;
alter table public.submissions add constraint submissions_email_count_check check (
  email_count between 1 and 100
);

-- Accept the form's "No maintenance" value ('none') in addition to 'no'.
alter table public.submissions drop constraint if exists submissions_maintenance_check;
alter table public.submissions add constraint submissions_maintenance_check check (
  maintenance in ('no', 'none', 'basic', 'standard', 'premium')
);

-- Budget: keep old + new value sets (both have existed at different times).
alter table public.submissions drop constraint if exists submissions_budget_check;
alter table public.submissions add constraint submissions_budget_check check (
  budget in (
    '100-300', '300-500', '500-1000', '1000+', 'not-sure',
    'under-1000', '1000-2500', '2500-5000', '5000-10000', 'over-10000'
  )
);