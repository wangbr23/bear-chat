begin;

select plan(59);

select has_table('public', 'room_events', 'the room events table exists');

select columns_are(
  'public',
  'room_events',
  array[
    'id',
    'room_id',
    'sequence',
    'sender_id',
    'client_event_id',
    'kind',
    'payload',
    'target_user_id',
    'referenced_event_id',
    'created_at'
  ]
);

select col_type_is('public', 'room_events', 'id', 'uuid', 'room_events.id is a uuid');
select col_type_is('public', 'room_events', 'room_id', 'uuid', 'room_events.room_id is a uuid');
select col_type_is(
  'public',
  'room_events',
  'sequence',
  'positive_bigint',
  'room_events.sequence uses the positive bigint domain'
);
select col_type_is('public', 'room_events', 'sender_id', 'uuid', 'room_events.sender_id is a uuid');
select col_type_is(
  'public',
  'room_events',
  'client_event_id',
  'uuid',
  'room_events.client_event_id is a uuid'
);
select col_type_is(
  'public',
  'room_events',
  'kind',
  'room_event_kind',
  'room_events.kind uses the room event kind enum'
);
select col_type_is('public', 'room_events', 'payload', 'jsonb', 'room_events.payload is jsonb');
select col_type_is(
  'public',
  'room_events',
  'target_user_id',
  'uuid',
  'room_events.target_user_id is a uuid'
);
select col_type_is(
  'public',
  'room_events',
  'referenced_event_id',
  'uuid',
  'room_events.referenced_event_id is a uuid'
);
select col_type_is(
  'public',
  'room_events',
  'created_at',
  'timestamp with time zone',
  'room_events.created_at is a timestamptz'
);

select col_not_null('public', 'room_events', 'id', 'room_events.id is not null');
select col_not_null('public', 'room_events', 'room_id', 'room_events.room_id is not null');
select col_not_null('public', 'room_events', 'sequence', 'room_events.sequence is not null');
select col_is_null('public', 'room_events', 'sender_id', 'room_events.sender_id is nullable');
select col_not_null(
  'public',
  'room_events',
  'client_event_id',
  'room_events.client_event_id is not null'
);
select col_not_null('public', 'room_events', 'kind', 'room_events.kind is not null');
select col_not_null('public', 'room_events', 'payload', 'room_events.payload is not null');
select col_is_null('public', 'room_events', 'target_user_id', 'room_events.target_user_id is nullable');
select col_is_null(
  'public',
  'room_events',
  'referenced_event_id',
  'room_events.referenced_event_id is nullable'
);
select col_not_null('public', 'room_events', 'created_at', 'room_events.created_at is not null');
select col_is_pk('public', 'room_events', 'id', 'room_events.id is the primary key');

select fk_ok(
  'public',
  'room_events',
  'room_id',
  'public',
  'rooms',
  'id',
  'room_events.room_id references rooms.id'
);
select fk_ok(
  'public',
  'room_events',
  'sender_id',
  'public',
  'profiles',
  'user_id',
  'room_events.sender_id references profiles.user_id'
);
select fk_ok(
  'public',
  'room_events',
  'target_user_id',
  'public',
  'profiles',
  'user_id',
  'room_events.target_user_id references profiles.user_id'
);
select fk_ok(
  'public',
  'room_events',
  array['room_id', 'referenced_event_id'],
  'public',
  'room_events',
  array['room_id', 'id'],
  'room_events references events in the same room'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't43-owner@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't43-sender-a@example.com'),
  ('33333333-3333-3333-3333-333333333333', 't43-sender-b@example.com'),
  ('44444444-4444-4444-4444-444444444444', 't43-target@example.com');

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
    'Sender A',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Sender B',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Target Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

insert into public.rooms (id, name, owner_id)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'First Event Room',
    '11111111-1111-1111-1111-111111111111'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Second Event Room',
    '11111111-1111-1111-1111-111111111111'
  );

select lives_ok(
  $$insert into public.room_events (
      id,
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'eeeeeeee-0000-0000-0000-000000000001',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      1,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000001',
      'text',
      '{"schemaVersion":1,"text":"hello"}'::jsonb
    )$$,
  'a valid text event is accepted'
);

select lives_ok(
  $$insert into public.room_events (
      id,
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload,
      target_user_id,
      referenced_event_id
    ) values (
      'eeeeeeee-0000-0000-0000-000000000002',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      2,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000002',
      'reaction',
      '{"schemaVersion":1,"reactionID":"heart"}'::jsonb,
      '44444444-4444-4444-4444-444444444444',
      'eeeeeeee-0000-0000-0000-000000000001'
    )$$,
  'an event can carry target and referenced-event relationships'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      3,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000003',
      'emote',
      '{"schemaVersion":1,"emoteID":"wave"}'::jsonb
    )$$,
  'an event can use generated defaults'
);

select ok(
  (
    select id is not null
    from public.room_events
    where client_event_id = 'cccccccc-0000-0000-0000-000000000003'
  ),
  'an event id is generated by PostgreSQL'
);

select ok(
  (
    select created_at is not null
    from public.room_events
    where client_event_id = 'cccccccc-0000-0000-0000-000000000003'
  ),
  'an event creation time is generated by PostgreSQL'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      4,
      null,
      'cccccccc-0000-0000-0000-000000000004',
      'text',
      '{"schemaVersion":1,"text":"deleted sender one"}'::jsonb
    )$$,
  'an event may represent a deleted sender'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      5,
      null,
      'cccccccc-0000-0000-0000-000000000004',
      'text',
      '{"schemaVersion":1,"text":"deleted sender two"}'::jsonb
    )$$,
  'deleted-sender events do not collide on client event id'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      1,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000005',
      'text',
      '{"schemaVersion":1,"text":"duplicate sequence"}'::jsonb
    )$$,
  '23505',
  NULL,
  'an event sequence cannot repeat within a room'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      1,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000005',
      'text',
      '{"schemaVersion":1,"text":"other room"}'::jsonb
    )$$,
  'the same sequence can exist in another room'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      6,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000001',
      'text',
      '{"schemaVersion":1,"text":"duplicate retry identity"}'::jsonb
    )$$,
  '23505',
  NULL,
  'a sender client event id cannot repeat within a room'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      2,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000001',
      'text',
      '{"schemaVersion":1,"text":"same retry id in another room"}'::jsonb
    )$$,
  'a sender client event id may repeat in another room'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      6,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000001',
      'text',
      '{"schemaVersion":1,"text":"same retry id from another sender"}'::jsonb
    )$$,
  'a client event id may repeat for another sender'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      0,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000006',
      'text',
      '{"schemaVersion":1,"text":"bad sequence"}'::jsonb
    )$$,
  '23514',
  NULL,
  'a zero event sequence is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      '99999999-9999-9999-9999-999999999999',
      1,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000007',
      'text',
      '{"schemaVersion":1,"text":"unknown room"}'::jsonb
    )$$,
  '23503',
  NULL,
  'an event for an unknown room is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '99999999-9999-9999-9999-999999999999',
      'cccccccc-0000-0000-0000-000000000008',
      'text',
      '{"schemaVersion":1,"text":"unknown sender"}'::jsonb
    )$$,
  '23503',
  NULL,
  'an event with an unknown sender is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload,
      target_user_id
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000009',
      'interaction',
      '{"schemaVersion":1,"actionID":"hug"}'::jsonb,
      '99999999-9999-9999-9999-999999999999'
    )$$,
  '23503',
  NULL,
  'an event with an unknown target is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload,
      referenced_event_id
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000010',
      'reaction',
      '{"schemaVersion":1,"reactionID":"heart"}'::jsonb,
      'eeeeeeee-9999-9999-9999-999999999999'
    )$$,
  '23503',
  NULL,
  'an event with an unknown referenced event is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload,
      referenced_event_id
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000016',
      'reaction',
      '{"schemaVersion":1,"reactionID":"heart"}'::jsonb,
      (
        select id
        from public.room_events
        where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
          and sequence = 1
      )
    )$$,
  '23503',
  NULL,
  'an event cannot reference an event from another room'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000011',
      'text',
      '[]'::jsonb
    )$$,
  '23514',
  NULL,
  'an array event payload is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000012',
      'text',
      '"text"'::jsonb
    )$$,
  '23514',
  NULL,
  'a scalar event payload is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000013',
      'text',
      'null'::jsonb
    )$$,
  '23514',
  NULL,
  'a JSON null event payload is rejected'
);

select throws_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      100,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000014',
      'unknown',
      '{}'::jsonb
    )$$,
  '22P02',
  NULL,
  'an unknown event kind is rejected'
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      7,
      '33333333-3333-3333-3333-333333333333',
      'cccccccc-0000-0000-0000-000000000015',
      'text',
      '{}'::jsonb
    )$$,
  'the table accepts an object for later per-kind validation'
);

delete from public.profiles
where user_id = '22222222-2222-2222-2222-222222222222';

select is(
  (
    select sender_id
    from public.room_events
    where id = 'eeeeeeee-0000-0000-0000-000000000001'
  ),
  null::uuid,
  'deleting a sender profile clears the event sender'
);

select is(
  (
    select count(*)
    from public.room_events
    where id = 'eeeeeeee-0000-0000-0000-000000000001'
  ),
  1::bigint,
  'deleting a sender profile preserves the event'
);

insert into public.profiles (user_id, display_name, appearance, revision)
values (
  '22222222-2222-2222-2222-222222222222',
  'Recreated Sender A',
  '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
  1
);

select lives_ok(
  $$insert into public.room_events (
      room_id,
      sequence,
      sender_id,
      client_event_id,
      kind,
      payload
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      8,
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-0000-0000-0000-000000000001',
      'text',
      '{"schemaVersion":1,"text":"new sender identity row"}'::jsonb
    )$$,
  'a deleted-sender event no longer reserves its retry identity'
);

delete from public.profiles
where user_id = '44444444-4444-4444-4444-444444444444';

select is(
  (
    select target_user_id
    from public.room_events
    where id = 'eeeeeeee-0000-0000-0000-000000000002'
  ),
  null::uuid,
  'deleting a target profile clears the event target'
);

select is(
  (
    select count(*)
    from public.room_events
    where id = 'eeeeeeee-0000-0000-0000-000000000002'
  ),
  1::bigint,
  'deleting a target profile preserves the event'
);

select throws_ok(
  $$delete from public.room_events
    where id = 'eeeeeeee-0000-0000-0000-000000000001'$$,
  '23503',
  NULL,
  'a referenced event cannot be deleted by itself'
);

select lives_ok(
  $$delete from public.rooms
    where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'$$,
  'a room and its referenced event graph can be deleted together'
);

select is_empty(
  $$select 1 from public.room_events
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'$$,
  'deleting a room deletes its event history'
);

select is(
  (
    select count(*)
    from public.room_events
    where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
  ),
  2::bigint,
  'deleting one room preserves another room event history'
);

select * from finish();

rollback;
