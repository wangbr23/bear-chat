-- Ordered room event storage (T43), building on the T40 event-kind enum and
-- the T41/T42 profile and room tables.
--
-- Event rows are preserved when a non-owner profile is deleted, with sender
-- and target references cleared to represent deleted users. Deleting a room
-- permanently deletes its event history with the rest of the room.
--
-- Per-kind payload, target membership, and reference-order validation arrives
-- with the protected send_room_event function in T71. RLS and grants arrive
-- with T55; no client access is granted here.

create table public.room_events (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms (id) on delete cascade,
  sequence public.positive_bigint not null,
  sender_id uuid references public.profiles (user_id) on delete set null,
  client_event_id uuid not null,
  kind public.room_event_kind not null,
  payload jsonb not null,
  target_user_id uuid references public.profiles (user_id) on delete set null,
  referenced_event_id uuid,
  created_at timestamptz not null default now(),
  constraint room_events_room_sequence_key unique (room_id, sequence),
  constraint room_events_room_id_id_key unique (room_id, id),
  constraint room_events_referenced_event_fk foreign key (
    room_id,
    referenced_event_id
  ) references public.room_events (room_id, id),
  constraint room_events_payload_object check (
    coalesce(jsonb_typeof(payload) = 'object', false)
  )
);

create unique index room_events_sender_client_event_idx
  on public.room_events (room_id, sender_id, client_event_id)
  where sender_id is not null;

create index room_events_sender_id_idx on public.room_events (sender_id);
create index room_events_target_user_id_idx on public.room_events (target_user_id);
create index room_events_referenced_event_id_idx on public.room_events (referenced_event_id);
