-- Idempotent account-deletion jobs (T49), building on the T40
-- account_deletion_job_state enum and the T41 profiles table.
--
-- PostgreSQL and Supabase Auth cannot commit atomically, so each user carries
-- at most one job that begin_account_deletion (T81) creates or reuses and the
-- delete-account Edge Function (T164) advances: Auth-deletion attempts record
-- their time and a content-free error code, and success completes the job. A
-- pending job with an error code stays retryable (T165) while sign-in remains
-- blocked by deletion-pending state.
--
-- Deleting the profile removes the job with it. That makes the completed
-- state meaningful only while the user still exists: once the Auth identity
-- deletion cascades the profile away, the job is gone and no retry remains.
--
-- RLS and grants arrive with T59. No client access is granted here.

create table public.account_deletion_jobs (
  user_id uuid primary key references public.profiles (user_id) on delete cascade,
  state public.account_deletion_job_state not null default 'pending',
  requested_at timestamptz not null default now(),
  attempted_at timestamptz,
  completed_at timestamptz,
  error_code text,
  constraint account_deletion_jobs_completed_state_matches check (
    (state = 'completed') = (completed_at is not null)
  ),
  constraint account_deletion_jobs_error_code_bounded check (
    error_code is null or char_length(error_code) between 1 and 100
  )
);

-- The retry scheduler scans pending jobs; the partial index keeps completed
-- and removed users out of that scan.
create index account_deletion_jobs_pending_idx
  on public.account_deletion_jobs (requested_at)
  where state = 'pending';
