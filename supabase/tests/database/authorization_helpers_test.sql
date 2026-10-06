begin;

select plan(37);

-- Structural contract: both helpers exist, answer booleans in plain SQL,
-- run as their owner, are stable, and pin an empty search path.
select has_function('public', 'is_room_member', 'the membership helper exists');
select has_function('public', 'is_room_owner', 'the ownership helper exists');

select function_returns(
  'public',
  'is_room_member',
  'boolean',
  'the membership helper answers a boolean'
);
select function_returns(
  'public',
  'is_room_owner',
  'boolean',
  'the ownership helper answers a boolean'
);

select function_lang_is(
  'public',
  'is_room_member',
  'sql',
  'the membership helper is a plain SQL function'
);
select function_lang_is(
  'public',
  'is_room_owner',
  'sql',
  'the ownership helper is a plain SQL function'
);

select is_definer(
  'public',
  'is_room_member',
  'the membership helper reads membership as its definer owner'
);
select is_definer(
  'public',
  'is_room_owner',
  'the ownership helper reads membership as its definer owner'
);

select is(
  (
    select provolatile::text
    from pg_proc
    where oid = 'public.is_room_member(uuid)'::regprocedure
  ),
  's',
  'the membership helper is stable so policy evaluation can cache it'
);
select is(
  (
    select provolatile::text
    from pg_proc
    where oid = 'public.is_room_owner(uuid)'::regprocedure
  ),
  's',
  'the ownership helper is stable so policy evaluation can cache it'
);

select is(
  (
    select proconfig::text[]
    from pg_proc
    where oid = 'public.is_room_member(uuid)'::regprocedure
  ),
  array['search_path=""']::text[],
  'the membership helper pins an empty search path'
);
select is(
  (
    select proconfig::text[]
    from pg_proc
    where oid = 'public.is_room_owner(uuid)'::regprocedure
  ),
  array['search_path=""']::text[],
  'the ownership helper pins an empty search path'
);

-- Least-privilege grants: policy expressions evaluate with the calling
-- client role's privileges, so anon and authenticated both need EXECUTE
-- (the helpers answer false for anon); PUBLIC and service_role get none.
select function_privs_are(
  'public',
  'is_room_member',
  'anon',
  array['EXECUTE'],
  'anon can execute the membership helper for policy evaluation'
);
select function_privs_are(
  'public',
  'is_room_member',
  'authenticated',
  array['EXECUTE'],
  'authenticated callers execute the membership helper'
);
select function_privs_are(
  'public',
  'is_room_member',
  'service_role',
  '{}'::text[],
  'service_role does not execute the membership helper'
);
select function_privs_are(
  'public',
  'is_room_member',
  'public',
  '{}'::text[],
  'public does not execute the membership helper'
);
select function_privs_are(
  'public',
  'is_room_owner',
  'anon',
  array['EXECUTE'],
  'anon can execute the ownership helper for policy evaluation'
);
select function_privs_are(
  'public',
  'is_room_owner',
  'authenticated',
  array['EXECUTE'],
  'authenticated callers execute the ownership helper'
);
select function_privs_are(
  'public',
  'is_room_owner',
  'service_role',
  '{}'::text[],
  'service_role does not execute the ownership helper'
);
select function_privs_are(
  'public',
  'is_room_owner',
  'public',
  '{}'::text[],
  'public does not execute the ownership helper'
);

-- Behavioral fixture: an owner, a fellow member, and an outsider who owns
-- a second room of their own.
insert into auth.users (id, email)
values
  ('52520000-0000-0000-0000-000000000001', 't52-owner@example.com'),
  ('52520000-0000-0000-0000-000000000002', 't52-member@example.com'),
  ('52520000-0000-0000-0000-000000000003', 't52-outsider@example.com');

insert into public.profiles (user_id, display_name, appearance, revision)
values
  (
    '52520000-0000-0000-0000-000000000001',
    'Owner Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '52520000-0000-0000-0000-000000000002',
    'Member Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  ),
  (
    '52520000-0000-0000-0000-000000000003',
    'Outsider Bear',
    '{"schemaVersion":1,"bodyID":"body-brown","faceID":"face-happy","furColorID":"fur-brown","accentColorID":"accent-red","clothingIDs":[],"accessoryIDs":[]}'::jsonb,
    1
  );

insert into public.rooms (id, name, owner_id)
values
  ('52520000-0000-0000-0000-000000000aa1', 'Helpers Lodge', '52520000-0000-0000-0000-000000000001'),
  ('52520000-0000-0000-0000-000000000aa2', 'Outsider Lodge', '52520000-0000-0000-0000-000000000003');

insert into public.room_members (room_id, user_id, role)
values
  ('52520000-0000-0000-0000-000000000aa1', '52520000-0000-0000-0000-000000000001', 'owner'),
  ('52520000-0000-0000-0000-000000000aa1', '52520000-0000-0000-0000-000000000002', 'member'),
  ('52520000-0000-0000-0000-000000000aa2', '52520000-0000-0000-0000-000000000003', 'owner');

-- An unauthenticated caller has no identity and no membership.
select set_config('request.jwt.claims', '{}', true);
select set_config('request.jwt.claim.sub', '', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'an unauthenticated caller is not a room member'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'an unauthenticated caller is not a room owner'
);

-- A signed-in nonmember is rejected by both helpers.
select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000003"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000003', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'a nonmember is not a room member'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'a nonmember is not a room owner'
);

-- A plain member passes INV-1 but not the owner check.
select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000002"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000002', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa1'::uuid),
  true,
  'a current member counts as a room member'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'a plain member does not count as the room owner'
);

-- The owner passes both helpers through the owner role row (INV-3).
select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000001"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000001', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa1'::uuid),
  true,
  'the owner counts as a current member'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa1'::uuid),
  true,
  'the owner role row answers the ownership helper'
);

-- The helpers are room-scoped: owning one room grants nothing elsewhere.
select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa2'::uuid),
  false,
  'membership in another room does not leak across rooms'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa2'::uuid),
  false,
  'the ownership helper does not answer for rooms the caller does not own'
);

select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000003"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000003', true);

select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa2'::uuid),
  true,
  'the outsider is the owner of their own room'
);

-- Unknown and null room ids answer false rather than leaking a match.
select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000001"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000001', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000ff1'::uuid),
  false,
  'an unknown room id is not a member answer'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000ff1'::uuid),
  false,
  'an unknown room id is not an owner answer'
);
select is(
  public.is_room_member(null::uuid),
  false,
  'a null room id is not a member answer'
);
select is(
  public.is_room_owner(null::uuid),
  false,
  'a null room id is not an owner answer'
);

-- Removal ends access immediately (INV-12): the membership row is gone,
-- so both helpers reject the former member without any other step.
delete from public.room_members
where room_id = '52520000-0000-0000-0000-000000000aa1'::uuid
  and user_id = '52520000-0000-0000-0000-000000000002'::uuid;

select set_config('request.jwt.claims', '{"sub": "52520000-0000-0000-0000-000000000002"}', true);
select set_config('request.jwt.claim.sub', '52520000-0000-0000-0000-000000000002', true);

select is(
  public.is_room_member('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'a removed member loses member access immediately'
);
select is(
  public.is_room_owner('52520000-0000-0000-0000-000000000aa1'::uuid),
  false,
  'a removed member loses owner access immediately'
);

select * from finish();

rollback;
