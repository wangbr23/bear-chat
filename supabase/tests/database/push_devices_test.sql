begin;

select plan(36);

select has_type('public', 'apns_environment', 'the APNs environment enum exists');

select enum_has_labels(
  'public',
  'apns_environment',
  array['sandbox', 'production']
);

select has_type(
  'public',
  'notification_preview_mode',
  'the notification preview mode enum exists'
);

select enum_has_labels(
  'public',
  'notification_preview_mode',
  array['generic', 'detailed']
);

select has_table('public', 'push_devices', 'the push devices table exists');

select columns_are(
  'public',
  'push_devices',
  array[
    'user_id',
    'installation_id',
    'environment',
    'token',
    'preview_mode',
    'last_seen_at'
  ]
);

select col_type_is('public', 'push_devices', 'user_id', 'uuid', 'push device user id is a uuid');
select col_type_is(
  'public',
  'push_devices',
  'installation_id',
  'uuid',
  'push device installation id is a uuid'
);
select col_type_is(
  'public',
  'push_devices',
  'environment',
  'apns_environment',
  'push device environment uses the APNs environment enum'
);
select col_type_is('public', 'push_devices', 'token', 'bytea', 'push device token is opaque bytes');
select col_type_is(
  'public',
  'push_devices',
  'preview_mode',
  'notification_preview_mode',
  'push device preview mode uses the notification preview enum'
);
select col_type_is(
  'public',
  'push_devices',
  'last_seen_at',
  'timestamp with time zone',
  'push device last seen time is a timestamptz'
);

select col_not_null('public', 'push_devices', 'user_id', 'push device user id is not null');
select col_not_null(
  'public',
  'push_devices',
  'installation_id',
  'push device installation id is not null'
);
select col_not_null('public', 'push_devices', 'environment', 'push device environment is not null');
select col_not_null('public', 'push_devices', 'token', 'push device token is not null');
select col_not_null('public', 'push_devices', 'preview_mode', 'push device preview mode is not null');
select col_not_null('public', 'push_devices', 'last_seen_at', 'push device last seen time is not null');
select col_is_pk(
  'public',
  'push_devices',
  array['user_id', 'installation_id', 'environment'],
  'push devices use the user, installation, and environment composite primary key'
);
select fk_ok(
  'public',
  'push_devices',
  'user_id',
  'public',
  'profiles',
  'user_id',
  'push devices belong to a profile'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't45-owner@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't45-cascade@example.com');

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
    'Cascade Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

select lives_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000001',
      'sandbox',
      decode(repeat('ab', 32), 'hex')
    )$$,
  'a valid sandbox device registration is accepted'
);

select is(
  (
    select preview_mode::text
    from public.push_devices
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'
  ),
  'generic',
  'notification previews default to generic'
);

select ok(
  (
    select last_seen_at is not null
    from public.push_devices
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'
  ),
  'a registration receives a server last-seen timestamp'
);

select lives_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token,
      preview_mode
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000001',
      'production',
      decode(repeat('cd', 32), 'hex'),
      'detailed'
    )$$,
  'one installation can register separately with production APNs'
);

select is(
  (
    select count(*)
    from public.push_devices
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
  ),
  2::bigint,
  'sandbox and production registrations remain distinct'
);

select throws_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000001',
      'sandbox',
      decode(repeat('ef', 32), 'hex')
    )$$,
  '23505',
  NULL,
  'a user has one registration per installation and APNs environment'
);

select throws_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000002',
      'sandbox',
      decode('', 'hex')
    )$$,
  '23514',
  NULL,
  'an empty APNs token is rejected'
);

select throws_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000003',
      'development',
      decode(repeat('01', 32), 'hex')
    )$$,
  '22P02',
  NULL,
  'a non-APNs environment is rejected'
);

select throws_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token,
      preview_mode
    ) values (
      '11111111-1111-1111-1111-111111111111',
      '10000000-0000-0000-0000-000000000004',
      'sandbox',
      decode(repeat('02', 32), 'hex'),
      'full'
    )$$,
  '22P02',
  NULL,
  'an unknown notification preview mode is rejected'
);

select throws_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '99999999-9999-9999-9999-999999999999',
      '90000000-0000-0000-0000-000000000001',
      'sandbox',
      decode(repeat('03', 32), 'hex')
    )$$,
  '23503',
  NULL,
  'a device registration requires an existing profile'
);

select lives_ok(
  $$update public.push_devices
    set token = decode(repeat('ef', 32), 'hex'), last_seen_at = now()
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'$$,
  'an APNs token can rotate for an existing registration'
);

select is(
  (
    select encode(token, 'hex')
    from public.push_devices
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'
  ),
  repeat('ef', 32),
  'the latest opaque APNs token is stored'
);

select lives_ok(
  $$update public.push_devices
    set preview_mode = 'detailed'
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'$$,
  'a user can opt in to detailed notification previews'
);

select is(
  (
    select preview_mode::text
    from public.push_devices
    where user_id = '11111111-1111-1111-1111-111111111111'
      and installation_id = '10000000-0000-0000-0000-000000000001'
      and environment = 'sandbox'
  ),
  'detailed',
  'the detailed preview preference is stored'
);

select lives_ok(
  $$insert into public.push_devices (
      user_id,
      installation_id,
      environment,
      token
    ) values (
      '22222222-2222-2222-2222-222222222222',
      '20000000-0000-0000-0000-000000000001',
      'sandbox',
      decode(repeat('04', 32), 'hex')
    )$$,
  'another profile can register a push device'
);

delete from public.profiles
where user_id = '22222222-2222-2222-2222-222222222222';

select is_empty(
  $$select 1 from public.push_devices
    where user_id = '22222222-2222-2222-2222-222222222222'$$,
  'deleting a profile deletes its push-device registrations'
);

select * from finish();

rollback;
