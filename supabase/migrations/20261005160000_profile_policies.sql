-- Profile visibility and direct-write denial (T53), building on the T41
-- profiles table and the T52 authorization helpers.
--
-- A signed-in caller can read a profile only when it is not deleted and it
-- is either their own or belongs to someone who shares at least one room
-- with them. Deleted profiles are hidden from everyone, including their
-- owner; deletion-pending sign-in denial stays with T59.
--
-- The shared-room check reads room_members with the caller's own
-- privileges, so once T54 adds room_members policies a caller still only
-- sees co-members of rooms they belong to. is_room_member keeps the check
-- scoped to the caller's rooms, independent of how those policies evolve.
--
-- Clients never write profiles directly: creation and edits go through the
-- protected update_profile function (T60), which validates appearance
-- against the asset allowlist and compare-and-swaps the revision. Supabase's
-- default privileges grant every table operation to anon and authenticated,
-- so those are revoked first and only SELECT is granted back to
-- authenticated. anon gets nothing. service_role keeps its defaults because
-- it bypasses RLS and the notification Edge Function reads profiles.
--
-- RLS is enabled without FORCE, matching the T52 note that the definer
-- helpers rely on the table owner reading rows unrestricted.

alter table public.profiles enable row level security;

revoke all on table public.profiles from anon;
revoke all on table public.profiles from authenticated;

grant select on table public.profiles to authenticated;

create policy profiles_select_self_or_room_peer
on public.profiles
for select
to authenticated
using (
  deleted_at is null
  and (
    user_id = (select auth.uid())
    or exists (
      select 1
      from public.room_members peer
      where peer.user_id = profiles.user_id
        and public.is_room_member(peer.room_id)
    )
  )
);
