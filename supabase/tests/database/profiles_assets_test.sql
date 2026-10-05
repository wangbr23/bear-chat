begin;

select plan(55);

select has_table('public', 'profiles', 'the profiles table exists');

select columns_are(
  'public',
  'profiles',
  array['user_id', 'display_name', 'appearance', 'revision', 'created_at', 'updated_at', 'deleted_at']
);

select col_type_is(
  'public',
  'profiles',
  'user_id',
  'uuid',
  'profiles.user_id is a uuid'
);

select col_type_is(
  'public',
  'profiles',
  'display_name',
  'bounded_display_name',
  'profiles.display_name uses the bounded display name domain'
);

select col_type_is(
  'public',
  'profiles',
  'appearance',
  'jsonb',
  'profiles.appearance is jsonb'
);

select col_type_is(
  'public',
  'profiles',
  'revision',
  'positive_bigint',
  'profiles.revision uses the positive bigint domain'
);

select col_type_is(
  'public',
  'profiles',
  'created_at',
  'timestamp with time zone',
  'profiles.created_at is a timestamptz'
);

select col_type_is(
  'public',
  'profiles',
  'updated_at',
  'timestamp with time zone',
  'profiles.updated_at is a timestamptz'
);

select col_type_is(
  'public',
  'profiles',
  'deleted_at',
  'timestamp with time zone',
  'profiles.deleted_at is a timestamptz'
);

select col_not_null(
  'public',
  'profiles',
  'user_id',
  'profiles.user_id is not null'
);

select col_not_null(
  'public',
  'profiles',
  'display_name',
  'profiles.display_name is not null'
);

select col_not_null(
  'public',
  'profiles',
  'appearance',
  'profiles.appearance is not null'
);

select col_not_null(
  'public',
  'profiles',
  'revision',
  'profiles.revision is not null'
);

select col_not_null(
  'public',
  'profiles',
  'created_at',
  'profiles.created_at is not null'
);

select col_not_null(
  'public',
  'profiles',
  'updated_at',
  'profiles.updated_at is not null'
);

select col_is_null(
  'public',
  'profiles',
  'deleted_at',
  'profiles.deleted_at is nullable'
);

select col_is_pk(
  'public',
  'profiles',
  'user_id',
  'profiles.user_id is the primary key'
);

select has_fk(
  'public',
  'profiles',
  'profiles has a foreign key'
);

select fk_ok(
  'public',
  'profiles',
  'user_id',
  'auth',
  'users',
  'id',
  'profiles.user_id references auth.users(id)'
);

select has_table(
  'public',
  'asset_catalog_entries',
  'the asset catalog entries table exists'
);

select columns_are(
  'public',
  'asset_catalog_entries',
  array['catalog_version', 'kind', 'semantic_id', 'compatibility', 'is_active', 'created_at']
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'catalog_version',
  'text',
  'asset_catalog_entries.catalog_version is text'
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'kind',
  'text',
  'asset_catalog_entries.kind is text'
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'semantic_id',
  'text',
  'asset_catalog_entries.semantic_id is text'
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'compatibility',
  'jsonb',
  'asset_catalog_entries.compatibility is jsonb'
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'is_active',
  'boolean',
  'asset_catalog_entries.is_active is boolean'
);

select col_type_is(
  'public',
  'asset_catalog_entries',
  'created_at',
  'timestamp with time zone',
  'asset_catalog_entries.created_at is a timestamptz'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'catalog_version',
  'asset_catalog_entries.catalog_version is not null'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'kind',
  'asset_catalog_entries.kind is not null'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'semantic_id',
  'asset_catalog_entries.semantic_id is not null'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'compatibility',
  'asset_catalog_entries.compatibility is not null'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'is_active',
  'asset_catalog_entries.is_active is not null'
);

select col_not_null(
  'public',
  'asset_catalog_entries',
  'created_at',
  'asset_catalog_entries.created_at is not null'
);

select col_default_is(
  'public',
  'asset_catalog_entries',
  'is_active',
  'true',
  'asset_catalog_entries.is_active defaults to true'
);

select col_is_pk(
  'public',
  'asset_catalog_entries',
  ARRAY['catalog_version', 'kind', 'semantic_id'],
  'asset_catalog_entries has the version, kind, and id composite key'
);

insert into auth.users (id, email)
values
  ('11111111-1111-1111-1111-111111111111', 't41-bear-one@example.com'),
  ('22222222-2222-2222-2222-222222222222', 't41-bear-two@example.com');

select lives_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  'a valid profile row is accepted'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23505',
  NULL,
  'a duplicate profile user_id is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '33333333-3333-3333-3333-333333333333',
      'Bear Ghost',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23503',
  NULL,
  'a profile for an unknown auth user is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      repeat('a', 31),
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a 31-character display name is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      0
    )$$,
  '23514',
  NULL,
  'a zero profile revision is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'an appearance without schemaVersion is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":0,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a zero appearance schema version is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1.5,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a non-integer appearance schema version is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":null,"faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a null appearance body id is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":"","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'an empty appearance body id is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":"none","accessoryIDs":[]}'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a non-array clothing id list is rejected'
);

select lives_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '22222222-2222-2222-2222-222222222222',
      'Bear Two',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[],"futureField":true}'::jsonb,
      1
    )$$,
  'extra appearance keys are accepted so newer schema versions stay forward-compatible'
);

select lives_ok(
  $$insert into public.asset_catalog_entries (catalog_version, kind, semantic_id, compatibility)
    values ('appearance-v1', 'body', 'body-brown', '{"requires":[]}'::jsonb)$$,
  'a valid asset catalog entry is accepted'
);

select is(
  (
    select is_active
    from public.asset_catalog_entries
    where catalog_version = 'appearance-v1'
      and kind = 'body'
      and semantic_id = 'body-brown'
  ),
  true,
  'an omitted is_active defaults to true'
);

select throws_ok(
  $$insert into public.asset_catalog_entries (catalog_version, kind, semantic_id, compatibility)
    values ('appearance-v1', 'body', 'body-brown', '{"requires":[]}'::jsonb)$$,
  '23505',
  NULL,
  'a duplicate catalog version, kind, and id is rejected'
);

select throws_ok(
  $$insert into public.asset_catalog_entries (catalog_version, kind, semantic_id, compatibility)
    values ('appearance-v1', 'face', 'face-happy', NULL)$$,
  '23502',
  NULL,
  'a null compatibility document is rejected'
);

select throws_ok(
  $$insert into public.asset_catalog_entries (catalog_version, kind, semantic_id, compatibility)
    values ('appearance-v1', NULL, 'face-happy', '{"requires":[]}'::jsonb)$$,
  '23502',
  NULL,
  'a null catalog kind is rejected'
);

select throws_ok(
  $$insert into public.asset_catalog_entries (catalog_version, kind, semantic_id, compatibility, is_active)
    values ('appearance-v1', 'face', 'face-happy', '{"requires":[]}'::jsonb, NULL)$$,
  '23502',
  NULL,
  'a null is_active flag is rejected'
);

select throws_ok(
  $$insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '11111111-1111-1111-1111-111111111111',
      'Bear One',
      '5'::jsonb,
      1
    )$$,
  '23514',
  NULL,
  'a scalar appearance document is rejected'
);

select * from finish();

rollback;
