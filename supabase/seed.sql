-- Synthetic local seed fixtures (T50), applied by `supabase db reset` after
-- migrations. Local development data only: never referenced by tests, and
-- never provisioned to hosted environments.
--
-- Fixtures span every approved table family except asset_catalog_entries,
-- which T51 seeds from the T22 approved catalog release. Event payload
-- shapes follow the LLD's versioned payload variants with synthetic semantic
-- IDs; report category/status are placeholder value sets pending the T9/T13
-- approvals. Presence leases are intentionally long-lived so the room scene
-- has active bears to render between resets.
--
-- Identities use seed- prefixed emails and the shared development password
-- `bear-chat-dev` (bcrypt via pgcrypto). IDs use a0000000/b0000000/... prefixes
-- that no test fixture uses, and event sequences stay contiguous with each
-- room's next_event_sequence per INV-4.

insert into auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values
  ('a0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'seed-maple@example.com', crypt('bear-chat-dev', gen_salt('bf')), now(), now(), now()),
  ('a0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'seed-cedar@example.com', crypt('bear-chat-dev', gen_salt('bf')), now(), now(), now()),
  ('a0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'seed-birch@example.com', crypt('bear-chat-dev', gen_salt('bf')), now(), now(), now()),
  ('a0000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'seed-rowan@example.com', crypt('bear-chat-dev', gen_salt('bf')), now(), now(), now()),
  ('a0000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'seed-willow@example.com', crypt('bear-chat-dev', gen_salt('bf')), now(), now(), now());

insert into public.profiles (user_id, display_name, appearance, revision)
values
  (
    'a0000000-0000-0000-0000-000000000001',
    'Maple Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-amber","accentColorID":"accent-red","clothingIDs":["scarf-green"],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    'a0000000-0000-0000-0000-000000000002',
    'Cedar Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-calm","furColorID":"fur-cocoa","accentColorID":"accent-blue","clothingIDs":[],"accessoryIDs":["cap-red"]}'::jsonb,
    1
  ),
  (
    'a0000000-0000-0000-0000-000000000003',
    'Birch Bear',
    '{"schemaVersion":1,"bodyID":"body-polar","faceID":"face-happy","furColorID":"fur-snow","accentColorID":"accent-green","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    'a0000000-0000-0000-0000-000000000004',
    'Rowan Bear',
    '{"schemaVersion":1,"bodyID":"body-black","faceID":"face-calm","furColorID":"fur-midnight","accentColorID":"accent-orange","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    'a0000000-0000-0000-0000-000000000005',
    'Willow Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-sleepy","furColorID":"fur-honey","accentColorID":"accent-purple","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

insert into public.rooms (id, name, owner_id, next_event_sequence)
values
  ('b0000000-0000-0000-0000-000000000001', 'Lakeside Lodge', 'a0000000-0000-0000-0000-000000000001', 7),
  ('b0000000-0000-0000-0000-000000000002', 'Hillside Hollow', 'a0000000-0000-0000-0000-000000000004', 3);

insert into public.room_members (room_id, user_id, role, is_muted, last_acknowledged_sequence)
values
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'owner', false, 6),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'member', false, 6),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'member', true, 4),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', 'owner', false, 2),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'member', false, 2),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'member', false, 2);

insert into public.room_invites (id, room_id, creator_id, token_digest, expires_at, revoked_at)
values
  ('d0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', decode(repeat('5e', 32), 'hex'), now() + interval '7 days', null),
  ('d0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', decode(repeat('5f', 32), 'hex'), now() + interval '7 days', now()),
  ('d0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', decode(repeat('5d', 32), 'hex'), now() + interval '7 days', null);

insert into public.room_events (
    id, room_id, sequence, sender_id, client_event_id,
    kind, payload, target_user_id, referenced_event_id
  )
values
  (
    'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 1,
    'a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001',
    'text', '{"schemaVersion":1,"text":"Welcome to the lodge!"}'::jsonb,
    null, null
  ),
  (
    'c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 2,
    'a0000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000002',
    'text', '{"schemaVersion":1,"text":"The fire is warm today"}'::jsonb,
    null, null
  ),
  (
    'c0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', 3,
    'a0000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000003',
    'emote', '{"schemaVersion":1,"emoteID":"wave"}'::jsonb,
    null, null
  ),
  (
    'c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000001', 4,
    'a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000004',
    'group_action', '{"schemaVersion":1,"actionID":"dance"}'::jsonb,
    null, null
  ),
  (
    'c0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000001', 5,
    'a0000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000005',
    'interaction', '{"schemaVersion":1,"actionID":"pat"}'::jsonb,
    'a0000000-0000-0000-0000-000000000001', null
  ),
  (
    'c0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000001', 6,
    'a0000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000006',
    'reaction', '{"schemaVersion":1,"reactionID":"heart"}'::jsonb,
    null, 'c0000000-0000-0000-0000-000000000005'
  ),
  (
    'c0000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000002', 1,
    'a0000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000007',
    'text', '{"schemaVersion":1,"text":"Quiet afternoon in the hollow"}'::jsonb,
    null, null
  ),
  (
    'c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000002', 2,
    'a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000008',
    'text', '{"schemaVersion":1,"text":"Cedar and I just arrived"}'::jsonb,
    null, null
  );

-- Leases expire an hour after each reset so the room scene has active bears
-- to render; the lease lifecycle functions own real expiry in normal use.
insert into public.presence_sessions (room_id, user_id, connection_id, installation_id, lease_expires_at)
values
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', now() + interval '1 hour'),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', now() + interval '1 hour'),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000003', now() + interval '1 hour');

insert into public.room_presence_state (room_id, user_id, destination_x, destination_y, movement_revision)
values
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 0.40, 0.60, 3),
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 0.60, 0.55, 2),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004', 0.50, 0.50, 1);

insert into public.push_devices (user_id, installation_id, environment, token, preview_mode)
values
  ('a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'production', decode(repeat('aa', 16), 'hex'), 'generic'),
  ('a0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'sandbox', decode(repeat('bb', 16), 'hex'), 'detailed');

insert into public.user_blocks (blocker_id, blocked_id)
values
  ('a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000004');

-- Category and status are placeholder value sets pending the T9/T13
-- approvals; nothing reads them until the T80 report function exists.
insert into public.reports (
    id, reporter_id, room_id, reported_user_id, reported_event_id,
    disclosed_snapshot, category, status, retention_deadline
  )
values
  (
    '80000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000005',
    '{"senderName":"Birch Bear","eventSummary":"patted Maple Bear"}'::jsonb,
    'message_content',
    'received',
    now() + interval '30 days'
  );

-- A past fixed window keeps this row inert; protected functions own real
-- counters and production values arrive with T23/T172.
insert into public.rate_limit_counters (subject_user_id, operation, window_start, attempt_count)
values
  ('a0000000-0000-0000-0000-000000000001', 'event', '2026-01-01 00:00:00+00'::timestamptz, 3);

-- Willow owns no rooms, matching the approved resolution that account
-- deletion requires every owned room transferred or deleted first.
insert into public.account_deletion_jobs (user_id)
values
  ('a0000000-0000-0000-0000-000000000005');
