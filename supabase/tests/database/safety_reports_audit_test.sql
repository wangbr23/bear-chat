begin;

select plan(78);

-- reports table shape

select has_table('public', 'reports', 'the reports table exists');

select columns_are(
  'public',
  'reports',
  array[
    'id',
    'reporter_id',
    'room_id',
    'reported_user_id',
    'reported_event_id',
    'disclosed_snapshot',
    'category',
    'status',
    'retention_deadline',
    'created_at',
    'updated_at'
  ]
);

select col_type_is('public', 'reports', 'id', 'uuid', 'the report id is a uuid');
select col_type_is('public', 'reports', 'reporter_id', 'uuid', 'the reporter id is a uuid');
select col_type_is('public', 'reports', 'room_id', 'uuid', 'the reported room id is a uuid');
select col_type_is(
  'public',
  'reports',
  'reported_user_id',
  'uuid',
  'the reported user id is a uuid'
);
select col_type_is(
  'public',
  'reports',
  'reported_event_id',
  'uuid',
  'the reported event id is a uuid'
);
select col_type_is(
  'public',
  'reports',
  'disclosed_snapshot',
  'jsonb',
  'the disclosed snapshot is jsonb'
);
select col_type_is('public', 'reports', 'category', 'text', 'the report category is text');
select col_type_is('public', 'reports', 'status', 'text', 'the report status is text');
select col_type_is(
  'public',
  'reports',
  'retention_deadline',
  'timestamp with time zone',
  'the retention deadline is a timestamptz'
);
select col_type_is(
  'public',
  'reports',
  'created_at',
  'timestamp with time zone',
  'report creation time is a timestamptz'
);
select col_type_is(
  'public',
  'reports',
  'updated_at',
  'timestamp with time zone',
  'report update time is a timestamptz'
);

select col_not_null('public', 'reports', 'reporter_id', 'the reporter is required');
select col_not_null(
  'public',
  'reports',
  'disclosed_snapshot',
  'the disclosed snapshot is required'
);
select col_not_null('public', 'reports', 'category', 'the report category is required');
select col_not_null('public', 'reports', 'status', 'the report status is required');
select col_not_null(
  'public',
  'reports',
  'retention_deadline',
  'the retention deadline is required'
);
select col_not_null('public', 'reports', 'created_at', 'report creation time is not null');
select col_not_null('public', 'reports', 'updated_at', 'report update time is not null');

select col_is_pk(
  'public',
  'reports',
  array['id'],
  'reports use a generated id as the primary key'
);

select fk_ok(
  'public',
  'reports',
  'reporter_id',
  'public',
  'profiles',
  'user_id',
  'the reporter references a profile'
);
select fk_ok(
  'public',
  'reports',
  'room_id',
  'public',
  'rooms',
  'id',
  'the reported room references a room'
);
select fk_ok(
  'public',
  'reports',
  'reported_user_id',
  'public',
  'profiles',
  'user_id',
  'the reported user references a profile'
);
select fk_ok(
  'public',
  'reports',
  'reported_event_id',
  'public',
  'room_events',
  'id',
  'the reported event references a room event'
);

-- audit_log table shape

select has_table('public', 'audit_log', 'the audit log table exists');

select columns_are(
  'public',
  'audit_log',
  array[
    'id',
    'actor',
    'operation',
    'resource_type',
    'resource_id',
    'reason_code',
    'metadata',
    'created_at'
  ]
);

select col_type_is('public', 'audit_log', 'id', 'uuid', 'the audit record id is a uuid');
select col_type_is('public', 'audit_log', 'actor', 'text', 'the audit actor is text');
select col_type_is('public', 'audit_log', 'operation', 'text', 'the audit operation is text');
select col_type_is(
  'public',
  'audit_log',
  'resource_type',
  'text',
  'the audit resource type is text'
);
select col_type_is(
  'public',
  'audit_log',
  'resource_id',
  'uuid',
  'the audit resource id is a uuid'
);
select col_type_is('public', 'audit_log', 'reason_code', 'text', 'the audit reason code is text');
select col_type_is('public', 'audit_log', 'metadata', 'jsonb', 'the audit metadata is jsonb');
select col_type_is(
  'public',
  'audit_log',
  'created_at',
  'timestamp with time zone',
  'audit creation time is a timestamptz'
);

select col_not_null('public', 'audit_log', 'actor', 'the audit actor is required');
select col_not_null('public', 'audit_log', 'operation', 'the audit operation is required');
select col_not_null(
  'public',
  'audit_log',
  'resource_type',
  'the audit resource type is required'
);
select col_not_null(
  'public',
  'audit_log',
  'resource_id',
  'the audit resource id is required'
);
select col_not_null('public', 'audit_log', 'reason_code', 'the audit reason code is required');
select col_not_null('public', 'audit_log', 'metadata', 'the audit metadata is required');
select col_not_null('public', 'audit_log', 'created_at', 'audit creation time is not null');

select col_is_pk(
  'public',
  'audit_log',
  array['id'],
  'audit records use a generated id as the primary key'
);

select ok(
  not exists(
    select 1
    from information_schema.table_constraints
    where constraint_schema = 'public'
      and table_name = 'audit_log'
      and constraint_type = 'FOREIGN KEY'
  ),
  'audit actors stay text because service roles and reviewers are not app users'
);

select has_trigger(
  'public',
  'audit_log',
  'audit_log_append_only',
  'the audit log carries its append-only trigger'
);

-- lookup indexes

select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'reports'
      and indexname = 'reports_room_id_idx'
  ),
  'reports have a room lookup index'
);
select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'reports'
      and indexname = 'reports_reporter_id_idx'
  ),
  'reports have a reporter lookup index'
);
select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'reports'
      and indexname = 'reports_reported_user_id_idx'
  ),
  'reports have a reported-user lookup index'
);
select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'reports'
      and indexname = 'reports_reported_event_id_idx'
  ),
  'reports have a reported-event lookup index'
);
select ok(
  exists(
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'audit_log'
      and indexname = 'audit_log_resource_idx'
  ),
  'audit records have a resource lookup index'
);

-- report behavior

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't47-reporter@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't47-reported@example.com');

insert into public.profiles (user_id, display_name, appearance, revision)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'Reporter Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Reported Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

insert into public.rooms (id, name, owner_id)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Report Lodge', '11111111-1111-1111-1111-111111111111');

insert into public.room_events (id, room_id, sequence, sender_id, client_event_id, kind, payload)
values (
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  1,
  '22222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'text',
  '{"text":"hello"}'::jsonb
);

select lives_ok(
  $$insert into public.reports (
      reporter_id,
      room_id,
      reported_user_id,
      reported_event_id,
      disclosed_snapshot,
      category,
      status,
      retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'cccccccc-cccc-cccc-cccc-cccccccccccc',
      '{"reportedText":"hello"}'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  'a complete safety report is accepted'
);

select ok(
  (
    select id is not null
      and created_at is not null
      and updated_at is not null
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  'a report receives a generated id and server timestamps'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      '',
      'received',
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'an empty report category is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      repeat('c', 51),
      'received',
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'an overlong report category is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      '',
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'an empty report status is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      repeat('s', 51),
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'an overlong report status is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '[]'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'a non-object disclosed snapshot is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'null'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  '23514',
  NULL,
  'a jsonb-null disclosed snapshot is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      'received',
      now() - interval '1 day'
    )$$,
  '23514',
  NULL,
  'a past retention deadline is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      'received',
      now()
    )$$,
  '23514',
  NULL,
  'a retention deadline at creation time is rejected'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'dddddddd-dddd-dddd-dddd-dddddddddddd',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  '23503',
  NULL,
  'the reported room must exist'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '99999999-9999-9999-9999-999999999999',
      '{}'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  '23503',
  NULL,
  'the reported user must have a profile'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, reported_event_id,
      disclosed_snapshot, category, status, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
      '{}'::jsonb,
      'message_content',
      'received',
      now() + interval '30 days'
    )$$,
  '23503',
  NULL,
  'the reported event must exist'
);

select throws_ok(
  $$insert into public.reports (
      reporter_id, room_id, reported_user_id, disclosed_snapshot,
      category, retention_deadline
    )
    values (
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '22222222-2222-2222-2222-222222222222',
      '{}'::jsonb,
      'message_content',
      now() + interval '30 days'
    )$$,
  '23502',
  NULL,
  'a report cannot be stored without an explicit status'
);

-- report retention across deletions

delete from public.rooms
where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

select ok(
  (
    select room_id is null
      and reported_event_id is null
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  'deleting a room clears the report room and event references'
);

select is(
  (
    select count(*)
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  1::bigint,
  'deleting a room preserves the retained report'
);

delete from public.profiles
where user_id = '22222222-2222-2222-2222-222222222222';

select ok(
  (
    select reported_user_id is null
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  'deleting the reported profile clears the reported-user reference'
);

select is(
  (
    select count(*)
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  1::bigint,
  'deleting the reported profile preserves the retained report'
);

delete from public.profiles
where user_id = '11111111-1111-1111-1111-111111111111';

select is(
  (
    select count(*)
    from public.reports
    where reporter_id = '11111111-1111-1111-1111-111111111111'
  ),
  0::bigint,
  'deleting the reporter profile removes the filed report'
);

-- audit_log behavior

select lives_ok(
  $$insert into public.audit_log (
      actor, operation, resource_type, resource_id, reason_code, metadata
    )
    values (
      'service-role',
      'report_status_changed',
      'safety_report',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      'review_completed',
      '{"status":"reviewed"}'::jsonb
    )$$,
  'an append-only audit record is accepted'
);

select ok(
  (
    select id is not null
      and created_at is not null
    from public.audit_log
    where actor = 'service-role'
  ),
  'an audit record receives a generated id and server timestamp'
);

select throws_ok(
  $$insert into public.audit_log (actor, operation, resource_type, resource_id, reason_code, metadata)
    values (
      'service-role',
      'report_status_changed',
      'safety_report',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      'review_completed',
      '[]'::jsonb
    )$$,
  '23514',
  NULL,
  'a non-object audit metadata value is rejected'
);

select throws_ok(
  $$insert into public.audit_log (actor, operation, resource_type, resource_id, reason_code, metadata)
    values (
      'service-role',
      'report_status_changed',
      'safety_report',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      'review_completed',
      'null'::jsonb
    )$$,
  '23514',
  NULL,
  'a jsonb-null audit metadata value is rejected'
);

select throws_ok(
  $$insert into public.audit_log (actor, operation, resource_type, resource_id, reason_code, metadata)
    values (
      'service-role',
      '',
      'safety_report',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      'review_completed',
      '{}'::jsonb
    )$$,
  '23514',
  NULL,
  'an empty audit operation is rejected'
);

select throws_ok(
  $$insert into public.audit_log (actor, operation, resource_type, resource_id, reason_code, metadata)
    values (
      repeat('a', 101),
      'report_status_changed',
      'safety_report',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      'review_completed',
      '{}'::jsonb
    )$$,
  '23514',
  NULL,
  'an overlong audit actor is rejected'
);

select throws_ok(
  $$update public.audit_log
    set reason_code = 'revised'
    where actor = 'service-role'$$,
  'P0001',
  NULL,
  'updating an audit record is rejected'
);

select throws_ok(
  $$delete from public.audit_log
    where actor = 'service-role'$$,
  'P0001',
  NULL,
  'deleting an audit record is rejected'
);

select throws_ok(
  $$truncate public.audit_log$$,
  'P0001',
  NULL,
  'truncating the audit log is rejected'
);

select * from finish();

rollback;
