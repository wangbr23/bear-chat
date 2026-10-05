begin;

select plan(35);

select has_table('public', 'rate_limit_counters', 'the rate limit counters table exists');

select columns_are(
  'public',
  'rate_limit_counters',
  array['subject_user_id', 'operation', 'window_start', 'attempt_count', 'updated_at'],
  'rate limit counters record only what limits a window'
);

select col_type_is('public', 'rate_limit_counters', 'subject_user_id', 'uuid', 'the counter subject is a uuid');
select col_type_is('public', 'rate_limit_counters', 'operation', 'text', 'the operation is constrained text');
select col_type_is(
  'public',
  'rate_limit_counters',
  'window_start',
  'timestamp with time zone',
  'the window start is a timestamptz'
);
select col_type_is('public', 'rate_limit_counters', 'attempt_count', 'integer', 'the attempt count is an integer');
select col_type_is(
  'public',
  'rate_limit_counters',
  'updated_at',
  'timestamp with time zone',
  'the last update is a timestamptz'
);

select col_not_null('public', 'rate_limit_counters', 'subject_user_id', 'the subject is not null');
select col_not_null('public', 'rate_limit_counters', 'operation', 'the operation is not null');
select col_not_null('public', 'rate_limit_counters', 'window_start', 'the window start is not null');
select col_not_null('public', 'rate_limit_counters', 'attempt_count', 'the attempt count is not null');
select col_not_null('public', 'rate_limit_counters', 'updated_at', 'the last update is not null');

select col_default_is(
  'public',
  'rate_limit_counters',
  'attempt_count',
  '1',
  'the first attempt is counted by default'
);
select col_default_is(
  'public',
  'rate_limit_counters',
  'updated_at',
  'now()',
  'the last update defaults to server time'
);

select col_is_pk(
  'public',
  'rate_limit_counters',
  array['subject_user_id', 'operation', 'window_start'],
  'counters are keyed by subject, operation, and window bucket'
);

select fk_ok(
  'public',
  'rate_limit_counters',
  'subject_user_id',
  'public',
  'profiles',
  'user_id',
  'the counter subject references a profile'
);

select has_check('public', 'rate_limit_counters', 'rate limit counters constrain their values');

select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'rate_limit_counters'
      and indexname = 'rate_limit_counters_window_start_idx'
      and indexdef like '%(window_start)%'
  ),
  'expired-window cleanup has a window-start scan index'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't48-bear-one@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't48-bear-two@example.com'),
  ('33333333-3333-3333-3333-333333333333', 't48-cascade@example.com');

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
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'event',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  'a first event attempt creates its window counter'
);

select is(
  (
    select attempt_count
    from public.rate_limit_counters
    where subject_user_id = '11111111-1111-1111-1111-111111111111'
      and operation = 'event'
      and window_start = '2026-10-05 12:00:00+00'::timestamptz
  ),
  1,
  'the counter records the first attempt without an explicit count'
);

select lives_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'invite',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  'the same subject counts separate operations independently'
);

select lives_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'event',
      '2026-10-05 12:01:00+00'::timestamptz
    )$$,
  'the same operation counts separate windows independently'
);

select lives_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '22222222-2222-2222-2222-222222222222',
      'join',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  'different subjects count independently'
);

select throws_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'event',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  '23505',
  NULL,
  'the same counter row cannot be duplicated by a plain insert'
);

select throws_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'login',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  '23514',
  NULL,
  'only approved operations are counted'
);

select throws_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start, attempt_count)
    values (
      '11111111-1111-1111-1111-111111111111',
      'movement',
      '2026-10-05 12:00:00+00'::timestamptz,
      0
    )$$,
  '23514',
  NULL,
  'a counter cannot start at zero'
);

select throws_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start, attempt_count)
    values (
      '11111111-1111-1111-1111-111111111111',
      'movement',
      '2026-10-05 12:00:00+00'::timestamptz,
      -1
    )$$,
  '23514',
  NULL,
  'a counter cannot be negative'
);

select throws_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '99999999-9999-9999-9999-999999999999',
      'event',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  '23503',
  NULL,
  'the counter subject must have a profile'
);

select lives_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '11111111-1111-1111-1111-111111111111',
      'event',
      '2026-10-05 12:00:00+00'::timestamptz
    )
    on conflict (subject_user_id, operation, window_start)
    do update set attempt_count = rate_limit_counters.attempt_count + 1,
                  updated_at = now()$$,
  'protected functions increment an existing window counter in place'
);

select is(
  (
    select attempt_count
    from public.rate_limit_counters
    where subject_user_id = '11111111-1111-1111-1111-111111111111'
      and operation = 'event'
      and window_start = '2026-10-05 12:00:00+00'::timestamptz
  ),
  2,
  'the incremented counter reflects both attempts'
);

select is(
  (select count(*) from public.rate_limit_counters),
  4::bigint,
  'incrementing does not create extra rows'
);

select lives_ok(
  $$insert into public.rate_limit_counters (subject_user_id, operation, window_start)
    values (
      '33333333-3333-3333-3333-333333333333',
      'report',
      '2026-10-05 12:00:00+00'::timestamptz
    )$$,
  'a subject can hold counters before deletion'
);

delete from public.profiles
where user_id = '33333333-3333-3333-3333-333333333333';

select is_empty(
  $$select 1 from public.rate_limit_counters
    where subject_user_id = '33333333-3333-3333-3333-333333333333'$$,
  'deleting a profile removes its counters'
);

select is(
  (select count(*) from public.rate_limit_counters),
  4::bigint,
  'deleting one profile preserves other subjects counters'
);

delete from public.profiles
where user_id in (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222'
);

select is_empty(
  $$select 1 from public.rate_limit_counters$$,
  'deleting the remaining profiles removes every counter'
);

select * from finish();

rollback;