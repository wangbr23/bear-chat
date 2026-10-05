begin;

select plan(25);

select has_table('public', 'user_blocks', 'the user blocks table exists');

select columns_are(
  'public',
  'user_blocks',
  array['blocker_id', 'blocked_id', 'created_at']
);

select col_type_is('public', 'user_blocks', 'blocker_id', 'uuid', 'blocker id is a uuid');
select col_type_is('public', 'user_blocks', 'blocked_id', 'uuid', 'blocked id is a uuid');
select col_type_is(
  'public',
  'user_blocks',
  'created_at',
  'timestamp with time zone',
  'block creation time is a timestamptz'
);

select col_not_null('public', 'user_blocks', 'blocker_id', 'blocker id is not null');
select col_not_null('public', 'user_blocks', 'blocked_id', 'blocked id is not null');
select col_not_null('public', 'user_blocks', 'created_at', 'block creation time is not null');
select col_is_pk(
  'public',
  'user_blocks',
  array['blocker_id', 'blocked_id'],
  'user blocks use the directional identity pair as the primary key'
);
select fk_ok(
  'public',
  'user_blocks',
  'blocker_id',
  'public',
  'profiles',
  'user_id',
  'the blocker references a profile'
);
select fk_ok(
  'public',
  'user_blocks',
  'blocked_id',
  'public',
  'profiles',
  'user_id',
  'the blocked user references a profile'
);
select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'user_blocks'
      and indexname = 'user_blocks_blocked_id_idx'
      and indexdef like '%(blocked_id, blocker_id)%'
  ),
  'user blocks have a reverse-direction lookup index'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't46-bear-one@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't46-bear-two@example.com'),
  ('33333333-3333-3333-3333-333333333333', 't46-cascade@example.com');

insert into public.profiles (user_id, display_name, appearance, revision)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'Bear One',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Bear Two',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Cascade Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

select lives_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '11111111-1111-1111-1111-111111111111',
      '22222222-2222-2222-2222-222222222222'
    )$$,
  'a directional user block is accepted'
);

select ok(
  (
    select created_at is not null
    from public.user_blocks
    where blocker_id = '11111111-1111-1111-1111-111111111111'
      and blocked_id = '22222222-2222-2222-2222-222222222222'
  ),
  'a block receives a server creation timestamp'
);

select lives_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '22222222-2222-2222-2222-222222222222',
      '11111111-1111-1111-1111-111111111111'
    )$$,
  'the reverse block direction is stored independently'
);

select is(
  (select count(*) from public.user_blocks),
  2::bigint,
  'opposite block directions create two rows'
);

select throws_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '11111111-1111-1111-1111-111111111111',
      '22222222-2222-2222-2222-222222222222'
    )$$,
  '23505',
  NULL,
  'the same directional block cannot be duplicated'
);

select throws_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '11111111-1111-1111-1111-111111111111',
      '11111111-1111-1111-1111-111111111111'
    )$$,
  '23514',
  NULL,
  'a user cannot block themselves'
);

select throws_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '99999999-9999-9999-9999-999999999999',
      '11111111-1111-1111-1111-111111111111'
    )$$,
  '23503',
  NULL,
  'the blocker must have a profile'
);

select throws_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '11111111-1111-1111-1111-111111111111',
      '99999999-9999-9999-9999-999999999999'
    )$$,
  '23503',
  NULL,
  'the blocked user must have a profile'
);

select lives_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '11111111-1111-1111-1111-111111111111',
      '33333333-3333-3333-3333-333333333333'
    )$$,
  'a profile can appear as the blocked user in another pair'
);

select lives_ok(
  $$insert into public.user_blocks (blocker_id, blocked_id)
    values (
      '33333333-3333-3333-3333-333333333333',
      '22222222-2222-2222-2222-222222222222'
    )$$,
  'a profile can appear as the blocker in another pair'
);

delete from public.profiles
where user_id = '33333333-3333-3333-3333-333333333333';

select is_empty(
  $$select 1 from public.user_blocks
    where blocker_id = '33333333-3333-3333-3333-333333333333'
       or blocked_id = '33333333-3333-3333-3333-333333333333'$$,
  'deleting a profile removes blocks in either direction'
);

select is(
  (select count(*) from public.user_blocks),
  2::bigint,
  'deleting one profile preserves unrelated directional blocks'
);

delete from public.profiles
where user_id = '11111111-1111-1111-1111-111111111111';

select is_empty(
  $$select 1 from public.user_blocks$$,
  'deleting a remaining participant removes every related block'
);

select * from finish();

rollback;
