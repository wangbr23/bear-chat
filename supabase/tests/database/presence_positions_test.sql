begin;

select plan(57);

select has_table('public', 'presence_sessions', 'the presence sessions table exists');

select columns_are(
  'public',
  'presence_sessions',
  array[
    'room_id',
    'user_id',
    'connection_id',
    'installation_id',
    'lease_expires_at',
    'updated_at'
  ]
);

select col_type_is('public', 'presence_sessions', 'room_id', 'uuid', 'presence room id is a uuid');
select col_type_is('public', 'presence_sessions', 'user_id', 'uuid', 'presence user id is a uuid');
select col_type_is(
  'public',
  'presence_sessions',
  'connection_id',
  'uuid',
  'presence connection id is a uuid'
);
select col_type_is(
  'public',
  'presence_sessions',
  'installation_id',
  'uuid',
  'presence installation id is a uuid'
);
select col_type_is(
  'public',
  'presence_sessions',
  'lease_expires_at',
  'timestamp with time zone',
  'presence lease expiry is a timestamptz'
);
select col_type_is(
  'public',
  'presence_sessions',
  'updated_at',
  'timestamp with time zone',
  'presence update time is a timestamptz'
);

select col_not_null('public', 'presence_sessions', 'room_id', 'presence room id is not null');
select col_not_null('public', 'presence_sessions', 'user_id', 'presence user id is not null');
select col_not_null(
  'public',
  'presence_sessions',
  'connection_id',
  'presence connection id is not null'
);
select col_not_null(
  'public',
  'presence_sessions',
  'installation_id',
  'presence installation id is not null'
);
select col_not_null(
  'public',
  'presence_sessions',
  'lease_expires_at',
  'presence lease expiry is not null'
);
select col_not_null('public', 'presence_sessions', 'updated_at', 'presence update time is not null');
select col_is_pk(
  'public',
  'presence_sessions',
  array['room_id', 'user_id', 'connection_id'],
  'presence sessions use the room, user, and connection composite primary key'
);
select fk_ok(
  'public',
  'presence_sessions',
  array['room_id', 'user_id'],
  'public',
  'room_members',
  array['room_id', 'user_id'],
  'presence sessions belong to a current room membership'
);

select has_table('public', 'room_presence_state', 'the room presence state table exists');

select columns_are(
  'public',
  'room_presence_state',
  array[
    'room_id',
    'user_id',
    'destination_x',
    'destination_y',
    'movement_revision',
    'updated_at'
  ]
);

select col_type_is('public', 'room_presence_state', 'room_id', 'uuid', 'state room id is a uuid');
select col_type_is('public', 'room_presence_state', 'user_id', 'uuid', 'state user id is a uuid');
select col_type_is(
  'public',
  'room_presence_state',
  'destination_x',
  'normalized_coordinate',
  'state destination x uses the normalized coordinate domain'
);
select col_type_is(
  'public',
  'room_presence_state',
  'destination_y',
  'normalized_coordinate',
  'state destination y uses the normalized coordinate domain'
);
select col_type_is(
  'public',
  'room_presence_state',
  'movement_revision',
  'positive_bigint',
  'state movement revision uses the positive bigint domain'
);
select col_type_is(
  'public',
  'room_presence_state',
  'updated_at',
  'timestamp with time zone',
  'state update time is a timestamptz'
);

select col_not_null('public', 'room_presence_state', 'room_id', 'state room id is not null');
select col_not_null('public', 'room_presence_state', 'user_id', 'state user id is not null');
select col_not_null(
  'public',
  'room_presence_state',
  'destination_x',
  'state destination x is not null'
);
select col_not_null(
  'public',
  'room_presence_state',
  'destination_y',
  'state destination y is not null'
);
select col_not_null(
  'public',
  'room_presence_state',
  'movement_revision',
  'state movement revision is not null'
);
select col_not_null('public', 'room_presence_state', 'updated_at', 'state update time is not null');
select col_is_pk(
  'public',
  'room_presence_state',
  array['room_id', 'user_id'],
  'room presence state uses the room and user composite primary key'
);
select fk_ok(
  'public',
  'room_presence_state',
  array['room_id', 'user_id'],
  'public',
  'room_members',
  array['room_id', 'user_id'],
  'room presence state belongs to a current room membership'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't44-owner@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't44-member@example.com'),
  ('33333333-3333-3333-3333-333333333333', 't44-nonmember@example.com'),
  ('44444444-4444-4444-4444-444444444444', 't44-cascade@example.com');

insert into public.profiles (user_id, display_name, appearance, revision)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'Owner Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Member Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Nonmember Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Cascade Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

insert into public.rooms (id, name, owner_id)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Presence Room',
    '11111111-1111-1111-1111-111111111111'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Cascade Room',
    '11111111-1111-1111-1111-111111111111'
  );

insert into public.room_members (room_id, user_id, role)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'owner'
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '22222222-2222-2222-2222-222222222222',
    'member'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '11111111-1111-1111-1111-111111111111',
    'owner'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '44444444-4444-4444-4444-444444444444',
    'member'
  );

select lives_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      'c0000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000001',
      now() + interval '30 seconds'
    )$$,
  'a current member can open a presence session'
);

select lives_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      'c0000000-0000-0000-0000-000000000002',
      '10000000-0000-0000-0000-000000000002',
      now() + interval '30 seconds'
    )$$,
  'the same user can be present from another installation'
);

select is(
  (
    select count(*)
    from public.presence_sessions
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'
  ),
  2::bigint,
  'multiple installations create separate presence sessions'
);

select throws_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      '11111111-1111-1111-1111-111111111111',
      'c0000000-0000-0000-0000-000000000003',
      '10000000-0000-0000-0000-000000000001',
      now() + interval '30 seconds'
    )$$,
  '23505',
  NULL,
  'one installation cannot expose a user in two rooms'
);

select throws_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      'c0000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000003',
      now() + interval '30 seconds'
    )$$,
  '23505',
  NULL,
  'a connection id cannot be duplicated for the same room member'
);

select throws_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '33333333-3333-3333-3333-333333333333',
      'c0000000-0000-0000-0000-000000000004',
      '30000000-0000-0000-0000-000000000001',
      now() + interval '30 seconds'
    )$$,
  '23503',
  NULL,
  'a nonmember cannot have a presence session'
);

select throws_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at,
      updated_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'c0000000-0000-0000-0000-000000000005',
      '20000000-0000-0000-0000-000000000001',
      '2026-10-05 12:00:00+00',
      '2026-10-05 12:00:00+00'
    )$$,
  '23514',
  NULL,
  'a lease must expire after its update time'
);

select throws_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at,
      updated_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'c0000000-0000-0000-0000-000000000006',
      '20000000-0000-0000-0000-000000000002',
      '2026-10-05 11:59:59+00',
      '2026-10-05 12:00:00+00'
    )$$,
  '23514',
  NULL,
  'a lease cannot expire before its update time'
);

select lives_ok(
  $$insert into public.presence_sessions (
      room_id,
      user_id,
      connection_id,
      installation_id,
      lease_expires_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'c0000000-0000-0000-0000-000000000007',
      '20000000-0000-0000-0000-000000000003',
      now() + interval '30 seconds'
    )$$,
  'another current member can open a presence session'
);

select lives_ok(
  $$insert into public.room_presence_state (
      room_id,
      user_id,
      destination_x,
      destination_y,
      movement_revision
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      0.5,
      0.5,
      1
    )$$,
  'a current member can have room presence state'
);

select lives_ok(
  $$insert into public.room_presence_state (
      room_id,
      user_id,
      destination_x,
      destination_y,
      movement_revision
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      0,
      0,
      1
    )$$,
  'zero is a valid destination boundary'
);

select lives_ok(
  $$update public.room_presence_state
    set destination_x = 1, destination_y = 1
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '22222222-2222-2222-2222-222222222222'$$,
  'one is a valid destination boundary'
);

select throws_ok(
  $$update public.room_presence_state
    set destination_x = -0.01
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a destination x below zero is rejected'
);

select throws_ok(
  $$update public.room_presence_state
    set destination_x = 1.01
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a destination x above one is rejected'
);

select throws_ok(
  $$update public.room_presence_state
    set destination_y = -0.01
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a destination y below zero is rejected'
);

select throws_ok(
  $$update public.room_presence_state
    set destination_y = 1.01
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a destination y above one is rejected'
);

select throws_ok(
  $$update public.room_presence_state
    set movement_revision = 0
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a zero movement revision is rejected'
);

select throws_ok(
  $$insert into public.room_presence_state (
      room_id,
      user_id,
      destination_x,
      destination_y,
      movement_revision
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      0.25,
      0.75,
      2
    )$$,
  '23505',
  NULL,
  'a room member has only one latest movement state'
);

select throws_ok(
  $$insert into public.room_presence_state (
      room_id,
      user_id,
      destination_x,
      destination_y,
      movement_revision
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '33333333-3333-3333-3333-333333333333',
      0.25,
      0.75,
      1
    )$$,
  '23503',
  NULL,
  'a nonmember cannot have room presence state'
);

select lives_ok(
  $$update public.room_presence_state
    set destination_x = 0.75, destination_y = 0.25, movement_revision = 2
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'$$,
  'a higher movement revision is accepted'
);

select is(
  (
    select movement_revision::bigint
    from public.room_presence_state
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'
  ),
  2::bigint,
  'the latest movement revision is stored'
);

delete from public.room_members
where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
  and user_id = '22222222-2222-2222-2222-222222222222';

select is_empty(
  $$select 1 from public.presence_sessions
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '22222222-2222-2222-2222-222222222222'$$,
  'deleting a membership deletes its presence sessions'
);

select is_empty(
  $$select 1 from public.room_presence_state
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '22222222-2222-2222-2222-222222222222'$$,
  'deleting a membership deletes its room presence state'
);

insert into public.presence_sessions (
  room_id,
  user_id,
  connection_id,
  installation_id,
  lease_expires_at
) values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '44444444-4444-4444-4444-444444444444',
  'c0000000-0000-0000-0000-000000000008',
  '40000000-0000-0000-0000-000000000001',
  now() + interval '30 seconds'
);

insert into public.room_presence_state (
  room_id,
  user_id,
  destination_x,
  destination_y,
  movement_revision
) values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '44444444-4444-4444-4444-444444444444',
  0.5,
  0.5,
  1
);

delete from public.rooms
where id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

select is_empty(
  $$select 1 from public.presence_sessions
    where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'$$,
  'deleting a room deletes its presence sessions'
);

select is_empty(
  $$select 1 from public.room_presence_state
    where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'$$,
  'deleting a room deletes its room presence state'
);

select * from finish();

rollback;
