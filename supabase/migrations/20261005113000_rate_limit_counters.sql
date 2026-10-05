-- Operation-scoped fixed-window rate counters (T48), building on the T41
-- profiles table.
--
-- Protected database functions (T60-T81) keep each operation's limit and
-- window length as server constants and upsert one row per subject,
-- operation, and window bucket. Production values are deferred to T23 and
-- T172; no limit logic lives in this migration.
--
-- The operation label is constrained text rather than an enum: the LLD
-- reserves enums for stable closed states, and these internal labels may
-- gain entries as protected operations evolve. Window lengths are
-- intentionally not stored because each function derives its own buckets.
--
-- Rows are function-internal state with no client access; RLS and grants
-- are owned by T58. No client access is granted here.

create table public.rate_limit_counters (
  subject_user_id uuid not null references public.profiles (user_id) on delete cascade,
  operation text not null,
  window_start timestamptz not null,
  attempt_count integer not null default 1,
  updated_at timestamptz not null default now(),
  primary key (subject_user_id, operation, window_start),
  constraint rate_limit_counters_operation_check check (
    operation in (
      'event',
      'movement',
      'heartbeat',
      'invite',
      'join',
      'report',
      'device_registration'
    )
  ),
  constraint rate_limit_counters_attempt_count_check check (attempt_count >= 1)
);

-- Heartbeats and movement updates continuously create short-lived window
-- rows, so expired buckets must eventually be swept; this serves that scan.
create index rate_limit_counters_window_start_idx
  on public.rate_limit_counters (window_start);