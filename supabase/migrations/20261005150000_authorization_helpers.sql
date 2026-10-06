-- Stable authorization helpers (T52), building on the T42 rooms and
-- memberships schema. Every RLS policy migration (T53-T59) and protected
-- mutation function (T60+) answers INV-1 and INV-3 through these two
-- functions instead of re-encoding membership SQL per table:
--
--   is_room_member  — INV-1: the caller has a room_members row for the room.
--                     Membership rows cascade away on removal or room
--                     deletion, so access ends immediately (INV-12).
--   is_room_owner   — INV-3: the caller holds the owner role row for the
--                     room. The partial unique index allows at most one
--                     owner row per room, and the protected transactions
--                     (T61 creation, T67 transfer) keep rooms.owner_id
--                     equal to that row, so the membership row is the
--                     authoritative ownership artifact and no join to
--                     rooms is needed.
--
-- Both functions are SECURITY DEFINER with a pinned empty search_path so
-- policy evaluation reads membership rows directly, independent of the
-- rooms'/room_members' own policies. That makes the helpers recursion-free
-- by construction, but it also means the RLS migrations must enable RLS
-- without FORCE on the membership tables (or otherwise keep the definer
-- owner able to read membership rows); forcing RLS onto the table owner
-- would strip these helpers of their read context.
--
-- Account deletion deliberately adds its own access-denial layer (T59):
-- profiles.deleted_at is not consulted here so deletion-pending denial
-- stays policy work, not helper work.
--
-- EXECUTE is granted to anon and authenticated — RLS policy expressions
-- evaluate with the calling client role's privileges, so anon must be able
-- to execute them; the helpers answer false without a JWT, so anon gains
-- nothing (deny-by-default stays correct even if a policy ever runs for
-- anon). The PUBLIC default grant is revoked and service_role gets nothing:
-- it bypasses RLS entirely and no planned surface calls the helpers.
-- Helpers return booleans only and never disclose rows.

create function public.is_room_member(target_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.room_members member
    where member.room_id = target_room_id
      and member.user_id = auth.uid()
  )
$$;

create function public.is_room_owner(target_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.room_members member
    where member.room_id = target_room_id
      and member.user_id = auth.uid()
      and member.role = 'owner'
  )
$$;

revoke execute on function public.is_room_member(uuid) from public;
revoke execute on function public.is_room_owner(uuid) from public;

grant execute on function public.is_room_member(uuid) to anon;
grant execute on function public.is_room_member(uuid) to authenticated;
grant execute on function public.is_room_owner(uuid) to anon;
grant execute on function public.is_room_owner(uuid) to authenticated;
