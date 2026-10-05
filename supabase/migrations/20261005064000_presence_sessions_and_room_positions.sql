-- Ephemeral room presence and latest movement state (T44), building on the
-- T40 normalized/positive domains and T42 room memberships.
--
-- Membership deletion cascades both tables so leaving or removal immediately
-- clears presence data. One user may be present from multiple installations,
-- but each installation can expose that user in only one selected room.
--
-- Lease lifecycle functions arrive with T72-T76, and RLS/grants arrive with
-- T56. No client access is granted here.

create table public.presence_sessions (
  room_id uuid not null,
  user_id uuid not null,
  connection_id uuid not null,
  installation_id uuid not null,
  lease_expires_at timestamptz not null,
  updated_at timestamptz not null default now(),
  primary key (room_id, user_id, connection_id),
  constraint presence_sessions_membership_fk foreign key (room_id, user_id)
    references public.room_members (room_id, user_id) on delete cascade,
  constraint presence_sessions_user_installation_key unique (user_id, installation_id),
  constraint presence_sessions_lease_after_update check (lease_expires_at > updated_at)
);

create index presence_sessions_room_expiry_idx
  on public.presence_sessions (room_id, lease_expires_at);

create table public.room_presence_state (
  room_id uuid not null,
  user_id uuid not null,
  destination_x public.normalized_coordinate not null,
  destination_y public.normalized_coordinate not null,
  movement_revision public.positive_bigint not null,
  updated_at timestamptz not null default now(),
  primary key (room_id, user_id),
  constraint room_presence_state_membership_fk foreign key (room_id, user_id)
    references public.room_members (room_id, user_id) on delete cascade
);
