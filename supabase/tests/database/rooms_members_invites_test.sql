begin;

select plan(91);

select has_table('public', 'rooms', 'the rooms table exists');

select columns_are(
  'public',
  'rooms',
  array['id', 'name', 'owner_id', 'layout_id', 'next_event_sequence', 'created_at']
);

select col_type_is('public', 'rooms', 'id', 'uuid', 'rooms.id is a uuid');
select col_type_is('public', 'rooms', 'name', 'bounded_room_name', 'rooms.name uses the bounded room name domain');
select col_type_is('public', 'rooms', 'owner_id', 'uuid', 'rooms.owner_id is a uuid');
select col_type_is('public', 'rooms', 'layout_id', 'text', 'rooms.layout_id is text');
select col_type_is(
  'public',
  'rooms',
  'next_event_sequence',
  'positive_bigint',
  'rooms.next_event_sequence uses the positive bigint domain'
);
select col_type_is(
  'public',
  'rooms',
  'created_at',
  'timestamp with time zone',
  'rooms.created_at is a timestamptz'
);

select col_not_null('public', 'rooms', 'id', 'rooms.id is not null');
select col_not_null('public', 'rooms', 'name', 'rooms.name is not null');
select col_not_null('public', 'rooms', 'owner_id', 'rooms.owner_id is not null');
select col_not_null('public', 'rooms', 'layout_id', 'rooms.layout_id is not null');
select col_not_null('public', 'rooms', 'next_event_sequence', 'rooms.next_event_sequence is not null');
select col_not_null('public', 'rooms', 'created_at', 'rooms.created_at is not null');
select col_is_pk('public', 'rooms', 'id', 'rooms.id is the primary key');

select fk_ok(
  'public',
  'rooms',
  'owner_id',
  'public',
  'profiles',
  'user_id',
  'rooms.owner_id references profiles.user_id'
);

select has_table('public', 'room_members', 'the room members table exists');

select columns_are(
  'public',
  'room_members',
  array['room_id', 'user_id', 'role', 'joined_at', 'is_muted', 'last_acknowledged_sequence']
);

select col_type_is('public', 'room_members', 'room_id', 'uuid', 'room_members.room_id is a uuid');
select col_type_is('public', 'room_members', 'user_id', 'uuid', 'room_members.user_id is a uuid');
select col_type_is(
  'public',
  'room_members',
  'role',
  'room_member_role',
  'room_members.role uses the room member role enum'
);
select col_type_is(
  'public',
  'room_members',
  'joined_at',
  'timestamp with time zone',
  'room_members.joined_at is a timestamptz'
);
select col_type_is('public', 'room_members', 'is_muted', 'boolean', 'room_members.is_muted is boolean');
select col_type_is(
  'public',
  'room_members',
  'last_acknowledged_sequence',
  'bigint',
  'room_members.last_acknowledged_sequence is a bigint'
);

select col_not_null('public', 'room_members', 'room_id', 'room_members.room_id is not null');
select col_not_null('public', 'room_members', 'user_id', 'room_members.user_id is not null');
select col_not_null('public', 'room_members', 'role', 'room_members.role is not null');
select col_not_null('public', 'room_members', 'joined_at', 'room_members.joined_at is not null');
select col_not_null('public', 'room_members', 'is_muted', 'room_members.is_muted is not null');
select col_not_null(
  'public',
  'room_members',
  'last_acknowledged_sequence',
  'room_members.last_acknowledged_sequence is not null'
);
select col_is_pk(
  'public',
  'room_members',
  array['room_id', 'user_id'],
  'room_members uses the room and user composite primary key'
);

select fk_ok(
  'public',
  'room_members',
  'room_id',
  'public',
  'rooms',
  'id',
  'room_members.room_id references rooms.id'
);

select fk_ok(
  'public',
  'room_members',
  'user_id',
  'public',
  'profiles',
  'user_id',
  'room_members.user_id references profiles.user_id'
);

select has_table('public', 'room_invites', 'the room invites table exists');

select columns_are(
  'public',
  'room_invites',
  array[
    'id',
    'room_id',
    'creator_id',
    'token_digest',
    'expires_at',
    'max_uses',
    'use_count',
    'revoked_at',
    'created_at'
  ]
);

select col_type_is('public', 'room_invites', 'id', 'uuid', 'room_invites.id is a uuid');
select col_type_is('public', 'room_invites', 'room_id', 'uuid', 'room_invites.room_id is a uuid');
select col_type_is('public', 'room_invites', 'creator_id', 'uuid', 'room_invites.creator_id is a uuid');
select col_type_is('public', 'room_invites', 'token_digest', 'bytea', 'room_invites.token_digest is bytea');
select col_type_is(
  'public',
  'room_invites',
  'expires_at',
  'timestamp with time zone',
  'room_invites.expires_at is a timestamptz'
);
select col_type_is(
  'public',
  'room_invites',
  'max_uses',
  'positive_bigint',
  'room_invites.max_uses uses the positive bigint domain'
);
select col_type_is('public', 'room_invites', 'use_count', 'bigint', 'room_invites.use_count is a bigint');
select col_type_is(
  'public',
  'room_invites',
  'revoked_at',
  'timestamp with time zone',
  'room_invites.revoked_at is a timestamptz'
);
select col_type_is(
  'public',
  'room_invites',
  'created_at',
  'timestamp with time zone',
  'room_invites.created_at is a timestamptz'
);

select col_not_null('public', 'room_invites', 'id', 'room_invites.id is not null');
select col_not_null('public', 'room_invites', 'room_id', 'room_invites.room_id is not null');
select col_not_null('public', 'room_invites', 'creator_id', 'room_invites.creator_id is not null');
select col_not_null('public', 'room_invites', 'token_digest', 'room_invites.token_digest is not null');
select col_not_null('public', 'room_invites', 'expires_at', 'room_invites.expires_at is not null');
select col_is_null('public', 'room_invites', 'max_uses', 'room_invites.max_uses is nullable');
select col_not_null('public', 'room_invites', 'use_count', 'room_invites.use_count is not null');
select col_is_null('public', 'room_invites', 'revoked_at', 'room_invites.revoked_at is nullable');
select col_not_null('public', 'room_invites', 'created_at', 'room_invites.created_at is not null');
select col_is_pk('public', 'room_invites', 'id', 'room_invites.id is the primary key');

select fk_ok(
  'public',
  'room_invites',
  'room_id',
  'public',
  'rooms',
  'id',
  'room_invites.room_id references rooms.id'
);

select fk_ok(
  'public',
  'room_invites',
  'creator_id',
  'public',
  'profiles',
  'user_id',
  'room_invites.creator_id references profiles.user_id'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't42-owner@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't42-member@example.com'),
  ('33333333-3333-3333-3333-333333333333', 't42-other@example.com'),
  ('44444444-4444-4444-4444-444444444444', 't42-cascade@example.com');

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
    'Other Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Cascade Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

select lives_ok(
  $$insert into public.rooms (id, name, owner_id)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'Test Room',
      '11111111-1111-1111-1111-111111111111'
    )$$,
  'a valid room is accepted'
);

select lives_ok(
  $$insert into public.rooms (name, owner_id)
    values ('Generated ID Room', '11111111-1111-1111-1111-111111111111')$$,
  'a room can use its generated id and defaults'
);

select ok(
  (select id is not null from public.rooms where name = 'Generated ID Room'),
  'a room id is generated by PostgreSQL'
);

select is(
  (select layout_id from public.rooms where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'lodge-v1',
  'the room layout defaults to lodge-v1'
);

select is(
  (
    select next_event_sequence::bigint
    from public.rooms
    where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
  ),
  1::bigint,
  'the next event sequence defaults to one'
);

select throws_ok(
  $$insert into public.rooms (name, owner_id)
    values (repeat('a', 51), '11111111-1111-1111-1111-111111111111')$$,
  '23514',
  NULL,
  'a 51-character room name is rejected'
);

select throws_ok(
  $$insert into public.rooms (name, owner_id, layout_id)
    values ('Unknown Layout', '11111111-1111-1111-1111-111111111111', 'unknown-v1')$$,
  '23514',
  NULL,
  'an unsupported room layout is rejected'
);

select throws_ok(
  $$insert into public.rooms (name, owner_id, next_event_sequence)
    values ('Bad Sequence', '11111111-1111-1111-1111-111111111111', 0)$$,
  '23514',
  NULL,
  'a zero next event sequence is rejected'
);

select throws_ok(
  $$insert into public.rooms (name, owner_id)
    values ('Unknown Owner', '99999999-9999-9999-9999-999999999999')$$,
  '23503',
  NULL,
  'a room for an unknown owner profile is rejected'
);

select lives_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      'owner'
    )$$,
  'a valid owner membership is accepted'
);

select is(
  (
    select is_muted
    from public.room_members
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'
  ),
  false,
  'a membership defaults to unmuted'
);

select is(
  (
    select last_acknowledged_sequence
    from public.room_members
    where room_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      and user_id = '11111111-1111-1111-1111-111111111111'
  ),
  0::bigint,
  'a membership defaults to no acknowledged events'
);

select lives_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'member'
    )$$,
  'a valid member membership is accepted'
);

select throws_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'member'
    )$$,
  '23505',
  NULL,
  'a duplicate room membership is rejected'
);

select throws_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '33333333-3333-3333-3333-333333333333',
      'owner'
    )$$,
  '23505',
  NULL,
  'a second owner-role row for one room is rejected'
);

select throws_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      '33333333-3333-3333-3333-333333333333',
      'member'
    )$$,
  '23503',
  NULL,
  'a membership for an unknown room is rejected'
);

select throws_ok(
  $$insert into public.room_members (room_id, user_id, role)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '99999999-9999-9999-9999-999999999999',
      'member'
    )$$,
  '23503',
  NULL,
  'a membership for an unknown profile is rejected'
);

select throws_ok(
  $$insert into public.room_members (
      room_id,
      user_id,
      role,
      last_acknowledged_sequence
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '33333333-3333-3333-3333-333333333333',
      'member',
      -1
    )$$,
  '23514',
  NULL,
  'a negative acknowledged sequence is rejected'
);

select lives_ok(
  $$insert into public.room_invites (
      id,
      room_id,
      creator_id,
      token_digest,
      expires_at
    ) values (
      'aaaaaaaa-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('ab', 32), 'hex'),
      now() + interval '7 days'
    )$$,
  'a valid unlimited invitation is accepted'
);

select is(
  (
    select use_count
    from public.room_invites
    where id = 'aaaaaaaa-1111-1111-1111-111111111111'
  ),
  0::bigint,
  'an invitation use count defaults to zero'
);

select is(
  (
    select max_uses::bigint
    from public.room_invites
    where id = 'aaaaaaaa-1111-1111-1111-111111111111'
  ),
  null::bigint,
  'an invitation defaults to unlimited uses'
);

select throws_ok(
  $$insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('ab', 32), 'hex'),
      now() + interval '7 days'
    )$$,
  '23505',
  NULL,
  'a duplicate invitation token digest is rejected'
);

select throws_ok(
  $$insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode('ab', 'hex'),
      now() + interval '7 days'
    )$$,
  '23514',
  NULL,
  'a token digest that is not 32 bytes is rejected'
);

select throws_ok(
  $$insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('01', 32), 'hex'),
      now()
    )$$,
  '23514',
  NULL,
  'an invitation that does not expire after creation is rejected'
);

select throws_ok(
  $$insert into public.room_invites (
      room_id,
      creator_id,
      token_digest,
      expires_at,
      max_uses
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('02', 32), 'hex'),
      now() + interval '7 days',
      0
    )$$,
  '23514',
  NULL,
  'a zero invitation use limit is rejected'
);

select throws_ok(
  $$insert into public.room_invites (
      room_id,
      creator_id,
      token_digest,
      expires_at,
      use_count
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('03', 32), 'hex'),
      now() + interval '7 days',
      -1
    )$$,
  '23514',
  NULL,
  'a negative invitation use count is rejected'
);

select throws_ok(
  $$insert into public.room_invites (
      room_id,
      creator_id,
      token_digest,
      expires_at,
      max_uses,
      use_count
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('04', 32), 'hex'),
      now() + interval '7 days',
      1,
      2
    )$$,
  '23514',
  NULL,
  'an invitation use count above its limit is rejected'
);

select throws_ok(
  $$insert into public.room_invites (
      room_id,
      creator_id,
      token_digest,
      expires_at,
      revoked_at,
      created_at
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('05', 32), 'hex'),
      '2026-10-11 12:00:00+00',
      '2026-10-04 11:59:59+00',
      '2026-10-04 12:00:00+00'
    )$$,
  '23514',
  NULL,
  'an invitation cannot be revoked before it was created'
);

select throws_ok(
  $$insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
    values (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('06', 32), 'hex'),
      now() + interval '7 days'
    )$$,
  '23503',
  NULL,
  'an invitation for an unknown room is rejected'
);

select throws_ok(
  $$insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
    values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '99999999-9999-9999-9999-999999999999',
      decode(repeat('07', 32), 'hex'),
      now() + interval '7 days'
    )$$,
  '23503',
  NULL,
  'an invitation for an unknown creator profile is rejected'
);

select lives_ok(
  $$insert into public.room_invites (
      room_id,
      creator_id,
      token_digest,
      expires_at,
      max_uses,
      use_count
    ) values (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '11111111-1111-1111-1111-111111111111',
      decode(repeat('08', 32), 'hex'),
      now() + interval '7 days',
      1,
      1
    )$$,
  'an invitation at its use limit is valid'
);

insert into public.rooms (id, name, owner_id)
values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Cascade Room',
  '44444444-4444-4444-4444-444444444444'
);

insert into public.room_members (room_id, user_id, role)
values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '44444444-4444-4444-4444-444444444444',
  'owner'
);

insert into public.room_invites (room_id, creator_id, token_digest, expires_at)
values (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '44444444-4444-4444-4444-444444444444',
  decode(repeat('cd', 32), 'hex'),
  now() + interval '7 days'
);

delete from public.rooms
where id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

select is_empty(
  $$select 1 from public.room_members
    where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'$$,
  'deleting a room deletes its memberships'
);

select is_empty(
  $$select 1 from public.room_invites
    where room_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'$$,
  'deleting a room deletes its invitations'
);

delete from public.profiles
where user_id = '22222222-2222-2222-2222-222222222222';

select is_empty(
  $$select 1 from public.room_members
    where user_id = '22222222-2222-2222-2222-222222222222'$$,
  'deleting a non-owner profile deletes its memberships'
);

select throws_ok(
  $$delete from public.profiles
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23503',
  NULL,
  'an owner profile cannot be deleted while it owns a room'
);

select * from finish();

rollback;
