begin;

select plan(26);

-- table shape

select has_table('public', 'account_deletion_jobs', 'the account deletion jobs table exists');

select columns_are(
  'public',
  'account_deletion_jobs',
  array['user_id', 'state', 'requested_at', 'attempted_at', 'completed_at', 'error_code']
);

select col_type_is('public', 'account_deletion_jobs', 'user_id', 'uuid', 'the job user id is a uuid');
select col_type_is(
  'public',
  'account_deletion_jobs',
  'state',
  'account_deletion_job_state',
  'the job state uses the deletion-job state enum'
);
select col_type_is(
  'public',
  'account_deletion_jobs',
  'requested_at',
  'timestamp with time zone',
  'the requested time is a timestamptz'
);
select col_type_is(
  'public',
  'account_deletion_jobs',
  'attempted_at',
  'timestamp with time zone',
  'the attempted time is a timestamptz'
);
select col_type_is(
  'public',
  'account_deletion_jobs',
  'completed_at',
  'timestamp with time zone',
  'the completed time is a timestamptz'
);
select col_type_is('public', 'account_deletion_jobs', 'error_code', 'text', 'the error code is text');

select col_not_null('public', 'account_deletion_jobs', 'user_id', 'the job user is required');
select col_not_null('public', 'account_deletion_jobs', 'state', 'the job state is required');
select col_not_null(
  'public',
  'account_deletion_jobs',
  'requested_at',
  'the requested time is not null'
);

select col_is_pk(
  'public',
  'account_deletion_jobs',
  array['user_id'],
  'deletion jobs carry at most one job per user'
);

select fk_ok(
  'public',
  'account_deletion_jobs',
  'user_id',
  'public',
  'profiles',
  'user_id',
  'the job references a profile'
);

select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'account_deletion_jobs'
      and indexname = 'account_deletion_jobs_pending_idx'
      and indexdef like '%(requested_at)%'
  ),
  'pending jobs have a retry-scheduler index'
);

-- job behavior

insert into auth.users (id, email)
values ('11111111-1111-1111-1111-111111111111', 't49-bear@example.com');

insert into public.profiles (user_id, display_name, appearance, revision)
values (
  '11111111-1111-1111-1111-111111111111',
  'Deletion Bear',
  '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
  1
);

select lives_ok(
  $$insert into public.account_deletion_jobs (user_id)
    values ('11111111-1111-1111-1111-111111111111')$$,
  'a deletion job is created pending by default'
);

select ok(
  (
    select state = 'pending'
      and requested_at is not null
      and attempted_at is null
      and completed_at is null
      and error_code is null
    from public.account_deletion_jobs
    where user_id = '11111111-1111-1111-1111-111111111111'
  ),
  'a fresh job records the request without attempt or completion state'
);

select throws_ok(
  $$insert into public.account_deletion_jobs (user_id)
    values ('11111111-1111-1111-1111-111111111111')$$,
  '23505',
  NULL,
  'a user cannot carry two deletion jobs'
);

select throws_ok(
  $$insert into public.account_deletion_jobs (user_id)
    values ('99999999-9999-9999-9999-999999999999')$$,
  '23503',
  NULL,
  'the deletion job must reference a profile'
);

select lives_ok(
  $$update public.account_deletion_jobs
    set attempted_at = now(),
        error_code = 'service_unavailable'
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  'a failed attempt records the attempt time and content-free error code'
);

select throws_ok(
  $$update public.account_deletion_jobs
    set error_code = repeat('e', 101)
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'an overlong error code is rejected'
);

select throws_ok(
  $$update public.account_deletion_jobs
    set error_code = ''
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'an empty error code is rejected'
);

select throws_ok(
  $$update public.account_deletion_jobs
    set state = 'completed'
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a completed job requires a completion timestamp'
);

select throws_ok(
  $$update public.account_deletion_jobs
    set completed_at = now()
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a pending job cannot carry a completion timestamp'
);

select lives_ok(
  $$update public.account_deletion_jobs
    set state = 'completed',
        completed_at = now(),
        error_code = null
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  'a successful deletion completes the job with a completion timestamp'
);

select throws_ok(
  $$update public.account_deletion_jobs
    set state = 'pending'
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  '23514',
  NULL,
  'a completed job cannot return to pending'
);

delete from public.profiles
where user_id = '11111111-1111-1111-1111-111111111111';

select is_empty(
  $$select 1 from public.account_deletion_jobs
    where user_id = '11111111-1111-1111-1111-111111111111'$$,
  'deleting the profile removes the deletion job'
);

select * from finish();

rollback;
