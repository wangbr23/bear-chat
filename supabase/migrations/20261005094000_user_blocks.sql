-- Directional user blocks (T46), building on T41 profiles.
--
-- The protected block mutation in T79 verifies shared-room eligibility. T58
-- owns client policies and grants; no client access is granted here.

create table public.user_blocks (
  blocker_id uuid not null references public.profiles (user_id) on delete cascade,
  blocked_id uuid not null references public.profiles (user_id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint user_blocks_distinct_users check (blocker_id <> blocked_id)
);

-- The primary key serves blocker-first checks; this supports checking the
-- reverse direction without scanning every block row.
create index user_blocks_blocked_id_idx
  on public.user_blocks (blocked_id, blocker_id);
