begin;

select plan(16);

-- Structural contract: RLS is on, clients hold only the read grant, and the
-- read policy is the table's only policy.
select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true,
  'profiles has row level security enabled'
);

select table_privs_are(
  'public',
  'profiles',
  'anon',
  '{}'::text[],
  'anon holds no privileges on profiles'
);
select table_privs_are(
  'public',
  'profiles',
  'authenticated',
  array['SELECT'],
  'authenticated callers may only read profiles'
);

select policies_are(
  'public',
  'profiles',
  array['profiles_select_self_or_room_peer'],
  'profiles exposes only the self-or-room-peer read policy'
);

-- Behavioral fixture: a caller, a roommate, a stranger in a separate room,
-- and a deleted roommate who still holds a membership row.
insert into auth.users (id, email)
values
  ('53530000-0000-0000-0000-000000000001', 't53-self@example.com'),
  ('53530000-0000-0000-0000-000000000002', 't53-roommate@example.com'),
  ('53530000-0000-0000-0000-000000000003', 't53-stranger@example.com'),
  ('53530000-0000-0000-0000-000000000004', 't53-deleted@example.com');

insert into public.profiles (user_id, display_name, appearance, revision, deleted_at)
values
  (
    '53530000-0000-0000-0000-000000000001',
    'Self Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1,
    null
  ),
  (
    '53530000-0000-0000-0000-000000000002',
    'Roommate Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1,
    null
  ),
  (
    '53530000-0000-0000-0000-000000000003',
    'Stranger Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1,
    null
  ),
  (
    '53530000-0000-0000-0000-000000000004',
    'Deleted Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1,
    now()
  );

insert into public.rooms (id, name, owner_id)
values
  ('53530000-0000-0000-0000-000000000aa1', 'Shared Lodge', '53530000-0000-0000-0000-000000000001'),
  ('53530000-0000-0000-0000-000000000aa2', 'Stranger Lodge', '53530000-0000-0000-0000-000000000003');

insert into public.room_members (room_id, user_id, role)
values
  ('53530000-0000-0000-0000-000000000aa1', '53530000-0000-0000-0000-000000000001', 'owner'),
  ('53530000-0000-0000-0000-000000000aa1', '53530000-0000-0000-0000-000000000002', 'member'),
  ('53530000-0000-0000-0000-000000000aa1', '53530000-0000-0000-0000-000000000004', 'member'),
  ('53530000-0000-0000-0000-000000000aa2', '53530000-0000-0000-0000-000000000003', 'owner');

-- Every behavioral check below runs as a client role so RLS applies.
set local role authenticated;

-- The caller sees themself and their live roommate, but not the stranger
-- or the deleted roommate.
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000001", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000001', true);

select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
    order by user_id
  $$,
  $$
    values
      ('53530000-0000-0000-0000-000000000001'::uuid),
      ('53530000-0000-0000-0000-000000000002'::uuid)
  $$,
  'a caller sees their own profile and live roommates only'
);

-- Direct writes are denied even against the caller's own row.
select throws_ok(
  $$
    insert into public.profiles (user_id, display_name, appearance, revision)
    values (
      '53530000-0000-0000-0000-000000000001',
      'Forged Bear',
      '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
      1
    )
  $$,
  '42501',
  null,
  'a client cannot insert a profile directly'
);
select throws_ok(
  $$
    update public.profiles
    set display_name = 'Renamed Bear'
    where user_id = '53530000-0000-0000-0000-000000000001'
  $$,
  '42501',
  null,
  'a client cannot update even their own profile directly'
);
select throws_ok(
  $$
    delete from public.profiles
    where user_id = '53530000-0000-0000-0000-000000000001'
  $$,
  '42501',
  null,
  'a client cannot delete a profile directly'
);

-- Visibility is symmetric between live roommates.
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000002", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000002', true);

select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
    order by user_id
  $$,
  $$
    values
      ('53530000-0000-0000-0000-000000000001'::uuid),
      ('53530000-0000-0000-0000-000000000002'::uuid)
  $$,
  'a roommate sees the caller but not the deleted roommate'
);

-- A stranger who shares no room sees only themself.
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000003", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000003', true);

select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
  $$,
  $$ values ('53530000-0000-0000-0000-000000000003'::uuid) $$,
  'a caller who shares no room sees only their own profile'
);

-- A deleted profile is hidden even from its owner. Denying the deleted
-- account's other reads is T59's deletion-pending layer, not this policy.
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000004", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000004', true);

select is_empty(
  $$
    select user_id
    from public.profiles
    where user_id = '53530000-0000-0000-0000-000000000004'
  $$,
  'a deleted profile is hidden from its own owner'
);

-- A signed-in caller with no profile row sees nothing and cannot guess one.
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-0000000000ff", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-0000000000ff', true);

select is_empty(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
  $$,
  'a caller who belongs to no room sees no other profiles'
);

-- Removing a membership ends profile visibility immediately (INV-12).
reset role;

delete from public.room_members
where room_id = '53530000-0000-0000-0000-000000000aa1'
  and user_id = '53530000-0000-0000-0000-000000000002';

set local role authenticated;
select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000001", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000001', true);

select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
  $$,
  $$ values ('53530000-0000-0000-0000-000000000001'::uuid) $$,
  'a removed roommate disappears from the owner''s view immediately'
);

select set_config('request.jwt.claims', '{"sub": "53530000-0000-0000-0000-000000000002", "role": "authenticated"}', true);
select set_config('request.jwt.claim.sub', '53530000-0000-0000-0000-000000000002', true);

select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id::text like '53530000-%'
  $$,
  $$ values ('53530000-0000-0000-0000-000000000002'::uuid) $$,
  'a removed member loses sight of former roommates immediately'
);

-- Signed-out callers have no table access at all.
reset role;
set local role anon;
select set_config('request.jwt.claims', '{"role": "anon"}', true);
select set_config('request.jwt.claim.sub', '', true);

select throws_ok(
  $$ select user_id from public.profiles $$,
  '42501',
  null,
  'anon cannot read profiles'
);
select throws_ok(
  $$
    update public.profiles
    set display_name = 'Anon Bear'
    where user_id = '53530000-0000-0000-0000-000000000001'
  $$,
  '42501',
  null,
  'anon cannot write profiles'
);

reset role;

select * from finish();

rollback;
