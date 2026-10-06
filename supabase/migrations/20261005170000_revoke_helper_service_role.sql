-- Corrects T52: the authorization helpers revoked only the PUBLIC grant, but
-- Supabase's default privileges also grant EXECUTE on new public functions
-- to service_role. service_role bypasses RLS and no planned surface calls
-- the helpers, so the T52 decision is that it holds no EXECUTE on them.

revoke execute on function public.is_room_member(uuid) from service_role;
revoke execute on function public.is_room_owner(uuid) from service_role;
