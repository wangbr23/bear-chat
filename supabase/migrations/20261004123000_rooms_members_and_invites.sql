-- rooms, room_members, and room_invites (T42), building on the T40
-- enums/domains and T41 profiles table.
--
-- Room deletion is a hard delete. Dependent memberships and invitations
-- cascade from the room, matching the approved immediate-purge behavior.
--
-- Cross-row invariants stay in the protected room functions that own those
-- transactions: T61 creates the room, owner membership, and first invite;
-- T64 enforces the eight-member cap while joining; and T67 keeps owner_id and
-- the owner role synchronized during transfer. The partial unique index here
-- prevents two owner-role rows from existing for one room.
--
-- RLS and grants arrive with T54. No client access is granted here.

create table public.rooms (
  id uuid primary key default gen_random_uuid(),
  name public.bounded_room_name not null,
  owner_id uuid not null references public.profiles (user_id) on delete restrict,
  layout_id text not null default 'lodge-v1',
  next_event_sequence public.positive_bigint not null default 1,
  created_at timestamptz not null default now(),
  constraint rooms_layout_id_supported check (layout_id = 'lodge-v1')
);

create index rooms_owner_id_idx on public.rooms (owner_id);

create table public.room_members (
  room_id uuid not null references public.rooms (id) on delete cascade,
  user_id uuid not null references public.profiles (user_id) on delete cascade,
  role public.room_member_role not null,
  joined_at timestamptz not null default now(),
  is_muted boolean not null default false,
  last_acknowledged_sequence bigint not null default 0,
  primary key (room_id, user_id),
  constraint room_members_acknowledged_sequence_nonnegative check (
    last_acknowledged_sequence >= 0
  )
);

create index room_members_user_id_idx on public.room_members (user_id);

create unique index room_members_one_owner_per_room_idx
  on public.room_members (room_id)
  where role = 'owner';

create table public.room_invites (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms (id) on delete cascade,
  creator_id uuid not null references public.profiles (user_id) on delete cascade,
  token_digest bytea not null,
  expires_at timestamptz not null,
  max_uses public.positive_bigint,
  use_count bigint not null default 0,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  constraint room_invites_token_digest_key unique (token_digest),
  constraint room_invites_token_digest_size check (octet_length(token_digest) = 32),
  constraint room_invites_expiry_after_creation check (expires_at > created_at),
  constraint room_invites_use_count_nonnegative check (use_count >= 0),
  constraint room_invites_use_count_within_limit check (
    max_uses is null or use_count <= max_uses
  ),
  constraint room_invites_revoked_after_creation check (
    revoked_at is null or revoked_at >= created_at
  )
);

create index room_invites_room_id_idx on public.room_invites (room_id);
create index room_invites_creator_id_idx on public.room_invites (creator_id);
